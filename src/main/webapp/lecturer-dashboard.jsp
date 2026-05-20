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
        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%); color: #fff; min-height: 100vh; overflow-x: hidden; }

        .blob { position: fixed; width: 400px; height: 400px; border-radius: 50%; filter: blur(80px); opacity: 0.3; animation: float 6s ease-in-out infinite; pointer-events: none; z-index: 0; }
        .blob-1 { top: 10%; left: -5%; background: linear-gradient(135deg, #06b6d4, #3b82f6); }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #a855f7, #7c3aed); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #10b981, #059669); animation-delay: -4s; opacity: 0.2; }
        @keyframes float { 0%, 100% { transform: translate(0, 0) rotate(0deg); } 50% { transform: translate(30px, -30px) rotate(5deg); } }

        .navbar { background: rgba(255,255,255,0.05); backdrop-filter: blur(20px); padding: 0.8rem 0; border-bottom: 1px solid rgba(255,255,255,0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 1.6rem; font-weight: 800; background: linear-gradient(135deg, #fff, #06b6d4); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-link { color: rgba(255,255,255,0.8) !important; font-weight: 500; margin: 0 0.3rem; padding: 8px 18px !important; border-radius: 40px; transition: all 0.3s; }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: #fff !important; }
        .nav-link.logout-btn { background: rgba(239,68,68,0.2); color: #f87171 !important; border: 1px solid rgba(239,68,68,0.3); }
        .nav-link.logout-btn:hover { background: rgba(239,68,68,0.4); }

        .main-content { padding-top: 90px; padding-bottom: 40px; position: relative; z-index: 1; }

        .welcome-card { background: linear-gradient(135deg, rgba(6,182,212,0.2), rgba(59,130,246,0.2)); border: 1px solid rgba(6,182,212,0.3); border-radius: 20px; padding: 30px; margin-bottom: 30px; backdrop-filter: blur(10px); }
        .welcome-card h2 { font-size: 2rem; font-weight: 800; }
        .welcome-card p { color: rgba(255,255,255,0.7); margin: 0; }

        .stat-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 16px; padding: 24px; backdrop-filter: blur(10px); transition: all 0.3s; text-align: center; }
        .stat-card:hover { transform: translateY(-4px); background: rgba(255,255,255,0.08); }
        .stat-icon { width: 60px; height: 60px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; margin: 0 auto 12px; }
        .stat-value { font-size: 2.2rem; font-weight: 800; }
        .stat-label { color: rgba(255,255,255,0.6); font-size: 0.9rem; }

        .section-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; padding: 30px; backdrop-filter: blur(10px); margin-bottom: 30px; }
        .section-title { font-size: 1.3rem; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }

        .course-row { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08); border-radius: 12px; padding: 16px 20px; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; transition: all 0.3s; flex-wrap: wrap; gap: 12px; }
        .course-row:hover { background: rgba(255,255,255,0.07); border-color: rgba(6,182,212,0.3); }
        .course-name { font-weight: 600; font-size: 1rem; }
        .course-meta { color: rgba(255,255,255,0.6); font-size: 0.85rem; margin-top: 4px; }
        .course-badge { padding: 4px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
        .badge-seats { background: rgba(16,185,129,0.2); color: #34d399; border: 1px solid rgba(16,185,129,0.3); }
        .badge-full { background: rgba(239,68,68,0.2); color: #f87171; border: 1px solid rgba(239,68,68,0.3); }
        .badge-credits { background: rgba(139,92,246,0.2); color: #a78bfa; border: 1px solid rgba(139,92,246,0.3); }

        .btn-teal { background: linear-gradient(135deg, #06b6d4, #0891b2); border: none; color: #fff; padding: 8px 20px; border-radius: 10px; font-weight: 600; transition: all 0.3s; font-size: 0.9rem; }
        .btn-teal:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(6,182,212,0.4); color: #fff; }
        .btn-danger-soft { background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3); color: #f87171; padding: 8px 16px; border-radius: 10px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; }
        .btn-danger-soft:hover { background: rgba(239,68,68,0.3); color: #fca5a5; }
        .btn-outline-info-soft { background: rgba(6,182,212,0.1); border: 1px solid rgba(6,182,212,0.3); color: #67e8f9; padding: 8px 16px; border-radius: 10px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; }
        .btn-outline-info-soft:hover { background: rgba(6,182,212,0.25); color: #a5f3fc; }

        .form-control, .form-select { background: rgba(255,255,255,0.07); border: 1px solid rgba(255,255,255,0.15); color: #fff; border-radius: 10px; padding: 10px 14px; }
        .form-control:focus, .form-select:focus { background: rgba(255,255,255,0.1); border-color: #06b6d4; color: #fff; box-shadow: 0 0 0 3px rgba(6,182,212,0.2); }
        .form-control::placeholder { color: rgba(255,255,255,0.4); }
        .form-select option { background: #1e1b4b; color: #fff; }
        .form-label { color: rgba(255,255,255,0.8); font-weight: 500; font-size: 0.9rem; }

        .student-table { width: 100%; border-collapse: separate; border-spacing: 0; }
        .student-table th { background: rgba(6,182,212,0.15); color: #67e8f9; font-weight: 600; font-size: 0.85rem; padding: 12px 16px; text-transform: uppercase; letter-spacing: 0.05em; }
        .student-table th:first-child { border-radius: 10px 0 0 0; }
        .student-table th:last-child { border-radius: 0 10px 0 0; }
        .student-table td { padding: 12px 16px; border-bottom: 1px solid rgba(255,255,255,0.06); font-size: 0.9rem; color: rgba(255,255,255,0.85); }
        .student-table tr:hover td { background: rgba(255,255,255,0.03); }

        .alert-success-custom { background: rgba(16,185,129,0.15); border: 1px solid rgba(16,185,129,0.3); color: #34d399; border-radius: 12px; padding: 14px 20px; margin-bottom: 20px; }
        .alert-danger-custom { background: rgba(239,68,68,0.15); border: 1px solid rgba(239,68,68,0.3); color: #f87171; border-radius: 12px; padding: 14px 20px; margin-bottom: 20px; }

        .profile-badge { display: inline-flex; align-items: center; gap: 8px; background: rgba(6,182,212,0.15); border: 1px solid rgba(6,182,212,0.3); padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; color: #67e8f9; }

        .modal-content { background: #1e1b4b; border: 1px solid rgba(255,255,255,0.15); border-radius: 20px; color: #fff; }
        .modal-header { border-bottom: 1px solid rgba(255,255,255,0.1); padding: 20px 24px; }
        .modal-footer { border-top: 1px solid rgba(255,255,255,0.1); }
        .modal-title { font-weight: 700; }
        .btn-close { filter: invert(1); }

        .btn-edit-soft { background: rgba(245,158,11,0.15); border: 1px solid rgba(245,158,11,0.3); color: #fcd34d; padding: 8px 16px; border-radius: 10px; font-weight: 600; font-size: 0.85rem; transition: all 0.3s; cursor: pointer; }
        .btn-edit-soft:hover { background: rgba(245,158,11,0.3); color: #fde68a; }

        .empty-state { text-align: center; padding: 40px; color: rgba(255,255,255,0.4); }
        .empty-state i { font-size: 3rem; margin-bottom: 12px; display: block; }
    </style>
</head>
<body>
<div class="blob blob-1"></div>
<div class="blob blob-2"></div>
<div class="blob blob-3"></div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="lecturer-dashboard"><i class="fas fa-graduation-cap me-2"></i>CourseReg</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link active" href="lecturer-dashboard"><i class="fas fa-home me-1"></i>Dashboard</a></li>
                <li class="nav-item">
                    <span class="profile-badge me-2"><i class="fas fa-user-tie"></i><%= lecturerName %></span>
                </li>
                <li class="nav-item"><a class="nav-link logout-btn" href="logout"><i class="fas fa-sign-out-alt me-1"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="main-content">
    <div class="container">

        <!-- Alerts -->
        <% if (successMsg != null) { %>
        <div class="alert-success-custom"><i class="fas fa-check-circle me-2"></i><%= successMsg.replace("+", " ") %></div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert-danger-custom"><i class="fas fa-exclamation-circle me-2"></i><%= errorMsg.replace("+", " ") %></div>
        <% } %>

        <!-- Welcome Card -->
        <div class="welcome-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h2><i class="fas fa-chalkboard-teacher me-2" style="color:#06b6d4;"></i>Welcome, <%= lecturerName %>!</h2>
                    <p class="mt-2">
                        <i class="fas fa-building me-1"></i><%= lecturerDept %> &nbsp;&nbsp;
                        <i class="fas fa-envelope me-1"></i><%= lecturerEmail %>
                    </p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <button class="btn btn-teal" data-bs-toggle="modal" data-bs-target="#addCourseModal">
                        <i class="fas fa-plus me-2"></i>Add New Course
                    </button>
                </div>
            </div>
        </div>

        <!-- Stats -->
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(6,182,212,0.2); color:#06b6d4;">
                        <i class="fas fa-book-open"></i>
                    </div>
                    <div class="stat-value" style="color:#06b6d4;"><%= myCourses != null ? myCourses.size() : 0 %></div>
                    <div class="stat-label">My Courses</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(139,92,246,0.2); color:#a78bfa;">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value" style="color:#a78bfa;">
                        <%
                            java.util.Map<String, Integer> enrolledCounts = (java.util.Map<String, Integer>) request.getAttribute("enrolledCounts");
                            int totalEnrolled = 0;
                            if (enrolledCounts != null) {
                                for (int cnt : enrolledCounts.values()) {
                                    totalEnrolled += cnt;
                                }
                            }
                        %><%= totalEnrolled %>
                    </div>
                    <div class="stat-label">Total Enrolled Students</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(16,185,129,0.2); color:#34d399;">
                        <i class="fas fa-chair"></i>
                    </div>
                    <div class="stat-value" style="color:#34d399;">
                        <%
                            int totalSeatsLeft = 0;
                            if (myCourses != null && enrolledCounts != null) {
                                for (Course c : myCourses) {
                                    int ec = enrolledCounts.getOrDefault(c.getCourseId(), 0);
                                    totalSeatsLeft += (c.getTotalSeats() - ec);
                                }
                            }
                        %><%= totalSeatsLeft %>
                    </div>
                    <div class="stat-label">Total Available Seats</div>
                </div>
            </div>
        </div>

        <!-- My Courses Section -->
        <div class="section-card">
            <div class="section-title">
                <i class="fas fa-book" style="color:#06b6d4;"></i> My Courses
                <span class="ms-auto">
                    <button class="btn btn-teal btn-sm" data-bs-toggle="modal" data-bs-target="#addCourseModal">
                        <i class="fas fa-plus me-1"></i>Add Course
                    </button>
                </span>
            </div>

            <% if (myCourses == null || myCourses.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-book-open"></i>
                <p>You haven't added any courses yet.</p>
                <button class="btn btn-teal mt-2" data-bs-toggle="modal" data-bs-target="#addCourseModal">Add Your First Course</button>
            </div>
            <% } else { %>
                <% for (Course course : myCourses) {
                    int enrolled = (enrolledCounts != null) ? enrolledCounts.getOrDefault(course.getCourseId(), 0) : 0;
                    boolean isFull = (enrolled >= course.getTotalSeats());
                %>
                <div class="course-row">
                    <div>
                        <div class="course-name"><%= course.getCourseName() %> <small style="color:rgba(255,255,255,0.4);">(#<%= course.getCourseId() %>)</small></div>
                        <div class="course-meta">
                            <i class="fas fa-clock me-1"></i><%= course.getSchedule() %> &nbsp;
                            <i class="fas fa-building me-1"></i><%= course.getDepartment() %>
                        </div>
                    </div>
                    <div class="d-flex align-items-center gap-2 flex-wrap">
                        <span class="course-badge badge-credits"><i class="fas fa-star me-1"></i><%= course.getCredits() %> Credits</span>
                        <span class="course-badge <%= isFull ? "badge-full" : "badge-seats" %>">
                            <i class="fas fa-users me-1"></i><%= enrolled %>/<%= course.getTotalSeats() %> enrolled
                        </span>
                        <a href="lecturer-dashboard?action=viewStudents&courseId=<%= course.getCourseId() %>" class="btn btn-outline-info-soft">
                            <i class="fas fa-users me-1"></i>View Students
                        </a>
                        <button class="btn btn-edit-soft"
                            onclick="openEditModal('<%= course.getCourseId() %>','<%= course.getCourseName().replace("'", "\\'") %>','<%= course.getTotalSeats() %>','<%= course.getCredits() %>','<%= course.getSchedule().replace("'", "\\'") %>')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <form action="lecturer-dashboard" method="post" style="display:inline;" onsubmit="return confirm('Delete this course?');">
                            <input type="hidden" name="action" value="deleteCourse">
                            <input type="hidden" name="courseId" value="<%= course.getCourseId() %>">
                            <button type="submit" class="btn btn-danger-soft"><i class="fas fa-trash"></i></button>
                        </form>
                    </div>
                </div>
                <% } %>
            <% } %>
        </div>

        <!-- Enrolled Students Section (shown when a course is selected) -->
        <% if (selectedCourse != null) { %>
        <div class="section-card">
            <div class="section-title">
                <i class="fas fa-users" style="color:#a78bfa;"></i>
                Enrolled Students — <span style="color:#06b6d4;"><%= selectedCourse.getCourseName() %></span>
                <a href="lecturer-dashboard" class="btn btn-sm ms-auto" style="background:rgba(255,255,255,0.1);color:#fff;border-radius:8px;">
                    <i class="fas fa-times me-1"></i>Close
                </a>
            </div>

            <% if (enrolledStudents == null || enrolledStudents.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-user-slash"></i>
                <p>No students enrolled in this course yet.</p>
            </div>
            <% } else { %>
            <div class="table-responsive">
                <table class="student-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th><i class="fas fa-id-card me-1"></i>Student ID</th>
                            <th><i class="fas fa-user me-1"></i>Name</th>
                            <th><i class="fas fa-envelope me-1"></i>Email</th>
                            <th><i class="fas fa-building me-1"></i>Department</th>
                            <th><i class="fas fa-layer-group me-1"></i>Semester</th>
                            <th><i class="fas fa-calendar me-1"></i>Enrolled On</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% int i = 1; for (Map<String, String> s : enrolledStudents) { %>
                        <tr>
                            <td><%= i++ %></td>
                            <td><span class="course-badge badge-credits"><%= s.get("studentId") %></span></td>
                            <td><i class="fas fa-user-circle me-1" style="color:#06b6d4;"></i><%= s.get("name") %></td>
                            <td><%= s.get("email") %></td>
                            <td><%= s.get("department") %></td>
                            <td>Sem <%= s.get("semester") %></td>
                            <td><%= s.get("registrationDate") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
        <% } %>

    </div>
</div>

<!-- Add Course Modal -->
<div class="modal fade" id="addCourseModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-plus-circle me-2" style="color:#06b6d4;"></i>Add New Course</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="lecturer-dashboard" method="post">
                <input type="hidden" name="action" value="addCourse">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Course Name *</label>
                            <input type="text" name="courseName" class="form-control" placeholder="e.g. Introduction to Machine Learning" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Total Seats *</label>
                            <input type="number" name="totalSeats" class="form-control" placeholder="e.g. 30" min="1" max="200" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Credits *</label>
                            <select name="credits" class="form-select" required>
                                <option value="">Select Credits</option>
                                <option value="1">1 Credit</option>
                                <option value="2">2 Credits</option>
                                <option value="3">3 Credits</option>
                                <option value="4">4 Credits</option>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Schedule *</label>
                            <input type="text" name="schedule" class="form-control" placeholder="e.g. Mon/Wed 10:00-11:30" required>
                        </div>
                        <div class="col-md-12">
                            <div class="p-3 rounded" style="background:rgba(6,182,212,0.1); border:1px solid rgba(6,182,212,0.2);">
                                <small style="color:#67e8f9;"><i class="fas fa-info-circle me-1"></i>
                                    The course will be added under your department (<strong><%= lecturerDept %></strong>) with your name as instructor.
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn" data-bs-dismiss="modal" style="background:rgba(255,255,255,0.1);color:#fff;">Cancel</button>
                    <button type="submit" class="btn btn-teal"><i class="fas fa-plus me-2"></i>Add Course</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Course Modal -->
<div class="modal fade" id="editCourseModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-edit me-2" style="color:#f59e0b;"></i>Edit Course</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="lecturer-dashboard" method="post">
                <input type="hidden" name="action" value="editCourse">
                <input type="hidden" name="courseId" id="editCourseId">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Course Name *</label>
                            <input type="text" name="courseName" id="editCourseName" class="form-control" placeholder="e.g. Introduction to Machine Learning" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Total Seats *</label>
                            <input type="number" name="totalSeats" id="editTotalSeats" class="form-control" placeholder="e.g. 30" min="1" max="200" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Credits *</label>
                            <select name="credits" id="editCredits" class="form-select" required>
                                <option value="1">1 Credit</option>
                                <option value="2">2 Credits</option>
                                <option value="3">3 Credits</option>
                                <option value="4">4 Credits</option>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Schedule *</label>
                            <input type="text" name="schedule" id="editSchedule" class="form-control" placeholder="e.g. Mon/Wed 10:00-11:30" required>
                        </div>
                        <div class="col-md-12">
                            <div class="p-3 rounded" style="background:rgba(245,158,11,0.1); border:1px solid rgba(245,158,11,0.2);">
                                <small style="color:#fcd34d;"><i class="fas fa-info-circle me-1"></i>
                                    Department and instructor will remain unchanged (<strong><%= lecturerDept %></strong> / <strong><%= lecturerName %></strong>).
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn" data-bs-dismiss="modal" style="background:rgba(255,255,255,0.1);color:#fff;">Cancel</button>
                    <button type="submit" class="btn btn-edit-soft"><i class="fas fa-save me-2"></i>Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openEditModal(courseId, courseName, totalSeats, credits, schedule) {
    document.getElementById('editCourseId').value = courseId;
    document.getElementById('editCourseName').value = courseName;
    document.getElementById('editTotalSeats').value = totalSeats;
    document.getElementById('editSchedule').value = schedule;
    var sel = document.getElementById('editCredits');
    for (var i = 0; i < sel.options.length; i++) {
        if (sel.options[i].value == credits) { sel.selectedIndex = i; break; }
    }
    var modal = new bootstrap.Modal(document.getElementById('editCourseModal'));
    modal.show();
}
</script>
