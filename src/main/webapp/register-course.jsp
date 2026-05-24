<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.dao.FeedbackDAO" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="com.registration.model.RegistrationRequest" %>
<%@ page import="com.registration.model.Feedback" %>
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
    FeedbackDAO feedbackDAO = new FeedbackDAO();

    // Build reviews data
    Map<String, Double> avgRatingMap = new HashMap<>();
    Map<String, List<Feedback>> courseFeedbackMap = new HashMap<>();

    // Get filter parameters
    String searchKeyword = request.getParameter("search");
    String filterDept = request.getParameter("department");
    String sortBy = request.getParameter("sort");

    // Get all courses
    List<Course> allCourses = courseDAO.getAllCourses();

    // Populate reviews maps
    for (Course c : allCourses) {
        avgRatingMap.put(c.getCourseId(), feedbackDAO.getAverageRatingForCourse(c.getCourseId()));
        courseFeedbackMap.put(c.getCourseId(), feedbackDAO.getFeedbacksByCourse(c.getCourseId()));
    }

    // Get student's registered courses
    List<Registration> myRegistrations = registrationDAO.getRegistrationsByStudent(student.getId());
    Set<String> registeredCourseIds = new HashSet<>();
    for (Registration reg : myRegistrations) {
        registeredCourseIds.add(reg.getCourseId());
    }

    // Get student's pending queue requests
    List<RegistrationRequest> queueRequests = registrationDAO.getQueueStatus();
    Set<String> queuedCourseIds = new HashSet<>();
    for (RegistrationRequest req : queueRequests) {
        if (req.getStudentId().equals(student.getId())) {
            queuedCourseIds.add(req.getCourseId());
        }
    }

    // Get available courses (not registered and not queued)
    List<Course> availableCourses = new ArrayList<>();
    for (Course c : allCourses) {
        if (c.isAvailable() && !registeredCourseIds.contains(c.getCourseId()) && !queuedCourseIds.contains(c.getCourseId())) {
            availableCourses.add(c);
        }
    }

    // Apply department filter
    if (filterDept != null && !filterDept.isEmpty() && !"all".equals(filterDept)) {
        List<Course> filtered = new ArrayList<>();
        for (Course c : availableCourses) {
            String courseDept = c.getDepartment();
            if (courseDept != null && courseDept.equals(filterDept)) {
                filtered.add(c);
            }
        }
        availableCourses = filtered;
    }

    // Apply search filter
    if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
        String keyword = searchKeyword.toLowerCase().trim();
        List<Course> filtered = new ArrayList<>();
        for (Course c : availableCourses) {
            if (c.getCourseName().toLowerCase().contains(keyword) ||
                c.getInstructor().toLowerCase().contains(keyword) ||
                c.getCourseId().toLowerCase().contains(keyword)) {
                filtered.add(c);
            }
        }
        availableCourses = filtered;
    }

    // Apply sorting
    if ("name_asc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparing(Course::getCourseName));
    } else if ("name_desc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparing(Course::getCourseName).reversed());
    } else if ("seats_asc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparingInt(Course::getAvailableSeats));
    } else if ("seats_desc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparingInt(Course::getAvailableSeats).reversed());
    } else if ("credits_asc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparingInt(Course::getCredits));
    } else if ("credits_desc".equals(sortBy)) {
        availableCourses.sort(Comparator.comparingInt(Course::getCredits).reversed());
    }

    // Calculate statistics
    int registeredCount = registeredCourseIds.size();
    int queuedCount = queuedCourseIds.size();
    int availableCount = availableCourses.size();
    int totalCourses = allCourses.size();

    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Registration | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0f0c29; background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%); color: #fff; min-height: 100vh; overflow-x: hidden; }

        /* Animated Background */
        .blob { position: fixed; width: 400px; height: 400px; background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 50%; filter: blur(80px); opacity: 0.3; animation: float 6s ease-in-out infinite; pointer-events: none; z-index: 0; }
        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -4s; opacity: 0.2; }
        @keyframes float { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 50% { transform: translate(30px, -30px) rotate(5deg); } }

        /* Navbar - matching student-dashboard.jsp */
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

        /* Container */
        .register-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Welcome Card */
        .welcome-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border-radius: 28px; padding: 32px 36px; color: white; margin-bottom: 35px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .welcome-card h1 { font-size: 2rem; font-weight: 700; margin-bottom: 8px; }

        /* Stats Grid */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px; text-align: center; transition: all 0.3s; border: 1px solid rgba(255, 255, 255, 0.1); }
        .stat-card:hover { transform: translateY(-3px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.3); }
        .stat-number { font-size: 2rem; font-weight: 800; color: #a855f7; }
        .stat-label { color: rgba(255, 255, 255, 0.7); font-size: 0.75rem; font-weight: 500; margin-top: 5px; text-transform: uppercase; letter-spacing: 0.5px; }

        /* Filter Section */
        .filter-section { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px 25px; margin-bottom: 30px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .filter-label { font-weight: 600; font-size: 0.75rem; margin-bottom: 6px; color: rgba(255, 255, 255, 0.8); text-transform: uppercase; letter-spacing: 0.5px; }
        .filter-control { background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 12px; padding: 10px 14px; font-size: 0.85rem; width: 100%; transition: all 0.3s; color: white; }
        .filter-control:focus { border-color: #a855f7; outline: none; box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.2); }
        .filter-control option { background: #1e1b4b; }
        .btn-search { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; border: none; padding: 10px 24px; border-radius: 12px; font-weight: 500; font-size: 0.85rem; transition: all 0.3s; }
        .btn-search:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-reset { background: rgba(255, 255, 255, 0.1); color: white; border: 1px solid rgba(255, 255, 255, 0.2); padding: 10px 24px; border-radius: 12px; font-weight: 500; font-size: 0.85rem; transition: all 0.3s; }
        .btn-reset:hover { background: rgba(255, 255, 255, 0.2); transform: translateY(-1px); }

        /* Course Grid */
        .courses-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; margin-bottom: 30px; }
        .course-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 24px; overflow: hidden; transition: all 0.3s; border: 1px solid rgba(255, 255, 255, 0.1); }
        .course-card:hover { transform: translateY(-5px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.3); }
        .course-header { padding: 18px 20px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
        .course-header h3 { font-size: 1.2rem; font-weight: 700; margin: 0; color: white; }
        .course-code { font-size: 0.7rem; color: rgba(255, 255, 255, 0.5); font-family: monospace; margin-top: 5px; }
        .course-body { padding: 18px 20px; }
        .course-detail { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; font-size: 0.8rem; color: rgba(255, 255, 255, 0.8); }
        .course-detail i { width: 20px; color: #a855f7; }
        .course-detail strong { color: rgba(255, 255, 255, 0.9); }
        .seats-bar { background: rgba(255, 255, 255, 0.1); border-radius: 10px; height: 6px; margin-top: 8px; overflow: hidden; }
        .seats-fill { height: 100%; border-radius: 10px; transition: width 0.3s; }
        .badge-available { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; }
        .badge-department { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 4px 10px; border-radius: 30px; font-size: 0.65rem; font-weight: 600; }
        .course-footer { padding: 15px 20px 20px; border-top: 1px solid rgba(255, 255, 255, 0.1); }
        .btn-register { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; border: none; padding: 10px; border-radius: 40px; font-weight: 600; font-size: 0.8rem; width: 100%; transition: all 0.3s; }
        .btn-register:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(168, 85, 247, 0.4); }

        /* Empty State */
        .empty-state { text-align: center; padding: 60px 20px; background: rgba(255, 255, 255, 0.05); border-radius: 24px; }
        .empty-state i { font-size: 4rem; color: rgba(255, 255, 255, 0.3); margin-bottom: 15px; }

        /* Reviews */
        .reviews-summary { display: flex; align-items: center; gap: 8px; margin-bottom: 10px; padding: 8px 12px; background: rgba(245, 158, 11, 0.08); border-radius: 10px; border: 1px solid rgba(245, 158, 11, 0.15); }
        .stars-display { display: flex; gap: 2px; }
        .stars-display i { font-size: 0.75rem; }
        .rating-value { font-size: 0.85rem; font-weight: 700; color: #fcd34d; }
        .review-count { font-size: 0.75rem; color: rgba(255,255,255,0.5); }
        .btn-read-reviews { background: none; border: none; color: #f59e0b; font-size: 0.72rem; font-weight: 600; cursor: pointer; padding: 0; text-decoration: underline; transition: color 0.2s; margin-left: auto; }
        .btn-read-reviews:hover { color: #fbbf24; }
        .no-reviews-note { font-size: 0.72rem; color: rgba(255,255,255,0.35); margin-bottom: 10px; }

        /* Reviews Modal */
        .review-item { background: rgba(255,255,255,0.05); border-radius: 14px; padding: 16px; margin-bottom: 12px; border: 1px solid rgba(255,255,255,0.08); }
        .review-item:last-child { margin-bottom: 0; }
        .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .review-author { font-weight: 600; font-size: 0.88rem; color: white; }
        .review-date { font-size: 0.72rem; color: rgba(255,255,255,0.4); }
        .review-stars { margin-bottom: 8px; }
        .review-stars i { font-size: 0.8rem; }
        .review-comment { font-size: 0.83rem; color: rgba(255,255,255,0.8); line-height: 1.5; margin: 0; }

        /* Alert */
        .alert-custom { border-radius: 12px; padding: 12px 18px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-success-custom { background: rgba(16, 185, 129, 0.15); border-left: 4px solid #10b981; color: #6ee7b7; }
        .alert-danger-custom { background: rgba(239, 68, 68, 0.15); border-left: 4px solid #ef4444; color: #fca5a5; }

        /* Info Card */
        .info-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px 25px; margin-top: 30px; border: 1px solid rgba(255, 255, 255, 0.1); }

        /* Reviews Browser Section */
        .reviews-browser-section { margin-bottom: 30px; }
        .reviews-browser-header { background: rgba(245,158,11,0.08); border: 1px solid rgba(245,158,11,0.2); border-radius: 20px 20px 0 0; padding: 20px 24px; border-bottom: none; }
        .reviews-badge { background: rgba(245,158,11,0.2); color: #fcd34d; padding: 5px 14px; border-radius: 30px; font-size: 0.75rem; font-weight: 600; white-space: nowrap; }
        .reviewed-courses-grid { background: rgba(255,255,255,0.03); border: 1px solid rgba(245,158,11,0.2); border-radius: 0 0 20px 20px; padding: 20px; display: flex; flex-direction: column; gap: 14px; }
        .reviewed-course-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; padding: 16px 20px; transition: all 0.25s; }
        .reviewed-course-card:hover { background: rgba(255,255,255,0.08); border-color: rgba(245,158,11,0.25); }
        .reviewed-course-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; margin-bottom: 10px; }
        .reviewed-course-name { font-size: 0.95rem; font-weight: 700; color: white; margin-bottom: 4px; }
        .reviewed-course-meta { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .rc-dept-badge { background: rgba(168,85,247,0.2); color: #d8b4fe; padding: 2px 8px; border-radius: 20px; font-size: 0.68rem; font-weight: 600; white-space: nowrap; }
        .reviewed-course-rating { text-align: right; flex-shrink: 0; }
        .rc-stars { margin-bottom: 3px; }
        .rc-rating-line { display: flex; align-items: center; gap: 6px; justify-content: flex-end; }
        .rc-avg { font-size: 0.9rem; font-weight: 700; color: #fcd34d; }
        .rc-count { font-size: 0.72rem; color: rgba(255,255,255,0.45); }
        .rc-preview { font-size: 0.8rem; color: rgba(255,255,255,0.6); font-style: italic; line-height: 1.5; margin-bottom: 12px; padding: 8px 12px; background: rgba(255,255,255,0.04); border-left: 3px solid rgba(245,158,11,0.4); border-radius: 0 8px 8px 0; }
        .rc-preview-author { font-style: normal; font-weight: 600; color: rgba(255,255,255,0.45); font-size: 0.75rem; margin-left: 4px; }
        .rc-actions { display: flex; align-items: center; gap: 10px; }
        .rc-btn-read { background: rgba(245,158,11,0.15); border: 1px solid rgba(245,158,11,0.35); color: #fcd34d; padding: 6px 16px; border-radius: 30px; font-size: 0.75rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .rc-btn-read:hover { background: rgba(245,158,11,0.28); }
        .rc-enrolled-badge { background: rgba(16,185,129,0.15); color: #6ee7b7; padding: 5px 12px; border-radius: 30px; font-size: 0.72rem; font-weight: 600; }
        .rc-queued-badge { background: rgba(168,85,247,0.15); color: #d8b4fe; padding: 5px 12px; border-radius: 30px; font-size: 0.72rem; font-weight: 600; }
        .reviews-empty { background: rgba(255,255,255,0.03); border: 1px solid rgba(245,158,11,0.2); border-radius: 0 0 20px 20px; text-align: center; padding: 40px; color: rgba(255,255,255,0.4); }
        .reviews-empty i { font-size: 2.5rem; display: block; margin-bottom: 10px; }
        .reviews-empty p { font-size: 0.85rem; margin: 0; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 50px 0 25px; border-top: 1px solid rgba(255, 255, 255, 0.1); margin-top: 30px; }
        .footer-brand { font-size: 1.4rem; font-weight: 800; margin-bottom: 15px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 5px 0; font-size: 0.85rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; transform: translateX(5px); }
        .copyright { text-align: center; padding-top: 30px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.8rem; }

        @media (max-width: 992px) { .courses-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } .courses-grid { grid-template-columns: 1fr; } .welcome-card { padding: 20px; } .blob { display: none; } }
    </style>
</head>
<body>

<!-- Animated Background Blobs -->
<div class="blob blob-1"></div>
<div class="blob blob-2"></div>
<div class="blob blob-3"></div>

<!-- Navigation - Matching student-dashboard.jsp exactly -->
<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container">
        <a class="navbar-brand" href="student-dashboard.jsp">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link" href="student-dashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="student-courses.jsp">My Courses</a></li>
                <li class="nav-item"><a class="nav-link active" href="register-course">Register</a></li>
                <li class="nav-item"><a class="nav-link" href="queue-status">Queue Status</a></li>
                <li class="nav-item"><a class="nav-link" href="profile-settings.jsp"><i class="fas fa-user-pen me-1"></i>Profile</a></li>
                <li class="nav-item">
                    <a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="register-container">
    <div class="container">

        <!-- Welcome Card -->
        <div class="welcome-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1><i class="fas fa-graduation-cap me-2"></i>Course Registration</h1>
                    <p class="mb-0 opacity-75">Browse available courses and join the registration queue. <strong><%= availableCount %></strong> courses available.</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <span class="badge bg-white text-dark px-3 py-2 rounded-pill">
                        <i class="fas fa-user me-1"></i> <%= student.getDepartment() %> • Semester <%= student.getSemester() %>
                    </span>
                </div>
            </div>
        </div>

        <!-- Statistics Grid -->
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-number"><%= registeredCount %></div><div class="stat-label">Registered</div></div>
            <div class="stat-card"><div class="stat-number"><%= queuedCount %></div><div class="stat-label">In Queue</div></div>
            <div class="stat-card"><div class="stat-number"><%= availableCount %></div><div class="stat-label">Available</div></div>
            <div class="stat-card"><div class="stat-number"><%= totalCourses %></div><div class="stat-label">Total Courses</div></div>
        </div>

        <!-- Alerts -->
        <% if(message != null) { %>
            <div class="alert-custom alert-success-custom"><i class="fas fa-check-circle me-2"></i> <%= message %></div>
        <% } %>
        <% if(error != null) { %>
            <div class="alert-custom alert-danger-custom"><i class="fas fa-exclamation-triangle me-2"></i> <%= error %></div>
        <% } %>

        <!-- Filter Section -->
        <div class="filter-section">
            <form method="get" action="register-course" class="row g-3 align-items-end">
                <div class="col-md-5">
                    <label class="filter-label"><i class="fas fa-search me-1"></i> Search Courses</label>
                    <div class="d-flex gap-2">
                        <input type="text" name="search" class="filter-control" placeholder="Course name, instructor or code..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                        <button type="submit" class="btn-search"><i class="fas fa-search me-1"></i> Search</button>
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="filter-label"><i class="fas fa-filter me-1"></i> Department</label>
                    <select name="department" class="filter-control" onchange="this.form.submit()">
                        <option value="all" <%= (filterDept == null || "all".equals(filterDept)) ? "selected" : "" %>>All Departments</option>
                        <option value="Computer Science" <%= "Computer Science".equals(filterDept) ? "selected" : "" %>>Computer Science</option>
                        <option value="Information Technology" <%= "Information Technology".equals(filterDept) ? "selected" : "" %>>Information Technology</option>
                        <option value="Software Engineering" <%= "Software Engineering".equals(filterDept) ? "selected" : "" %>>Software Engineering</option>
                        <option value="Data Science" <%= "Data Science".equals(filterDept) ? "selected" : "" %>>Data Science</option>
                        <option value="Cyber Security" <%= "Cyber Security".equals(filterDept) ? "selected" : "" %>>Cyber Security</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="filter-label"><i class="fas fa-sort me-1"></i> Sort By</label>
                    <select name="sort" class="filter-control" onchange="this.form.submit()">
                        <option value="">Default</option>
                        <option value="name_asc" <%= "name_asc".equals(sortBy) ? "selected" : "" %>>Name (A-Z)</option>
                        <option value="credits_desc" <%= "credits_desc".equals(sortBy) ? "selected" : "" %>>Credits (High to Low)</option>
                        <option value="seats_asc" <%= "seats_asc".equals(sortBy) ? "selected" : "" %>>Seats (Low to High)</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="filter-label">&nbsp;</label>
                    <a href="register-course" class="btn-reset w-100 text-center d-block"><i class="fas fa-sync-alt me-1"></i> Reset</a>
                </div>
            </form>
        </div>

        <!-- Courses Grid -->
        <% if(availableCourses.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-info-circle"></i>
                <h4>No courses available</h4>
                <p class="mb-4">All courses are either full or you have already registered.</p>
                <a href="student-courses.jsp" class="btn btn-primary" style="background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 10px 25px; border-radius: 40px;">View My Courses</a>
            </div>
        <% } else { %>
            <div class="courses-grid">
                <% for(Course course : availableCourses) {
                    int fillPercent = (course.getTotalSeats() - course.getAvailableSeats()) * 100 / course.getTotalSeats();
                    String progressColor = fillPercent > 80 ? "#ef4444" : (fillPercent > 50 ? "#f59e0b" : "#10b981");
                    String dept = course.getDepartment();
                    if(dept == null || dept.isEmpty()) dept = "General";
                    boolean lowSeats = course.getAvailableSeats() < 5;
                %>
                    <div class="course-card">
                        <div class="course-header">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <h3><%= course.getCourseName() %></h3>
                                    <div class="course-code"><%= course.getCourseId() %></div>
                                </div>
                                <span class="badge-available"><i class="fas fa-check-circle me-1"></i> Available</span>
                            </div>
                        </div>
                        <div class="course-body">
                            <div class="course-detail">
                                <i class="fas fa-building"></i>
                                <span><%= dept %></span>
                            </div>
                            <div class="course-detail">
                                <i class="fas fa-chalkboard-user"></i>
                                <strong>Instructor:</strong> <span><%= course.getInstructor() %></span>
                            </div>
                            <div class="course-detail">
                                <i class="fas fa-star"></i>
                                <strong>Credits:</strong> <span><%= course.getCredits() %></span>
                            </div>
                            <div class="course-detail">
                                <i class="fas fa-calendar-alt"></i>
                                <strong>Schedule:</strong> <span><%= course.getSchedule() %></span>
                            </div>
                            <div class="course-detail">
                                <i class="fas fa-users"></i>
                                <strong>Seats:</strong>
                                <span class="<%= lowSeats ? "text-danger fw-bold" : "" %>"><%= course.getAvailableSeats() %> / <%= course.getTotalSeats() %></span>
                            </div>
                            <div class="seats-bar">
                                <div class="seats-fill" style="width: <%= fillPercent %>%; background: <%= progressColor %>;"></div>
                            </div>
                            <%
                                double avgRating = avgRatingMap.getOrDefault(course.getCourseId(), 0.0);
                                int reviewCount = courseFeedbackMap.getOrDefault(course.getCourseId(), new ArrayList<>()).size();
                            %>
                            <% if (reviewCount > 0) { %>
                            <div class="reviews-summary mt-3">
                                <div class="stars-display">
                                    <% for (int s = 1; s <= 5; s++) { %>
                                        <i class="fas fa-star" style="color: <%= s <= Math.round(avgRating) ? "#f59e0b" : "rgba(255,255,255,0.2)" %>;"></i>
                                    <% } %>
                                </div>
                                <span class="rating-value"><%= String.format("%.1f", avgRating) %></span>
                                <span class="review-count">(<%= reviewCount %> review<%= reviewCount != 1 ? "s" : "" %>)</span>
                                <button class="btn-read-reviews" onclick="viewReviews('<%= course.getCourseId() %>','<%= course.getCourseName().replace("'","\\x27") %>')">
                                    Read reviews →
                                </button>
                            </div>
                            <% } else { %>
                            <div class="no-reviews-note mt-2"><i class="fas fa-comment-slash me-1"></i>No reviews yet</div>
                            <% } %>
                        </div>
                        <div class="course-footer">
                            <form action="register-course" method="post">
                                <input type="hidden" name="courseId" value="<%= course.getCourseId() %>">
                                <button type="submit" class="btn-register">
                                    <i class="fas fa-clock me-2"></i> Join Queue
                                </button>
                            </form>
                            <div class="text-center mt-2">
                                <small class="opacity-50"><i class="fas fa-info-circle"></i> FIFO - First Come First Serve</small>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

        <!-- Course Reviews Browser -->
        <%
            // Collect only courses that have at least one approved review
            List<Course> coursesWithReviews = new ArrayList<>();
            for (Course c : allCourses) {
                if (!courseFeedbackMap.getOrDefault(c.getCourseId(), new ArrayList<>()).isEmpty()) {
                    coursesWithReviews.add(c);
                }
            }
        %>
        <div class="reviews-browser-section">
            <div class="reviews-browser-header">
                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <div>
                        <h4 class="mb-1"><i class="fas fa-star me-2" style="color:#f59e0b;"></i>Course Reviews</h4>
                        <p class="mb-0" style="color:rgba(255,255,255,0.6); font-size:0.85rem;">Read what students say before you enroll</p>
                    </div>
                    <% if (!coursesWithReviews.isEmpty()) { %>
                    <span class="reviews-badge"><%= coursesWithReviews.size() %> course<%= coursesWithReviews.size() != 1 ? "s" : "" %> reviewed</span>
                    <% } %>
                </div>
            </div>

            <% if (coursesWithReviews.isEmpty()) { %>
            <div class="reviews-empty">
                <i class="fas fa-comment-slash"></i>
                <p>No course reviews yet. Be the first to review after completing a course!</p>
            </div>
            <% } else { %>
            <div class="reviewed-courses-grid">
                <% for (Course rc : coursesWithReviews) {
                    List<Feedback> rcFeedbacks = courseFeedbackMap.get(rc.getCourseId());
                    double rcAvg = avgRatingMap.getOrDefault(rc.getCourseId(), 0.0);
                    int rcCount = rcFeedbacks.size();
                    String rcDept = rc.getDepartment();
                    if (rcDept == null || rcDept.isEmpty()) rcDept = "General";
                    boolean isRegistered = registeredCourseIds.contains(rc.getCourseId());
                    boolean isQueued = queuedCourseIds.contains(rc.getCourseId());
                %>
                <div class="reviewed-course-card">
                    <div class="reviewed-course-top">
                        <div class="reviewed-course-info">
                            <div class="reviewed-course-name"><%= rc.getCourseName() %></div>
                            <div class="reviewed-course-meta">
                                <span class="rc-dept-badge"><%= rcDept %></span>
                                <span style="color:rgba(255,255,255,0.45); font-size:0.72rem;"><%= rc.getInstructor() %></span>
                            </div>
                        </div>
                        <div class="reviewed-course-rating">
                            <div class="rc-stars">
                                <% for (int s = 1; s <= 5; s++) { %>
                                    <i class="fas fa-star" style="color:<%= s <= Math.round(rcAvg) ? "#f59e0b" : "rgba(255,255,255,0.2)" %>; font-size:0.8rem;"></i>
                                <% } %>
                            </div>
                            <div class="rc-rating-line">
                                <span class="rc-avg"><%= String.format("%.1f", rcAvg) %></span>
                                <span class="rc-count"><%= rcCount %> review<%= rcCount != 1 ? "s" : "" %></span>
                            </div>
                        </div>
                    </div>
                    <% Feedback firstFb = rcFeedbacks.get(0); %>
                    <div class="rc-preview">
                        "<%= firstFb.getComment().length() > 90 ? firstFb.getComment().substring(0,90) + "…" : firstFb.getComment() %>"
                        <span class="rc-preview-author">— <%= firstFb.getStudentName() %></span>
                    </div>
                    <div class="rc-actions">
                        <button class="rc-btn-read" onclick="viewReviews('<%= rc.getCourseId() %>','<%= rc.getCourseName().replace("'","\\x27") %>')">
                            <i class="fas fa-book-open me-1"></i>Read all <%= rcCount %> review<%= rcCount != 1 ? "s" : "" %>
                        </button>
                        <% if (isRegistered) { %>
                            <span class="rc-enrolled-badge"><i class="fas fa-check me-1"></i>Enrolled</span>
                        <% } else if (isQueued) { %>
                            <span class="rc-queued-badge"><i class="fas fa-clock me-1"></i>In Queue</span>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- Info Card -->
        <div class="info-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h6><i class="fas fa-hourglass-half me-2"></i> How Registration Works</h6>
                    <p class="mb-0 small opacity-75">Click "Join Queue" → Request added to FIFO queue → Admin approves in order → You're automatically enrolled and notified.</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <a href="queue-status" class="btn btn-light btn-sm rounded-pill px-4" style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white;">View Queue <i class="fas fa-arrow-right ms-1"></i></a>
                </div>
            </div>
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

<!-- Reviews Modal -->
<div class="modal fade" id="reviewsModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="background:#1e1b4b; border:1px solid rgba(255,255,255,0.15); border-radius:20px; color:white;">
            <div class="modal-header" style="border-bottom:1px solid rgba(255,255,255,0.1); padding: 16px 22px;">
                <div>
                    <h5 class="modal-title mb-0"><i class="fas fa-star me-2" style="color:#f59e0b;"></i>Reviews: <span id="reviewsCourseTitle"></span></h5>
                    <div id="reviewsAvgLine" class="mt-1" style="font-size:0.8rem; color:rgba(255,255,255,0.6);"></div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" style="filter:invert(1);"></button>
            </div>
            <div class="modal-body p-3" id="reviewsBody" style="max-height:460px; overflow-y:auto;">
                <p style="color:rgba(255,255,255,0.5);">Loading...</p>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Embed all approved reviews from server
    var allFeedbacks = {
<%
    boolean firstCourse = true;
    for (Course c : allCourses) {
        List<Feedback> fbs = courseFeedbackMap.getOrDefault(c.getCourseId(), new java.util.ArrayList<>());
        if (!firstCourse) out.print(",");
        firstCourse = false;
        out.print("\"" + c.getCourseId() + "\":[");
        boolean firstFb = true;
        for (Feedback fb : fbs) {
            if (!firstFb) out.print(",");
            firstFb = false;
            String safeComment = fb.getComment().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n");
            String safeName = fb.getStudentName().replace("\\","\\\\").replace("\"","\\\"");
            out.print("{\"student\":\"" + safeName + "\",\"rating\":" + fb.getRating() +
                    ",\"comment\":\"" + safeComment + "\",\"date\":\"" + fb.getFeedbackDate().toString().substring(0,10) + "\"}");
        }
        out.print("]");
    }
%>
    };

    function viewReviews(courseId, courseName) {
        var feedbacks = allFeedbacks[courseId] || [];
        document.getElementById('reviewsCourseTitle').textContent = courseName;

        // Build avg summary line
        var avgLine = '';
        if (feedbacks.length > 0) {
            var total = feedbacks.reduce(function(s, f) { return s + f.rating; }, 0);
            var avg = (total / feedbacks.length).toFixed(1);
            var stars = '';
            for (var i = 1; i <= 5; i++) {
                stars += '<i class="fas fa-star" style="color:' + (i <= Math.round(avg) ? '#f59e0b' : 'rgba(255,255,255,0.2)') + '; font-size:0.8rem;"></i> ';
            }
            avgLine = stars + ' <strong style="color:#fcd34d;">' + avg + '</strong> &nbsp;·&nbsp; ' + feedbacks.length + ' review' + (feedbacks.length !== 1 ? 's' : '');
        }
        document.getElementById('reviewsAvgLine').innerHTML = avgLine;

        var html = '';
        if (feedbacks.length === 0) {
            html = '<div style="text-align:center; padding:40px; color:rgba(255,255,255,0.4);"><i class="fas fa-comment-slash" style="font-size:2.5rem; margin-bottom:12px; display:block;"></i>No reviews yet for this course.</div>';
        } else {
            feedbacks.forEach(function(fb) {
                var stars = '';
                for (var i = 1; i <= 5; i++) {
                    stars += '<i class="fas fa-star" style="color:' + (i <= fb.rating ? '#f59e0b' : 'rgba(255,255,255,0.2)') + ';"></i>';
                }
                html += '<div class="review-item">' +
                    '<div class="review-header">' +
                    '<span class="review-author"><i class="fas fa-user-circle me-2" style="color:#a855f7;"></i>' + escHtml(fb.student) + '</span>' +
                    '<span class="review-date">' + fb.date + '</span>' +
                    '</div>' +
                    '<div class="review-stars">' + stars + '</div>' +
                    '<p class="review-comment">' + escHtml(fb.comment) + '</p>' +
                    '</div>';
            });
        }
        document.getElementById('reviewsBody').innerHTML = html;
        new bootstrap.Modal(document.getElementById('reviewsModal')).show();
    }

    function escHtml(str) {
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(str));
        return d.innerHTML;
    }
</script>
</body>
</html>
