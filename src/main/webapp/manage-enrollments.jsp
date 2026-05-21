<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.UserDAO" %>
<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    RegistrationDAO registrationDAO = new RegistrationDAO();
    CourseDAO courseDAO = new CourseDAO();
    UserDAO userDAO = new UserDAO();

    List<Registration> allRegistrations = registrationDAO.getAllRegistrations();
    List<Course> allCourses = courseDAO.getAllCourses();
    List<Student> allStudents = userDAO.getAllStudents();

    // Build lookup maps
    Map<String, String> courseNameMap = new HashMap<>();
    for (Course c : allCourses) courseNameMap.put(c.getCourseId(), c.getCourseName());

    Map<String, String> studentNameMap = new HashMap<>();
    for (Student s : allStudents) studentNameMap.put(s.getId(), s.getUsername() + " (" + s.getStudentId() + ")");

    String successMsg = request.getParameter("success");
    String errorMsg   = request.getParameter("error");
    String filterStudent = request.getParameter("filterStudent");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Enrollments | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%); color: #fff; min-height: 100vh; overflow-x: hidden; }
        .blob { position: fixed; width: 400px; height: 400px; background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 50%; filter: blur(80px); opacity: 0.3; animation: float 6s ease-in-out infinite; pointer-events: none; z-index: 0; }
        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        @keyframes float { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 50% { transform: translate(30px, -30px) rotate(5deg); } }
        .navbar { background: rgba(255,255,255,0.05); backdrop-filter: blur(20px); padding: 0.8rem 0; border-bottom: 1px solid rgba(255,255,255,0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 1.6rem; font-weight: 800; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-link { color: rgba(255,255,255,0.8) !important; font-weight: 500; margin: 0 0.3rem; padding: 8px 18px !important; border-radius: 40px; transition: all 0.3s; }
        .nav-link:hover { background: rgba(255,255,255,0.1); color: white !important; }
        .nav-link.active { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white !important; }
        .btn-logout { background: linear-gradient(135deg, #ef4444, #dc2626); color: white; border: none; width: 38px; height: 38px; border-radius: 50%; font-size: 1rem; transition: all 0.3s; margin-left: 8px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .btn-logout:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3); }
        .page-container { padding: 100px 0 50px; position: relative; z-index: 1; }
        .page-header h1 { font-size: 1.8rem; font-weight: 700; }
        .page-header p { color: rgba(255,255,255,0.7); margin-top: 5px; }
        .card-section { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 24px; margin-bottom: 25px; border: 1px solid rgba(255,255,255,0.1); }
        .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 8px; }
        .card-title i { color: #a855f7; }
        .form-label { font-weight: 600; font-size: 0.75rem; color: rgba(255,255,255,0.8); margin-bottom: 5px; }
        .form-control, .form-select { background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.2); border-radius: 12px; padding: 8px 12px; font-size: 0.85rem; color: white; }
        .form-control:focus, .form-select:focus { border-color: #a855f7; outline: none; box-shadow: 0 0 0 2px rgba(168,85,247,0.2); }
        .form-select option { background: #1e1b4b; }
        .enroll-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
        .enroll-table th { background: rgba(255,255,255,0.08); padding: 10px 12px; font-weight: 600; color: rgba(255,255,255,0.9); border-bottom: 1px solid rgba(255,255,255,0.1); }
        .enroll-table td { padding: 10px 12px; border-bottom: 1px solid rgba(255,255,255,0.05); color: rgba(255,255,255,0.8); vertical-align: middle; }
        .enroll-table tr:hover { background: rgba(255,255,255,0.03); }
        .badge-approved { background: rgba(16,185,129,0.2); color: #6ee7b7; padding: 3px 10px; border-radius: 30px; font-size: 0.7rem; }
        .badge-pending { background: rgba(245,158,11,0.2); color: #fcd34d; padding: 3px 10px; border-radius: 30px; font-size: 0.7rem; }
        .btn-transfer-sm { background: #3b82f6; color: white; border: none; padding: 5px 12px; border-radius: 8px; font-size: 0.72rem; cursor: pointer; margin-right: 4px; }
        .btn-unenroll-sm { background: #ef4444; color: white; border: none; padding: 5px 12px; border-radius: 8px; font-size: 0.72rem; cursor: pointer; }
        .alert-success { background: rgba(16,185,129,0.15); border: 1px solid rgba(16,185,129,0.3); color: #6ee7b7; padding: 12px 18px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-error { background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3); color: #fca5a5; padding: 12px 18px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .search-input { background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.2); border-radius: 12px; padding: 8px 14px; font-size: 0.85rem; color: white; min-width: 250px; }
        .search-input::placeholder { color: rgba(255,255,255,0.4); }
        .modal-content { background: #1e1b4b; border: 1px solid rgba(255,255,255,0.15); border-radius: 20px; color: white; }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.1); }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-close { filter: invert(1); }
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 9px 22px; border-radius: 40px; color: white; font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .stats-pill { background: rgba(168,85,247,0.2); border: 1px solid rgba(168,85,247,0.3); color: #d8b4fe; padding: 6px 16px; border-radius: 30px; font-size: 0.8rem; font-weight: 500; display: inline-block; margin-right: 10px; }
    </style>
</head>
<body>
<div class="blob blob-1"></div>
<div class="blob blob-2"></div>

<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container">
        <a class="navbar-brand" href="admin">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" style="border-color:rgba(255,255,255,0.3)">
            <span class="navbar-toggler-icon" style="filter:invert(1)"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link" href="admin">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="courses">Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="admin?action=queue">Queue</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-students.jsp">Students</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-admins">Admins</a></li>
                <li class="nav-item"><a class="nav-link active" href="manage-enrollments">Enrollments</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="page-container">
    <div class="container">
        <div class="page-header mb-4">
            <h1><i class="fas fa-exchange-alt me-2" style="color:#a855f7"></i>Enrollment Management</h1>
            <p>Transfer students between courses or unenroll them</p>
        </div>

        <% if (successMsg != null) { %>
        <div class="alert-success"><i class="fas fa-check-circle me-2"></i><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert-error"><i class="fas fa-exclamation-triangle me-2"></i><%= errorMsg %></div>
        <% } %>

        <div class="mb-3">
            <span class="stats-pill"><i class="fas fa-list me-1"></i><%= allRegistrations.size() %> Total Enrollments</span>
        </div>

        <!-- Filter -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-filter"></i> Filter Enrollments</div>
            <div class="d-flex align-items-center gap-3 flex-wrap">
                <input type="text" class="search-input" id="searchInput" placeholder="Search by student name or course..." oninput="filterTable()">
            </div>
        </div>

        <!-- Enrollments Table -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-clipboard-list"></i> All Enrollments</div>
            <% if (allRegistrations.isEmpty()) { %>
            <p style="color:rgba(255,255,255,0.5); text-align:center; padding:30px;">No enrollments found.</p>
            <% } else { %>
            <div class="table-responsive">
                <table class="enroll-table" id="enrollTable">
                    <thead>
                        <tr>
                            <th>Registration ID</th>
                            <th>Student</th>
                            <th>Current Course</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Registration reg : allRegistrations) {
                        String sName = studentNameMap.getOrDefault(reg.getStudentId(), reg.getStudentId());
                        String cName = courseNameMap.getOrDefault(reg.getCourseId(), reg.getCourseId());
                    %>
                        <tr>
                            <td style="color:rgba(255,255,255,0.5); font-size:0.75rem;"><%= reg.getRegistrationId() %></td>
                            <td><strong><%= sName %></strong></td>
                            <td><%= cName %></td>
                            <td>
                                <% if ("approved".equals(reg.getStatus())) { %>
                                <span class="badge-approved">Approved</span>
                                <% } else { %>
                                <span class="badge-pending"><%= reg.getStatus() %></span>
                                <% } %>
                            </td>
                            <td style="font-size:0.75rem; color:rgba(255,255,255,0.6);">
                                <%= reg.getRegistrationDate() != null ? reg.getRegistrationDate().toString().substring(0,10) : "N/A" %>
                            </td>
                            <td>
                                <button class="btn-transfer-sm" onclick="openTransferModal('<%= reg.getRegistrationId() %>','<%= cName %>')">
                                    <i class="fas fa-exchange-alt me-1"></i>Transfer
                                </button>
                                <a class="btn-unenroll-sm" href="manage-enrollments?action=unenroll&registrationId=<%= reg.getRegistrationId() %>"
                                   onclick="return confirm('Unenroll this student from <%= cName %>?')">
                                    <i class="fas fa-user-minus me-1"></i>Unenroll
                                </a>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Transfer Modal -->
<div class="modal fade" id="transferModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-exchange-alt me-2"></i>Transfer Enrollment</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="manage-enrollments" method="post">
                <input type="hidden" name="action" value="transfer">
                <input type="hidden" name="registrationId" id="transferRegId">
                <div class="modal-body">
                    <p style="color:rgba(255,255,255,0.7); font-size:0.85rem; margin-bottom:16px;">
                        Current course: <strong id="currentCourseLabel" style="color:#a855f7;"></strong>
                    </p>
                    <div class="mb-3">
                        <label class="form-label">Transfer To Course *</label>
                        <select class="form-select" name="newCourseId" required>
                            <option value="">-- Select New Course --</option>
                            <% for (Course c : allCourses) { %>
                            <option value="<%= c.getCourseId() %>">
                                <%= c.getCourseName() %> (Available: <%= c.getAvailableSeats() %>)
                            </option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-custom"><i class="fas fa-check me-1"></i>Confirm Transfer</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openTransferModal(regId, currentCourse) {
    document.getElementById('transferRegId').value = regId;
    document.getElementById('currentCourseLabel').textContent = currentCourse;
    new bootstrap.Modal(document.getElementById('transferModal')).show();
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('#enrollTable tbody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>
</body>
</html>
