<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | CourseReg</title>
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

        /* Login Container */
        .login-container {
            min-height: calc(100vh - 80px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 100px 20px 60px;
        }

        /* Animated Background */
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

        .login-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            overflow: hidden;
            transition: transform 0.3s ease;
            max-width: 480px;
            width: 100%;
            border: 1px solid rgba(255, 255, 255, 0.1);
            position: relative;
            z-index: 1;
        }

        .login-card:hover {
            transform: translateY(-5px);
        }

        .login-header {
            background: linear-gradient(135deg, rgba(168, 85, 247, 0.2), rgba(124, 58, 237, 0.2));
            padding: 32px 40px 28px;
            text-align: center;
            color: white;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .login-header i {
            font-size: 3rem;
            margin-bottom: 12px;
            color: #a855f7;
        }

        .login-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .login-header p {
            opacity: 0.8;
            font-size: 0.85rem;
            margin-bottom: 0;
        }

        .login-body {
            padding: 32px 36px;
        }

        .form-group {
            margin-bottom: 24px;
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
            padding: 12px 16px;
            color: rgba(255, 255, 255, 0.6);
            font-size: 0.95rem;
            border-right: 1px solid rgba(255, 255, 255, 0.1);
        }

        .input-group-custom input {
            flex: 1;
            border: none;
            padding: 12px 16px;
            font-size: 0.9rem;
            outline: none;
            background: transparent;
            color: white;
            width: 100%;
        }

        .input-group-custom input::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .btn-login {
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
            cursor: pointer;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(168, 85, 247, 0.4);
        }

        .forgot-password {
            text-align: right;
            margin-top: 12px;
        }

        .forgot-password a {
            color: rgba(255, 255, 255, 0.6);
            text-decoration: none;
            font-size: 0.8rem;
            transition: color 0.3s;
            cursor: pointer;
        }

        .forgot-password a:hover {
            color: #a855f7;
        }

        .register-link {
            text-align: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .register-link p {
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 0;
            font-size: 0.85rem;
        }

        .register-link a {
            color: #a855f7;
            text-decoration: none;
            font-weight: 600;
        }

        .register-link a:hover {
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

        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            border-left: 4px solid #10b981;
            color: #6ee7b7;
        }

        /* Modal Styles */
        .admin-modal .modal-content {
            background: rgba(15, 12, 41, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .admin-modal .modal-header {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 24px 24px 0 0;
            padding: 20px 28px;
            border: none;
        }

        .admin-contact-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 20px;
            padding: 20px;
            margin: 10px 0;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .contact-detail {
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            color: rgba(255, 255, 255, 0.8);
        }

        .contact-detail i {
            width: 25px;
            color: #a855f7;
        }

        .btn-copy {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 4px 12px;
            border-radius: 40px;
            font-size: 0.7rem;
            color: white;
            transition: 0.3s;
        }

        .btn-copy:hover {
            background: #a855f7;
        }

        .modal-footer .btn-secondary {
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
            .login-body { padding: 24px 20px; }
            .login-header { padding: 28px 20px; }
            .login-header h2 { font-size: 1.5rem; }
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
<nav class="navbar navbar-expand-lg fixed-top">
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

<!-- Login Container -->
<div class="login-container">
    <div class="login-card">
        <div class="login-header">
            <i class="fas fa-graduation-cap"></i>
            <h2>Welcome Back!</h2>
            <p>Sign in to access your dashboard</p>
        </div>
        <div class="login-body">
            <% if(request.getParameter("success") != null) { %>
                <div class="alert-message alert-success">
                    <i class="fas fa-check-circle me-2"></i> <%= request.getParameter("success") %>
                </div>
            <% } %>
            <% if(request.getAttribute("error") != null) { %>
                <div class="alert-message">
                    <i class="fas fa-exclamation-triangle me-2"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form action="login" method="post">
                <div class="form-group">
                    <label><i class="fas fa-user me-1"></i> Username</label>
                    <div class="input-group-custom">
                        <span class="input-icon"><i class="fas fa-user-circle"></i></span>
                        <input type="text" name="username" placeholder="Enter your username" required>
                    </div>
                </div>
                <div class="form-group">
                    <label><i class="fas fa-lock me-1"></i> Password</label>
                    <div class="input-group-custom">
                        <span class="input-icon"><i class="fas fa-key"></i></span>
                        <input type="password" name="password" placeholder="Enter your password" required>
                    </div>
                </div>
                <div class="forgot-password">
                    <a href="#" data-bs-toggle="modal" data-bs-target="#adminContactModal">
                        <i class="fas fa-question-circle me-1"></i> Forgot Password?
                    </a>
                </div>
                <button type="submit" class="btn-login">
                    <i class="fas fa-sign-in-alt me-2"></i> Sign In
                </button>
            </form>

            <div class="register-link">
                <p>Don't have an account? <a href="signup.jsp"><i class="fas fa-user-plus ms-1"></i> Create an Account</a></p>
            </div>
        </div>
    </div>
</div>

<!-- Admin Contact Modal -->
<div class="modal fade admin-modal" id="adminContactModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-headset me-2"></i>Contact System Administrator</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4">
                <div class="admin-contact-card">
                    <div class="text-center mb-3">
                        <i class="fas fa-user-shield fa-3x" style="color: #a855f7;"></i>
                        <h5 class="mt-2 fw-bold">Admin Support Team</h5>
                    </div>
                    <div class="contact-detail">
                        <i class="fas fa-user"></i>
                        <span><strong>Name:</strong> Mr. Admin User</span>
                    </div>
                    <div class="contact-detail">
                        <i class="fas fa-envelope"></i>
                        <span><strong>Email:</strong> admin@coursereg.com</span>
                        <button class="btn-copy" onclick="copyToClipboard('admin@coursereg.com')"><i class="fas fa-copy me-1"></i> Copy</button>
                    </div>
                    <div class="contact-detail">
                        <i class="fas fa-phone-alt"></i>
                        <span><strong>Phone:</strong> +94 12 345 6789</span>
                        <button class="btn-copy" onclick="copyToClipboard('+94 12 345 6789')"><i class="fas fa-copy me-1"></i> Copy</button>
                    </div>
                    <div class="contact-detail">
                        <i class="fab fa-whatsapp"></i>
                        <span><strong>WhatsApp:</strong> +94 12 345 6789</span>
                    </div>
                    <div class="contact-detail">
                        <i class="fas fa-clock"></i>
                        <span><strong>Support Hours:</strong> Mon-Fri, 9:00 AM - 5:00 PM</span>
                    </div>
                </div>
                <div class="alert alert-info mt-3 mb-0" style="background: rgba(6, 182, 212, 0.1); border: none; border-radius: 16px; color: #67e8f9;">
                    <i class="fas fa-info-circle me-2" style="color: #06b6d4;"></i>
                    Please contact the admin to reset your password or for any login issues.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 40px; padding: 8px 24px;">Close</button>
                <a href="mailto:admin@coursereg.com" class="btn btn-primary" style="background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; border-radius: 40px; padding: 8px 24px;"><i class="fas fa-envelope me-2"></i>Send Email</a>
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
                <h6 class="text-white mb-3">Quick Links</h6>
                <a href="index.jsp">Home</a>
                <a href="login.jsp">Login</a>
                <a href="signup.jsp">Register</a>
            </div>
            <div class="col-md-2 col-6 mb-4 footer-links">
                <h6 class="text-white mb-3">Support</h6>
                <a href="#" data-bs-toggle="modal" data-bs-target="#adminContactModal">Contact Admin</a>
                <a href="#">FAQs</a>
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
    // Smooth scroll
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if(target) target.scrollIntoView({ behavior: 'smooth' });
        });
    });

    function copyToClipboard(text) {
        navigator.clipboard.writeText(text).then(function() {
            alert('✅ Copied: ' + text);
        });
    }
</script>
</body>
</html>
