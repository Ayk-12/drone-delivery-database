### This file contains all the advanced queries that need to be run once. ###

/*==========================================================
10) 'ASSERTION'
If the drone is charging, block the insert.
==========================================================*/
DELIMITER //
CREATE TRIGGER check_drone_not_charging
BEFORE INSERT ON OperatorOperates
FOR EACH ROW
BEGIN
    DECLARE status_value VARCHAR(50);

    SELECT current_status
    INTO status_value
    FROM Drone
    WHERE drone_ID = NEW.drone_ID;

    IF status_value = 'Charging' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot assign operator: Drone is currently charging.';
    END IF;
END//
DELIMITER ;

/*
CREATE ASSERTION no_charging_drone_assigned
CHECK (
    NOT EXISTS (
        SELECT *
        FROM OperatorOperates O
        JOIN Drone D ON O.drone_ID = D.drone_ID
        WHERE D.current_status = 'charging'
    )
);
*/



/*==========================================================
11.1) 'VIEW'
Finds all the people in the database, along with their information.
==========================================================*/
CREATE VIEW AllPeople AS (SELECT p.SSN, p.person_name, p.email, n.phone, get_role_of_SSN(p.SSN) AS role_in_db
						  FROM Person p NATURAL LEFT OUTER JOIN phoneNums n
                          ORDER BY role_in_db, p.person_name);

/*==========================================================
11.2) 'VIEW'
Finds all the employees in the database, along with their information.
==========================================================*/
CREATE VIEW AllEmployees AS (SELECT T.SSN, T.person_name, T.email, n.phone, T.start_date, T.salary, get_role_of_SSN(T.SSN) AS role_in_db
							 FROM  ((SELECT p1.SSN, p1.person_name, p1.email, te.start_date, te.salary
								     FROM Person p1 NATURAL JOIN Technician te)
									 UNION
									(SELECT p2.SSN, p2.person_name, p2.email, o.start_date, o.salary
									 FROM Person p2 NATURAL JOIN Drone_Operator o)) AS T
                                     NATURAL LEFT OUTER JOIN phoneNums n
                          ORDER BY role_in_db, T.person_name);

/*==========================================================
11.3) 'VIEW'
Finds the years of experience for all drone operators in the database.
==========================================================*/
CREATE VIEW oyearsOfExperience AS
SELECT
    SSN,
    start_date,
    TIMESTAMPDIFF(YEAR, start_date, CURDATE()) AS o_exp
FROM drone_operator;

/*==========================================================
11.4) 'VIEW'
Finds the years of experience for all technicians in the database.
==========================================================*/
CREATE VIEW tyearsOfExperience AS
SELECT
    SSN,
    start_date,
    TIMESTAMPDIFF(YEAR, start_date, CURDATE()) AS t_exp
FROM technician;



/*==========================================================
12) 'TRIGGER'
If the drone is under maintenance, block the insert.
==========================================================*/
DELIMITER //
CREATE TRIGGER prevent_delivery_for_maintenance_drone
BEFORE INSERT ON delivery_order
FOR EACH ROW
BEGIN
    DECLARE drone_status VARCHAR(50);

    SELECT current_status
    INTO drone_status
    FROM Drone
    WHERE drone_ID = NEW.carrierDroneID;

    
    IF drone_status = 'Maintenance' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create delivery: Drone is under maintenance.';
    END IF;
END//
DELIMITER ;



/*==========================================================
13.1) Function
Returns the average number of maintenances done on drones.
==========================================================*/
DELIMITER $$
CREATE FUNCTION avg_maintenance_per_drone() RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_maintenance INTEGER;
    DECLARE total_drones INTEGER;

    SELECT COUNT(*) 
    INTO total_maintenance
    FROM Maintenance_Record;

    SELECT COUNT(*) 
    INTO total_drones
    FROM Drone;

    IF total_drones = 0 THEN
        RETURN 0;
    END IF;

    RETURN total_maintenance / total_drones;
END$$
DELIMITER ;

/*==========================================================
13.2) Procedure
Returns the average number of maintenances done on drones.
Disable Safe Updates before execution, then reenable.
==========================================================*/
DELIMITER $$
CREATE PROCEDURE set_lowest_battery_drone_charging()
BEGIN
    UPDATE Drone
    SET current_status = 'Charging'
    WHERE battery_cap = (SELECT min_battery
						 FROM (SELECT MIN(battery_cap) AS min_battery
							   FROM Drone
                               WHERE current_status != 'Charging') t);
END$$
DELIMITER ;

/*==========================================================
13.3) Function
Returns the role of the person according to the database
(Customer, Technician, DroneOperator, Other).
==========================================================*/
DELIMITER $$
CREATE FUNCTION get_role_of_SSN(in_SSN VARCHAR(11)) RETURNS VARCHAR(13)
DETERMINISTIC
BEGIN
    IF EXISTS (SELECT *
			   FROM Person p NATURAL JOIN Customer c
               WHERE p.SSN = in_SSN)
		THEN RETURN 'Customer';
	ELSEIF EXISTS (SELECT *
				   FROM Person p NATURAL JOIN Technician t
                   WHERE p.SSN = in_SSN)
		THEN RETURN 'Technician';
	ELSEIF EXISTS (SELECT *
				   FROM Person p NATURAL JOIN Drone_Operator d
                   WHERE p.SSN = in_SSN)
		THEN RETURN 'DroneOperator';
	END IF;
    RETURN 'Other';
END$$
DELIMITER ;
