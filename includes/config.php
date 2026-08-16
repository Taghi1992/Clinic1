<?php
session_start();

define('DB_HOST', 'localhost');
define('DB_NAME', 'clinic_db');
define('DB_USER', 'root');
define('DB_PASS', '');
define('SMS_API_KEY', 'Your-Kavenegar-API-Key');
define('SMS_SENDER', '1000596446');

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch(PDOException $e) {
    die("خطا در اتصال: " . $e->getMessage());
}

function sendSMS($phone, $message, $patient_id = null) {
    global $pdo;
    $api_key = SMS_API_KEY;
    $sender = SMS_SENDER;
    $url = "https://api.kavenegar.com/v1/$api_key/sms/send.json";
    
    $data = array('sender' => $sender, 'receptor' => $phone, 'message' => $message);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    $status = ($http_code == 200) ? 'sent' : 'failed';
    if ($patient_id) {
        $stmt = $pdo->prepare("INSERT INTO sms_logs (patient_id, phone, message, type, status) VALUES (?, ?, ?, 'notification', ?)");
        $stmt->execute([$patient_id, $phone, $message, $status]);
    }
    return json_decode($response, true);
}

function generateOTP() {
    return str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
}

function isAdminLoggedIn() { return isset($_SESSION['user_id']) && $_SESSION['user_role'] === 'admin'; }
function isDoctorLoggedIn() { return isset($_SESSION['user_id']) && $_SESSION['user_role'] === 'doctor'; }
function isReceptionistLoggedIn() { return isset($_SESSION['user_id']) && $_SESSION['user_role'] === 'receptionist'; }
function isStaffLoggedIn() { return isset($_SESSION['user_id']) && in_array($_SESSION['user_role'], ['admin', 'doctor', 'receptionist']); }
?>
