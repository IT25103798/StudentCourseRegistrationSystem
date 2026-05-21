<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.model.LecturerUser" %>
<%@ page import="com.registration.model.Lecturer" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (!"lecturer".equals(role) || username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Lecturer lecturer = (Lecturer) request.getAttribute("lecturer");
    List<Course> myCourses = (List<Course>) request.getAttribute("myCourses");
    List<Course> allCourses = (List<Course>) request.getAttribute("allCourses");
    List<Map<String, String>> enrolledStudents = (List<Map<String, String>>) request.getAttribute("enrolledStudents");
    Course selectedCourse = (Course) request.getAttribute("selectedCourse");

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    String lecturerName = (lecturer != null) ? lecturer.getName() : username;
    String lecturerDept = (lecturer != null) ? lecturer.getDepartment() : "N/A";
    String lecturerEmail = (lecturer != null) ? lecturer.getEmail() : "N/A";

    java.util.Map<String, Integer> enrolledCounts = (java.util.Map<String, Integer>) request.getAttribute("enrolledCounts");
    int totalEnrolled = 0;
    int totalSeatsLeft = 0;
    if (enrolledCounts != null) {
        for (int cnt : enrolledCounts.values()) totalEnrolled += cnt;
    }
    if (myCourses != null && enrolledCounts != null) {
        for (Course c : myCourses) {
            int ec = enrolledCounts.getOrDefault(c.getCourseId(), 0);
            totalSeatsLeft += (c.getTotalSeats() - ec);
        }
    }
    int totalCourses = (myCourses != null) ? myCourses.size() : 0;
    int totalSeats = 0;
    if (myCourses != null) {
        for (Course c : myCourses) totalSeats += c.getTotalSeats();
    }
    int fillRate = (totalSeats > 0) ? (int)((double)totalEnrolled / totalSeats * 100) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lecturer Dashboard | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: #0f0c29;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        .blob {
            position: fixed;
            width: 500px;
            height: 500px;
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.3;
            animation: float 10s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }
        .blob-1 { top: 10%; left: -10%; }
        .blob-2 { bottom: 0; right: -10%; width: 600px; height: 600px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -3s; }
        .blob-3 { top: 40%; left: 30%; width: 350px; height: 350px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -6s; opacity: 0.2; }
        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(40px, -40px) rotate(5deg); }
        }

        .navbar {
            background: rgba(15, 12, 41, 0.75);
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
            margin: 0 0.2rem;
            padding: 8px 18px !important;
            border-radius: 40px;
            transition: all 0.3s;
        }
        .nav-link:hover { background: rgba(255, 255, 255, 0.1); color: white !important; }
        .nav-link.active { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white !important; box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }

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
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
        }
        .btn-logout:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3); }

        .dashboard-container { padding: 100px 0 50px; position: relative; z-index: 1; }
        .welcome-header { margin-bottom: 35px; }
        .welcome-header h1 { font-size: 2rem; font-weight: 700; }
        .lecturer-badge { background: linear-gradient(135deg, #a855f7, #7c3aed); padding: 8px 20px; border-radius: 40px; font-weight: 600; font-size: 0.85rem; }

        .stats-row { display: flex; gap: 20px; margin-bottom: 35px; flex-wrap: wrap; }
        .stat-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(12px);
            border-radius: 24px;
            padding: 20px 24px;
            flex: 1;
            min-width: 180px;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
            cursor: pointer;
        }
        .stat-card:hover { transform: translateY(-4px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.4); }
        .stat-number { font-size: 2.2rem; font-weight: 800; color: #a855f7; line-height: 1; }
        .stat-label { color: rgba(255, 255, 255, 0.7); font-size: 0.8rem; font-weight: 500; margin-top: 6px; text-transform: uppercase; letter-spacing: 0.03em; }
        .stat-icon { width: 48px; height: 48px; background: rgba(168, 85, 247, 0.2); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; color: #a855f7; }
        .fill-bar-wrap { margin-top: 12px; }
        .fill-bar-track { height: 5px; background: rgba(255,255,255,0.1); border-radius: 4px; overflow: hidden; }
        .fill-bar-fill { height: 100%; border-radius: 4px; transition: width 0.8s ease; }

        .quick-actions-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(12px);
            border-radius: 24px;
            padding: 24px 28px;
            margin-bottom: 35px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .quick-action-btn {
            padding: 12px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            display: inline-block;
            width: 100%;
            text-align: center;
            text-decoration: none;
            border: none;
        }
        .quick-action-btn:hover { transform: translateY(-2px); filter: brightness(1.05); }

        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(12px);
            border-radius: 24px;
            padding: 24px 28px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .content-card h5 { font-weight: 700; margin-bottom: 20px; }

        .custom-table { width: 100%; border-collapse: collapse; }
        .custom-table thead th {
            background: rgba(255, 255, 255, 0.08);
            padding: 12px 16px;
            font-weight: 600;
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: rgba(255, 255, 255, 0.9);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            text-align: left;
        }
        .custom-table tbody td {
            padding: 12px 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.85);
            vertical-align: middle;
        }
        .custom-table tbody tr:hover { background: rgba(255, 255, 255, 0.03); }

        .badge-enrolled { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 4px 12px; border-radius: 40px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-seats { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 10px; border-radius: 40px; font-size: 0.7rem; font-weight: 600; }
        .badge-full { background: rgba(239, 68, 68, 0.2); color: #fca5a5; }

        .btn-sm-glass {
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
            color: white;
            border-radius: 30px;
            padding: 5px 14px;
            font-size: 0.75rem;
            font-weight: 500;
            transition: 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-sm-glass:hover { background: rgba(168, 85, 247, 0.3); color: white; border-color: #a855f7; }
        .btn-danger-glass { background: rgba(239,68,68,0.15); border-color: rgba(239,68,68,0.3); }
        .btn-danger-glass:hover { background: rgba(239,68,68,0.4); border-color: #ef4444; }

        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: rgba(255,255,255,0.5); }
        .search-input {
            width: 100%;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255,255,255,0.1);
            color: white;
            border-radius: 40px;
            padding: 10px 16px 10px 42px;
            font-size: 0.85rem;
        }
        .search-input:focus { outline: none; border-color: #a855f7; background: rgba(168,85,247,0.1); }

        .modal-content {
            background: #1e1b3c;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 24px;
            color: white;
        }
        .form-control, .form-select {
            background: rgba(0,0,0,0.3);
            border: 1px solid rgba(255,255,255,0.15);
            color: white;
            border-radius: 14px;
            padding: 10px 16px;
        }
        .form-control:focus, .form-select:focus {
            background: rgba(0,0,0,0.5);
            border-color: #a855f7;
            box-shadow: 0 0 0 3px rgba(168,85,247,0.2);
            color: white;
        }

        footer { background: rgba(0, 0, 0, 0.4); padding: 50px 0 25px; border-top: 1px solid rgba(255, 255, 255, 0.1); margin-top: 40px; }
        .footer-brand { font-size: 1.4rem; font-weight: 800; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; display: inline-block; margin-bottom: 15px; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 5px 0; font-size: 0.85rem; }
        .footer-links a:hover { color: #a855f7; }
        .copyright { text-align: center; padding-top: 30px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.8rem; }

        @media (max-width: 768px) { .stats-row { flex-direction: column; } .blob { display: none; } }

        .alert-custom { background: rgba(0,0,0,0.6); backdrop-filter: blur(8px); border-radius: 16px; border-left: 4px solid; padding: 14px 20px; margin-bottom: 24px; }
        .alert-success { border-left-color: #10b981; color: #a7f3d0; }
        .alert-danger { border-left-color: #ef4444; color: #fecaca; }

        .progress { background: rgba(255,255,255,0.1); border-radius: 10px; overflow: hidden; }
        .progress-bar { transition: width 0.3s ease; }
    </style>
</head>
<body>

<div class="blob blob-1"></div>
<div class="blob blob-2"></div>
<div class="blob blob-3"></div>

<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="lecturer-dashboard">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#lecturerNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="lecturerNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link active" href="lecturer-dashboard">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="profile-settings.jsp">Profile</a></li>
                <li class="nav-item"><a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#addCourseModal"><i class="fas fa-plus-circle me-1"></i>Add Course</a></li>
                <li class="nav-item"><a class="btn-logout ms-2" href="logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="dashboard-container">
    <div class="container">

        <div class="welcome-header d-flex justify-content-between align-items-center flex-wrap">
            <div>
                <h1 class="fw-bold mb-1"><i class="fas fa-chalkboard-user me-3" style="color: #a855f7;"></i>Lecturer Command Center</h1>
                <p class="opacity-75">Manage your courses, track enrollments, and engage with students</p>
            </div>
            <div class="mt-2 mt-md-0">
                <span class="lecturer-badge"><i class="fas fa-user-graduate me-2"></i><%= lecturerName %></span>
                <span class="ms-2 badge bg-primary px-3 py-2 rounded-pill"><i class="fas fa-university me-1"></i> <%= lecturerDept %></span>
            </div>
        </div>

        <% if (successMsg != null) { %>
        <div class="alert-custom alert-success d-flex align-items-center gap-3"><i class="fas fa-check-circle fa-lg"></i><%= successMsg.replace("+", " ") %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert-custom alert-danger d-flex align-items-center gap-3"><i class="fas fa-exclamation-triangle fa-lg"></i><%= errorMsg.replace("+", " ") %></div>
        <% } %>

        <div class="stats-row">
            <div class="stat-card" onclick="document.getElementById('coursesSection').scrollIntoView({behavior:'smooth'})">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number"><%= totalCourses %></div><div class="stat-label">Active Courses</div></div>
                    <div class="stat-icon"><i class="fas fa-book-open"></i></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number" style="color:#c084fc;"><%= totalEnrolled %></div><div class="stat-label">Total Enrolled Students</div></div>
                    <div class="stat-icon" style="background:rgba(192,132,252,0.2); color:#c084fc;"><i class="fas fa-users"></i></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number" style="color:#34d399;"><%= totalSeatsLeft %></div><div class="stat-label">Seats Available</div></div>
                    <div class="stat-icon" style="background:rgba(52,211,153,0.2); color:#34d399;"><i class="fas fa-chair"></i></div>
                </div>
            </div>
            <div class="stat-card">
                <div class="d-flex justify-content-between align-items-start">
                    <div><div class="stat-number" style="color:#fbbf24;"><%= fillRate %>%</div><div class="stat-label">Fill Rate</div></div>
                    <div class="stat-icon" style="background:rgba(251,191,36,0.2); color:#fbbf24;"><i class="fas fa-chart-line"></i></div>
                </div>
                <div class="fill-bar-wrap">
                    <div class="fill-bar-track">
                        <div class="fill-bar-fill" style="width: <%= fillRate %>%; background: <%= (fillRate > 80) ? "#ef4444" : (fillRate > 50) ? "#fbbf24" : "#34d399" %>;"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="quick-actions-card">
            <h5><i class="fas fa-bolt me-2" style="color: #f59e0b;"></i> Quick Actions</h5>
            <div class="row g-3">
                <div class="col-md-3 col-sm-6">
                    <button class="quick-action-btn" style="background: #2563eb; color: white;" data-bs-toggle="modal" data-bs-target="#addCourseModal">
                        <i class="fas fa-plus me-2"></i> Create Course
                    </button>
                </div>
                <div class="col-md-3 col-sm-6">
                    <input type="text" id="globalCourseSearch" class="form-control" placeholder=" Filter my courses..." style="background:rgba(255,255,255,0.08); border-color:rgba(255,255,255,0.2); color:white;" onkeyup="filterCourseCards()">
                </div>
                <div class="col-md-3 col-sm-6">
                    <a href="#studentsSection" class="quick-action-btn" style="background: #10b981; color: white; text-decoration:none;" id="scrollToStudentsBtn">
                        <i class="fas fa-graduation-cap me-2"></i> View Enrolled
                    </a>
                </div>
                <div class="col-md-3 col-sm-6">
                    <span class="quick-action-btn" style="background: #1e293b; color: #94a3b8;"><i class="fas fa-envelope me-2"></i> <%= lecturerEmail %></span>
                </div>
            </div>
        </div>

        <div class="content-card" id="coursesSection">
            <h5><i class="fas fa-book me-2" style="color: #a855f7;"></i> My Courses <span class="badge bg-secondary ms-2"><%= totalCourses %></span></h5>
            <div class="table-responsive">
                <table class="custom-table" id="coursesTable">
                    <thead>
                        <tr><th>Course Name</th><th>ID</th><th>Schedule</th><th>Credits</th><th>Enrollment</th><th>Seats Left</th><th>Actions</th></tr>
                    </thead>
                    <tbody id="coursesTableBody">
                        <% if (myCourses == null || myCourses.isEmpty()) { %>
                        <tr><td colspan="7" class="text-center py-5 opacity-50">No courses added yet. Click "Create Course" to get started.</td></tr>
                        <% } else {
                            for (Course course : myCourses) {
                                int enrolled = (enrolledCounts != null) ? enrolledCounts.getOrDefault(course.getCourseId(), 0) : 0;
                                int left = course.getTotalSeats() - enrolled;
                                int pct = (course.getTotalSeats() > 0) ? (int)((double)enrolled / course.getTotalSeats() * 100) : 0;
                                String statusBadge = left <= 0 ? "badge-full" : "badge-seats";
                                String statusText = left <= 0 ? "Full" : left + " left";
                        %>
                        <tr class="course-row" data-coursename="<%= course.getCourseName().toLowerCase() %>">
                            <td><strong><%= course.getCourseName() %></strong></td>
                            <td><span class="badge-enrolled">#<%= course.getCourseId() %></span></td>
                            <td><i class="far fa-clock me-1"></i><%= course.getSchedule() %></td>
                            <td><%= course.getCredits() %> cr</td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <span><%= enrolled %>/<%= course.getTotalSeats() %></span>
                                    <div class="progress w-50" style="height: 6px;"><div class="progress-bar" style="width: <%= pct %>%; background: <%= left <= 0 ? "#ef4444" : "#a855f7" %>;"></div></div>
                                </div>
                             </td>
                            <td><span class="<%= statusBadge %>"><%= statusText %></span></td>
                            <td>
                                <a href="lecturer-dashboard?action=viewStudents&courseId=<%= course.getCourseId() %>" class="btn-sm-glass me-1"><i class="fas fa-users"></i> Students</a>
                                <button class="btn-sm-glass" onclick="openEditModal('<%= course.getCourseId() %>','<%= course.getCourseName().replace("'", "\\'") %>','<%= course.getTotalSeats() %>','<%= course.getCredits() %>','<%= course.getSchedule().replace("'", "\\'") %>')"><i class="fas fa-edit"></i></button>
                                <form action="lecturer-dashboard" method="post" style="display:inline;" onsubmit="return confirm('Permanently delete <%= course.getCourseName() %>?')">
                                    <input type="hidden" name="action" value="deleteCourse">
                                    <input type="hidden" name="courseId" value="<%= course.getCourseId() %>">
                                    <button type="submit" class="btn-sm-glass btn-danger-glass"><i class="fas fa-trash"></i></button>
                                </form>
                             </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>

        <% if (selectedCourse != null) { %>
        <div class="content-card" id="studentsSection">
            <h5><i class="fas fa-users me-2" style="color: #c084fc;"></i> Enrolled Students · <%= selectedCourse.getCourseName() %></h5>
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div class="search-wrap" style="width: 280px;"><i class="fas fa-search"></i><input type="text" id="studentSearchInput" class="search-input" placeholder="Search by name or ID..."></div>
                <a href="lecturer-dashboard" class="btn-sm-glass"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            </div>
            <div class="table-responsive">
                <table class="custom-table" id="studentsDetailTable">
                    <thead>
                        <tr><th>#</th><th>Student ID</th><th>Name</th><th>Email</th><th>Department</th><th>Semester</th><th>Enrolled On</th></tr>
                    </thead>
                    <tbody id="studentRows">
                        <% if (enrolledStudents != null && !enrolledStudents.isEmpty()) {
                            int idx = 1;
                            for (Map<String, String> s : enrolledStudents) { %>
                            <tr class="student-record" data-studentinfo="<%= s.get("name").toLowerCase() %> <%= s.get("studentId").toLowerCase() %>">
                                <td><%= idx++ %></td>
                                <td><span class="badge-enrolled"><%= s.get("studentId") %></span></td>
                                <td><i class="fas fa-user-circle me-1"></i> <%= s.get("name") %></td>
                                <td><%= s.get("email") %></td>
                                <td><%= s.get("department") %></td>
                                <td>Sem <%= s.get("semester") %></td>
                                <td><small><%= s.get("registrationDate") %></small></td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="7" class="text-center py-4 opacity-50">No students enrolled yet.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>

        <div class="row mt-3">
            <div class="col-12">
                <div class="p-4 rounded-4" style="background: linear-gradient(135deg, rgba(168,85,247,0.2), rgba(59,130,246,0.1)); border: 1px solid rgba(255,255,255,0.1);">
                    <div class="row align-items-center">
                        <div class="col-md-8"><h6 class="mb-2"><i class="fas fa-microchip me-2"></i> Academic Console</h6><p class="small opacity-75 mb-0">FIFO queue management | Real-time seat tracking | File-backed persistence. Manage courses and monitor student registrations.</p></div>
                        <div class="col-md-4 text-md-end mt-2 mt-md-0"><i class="fas fa-chalkboard fa-2x opacity-25 me-2"></i><i class="fas fa-database fa-2x opacity-25"></i></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3"><div class="footer-brand">Course<span>Reg</span></div><p class="text-white-50 small">Empowering education through intelligent registration.</p></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Quick</h6><a href="lecturer-dashboard">Dashboard</a><a href="profile-settings.jsp">Profile</a></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Courses</h6><a href="#" data-bs-toggle="modal" data-bs-target="#addCourseModal">Add Course</a><a href="#">My Teaching</a></div>
            <div class="col-md-4 mb-3 footer-links"><h6 class="text-white mb-2">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-linkedin"></i></a><a href="#"><i class="fab fa-github"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2025 CourseReg | FIFO Queue | Insertion Sort Optimization | Next-Gen Academic Suite</p></div>
    </div>
</footer>

<div class="modal fade" id="addCourseModal" tabindex="-1">
    <div class="modal-dialog modal-lg"><div class="modal-content">
        <div class="modal-header"><h5 class="modal-title"><i class="fas fa-plus-circle me-2" style="color:#a855f7;"></i>Launch New Course</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
        <form action="lecturer-dashboard" method="post"><input type="hidden" name="action" value="addCourse">
            <div class="modal-body p-4"><div class="row g-3">
                <div class="col-12"><label class="form-label">Course Name</label><input type="text" name="courseName" class="form-control" required></div>
                <div class="col-md-6"><label class="form-label">Total Seats</label><input type="number" name="totalSeats" class="form-control" min="1" max="200" required></div>
                <div class="col-md-6"><label class="form-label">Credits</label><select name="credits" class="form-select" required><option value="1">1 Credit</option><option value="2">2 Credits</option><option value="3" selected>3 Credits</option><option value="4">4 Credits</option></select></div>
                <div class="col-12"><label class="form-label">Schedule</label><input type="text" name="schedule" class="form-control" placeholder="e.g., Mon/Wed 2PM-4PM" required></div>
                <div class="col-12"><div class="alert alert-dark bg-dark-50 text-white-50"><small><i class="fas fa-info-circle"></i> Department: <strong><%= lecturerDept %></strong> · Instructor: <strong><%= lecturerName %></strong></small></div></div>
            </div></div>
            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn" style="background:#a855f7; color:white;">Create Course</button></div>
        </form>
    </div></div>
</div>

<div class="modal fade" id="editCourseModal" tabindex="-1">
    <div class="modal-dialog modal-lg"><div class="modal-content">
        <div class="modal-header"><h5 class="modal-title"><i class="fas fa-edit me-2"></i>Refine Course</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
        <form action="lecturer-dashboard" method="post"><input type="hidden" name="action" value="editCourse"><input type="hidden" name="courseId" id="editCourseId">
            <div class="modal-body p-4"><div class="row g-3">
                <div class="col-12"><label class="form-label">Course Name</label><input type="text" name="courseName" id="editCourseName" class="form-control" required></div>
                <div class="col-md-6"><label class="form-label">Total Seats</label><input type="number" name="totalSeats" id="editTotalSeats" class="form-control" required></div>
                <div class="col-md-6"><label class="form-label">Credits</label><select name="credits" id="editCredits" class="form-select"><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option></select></div>
                <div class="col-12"><label class="form-label">Schedule</label><input type="text" name="schedule" id="editSchedule" class="form-control" required></div>
            </div></div>
            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn" style="background:#f59e0b; color:white;">Save Changes</button></div>
        </form>
    </div></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEditModal(id, name, seats, credits, schedule) {
    document.getElementById('editCourseId').value = id;
    document.getElementById('editCourseName').value = name;
    document.getElementById('editTotalSeats').value = seats;
    document.getElementById('editSchedule').value = schedule;
    let sel = document.getElementById('editCredits');
    for(let i=0;i<sel.options.length;i++) if(sel.options[i].value == credits) { sel.selectedIndex = i; break; }
    new bootstrap.Modal(document.getElementById('editCourseModal')).show();
}

function filterCourseCards() {
    let filter = document.getElementById('globalCourseSearch').value.toLowerCase();
    let rows = document.querySelectorAll('#coursesTableBody tr');
    rows.forEach(row => {
        let name = row.getAttribute('data-coursename') || '';
        row.style.display = name.includes(filter) ? '' : 'none';
    });
}

if(document.getElementById('studentSearchInput')) {
    document.getElementById('studentSearchInput').addEventListener('keyup', function() {
        let val = this.value.toLowerCase();
        document.querySelectorAll('#studentRows .student-record').forEach(row => {
            let info = row.getAttribute('data-studentinfo') || '';
            row.style.display = info.includes(val) ? '' : 'none';
        });
    });
}

setTimeout(() => {
    document.querySelectorAll('.alert-custom').forEach(el => {
        el.style.transition = 'opacity 0.5s';
        el.style.opacity = '0';
        setTimeout(() => el.remove(), 500);
    });
}, 4000);
</script>
</body>
</html>
