CREATE TABLE IF NOT EXISTS vehicle_mileage (
    vehicle_id INT PRIMARY KEY,
    owner_id INT,
    mileage FLOAT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

