<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.FeedbackDAO" %>
<%@ page import="com.registration.model.Feedback" %>
<%@ page import="java.util.*" %>

<%
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null || !"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    FeedbackDAO feedbackDAO = new FeedbackDAO();
    List<Feedback> allFeedbacks = feedbackDAO.getAllFeedbacks();

    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Feedback | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
        .feedback-container {
            padding: 100px 0 50px;
            position: relative;
            z-index: 1;
        }

        /* Page Header */
        .page-header {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 28px;
            padding: 32px 36px;
            margin-bottom: 35px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .page-header h1 {
            font-size: 2rem;
            font-weight: 700;
        }

        /* Content Card */
        .content-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 24px;
            padding: 24px 28px;
            margin-bottom: 30px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid rgba(255, 255, 255, 0.1);
            color: white;
        }

        /* Table */
        .feedback-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }

        .feedback-table th {
            background: rgba(255, 255, 255, 0.08);
            padding: 12px;
            font-weight: 600;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            text-align: left;
            color: rgba(255, 255, 255, 0.9);
        }

        .feedback-table td {
            padding: 10px 12px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: rgba(255, 255, 255, 0.8);
        }

        /* Badges */
        .badge-pending {
            background: rgba(245, 158, 11, 0.2);
            color: #fcd34d;
            padding: 4px 12px;
            border-radius: 30px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        .badge-approved {
            background: rgba(16, 185, 129, 0.2);
            color: #6ee7b7;
            padding: 4px 12px;
            border-radius: 30px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        .badge-rejected {
            background: rgba(239, 68, 68, 0.2);
            color: #fca5a5;
            padding: 4px 12px;
            border-radius: 30px;
            font-size: 0.7rem;
            font-weight: 600;
        }

        /* Buttons */
        .btn-approve {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            border: none;
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 600;
            margin: 2px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-approve:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            color: white;
        }

        .btn-reject {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 0.7rem;
            font-weight: 600;
            margin: 2px;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-reject:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
            color: white;
        }

        /* Star Rating */
        .star-rating {
            color: #f59e0b;
        }

        /* Alerts */
        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            backdrop-filter: blur(10px);
            border-left: 4px solid #10b981;
            color: #6ee7b7;
            padding: 12px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.15);
            backdrop-filter: blur(10px);
            border-left: 4px solid #ef4444;
            color: #fca5a5;
            padding: 12px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        /* Badge */
        .badge-primary {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            color: white;
            padding: 5px 12px;
            border-radius: 30px;
            font-size: 0.75rem;
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
            .feedback-container {
                padding: 120px 0 40px;
            }
            .feedback-table {
                font-size: 0.7rem;
            }
            .blob {
                display: none;
            }
        }

        /* Print */
        @media print {
            .navbar, .btn-logout, footer {
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
                <li class="nav-item">
                    <a class="nav-link" href="admin">Dashboard</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="courses">Courses</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="admin?action=queue">Queue</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="manage-students.jsp">Students</a>
                </li>
                <li class="nav-item"><a class="nav-link" href="manage-admins">Admins</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-enrollments">Enrollments</a></li>
                <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                <li class="nav-item">
                    <a class="nav-link" href="reports.jsp">Reports</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="admin-feedback.jsp">Feedback</a>
                </li>
                <li class="nav-item">
                    <a class="btn-logout" href="logout" title="Logout"><i class="fas fa-sign-out-alt"></i></a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="feedback-container">
    <div class="container">

        <!-- Page Header -->
        <div class="page-header">
            <div class="d-flex justify-content-between align-items-center flex-wrap">
                <div>
                    <h1>
                        <i class="fas fa-star me-2" style="color: #f59e0b;"></i>
                        Manage Course Feedback
                    </h1>
                    <p class="mb-0 opacity-75">Approve or reject student feedback and reviews</p>
                </div>
            </div>
        </div>

        <!-- Alert Messages -->
        <% if (successMsg != null) { %>
            <div class="alert-success">
                <i class="fas fa-check-circle me-2"></i> <%= successMsg %>
            </div>
        <% } %>

        <% if (errorMsg != null) { %>
            <div class="alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i> <%= errorMsg %>
            </div>
        <% } %>

        <!-- Feedback Table -->
        <div class="content-card">
            <div class="card-title">
                <i class="fas fa-list me-2" style="color: #a855f7;"></i>
                Student Feedback & Reviews
                <span class="badge-primary ms-2"><%= allFeedbacks.size() %> total</span>
            </div>

            <div class="table-responsive">
                <table class="feedback-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Student</th>
                            <th>Course</th>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (allFeedbacks.isEmpty()) { %>
                            <tr>
                                <td colspan="8" class="text-center py-5">
                                    <i class="fas fa-inbox me-2"></i>No feedback submitted yet
                                </td>
                            </tr>
                        <% } else {
                            for (Feedback f : allFeedbacks) {
                                String statusClass = f.getStatus().equals("pending") ? "badge-pending" :
                                                   (f.getStatus().equals("approved") ? "badge-approved" : "badge-rejected");
                        %>
                            <tr>
                                <td><code><%= f.getFeedbackId() %></code></td>
                                <td><strong><%= f.getStudentName() %></strong></td>
                                <td><%= f.getCourseName() %></td>
                                <td class="star-rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <% if (i <= f.getRating()) { %>
                                            <i class="fas fa-star"></i>
                                        <% } else { %>
                                            <i class="far fa-star"></i>
                                        <% } %>
                                    <% } %>
                                    (<%= f.getRating() %>)
                                </td>
                                <td>
                                    <%= f.getComment().length() > 50 ? f.getComment().substring(0, 50) + "..." : f.getComment() %>
                                </td>
                                <td><small><%= f.getFeedbackDate() %></small></td>
                                <td><span class="<%= statusClass %>"><%= f.getStatus() %></span></td>
                                <td>
                                    <% if ("pending".equals(f.getStatus())) { %>
                                        <a href="approve-feedback?feedbackId=<%= f.getFeedbackId() %>&status=approved"
                                           class="btn-approve"
                                           onclick="return confirm('Approve this feedback?')">
                                            <i class="fas fa-check me-1"></i>Approve
                                        </a>
                                        <a href="approve-feedback?feedbackId=<%= f.getFeedbackId() %>&status=rejected"
                                           class="btn-reject"
                                           onclick="return confirm('Reject this feedback?')">
                                            <i class="fas fa-times me-1"></i>Reject
                                        </a>
                                    <% } else { %>
                                        <span class="opacity-50">—</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% }
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
                <a href="admin-feedback.jsp">Feedback</a>
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
</body>
</html>
