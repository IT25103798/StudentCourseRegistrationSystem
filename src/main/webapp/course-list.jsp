<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.registration.model.Course" %>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.LecturerDAO" %>
<%@ page import="com.registration.model.Lecturer" %>
<%
    CourseDAO courseDAO = new CourseDAO();
    List<Course> courses = courseDAO.getAllCourses();
    LecturerDAO lecturerDAO = new LecturerDAO();
    List<Lecturer> allLecturers = lecturerDAO.getAllLecturers();

    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String deleteId = request.getParameter("deleteId");
    if (deleteId != null && "admin".equals(role)) {
        courseDAO.deleteCourse(deleteId);
        response.sendRedirect("courses?success=Course+deleted");
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
    <title>Course Management | CourseReg</title>
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
        .course-container { padding: 100px 0 50px; position: relative; z-index: 1; }

        /* Page Header */
        .page-header { margin-bottom: 25px; }
        .page-header h1 { font-size: 1.8rem; font-weight: 700; color: white; }
        .page-header p { color: rgba(255, 255, 255, 0.7); margin-top: 5px; }

        /* Cards */
        .card-section { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(10px); border-radius: 20px; padding: 20px 24px; margin-bottom: 25px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 18px; padding-bottom: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); display: flex; align-items: center; gap: 8px; color: white; }
        .card-title i { color: #a855f7; }

        /* Form Elements */
        .form-label { font-weight: 600; font-size: 0.75rem; margin-bottom: 6px; color: rgba(255, 255, 255, 0.8); }
        .form-control, .form-select { background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 12px; padding: 8px 12px; font-size: 0.85rem; color: white; }
        .form-control:focus, .form-select:focus { border-color: #a855f7; outline: none; box-shadow: 0 0 0 2px rgba(168, 85, 247, 0.2); }
        .form-control::placeholder { color: rgba(255, 255, 255, 0.4); }
        .form-select option { background: #1e1b4b; }

        /* Buttons */
        .btn-primary-custom { background: linear-gradient(135deg, #a855f7, #7c3aed); border: none; padding: 8px 20px; border-radius: 40px; font-weight: 500; font-size: 0.8rem; color: white; }
        .btn-primary-custom:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(168, 85, 247, 0.3); }
        .btn-secondary-custom { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); padding: 8px 20px; border-radius: 40px; font-weight: 500; font-size: 0.8rem; color: white; }
        .btn-secondary-custom:hover { background: rgba(255, 255, 255, 0.2); }

        /* Table */
        .courses-table { width: 100%; border-collapse: collapse; font-size: 0.8rem; }
        .courses-table th { background: rgba(255, 255, 255, 0.08); padding: 10px 10px; font-weight: 600; color: rgba(255, 255, 255, 0.9); border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
        .courses-table td { padding: 10px 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); vertical-align: middle; color: rgba(255, 255, 255, 0.8); }
        .courses-table tr:hover { background: rgba(255, 255, 255, 0.03); }

        /* Badges */
        .badge-available { background: rgba(16, 185, 129, 0.2); color: #6ee7b7; padding: 3px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .badge-full { background: rgba(239, 68, 68, 0.2); color: #fca5a5; padding: 3px 10px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .badge-credits { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; padding: 3px 8px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }
        .badge-dept { background: rgba(245, 158, 11, 0.2); color: #fcd34d; padding: 3px 8px; border-radius: 30px; font-size: 0.7rem; font-weight: 500; }

        /* Action Buttons */
        .btn-edit { background: #f59e0b; color: white; border: none; padding: 4px 10px; border-radius: 6px; font-size: 0.7rem; margin: 0 2px; }
        .btn-edit:hover { background: #d97706; }
        .btn-delete { background: #ef4444; color: white; border: none; padding: 4px 10px; border-radius: 6px; font-size: 0.7rem; margin: 0 2px; }
        .btn-delete:hover { background: #dc2626; }

        /* Empty State */
        .empty-state { text-align: center; padding: 50px; color: rgba(255, 255, 255, 0.6); }
        .empty-state i { font-size: 3rem; color: rgba(255, 255, 255, 0.3); margin-bottom: 15px; }

        /* Alerts */
        .alert-success { background: rgba(16, 185, 129, 0.15); border-left: 4px solid #10b981; color: #6ee7b7; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }
        .alert-danger { background: rgba(239, 68, 68, 0.15); border-left: 4px solid #ef4444; color: #fca5a5; padding: 10px 15px; border-radius: 12px; margin-bottom: 20px; font-size: 0.85rem; }

        /* Modal */
        .modal-custom .modal-content { background: rgba(15, 12, 41, 0.95); backdrop-filter: blur(20px); border-radius: 20px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .modal-custom .modal-header { background: linear-gradient(135deg, #a855f7, #7c3aed); border-radius: 20px 20px 0 0; padding: 15px 20px; border: none; }
        .modal-custom .modal-header .btn-close { filter: brightness(0) invert(1); }
        .modal-custom .modal-footer .btn-secondary { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; }

        /* Footer */
        footer { background: rgba(0, 0, 0, 0.4); padding: 40px 0 20px; margin-top: 40px; border-top: 1px solid rgba(255, 255, 255, 0.1); }
        .footer-brand { font-size: 1.3rem; font-weight: 800; margin-bottom: 12px; display: inline-block; background: linear-gradient(135deg, #fff, #a855f7); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .footer-links a { color: rgba(255, 255, 255, 0.6); text-decoration: none; display: block; padding: 4px 0; font-size: 0.8rem; transition: 0.3s; }
        .footer-links a:hover { color: #a855f7; }
        .copyright { text-align: center; padding-top: 25px; margin-top: 25px; border-top: 1px solid rgba(255, 255, 255, 0.08); color: rgba(255, 255, 255, 0.5); font-size: 0.75rem; }

        @media (max-width: 768px) { .course-container { padding: 120px 0 40px; } .courses-table { font-size: 0.7rem; } .card-section { padding: 15px; } .blob { display: none; } }
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
        <a class="navbar-brand" href="<%= "admin".equals(role) ? "admin" : "student-dashboard.jsp" %>">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <% if("admin".equals(role)) { %>
                    <li class="nav-item"><a class="nav-link" href="admin">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link active" href="courses">Courses</a></li>
                    <li class="nav-item"><a class="nav-link" href="admin?action=queue">Queue</a></li>
                    <li class="nav-item"><a class="nav-link" href="manage-students.jsp">Students</a></li>
                    <li class="nav-item"><a class="nav-link" href="manage-lecturers">Lecturers</a></li>
                    <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                    <li class="nav-item"><a class="nav-link" href="admin-feedback.jsp">Feedback</a></li>
                <% } else { %>
                    <li class="nav-item"><a class="nav-link" href="student-dashboard.jsp">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="student-courses.jsp">My Courses</a></li>
                    <li class="nav-item"><a class="nav-link" href="register-course">Register</a></li>
                    <li class="nav-item"><a class="nav-link" href="queue-status">Queue</a></li>
                <% } %>
                <li class="nav-item"><a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="course-container">
    <div class="container">

        <!-- Page Header -->
        <div class="page-header d-flex justify-content-between align-items-center">
            <div><h1><i class="fas fa-book me-2" style="color: #a855f7;"></i>Course Management</h1><p>Browse, add, edit, and manage all courses</p></div>
            <% if("admin".equals(role)) { %>
                <button class="btn btn-primary-custom" data-bs-toggle="modal" data-bs-target="#addCourseModal"><i class="fas fa-plus me-2"></i>Add Course</button>
            <% } %>
        </div>

        <!-- Alerts -->
        <% if(successMsg != null) { %><div class="alert-success"><i class="fas fa-check-circle me-2"></i> <%= successMsg %></div><% } %>
        <% if(errorMsg != null) { %><div class="alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> <%= errorMsg %></div><% } %>

        <!-- Search & Filter -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-filter"></i> Search & Filter Courses</div>
            <form method="get" action="courses" class="row g-3">
                <div class="col-md-5">
                    <div class="form-label">Search</div>
                    <div class="d-flex gap-2">
                        <input type="text" name="keyword" class="form-control" placeholder="Course name or instructor...">
                        <input type="hidden" name="action" value="search">
                        <button class="btn btn-primary-custom" type="submit"><i class="fas fa-search me-1"></i> Search</button>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-label">Sort By</div>
                    <select name="sortBy" class="form-select" onchange="this.form.submit()">
                        <option value="">Default</option>
                        <option value="demand">📊 Low Seats First</option>
                        <option value="name">📖 Name (A-Z)</option>
                    </select>
                    <input type="hidden" name="action" value="sorted">
                </div>
                <div class="col-md-3">
                    <div class="form-label">&nbsp;</div>
                    <a href="courses" class="btn btn-secondary-custom w-100"><i class="fas fa-sync-alt me-1"></i> Reset</a>
                </div>
            </form>
        </div>

        <!-- Courses Table -->
        <div class="card-section">
            <div class="card-title"><i class="fas fa-table-list"></i> All Courses <span class="badge bg-primary ms-2" style="background: rgba(168,85,247,0.3); color: #d8b4fe;"><%= courses.size() %> courses</span></div>
            <div class="table-responsive">
                <table class="courses-table">
                    <thead>
                        <tr>
                            <th>ID</th><th>Course Name</th><th>Department</th><th>Instructor</th>
                            <th>Credits</th><th>Seats</th><th>Available</th><th>Schedule</th><th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if(courses.isEmpty()) { %>
                            <td><td colspan="10" class="empty-state">
                                <i class="fas fa-info-circle"></i>
                                <h6>No courses found</h6>
                                <button class="btn btn-primary-custom mt-2" data-bs-toggle="modal" data-bs-target="#addCourseModal"><i class="fas fa-plus"></i> Add Course</button>
                              </td>
                        <% } else {
                            for(Course course : courses) {
                                boolean available = course.getAvailableSeats() > 0;
                                String dept = course.getDepartment();
                                if(dept == null || dept.isEmpty()) dept = "General";
                        %>
                            <tr>
                                <td><strong><%= course.getCourseId() %></strong></td>
                                <td><%= course.getCourseName() %></td>
                                <td><span class="badge-dept"><%= dept %></span></td>
                                <td><%= course.getInstructor() %></td>
                                <td><span class="badge-credits"><%= course.getCredits() %></span></td>
                                <td><%= course.getTotalSeats() %></td>
                                <td><%= course.getAvailableSeats() %></td>
                                <td><small><%= course.getSchedule() %></small></td>
                                <td><% if(available) { %><span class="badge-available">Available</span><% } else { %><span class="badge-full">Full</span><% } %></td>
                                <td>
                                    <button class="btn-edit" onclick='editCourse("<%= course.getCourseId() %>","<%= course.getCourseName() %>","<%= dept %>","<%= course.getInstructor() %>",<%= course.getTotalSeats() %>,<%= course.getCredits() %>,"<%= course.getSchedule() %>")'><i class="fas fa-edit"></i> Edit</button>
                                    <button class="btn-delete" onclick="confirmDelete('<%= course.getCourseId() %>','<%= course.getCourseName() %>')"><i class="fas fa-trash"></i> Delete</button>
                                  </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Course Modal -->
<div class="modal fade modal-custom" id="addCourseModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-plus-circle me-2"></i>Add Course</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="courses" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-body p-4">
                    <div class="mb-3"><label class="form-label">Course Name</label><input type="text" name="courseName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Department</label><select name="department" class="form-select" required><option value="">Select</option><option>Computer Science</option><option>Information Technology</option><option>Software Engineering</option><option>Data Science</option><option>Cyber Security</option><option>General</option></select></div>
                    <div class="mb-3"><label class="form-label">Instructor</label>
                        <select name="instructor" class="form-select" required>
                            <option value="">-- Select Lecturer --</option>
                            <% for(Lecturer lec : allLecturers) { if("active".equals(lec.getStatus())) { %>
                                <option value="<%= lec.getName() %>"><%= lec.getName() %> &mdash; <%= lec.getDepartment() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="row"><div class="col-md-6 mb-3"><label class="form-label">Total Seats</label><input type="number" name="totalSeats" class="form-control" required></div><div class="col-md-6 mb-3"><label class="form-label">Credits</label><input type="number" name="credits" class="form-control" required></div></div>
                    <div class="mb-3"><label class="form-label">Schedule</label><input type="text" name="schedule" class="form-control" placeholder="Mon/Wed 10:00-11:30" required></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Add Course</button></div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Course Modal -->
<div class="modal fade modal-custom" id="editCourseModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Course</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <form action="courses" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="courseId" id="editCourseId">
                <div class="modal-body p-4">
                    <div class="mb-3"><label class="form-label">Course Name</label><input type="text" name="courseName" id="editCourseName" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Department</label><select name="department" id="editDepartment" class="form-select" required><option>Computer Science</option><option>Information Technology</option><option>Software Engineering</option><option>Data Science</option><option>Cyber Security</option><option>General</option></select></div>
                    <div class="mb-3"><label class="form-label">Instructor</label>
                        <select name="instructor" id="editInstructor" class="form-select" required>
                            <option value="">-- Select Lecturer --</option>
                            <% for(Lecturer lec : allLecturers) { if("active".equals(lec.getStatus())) { %>
                                <option value="<%= lec.getName() %>"><%= lec.getName() %> &mdash; <%= lec.getDepartment() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="row"><div class="col-md-6 mb-3"><label class="form-label">Total Seats</label><input type="number" name="totalSeats" id="editTotalSeats" class="form-control" required></div><div class="col-md-6 mb-3"><label class="form-label">Credits</label><input type="number" name="credits" id="editCredits" class="form-control" required></div></div>
                    <div class="mb-3"><label class="form-label">Schedule</label><input type="text" name="schedule" id="editSchedule" class="form-control" required></div>
                </div>
                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary-custom">Update Course</button></div>
            </form>
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
<script>
    function editCourse(id,name,dept,instructor,seats,credits,schedule){
        document.getElementById('editCourseId').value=id;
        document.getElementById('editCourseName').value=name;
        document.getElementById('editDepartment').value=dept;
        var sel=document.getElementById('editInstructor'); for(var i=0;i<sel.options.length;i++){ if(sel.options[i].value===instructor){sel.selectedIndex=i;break;} }
        document.getElementById('editTotalSeats').value=seats;
        document.getElementById('editCredits').value=credits;
        document.getElementById('editSchedule').value=schedule;
        new bootstrap.Modal(document.getElementById('editCourseModal')).show();
    }
    function confirmDelete(id,name){
        if(confirm('Delete "'+name+'"? This cannot be undone.')){
            window.location.href='courses?deleteId='+id;
        }
    }
</script>
</body>
</html>
