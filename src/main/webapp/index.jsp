<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CourseReg | Smart Course Registration System</title>
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
            overflow-x: hidden;
        }

        /* Custom Cursor */
        .cursor {
            width: 20px;
            height: 20px;
            border: 2px solid #fff;
            border-radius: 50%;
            position: fixed;
            pointer-events: none;
            z-index: 9999;
            transition: all 0.1s ease;
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

        .btn-login {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            padding: 8px 28px;
            border-radius: 40px;
            font-weight: 500;
            transition: all 0.3s;
            backdrop-filter: blur(10px);
        }

        .btn-login:hover {
            background: white;
            color: #1e1b4b;
            transform: translateY(-2px);
        }

        .btn-signup {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border: none;
            color: white;
            padding: 8px 28px;
            border-radius: 40px;
            font-weight: 500;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(168, 85, 247, 0.3);
        }

        .btn-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(168, 85, 247, 0.4);
        }

        /* Hero Section */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            padding: 100px 0;
            position: relative;
            overflow: hidden;
        }

        /* Animated Background Elements */
        .blob {
            position: absolute;
            width: 400px;
            height: 400px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
            animation: float 6s ease-in-out infinite;
        }

        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -4s; opacity: 0.2; }

        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(30px, -30px) rotate(5deg); }
        }

        .hero h1 {
            font-size: 4rem;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 1.5rem;
            background: linear-gradient(135deg, #fff, #a855f7, #7c3aed);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero .badge {
            background: rgba(168, 85, 247, 0.2);
            border: 1px solid rgba(168, 85, 247, 0.5);
            border-radius: 40px;
            padding: 8px 20px;
            display: inline-block;
            margin-bottom: 20px;
            font-size: 0.8rem;
            backdrop-filter: blur(10px);
        }

        .hero-stats {
            display: flex;
            gap: 2rem;
            margin-top: 2rem;
        }

        .hero-stat {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            padding: 15px 25px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .hero-stat .number {
            font-size: 1.8rem;
            font-weight: 800;
            color: #a855f7;
        }

        /* Dashboard Card */
        .dashboard-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 32px;
            padding: 25px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: transform 0.3s;
        }

        .dashboard-card:hover {
            transform: translateY(-10px);
        }

        .dashboard-header {
            background: rgba(255, 255, 255, 0.08);
            border-radius: 20px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .menu-item {
            background: rgba(255, 255, 255, 0.05);
            padding: 10px 15px;
            border-radius: 12px;
            margin: 5px 0;
            transition: all 0.3s;
            cursor: pointer;
        }

        .menu-item:hover, .menu-item.active {
            background: #a855f7;
            transform: translateX(5px);
        }

        .stat-modern {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 15px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .stat-number-modern {
            font-size: 1.8rem;
            font-weight: 800;
            color: #a855f7;
        }

        .schedule-table {
            width: 100%;
            font-size: 0.8rem;
        }

        .schedule-table th {
            background: rgba(255, 255, 255, 0.05);
            padding: 10px;
            border-radius: 10px;
        }

        .schedule-table td {
            padding: 8px 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .badge-active {
            background: #10b981;
            padding: 4px 12px;
            border-radius: 30px;
            font-size: 0.7rem;
        }

        .badge-queue {
            background: #f59e0b;
            padding: 4px 12px;
            border-radius: 30px;
            font-size: 0.7rem;
        }

        /* Features Section */
        .features-section {
            padding: 100px 0;
            background: rgba(255, 255, 255, 0.02);
        }

        .section-title {
            text-align: center;
            margin-bottom: 60px;
        }

        .section-title h2 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .section-title p {
            color: rgba(255, 255, 255, 0.7);
        }

        .feature-card-modern {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 30px;
            text-align: center;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
            height: 100%;
        }

        .feature-card-modern:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(168, 85, 247, 0.5);
        }

        .feature-icon-modern {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }

        .feature-icon-modern i {
            font-size: 2rem;
        }

        /* CTA Section */
        .cta-section {
            padding: 80px 0;
            text-align: center;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
        }

        .btn-cta-modern {
            background: white;
            color: #7c3aed;
            border: none;
            padding: 14px 45px;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s;
            margin: 0 10px;
        }

        .btn-cta-modern:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .btn-cta-outline-modern {
            background: transparent;
            border: 2px solid white;
            padding: 12px 43px;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s;
            color: white;
        }

        .btn-cta-outline-modern:hover {
            background: white;
            color: #7c3aed;
            transform: translateY(-3px);
        }

        /* Floating Cards */
        .floating-card-modern {
            position: absolute;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 16px;
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        /* Footer */
        footer {
            background: rgba(0, 0, 0, 0.4);
            padding: 50px 0 25px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer-links a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            display: block;
            padding: 5px 0;
            transition: 0.3s;
        }

        .footer-links a:hover {
            color: #a855f7;
            transform: translateX(5px);
        }

        @media (max-width: 768px) {
            .hero h1 { font-size: 2.5rem; }
            .hero-stats { flex-direction: column; }
            .blob { display: none; }
        }
    </style>
</head>
<body>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container">
        <a class="navbar-brand" href="#">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="#home">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="#features">Features</a></li>
                <li class="nav-item"><a class="nav-link" href="#howitworks">How It Works</a></li>
                <li class="nav-item ms-lg-3">
                    <a class="btn-login me-2" href="login.jsp"><i class="fas fa-sign-in-alt me-2"></i>Login</a>
                </li>
                <li class="nav-item">
                    <a class="btn-signup" href="signup.jsp"><i class="fas fa-user-plus me-2"></i>Register</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<section id="home" class="hero">
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>

    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6">
                <div class="badge">✨ Next-Gen Registration System</div>
                <h1>Smart Course Registration for Modern Students</h1>
                <p class="lead mb-4" style="color: rgba(255,255,255,0.8);">Experience fair FIFO queue processing, intelligent course sorting, and real-time seat tracking.</p>
                <div>
                    <a href="signup.jsp" class="btn-signup btn-lg me-3" style="padding: 12px 35px;">Get Started →</a>
                    <a href="login.jsp" class="btn-login btn-lg" style="padding: 12px 35px;">Login</a>
                </div>
                <div class="hero-stats">
                    <div class="hero-stat"><div class="number">50+</div><div class="small">Courses</div></div>
                    <div class="hero-stat"><div class="number">1000+</div><div class="small">Students</div></div>
                    <div class="hero-stat"><div class="number">99.9%</div><div class="small">Uptime</div></div>
                </div>
            </div>
            <div class="col-lg-6 mt-5 mt-lg-0 position-relative">
                <div class="dashboard-card">
                    <div class="dashboard-header">
                        <h5 class="mb-0"><i class="fas fa-user-graduate me-2"></i>Student Dashboard</h5>
                        <small>Welcome back, Student 👋</small>
                    </div>
                    <div class="row">
                        <div class="col-4">
                            <div class="menu-item active"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</div>
                            <div class="menu-item"><i class="fas fa-book-open me-2"></i>My Courses</div>
                            <div class="menu-item"><i class="fas fa-plus-circle me-2"></i>Register</div>
                            <div class="menu-item"><i class="fas fa-clock me-2"></i>Queue Status</div>
                        </div>
                        <div class="col-8">
                            <div class="row g-2 mb-3">
                                <div class="col-6"><div class="stat-modern"><div class="stat-number-modern">4</div><div class="small">Enrolled</div></div></div>
                                <div class="col-6"><div class="stat-modern"><div class="stat-number-modern">12</div><div class="small">Completed</div></div></div>
                                <div class="col-6"><div class="stat-modern"><div class="stat-number-modern">2</div><div class="small">In Queue</div></div></div>
                                <div class="col-6"><div class="stat-modern"><div class="stat-number-modern">18</div><div class="small">Credits</div></div></div>
                            </div>
                        </div>
                    </div>
                    <div class="mt-3">
                        <h6 class="mb-2"><i class="fas fa-calendar-week me-2"></i>Current Schedule</h6>
                        <table class="schedule-table">
                            <thead><tr><th>Course</th><th>Time</th><th>Professor</th><th>Status</th></tr></thead>
                            <tbody>
                                <tr><td>Data Structures</td><td>10:00 AM</td><td>Prof. Smith</td><td><span class="badge-active">Active</span></td></tr>
                                <tr><td>Algorithms</td><td>2:00 PM</td><td>Prof. Johnson</td><td><span class="badge-active">Active</span></td></tr>
                                <tr><td>Web Development</td><td>11:00 AM</td><td>Prof. Williams</td><td><span class="badge-queue">Queue</span></td></tr>
                                <tr><td>Databases</td><td>3:30 PM</td><td>Prof. Brown</td><td><span class="badge-queue">Queue</span></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="floating-card-modern" style="top: -5%; right: -5%;">
                    <i class="fas fa-clock fa-lg" style="color: #f59e0b;"></i>
                    <span><strong>Queue Position</strong><br>You are #2 in line</span>
                </div>
                <div class="floating-card-modern" style="bottom: -5%; left: -5%; animation-delay: 1s;">
                    <i class="fas fa-check-circle fa-lg" style="color: #10b981;"></i>
                    <span><strong>Registration Open</strong><br>12 courses available</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Features Section -->
<section id="features" class="features-section">
    <div class="container">
        <div class="section-title">
            <h2>Everything You Need</h2>
            <p>Powerful features to manage your academic journey</p>
        </div>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-book"></i></div>
                    <h4>Course Management</h4>
                    <p>Complete CRUD operations with real-time seat availability tracking.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-clock"></i></div>
                    <h4>FIFO Queue System</h4>
                    <p>Fair First-In-First-Out processing for all registration requests.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-chart-line"></i></div>
                    <h4>Smart Sorting</h4>
                    <p>Insertion Sort algorithm prioritizes limited seat courses.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-user-graduate"></i></div>
                    <h4>Student Dashboard</h4>
                    <p>Personalized dashboard with real-time queue position.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-chart-pie"></i></div>
                    <h4>Admin Analytics</h4>
                    <p>Beautiful charts and reports for registration trends.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern"><i class="fas fa-shield-alt"></i></div>
                    <h4>Secure Storage</h4>
                    <p>All data stored securely with file-based persistence.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- How It Works Section -->
<section id="howitworks" class="py-5" style="background: rgba(255,255,255,0.02);">
    <div class="container">
        <div class="section-title">
            <h2>How It Works</h2>
            <p>Simple 3-step registration process</p>
        </div>
        <div class="row text-center g-4">
            <div class="col-md-4">
                <div class="feature-icon-modern mx-auto mb-3" style="width: 60px; height: 60px;"><i class="fas fa-search fa-2x"></i></div>
                <h4>1. Browse Courses</h4>
                <p class="text-white-50">Explore available courses and check seat availability.</p>
            </div>
            <div class="col-md-4">
                <div class="feature-icon-modern mx-auto mb-3" style="width: 60px; height: 60px;"><i class="fas fa-clock fa-2x"></i></div>
                <h4>2. Join Queue</h4>
                <p class="text-white-50">Your request enters the FIFO queue. Fair processing guaranteed.</p>
            </div>
            <div class="col-md-4">
                <div class="feature-icon-modern mx-auto mb-3" style="width: 60px; height: 60px;"><i class="fas fa-check-circle fa-2x"></i></div>
                <h4>3. Get Approved</h4>
                <p class="text-white-50">Admin approves in order. You're officially enrolled!</p>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="cta-section">
    <div class="container">
        <h2 class="mb-3">Ready to Start Your Academic Journey?</h2>
        <p class="mb-4">Join thousands of students already using CourseReg</p>
        <div>
            <a href="signup.jsp" class="btn-cta-modern">Register Now →</a>
            <a href="login.jsp" class="btn-cta-outline-modern">Login</a>
        </div>
    </div>
</section>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3">
                <div class="footer-brand" style="font-size: 1.5rem; font-weight: 800; margin-bottom: 15px;">Course<span style="color: #a855f7;">Reg</span></div>
                <p class="text-white-50 small">Smart course registration for modern education.</p>
            </div>
            <div class="col-md-2 col-6 mb-3 footer-links">
                <h6 class="text-white mb-2">Product</h6>
                <a href="#features">Features</a>
                <a href="#howitworks">How It Works</a>
            </div>
            <div class="col-md-2 col-6 mb-3 footer-links">
                <h6 class="text-white mb-2">Company</h6>
                <a href="#">About Us</a>
                <a href="#">Contact</a>
            </div>
            <div class="col-md-4 mb-3 footer-links">
                <h6 class="text-white mb-2">Connect</h6>
                <div class="d-flex gap-3">
                    <a href="#"><i class="fab fa-twitter fa-lg"></i></a>
                    <a href="#"><i class="fab fa-linkedin fa-lg"></i></a>
                    <a href="#"><i class="fab fa-github fa-lg"></i></a>
                    <a href="#"><i class="fab fa-instagram fa-lg"></i></a>
                </div>
            </div>
        </div>
        <div class="copyright text-center mt-4 pt-3 border-top border-secondary">
            <p class="small text-white-50">&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p>
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
</script>
</body>
</html>
