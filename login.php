<?php
require_once 'includes/config.php';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['user_login'])) {
    $username = trim($_POST['username']);
    $password = $_POST['password'];
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND is_active = TRUE");
    $stmt->execute([$username]);
    $user = $stmt->fetch();
    
    if ($user && password_verify($password, $user['password_hash'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_name'] = $user['full_name'];
        $_SESSION['user_role'] = $user['role'];
        
        switch ($user['role']) {
            case 'admin': header('Location: pages/admin/dashboard.php'); break;
            case 'doctor': header('Location: pages/doctor/dashboard.php'); break;
            case 'receptionist': header('Location: pages/receptionist/dashboard.php'); break;
        }
        exit;
    } else {
        $error = '❌ نام کاربری یا رمز عبور اشتباه است.';
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['patient_login'])) {
    $national = trim($_POST['national_code']);
    
    $stmt = $pdo->prepare("SELECT * FROM patients WHERE national_code = ?");
    $stmt->execute([$national]);
    $patient = $stmt->fetch();
    
    if ($patient) {
        $_SESSION['patient_national'] = $national;
        $_SESSION['patient_name'] = $patient['full_name'];
        $_SESSION['patient_id'] = $patient['id'];
        
        if (!$patient['is_verified']) {
            header('Location: pages/patient/verify_otp.php?national=' . $national);
            exit;
        }
        
        header('Location: pages/patient/profile.php?national=' . $national);
        exit;
    } else {
        $error = '❌ کد ملی یافت نشد.';
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ورود به کلینیک</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="login-header">
            <h1>🏥 کلینیک پزشکی</h1>
            <p>سیستم مدیریت جامع نوبت‌دهی</p>
        </div>
        <?php if ($error): ?>
            <div class="alert alert-error"><?= $error ?></div>
        <?php endif; ?>
        <div class="login-grid">
            <div class="login-card admin">
                <div class="card-header">👑 مدیریت</div>
                <form method="POST">
                    <input type="text" name="username" placeholder="نام کاربری" required>
                    <input type="password" name="password" placeholder="رمز عبور" required>
                    <button type="submit" name="user_login">ورود</button>
                </form>
            </div>
            <div class="login-card doctor">
                <div class="card-header">🩺 پزشک</div>
                <form method="POST">
                    <input type="text" name="username" placeholder="نام کاربری" required>
                    <input type="password" name="password" placeholder="رمز عبور" required>
                    <button type="submit" name="user_login">ورود</button>
                </form>
            </div>
            <div class="login-card receptionist">
                <div class="card-header">📋 منشی</div>
                <form method="POST">
                    <input type="text" name="username" placeholder="نام کاربری" required>
                    <input type="password" name="password" placeholder="رمز عبور" required>
                    <button type="submit" name="user_login">ورود</button>
                </form>
            </div>
            <div class="login-card patient">
                <div class="card-header">👤 بیمار</div>
                <form method="POST">
                    <input type="text" name="national_code" placeholder="کد ملی" maxlength="10" required>
                    <button type="submit" name="patient_login">ورود</button>
                </form>
                <p style="margin-top:10px; text-align:center;"><a href="pages/patient/register.php">ثبت‌نام جدید</a></p>
            </div>
        </div>
    </div>
</body>
</html>
