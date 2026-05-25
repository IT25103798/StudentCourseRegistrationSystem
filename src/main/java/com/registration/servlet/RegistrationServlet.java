package com.registration.servlet;

import com.registration.dao.CourseDAO;
import com.registration.dao.RegistrationDAO;
import com.registration.model.Course;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;  // ← THIS IMPORT WAS MISSING!

@WebServlet("/register-course")
public class RegistrationServlet extends HttpServlet {

    private RegistrationDAO registrationDAO = new RegistrationDAO();
    private CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        String courseId = request.getParameter("courseId");

        Course course = courseDAO.findCourseById(courseId);

        if (course != null && userId != null) {
            registrationDAO.addRegistrationRequest(userId, username, courseId, course.getCourseName());
            request.setAttribute("message", "Registration request added to queue!");
        } else {
            request.setAttribute("error", "Registration failed!");
        }

        List<Course> courses = courseDAO.getAllCourses();
        request.setAttribute("courses", courses);
        request.getRequestDispatcher("register-course.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Course> courses = courseDAO.getAllCourses();
        request.setAttribute("courses", courses);
        request.getRequestDispatcher("register-course.jsp").forward(request, response);
    }
}
