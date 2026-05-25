<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="com.registration.model.RegistrationRequest" %>
<%@ page import="com.registration.model.Course" %>
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
    RegistrationDAO registrationDAO = new RegistrationDAO();
    CourseDAO courseDAO = new CourseDAO();

    // Get ALL queue requests (PENDING)
    List<RegistrationRequest> allQueue = registrationDAO.getQueueStatus();

    // Filter ONLY current student's queue requests (PENDING)
    List<RegistrationRequest> myQueue = new ArrayList<>();
    for (RegistrationRequest req : allQueue) {
        if (req.getStudentId().equals(student.getId())) {
            myQueue.add(req);
        }
    }

    // Get APPROVED registrations
    List<Registration> approvedRegistrations = registrationDAO.getRegistrationsByStudent(student.getId());
    int approvedCount = approvedRegistrations.size();
    int totalCredits = 0;
    for (Registration reg : approvedRegistrations) {
        Course c = courseDAO.findCourseById(reg.getCourseId());
        if (c != null) {
            totalCredits += c.getCredits();
        }
    }

    int myQueueSize = myQueue.size();
    int totalQueueSize = allQueue.size();

    // Get REJECTED registrations
    List<String> rejectedRegistrations = new ArrayList<>();
    int rejectedCount = 0;

    try {
        String rejectedFile = application.getRealPath("/") + "../../../../data/rejected_registrations.txt";
        java.io.File file = new java.io.File(rejectedFile);
        if (!file.exists()) {
            // Fallback: try relative to working directory
            file = new java.io.File("data/rejected_registrations.txt");
        }
        if (file.exists()) {
            java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.FileReader(file));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.contains(student.getId())) {
                    rejectedRegistrations.add(line);
                    rejectedCount++;
                }
            }
            reader.close();
        }
    } catch (Exception e) {
        System.out.println("Error reading rejected file: " + e.getMessage());
    }

    // Auto refresh interval (in seconds)
    int refreshInterval = 15;

    String currentPage = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Queue Status | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <meta http-equiv="refresh" content="<%= refreshInterval %>">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #0f0c29; background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%); color: #fff; min-height: 100vh; overflow-x: hidden; }

        /* Animated Background */
        .blob { position: fixed; width: 400px; height: 400px; background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 50%; filter: blur(80px); opacity: 0.3; animation: float 6s ease-in-out infinite; pointer-events: none; z-index: 0; }
        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -4s; opacity: 0.2; }
        @keyframes float { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 50% { transform: translate(30px, -30px) rotate(5deg); } }

        /* Navbar */
        .navbar { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); padding: 0.8rem 0; border-bottom: 1px solid rgba(255, 255, 255, 0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 1.6rem; font-weight: 800; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-link { color: rgba(255, 255, 255, 0.8) !important; font-weight: 500; margin: 0 0.3rem; padding: 8px 18px !important; border-radius: 40px; transition: all 0.3s; }
        .nav-link:hover { background: rgba(255, 255, 255, 0.1); color: white !important; }
        .nav-link.active { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white !important; box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-logout { background: linear-gradient(135deg, #ef4444, #dc2626); color: white; border: none; padding: 8px 22px; border-radius: 40px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; margin-left: 8px; }
        .btn-logout:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3); }

        /* Container */
        .queue-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Header Card */
        .header-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border-radius: 28px; padding: 32px 36px; color: white; margin-bottom: 35px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .header-card h1 { font-size: 2rem; font-weight: 700; }

        /* Stats Cards */
        .stats-row { display: flex; gap: 20px; margin-bottom: 30px; flex-wrap: wrap; }
        .stat-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px; flex: 1; min-width: 140px; text-align: center; transition: all 0.3s; border: 1px solid rgba(255, 255, 255, 0.1); }
        .stat-card:hover { transform: translateY(-3px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.3); }
        .stat-number { font-size: 2rem; font-weight: 800; color: #a855f7; }
        .stat-label { color: rgba(255, 255, 255, 0.7); font-size: 0.75rem; margin-top: 5px; }

        /* Queue Info Card */
        .queue-info-card { background: rgba(245, 158, 11, 0.15); border-radius: 20px; padding: 15px 20px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; border-left: 4px solid #f59e0b; }
        .refresh-indicator { background: rgba(255, 255, 255, 0.1); border-radius: 30px; padding: 5px 15px; font-size: 0.7rem; color: rgba(255, 255, 255, 0.7); display: inline-flex; align-items: center; gap: 8px; }

        /* Content Cards */
        .content-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 24px; padding: 24px 28px; margin-bottom: 30px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .section-title { font-size: 1rem; font-weight: 600; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); display: flex; align-items: center; gap: 10px; }
        .section-title i { color: #a855f7; }

        /* Tables */
        .custom-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        .custom-table th { background: rgba(255, 255, 255, 0.08); padding: 10px 12px; font-weight: 600; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        .custom-table td { padding: 10px 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); vertical-align: middle; color: rgba(255, 255, 255, 0.8); }
        .custom-table tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-next { background: rgba(245, 158, 11, 0.2); color: #fcd34d; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-position { background: rgba(255, 255, 255, 0.1); color: rgba(255, 255, 255, 0.7); padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .status-pending { background: rgba(245, 158, 11, 0.15); color: #fcd34d; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .status-approved { background: rgba(16, 185, 129, 0.15); color: #6ee7b7; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .status-rejected { background: rgba(239, 68, 68, 0.15); color: #fca5a5; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }

        /* Empty State */
        .empty-state { text-align: center; padding: 40px 20px; }
        .empty-state i { font-size: 3rem; color: rgba(255, 255, 255, 0.3); margin-bottom: 15px; }
        .empty-state h5 { font-size: 1rem; color: rgba(255, 255, 255, 0.6); }

        /* Buttons */
        .btn-back { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; border: none; padding: 10px 28px; border-radius: 40px; font-weight: 500; font-size: 0.85rem; text-decoration: none; display: inline-block; transition: all 0.3s; }
        .btn-back:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.4); }

        /* Info Card */
        .info-card { background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 20px; padding: 20px 24px; color: white; margin-top: 10px; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 50px 0 25px; border-top: 1px solid rgba(255, 255, 255, 0.1); margin-top: 30px; }
        .footer-brand { font-size: 1.4rem; font-weight: 800; margin-bottom: 15px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 5px 0; font-size: 0.85rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; transform: translateX(5px); }
        .copyright { text-align: center; padding-top: 30px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.8rem; }

        @media (max-width: 768px) { .queue-container { padding: 120px 0 40px; } .stats-row { flex-direction: column; } .custom-table { font-size: 0.7rem; } .blob { display: none; } }
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
                <li class="nav-item"><a class="nav-link" href="student-dashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="student-courses.jsp">My Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="register-course">Register</a></li>
                <li class="nav-item"><a class="nav-link active" href="queue-status">Queue Status</a></li>
                <li class="nav-item"><a class="nav-link" href="profile-settings.jsp"><i class="fas fa-user-pen me-1"></i>Profile</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="queue-container">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-10">

                <!-- Header -->
                <div class="header-card">
                    <h1 class="fw-bold mb-1"><i class="fas fa-hourglass-half me-2"></i>My Queue Status</h1>
                    <p class="mb-0 opacity-75">Track your registration requests - Pending, Approved & Rejected</p>
                </div>

                <!-- Statistics Cards -->
                <div class="stats-row">
                    <div class="stat-card"><div class="stat-number"><%= myQueueSize %></div><div class="stat-label">Pending</div></div>
                    <div class="stat-card"><div class="stat-number"><%= approvedCount %></div><div class="stat-label">Approved</div></div>
                    <div class="stat-card"><div class="stat-number"><%= totalCredits %></div><div class="stat-label">Total Credits</div></div>
                    <div class="stat-card"><div class="stat-number"><%= rejectedCount %></div><div class="stat-label">Rejected</div></div>
                </div>

                <!-- Queue Info -->
                <div class="queue-info-card">
                    <div><i class="fas fa-info-circle me-2" style="color: #fcd34d;"></i><strong>Your Queue:</strong> <%= myQueueSize %> pending request(s)</div>
                    <div class="refresh-indicator"><i class="fas fa-sync-alt"></i> Refreshes in <span id="countdown"><%= refreshInterval %></span>s</div>
                </div>

                <!-- Pending Requests Table -->
                <div class="content-card">
                    <div class="section-title"><i class="fas fa-clock"></i> Pending Requests <span class="badge bg-warning ms-2" style="background: rgba(245,158,11,0.2); color: #fcd34d;"><%= myQueueSize %></span></div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead><tr><th>Position</th><th>Course Name</th><th>Request Time</th><th>Status</th></tr></thead>
                            <tbody>
                                <% if(myQueue.isEmpty()) { %>
                                    <tr><td colspan="4" class="text-center"><div class="empty-state"><i class="fas fa-inbox"></i><h5>No pending requests</h5><a href="register-course" class="btn btn-primary btn-sm mt-2" style="background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 5px 15px; border-radius: 40px;">Register</a></div></td></tr>
                                <% } else { int pos = 1; for(RegistrationRequest req : myQueue) { %>
                                    <tr class="<%= pos == 1 ? "table-warning" : "" %>">
                                        <td><% if(pos == 1) { %><span class="badge-next">#<%= pos %> - NEXT</span><% } else { %><span class="badge-position">#<%= pos %></span><% } %></td>
                                        <td><strong><%= req.getCourseName() %></strong></td>
                                        <td><small><%= req.getRequestTime() %></small></td>
                                        <td><span class="status-pending"><i class="fas fa-hourglass-half me-1"></i> Pending</span></td>
                                    </tr>
                                <% pos++; } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Approved Courses Table -->
                <div class="content-card">
                    <div class="section-title"><i class="fas fa-check-circle"></i> Approved Courses <span class="badge bg-success ms-2" style="background: rgba(16,185,129,0.2); color: #6ee7b7;"><%= approvedCount %></span></div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead><tr><th>Course Code</th><th>Course Name</th><th>Instructor</th><th>Credits</th><th>Registration Date</th><th>Status</th></tr></thead>
                            <tbody>
                                <% if(approvedRegistrations.isEmpty()) { %>
                                    <tr><td colspan="6" class="text-center"><div class="empty-state"><i class="fas fa-book-open"></i><h5>No approved courses yet</h5><a href="register-course" class="btn btn-primary btn-sm mt-2" style="background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 5px 15px; border-radius: 40px;">Browse Courses</a></div></td></tr>
                                <% } else {
                                    for(Registration reg : approvedRegistrations) {
                                        Course c = courseDAO.findCourseById(reg.getCourseId());
                                        if(c != null) { %>
                                            <tr>
                                                <td><strong><%= c.getCourseId() %></strong></td>
                                                <td><%= c.getCourseName() %></td>
                                                <td><%= c.getInstructor() %></td>
                                                <td><span class="badge bg-info" style="background: rgba(168,85,247,0.2); color: #d8b4fe;"><%= c.getCredits() %></span></td>
                                                <td><small><%= reg.getRegistrationDate() %></small></td>
                                                <td><span class="status-approved"><i class="fas fa-check-circle me-1"></i> Approved</span></td>
                                            </tr>
                                <% } } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Rejected Requests Table -->
                <div class="content-card">
                    <div class="section-title"><i class="fas fa-times-circle"></i> Rejected Requests <span class="badge bg-danger ms-2" style="background: rgba(239,68,68,0.2); color: #fca5a5;"><%= rejectedCount %></span></div>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead><tr><th>Request ID</th><th>Course Name</th><th>Request Time</th><th>Status</th></tr></thead>
                            <tbody>
                                <% if(rejectedRegistrations.isEmpty()) { %>
                                    <tr><td colspan="4" class="text-center"><div class="empty-state"><i class="fas fa-check-circle"></i><h5>No rejected requests</h5></div></td></tr>
                                <% } else {
                                    for(String rejected : rejectedRegistrations) {
                                        String[] parts = rejected.split("\\|");
                                        String reqId = parts.length > 0 ? parts[0] : "N/A";
                                        String courseName = parts.length > 4 ? parts[4] : "Unknown";
                                        String reqTime = parts.length > 5 ? parts[5] : "Unknown";
                                %>
                                    <tr>
                                        <td><code><%= reqId %></code></td>
                                        <td><strong><%= courseName %></strong></td>
                                        <td><small><%= reqTime %></small></td>
                                        <td><span class="status-rejected"><i class="fas fa-times-circle me-1"></i> Rejected</span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Back Button -->
                <div class="text-center mt-3">
                    <a href="student-dashboard.jsp" class="btn-back"><i class="fas fa-arrow-left me-2"></i>Back to Dashboard</a>
                </div>

                <!-- Info Card -->
                <div class="info-card mt-4">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h6 class="mb-1"><i class="fas fa-info-circle me-2"></i>Queue Processing Information</h6>
                            <p class="mb-0 small opacity-75">FIFO order: <span class="fw-bold text-warning">Pending</span> → Waiting | <span class="fw-bold text-success">Approved</span> → Enrolled | <span class="fw-bold text-danger">Rejected</span> → Try again</p>
                        </div>
                        <div class="col-md-4 text-md-end mt-2 mt-md-0">
                            <i class="fas fa-chart-line fa-2x opacity-25"></i>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3"><div class="footer-brand">Course<span>Reg</span></div><p class="text-white-50 small">Smart course registration system.</p></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Quick Links</h6><a href="student-dashboard.jsp">Dashboard</a><a href="student-courses.jsp">My Courses</a><a href="register-course">Register</a></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Support</h6><a href="#">Help</a><a href="#">Contact</a><a href="#">FAQs</a></div>
            <div class="col-md-4 mb-3 footer-links"><h6 class="text-white mb-2">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-linkedin"></i></a><a href="#"><i class="fab fa-github"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p></div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let secondsLeft = <%= refreshInterval %>;
    const countdownSpan = document.getElementById('countdown');
    function updateCountdown() { if(countdownSpan) { countdownSpan.innerText = secondsLeft; secondsLeft--; if(secondsLeft < 0) secondsLeft = <%= refreshInterval %>; } }
    setInterval(updateCountdown, 1000);
</script>
</body>
</html>
