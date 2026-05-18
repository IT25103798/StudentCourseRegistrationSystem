<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.LecturerDAO" %>
<%@ page import="com.registration.dao.UserDAO" %>
<%@ page import="com.registration.model.Lecturer" %>
<%@ page import="com.registration.model.LecturerUser" %>
<%@ page import="com.registration.util.FileHandler" %>
<%@ page import="com.registration.model.User" %>
<%@ page import="java.util.*" %>
<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    LecturerDAO lecturerDAO = new LecturerDAO();
    UserDAO userDAO = new UserDAO();
    List<User> allUsers = userDAO.getAllUsers();
    // Build map: lecturerId -> username
    Map<String, String> lecturerLoginMap = new HashMap<>();
    List<String> userLines = com.registration.util.FileHandler.readAllLines("users.txt");
    for (String ul : userLines) {
        String[] up = ul.split("\\|");
        if (up.length >= 6 && "lecturer".equals(up[4])) {
            lecturerLoginMap.put(up[5], up[1]); // lecturerId -> username
        }
    }
    List<Lecturer> lecturers = (List<Lecturer>) request.getAttribute("lecturers");
    Integer totalLecturers = (Integer) request.getAttribute("totalLecturers");
    Integer activeLecturers = (Integer) request.getAttribute("activeLecturers");
    Map<String, Integer> deptStats = (Map<String, Integer>) request.getAttribute("deptStats");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");

    if (lecturers == null) lecturers = lecturerDAO.getAllLecturers();
    if (totalLecturers == null) totalLecturers = lecturerDAO.getTotalLecturers();
    if (activeLecturers == null) activeLecturers = lecturerDAO.getActiveLecturers();
    if (deptStats == null) deptStats = lecturerDAO.getLecturersByDepartmentStats();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Lecturers | CourseReg</title>
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
        .lecturers-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Page Header */
        .page-header { margin-bottom: 25px; }
        .page-header h1 { font-size: 1.8rem; font-weight: 700; color: white; }
        .page-header p { color: rgba(255, 255, 255, 0.7); margin-top: 5px; }

        /* Stats Cards */
        .stats-row { display: flex; gap: 20px; margin-bottom: 30px; flex-wrap: wrap; }
        .stat-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px; flex: 1; min-width: 150px; text-align: center; border: 1px solid rgba(255, 255, 255, 0.1); transition: all 0.3s; }
        .stat-card:hover { transform: translateY(-3px); background: rgba(255, 255, 255, 0.08); border-color: rgba(168, 85, 247, 0.3); }
        .stat-number { font-size: 2rem; font-weight: 800; color: #a855f7; }
        .stat-label { color: rgba(255, 255, 255, 0.7); font-size: 0.75rem; margin-top: 5px; }

        /* Content Card */
        .content-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px 24px; margin-bottom: 25px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); display: flex; align-items: center; gap: 8px; color: white; }
        .card-title i { color: #a855f7; }

        /* Form Elements */
        .form-label { font-weight: 600; font-size: 0.75rem; margin-bottom: 6px; color: rgba(255, 255, 255, 0.8); }
        .form-control, .form-select { background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 12px; padding: 8px 12px; font-size: 0.85rem; color: white; }
        .form-control:focus, .form-select:focus { border-color: #a855f7; outline: none; box-shadow: 0 0 0 2px rgba(168, 85, 247, 0.2); }
        .form-control::placeholder { color: rgba(255, 255, 255, 0.4); }
        .form-select option { background: #1e1b4b; }

        /* Buttons */
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 8px 20px; border-radius: 40px; color: white; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-secondary-custom { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); padding: 8px 20px; border-radius: 40px; color: white; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-secondary-custom:hover { background: rgba(255, 255, 255, 0.2); }

        /* Table */
        .lecturers-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        .lecturers-table th { background: rgba(255, 255, 255, 0.08); padding: 10px; font-weight: 600; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        .lecturers-table td { padding: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); vertical-align: middle; color: rgba(255, 255, 255, 0.8); }
        .lecturers-table tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-active { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 4px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .badge-inactive { background: rgba(239, 68, 68, 0.2); color: #fca5a5; padding: 4px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .badge-dept { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 3px 8px; border-radius: 30px; font-size: 0.65rem; font-weight: 500; }

        /* Action Buttons */
        .btn-action { padding: 4px 10px; border-radius: 6px; font-size: 0.7rem; margin: 0 2px; border: none; cursor: pointer; }
        .btn-edit { background: #f59e0b; color: white; }
        .btn-edit:hover { background: #d97706; }
        .btn-delete { background: #ef4444; color: white; }
        .btn-delete:hover { background: #dc2626; }

        /* Modal */
        .modal-custom .modal-content { background: rgba(15, 12, 41, 0.95); backdrop-filter: blur(20px); border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .modal-custom .modal-header { background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 20px 20px 0 0; padding: 15px 20px; border: none; }
        .modal-custom .modal-header .btn-close { filter: brightness(0) invert(1); }
        .modal-custom .modal-footer .btn-secondary { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; }

        /* Alerts */
        .alert-success { background: rgba(16, 185, 129, 0.15); border-left: 4px solid #10b981; color: #6ee7b7; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-danger { background: rgba(239, 68, 68, 0.15); border-left: 4px solid #ef4444; color: #fca5a5; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }

        /* Empty State */
        .empty-state { text-align: center; padding: 50px; color: rgba(255, 255, 255, 0.6); }
        .empty-state i { font-size: 3rem; color: rgba(255, 255, 255, 0.3); margin-bottom: 15px; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 40px 0 20px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.1); }
        .footer-brand { font-size: 1.3rem; font-weight: 800; margin-bottom: 12px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 4px 0; font-size: 0.8rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; }
        .copyright { text-align: center; padding-top: 25px; margin-top: 25px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.75rem; }

        @media (max-width: 768px) { .lecturers-container { padding: 120px 0 40px; } .stats-row { flex-direction: column; } .blob { display: none; } }
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
                <li class="nav-item"><a class="nav-link active" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="lecturers-container">
    <div class="container">

        <!-- Page Header -->
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-chalkboard-user me-2" style="color: #a855f7;"></i>Manage Lecturers</h1>
                <p>Add, edit, and manage all lecturer information</p>
            </div>
            <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addLecturerModal">
                <i class="fas fa-user-plus me-2"></i>Add New Lecturer
            </button>
        </div>

        <!-- Alerts -->
        <% if(successMsg != null) { %>
            <div class="alert-success"><i class="fas fa-check-circle me-2"></i> <%= successMsg %></div>
        <% } %>
        <% if(errorMsg != null) { %>
            <div class="alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= errorMsg %></div>
        <% } %>

        <!-- Statistics Cards -->
        <div class="stats-row">
            <div class="stat-card"><div class="stat-number"><%= totalLecturers %></div><div class="stat-label">Total Lecturers</div></div>
            <div class="stat-card"><div class="stat-number"><%= activeLecturers %></div><div class="stat-label">Active Lecturers</div></div>
            <div class="stat-card"><div class="stat-number"><%= deptStats.size() %></div><div class="stat-label">Departments</div></div>
            <div class="stat-card"><div class="stat-number">
                <% int totalCourses = 0;
                   for(com.registration.model.Course c : new com.registration.dao.CourseDAO().getAllCourses()) totalCourses++; %>
                <%= totalCourses %>
            </div><div class="stat-label">Courses</div></div>
        </div>

        <!-- Department Stats -->
        <div class="content-card">
            <div class="card-title"><i class="fas fa-chart-pie"></i> Lecturers by Department</div>
            <div class="row">
                <% for(Map.Entry<String, Integer> entry : deptStats.entrySet()) { %>
                <div class="col-md-3 col-sm-6 mb-3">
                    <div class="d-flex justify-content-between align-items-center p-2" style="background: rgba(255,255,255,0.05); border-radius: 12px;">
                        <span><%= entry.getKey() %></span>
                        <span class="badge bg-primary" style="background: rgba(168,85,247,0.3) !important; color: #d8b4fe;"><%= entry.getValue() %> lecturers</span>
                    </div>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Search & Filter -->
        <div class="content-card">
            <div class="card-title"><i class="fas fa-search"></i> Search Lecturers</div>
            <form method="get" action="manage-lecturers" class="row g-3">
                <div class="col-md-8">
                    <input type="text" name="search" class="form-control" placeholder="Search by name, email, department or specialization..." value="<%= searchKeyword != null ? searchKeyword : "" %>">
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-primary-custom w-100"><i class="fas fa-search me-2"></i>Search</button>
                </div>
            </form>
        </div>

        <!-- Lecturers Table -->
        <div class="content-card">
            <div class="card-title"><i class="fas fa-table-list"></i> Lecturer Directory <span class="badge bg-primary ms-2" style="background: rgba(168,85,247,0.3) !important; color: #d8b4fe;"><%= lecturers.size() %> lecturers</span></div>
            <div class="table-responsive">
                <table class="lecturers-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Department</th>
                            <th>Specialization</th>
                            <th>Qualification</th>
                            <th>Login Account</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(lecturers.isEmpty()) { %>
                            <tr><td colspan="10" class="empty-state">
                                <i class="fas fa-user-graduate"></i>
                                <h6>No lecturers found</h6>
                                <button class="btn btn-primary-custom mt-2" data-bs-toggle="modal" data-bs-target="#addLecturerModal">Add Your First Lecturer</button>
                            </td></tr>
                        <% } else {
                            for(Lecturer lecturer : lecturers) { %>
                                <tr>
                                    <td><span class="badge-dept"><%= lecturer.getLecturerId() %></span></td>
                                    <td><strong><%= lecturer.getName() %></strong></td>
                                    <td><%= lecturer.getEmail() %></td>
                                    <td><%= lecturer.getPhone() %></td>
                                    <td><span class="badge-dept"><%= lecturer.getDepartment() %></span></td>
                                    <td><%= lecturer.getSpecialization() %></td>
                                    <td><%= lecturer.getQualification().length() > 20 ? lecturer.getQualification().substring(0,20)+"..." : lecturer.getQualification() %></td>
                                    <td>
                                        <% String loginUsername = lecturerLoginMap.get(lecturer.getLecturerId()); %>
                                        <% if (loginUsername != null) { %>
                                            <span style="background:rgba(16,185,129,0.15);color:#6ee7b7;padding:3px 9px;border-radius:20px;font-size:0.7rem;font-weight:600;"><i class="fas fa-user-check me-1"></i><%= loginUsername %></span>
                                        <% } else { %>
                                            <span style="background:rgba(239,68,68,0.15);color:#fca5a5;padding:3px 9px;border-radius:20px;font-size:0.7rem;font-weight:600;"><i class="fas fa-user-times me-1"></i>No Account</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if("active".equals(lecturer.getStatus())) { %>
                                            <span class="badge-active"><i class="fas fa-check-circle me-1"></i> Active</span>
                                        <% } else { %>
                                            <span class="badge-inactive"><i class="fas fa-ban me-1"></i> Inactive</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <button class="btn-action btn-edit" onclick='editLecturer("<%= lecturer.getLecturerId() %>","<%= lecturer.getName() %>","<%= lecturer.getEmail() %>","<%= lecturer.getPhone() %>","<%= lecturer.getDepartment() %>","<%= lecturer.getSpecialization() %>","<%= lecturer.getQualification() %>","<%= lecturer.getJoiningDate() %>","<%= lecturer.getStatus() %>")'>
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn-action btn-delete" onclick="confirmDelete('<%= lecturer.getLecturerId() %>','<%= lecturer.getName() %>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Lecturer Modal -->
<div class="modal fade modal-custom" id="addLecturerModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>Add New Lecturer</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="manage-lecturers" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-body p-4">
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Full Name</label><input type="text" name="name" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Email</label><input type="email" name="email" class="form-control" required></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Phone</label><input type="text" name="phone" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Department</label>
                            <select name="department" class="form-select" required>
                                <option>Computer Science</option><option>Information Technology</option>
                                <option>Software Engineering</option><option>Data Science</option>
                                <option>Cyber Security</option><option>General</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Specialization</label><input type="text" name="specialization" class="form-control" placeholder="e.g., Data Structures, AI, Networks" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Qualification</label><input type="text" name="qualification" class="form-control" placeholder="e.g., Ph.D, M.Sc" required></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Joining Date</label><input type="date" name="joiningDate" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Status</label>
                            <select name="status" class="form-select" required>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <!-- Login Credentials Section -->
                    <hr style="border-color: rgba(168,85,247,0.3); margin: 10px 0 18px;">
                    <div class="mb-2" style="font-size:0.8rem; font-weight:700; color:#a855f7;"><i class="fas fa-key me-1"></i> Login Credentials</div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Username</label><input type="text" name="username" class="form-control" placeholder="e.g., prof.sarah" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Password</label><input type="password" name="password" class="form-control" placeholder="Set initial password" required></div>
                    </div>
                    <div class="row">
                        <div class="col-12">
                            <div style="background:rgba(168,85,247,0.1); border:1px solid rgba(168,85,247,0.25); border-radius:10px; padding:10px 14px; font-size:0.75rem; color:rgba(255,255,255,0.7);">
                                <i class="fas fa-info-circle me-1" style="color:#a855f7;"></i>
                                The lecturer will use these credentials to log in and manage their assigned courses.
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Add Lecturer</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Lecturer Modal -->
<div class="modal fade modal-custom" id="editLecturerModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Lecturer</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="manage-lecturers" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="lecturerId" id="editLecturerId">
                <div class="modal-body p-4">
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Full Name</label><input type="text" name="name" id="editName" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Email</label><input type="email" name="email" id="editEmail" class="form-control" required></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Phone</label><input type="text" name="phone" id="editPhone" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Department</label>
                            <select name="department" id="editDepartment" class="form-select" required>
                                <option>Computer Science</option><option>Information Technology</option>
                                <option>Software Engineering</option><option>Data Science</option>
                                <option>Cyber Security</option><option>General</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Specialization</label><input type="text" name="specialization" id="editSpecialization" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Qualification</label><input type="text" name="qualification" id="editQualification" class="form-control" required></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3"><label class="form-label">Joining Date</label><input type="date" name="joiningDate" id="editJoiningDate" class="form-control" required></div>
                        <div class="col-md-6 mb-3"><label class="form-label">Status</label>
                            <select name="status" id="editStatus" class="form-select" required>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Update Lecturer</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade modal-custom" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #ef4444, #dc2626);"><h5 class="modal-title"><i class="fas fa-trash me-2"></i>Delete Lecturer</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <div class="modal-body p-4">
                <p>Are you sure you want to delete this lecturer?</p>
                <p class="text-danger small">This action cannot be undone.</p>
                <input type="hidden" id="deleteId">
            </div>
            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="button" class="btn btn-danger" onclick="proceedDelete()">Delete</button></div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3"><div class="footer-brand">Course<span>Reg</span></div><p class="text-white-50 small">Smart course registration system.</p></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Quick Links</h6><a href="admin">Dashboard</a><a href="courses">Courses</a><a href="admin?action=queue">Queue</a></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Management</h6><a href="manage-students.jsp">Students</a><a href="manage-lecturers">Lecturers</a><a href="reports.jsp">Reports</a></div>
            <div class="col-md-4 mb-3 footer-links"><h6 class="text-white mb-2">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-linkedin"></i></a><a href="#"><i class="fab fa-github"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p></div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function editLecturer(id, name, email, phone, department, specialization, qualification, joiningDate, status) {
        document.getElementById('editLecturerId').value = id;
        document.getElementById('editName').value = name;
        document.getElementById('editEmail').value = email;
        document.getElementById('editPhone').value = phone;
        document.getElementById('editDepartment').value = department;
        document.getElementById('editSpecialization').value = specialization;
        document.getElementById('editQualification').value = qualification;
        document.getElementById('editJoiningDate').value = joiningDate;
        document.getElementById('editStatus').value = status;
        new bootstrap.Modal(document.getElementById('editLecturerModal')).show();
    }

    let deleteId = null;
    function confirmDelete(id, name) {
        deleteId = id;
        document.getElementById('deleteId').value = id;
        new bootstrap.Modal(document.getElementById('deleteModal')).show();
    }

    function proceedDelete() {
        window.location.href = 'manage-lecturers?action=delete&lecturerId=' + deleteId;
    }
</script>
</body>
</html>
