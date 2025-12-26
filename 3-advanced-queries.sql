/*==========================================================
1) Set Membership Nested Query
Find all the drones that have not delivered anything yet.
==========================================================*/
SELECT drone_ID
FROM Drone
WHERE drone_ID NOT IN (SELECT DISTINCT carrierDroneID
					   FROM Delivery_Order);

/*==========================================================
2.1) Set Comparison Nested Query
Find the base with the most amount vacant space for drones.
==========================================================*/
SELECT Base_ID, b1.capacity_total - b1.occupant_count AS space_available
FROM Base b1
WHERE b1.capacity_total - b1.occupant_count > ALL (SELECT b2.capacity_total - b2.occupant_count
												   FROM Base b2
												   WHERE b1.base_id != b2.base_id);

/*==========================================================
2.2) Set Comparison Nested Query
Find no-fly zones with radii larger than any allowed fly zone radius.
These zones are larger than at least one safe fly zone.
==========================================================*/
SELECT z.zone_name, z.Zip_Code, z.radius
FROM Zone z JOIN noFlyZone nf ON(z.Zip_Code = nf.no_fly_zip)
WHERE z.radius > ANY (SELECT radius
					  FROM Zone z2 JOIN FlyZone fz ON(z2.Zip_Code = fz.fly_zip))
ORDER BY z.zone_name;

/*==========================================================
3.1) Set Cardinality Nested Query
Find all the drones that have no maintenance record in the database.
==========================================================*/
SELECT d.drone_id, d.current_status, d.payload_limit
FROM Drone d
WHERE NOT EXISTS (SELECT *
				  FROM Maintenance_Record mr
				  WHERE d.drone_id = mr.maintenance_drone_id)
ORDER BY d.drone_id;

/*==========================================================
3.2) Set Cardinality Nested Query
Find all record description entries that are not unique.
The keyword 'UNIQUE' id not defined in MySQL.
Alternatively, the query can be recreated using basic query syntax.
==========================================================*/
-- SELECT m1.record_description
-- FROM Maintenance_Record m1
-- WHERE NOT UNIQUE (SELECT m2.record_description
-- 				  FROM Maintenance_Record m2
-- 				  WHERE m1.record_description = m2.record_description);
SELECT record_description
FROM Maintenance_Record
GROUP BY record_description
HAVING COUNT(*) > 1;

/*==========================================================
4) Nested Queries at Different Levels
Find routes that have a zone whose waypoints are not found in any other zone.
==========================================================*/
SELECT fz1.route_id, fz1.fly_zone_zip
FROM RouteContainsFlyZone fz1
WHERE fz1.fly_zone_zip IN (SELECT w1.zone_zip
						   FROM ZoneContainsWaypoint w1
						   WHERE w1.waypoint_id NOT IN (SELECT w2.waypoint_id
														FROM ZoneContainsWaypoint w2
														WHERE w1.zone_zip != w2.zone_zip));

/*==========================================================
5) Division Operator
Find customers who provided feeback for all their orders.
==========================================================*/
SELECT c.SSN, p.person_name
FROM Customer c JOIN Person p ON p.SSN = c.SSN
WHERE NOT EXISTS (SELECT o.Order_Num
				  FROM Delivery_Order o
				  WHERE o.orderCustomerSSN = c.SSN
                  EXCEPT
				  SELECT f.OrderNum
				  FROM Feedback f
				  WHERE f.customerSSN = c.SSN)
AND c.SSN IN (SELECT o2.orderCustomerSSN
			  FROM Delivery_order o2);

/*==========================================================
6) Nested Query in the 'FROM' Statement
Find the drones that have been maintained more times than
the average number of maintenances in the database (here, avg = 1).
==========================================================*/
SELECT d.drone_ID
FROM Drone d JOIN (SELECT maintenance_drone_id, COUNT(*) AS maint_count
				   FROM Maintenance_Record
				   GROUP BY maintenance_drone_id) m
ON d.drone_ID = m.maintenance_drone_id
WHERE m.maint_count > avg_maintenance_per_drone();

/*==========================================================
7) Nested Query in the 'SELECT' Statement
Find each drone's last maintenance date.
==========================================================*/
SELECT d.drone_ID, (SELECT MAX(mr.maintenance_date)
					FROM Maintenance_Record mr
					WHERE mr.maintenance_drone_id = d.drone_ID) AS last_maintenance_date
FROM Drone d
ORDER BY d.drone_id;

/*==========================================================
9) 'OUTER JOIN'
Find each route's no fly zones (if any).
==========================================================*/
SELECT *
FROM Route r NATURAL LEFT OUTER JOIN RouteAvoidsNoFlyZone ra
ORDER BY r.route_ID;



### UNCOMMENT TO TEST ###
-- SELECT SSN, salary AS prequery, start_date -- Check salaries before running the update query
-- FROM Technician;

-- /*==========================================================
-- 8) UPDATE Query with 'CASE'
-- Update the salaries of the technicians.
-- Add 5% if the technician's salary is less than 2,500 and if
-- they have been working since before 2022.
-- Set to 3,000 if salary less greater than 2,600.
-- ==========================================================*/
-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE Technician
-- SET salary = CASE
--     WHEN salary <= 2500 AND YEAR(start_date) < 2022
--          THEN salary * 1.05
--     WHEN salary >= 2600 AND salary < 3000
--          THEN 3000
--     ELSE salary
-- 	END;
-- SET SQL_SAFE_UPDATES = 1;

-- SELECT SSN, salary AS postquery, start_date -- Check salaries after running the update query
-- FROM Technician;



/*==========================================================
x) Extra Queries
Find all technicians who have worked on drones that have appeared in at least one flight log.
==========================================================*/
SELECT t.SSN, p.person_name
FROM Technician t JOIN Person p ON (t.SSN = p.SSN)
WHERE t.SSN IN (SELECT technicianSSN
				FROM Maintenance_Record
				WHERE maintenance_drone_id IN (SELECT drone_id
											   FROM DroneRoute_FlightLog));

/*==========================================================
x) Extra Queries
Find all the technicians who have worked most on drone maintenance.
==========================================================*/
SELECT person.person_name
FROM maintenance_record AS r1 JOIN person ON (technicianSSN = SSN)
WHERE r1.Maintenance_num = (SELECT MAX(r2.Maintenance_num)
							FROM maintenance_record AS r2);