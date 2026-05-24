--TABLE 1
 CREATE TABLE Station(
 Station_ID SERIAL NOT NULL PRIMARY KEY,
 Station_Name VARCHAR(100) NOT NULL,
     -- Composite Location Attribute broken into atomic columns:
 City VARCHAR(50) NOT NULL,
 Sub_city VARCHAR(50) NOT NULL,
 Wereda VARCHAR(50) NOT NULL,
     -- Composite Daily Quota / Supply stocks:
 Benzene_Stock DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
 Diesel_Stock DECIMAL(12, 2) NOT NULL DEFAULT 0.00
 );


--TABLE 2
 CREATE TABLE Worker (
 Worker_ID INT PRIMARY KEY,
 Station_ID INT NOT NULL,
 Role VARCHAR(30) NOT NULL CHECK (Role IN ('Manager', 'Attendant')),
 FOREIGN KEY (Station_ID) REFERENCES Station(Station_ID) ON DELETE RESTRICT
 );


--TABLE 3
 CREATE TABLE Vehicle (
 Plate_Number VARCHAR(20) PRIMARY KEY,
 Service_Type VARCHAR(50) NOT NULL CHECK (Service_Type IN ('Code 1-public transport', 'Code 2- private', 'Code 3-Heavy Truck')),
 Fuel_Type_Requirement VARCHAR(15) NOT NULL CHECK (Fuel_Type_Requirement IN ('Benzene', 'Diesel')),
 --     -- Max limits enforced via check constraints from documentation rules:
 Max_Allowed_Fuel DECIMAL(6, 2) NOT NULL CHECK (
  (Service_Type = 'Code 1-public transport' AND Max_Allowed_Fuel <= 55.00) OR
  (Service_Type = 'Code 2- private' AND Max_Allowed_Fuel <= 35.00) OR
  (Service_Type = 'Code 3-Heavy Truck' AND Max_Allowed_Fuel <= 500.00)
  ),
 Active_Booking_Lock BOOLEAN NOT NULL DEFAULT FALSE
  );


--TABLE 4
 CREATE TABLE Customer (
 Customer_ID SERIAL NOT NULL PRIMARY KEY,
     -- Composite Full Name broken into atomic columns:
 First_Name VARCHAR(50) NOT NULL,
 Last_Name VARCHAR(50) NOT NULL,
 Phone_Number VARCHAR(20) UNIQUE NOT NULL,
     -- Composite Username and Password components (Hashed for safety):
 Username VARCHAR(50) UNIQUE NOT NULL,
 Password_Hash VARCHAR(255) NOT NULL, 
 Plate_Number VARCHAR(20) NOT NULL,
 FOREIGN KEY (Plate_Number) REFERENCES Vehicle(Plate_Number) ON DELETE CASCADE
 );


--TABLE 5
 CREATE TABLE Reservation (
 Reservation_ID SERIAL NOT NULL PRIMARY KEY,
 Station_ID INT NOT NULL,
 Plate_Number VARCHAR(20) NOT NULL,
 Fuel_Amount_Requested DECIMAL(6, 2) NOT NULL CHECK (Fuel_Amount_Requested > 0),
 OTP_Code VARCHAR(10) NOT NULL,
 Queue_Status VARCHAR(20) NOT NULL DEFAULT 'Waiting' CHECK (Queue_Status IN ('Waiting', 'Fulfilled', 'Expired')),
  -- Reservation timestamp explicitly recorded to calculate dynamic values down the line
 Reservation_Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
     -- Estimated Wait Time is a derived property: (Queue_Position * 6 min) + 20 min
     -- Generated columns calculate this automatically in engines like PostgreSQL/MySQL
 Estimated_Wait_Time_Minutes INT GENERATED ALWAYS AS (20) STORED, 
 FOREIGN KEY (Station_ID) REFERENCES Station(Station_ID) ON DELETE CASCADE,
 FOREIGN KEY (Plate_Number) REFERENCES Vehicle(Plate_Number) ON DELETE CASCADE
 );


--TABLE 6
 CREATE TABLE Money_Transaction (
 Transaction_ID SERIAL NOT NULL PRIMARY KEY,
 Reservation_ID INT UNIQUE NOT NULL,
     -- Composite Date_Time component separated atomically:
 Transaction_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
 Transaction_Time TIME NOT NULL DEFAULT (CURRENT_TIME),
 Unit_Price DECIMAL(10, 2) NOT NULL,
 Amount_Dispensed DECIMAL(6, 2) NOT NULL,
     -- Total Price is Derived: Amount_Dispensed * Unit_Price
 Total_Price DECIMAL(12, 2) GENERATED ALWAYS AS (Amount_Dispensed * Unit_Price) STORED,
 Verifier_Worker_ID INT NOT NULL,
 FOREIGN KEY (Reservation_ID) REFERENCES Reservation(Reservation_ID) ON DELETE RESTRICT,
 FOREIGN KEY (Verifier_Worker_ID) REFERENCES Worker(Worker_ID) ON DELETE RESTRICT
 );


       --INSERT 15 RECORDS FOR EACH TABLE
 INSERT INTO Station (Station_Name, City, Sub_city, Wereda, Benzene_Stock, Diesel_Stock) VALUES
 ('Bole Medhanialem Station', 'Addis Ababa', 'Bole', 'Wereda 03', 25000.00, 30000.00),
 ('Megenagna Hub Station', 'Addis Ababa', 'Yeka', 'Wereda 11', 18000.50, 22000.00),
 ('Meskel Square Premium', 'Addis Ababa', 'Kirkos', 'Wereda 02', 35000.00, 40000.00),
 ('Gotera Junction Fuel', 'Addis Ababa', 'Nifas Silk Lafto', 'Wereda 05', 12000.00, 28000.00),
 ('Piassa Heritage Station', 'Addis Ababa', 'Arada', 'Wereda 01', 15000.00, 10000.00),
 ('Adama Highway Express', 'Adama', 'Melka Adama', 'Wereda 02', 40000.00, 55000.00),
 ('Hawassa Lakeview Station', 'Hawassa', 'Tabor', 'Wereda 04', 20000.00, 25000.00),
('Bahir Dar Nile Fuel', 'Bahir Dar', 'Belay Zeleke', 'Wereda 03', 22000.00, 24000.00),
 ('Mekelle Central Station', 'Mekelle', 'Hadnet', 'Wereda 07', 17000.00, 19000.00),
 ('Dire Dawa Kebele Depot', 'Dire Dawa', 'Melka Jebdu', 'Wereda 02', 19500.00, 31000.00),
 ('Jimma Abba Jifar Fuel', 'Jimma', 'Jiren', 'Wereda 01', 14000.00, 18000.00),
 ('Dessie Piazza Depot', 'Dessie', 'Buanbua Wuha', 'Wereda 05', 13000.00, 16500.00),
 ('Gondar Fasil Station', 'Gondar', 'Maraki', 'Wereda 08', 16000.00, 15000.00),
 ('Sodo Central Supply', 'Wolaita Sodo', 'Arada', 'Wereda 02', 11000.00, 14000.00),
 ('Harar Jugol Gate Station', 'Harar', 'Amir Nur', 'Wereda 03', 10500.00, 12000.00);

 INSERT INTO Worker (Station_ID, Worker_ID, Role) VALUES
 (1,1, 'Manager'), (1,2, 'Attendant'),
 (2,3, 'Manager'), (2,4, 'Attendant'),
 (3,5, 'Manager'), (3,6, 'Attendant'),
 (4,7, 'Manager'), (4,8, 'Attendant'),
 (5,9, 'Manager'), (6,10, 'Manager'),
 (7,11, 'Manager'), (8,12, 'Manager'),
 (9,13, 'Manager'), (10,14, 'Manager'),
 (11,15, 'Manager');

 INSERT INTO Vehicle (Plate_Number, Service_Type, Fuel_Type_Requirement, Max_Allowed_Fuel, Active_Booking_Lock) VALUES
 ('AA-2-A12345', 'Code 2- private', 'Benzene', 35.00, FALSE),
 ('AA-3-B98765', 'Code 3-Heavy Truck', 'Diesel', 500.00, TRUE),
 ('AA-1-C45678', 'Code 1-public transport', 'Benzene', 55.00, FALSE),
 ('AA-2-D34567', 'Code 2- private', 'Benzene', 30.00, FALSE),
 ('AA-3-E89012', 'Code 3-Heavy Truck', 'Diesel', 450.00, FALSE),
 ('ET-1-99999', 'Code 1-public transport', 'Diesel', 55.00, TRUE),
 ('AA-2-F11223', 'Code 2- private', 'Benzene', 35.00, FALSE),
 ('AA-2-G44556', 'Code 2- private', 'Diesel', 35.00, FALSE),
 ('AA-3-H77889', 'Code 3-Heavy Truck', 'Diesel', 500.00, FALSE),
 ('AA-1-J33445', 'Code 1-public transport', 'Benzene', 50.00, FALSE),
 ('OR-2-K55667', 'Code 2- private', 'Benzene', 35.00, FALSE),
 ('SNN-1-L88990', 'Code 1-public transport', 'Diesel', 55.00, FALSE),
 ('AM-3-M22334', 'Code 3-Heavy Truck', 'Diesel', 400.00, FALSE),
 ('AA-2-N66778', 'Code 2- private', 'Benzene', 25.00, FALSE),
 ('AA-1-P11447', 'Code 1-public transport', 'Benzene', 55.00, FALSE);
 INSERT INTO Customer (First_Name, Last_Name, Phone_Number, Username, Password_Hash, Plate_Number) VALUES
 ('Abebe', 'Bikila', '+251911223344', 'abebe_b', 'hash_pass_1', 'AA-2-A12345'),
 ('Almaz', 'Ayana', '+251911556677', 'almaz_a', 'hash_pass_2', 'AA-3-B98765'),
 ('Yonas', 'Alemu', '+251912334455', 'yonas_a', 'hash_pass_3', 'AA-1-C45678'),
 ('Selam', 'Tesfaye', '+251913445566', 'selam_t', 'hash_pass_4', 'AA-2-D34567'),
 ('Tariku', 'Bekele', '+251914556677', 'tariku_b', 'hash_pass_5', 'AA-3-E89012'),
 ('Makeda', 'Saba', '+251915667788', 'makeda_s', 'hash_pass_6', 'ET-1-99999'),
 ('Dawit', 'Tsige', '+251916778899', 'dawit_t', 'hash_pass_7', 'AA-2-F11223'),
 ('Hagos', 'Gebru', '+251917889900', 'hagos_g', 'hash_pass_8', 'AA-2-G44556'),
 ('Eleni', 'Gabre', '+251918990011', 'eleni_g', 'hash_pass_9', 'AA-3-H77889'),
 ('Samuel', 'Tefera', '+251919001122', 'samuel_t', 'hash_pass_10', 'AA-1-J33445'),
 ('Lidya', 'Solomon', '+251920112233', 'lidya_s', 'hash_pass_11', 'OR-2-K55667'),
 ('Tamrat', 'Layne', '+251921223344', 'tamrat_l', 'hash_pass_12', 'SNN-1-L88990'),
 ('Genet', 'Dibaba', '+251922334455', 'genet_d', 'hash_pass_13', 'AM-3-M22334'),
 ('Fikru', 'Maru', '+251923445566', 'fikru_m', 'hash_pass_14', 'AA-2-N66778'),
 ('Meseret', 'Defar', '+251924556677', 'meseret_d', 'hash_pass_15', 'AA-1-P11447');
 INSERT INTO Reservation (Station_ID, Plate_Number, Fuel_Amount_Requested, OTP_Code, Queue_Status, Reservation_Time) VALUES
 (1, 'AA-2-A12345', 30.00, 'OTP-9812', 'Fulfilled', '2026-05-17 08:30:00'),
 (1, 'AA-3-B98765', 500.00, 'OTP-1123', 'Waiting', '2026-05-17 08:45:00'),
 (2, 'AA-1-C45678', 55.00, 'OTP-4431', 'Fulfilled', '2026-05-17 09:00:00'),
 (2, 'AA-2-D34567', 25.00, 'OTP-7762', 'Expired', '2026-05-17 09:15:00'),
 (3, 'AA-3-E89012', 400.00, 'OTP-2345', 'Fulfilled', '2026-05-17 09:30:00'),
 (3, 'ET-1-99999', 55.00, 'OTP-0987', 'Waiting', '2026-05-17 10:00:00'),
 (4, 'AA-2-F11223', 35.00, 'OTP-6654', 'Fulfilled', '2026-05-17 10:15:00'),
 (4, 'AA-2-G44556', 30.00, 'OTP-3321', 'Fulfilled', '2026-05-17 10:45:00'),
 (5, 'AA-3-H77889', 500.00, 'OTP-5543', 'Fulfilled', '2026-05-17 11:00:00'),
 (6, 'AA-1-J33445', 50.00, 'OTP-1290', 'Expired', '2026-05-17 11:15:00'),
 (7, 'OR-2-K55667', 35.00, 'OTP-7781', 'Fulfilled', '2026-05-17 11:30:00'),
 (8, 'SNN-1-L88990', 55.00, 'OTP-8832', 'Fulfilled', '2026-05-17 12:00:00'),
 (9, 'AM-3-M22334', 380.00, 'OTP-4490', 'Fulfilled', '2026-05-17 12:15:00'),
 (10, 'AA-2-N66778', 20.00, 'OTP-2231', 'Fulfilled', '2026-05-17 12:30:00'),
 (11, 'AA-1-P11447', 55.00, 'OTP-9901', 'Fulfilled', '2026-05-17 13:00:00');
 INSERT INTO Money_Transaction (Reservation_ID, Transaction_Date, Transaction_Time, Unit_Price, Amount_Dispensed, Verifier_Worker_ID) VALUES
 (1, '2026-05-17', '08:45:00', 112.50, 30.00, 2),
 (3, '2026-05-17', '09:20:00', 112.50, 55.00, 4),
 (5, '2026-05-17', '10:00:00', 120.00, 400.00, 6),
 (7, '2026-05-17', '10:30:00', 112.50, 35.00, 8),
 (8, '2026-05-17', '11:10:00', 120.00, 30.00, 8),
 (9, '2026-05-17', '11:25:00', 120.00, 500.00, 9),
 (11, '2026-05-17', '11:55:00', 112.50, 35.00, 11),
 (12, '2026-05-17', '12:20:00', 120.00, 55.00, 12),
 (13, '2026-05-17', '12:45:00', 120.00, 380.00, 13),
 (14, '2026-05-17', '13:00:00', 112.50, 20.00, 14),
 (15, '2026-05-17', '13:30:00', 112.50, 55.00, 15),
 (2, '2026-05-17', '14:00:00', 120.00, 500.00, 2), 
 (6, '2026-05-17', '14:15:00', 120.00, 55.00, 6),
 (4, '2026-05-17', '14:30:00', 112.50, 25.00, 4),
 (10, '2026-05-17', '14:45:00', 112.50, 50.00, 10);
       --SOME QUERIES FOR EXAMPLE
 SELECT 
     t.Transaction_ID,
     c.First_Name,
     c.Last_Name,
     t.Transaction_Date,
     t.Total_Price
 FROM Money_Transaction t
 INNER JOIN Reservation r ON t.Reservation_ID = r.Reservation_ID
 INNER JOIN Customer c ON r.Plate_Number = c.Plate_Number;
 SELECT 
     v.Plate_Number,
     v.Service_Type,
     s.Station_Name,
     s.City
 FROM Vehicle v
 CROSS JOIN Station s;
 SELECT 
     Transaction_ID, 
     Amount_Dispensed, 
     Total_Price, 
     Verifier_Worker_ID
 FROM Money_Transaction
 WHERE Verifier_Worker_ID IN (
     SELECT Worker_ID 
     FROM Worker 
     WHERE Role = 'Attendant'
 );

SELECT 
    Plate_Number,
    COUNT(Reservation_ID) AS Total_Reservations_Made,
    SUM(Fuel_Amount_Requested) AS Combined_Fuel_Liters
FROM Reservation
GROUP BY Plate_Number
HAVING SUM(Fuel_Amount_Requested) > 150.00;