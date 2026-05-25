<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.dao.CourseDAO" %>
<%@ page import="com.registration.dao.RegistrationDAO" %>
<%@ page import="com.registration.dao.FeedbackDAO" %>
<%@ page import="com.registration.model.Course" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Registration" %>
<%@ page import="com.registration.model.Feedback" %>
<%@ page import="java.util.*" %>
<%
    // Get session attributes
    Student student = (Student) session.getAttribute("user");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    // Redirect if not logged in
    if (username == null || student == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialize DAOs
    CourseDAO courseDAO = new CourseDAO();
    RegistrationDAO registrationDAO = new RegistrationDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();

    // Get student's registered courses
    List<Registration> myRegistrations = registrationDAO.getRegistrationsByStudent(student.getId());
    Map<String, Registration> registrationMap = new HashMap<>();
    for (Registration reg : myRegistrations) {
        registrationMap.put(reg.getCourseId(), reg);
    }

    // Get registered courses details
    List<Course> registeredCourses = new ArrayList<>();
    for (Registration reg : myRegistrations) {
        Course c = courseDAO.findCourseById(reg.getCourseId());
        if (c != null) {
            registeredCourses.add(c);
        }
    }

    // Get user's existing feedback
    List<Feedback> userFeedbacks = feedbackDAO.getFeedbacksByStudent(student.getId());
    Set<String> feedbackCourseIds = new HashSet<>();
    Map<String, Feedback> feedbackMap = new HashMap<>();
    for (Feedback f : userFeedbacks) {
        feedbackCourseIds.add(f.getCourseId());
        feedbackMap.put(f.getCourseId(), f);
    }

    // Calculate statistics
    int registeredCount = registeredCourses.size();
    int totalCredits = 0;
    for (Course c : registeredCourses) {
        totalCredits += c.getCredits();
    }

    // Get student's pending queue requests count
    List<com.registration.model.RegistrationRequest> queueRequests = registrationDAO.getQueueStatus();
    int queuedCount = 0;
    for (com.registration.model.RegistrationRequest req : queueRequests) {
        if (req.getStudentId().equals(student.getId())) {
            queuedCount++;
        }
    }

    String currentPage = request.getRequestURI();
    String feedbackMsg = request.getParameter("feedback");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses | CourseReg</title>
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
            background: #0f0c29;
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
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
            animation: float 6s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }

        .blob-1 { top: 10%; left: -5%; }
        .blob-2 { bottom: 0; right: -5%; width: 500px; height: 500px; background: linear-gradient(135deg, #06b6d4, #3b82f6); animation-delay: -2s; }
        .blob-3 { top: 50%; left: 30%; width: 300px; height: 300px; background: linear-gradient(135deg, #f59e0b, #ef4444); animation-delay: -4s; opacity: 0.2; }

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
            padding: 8px 22px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.85rem;
            transition: all 0.3s;
            margin-left: 8px;
        }

        .btn-logout:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(239, 68, 68, 0.3);
        }

        /* Main Container */
        .courses-container {
            padding: 100px 0 50px;
            position: relative;
            z-index: 1;
        }

        /* Header Card */
        .header-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border-radius: 28px;
            padding: 32px 36px;
            color: white;
            margin-bottom: 35px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .header-card h1 {
            font-size: 2rem;
            font-weight: 700;
        }

        /* Stat Cards */
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
            min-width: 150px;
            text-align: center;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.1);
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
            line-height: 1;
        }

        .stat-label {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.8rem;
            font-weight: 500;
            margin-top: 6px;
        }

        /* Course Card */
        .course-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px;
            padding: 22px;
            transition: all 0.3s;
            height: 100%;
            position: relative;
        }

        .course-card:hover {
            transform: translateY(-5px);
            background: rgba(255, 255, 255, 0.08);
            border-color: rgba(168, 85, 247, 0.3);
        }

        .course-badge {
            position: absolute;
            top: 16px;
            right: 16px;
        }

        .course-card h4 {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 8px;
            padding-right: 70px;
            color: white;
        }

        /* Buttons */
        .btn-primary-custom {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            border: none;
            padding: 8px 20px;
            border-radius: 40px;
            font-weight: 600;
            font-size: 0.8rem;
            transition: all 0.3s;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(168, 85, 247, 0.4);
        }

        .btn-feedback {
            background: #f59e0b;
            color: white;
            border: none;
            padding: 6px 15px;
            border-radius: 30px;
            font-weight: 500;
            font-size: 0.7rem;
            transition: all 0.3s;
        }

        .btn-feedback:hover {
            background: #d97706;
            transform: translateY(-1px);
        }

        .btn-feedback-submitted {
            background: #10b981;
            color: white;
            border: none;
            padding: 6px 15px;
            border-radius: 30px;
            font-weight: 500;
            font-size: 0.7rem;
            cursor: default;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 24px;
        }

        .empty-state i {
            font-size: 4rem;
            color: rgba(255, 255, 255, 0.3);
            margin-bottom: 20px;
        }

        /* Alert */
        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            border-left: 4px solid #10b981;
            color: #6ee7b7;
            padding: 12px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.15);
            border-left: 4px solid #ef4444;
            color: #fca5a5;
            padding: 12px 20px;
            border-radius: 12px;
            margin-bottom: 20px;
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

        @media (max-width: 768px) {
            .courses-container { padding: 120px 0 40px; }
            .header-card h1 { font-size: 1.5rem; }
            .header-card { padding: 24px; }
            .stats-row { flex-direction: column; }
            .course-card h4 { font-size: 1.1rem; }
            .blob { display: none; }
        }
    </style>
</head>
<body>

<!-- Animated Background Blobs -->
<div class="blob blob-1"></div>
<div class="blob blob-2"></div>
<div class="blob blob-3"></div>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg fixed-top" id="navbar">
    <div class="container">
        <a class="navbar-brand" href="student-dashboard.jsp">Course<span>Reg</span></a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item"><a class="nav-link" href="student-dashboard.jsp">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link active" href="student-courses.jsp">My Courses</a></li>
                <li class="nav-item"><a class="nav-link" href="register-course">Register</a></li>
                <li class="nav-item"><a class="nav-link" href="queue-status">Queue Status</a></li>
                <li class="nav-item"><a class="nav-link" href="profile-settings.jsp"><i class="fas fa-user-pen me-1"></i>Profile</a></li>
                <li class="nav-item">
                    <a class="btn-logout" href="logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Feedback Modal -->
<div class="modal fade" id="feedbackModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" style="background: rgba(15, 12, 41, 0.95); backdrop-filter: blur(20px); border-radius: 20px; border: 1px solid rgba(255,255,255,0.1);">
            <div class="modal-header" style="background: linear-gradient(135deg, #a855f7, #7c3aed); color: white; border-radius: 20px 20px 0 0;">
                <h5 class="modal-title"><i class="fas fa-star me-2"></i>Course Feedback</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="submit-feedback" method="post">
                <input type="hidden" name="courseId" id="feedbackCourseId">
                <input type="hidden" name="courseName" id="feedbackCourseName">
                <div class="modal-body p-4">
                    <div class="text-center mb-3">
                        <h5 id="modalCourseName" class="mb-2" style="color: white;">Course Name</h5>
                        <div class="rating-stars mb-3">
                            <i class="far fa-star fa-2x star" data-value="1"></i>
                            <i class="far fa-star fa-2x star" data-value="2"></i>
                            <i class="far fa-star fa-2x star" data-value="3"></i>
                            <i class="far fa-star fa-2x star" data-value="4"></i>
                            <i class="far fa-star fa-2x star" data-value="5"></i>
                        </div>
                        <input type="hidden" name="rating" id="ratingValue" required>
                        <div class="mb-3">
                            <label class="form-label fw-semibold" style="color: rgba(255,255,255,0.8);">Your Feedback</label>
                            <textarea name="comment" class="form-control" rows="4" placeholder="Share your experience with this course..." style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: white;" required></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: white;">Cancel</button>
                    <button type="submit" class="btn btn-primary" style="background: linear-gradient(135deg, #a855f7, #7c3aed); border: none;">Submit Feedback</button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .star {
        cursor: pointer;
        margin: 0 5px;
        transition: all 0.3s;
        color: rgba(255, 255, 255, 0.5);
    }
    .star:hover, .star.active {
        color: #f59e0b;
    }
</style>

<script>
    // Star rating functionality
    document.querySelectorAll('.star').forEach(star => {
        star.addEventListener('click', function() {
            let value = this.getAttribute('data-value');
            document.getElementById('ratingValue').value = value;

            document.querySelectorAll('.star').forEach(s => {
                if(s.getAttribute('data-value') <= value) {
                    s.classList.remove('far');
                    s.classList.add('fas');
                    s.classList.add('active');
                } else {
                    s.classList.remove('fas');
                    s.classList.add('far');
                    s.classList.remove('active');
                }
            });
        });
    });

    function openFeedbackModal(courseId, courseName) {
        document.getElementById('feedbackCourseId').value = courseId;
        document.getElementById('feedbackCourseName').value = courseName;
        document.getElementById('modalCourseName').innerText = courseName;
        document.getElementById('ratingValue').value = '';

        // Reset stars
        document.querySelectorAll('.star').forEach(s => {
            s.classList.remove('fas', 'active');
            s.classList.add('far');
        });

        new bootstrap.Modal(document.getElementById('feedbackModal')).show();
    }
</script>

<!-- Main Content -->
<div class="courses-container">
    <div class="container">

        <!-- Alert for feedback submission -->
        <% if("success".equals(feedbackMsg)) { %>
            <div class="alert-success"><i class="fas fa-check-circle me-2"></i> Thank you! Your feedback has been submitted.</div>
        <% } else if("updated".equals(feedbackMsg)) { %>
            <div class="alert-success"><i class="fas fa-check-circle me-2"></i> Your review has been updated successfully.</div>
        <% } else if("error".equals(feedbackMsg)) { %>
            <div class="alert-danger"><i class="fas fa-exclamation-triangle me-2"></i> Failed to submit feedback. Please try again.</div>
        <% } %>

        <!-- Header -->
        <div class="header-card">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="fw-bold mb-2"><i class="fas fa-book-open me-3"></i>My Registered Courses</h1>
                    <p class="mb-0 opacity-75">View all your approved and enrolled courses</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <span class="badge bg-white text-dark px-3 py-2 rounded-pill">
                        <i class="fas fa-user-graduate me-1"></i> <%= student.getDepartment() %> - Sem <%= student.getSemester() %>
                    </span>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-number"><%= registeredCount %></div>
                <div class="stat-label">Registered Courses</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= totalCredits %></div>
                <div class="stat-label">Total Credits</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= queuedCount %></div>
                <div class="stat-label">In Queue</div>
            </div>
        </div>

        <!-- Registered Courses Grid -->
        <% if(registeredCourses.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-book-open"></i>
                <h4 class="fw-semibold">No Registered Courses</h4>
                <p class="mb-4">You haven't registered for any courses yet.</p>
                <a href="register-course" class="btn btn-primary-custom text-white text-decoration-none">
                    <i class="fas fa-plus-circle me-2"></i> Register for a Course
                </a>
            </div>
        <% } else { %>
            <div class="row g-4">
                <% for(Course course : registeredCourses) {
                    Registration reg = registrationMap.get(course.getCourseId());
                    boolean hasFeedback = feedbackCourseIds.contains(course.getCourseId());
                    Feedback existingFeedback = hasFeedback ? feedbackMap.get(course.getCourseId()) : null;
                %>
                    <div class="col-md-6 col-lg-4">
                        <div class="course-card">
                            <div class="course-badge">
                                <span class="badge bg-success rounded-pill px-3 py-2"><i class="fas fa-check-circle me-1"></i> Approved</span>
                            </div>
                            <h4 class="mb-2"><%= course.getCourseName() %></h4>
                            <p class="small mb-3" style="color: rgba(255,255,255,0.6);"><i class="fas fa-code me-1"></i> <%= course.getCourseId() %></p>
                            <hr class="my-3" style="border-color: rgba(255,255,255,0.1);">
                            <div class="mb-2">
                                <i class="fas fa-chalkboard-user me-2" style="color: #a855f7; width: 20px;"></i>
                                <strong style="color: rgba(255,255,255,0.9);">Instructor:</strong> <span style="color: rgba(255,255,255,0.7);"><%= course.getInstructor() %></span>
                            </div>
                            <div class="mb-2">
                                <i class="fas fa-star me-2" style="color: #f59e0b; width: 20px;"></i>
                                <strong style="color: rgba(255,255,255,0.9);">Credits:</strong> <span style="color: rgba(255,255,255,0.7);"><%= course.getCredits() %></span>
                            </div>
                            <div class="mb-2">
                                <i class="fas fa-calendar-week me-2" style="color: #10b981; width: 20px;"></i>
                                <strong style="color: rgba(255,255,255,0.9);">Schedule:</strong> <span style="color: rgba(255,255,255,0.7);"><%= course.getSchedule() %></span>
                            </div>
                            <div class="mb-3">
                                <i class="fas fa-chair me-2" style="color: #ef4444; width: 20px;"></i>
                                <strong style="color: rgba(255,255,255,0.9);">Seats:</strong> <span style="color: rgba(255,255,255,0.7);"><%= course.getAvailableSeats() %> / <%= course.getTotalSeats() %></span>
                            </div>
                            <hr class="my-3" style="border-color: rgba(255,255,255,0.1);">
                            <div class="text-center">
                                <span class="badge bg-success rounded-pill px-3 py-2 mb-2">
                                    <i class="fas fa-check-circle me-1"></i> Enrolled
                                </span>
                                <small class="d-block mt-2" style="color: rgba(255,255,255,0.5);">
                                    <i class="fas fa-calendar-alt me-1"></i> Registered: <%= reg.getRegistrationDate() %>
                                </small>
                                <% if(hasFeedback && existingFeedback != null && "approved".equals(existingFeedback.getStatus())) { %>
                                    <div class="mt-2">
                                        <span class="badge bg-info">⭐ Your Rating: <%= existingFeedback.getRating() %>/5</span>
                                    </div>
                                <% } %>
                                <div class="mt-3">
                                    <% if(hasFeedback) { %>
                                        <button class="btn-feedback-submitted" disabled>
                                            <i class="fas fa-check-circle me-1"></i> Feedback Submitted
                                        </button>
                                        <button class="btn-feedback ms-2" style="background:rgba(245,158,11,0.3); border-color:rgba(245,158,11,0.5);"
                                            onclick="openEditFeedbackModal('<%= existingFeedback.getFeedbackId() %>','<%= course.getCourseId() %>','<%= course.getCourseName().replace("'","\\x27") %>',<%= existingFeedback.getRating() %>,'<%= existingFeedback.getComment().replace("'","\\x27").replace("\n"," ") %>')">
                                            <i class="fas fa-edit me-1"></i> Edit Review
                                        </button>
                                    <% } else { %>
                                        <button class="btn-feedback" onclick="openFeedbackModal('<%= course.getCourseId() %>', '<%= course.getCourseName() %>')">
                                            <i class="fas fa-star me-1"></i> Rate this Course
                                        </button>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

        <!-- Info Card -->
        <div class="mt-5">
            <div class="card border-0 rounded-4 overflow-hidden" style="background: linear-gradient(135deg, #a855f7, #7c3aed);">
                <div class="card-body p-4 text-white">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h5 class="mb-2"><i class="fas fa-info-circle me-2"></i> Course Registration Information</h5>
                            <p class="mb-0 small opacity-75">These are your approved and enrolled courses. Rate your courses to help other students make better decisions!</p>
                        </div>
                        <div class="col-md-4 text-md-end mt-3 mt-md-0">
                            <a href="register-course" class="btn btn-light rounded-pill px-4" style="background: rgba(255,255,255,0.2); border: 1px solid rgba(255,255,255,0.3); color: white;">
                                <i class="fas fa-plus-circle me-2"></i> Register More
                            </a>
                        </div>
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
            <div class="col-md-4 mb-4">
                <div class="footer-brand">Course<span>Reg</span></div>
                <p class="text-white-50 small">Smart course registration for modern education.</p>
            </div>
            <div class="col-md-2 col-6 mb-4 footer-links">
                <h6 class="text-white mb-3">Quick Links</h6>
                <a href="student-dashboard.jsp">Dashboard</a>
                <a href="student-courses.jsp">My Courses</a>
                <a href="register-course">Register</a>
            </div>
            <div class="col-md-2 col-6 mb-4 footer-links">
                <h6 class="text-white mb-3">Support</h6>
                <a href="#">Help Center</a>
                <a href="#">Contact Us</a>
                <a href="#">FAQs</a>
            </div>
            <div class="col-md-4 mb-4 footer-links">
                <h6 class="text-white mb-3">Connect</h6>
                <div class="d-flex gap-3">
                    <a href="#"><i class="fab fa-twitter fa-lg"></i></a>
                    <a href="#"><i class="fab fa-linkedin fa-lg"></i></a>
                    <a href="#"><i class="fab fa-github fa-lg"></i></a>
                    <a href="#"><i class="fab fa-facebook fa-lg"></i></a>
                </div>
            </div>
        </div>
        <div class="copyright">
            <p>&copy; 2024 CourseReg. All rights reserved. | FIFO Queue | Insertion Sort | File Handling | OOP Concepts</p>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.addEventListener('scroll', function() {
        const navbar = document.getElementById('navbar');
        if (window.scrollY > 50) navbar.classList.add('scrolled');
        else navbar.classList.remove('scrolled');
    });
</script>

<!-- Edit Feedback Modal -->
<div class="modal fade" id="editFeedbackModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="background:rgba(15,12,41,0.97); backdrop-filter:blur(20px); border-radius:20px; border:1px solid rgba(255,255,255,0.1);">
            <div class="modal-header" style="background:linear-gradient(135deg,#f59e0b,#d97706); color:white; border-radius:20px 20px 0 0;">
                <h5 class="modal-title"><i class="fas fa-edit me-2"></i>Edit Your Review</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="update-feedback" method="post">
                <input type="hidden" name="feedbackId" id="editFeedbackId">
                <input type="hidden" name="courseId" id="editFeedbackCourseId">
                <div class="modal-body p-4">
                    <div class="text-center mb-3">
                        <h5 id="editModalCourseName" class="mb-2" style="color:white;"></h5>
                        <div class="rating-stars mb-3" id="editStarsContainer">
                            <i class="far fa-star fa-2x edit-star" data-value="1"></i>
                            <i class="far fa-star fa-2x edit-star" data-value="2"></i>
                            <i class="far fa-star fa-2x edit-star" data-value="3"></i>
                            <i class="far fa-star fa-2x edit-star" data-value="4"></i>
                            <i class="far fa-star fa-2x edit-star" data-value="5"></i>
                        </div>
                        <input type="hidden" name="rating" id="editRatingValue" required>
                        <div class="mb-3">
                            <label class="form-label fw-semibold" style="color:rgba(255,255,255,0.8);">Your Updated Review</label>
                            <textarea name="comment" id="editComment" class="form-control" rows="4" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.2); color:white;" required></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.2); color:white;">Cancel</button>
                    <button type="submit" class="btn btn-warning" style="background:linear-gradient(135deg,#f59e0b,#d97706); border:none; color:white; font-weight:600;">
                        <i class="fas fa-save me-1"></i>Update Review
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Edit feedback stars
var editSelectedRating = 0;
document.querySelectorAll('.edit-star').forEach(function(star) {
    star.addEventListener('click', function() {
        editSelectedRating = parseInt(this.dataset.value);
        document.getElementById('editRatingValue').value = editSelectedRating;
        document.querySelectorAll('.edit-star').forEach(function(s, idx) {
            s.classList.toggle('fas', idx < editSelectedRating);
            s.classList.toggle('far', idx >= editSelectedRating);
            s.style.color = idx < editSelectedRating ? '#f59e0b' : 'rgba(255,255,255,0.5)';
        });
    });
    star.style.color = 'rgba(255,255,255,0.5)';
    star.style.cursor = 'pointer';
    star.style.margin = '0 5px';
});

function openEditFeedbackModal(feedbackId, courseId, courseName, currentRating, currentComment) {
    document.getElementById('editFeedbackId').value = feedbackId;
    document.getElementById('editFeedbackCourseId').value = courseId;
    document.getElementById('editModalCourseName').textContent = courseName;
    document.getElementById('editComment').value = currentComment;
    editSelectedRating = currentRating;
    document.getElementById('editRatingValue').value = currentRating;
    document.querySelectorAll('.edit-star').forEach(function(s, idx) {
        s.classList.toggle('fas', idx < currentRating);
        s.classList.toggle('far', idx >= currentRating);
        s.style.color = idx < currentRating ? '#f59e0b' : 'rgba(255,255,255,0.5)';
    });
    new bootstrap.Modal(document.getElementById('editFeedbackModal')).show();
}
</script>
</body>
</html>
