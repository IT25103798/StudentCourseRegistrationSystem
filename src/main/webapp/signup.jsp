<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #0f0c29;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Animated Background Blobs */
        .blob {
            position: fixed;
            width: 400px;
            height: 400px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
            animation: float 6s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }

        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -4s; opacity: 0.2; }

        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(30px, -30px) rotate(5deg); }
        }

        /* Navbar */
        .navbar {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            padding: 1rem 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .navbar-brand {
            font-size: 1.8rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav-link {
            color: rgba(255, 255, 255, 0.8) !important;
            font-weight: 500;
            margin: 0 0.3rem;
            padding: 8px 20px !important;
            border-radius: 40px;
            transition: all 0.3s;
        }

        .nav-link:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white !important;
        }

        .btn-login-nav {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 8px 28px;
            border-radius: 40px;
            font-weight: 500;
            transition: all 0.3s;
        }

        .btn-login-nav:hover {
            background: white;
            color: #1e1b4b;
            transform: translateY(-2px);
        }

        .btn-signup-nav {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border: none;
            color: white;
            padding: 8px 28px;
            border-radius: 40px;
            font-weight: 500;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(168, 85, 247, 0.3);
        }

        .btn-signup-nav:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(168, 85, 247, 0.4);
        }

        /* Signup Container */
        .signup-container {
            min-height: calc(100vh - 80px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 100px 20px 60px;
            position: relative;
            z-index: 1;
        }

        .signup-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            overflow: hidden;
            transition: transform 0.3s ease;
            max-width: 680px;
            width: 100%;
            margin: 0 auto;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .signup-card:hover {
            transform: translateY(-5px);
        }

        .signup-header {
            background: linear-gradient(135deg, rgba(168, 85, 247, 0.2), rgba(124, 58, 237, 0.2));
            padding: 32px 40px 28px;
            text-align: center;
            color: white;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .signup-header i {
            font-size: 3rem;
            margin-bottom: 12px;
            color: #a855f7;
        }

        .signup-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .signup-header p {
            opacity: 0.8;
            font-size: 0.85rem;
            margin-bottom: 0;
        }

        .signup-body {
            padding: 32px 36px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
            color: rgba(255, 255, 255, 0.9);
            font-size: 0.8rem;
        }

        .input-group-custom {
            display: flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 16px;
            transition: all 0.3s;
        }

        .input-group-custom:hover,
        .input-group-custom:focus-within {
            border-color: #a855f7;
            box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.2);
            background: rgba(255, 255, 255, 0.12);
        }

        .input-group-custom .input-icon {
            padding: 11px 16px;
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.95rem;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
        }

        .input-group-custom input,
        .input-group-custom select {
            flex: 1;
            border: none;
            padding: 11px 16px;
            font-size: 0.9rem;
            outline: none;
            background: transparent;
            color: white;
            width: 100%;
        }

        .input-group-custom input::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .input-group-custom select {
            cursor: pointer;
        }

        .input-group-custom select option {
            background: #1e1b4b;
            color: white;
        }

        .two-columns {
            display: flex;
            gap: 16px;
            margin-bottom: 0;
        }

        .two-columns .form-group {
            flex: 1;
            margin-bottom: 20px;
        }

        .btn-signup {
            width: 100%;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border: none;
            padding: 14px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.95rem;
            color: white;
            transition: all 0.3s;
            margin-top: 10px;
        }

        .btn-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(168, 85, 247, 0.4);
        }

        .login-link {
            text-align: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .login-link p {
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 0;
            font-size: 0.85rem;
        }

        .login-link a {
            color: #a855f7;
            text-decoration: none;
            font-weight: 600;
        }

        .login-link a:hover {
            color: #c084fc;
        }

        .alert-message {
            background: rgba(239, 68, 68, 0.15);
            border-left: 4px solid #ef4444;
            padding: 12px 18px;
            border-radius: 14px;
            margin-bottom: 24px;
            color: #fca5a5;
            font-size: 0.85rem;
        }

        .password-strength {
            height: 4px;
            margin-top: 10px;
            border-radius: 10px;
            transition: all 0.3s;
            display: none;
        }

        .error-message {
            color: #fca5a5;
            font-size: 0.7rem;
            margin-top: 6px;
        }

        .success-message {
            color: #6ee7b7;
            font-size: 0.7rem;
            margin-top: 6px;
        }

        .terms {
            margin-top: 20px;
            font-size: 0.7rem;
            color: rgba(255, 255, 255, 0.5);
            text-align: center;
        }

        .terms a {
            color: #a855f7;
            text-decoration: none;
        }

        .form-check-input {
            background-color: rgba(255, 255, 255, 0.1);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .form-check-input:checked {
            background-color: #a855f7;
            border-color: #a855f7;
        }

        .form-check-label {
            color: rgba(255, 255, 255, 0.7);
        }

        /* Modal */
        .modal-custom .modal-content {
            background: rgba(15, 12, 41, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .modal-custom .modal-header {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 24px 24px 0 0;
            padding: 20px 28px;
            border: none;
        }

        .modal-custom .modal-body {
            color: rgba(255, 255, 255, 0.8);
        }

        .modal-custom .modal-footer .btn-primary {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border: none;
            border-radius: 40px;
            padding: 10px 28px;
        }

        .modal-custom .modal-footer .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            border-radius: 40px;
        }

        /* Footer */
        footer {
            background: rgba(0, 0, 0, 0.4);
            padding: 50px 0 25px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 30px;
        }

        .footer-brand {
            font-size: 1.4rem;
            font-weight: 800;
            margin-bottom: 15px;
            display: inline-block;
            background: linear-gradient(135deg, #fff, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .footer-links a {
            color: rgba(255, 255, 255, 0.6);
            text-decoration: none;
            display: block;
            padding: 5px 0;
            font-size: 0.85rem;
            transition: 0.3s;
        }

        .footer-links a:hover {
            color: #a855f7;
            transform: translateX(5px);
        }

        .social-icons a {
            color: rgba(255, 255, 255, 0.6);
            font-size: 1.2rem;
            margin-right: 18px;
            transition: 0.3s;
        }

        .social-icons a:hover {
            color: #a855f7;
            transform: translateY(-3px);
        }

        .copyright {
            text-align: center;
            padding-top: 30px;
            margin-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.8rem;
        }

        @media (max-width: 768px) {
            .signup-body { padding: 24px 20px; }
            .signup-header { padding: 28px 20px; }
            .signup-header h2 { font-size: 1.5rem; }
            .two-columns { flex-direction: column; gap: 0; }
            .blob { display: none; }
        }
    </style>
</head>
<body>

<!-- Animated Background Blobs -->
<div class="blob blob-1"></div>
<div class="blob blob-2"></div>
<div class="blob blob-3"></div>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg fixed-top" id="navbar">
    <div class="container">
        <a class="navbar-brand" href="index.jsp">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="index.jsp#features">Features</a></li>
                <li class="nav-item"><a class="nav-link" href="index.jsp#howitworks">How It Works</a></li>
                <li class="nav-item ms-lg-2">
                    <a class="btn-login-nav me-2" href="login.jsp"><i class="fas fa-sign-in-alt me-2"></i>Login</a>
                </li>
                <li class="nav-item">
                    <a class="btn-signup-nav" href="signup.jsp"><i class="fas fa-user-plus me-2"></i>Register</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Signup Container -->
<div class="signup-container">
    <div class="signup-card">
        <div class="signup-header">
            <i class="fas fa-user-graduate"></i>
            <h2>Create Account</h2>
            <p>Join CourseReg and start your academic journey</p>
        </div>
        <div class="signup-body">
            <% if(request.getAttribute("error") != null) { %>
                <div class="alert-message">
                    <i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form id="signupForm" action="register" method="post" onsubmit="return validateForm()">

                <!-- Row 1: Username + Student ID -->
                <div class="two-columns">
                    <div class="form-group">
                        <label><i class="fas fa-user me-1"></i> Username</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-user-circle"></i></span>
                            <input type="text" name="username" id="username" placeholder="Choose a username" required>
                        </div>
                        <div id="usernameError" class="error-message"></div>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-id-card me-1"></i> Student ID</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-qrcode"></i></span>
                            <input type="text" name="studentId" id="studentId" placeholder="Enter your Student ID" required>
                        </div>
                        <div id="studentIdError" class="error-message"></div>
                    </div>
                </div>

                <!-- Row 2: Email + Password -->
                <div class="two-columns">
                    <div class="form-group">
                        <label><i class="fas fa-envelope me-1"></i> Email</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-envelope"></i></span>
                            <input type="email" name="email" id="email" placeholder="your@email.com" required>
                        </div>
                        <div id="emailError" class="error-message"></div>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-lock me-1"></i> Password</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-key"></i></span>
                            <input type="password" id="password" name="password" placeholder="Create a password" required onkeyup="checkPasswordStrength()">
                        </div>
                        <div class="password-strength" id="passwordStrength"></div>
                    </div>
                </div>

                <!-- Row 3: Confirm Password + Department -->
                <div class="two-columns">
                    <div class="form-group">
                        <label><i class="fas fa-lock me-1"></i> Confirm Password</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-check"></i></span>
                            <input type="password" id="confirmPassword" placeholder="Confirm your password" required>
                        </div>
                        <div id="passwordError" class="error-message"></div>
                    </div>
                    <div class="form-group">
                        <label><i class="fas fa-building me-1"></i> Department</label>
                        <div class="input-group-custom">
                            <span class="input-icon"><i class="fas fa-university"></i></span>
                            <select name="department" required>
                                <option value="">Select Department</option>
                                <option>💻 Computer Science</option>
                                <option>📱 Information Technology</option>
                                <option>🛠️ Software Engineering</option>
                                <option>📊 Data Science</option>
                                <option>🔒 Cyber Security</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Semester -->
                <div class="form-group">
                    <label><i class="fas fa-calendar-alt me-1"></i> Semester</label>
                    <div class="input-group-custom">
                        <span class="input-icon"><i class="fas fa-graduation-cap"></i></span>
                        <select name="semester" required>
                            <option value="">Select Semester</option>
                            <option value="1">📘 Semester 1</option>
                            <option value="2">📙 Semester 2</option>
                            <option value="3">📗 Semester 3</option>
                            <option value="4">📕 Semester 4</option>
                            <option value="5">📘 Semester 5</option>
                            <option value="6">📙 Semester 6</option>
                            <option value="7">📗 Semester 7</option>
                            <option value="8">📕 Semester 8</option>
                        </select>
                    </div>
                </div>

                <!-- Terms Checkbox -->
                <div class="mb-3 form-check">
                    <input type="checkbox" class="form-check-input" id="terms" required>
                    <label class="form-check-label small" for="terms">
                        I agree to the <a href="#" data-bs-toggle="modal" data-bs-target="#termsModal">Terms and Conditions</a>
                    </label>
                </div>

                <button type="submit" class="btn-signup">
                    <i class="fas fa-user-plus me-2"></i> Create Account
                </button>
            </form>

            <div class="login-link">
                <p>Already have an account? <a href="login.jsp"><i class="fas fa-sign-in-alt ms-1"></i> Sign In</a></p>
            </div>

            <div class="terms">
                <p>By signing up, you agree to our <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a></p>
            </div>
        </div>
    </div>
</div>

<!-- Terms Modal -->
<div class="modal fade modal-custom" id="termsModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-white"><i class="fas fa-file-contract me-2"></i>Terms & Conditions</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <h6 class="fw-bold">1. Acceptance of Terms</h6>
                <p class="small">By registering, you agree to these terms.</p>
                <h6 class="fw-bold mt-3">2. User Responsibilities</h6>
                <p class="small">Maintain account confidentiality.</p>
                <h6 class="fw-bold mt-3">3. Data Accuracy</h6>
                <p class="small">Provide accurate information.</p>
                <h6 class="fw-bold mt-3">4. Course Registration Policy</h6>
                <p class="small">Registrations processed in FIFO order.</p>
                <h6 class="fw-bold mt-3">5. Termination</h6>
                <p class="small">Violations may lead to account termination.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal"><i class="fas fa-check me-2"></i>I Understand</button>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="footer-brand">Course<span>Reg</span></div>
                <p class="text-white-50 small">Smart course registration for modern education.</p>
                <div class="social-icons">
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-linkedin-in"></i></a>
                    <a href="#"><i class="fab fa-github"></i></a>
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                </div>
            </div>
            <div class="col-md-2 col-6 mb-4 footer-links">
                <h6 class="text-white mb-3">Product</h6>
                <a href="#">Features</a>
                <a href="#">How It Works</a>
            </div>
            <div class="col-md-2 col-6 mb-4 footer-links">
                <h6 class="text-white mb-3">Company</h6>
                <a href="#">About Us</a>
                <a href="#">Contact</a>
            </div>
            <div class="col-md-4 mb-4 footer-links">
                <h6 class="text-white mb-3">Connect</h6>
                <div class="d-flex gap-3">
                    <a href="#"><i class="fab fa-twitter fa-lg"></i></a>
                    <a href="#"><i class="fab fa-linkedin fa-lg"></i></a>
                    <a href="#"><i class="fab fa-github fa-lg"></i></a>
                </div>
            </div>
        </div>
        <div class="copyright">
            <p>&copy; 2024 CourseReg. All rights reserved. | FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.addEventListener('scroll', function() {
        const navbar = document.getElementById('navbar');
        if (window.scrollY > 50) navbar.classList.add('scrolled');
        else navbar.classList.remove('scrolled');
    });

    function checkPasswordStrength() {
        let password = document.getElementById('password').value;
        let strengthBar = document.getElementById('passwordStrength');
        if (password.length === 0) {
            strengthBar.style.display = 'none';
        } else {
            strengthBar.style.display = 'block';
            if (password.length < 4) {
                strengthBar.style.width = '25%';
                strengthBar.style.backgroundColor = '#ef4444';
            } else if (password.length < 6) {
                strengthBar.style.width = '50%';
                strengthBar.style.backgroundColor = '#f59e0b';
            } else {
                strengthBar.style.width = '100%';
                strengthBar.style.backgroundColor = '#10b981';
            }
        }
    }

    function validateForm() {
        let password = document.getElementById('password').value;
        let confirm = document.getElementById('confirmPassword').value;
        let email = document.getElementById('email').value;
        let username = document.getElementById('username').value;
        let studentId = document.getElementById('studentId').value;
        let isValid = true;

        document.getElementById('passwordError').innerHTML = '';
        document.getElementById('emailError').innerHTML = '';
        document.getElementById('usernameError').innerHTML = '';
        document.getElementById('studentIdError').innerHTML = '';

        if (password !== confirm) {
            document.getElementById('passwordError').innerHTML = '❌ Passwords do not match!';
            isValid = false;
        }
        if (password.length < 6) {
            document.getElementById('passwordError').innerHTML = '❌ Password must be at least 6 characters!';
            isValid = false;
        }
        let emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(email)) {
            document.getElementById('emailError').innerHTML = '❌ Enter a valid email address!';
            isValid = false;
        }
        if (username.length < 3) {
            document.getElementById('usernameError').innerHTML = '❌ Username must be at least 3 characters!';
            isValid = false;
        }
        if (studentId.length < 3) {
            document.getElementById('studentIdError').innerHTML = '❌ Enter a valid Student ID!';
            isValid = false;
        }
        return isValid;
    }

    document.getElementById('confirmPassword').addEventListener('keyup', function() {
        let password = document.getElementById('password').value;
        let errorDiv = document.getElementById('passwordError');
        if (password !== this.value) {
            errorDiv.innerHTML = '❌ Passwords do not match!';
            errorDiv.style.color = '#fca5a5';
        } else if (password.length > 0) {
            errorDiv.innerHTML = '✅ Passwords match';
            errorDiv.style.color = '#6ee7b7';
        } else {
            errorDiv.innerHTML = '';
        }
    });
</script>
</body>
</html>
