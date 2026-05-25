<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.registration.model.Admin, com.registration.dao.UserDAO" %>
<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    String currentUserId = (String) session.getAttribute("userId");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    List<Admin> admins = userDAO.getAllAdmins();

    String successMsg = request.getParameter("success");
    String errorMsg   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Admins | CourseReg</title>
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
        .form-control::placeholder { color: rgba(255,255,255,0.4); }
        .form-select option { background: #1e1b4b; }
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 9px 22px; border-radius: 40px; color: white; font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .btn-primary-custom:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(168,85,247,0.35); }
        .admins-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
        .admins-table th { background: rgba(255,255,255,0.08); padding: 10px 12px; font-weight: 600; color: rgba(255,255,255,0.9); border-bottom: 1px solid rgba(255,255,255,0.1); }
        .admins-table td { padding: 10px 12px; border-bottom: 1px solid rgba(255,255,255,0.05); color: rgba(255,255,255,0.8); vertical-align: middle; }
        .admins-table tr:hover { background: rgba(255,255,255,0.03); }
        .badge-perm { background: rgba(168,85,247,0.2); color: #d8b4fe; padding: 3px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .btn-edit-sm { background: #f59e0b; color: white; border: none; padding: 5px 12px; border-radius: 8px; font-size: 0.72rem; cursor: pointer; }
        .btn-delete-sm { background: #ef4444; color: white; border: none; padding: 5px 12px; border-radius: 8px; font-size: 0.72rem; cursor: pointer; }
        .alert-success { background: rgba(16,185,129,0.15); border: 1px solid rgba(16,185,129,0.3); color: #6ee7b7; padding: 12px 18px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-error { background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3); color: #fca5a5; padding: 12px 18px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .modal-content { background: #1e1b4b; border: 1px solid rgba(255,255,255,0.15); border-radius: 20px; color: white; }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.1); }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-close { filter: invert(1); }
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
                <li class="nav-item"><a class="nav-link active" href="manage-admins">Admins</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-enrollments">Enrollments</a></li>
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
            <h1><i class="fas fa-user-shield me-2" style="color:#a855f7"></i>Admin Management</h1>
            <p>Create, update, and remove admin/staff accounts</p>
        </div>

        <% if (successMsg != null) { %>
        <div class="alert-success"><i class="fas fa-check-circle me-2"></i><%= successMsg %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert-error"><i class="fas fa-exclamation-triangle me-2"></i><%= errorMsg %></div>
        <% } %>

        <!-- Create Admin Form -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-plus-circle"></i> Create New Admin Account</div>
            <form action="manage-admins" method="post">
                <input type="hidden" name="action" value="create">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Username *</label>
                        <input type="text" class="form-control" name="username" required placeholder="e.g. admin2">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Password *</label>
                        <input type="password" class="form-control" name="password" required placeholder="Min 6 chars">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Email *</label>
                        <input type="email" class="form-control" name="email" required placeholder="admin@example.com">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Admin Code</label>
                        <input type="text" class="form-control" name="adminCode" value="ADMIN001" placeholder="ADMIN001">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Permissions</label>
                        <select class="form-select" name="permissions">
                            <option value="full">Full</option>
                            <option value="readonly">Read Only</option>
                            <option value="manage_students">Manage Students</option>
                            <option value="manage_courses">Manage Courses</option>
                        </select>
                    </div>
                    <div class="col-12">
                        <button type="submit" class="btn-primary-custom"><i class="fas fa-plus me-2"></i>Create Admin</button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Admins Table -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-users-cog"></i> Admin Accounts (<%= admins.size() %>)</div>
            <% if (admins.isEmpty()) { %>
            <p style="color:rgba(255,255,255,0.5); text-align:center; padding:30px;">No admin accounts found.</p>
            <% } else { %>
            <div class="table-responsive">
                <table class="admins-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Email</th>
                            <th>Admin Code</th>
                            <th>Permissions</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Admin a : admins) { %>
                        <tr>
                            <td style="color:rgba(255,255,255,0.5); font-size:0.75rem;"><%= a.getId() %></td>
                            <td><strong><%= a.getUsername() %></strong></td>
                            <td><%= a.getEmail() %></td>
                            <td><%= a.getAdminCode() %></td>
                            <td><span class="badge-perm"><%= a.getPermissions() %></span></td>
                            <td>
                                <button class="btn-edit-sm me-1" onclick="openEditModal('<%= a.getId() %>','<%= a.getPermissions() %>')">
                                    <i class="fas fa-edit me-1"></i>Edit
                                </button>
                                <% if (!a.getId().equals(currentUserId)) { %>
                                <a class="btn-delete-sm" href="manage-admins?action=delete&adminId=<%= a.getId() %>"
                                   onclick="return confirm('Delete admin <%= a.getUsername() %>? This cannot be undone.')">
                                    <i class="fas fa-trash me-1"></i>Delete
                                </a>
                                <% } else { %>
                                <span style="color:rgba(255,255,255,0.3); font-size:0.75rem;">(current user)</span>
                                <% } %>
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

<!-- Edit Admin Modal -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-user-edit me-2"></i>Update Admin</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="manage-admins" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="adminId" id="editAdminId">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">New Password <small style="color:rgba(255,255,255,0.4)">(leave blank to keep current)</small></label>
                        <input type="password" class="form-control" name="password" placeholder="Enter new password">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Permissions</label>
                        <select class="form-select" name="permissions" id="editPermissions">
                            <option value="full">Full</option>
                            <option value="readonly">Read Only</option>
                            <option value="manage_students">Manage Students</option>
                            <option value="manage_courses">Manage Courses</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-custom"><i class="fas fa-save me-1"></i>Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEditModal(adminId, permissions) {
    document.getElementById('editAdminId').value = adminId;
    document.getElementById('editPermissions').value = permissions;
    new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>
</body>
</html>
