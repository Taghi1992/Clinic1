CREATE DATABASE IF NOT EXISTS clinic_db;
USE clinic_db;

CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    national_code VARCHAR(10) UNIQUE NOT NULL,
    phone VARCHAR(11) NOT NULL,
    birth_date DATE,
    otp_code VARCHAR(6),
    otp_expiry DATETIME,
    is_verified BOOLEAN DEFAULT FALSE,
    loyalty_points INT DEFAULT 0,
    total_visits INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'doctor', 'receptionist') NOT NULL,
    phone VARCHAR(11),
    email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    phone VARCHAR(11),
    email VARCHAR(100),
    consultation_fee INT DEFAULT 0,
    user_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    doctor_name VARCHAR(100),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') DEFAULT 'pending',
    has_medical_record BOOLEAN DEFAULT FALSE,
    reminder_sent BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE medical_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis TEXT,
    symptoms TEXT,
    allergies TEXT,
    chronic_diseases TEXT,
    family_history TEXT,
    blood_pressure VARCHAR(20),
    heart_rate INT,
    temperature FLOAT,
    weight FLOAT,
    height FLOAT,
    bmi FLOAT,
    visit_date DATE NOT NULL,
    next_visit_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medical_record_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50),
    instructions TEXT,
    quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE
);

CREATE TABLE financial_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    final_amount DECIMAL(15,2) NOT NULL,
    payment_method ENUM('cash', 'card', 'online', 'insurance') DEFAULT 'cash',
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

CREATE TABLE feedbacks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

CREATE TABLE doctor_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week TINYINT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_duration INT DEFAULT 15,
    max_patients INT DEFAULT 10,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

CREATE TABLE sms_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    phone VARCHAR(11) NOT NULL,
    message TEXT,
    type ENUM('otp', 'reminder', 'notification') DEFAULT 'notification',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('sent', 'failed') DEFAULT 'sent',
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

INSERT INTO users (username, password_hash, full_name, role) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'مدیر سیستم', 'admin'),
('receptionist', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'منشی کلینیک', 'receptionist'),
('dr.mohammadi', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'دکتر علی محمدی', 'doctor');

INSERT INTO doctors (full_name, specialty, consultation_fee, user_id) VALUES
('دکتر علی محمدی', 'داخلی', 150000, 3),
('دکتر سارا حسینی', 'قلب و عروق', 200000, NULL),
('دکتر رضا کریمی', 'ارتوپدی', 180000, NULL),
('دکتر نرگس احمدی', 'اطفال', 120000, NULL);

INSERT INTO doctor_schedules (doctor_id, day_of_week, start_time, end_time, session_duration, max_patients) VALUES
(1, 0, '08:00:00', '14:00:00', 15, 20),
(1, 1, '08:00:00', '14:00:00', 15, 20),
(1, 2, '08:00:00', '14:00:00', 15, 20),
(1, 3, '16:00:00', '20:00:00', 15, 15);
