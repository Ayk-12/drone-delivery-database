CREATE TABLE IF NOT EXISTS Person(
	SSN VARCHAR(11),
    person_name VARCHAR(50),
    email VARCHAR(100),
    PRIMARY KEY (SSN),
    UNIQUE (email)
    );
    
CREATE TABLE IF NOT EXISTS Base(
Base_ID int,
occupant_count int,
capacity_total int,
PRIMARY KEY (Base_ID),
CHECK (occupant_count >= 0),
CHECK (capacity_total >= 0),
CHECK (occupant_count <= capacity_total)
);

CREATE TABLE IF NOT EXISTS Drone(
drone_ID int,
payload_limit int,
battery_cap int,
expected_charge_time time,
current_status varchar(50),
last_maint_date date,
Base_ID int NOT NULL,
PRIMARY KEY (drone_ID),
FOREIGN KEY (Base_ID) REFERENCES Base(Base_ID) ON DELETE SET NULL,
CHECK (battery_cap BETWEEN 0 AND 100)
);

CREATE TABLE IF NOT EXISTS Technician(
SSN VARCHAR(11), 
start_date date,
salary INT,
PRIMARY KEY (SSN),
FOREIGN KEY (SSN) REFERENCES Person(SSN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Drone_Operator(
SSN VARCHAR(11), 
specialization VARCHAR(50),
start_date date,
salary INT,
PRIMARY KEY (SSN),
FOREIGN KEY (SSN) REFERENCES Person(SSN) ON DELETE CASCADE,
CHECK (salary > 0)
);

CREATE TABLE IF NOT EXISTS Customer(
SSN VARCHAR(11), 
address_long decimal(9,6),
address_lat decimal(9,6),
payment_method varchar(50),
tokens INT,
PRIMARY KEY (SSN),
FOREIGN KEY (SSN) REFERENCES Person(SSN) ON DELETE CASCADE,
CHECK (tokens >= 0)
);

CREATE TABLE IF NOT EXISTS Route(
Route_ID int,
start_lat decimal(10,7),
start_long decimal(10,7),
end_lat decimal(10,7),
end_long decimal(10,7),
EFT int,
PRIMARY KEY (Route_ID)
);

CREATE TABLE IF NOT EXISTS Waypoint(
waypoint_id int auto_increment,
w_long decimal(9,6),
w_lat decimal(9,6),
PRIMARY KEY (waypoint_id)
);

CREATE TABLE IF NOT EXISTS Zone(
Zip_Code VARCHAR(5),
zone_name varchar(50),
radius int,
PRIMARY KEY (Zip_Code),
CHECK (radius > 0)
);

CREATE TABLE IF NOT EXISTS FlyZone(
fly_zip varchar(5),
terrain_type varchar(50),
PRIMARY KEY (fly_zip),
FOREIGN KEY (fly_zip) REFERENCES Zone(Zip_Code) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS noFlyZone(
no_fly_zip varchar(5),
no_fly_zone varchar(50),
PRIMARY KEY (no_fly_zip),
foreign key (no_fly_zip) REFERENCES Zone(Zip_Code) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS FlightLog(
Log_ID int,
log_time time,
log_longitude decimal(9,6),
log_latitude decimal(9,6),
log_altitude decimal(9,6),
battery_level int,
obstacle_detected varchar(150),
speed int,
PRIMARY KEY (Log_ID),
CHECK (battery_level BETWEEN 0 AND 100),
CHECK (speed between 0 and 360)
);

CREATE TABLE IF NOT EXISTS Delivery_Order(
Order_Num INT,
pickup_long decimal(10,7),
pickup_lat decimal(10,7),
dropoff_long decimal(10,7),
dropoff_lat decimal(10,7),
request_time time,
scheduled_delivery_ts time,
del_status varchar(50),
priority_flag varchar(50),
weight int,
orderCustomerSSN varchar(11),
carrierDroneID INT,
FOREIGN KEY (orderCustomerSSN) REFERENCES Customer(SSN) ON DELETE CASCADE,
PRIMARY KEY (orderCustomerSSN, Order_Num),
FOREIGN KEY (carrierDroneID) REFERENCES Drone(drone_ID) ON DELETE CASCADE,
CHECK (weight > 0)
);

CREATE TABLE IF NOT EXISTS Feedback(
time_stamp time,
rating INT,
comments VARCHAR(250),
CHECK (rating BETWEEN 1 AND 5),
customerSSN VARCHAR(11),
OrderNum int,
PRIMARY KEY (customerSSN, time_stamp),
FOREIGN KEY (customerSSN, OrderNum) REFERENCES Delivery_Order(orderCustomerSSN, Order_num) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Maintenance_Record(
Maintenance_num int,
record_description varchar(200),
maintenance_date date,
maintenance_status varchar(20),
maintenance_drone_id int NOT NULL,
technicianSSN varchar(11),
PRIMARY KEY (technicianSSN, Maintenance_num),
FOREIGN KEY (technicianSSN) REFERENCES Technician(SSN) ON DELETE CASCADE,
FOREIGN KEY (maintenance_drone_id) REFERENCES Drone(drone_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ZoneContainsWaypoint(
waypoint_id int,
zone_zip varchar(10),
PRIMARY KEY (waypoint_id, zone_zip),
FOREIGN KEY (zone_zip) REFERENCES Zone(Zip_Code) ON DELETE CASCADE,
FOREIGN KEY (waypoint_id) REFERENCES Waypoint(waypoint_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RouteContainsFlyZone(
Route_ID int,
fly_zone_zip varchar(10),
PRIMARY KEY (Route_ID, fly_zone_zip),
FOREIGN KEY (fly_zone_zip) REFERENCES FlyZone(fly_zip) ON DELETE CASCADE,
FOREIGN KEY (Route_ID) REFERENCES Route(Route_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RouteAvoidsNoFlyZone(
Route_ID int,
no_fly_zone_zip varchar(10),
PRIMARY KEY (Route_ID, no_fly_zone_zip),
FOREIGN KEY (no_fly_zone_zip) REFERENCES NoFlyZone(no_fly_zip) ON DELETE CASCADE,
FOREIGN KEY (Route_ID) REFERENCES Route(Route_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DroneRoute_FlightLog(
log_id int,
route_id int,
drone_id int,
PRIMARY KEY (log_id, route_id, drone_id),
FOREIGN KEY (route_id) REFERENCES Route(Route_ID) ON DELETE CASCADE,
FOREIGN KEY (log_id) REFERENCES FlightLog(Log_ID) ON DELETE CASCADE,
FOREIGN KEY (drone_id) REFERENCES Drone(drone_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS operatorOperates(
drone_id int,
operatorSSN varchar(11),
PRIMARY KEY (operatorSSN, drone_id),
FOREIGN KEY (drone_id) REFERENCES Drone(drone_ID) ON DELETE CASCADE,
FOREIGN KEY (operatorSSN) REFERENCES Drone_Operator(SSN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS phoneNums(
SSN VARCHAR(11),
phone VARCHAR(9), 
PRIMARY KEY (SSN, phone),
FOREIGN KEY (SSN) REFERENCES Person(SSN) ON DELETE CASCADE
);