package com.registration.servlet;

import com.registration.dao.CourseDAO;
import com.registration.dao.RegistrationDAO;
import com.registration.dao.UserDAO;
import com.registration.model.Course;
import com.registration.model.Registration;
import com.registration.model.Student;
import com.registration.util.FileHandler;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manage-enrollments")
public class EnrollmentManagementServlet extends HttpServlet {

    private RegistrationDAO registrationDAO = new RegistrationDAO();
    private CourseDAO courseDAO = new CourseDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (!"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("unenroll".equals(action)) {
            String registrationId = request.getParameter("registrationId");

            Registration reg = registrationDAO.getRegistrationById(registrationId);
            if (reg != null) {
                // Restore seat count
                Course course = courseDAO.findCourseById(reg.getCourseId());
                if (course != null) {
                    course.setAvailableSeats(course.getAvailableSeats() + 1);
                    courseDAO.updateCourse(course);
                }
                boolean cancelled = registrationDAO.cancelRegistration(registrationId);
                if (cancelled) {
                    response.sendRedirect("manage-enrollments?success=Student+unenrolled+successfully");
                } else {
                    response.sendRedirect("manage-enrollments?error=Failed+to+unenroll+student");
                }
            } else {
                response.sendRedirect("manage-enrollments?error=Registration+not+found");
            }
            return;
        }

        List<Registration> allRegistrations = registrationDAO.getAllRegistrations();
        List<Course> allCourses = courseDAO.getAllCourses();
        List<Student> allStudents = userDAO.getAllStudents();

        request.setAttribute("allRegistrations", allRegistrations);
        request.setAttribute("allCourses", allCourses);
        request.setAttribute("allStudents", allStudents);
        request.getRequestDispatcher("manage-enrollments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (!"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("transfer".equals(action)) {
            String registrationId = request.getParameter("registrationId");
            String newCourseId    = request.getParameter("newCourseId");

            Registration reg = registrationDAO.getRegistrationById(registrationId);
            if (reg == null) {
                response.sendRedirect("manage-enrollments?error=Registration+not+found");
                return;
            }

            Course oldCourse = courseDAO.findCourseById(reg.getCourseId());
            Course newCourse = courseDAO.findCourseById(newCourseId);

            if (newCourse == null) {
                response.sendRedirect("manage-enrollments?error=Target+course+not+found");
                return;
            }
            if (newCourse.getAvailableSeats() <= 0) {
                response.sendRedirect("manage-enrollments?error=Target+course+is+full");
                return;
            }
            if (reg.getCourseId().equals(newCourseId)) {
                response.sendRedirect("manage-enrollments?error=Student+is+already+enrolled+in+that+course");
                return;
            }

            // Restore seat in old course
            if (oldCourse != null) {
                oldCourse.setAvailableSeats(oldCourse.getAvailableSeats() + 1);
                courseDAO.updateCourse(oldCourse);
            }

            // Reduce seat in new course
            newCourse.setAvailableSeats(newCourse.getAvailableSeats() - 1);
            courseDAO.updateCourse(newCourse);

            // Update the registration record
            String newRegLine = reg.getRegistrationId() + "|" + reg.getStudentId() + "|" +
                    newCourseId + "|" + reg.getStatus() + "|" + reg.getRegistrationDate();
            boolean updated = FileHandler.updateLine("registrations.txt", registrationId, 0, newRegLine);

            if (updated) {
                response.sendRedirect("manage-enrollments?success=Enrollment+transferred+successfully");
            } else {
                response.sendRedirect("manage-enrollments?error=Failed+to+transfer+enrollment");
            }
        }
    }
}
