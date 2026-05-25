<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.registration.model.RegistrationRequest" %>
<%
    List<RegistrationRequest> queue = (List<RegistrationRequest>) request.getAttribute("queue");
    Integer queueSize = (Integer) request.getAttribute("queueSize");

    if (queue == null) queue = new ArrayList<>();
    if (queueSize == null) queueSize = 0;

    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Queue Management | CourseReg</title>
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
        .btn-logout { background: linear-gradient(135deg, #ef4444, #dc2626); color: white; border: none; width: 38px; height: 38px; border-radius: 50%; font-size: 1rem; transition: all 0.3s; margin-left: 8px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .btn-logout:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3); }

        /* Container */
        .queue-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Page Header */
        .page-header { margin-bottom: 25px; }
        .page-header h1 { font-size: 1.8rem; font-weight: 700; color: white; }
        .page-header p { color: rgba(255, 255, 255, 0.7); margin-top: 5px; }

        /* Queue Info Card */
        .queue-info-card { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(20px); border-radius: 24px; padding: 28px 32px; color: white; margin-bottom: 25px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .queue-badge { background: rgba(255, 255, 255, 0.1); padding: 10px 20px; border-radius: 20px; display: inline-block; text-align: center; }
        .queue-badge .number { font-size: 2rem; font-weight: 800; color: #a855f7; }
        .queue-badge .label { font-size: 0.7rem; opacity: 0.8; }

        /* Card Section */
        .card-section { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px 24px; margin-bottom: 25px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .card-section h5 { font-weight: 600; margin-bottom: 18px; color: white; }

        /* Table */
        .queue-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        .queue-table th { background: rgba(255, 255, 255, 0.08); padding: 12px; font-weight: 600; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); text-align: left; }
        .queue-table td { padding: 12px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); vertical-align: middle; color: rgba(255, 255, 255, 0.8); }
        .queue-table tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-next { background: rgba(245, 158, 11, 0.2); color: #fcd34d; padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }
        .badge-waiting { background: rgba(255, 255, 255, 0.1); color: rgba(255, 255, 255, 0.7); padding: 4px 12px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; display: inline-block; }

        /* Buttons */
        .btn-approve { background: #10b981; color: white; border: none; padding: 6px 15px; border-radius: 30px; margin-right: 5px; font-size: 0.7rem; font-weight: 600; transition: all 0.3s; }
        .btn-approve:hover { background: #059669; transform: scale(1.02); }
        .btn-reject { background: #ef4444; color: white; border: none; padding: 6px 15px; border-radius: 30px; font-size: 0.7rem; font-weight: 600; transition: all 0.3s; }
        .btn-reject:hover { background: #dc2626; transform: scale(1.02); }
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; border: none; padding: 8px 20px; border-radius: 40px; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-secondary-custom { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; padding: 8px 20px; border-radius: 40px; font-size: 0.8rem; font-weight: 500; transition: all 0.3s; }
        .btn-secondary-custom:hover { background: rgba(255, 255, 255, 0.2); }

        /* Alerts */
        .alert-success { background: rgba(16, 185, 129, 0.15); border-left: 4px solid #10b981; color: #6ee7b7; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-danger { background: rgba(239, 68, 68, 0.15); border-left: 4px solid #ef4444; color: #fca5a5; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }

        /* Empty State */
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state i { font-size: 4rem; color: rgba(255, 255, 255, 0.3); margin-bottom: 15px; }
        .empty-state h4 { font-size: 1.2rem; color: rgba(255, 255, 255, 0.6); margin-bottom: 10px; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 40px 0 20px; margin-top: 30px; border-top: 1px solid rgba(255, 255, 255, 0.1); }
        .footer-brand { font-size: 1.3rem; font-weight: 800; margin-bottom: 12px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 4px 0; font-size: 0.8rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; }
        .copyright { text-align: center; padding-top: 25px; margin-top: 25px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.75rem; }

        @media (max-width: 768px) { .queue-container { padding: 120px 0 40px; } .queue-table { font-size: 0.7rem; } .blob { display: none; } }
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
                <li class="nav-item"><a class="nav-link active" href="admin?action=queue">Queue</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-students.jsp">Students</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-admins">Admins</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-enrollments">Enrollments</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <li class="nav-item"><a class="btn-logout" href="logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="queue-container">
    <div class="container">

        <!-- Page Header -->
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h1><i class="fas fa-clock me-2" style="color: #a855f7;"></i>Queue Management</h1>
                <p>Manage and process student registration requests in FIFO order</p>
            </div>
            <div>
                <button onclick="location.reload()" class="btn btn-primary-custom me-2"><i class="fas fa-sync-alt me-2"></i>Refresh</button>
                <a href="admin" class="btn btn-secondary-custom"><i class="fas fa-arrow-left me-2"></i>Back</a>
            </div>
        </div>

        <!-- Alerts -->
        <% if(successMsg != null) { %>
            <div class="alert-success"><i class="fas fa-check-circle me-2"></i> <%= successMsg %></div>
        <% } %>
        <% if(errorMsg != null) { %>
            <div class="alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= errorMsg %></div>
        <% } %>

        <!-- Queue Info Card -->
        <div class="queue-info-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h3><i class="fas fa-hourglass-half me-2"></i>Registration Queue (FIFO)</h3>
                    <p class="mb-0 small opacity-75">First-In-First-Out order ensures fair processing.</p>
                </div>
                <div class="col-md-4 mt-3 mt-md-0 text-end">
                    <div class="queue-badge">
                        <div class="number"><%= queueSize %></div>
                        <div class="label">Total Requests</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Queue Table -->
        <div class="card-section">
            <h5><i class="fas fa-list me-2" style="color: #a855f7;"></i> Pending Registration Requests</h5>
            <div class="table-responsive">
                <table class="queue-table">
                    <thead>
                        <tr>
                            <th>Position</th>
                            <th>Request ID</th>
                            <th>Student</th>
                            <th>Student ID</th>
                            <th>Course</th>
                            <th>Request Time</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(queue.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <h4>Queue is Empty</h4>
                                    <a href="admin" class="btn btn-primary-custom mt-2">Go to Dashboard</a>
                                 </td>
                            </tr>
                        <% } else {
                            int position = 1;
                            for(RegistrationRequest req : queue) {
                                boolean isNext = (position == 1);
                        %>
                            <tr class="<%= isNext ? "table-warning" : "" %>">
                                <td>
                                    <% if(isNext) { %>
                                        <span class="badge-next"><i class="fas fa-arrow-right me-1"></i> #<%= position %> - NEXT</span>
                                    <% } else { %>
                                        <span class="badge-waiting">#<%= position %></span>
                                    <% } %>
                                </td>
                                <td><code><%= req.getRequestId() %></code></td>
                                <td>
                                    <strong><%= req.getStudentName() %></strong>
                                    <% if(isNext) { %>
                                        <span class="badge-waiting ms-1" style="background: rgba(245,158,11,0.2); color: #fcd34d;">Processing</span>
                                    <% } %>
                                </td>
                                <td><%= req.getStudentId() %></td>
                                <td><%= req.getCourseName() %></td>
                                <td><small><%= req.getRequestTime() %></small></td>
                                <td>
                                    <% if(isNext) { %>
                                        <a href="admin?action=approve&requestId=<%= req.getRequestId() %>" class="btn-approve btn-sm" onclick="return confirm('Approve this registration?')">Approve</a>
                                        <a href="admin?action=reject&requestId=<%= req.getRequestId() %>" class="btn-reject btn-sm" onclick="return confirm('Reject this registration?')">Reject</a>
                                    <% } else { %>
                                        <button class="btn btn-secondary btn-sm" disabled style="background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.5);">Waiting</button>
                                    <% } %>
                                </td>
                            </tr>
                        <%
                                position++;
                            }
                        } %>
                    </tbody>
                </table>
            </div>
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
</body>
</html>
