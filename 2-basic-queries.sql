/*==========================================================
BASIC QUERIES
==========================================================*/

/*==========================================================
1) Cartesian Product
Find all the drones that are charging currently.
==========================================================*/
SELECT d.drone_ID, d.current_status, o.operatorSSN
FROM Drone d, operatorOperates o
WHERE current_status = 'Charging' AND d.drone_ID = o.drone_id;

/*==========================================================
2) Natural Join
Find all the operators that specialize in drone operations.
==========================================================*/
SELECT p.person_name, p.email, o.specialization
FROM Drone_operator o NATURAL JOIN Person p
WHERE o.specialization LIKE "% operations";

/*==========================================================
3) Theta Join using "USING"
Find all the technicians whose salaries are greater than 2,500.
==========================================================*/
SELECT p.person_name, t.salary, t.start_date
FROM (Technician t JOIN Person p USING (SSN))
WHERE salary > 2500;

/*==========================================================
4) Theta Join using "ON"
Find all the waypoints in zones having their radius greater than 70.
==========================================================*/
SELECT z.zone_name, waypoint_id 
FROM waypoint w JOIN zonecontainswaypoint c USING (waypoint_id) JOIN zone z ON (zone_zip = Zip_Code)
WHERE z.radius > 70;

/*==========================================================
5) Self Join
Find all the customers that have the same delivery address.
==========================================================*/
SELECT C1.SSN AS Customer_1, C2.SSN AS Customer_2, C1.address_lat AS address_lat, C1.address_long AS address_long
FROM Customer C1 JOIN Customer C2 ON(C1.address_lat = C2.address_lat AND C1.address_long = C2.address_long AND C1.SSN < C2.SSN);

/*==========================================================
6) "DISTINCT"
Find all the possible priority flags an order can have.
==========================================================*/
SELECT DISTINCT priority_flag AS possible_flags
FROM delivery_order;

/*==========================================================
7) "LIKE"
Find all the maintenance instances that had to check something.
==========================================================*/
SELECT maintenance_status, record_description, technicianSSN, email
FROM maintenance_record m JOIN technician t ON (technicianSSN = SSN) JOIN person ON (technicianSSN = person.SSN)
WHERE record_description LIKE "% check";

/*==========================================================
8) "ORDER BY"
Find all the feedbacks of customers higher than 4 and order the ratings by descending order.
==========================================================*/
SELECT person_name AS customer_name, comments, OrderNum AS order_number, rating
FROM feedback JOIN person ON(customerSSN = SSN)
WHERE rating >= 4
ORDER BY (rating) DESC;

/*==========================================================
9) "UNION"
Find all the employees employed by the company (technicians and drone operators).
==========================================================*/
SELECT SSN, person_name AS employee_name
FROM Technician NATURAL JOIN Person
UNION
SELECT SSN, person_name
FROM Drone_Operator NATURAL JOIN Person;

/*==========================================================
10) "INTERSECT"
Find all the customers who submitted feedback.
==========================================================*/
SELECT orderCustomerSSN AS customers_feedback_ssn
FROM Delivery_Order
INTERSECT
SELECT customerSSN
FROM Feedback;

/*==========================================================
11) "EXCEPT"
Find all the customers who never submitted feedback.
==========================================================*/
SELECT orderCustomerSSN AS customers_no_feedback_ssn
FROM Delivery_Order
EXCEPT
SELECT customerSSN
FROM Feedback;

/*==========================================================
12) General Aggregate Function (without "GROUP BY")
Find the average rating of feedbacks.
==========================================================*/
SELECT AVG(rating) AS average_rating
FROM feedback;

/*==========================================================
13) Grouping Aggregate Function (with "GROUP BY")
Find the average rating of each customer separately.
==========================================================*/
SELECT person_name AS customer_name, AVG(rating) AS average_rating
FROM feedback JOIN person ON(customerSSN = SSN)
GROUP BY customerSSN;

/*==========================================================
14) Grouping Aggregate Function With Condition (with "GROUP BY" and "HAVING")
Find all the drones that carried more than one delivery order.
==========================================================*/
SELECT carrierDroneID AS drone_id, COUNT(*) AS total_orders
FROM Delivery_Order
GROUP BY carrierDroneID
HAVING COUNT(*) >= 2;