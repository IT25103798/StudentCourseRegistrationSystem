package com.registration.servlet;

import com.registration.dao.CourseDAO;
import com.registration.model.Course;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/courses")
public class CourseServlet extends HttpServlet {

    private CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("search".equals(action)) {
            String keyword = request.getParameter("keyword");
            List<Course> courses = courseDAO.searchCoursesByName(keyword);
            request.setAttribute("courses", courses);
            request.setAttribute("searchKeyword", keyword);
        } else if ("sorted".equals(action)) {
            String sortBy = request.getParameter("sortBy");
            if ("demand".equals(sortBy)) {
                List<Course> courses = courseDAO.getCoursesSortedByDemand();
                request.setAttribute("courses", courses);
            } else if ("name".equals(sortBy)) {
                List<Course> courses = courseDAO.getCoursesSortedByName();
                request.setAttribute("courses", courses);
            } else {
                List<Course> courses = courseDAO.getAllCourses();
                request.setAttribute("courses", courses);
            }
        } else {
            List<Course> courses = courseDAO.getAllCourses();
            request.setAttribute("courses", courses);
        }

        request.getRequestDispatcher("course-list.jsp").forward(request, response);
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

        if ("add".equals(action)) {
            String courseId = courseDAO.generateCourseId();
            String courseName = request.getParameter("courseName");
            String department = request.getParameter("department");  // ← GET DEPARTMENT
            String instructor = request.getParameter("instructor");
            int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
            int credits = Integer.parseInt(request.getParameter("credits"));
            String schedule = request.getParameter("schedule");

            // Debug print
            System.out.println("=== ADDING COURSE ===");
            System.out.println("Course Name: " + courseName);
            System.out.println("Department: " + department);
            System.out.println("Instructor: " + instructor);
            System.out.println("Total Seats: " + totalSeats);
            System.out.println("Credits: " + credits);
            System.out.println("Schedule: " + schedule);

            Course course = new Course(courseId, courseName, department, instructor,
                    totalSeats, totalSeats, credits, schedule);
            boolean added = courseDAO.addCourse(course);
            System.out.println("Course added: " + added);

        } else if ("update".equals(action)) {
            String courseId = request.getParameter("courseId");
            String courseName = request.getParameter("courseName");
            String department = request.getParameter("department");  // ← GET DEPARTMENT
            String instructor = request.getParameter("instructor");
            int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
            int credits = Integer.parseInt(request.getParameter("credits"));
            String schedule = request.getParameter("schedule");

            Course course = courseDAO.findCourseById(courseId);
            if (course != null) {
                course.setCourseName(courseName);
                course.setDepartment(department);  // ← SET DEPARTMENT
                course.setInstructor(instructor);
                course.setTotalSeats(totalSeats);
                course.setCredits(credits);
                course.setSchedule(schedule);
                courseDAO.updateCourse(course);
            }

        } else if ("delete".equals(action)) {
            String courseId = request.getParameter("courseId");
            courseDAO.deleteCourse(courseId);
        }

        response.sendRedirect("courses");
    }
}