<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="com.registration.model.RegistrationRequest" %>
<%@ page import="java.util.*" %>
<%
    // Get session attributes
    Student student = (Student) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    // Redirect if not logged in
    if (username == null || student == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize DAOs
    CourseDAO courseDAO = new CourseDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    // Get data
    List<Course> allCourses = courseDAO.getAllCourses();
    List<Course> availableCourses = new ArrayList<>();
    for (Course c : allCourses) {
        if (c.isAvailable()) {
            availableCourses.add(c);
        }
    }

    List<Registration> myRegistrations = registrationDAO.getRegistrationsByStudent(student.getId());
    List<RegistrationRequest> myQueue = registrationDAO.getQueueStatus();

    // Filter queue for current student
    List<RegistrationRequest> studentQueue = new ArrayList<>();
    for (RegistrationRequest req : myQueue) {
        if (req.getStudentId().equals(student.getId())) {
            studentQueue.add(req);
        }
    }

    // Calculate statistics
    int totalCourses = allCourses.size();
    int availableCount = availableCourses.size();
    int enrolledCount = myRegistrations.size();
    int queueCount = studentQueue.size();

    int totalCredits = 0;
    for (Registration reg : myRegistrations) {
        Course c = courseDAO.findCourseById(reg.getCourseId());
        if (c != null) {
            totalCredits += c.getCredits();
        }
    }

    String currentPage = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | CourseReg</title>
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

        /* Navbar */
        .navbar {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            padding: 0.8rem 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        .navbar-brand {
            font-size: 1.6rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav-link {
            color: rgba(255, 255, 255, 0.8) !important;
            font-weight: 500;
            margin: 0 0.3rem;
            padding: 8px 18px !important;
            border-radius: 40px;
            transition: all 0.3s;
        }

        .nav-link:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white !important;
        }

        .nav-link.active {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            color: white !important;
            box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3);
        }

        /* Profile Button */
        .profile-btn {
            background: none;
            border: none;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 16px 6px 10px;
            border-radius: 50px;
            transition: all 0.3s;
            margin-left: 10px;
            color: rgba(255, 255, 255, 0.9);
        }

        .profile-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        .profile-avatar {
            width: 35px;
            height: 35px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 0.9rem;
        }

        .btn-logout {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
            padding: 8px 22px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            margin-left: 8px;
        }

        .btn-logout:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3);
        }

        /* Dashboard Container */
        .dashboard-container {
            padding: 100px 0 50px;
            position: relative;
            z-index: 1;
        }

        /* Welcome Card */
        .welcome-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 28px;
            padding: 32px 36px;
            color: white;
            margin-bottom: 35px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .welcome-card h1 {
            font-size: 2rem;
            font-weight: 700;
        }

        /* Stat Cards */
        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 20px 24px;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .stat-card:hover {
            transform: translateY(-4px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(168, 85, 247, 0.3);
        }

        .stat-number {
            font-size: 2.2rem;
            font-weight: 800;
            color: #a855f7;
            line-height: 1;
        }

        .stat-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.8rem;
            font-weight: 500;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            background: rgba(168, 85, 247, 0.2);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            color: #a855f7;
        }

        /* Content Cards */
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 24px 28px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .card-title-icon {
            width: 40px;
            height: 40px;
            background: rgba(168, 85, 247, 0.2);
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #a855f7;
        }

        /* Quick Action Buttons */
        .quick-action-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 24px;
            text-align: center;
            transition: all 0.3s;
            text-decoration: none;
            display: block;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .quick-action-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(168, 85, 247, 0.3);
        }

        .quick-icon {
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        .quick-icon i {
            font-size: 1.8rem;
            color: white;
        }

        .quick-action-card h5 {
            font-weight: 700;
            margin-bottom: 8px;
            color: white;
        }

        .quick-action-card p {
            color: rgba(255, 255, 255, 0.6);
        }

        /* Tables */
        .custom-table {
            width: 100%;
            border-collapse: collapse;
        }

        .custom-table thead th {
            background: rgba(255, 255, 255, 0.08);
            padding: 14px 16px;
            font-weight: 600;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.9);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .custom-table tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.8);
        }

        .custom-table tbody tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }

        /* Badges */
        .badge-approved {
            background: rgba(16, 185, 129, 0.2);
            color: #6ee7b7;
            padding: 5px 14px;
            border-radius: 40px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        .badge-pending {
            background: rgba(245, 158, 11, 0.2);
            color: #fcd34d;
            padding: 5px 14px;
            border-radius: 40px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        /* Profile Modal */
        .profile-modal .modal-content {
            background: rgba(15, 12, 41, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 28px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .profile-modal .modal-header {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 28px 28px 0 0;
            padding: 20px 28px;
        }

        .profile-avatar-large {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 3rem;
            color: white;
            font-weight: 600;
        }

        .profile-detail {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 14px 18px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 14px;
            color: rgba(255, 255, 255, 0.8);
        }

        .profile-detail i {
            width: 28px;
            color: #a855f7;
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

        .copyright {
            text-align: center;
            padding-top: 30px;
            margin-top: 30px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            color: rgba(255, 255, 255, 0.5);
            font-size: 0.8rem;
        }

        @media (max-width: 768px) {
            .dashboard-container { padding: 120px 0 40px; }
            .welcome-card h1 { font-size: 1.4rem; }
            .welcome-card { padding: 24px; }
            .stat-number { font-size: 1.6rem; }
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
        <a class="navbar-brand" href="student-dashboard.jsp">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link active" href="student-dashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="student-courses.jsp">My Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="register-course">Register</a></li>
                <li class="nav-item"><a class="nav-link" href="queue-status">Queue Status</a></li>
                <li class="nav-item"><a class="nav-link" href="profile-settings.jsp"><i class="fas fa-user-pen me-1"></i>Profile</a></li>
                <li class="nav-item">
                    <a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Dashboard Container -->
<div class="dashboard-container">
    <div class="container">

        <!-- Welcome Card -->
        <div class="welcome-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="fw-bold mb-2">Welcome back, <%= username %>! 👋</h1>
                    <p class="mb-0 opacity-75">Track your registrations, check queue status, and manage your academic journey.</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <span class="badge bg-white text-dark px-3 py-2 me-2 rounded-pill"><i class="fas fa-building me-1"></i> <%= student.getDepartment() %></span>
                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill"><i class="fas fa-calendar me-1"></i> Semester <%= student.getSemester() %></span>
                </div>
            </div>
        </div>

        <!-- Statistics Row -->
        <div class="row g-4 mb-5">
            <div class="col-md-3 col-sm-6">
                <div class="stat-card d-flex justify-content-between align-items-center">
                    <div><div class="stat-number"><%= totalCourses %></div><div class="stat-label">Total Courses</div></div>
                    <div class="stat-icon"><i class="fas fa-book"></i></div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card d-flex justify-content-between align-items-center">
                    <div><div class="stat-number"><%= availableCount %></div><div class="stat-label">Available</div></div>
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card d-flex justify-content-between align-items-center">
                    <div><div class="stat-number"><%= enrolledCount %></div><div class="stat-label">Enrolled</div></div>
                    <div class="stat-icon"><i class="fas fa-graduation-cap"></i></div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-card d-flex justify-content-between align-items-center">
                    <div><div class="stat-number"><%= totalCredits %></div><div class="stat-label">Total Credits</div></div>
                    <div class="stat-icon"><i class="fas fa-star"></i></div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <a href="courses" class="quick-action-card">
                    <div class="quick-icon"><i class="fas fa-search"></i></div>
                    <h5>Browse Courses</h5>
                    <p class="small mb-0">Explore all available courses</p>
                </a>
            </div>
            <div class="col-md-4">
                <a href="register-course" class="quick-action-card">
                    <div class="quick-icon"><i class="fas fa-clock"></i></div>
                    <h5>Register for Course</h5>
                    <p class="small mb-0">Join the registration queue</p>
                </a>
            </div>
            <div class="col-md-4">
                <a href="queue-status" class="quick-action-card">
                    <div class="quick-icon"><i class="fas fa-hourglass-half"></i></div>
                    <h5>Check Queue Status</h5>
                    <p class="small mb-0">View your position in queue</p>
                </a>
            </div>
        </div>

        <!-- Enrolled Courses Section -->
        <div class="content-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="d-flex align-items-center gap-3">
                    <div class="card-title-icon"><i class="fas fa-book-open"></i></div>
                    <h4 class="fw-bold mb-0">My Enrolled Courses</h4>
                </div>
                <a href="student-courses.jsp" class="text-decoration-none small" style="color: #a855f7;">View All <i class="fas fa-arrow-right ms-1"></i></a>
            </div>
            <div class="table-responsive">
                <table class="custom-table">
                    <thead>
                        <tr><th>Course Code</th><th>Course Name</th><th>Instructor</th><th>Credits</th><th>Schedule</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                        <% if(myRegistrations.isEmpty()) { %>
                            <tr><td colspan="6" class="text-center py-5"><i class="fas fa-info-circle mb-2 d-block fs-4 opacity-50"></i>No enrolled courses yet.<br><a href="register-course" class="small" style="color: #a855f7;">Browse Courses →</a></td></tr>
                        <% } else {
                            for(Registration reg : myRegistrations) {
                                Course c = courseDAO.findCourseById(reg.getCourseId());
                                if(c != null) { %>
                                    <tr>
                                        <td><strong><%= c.getCourseId() %></strong></td>
                                        <td><%= c.getCourseName() %></td>
                                        <td><%= c.getInstructor() %></td>
                                        <td><span class="badge bg-info bg-opacity-10 text-white px-3 py-1 rounded-pill"><%= c.getCredits() %> credits</span></td>
                                        <td><small><%= c.getSchedule() %></small></td>
                                        <td><span class="badge-approved"><i class="fas fa-check-circle me-1"></i> Approved</span></td>
                                    </tr>
                        <% } } } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Queue Status Section -->
        <div class="content-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div class="d-flex align-items-center gap-3">
                    <div class="card-title-icon"><i class="fas fa-clock"></i></div>
                    <h4 class="fw-bold mb-0">Registration Queue Status</h4>
                </div>
                <a href="queue-status" class="text-decoration-none small" style="color: #a855f7;">Full Queue <i class="fas fa-arrow-right ms-1"></i></a>
            </div>
            <div class="table-responsive">
                <table class="custom-table">
                    <thead><tr><th>Position</th><th>Course Name</th><th>Request Time</th><th>Status</th></tr></thead>
                    <tbody>
                        <% if(studentQueue.isEmpty()) { %>
                            <tr><td colspan="4" class="text-center py-5"><i class="fas fa-check-circle fs-4 mb-2 d-block text-success"></i>No pending requests.</td></tr>
                        <% } else { int pos = 1; for(RegistrationRequest req : studentQueue) { %>
                            <tr class="<%= pos == 1 ? "table-warning" : "" %>">
                                <td><span class="badge <%= pos == 1 ? "bg-warning text-dark" : "bg-secondary" %> rounded-pill px-3 py-2">#<%= pos++ %></span></td>
                                <td><strong><%= req.getCourseName() %></strong></td>
                                <td><small><%= req.getRequestTime() %></small></td>
                                <td><span class="badge-pending"><i class="fas fa-hourglass-half me-1"></i> Pending</span></td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Info Card -->
        <div class="card border-0 rounded-4 overflow-hidden" style="background: linear-gradient(135deg, #a855f7, #7c3aed);">
            <div class="card-body p-4 text-white">
                <div class="row align-items-center">
                    <div class="col-md-9"><h5 class="mb-2"><i class="fas fa-lightbulb me-2"></i> How Queue Works</h5><p class="mb-0 small opacity-75">FIFO (First-In-First-Out) order. Your request joins the queue → Admin approves in order → You're enrolled automatically.</p></div>
                    <div class="col-md-3 text-end"><i class="fas fa-chart-line fa-3x opacity-25"></i></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Profile Modal -->
<div class="modal fade profile-modal" id="profileModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-user-circle me-2"></i>My Profile</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <div class="modal-body p-4">
                <div class="profile-avatar-large"><%= username.substring(0, 1).toUpperCase() %></div>
                <h4 class="text-center mb-4"><%= username %></h4>
                <div class="profile-detail"><i class="fas fa-id-card"></i><div><strong>Student ID</strong><br><%= student.getStudentId() %></div></div>
                <div class="profile-detail"><i class="fas fa-envelope"></i><div><strong>Email</strong><br><%= student.getEmail() %></div></div>
                <div class="profile-detail"><i class="fas fa-building"></i><div><strong>Department</strong><br><%= student.getDepartment() %></div></div>
                <div class="profile-detail"><i class="fas fa-graduation-cap"></i><div><strong>Current Semester</strong><br>Semester <%= student.getSemester() %></div></div>
                <div class="profile-detail"><i class="fas fa-calendar-alt"></i><div><strong>Member Since</strong><br>2024</div></div>
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-light border" data-bs-dismiss="modal" style="background: rgba(255,255,255,0.1); color: white;">Close</button><a href="logout" class="btn btn-danger">Logout</a></div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-4"><div class="footer-brand">Course<span>Reg</span></div><p class="text-white-50 small">Smart course registration for modern education.</p></div>
            <div class="col-md-2 col-6 mb-4 footer-links"><h6 class="text-white mb-3">Quick Links</h6><a href="student-dashboard.jsp">Dashboard</a><a href="student-courses.jsp">My Courses</a><a href="register-course">Register</a></div>
            <div class="col-md-2 col-6 mb-4 footer-links"><h6 class="text-white mb-3">Support</h6><a href="#">Help Center</a><a href="#">Contact</a><a href="#">FAQs</a></div>
            <div class="col-md-4 mb-4 footer-links"><h6 class="text-white mb-3">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter fa-lg"></i></a><a href="#"><i class="fab fa-linkedin fa-lg"></i></a><a href="#"><i class="fab fa-github fa-lg"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2024 CourseReg. All rights reserved. | FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p></div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.addEventListener('scroll', function() {
        const navbar = document.getElementById('navbar');
        if (window.scrollY > 50) navbar.classList.add('scrolled');
        else navbar.classList.remove('scrolled');
    });
</script>
</body>
</html>
