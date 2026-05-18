<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.registration.model.Student, com.registration.dao.UserDAO" %>
<%
    UserDAO userDAO = new UserDAO();
    List<Student> students = userDAO.getAllStudents();

    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    int csCount = 0, itCount = 0, seCount = 0, dsCount = 0, cyCount = 0;
    for (Student s : students) {
        String dept = s.getDepartment();
        if ("Computer Science".equals(dept)) csCount++;
        else if ("Information Technology".equals(dept)) itCount++;
        else if ("Software Engineering".equals(dept)) seCount++;
        else if ("Data Science".equals(dept)) dsCount++;
        else if ("Cyber Security".equals(dept)) cyCount++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Students | CourseReg</title>
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
        .students-container { padding: 100px 0 50px; position: relative; z-index: 1; }

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

        /* Filter Elements */
        .filter-label { font-weight: 600; font-size: 0.75rem; margin-bottom: 6px; color: rgba(255, 255, 255, 0.8); }
        .search-input { background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 12px; padding: 8px 12px; font-size: 0.85rem; color: white; }
        .search-input:focus { border-color: #a855f7; outline: none; box-shadow: 0 0 0 2px rgba(168, 85, 247, 0.2); }
        .search-input option { background: #1e1b4b; }

        /* Buttons */
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 8px 20px; border-radius: 40px; color: white; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-secondary-custom { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); padding: 8px 20px; border-radius: 40px; color: white; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-secondary-custom:hover { background: rgba(255, 255, 255, 0.2); }

        /* Table */
        .custom-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        .custom-table th { background: rgba(255, 255, 255, 0.08); padding: 10px; font-weight: 600; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        .custom-table td { padding: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); vertical-align: middle; color: rgba(255, 255, 255, 0.8); }
        .custom-table tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-dept { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 4px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; display: inline-block; }
        .badge-semester { background: rgba(245, 158, 11, 0.2); color: #fcd34d; padding: 4px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; display: inline-block; }

        /* Action Buttons */
        .btn-action { padding: 4px 10px; border-radius: 6px; font-size: 0.7rem; margin: 0 2px; border: none; cursor: pointer; }
        .btn-edit-action { background: #f59e0b; color: white; }
        .btn-edit-action:hover { background: #d97706; }
        .btn-delete-action { background: #ef4444; color: white; }
        .btn-delete-action:hover { background: #dc2626; }

        /* Modal */
        .modal-custom .modal-content { background: rgba(15, 12, 41, 0.95); backdrop-filter: blur(20px); border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .modal-custom .modal-header { background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 20px 20px 0 0; padding: 15px 20px; border: none; }
        .modal-custom .modal-header .btn-close { filter: brightness(0) invert(1); }
        .modal-custom .modal-footer .btn-secondary { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 40px 0 20px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.1); }
        .footer-brand { font-size: 1.3rem; font-weight: 800; margin-bottom: 12px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 4px 0; font-size: 0.8rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; }
        .copyright { text-align: center; padding-top: 25px; margin-top: 25px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.75rem; }

        @media (max-width: 768px) { .students-container { padding: 120px 0 40px; } .stats-row { flex-direction: column; } .blob { display: none; } }
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
                <li class="nav-item"><a class="nav-link active" href="manage-students.jsp">Students</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="students-container">
    <div class="container">

        <!-- Page Header -->
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-users me-2" style="color: #a855f7;"></i>Manage Students</h1>
                <p>View, add, edit, and manage student accounts</p>
            </div>
            <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addStudentModal"><i class="fas fa-user-plus me-2"></i>Add New Student</button>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-row">
            <div class="stat-card"><div class="stat-number"><%= students.size() %></div><div class="stat-label">Total Students</div></div>
            <div class="stat-card"><div class="stat-number"><%= csCount %></div><div class="stat-label">Computer Science</div></div>
            <div class="stat-card"><div class="stat-number"><%= itCount %></div><div class="stat-label">Information Technology</div></div>
            <div class="stat-card"><div class="stat-number"><%= seCount %></div><div class="stat-label">Software Engineering</div></div>
        </div>

        <!-- Search & Filter -->
        <div class="content-card">
            <div class="row g-3">
                <div class="col-md-5">
                    <label class="filter-label">Search Students</label>
                    <div class="d-flex gap-2">
                        <input type="text" id="searchInput" class="form-control search-input" placeholder="Name, ID or email..." onkeyup="filterTable()">
                        <button class="btn btn-primary-custom" onclick="filterTable()"><i class="fas fa-search"></i> Search</button>
                    </div>
                </div>
                <div class="col-md-3">
                    <label class="filter-label">Department</label>
                    <select id="deptFilter" class="form-select search-input" onchange="filterTable()">
                        <option value="all">All</option>
                        <option value="Computer Science">CS</option>
                        <option value="Information Technology">IT</option>
                        <option value="Software Engineering">SE</option>
                        <option value="Data Science">DS</option>
                        <option value="Cyber Security">Cyber</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="filter-label">Sort By</label>
                    <select id="sortBy" class="form-select search-input" onchange="sortTable()">
                        <option value="name">Name</option>
                        <option value="id">Student ID</option>
                        <option value="semester">Semester</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="filter-label">&nbsp;</label>
                    <button class="btn btn-secondary-custom w-100" onclick="resetFilters()"><i class="fas fa-sync-alt"></i> Reset</button>
                </div>
            </div>
        </div>

        <!-- Students Table -->
        <div class="content-card">
            <div class="table-responsive">
                <table class="custom-table" id="studentsTable">
                    <thead>
                        <tr>
                            <th>Student Name</th>
                            <th>Student ID</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Semester</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <% if(students.isEmpty()) { %>
                            <td><td colspan="6" class="text-center py-5 opacity-50">No students found</td></tr>
                        <% } else {
                            for(Student student : students) { %>
                                <tr data-name="<%= student.getUsername().toLowerCase() %>" data-id="<%= student.getStudentId().toLowerCase() %>" data-email="<%= student.getEmail().toLowerCase() %>" data-dept="<%= student.getDepartment() %>" data-semester="<%= student.getSemester() %>">
                                    <td><strong><%= student.getUsername() %></strong></td>
                                    <td><%= student.getStudentId() %></td>
                                    <td><%= student.getEmail() %></td>
                                    <td><span class="badge-dept"><%= student.getDepartment() %></span></td>
                                    <td><span class="badge-semester">Sem <%= student.getSemester() %></span></td>
                                    <td>
                                        <button class="btn-action btn-edit-action" onclick='editStudent("<%= student.getId() %>","<%= student.getUsername() %>","<%= student.getStudentId() %>","<%= student.getEmail() %>","<%= student.getDepartment() %>",<%= student.getSemester() %>)'><i class="fas fa-edit"></i></button>
                                        <button class="btn-action btn-delete-action" onclick="deleteStudent('<%= student.getId() %>','<%= student.getUsername() %>')"><i class="fas fa-trash"></i></button>
                                    </td>
                                </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Student Modal -->
<div class="modal fade modal-custom" id="addStudentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>Add Student</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="register" method="post">
                <div class="modal-body p-4">
                    <div class="row"><div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Username</label><input type="text" name="username" class="form-control search-input" required></div>
                    <div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Student ID</label><input type="text" name="studentId" class="form-control search-input" required></div></div>
                    <div class="row"><div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Password</label><input type="password" name="password" class="form-control search-input" required></div>
                    <div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Email</label><input type="email" name="email" class="form-control search-input" required></div></div>
                    <div class="row"><div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Department</label>
                        <select name="department" class="form-select search-input" required>
                            <option>Computer Science</option><option>Information Technology</option><option>Software Engineering</option>
                            <option>Data Science</option><option>Cyber Security</option><option>General</option>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Semester</label>
                        <select name="semester" class="form-select search-input" required>
                            <% for(int i=1;i<=8;i++){ %><option value="<%= i %>">Semester <%= i %></option><% } %>
                        </select>
                    </div></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Register</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Student Modal -->
<div class="modal fade modal-custom" id="editStudentModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Student</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="UpdateStudentServlet" method="post">
                <input type="hidden" name="userId" id="editUserId">
                <div class="modal-body p-4">
                    <div class="row"><div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Username</label><input type="text" name="username" id="editUsername" class="form-control search-input" required></div>
                    <div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Student ID</label><input type="text" name="studentId" id="editStudentId" class="form-control search-input" required></div></div>
                    <div class="mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Email</label><input type="email" name="email" id="editEmail" class="form-control search-input" required></div>
                    <div class="row"><div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Department</label>
                        <select name="department" id="editDepartment" class="form-select search-input" required>
                            <option>Computer Science</option><option>Information Technology</option><option>Software Engineering</option>
                            <option>Data Science</option><option>Cyber Security</option><option>General</option>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">Semester</label>
                        <select name="semester" id="editSemester" class="form-select search-input" required>
                            <% for(int i=1;i<=8;i++){ %><option value="<%= i %>">Semester <%= i %></option><% } %>
                        </select>
                    </div></div>
                    <div class="mb-3"><label class="fw-semibold mb-2" style="color: rgba(255,255,255,0.8);">New Password <span class="text-muted" style="color: rgba(255,255,255,0.5);">(optional)</span></label><input type="password" name="newPassword" class="form-control search-input" placeholder="Leave blank to keep current"></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Update</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3"><div class="footer-brand">Course<span>Reg</span></div><p class="text-white-50 small">Smart course registration.</p></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Quick Links</h6><a href="admin">Dashboard</a><a href="courses">Courses</a><a href="admin?action=queue">Queue</a></div>
            <div class="col-md-2 col-6 mb-3 footer-links"><h6 class="text-white mb-2">Management</h6><a href="manage-students.jsp">Students</a><a href="reports.jsp">Reports</a></div>
            <div class="col-md-4 mb-3 footer-links"><h6 class="text-white mb-2">Connect</h6><div class="d-flex gap-3"><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-linkedin"></i></a><a href="#"><i class="fab fa-github"></i></a></div></div>
        </div>
        <div class="copyright"><p>&copy; 2024 CourseReg. FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p></div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filterTable(){var s=document.getElementById('searchInput').value.toLowerCase(),d=document.getElementById('deptFilter').value;document.querySelectorAll('#tableBody tr[data-name]').forEach(r=>{var n=r.getAttribute('data-name'),i=r.getAttribute('data-id'),e=r.getAttribute('data-email'),dept=r.getAttribute('data-dept');r.style.display=(n.includes(s)||i.includes(s)||e.includes(s))&&(d==='all'||dept===d)?'':'none';});}
    function sortTable(){var sort=document.getElementById('sortBy').value,tbody=document.getElementById('tableBody'),rows=Array.from(tbody.querySelectorAll('tr[data-name]'));rows.sort((a,b)=>{if(sort==='name')return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name'));if(sort==='id')return a.getAttribute('data-id').localeCompare(b.getAttribute('data-id'));return parseInt(a.getAttribute('data-semester'))-parseInt(b.getAttribute('data-semester'));});rows.forEach(r=>tbody.appendChild(r));}
    function resetFilters(){document.getElementById('searchInput').value='';document.getElementById('deptFilter').value='all';document.querySelectorAll('#tableBody tr[data-name]').forEach(r=>r.style.display='');sortTable();}
    function editStudent(id,username,studentId,email,department,semester){document.getElementById('editUserId').value=id;document.getElementById('editUsername').value=username;document.getElementById('editStudentId').value=studentId;document.getElementById('editEmail').value=email;document.getElementById('editDepartment').value=department;document.getElementById('editSemester').value=semester;new bootstrap.Modal(document.getElementById('editStudentModal')).show();}
    function deleteStudent(userId,username){if(confirm('Delete "'+username+'"? This cannot be undone.')){window.location.href='DeleteStudentServlet?userId='+userId;}}
</script>
</body>
</html>
