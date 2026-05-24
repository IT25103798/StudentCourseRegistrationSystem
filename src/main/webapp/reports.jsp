<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.UserDAO" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    CourseDAO courseDAO = new CourseDAO();
    UserDAO userDAO = new UserDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();

    List<Course> allCourses = courseDAO.getAllCourses();
    List<Student> allStudents = userDAO.getAllStudents();
    List<Registration> allRegistrations = registrationDAO.getAllRegistrations();

    Map<String, Integer> deptCount = new LinkedHashMap<>();
    Map<Integer, Integer> semesterCount = new HashMap<>();

    for (Student s : allStudents) {
        String dept = s.getDepartment();
        deptCount.put(dept, deptCount.getOrDefault(dept, 0) + 1);
        int sem = s.getSemester();
        semesterCount.put(sem, semesterCount.getOrDefault(sem, 0) + 1);
    }

    int totalCourses = allCourses.size();
    int totalStudents = allStudents.size();
    int totalRegistrations = allRegistrations.size();
    int pendingQueue = registrationDAO.getQueueSize();

    int totalSeats = 0, occupiedSeats = 0;
    for (Course c : allCourses) {
        totalSeats += c.getTotalSeats();
        occupiedSeats += c.getTotalSeats() - c.getAvailableSeats();
    }
    double utilization = totalSeats > 0 ? (occupiedSeats * 100.0 / totalSeats) : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
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
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
            animation: float 6s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }

        .blob-1 {
            top: 10%;
            left: -5%;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
        }

        .blob-2 {
            bottom: 0;
            right: -5%;
            width: 500px;
            height: 500px;
            background: linear-gradient(135deg, #06b6d4, #3b82f6);
            animation-delay: -2s;
        }

        .blob-3 {
            top: 50%;
            left: 30%;
            width: 300px;
            height: 300px;
            background: linear-gradient(135deg, #f59e0b, #ef4444);
            animation-delay: -4s;
            opacity: 0.2;
        }

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

                .btn-logout {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
            width: 38px;
            height: 38px;
            border-radius: 50%;
            font-size: 1rem;
            transition: all 0.3s;
            margin-left: 8px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .btn-logout:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3);
        }

        /* Container */
        .reports-container {
            padding: 100px 0 50px;
            position: relative;
            z-index: 1;
        }

        /* Report Header */
        .report-header {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 28px;
            padding: 32px 36px;
            color: white;
            margin-bottom: 35px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .report-header h1 {
            font-size: 2rem;
            font-weight: 700;
        }

        /* Stats Cards */
        .stats-row {
            display: flex;
            gap: 20px;
            margin-bottom: 35px;
            flex-wrap: wrap;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 20px 24px;
            flex: 1;
            min-width: 160px;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
            text-align: center;
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
        }

        .stat-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.75rem;
            margin-top: 5px;
        }

        /* Content Cards */
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 24px 28px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            height: 100%;
        }

        .content-card h5 {
            font-weight: 600;
            margin-bottom: 20px;
            color: white;
        }

        /* Chart Container */
        .chart-container {
            position: relative;
            height: 280px;
            margin-top: 10px;
        }

        /* Buttons */
        .btn-print {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 8px 20px;
            border-radius: 40px;
            color: white;
            margin-right: 10px;
            transition: all 0.3s;
        }

        .btn-print:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-1px);
        }

        .btn-export {
            background: #10b981;
            border: none;
            padding: 8px 20px;
            border-radius: 40px;
            color: white;
            transition: all 0.3s;
        }

        .btn-export:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        /* Progress Bar */
        .progress-custom {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            height: 6px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 10px;
        }

        /* Badge */
        .badge-util {
            padding: 5px 12px;
            border-radius: 40px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        /* Table */
        .data-table {
            width: 100%;
            font-size: 0.85rem;
        }

        .data-table thead th {
            background: rgba(255, 255, 255, 0.08);
            padding: 10px 12px;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .data-table tbody td {
            padding: 8px 12px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8);
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

        /* Responsive */
        @media (max-width: 768px) {
            .reports-container {
                padding: 120px 0 40px;
            }
            .stats-row {
                flex-direction: column;
            }
            .chart-container {
                height: 200px;
            }
            .blob {
                display: none;
            }
        }

        /* Print */
        @media print {
            .navbar, .btn-logout, .btn-print, .btn-export, footer {
                display: none;
            }
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
        <a class="navbar-brand" href="admin">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link" href="admin">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="courses">Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="admin?action=queue">Queue</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-students.jsp">Students</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-admins">Admins</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-enrollments">Enrollments</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link active" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="reports-container">
    <div class="container">

        <!-- Report Header -->
        <div class="report-header">
            <div class="d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h1><i class="fas fa-chart-bar me-2" style="color: #a855f7;"></i>System Reports</h1>
                    <p class="mb-0 opacity-75">Comprehensive analytics and statistics</p>
                    <small class="opacity-50"><i class="far fa-calendar-alt me-1"></i> <%= new java.util.Date() %></small>
                </div>
                <div class="mt-3 mt-md-0">
                    <button class="btn-print" onclick="window.print()"><i class="fas fa-print me-2"></i>Print</button>
                    <button class="btn-export" onclick="exportReport()"><i class="fas fa-download me-2"></i>Export CSV</button>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Total Courses</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= totalStudents %></div>
                <div class="stat-label">Total Students</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= totalRegistrations %></div>
                <div class="stat-label">Registrations</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= pendingQueue %></div>
                <div class="stat-label">Pending Queue</div>
            </div>
        </div>

        <!-- Charts Row 1 -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-chart-pie me-2" style="color: #a855f7;"></i> Students by Department</h5>
                    <div class="chart-container">
                        <canvas id="deptChart"></canvas>
                    </div>
                    <div class="mt-3">
                        <% for (Map.Entry<String, Integer> e : deptCount.entrySet()) {
                            double p = totalStudents > 0 ? (e.getValue() * 100.0 / totalStudents) : 0;
                        %>
                        <div class="d-flex justify-content-between mb-1">
                            <span><%= e.getKey() %></span>
                            <span><%= e.getValue() %></span>
                            <span><%= String.format("%.1f", p) %>%</span>
                        </div>
                        <div class="progress-custom mb-2">
                            <div class="progress-fill" style="width: <%= p %>%; background: #a855f7;"></div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-chart-bar me-2" style="color: #f59e0b;"></i> Students by Semester</h5>
                    <div class="chart-container">
                        <canvas id="semesterChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row 2 -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-tachometer-alt me-2" style="color: #10b981;"></i> Seat Utilization</h5>
                    <div class="chart-container">
                        <canvas id="seatChart"></canvas>
                    </div>
                    <div class="text-center mt-3">
                        <span class="badge-util <%= utilization > 70 ? "bg-danger" : (utilization > 40 ? "bg-warning" : "bg-success") %> px-3 py-2"
                              style="<%= utilization > 70 ? "background: rgba(239,68,68,0.2); color:#fca5a5;" : (utilization > 40 ? "background: rgba(245,158,11,0.2); color:#fcd34d;" : "background: rgba(16,185,129,0.2); color:#6ee7b7;") %>">
                            <%= String.format("%.1f", utilization) %>% Utilization
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="content-card">
                    <h5><i class="fas fa-table me-2" style="color: #06b6d4;"></i> Course Details</h5>
                    <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Course</th>
                                    <th>Seats</th>
                                    <th>Enrolled</th>
                                    <th>Available</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Course c : allCourses) {
                                    int enrolled = 0;
                                    for (Registration r : allRegistrations) {
                                        if (r.getCourseId().equals(c.getCourseId()) && "approved".equals(r.getStatus())) {
                                            enrolled++;
                                        }
                                    }
                                %>
                                <tr>
                                    <td><%= c.getCourseName() %></td>
                                    <td><%= c.getTotalSeats() %></td>
                                    <td><%= enrolled %></td>
                                    <td><%= c.getAvailableSeats() %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
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
            <div class="col-md-4 mb-3">
                <div class="footer-brand">Course<span>Reg</span></div>
                <p class="text-white-50 small">Smart course registration system.</p>
            </div>
            <div class="col-md-2 col-6 mb-3 footer-links">
                <h6 class="text-white mb-2">Quick Links</h6>
                <a href="admin">Dashboard</a>
                <a href="courses">Courses</a>
                <a href="admin?action=queue">Queue</a>
            </div>
            <div class="col-md-2 col-6 mb-3 footer-links">
                <h6 class="text-white mb-2">Management</h6>
                <a href="manage-students.jsp">Students</a>
                <a href="reports.jsp">Reports</a>
            </div>
            <div class="col-md-4 mb-3 footer-links">
                <h6 class="text-white mb-2">Connect</h6>
                <div class="d-flex gap-3">
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-linkedin"></i></a>
                    <a href="#"><i class="fab fa-github"></i></a>
                </div>
            </div>
        </div>
        <div class="copyright">
            <p>&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Department Pie Chart
    new Chart(document.getElementById('deptChart'), {
        type: 'pie',
        data: {
            labels: [<% for (String d : deptCount.keySet()) { %>'<%= d %>',<% } %>],
            datasets: [{
                data: [<% for (int c : deptCount.values()) { %><%= c %>,<% } %>],
                backgroundColor: ['#a855f7', '#10b981', '#f59e0b', '#06b6d4', '#ef4444'],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: 'rgba(255,255,255,0.8)' }
                }
            }
        }
    });

    // Semester Bar Chart
    new Chart(document.getElementById('semesterChart'), {
        type: 'bar',
        data: {
            labels: ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'],
            datasets: [{
                label: 'Students',
                data: [
                    <%= semesterCount.getOrDefault(1, 0) %>,
                    <%= semesterCount.getOrDefault(2, 0) %>,
                    <%= semesterCount.getOrDefault(3, 0) %>,
                    <%= semesterCount.getOrDefault(4, 0) %>,
                    <%= semesterCount.getOrDefault(5, 0) %>,
                    <%= semesterCount.getOrDefault(6, 0) %>,
                    <%= semesterCount.getOrDefault(7, 0) %>,
                    <%= semesterCount.getOrDefault(8, 0) %>
                ],
                backgroundColor: '#a855f7',
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    labels: { color: 'rgba(255,255,255,0.8)' }
                }
            }
        }
    });

    // Seat Utilization Doughnut Chart
    new Chart(document.getElementById('seatChart'), {
        type: 'doughnut',
        data: {
            labels: ['Occupied', 'Available'],
            datasets: [{
                data: [<%= occupiedSeats %>, <%= totalSeats - occupiedSeats %>],
                backgroundColor: ['#a855f7', 'rgba(255,255,255,0.1)'],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: 'rgba(255,255,255,0.8)' }
                }
            }
        }
    });

    // Export CSV
    function exportReport() {
        let csv = "CourseReg Report\nGenerated,<%= new java.util.Date() %>\n\n";
        csv += "Total Courses,<%= totalCourses %>\n";
        csv += "Total Students,<%= totalStudents %>\n";
        csv += "Total Registrations,<%= totalRegistrations %>\n";
        csv += "Pending Queue,<%= pendingQueue %>\n\n";
        csv += "Department,Students,Percentage\n";

        <% for (Map.Entry<String, Integer> e : deptCount.entrySet()) {
            double p = totalStudents > 0 ? (e.getValue() * 100.0 / totalStudents) : 0;
        %>
        csv += "<%= e.getKey() %>,<%= e.getValue() %>,<%= String.format("%.1f", p) %>%\n";
        <% } %>

        const blob = new Blob([csv], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'coursereg_report_<%= new Date().getTime() %>.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }
</script>

</body>
</html>
