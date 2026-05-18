package com.registration.servlet;

import com.registration.dao.CourseDAO;
import com.registration.dao.LecturerDAO;
import com.registration.dao.RegistrationDAO;
import com.registration.dao.UserDAO;
import com.registration.model.Course;
import com.registration.model.Lecturer;
import com.registration.model.LecturerUser;
import com.registration.model.Registration;
import com.registration.model.Student;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/lecturer-dashboard")
public class LecturerDashboardServlet extends HttpServlet {

    private CourseDAO courseDAO = new CourseDAO();
    private LecturerDAO lecturerDAO = new LecturerDAO();
    private RegistrationDAO registrationDAO = new RegistrationDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (!"lecturer".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        LecturerUser lecturerUser = (LecturerUser) session.getAttribute("user");
        String lecturerId = lecturerUser.getLecturerId();
        Lecturer lecturer = lecturerDAO.getLecturerById(lecturerId);
        request.setAttribute("lecturer", lecturer);

        String action = request.getParameter("action");

        if ("viewStudents".equals(action)) {
            // View enrolled students for a specific course
            String courseId = request.getParameter("courseId");
            Course course = courseDAO.findCourseById(courseId);
            if (course != null) {
                List<Registration> registrations = registrationDAO.getRegistrationsByCourse(courseId);
                List<Map<String, String>> enrolledStudents = new ArrayList<>();
                for (Registration reg : registrations) {
                    if ("approved".equals(reg.getStatus())) {
                        Student student = userDAO.findStudentById(reg.getStudentId());
                        if (student != null) {
                            Map<String, String> info = new HashMap<>();
                            info.put("studentId", student.getStudentId());
                            info.put("name", student.getUsername());
                            info.put("email", student.getEmail());
                            info.put("department", student.getDepartment());
                            info.put("semester", String.valueOf(student.getSemester()));
                            info.put("registrationDate", reg.getRegistrationDate().toString().substring(0, 10));
                            enrolledStudents.add(info);
                        }
                    }
                }
                request.setAttribute("enrolledStudents", enrolledStudents);
                request.setAttribute("selectedCourse", course);
            }
        }

        // Load courses taught by this lecturer (matched by name in instructor field)
        List<Course> allCourses = courseDAO.getAllCourses();
        List<Course> myCourses = new ArrayList<>();
        if (lecturer != null) {
            for (Course c : allCourses) {
                if (lecturer.getName().equalsIgnoreCase(c.getInstructor())) {
                    myCourses.add(c);
                }
            }
        }
        // Build accurate enrolled counts from actual registration records (not seat math)
        Map<String, Integer> enrolledCounts = new HashMap<>();
        for (Course c : myCourses) {
            List<Registration> regs = registrationDAO.getRegistrationsByCourse(c.getCourseId());
            int count = 0;
            for (Registration r : regs) {
                if ("approved".equals(r.getStatus())) count++;
            }
            enrolledCounts.put(c.getCourseId(), count);
        }

        request.setAttribute("myCourses", myCourses);
        request.setAttribute("allCourses", allCourses);
        request.setAttribute("enrolledCounts", enrolledCounts);

        request.getRequestDispatcher("lecturer-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (!"lecturer".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("addCourse".equals(action)) {
            LecturerUser lecturerUser = (LecturerUser) session.getAttribute("user");
            String lecturerId = lecturerUser.getLecturerId();
            Lecturer lecturer = lecturerDAO.getLecturerById(lecturerId);

            String courseId = courseDAO.generateCourseId();
            String courseName = request.getParameter("courseName");
            String department = (lecturer != null) ? lecturer.getDepartment() : request.getParameter("department");
            String instructor = (lecturer != null) ? lecturer.getName() : request.getParameter("instructor");
            int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
            int credits = Integer.parseInt(request.getParameter("credits"));
            String schedule = request.getParameter("schedule");

            Course course = new Course();
            course.setCourseId(courseId);
            course.setCourseName(courseName);
            course.setDepartment(department);
            course.setInstructor(instructor);
            course.setTotalSeats(totalSeats);
            course.setAvailableSeats(totalSeats);
            course.setCredits(credits);
            course.setSchedule(schedule);

            boolean added = courseDAO.addCourse(course);
            if (added) {
                response.sendRedirect("lecturer-dashboard?success=Course+added+successfully");
            } else {
                response.sendRedirect("lecturer-dashboard?error=Failed+to+add+course");
            }

        } else if ("editCourse".equals(action)) {
            String courseId = request.getParameter("courseId");
            LecturerUser lecturerUser = (LecturerUser) session.getAttribute("user");
            Lecturer lecturer = lecturerDAO.getLecturerById(lecturerUser.getLecturerId());
            Course course = courseDAO.findCourseById(courseId);

            // Security: only allow editing courses taught by this lecturer
            if (course != null && lecturer != null &&
                    lecturer.getName().equalsIgnoreCase(course.getInstructor())) {

                String courseName = request.getParameter("courseName");
                int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
                int credits = Integer.parseInt(request.getParameter("credits"));
                String schedule = request.getParameter("schedule");

                course.setCourseName(courseName);
                course.setTotalSeats(totalSeats);
                course.setCredits(credits);
                course.setSchedule(schedule);
                // Department and instructor stay locked to the lecturer's own values
                course.setDepartment(lecturer.getDepartment());
                course.setInstructor(lecturer.getName());

                boolean updated = courseDAO.updateCourse(course);
                if (updated) {
                    response.sendRedirect("lecturer-dashboard?success=Course+updated+successfully");
                } else {
                    response.sendRedirect("lecturer-dashboard?error=Failed+to+update+course");
                }
            } else {
                response.sendRedirect("lecturer-dashboard?error=Unauthorized+action");
            }

        } else if ("deleteCourse".equals(action)) {
            String courseId = request.getParameter("courseId");
            // Security: only allow deleting courses taught by this lecturer
            LecturerUser lecturerUser = (LecturerUser) session.getAttribute("user");
            Lecturer lecturer = lecturerDAO.getLecturerById(lecturerUser.getLecturerId());
            Course course = courseDAO.findCourseById(courseId);

            if (course != null && lecturer != null &&
                    lecturer.getName().equalsIgnoreCase(course.getInstructor())) {
                boolean deleted = courseDAO.deleteCourse(courseId);
                if (deleted) {
                    response.sendRedirect("lecturer-dashboard?success=Course+deleted");
                } else {
                    response.sendRedirect("lecturer-dashboard?error=Failed+to+delete+course");
                }
            } else {
                response.sendRedirect("lecturer-dashboard?error=Unauthorized+action");
            }
        }
    }
}
