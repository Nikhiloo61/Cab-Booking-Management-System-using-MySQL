CREATE DATABASE IF NOT EXISTS CabBookingDB;
USE CabBookingDB;

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_name VARCHAR(100),
    phone VARCHAR(15),
    license_no VARCHAR(50)
);

CREATE TABLE cabs (
    cab_id INT PRIMARY KEY AUTO_INCREMENT,
    cab_number VARCHAR(20) UNIQUE,
    model VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Available'  -- Available / Booked
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    address VARCHAR(150)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    cab_id INT,
    driver_id INT,
    distance_km DECIMAL(10,2),
    fare DECIMAL(10,2),
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (cab_id) REFERENCES cabs(cab_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

DELIMITER $$

CREATE FUNCTION calculate_fare(distance DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE base_fare DECIMAL(10,2);
    DECLARE total_fare DECIMAL(10,2);
    SET base_fare = distance * 10;  -- ₹10 per km
    SET total_fare = base_fare + (base_fare * 0.05);  -- +5% GST
    RETURN total_fare;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE book_cab_auto (
    IN p_customer_id INT,
    IN p_distance DECIMAL(10,2)
)
BEGIN
    DECLARE available_cab INT;
    DECLARE available_driver INT;
    DECLARE total_fare DECIMAL(10,2);

    -- Find first available cab
    SELECT cab_id INTO available_cab
    FROM cabs
    WHERE status = 'Available'
    LIMIT 1;

    -- Find first available driver
    SELECT driver_id INTO available_driver
    FROM drivers
    LIMIT 1;

    -- If no cab available
    IF available_cab IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No cabs available right now!';
    END IF;

    -- Calculate fare with function
    SET total_fare = calculate_fare(p_distance);

    -- Add to bookings
    INSERT INTO bookings (customer_id, cab_id, driver_id, distance_km, fare)
    VALUES (p_customer_id, available_cab, available_driver, p_distance, total_fare);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE cancel_booking (
    IN p_booking_id INT
)
BEGIN
    DECLARE cabId INT;

    -- Get cab ID of booking
    SELECT cab_id INTO cabId
    FROM bookings
    WHERE booking_id = p_booking_id;

    -- Delete booking
    DELETE FROM bookings WHERE booking_id = p_booking_id;

    -- Mark cab available again
    UPDATE cabs
    SET status = 'Available'
    WHERE cab_id = cabId;
END $$

DELIMITER ;


-- Trigger 1: Change cab status to 'Booked' after booking
DELIMITER $$ 
CREATE TRIGGER trg_update_cab_status
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    UPDATE cabs
    SET status = 'Booked'
    WHERE cab_id = NEW.cab_id;
END $$ 
DELIMITER ;

-- ✅ Trigger 2: Change cab status to 'Available' after cancellation
DELIMITER $$
CREATE TRIGGER trg_reset_cab_status
AFTER DELETE ON bookings
FOR EACH ROW
BEGIN
    UPDATE cabs
    SET status = 'Available'
    WHERE cab_id = OLD.cab_id;
END $$

DELIMITER ;

INSERT INTO drivers (driver_name, phone, license_no) VALUES
('Rahul Mehta', '9876543210', 'DL12345'),
('Sanjay Kumar', '9123456780', 'DL67890');

INSERT INTO cabs (cab_number, model) VALUES
('MH12AB1234', 'Hyundai i10'),
('MH14XY7890', 'Maruti Swift');

INSERT INTO customers (customer_name, phone, address) VALUES
('Amit Sharma', '9898989898', 'Pune'),
('Priya Singh', '9797979797', 'Mumbai');

-- Book a cab
CALL book_cab_auto(1, 15.5);

-- View bookings
SELECT * FROM bookings;

-- View cab status
SELECT * FROM cabs;

-- Cancel booking
CALL cancel_booking(3);

-- Check cab status after cancellation
SELECT * FROM cabs;
