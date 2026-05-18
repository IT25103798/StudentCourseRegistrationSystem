<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.model.Admin" %>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.UserDAO" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.RegistrationRequest" %>
<%@ page import="java.util.*" %>
<%
    Admin admin = (Admin) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (admin == null || username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    CourseDAO courseDAO = new CourseDAO();
    UserDAO userDAO = new UserDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    int totalCourses = courseDAO.getAllCourses().size();
    int totalStudents = userDAO.getAllStudents().size();
    int queueSize = registrationDAO.getQueueSize();

    // Get recent registrations (last 5)
    List<com.registration.model.Registration> recentRegistrations = registrationDAO.getAllRegistrations();
    List<com.registration.model.Registration> lastFive = new ArrayList<>();
    int regCount = recentRegistrations.size();
    for (int i = Math.max(0, regCount - 5); i < regCount; i++) {
        lastFive.add(recentRegistrations.get(i));
    }

    // Get top courses by enrollment
    List<Course> allCourses = courseDAO.getAllCourses();
    Map<String, Integer> courseEnrollment = new LinkedHashMap<>();
    Map<String, Integer> courseSeatsLeft = new LinkedHashMap<>();
    for (Course c : allCourses) {
        int enrolled = 0;
        for (com.registration.model.Registration r : recentRegistrations) {
            if (r.getCourseId().equals(c.getCourseId()) && "approved".equals(r.getStatus())) {
                enrolled++;
            }
        }
        courseEnrollment.put(c.getCourseName(), enrolled);
        courseSeatsLeft.put(c.getCourseName(), c.getAvailableSeats());
    }

    // Get recent queue requests
    List<RegistrationRequest> queueList = registrationDAO.getQueueStatus();
    List<RegistrationRequest> recentQueue = queueList.size() > 5 ? queueList.subList(0, 5) : queueList;

    String currentPage = request.getRequestURI();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | CourseReg</title>
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

        /* Navbar */
        .navbar { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); padding: 0.8rem 0; border-bottom: 1px solid rgba(255, 255, 255, 0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 1.6rem; font-weight: 800; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-link { color: rgba(255, 255, 255, 0.8) !important; font-weight: 500; margin: 0 0.3rem; padding: 8px 18px !important; border-radius: 40px; transition: all 0.3s; }
        .nav-link:hover { background: rgba(255, 255, 255, 0.1); color: white !important; }
        .nav-link.active { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white !important; box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-logout { background: linear-gradient(135deg, #ef4444, #dc2626); color: white; border: none; padding: 8px 22px; border-radius: 40px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; margin-left: 8px; }
        .btn-logout:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3); }

        /* Container */
        .dashboard-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Welcome Header */
        .welcome-header { margin-bottom: 35px; }
        .welcome-header h1 { font-size: 2rem; font-weight: 700; color: white; }
        .admin-badge { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; padding: 8px 20px; border-radius: 40px; font-weight: 600; font-size: 0.85rem; }

        /* Stats Cards */
        .stats-row { display: flex; gap: 20px; margin-bottom: 35px; flex-wrap: wrap; }
        .stat-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 24px; padding: 20px 24px; flex: 1; min-width: 180px; transition: all 0.3s; border: 1px solid rgba(255, 255, 255, 0.1); cursor: pointer; }
        .stat-card:hover { transform: translateY(-4px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.3); }
        .stat-number { font-size: 2.2rem; font-weight: 800; color: #a855f7; line-height: 1; }
        .stat-label { color: rgba(255, 255, 255, 0.7); font-size: 0.8rem; font-weight: 500; margin-top: 6px; }
        .stat-icon { width: 48px; height: 48px; background: rgba(168, 85, 247, 0.2); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; color: #a855f7; }

        /* Quick Actions Card */
        .quick-actions-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 24px; padding: 24px 28px; margin-bottom: 35px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .quick-actions-card h5 { font-weight: 600; margin-bottom: 20px; color: white; }
        .quick-action-btn { padding: 12px; border-radius: 40px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; display: inline-block; width: 100%; text-align: center; text-decoration: none; }
        .quick-action-btn:hover { transform: translateY(-2px); }

        /* Content Cards */
        .content-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 24px; padding: 24px 28px; margin-bottom: 30px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .content-card h5 { font-weight: 600; margin-bottom: 20px; color: white; }

        /* Tables */
        .custom-table { width: 100%; border-collapse: collapse; }
        .custom-table thead th { background: rgba(255, 255, 255, 0.08); padding: 12px 16px; font-weight: 600; font-size: 0.75rem; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        .custom-table tbody td { padding: 10px 16px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); font-size: 0.8rem; color: rgba(255, 255, 255, 0.8); }
        .custom-table tbody tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-approved { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 12px; border-radius: 40px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-enrolled { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 4px 10px; border-radius: 40px; font-size: 0.7rem; font-weight: 600; }

        /* Info Card */
        .info-card { background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 24px; padding: 28px 32px; color: white; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 50px 0 25px; border-top: 1px solid rgba(255, 255, 255, 0.1); margin-top: 30px; }
        .footer-brand { font-size: 1.4rem; font-weight: 800; margin-bottom: 15px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 5px 0; font-size: 0.85rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; transform: translateX(5px); }
        .copyright { text-align: center; padding-top: 30px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.8rem; }

        @media (max-width: 768px) { .dashboard-container { padding: 120px 0 40px; } .stats-row { flex-direction: column; } .blob { display: none; } }
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
        <a class="navbar-brand" href="admin">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link active" href="admin">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="courses">Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="admin?action=queue">Queue</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-students.jsp">Students</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="dashboard-container">
    <div class="container">

        <!-- Welcome Header -->
        <div class="welcome-header d-flex justify-content-between align-items-center flex-wrap">
            <div>
                <h1 class="fw-bold mb-1">Admin Dashboard</h1>
                <p class="opacity-75">Manage courses, registrations, and system settings</p>
            </div>
            <div class="mt-2 mt-md-0">
                <span class="admin-badge"><i class="fas fa-user-cog me-2"></i><%= username %></span>
                <span class="ms-2 badge bg-danger px-3 py-2 rounded-pill"><i class="fas fa-shield-alt me-1"></i> ADMIN</span>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-row">
            <div class="stat-card" onclick="window.location='courses'">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number"><%= totalCourses %></div><div class="stat-label">Total Courses</div></div>
                    <div class="stat-icon"><i class="fas fa-book"></i></div>
                </div>
            </div>
            <div class="stat-card" onclick="window.location='manage-students.jsp'">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number"><%= totalStudents %></div><div class="stat-label">Total Students</div></div>
                    <div class="stat-icon"><i class="fas fa-users"></i></div>
                </div>
            </div>
            <div class="stat-card" onclick="window.location='admin?action=queue'">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number"><%= queueSize %></div><div class="stat-label">Queue Size</div></div>
                    <div class="stat-icon"><i class="fas fa-hourglass-half"></i></div>
                </div>
                <% if(queueSize > 0) { %>
                    <span class="badge bg-danger mt-2 rounded-pill px-3">Pending: <%= queueSize %></span>
                <% } %>
            </div>
            <div class="stat-card" onclick="window.location='reports.jsp'">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number"><%= recentRegistrations.size() %></div><div class="stat-label">Total Registrations</div></div>
                    <div class="stat-icon"><i class="fas fa-check-circle"></i></div>
                </div>
            </div>
        </div>

        <!-- Quick Actions - WITH VISIBLE COLORS -->
        <div class="quick-actions-card">
            <h5><i class="fas fa-bolt me-2" style="color: #f59e0b;"></i> Quick Actions</h5>
            <div class="row g-3">
                <div class="col-md-3 col-sm-6">
                    <a href="courses?action=add" class="quick-action-btn" style="background: #2563eb; color: white; border: none;">
                        <i class="fas fa-plus me-2"></i> Add Course
                    </a>
                </div>
                <div class="col-md-3 col-sm-6">
                    <a href="admin?action=queue" class="quick-action-btn" style="background: #f59e0b; color: #1e293b; border: none;">
                        <i class="fas fa-clock me-2"></i> Process Queue
                        <% if(queueSize > 0) { %>
                            <span class="badge bg-danger ms-2" style="background: #dc2626; color: white;"><%= queueSize %></span>
                        <% } %>
                    </a>
                </div>
                <div class="col-md-3 col-sm-6">
                    <a href="manage-students.jsp" class="quick-action-btn" style="background: #10b981; color: white; border: none;">
                        <i class="fas fa-user-plus me-2"></i> Add Student
                    </a>
                </div>
                <div class="col-md-3 col-sm-6">
                    <a href="reports.jsp" class="quick-action-btn" style="background: #06b6d4; color: white; border: none;">
                        <i class="fas fa-chart-line me-2"></i> View Reports
                    </a>
                </div>
            </div>
        </div>

        <!-- Two Column Layout -->
        <div class="row g-4">
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-history me-2" style="color: #a855f7;"></i> Recent Registrations</h5>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Student ID</th>
                                    <th>Course</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if(lastFive.isEmpty()) { %>
                                    <tr><td colspan="4" class="text-center py-4 opacity-50">No registrations yet</td></tr>
                                <% } else {
                                    for(com.registration.model.Registration reg : lastFive) {
                                        Course c = courseDAO.findCourseById(reg.getCourseId());
                                        String courseName = (c != null) ? c.getCourseName() : "Unknown";
                                %>
                                    <tr>
                                        <td><%= reg.getStudentId() %></td>
                                        <td><%= courseName %></td>
                                        <td><small><%= reg.getRegistrationDate() %></small></td>
                                        <td><span class="badge-approved"><%= reg.getStatus() %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-trophy me-2" style="color: #f59e0b;"></i> Top Courses by Enrollment</h5>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Course Name</th>
                                    <th>Enrolled</th>
                                    <th>Seats Left</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Map.Entry<String, Integer>> sortedCourses = new ArrayList<>(courseEnrollment.entrySet());
                                    sortedCourses.sort((a, b) -> b.getValue().compareTo(a.getValue()));
                                    int count = 0;
                                    for(Map.Entry<String, Integer> entry : sortedCourses) {
                                        if(count++ >= 5) break;
                                        int seatsLeft = courseSeatsLeft.getOrDefault(entry.getKey(), 0);
                                %>
                                    <tr>
                                        <td><strong><%= entry.getKey() %></strong></td>
                                        <td><span class="badge-enrolled"><%= entry.getValue() %> enrolled</span></td>
                                        <td><%= seatsLeft %> seats</td>
                                    </tr>
                                <% } %>
                                <% if(sortedCourses.isEmpty()) { %>
                                    <tr><td colspan="3" class="text-center py-4 opacity-50">No enrollments yet</tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Queue Requests -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="content-card">
                    <h5><i class="fas fa-clock me-2" style="color: #f59e0b;"></i> Pending Queue Requests</h5>
                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Course</th>
                                    <th>Request Time</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if(recentQueue.isEmpty()) { %>
                                    <tr><td colspan="4" class="text-center py-4 opacity-50">No pending requests</tr>
                                <% } else {
                                    for(RegistrationRequest req : recentQueue) { %>
                                    <tr>
                                        <td><strong><%= req.getStudentName() %></strong></td>
                                        <td><%= req.getCourseName() %></td>
                                        <td><small><%= req.getRequestTime() %></small></td>
                                        <td><a href="admin?action=approve&requestId=<%= req.getRequestId() %>" class="btn btn-sm" style="background: #10b981; color: white; border: none; border-radius: 40px; padding: 5px 15px;" onclick="return confirm('Approve this registration?')">Approve</a></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                    <% if(queueSize > 5) { %>
                        <div class="text-center mt-3"><a href="admin?action=queue" style="color: #a855f7;">View all <%= queueSize %> requests →</a></div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- System Info Card -->
        <div class="row mt-2">
            <div class="col-12">
                <div class="info-card">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h5 class="mb-2"><i class="fas fa-info-circle me-2"></i> System Information</h5>
                            <p class="mb-0 small opacity-75">FIFO (First-In-First-Out) queue for fair registration. Courses prioritized using Insertion Sort based on available seats. All data stored securely via file handling.</p>
                        </div>
                        <div class="col-md-4 text-md-end mt-3 mt-md-0"><i class="fas fa-database fa-3x opacity-25 me-3"></i><i class="fas fa-code-branch fa-3x opacity-25"></i></div>
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
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Quick Links</h6><a href="admin">Dashboard</a><a href="courses">Courses</a><a href="admin?action=queue">Queue</a></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Management</h6><a href="manage-students.jsp">Students</a><a href="reports.jsp">Reports</a></div>
            <div class="col-md-4 mb-3 footer-links"><h6 class="text-white mb-2">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-linkedin"></i></a><a href="#"><i class="fab fa-github"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p></div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>window.addEventListener('scroll', function() { const navbar = document.getElementById('navbar'); if (window.scrollY > 50) navbar.classList.add('scrolled'); else navbar.classList.remove('scrolled'); });</script>
</body>
</html>