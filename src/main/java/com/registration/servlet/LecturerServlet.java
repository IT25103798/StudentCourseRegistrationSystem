package com.registration.servlet;

import com.registration.dao.LecturerDAO;
import com.registration.dao.UserDAO;
import com.registration.model.Lecturer;
import com.registration.model.LecturerUser;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manage-lecturers")
public class LecturerServlet extends HttpServlet {

    private LecturerDAO lecturerDAO = new LecturerDAO();
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

        // Handle delete via GET (sent by proceedDelete() JS function)
        if ("delete".equals(action)) {
            String lecturerId = request.getParameter("lecturerId");
            boolean deleted = lecturerDAO.deleteLecturer(lecturerId);
            if (deleted) {
                response.sendRedirect("manage-lecturers?success=Lecturer+deleted");
            } else {
                response.sendRedirect("manage-lecturers?error=Failed+to+delete+lecturer");
            }
            return;
        }

        String searchKeyword = request.getParameter("search");

        List<Lecturer> lecturers;

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            lecturers = lecturerDAO.searchLecturers(searchKeyword);
            request.setAttribute("searchKeyword", searchKeyword);
        } else {
            lecturers = lecturerDAO.getAllLecturers();
        }

        request.setAttribute("lecturers", lecturers);
        request.setAttribute("totalLecturers", lecturerDAO.getTotalLecturers());
        request.setAttribute("activeLecturers", lecturerDAO.getActiveLecturers());
        request.setAttribute("deptStats", lecturerDAO.getLecturersByDepartmentStats());

        request.getRequestDispatcher("manage-lecturers.jsp").forward(request, response);
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
            String lecturerId = lecturerDAO.generateLecturerId();
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String department = request.getParameter("department");
            String specialization = request.getParameter("specialization");
            String qualification = request.getParameter("qualification");
            String joiningDate = request.getParameter("joiningDate");
            String status = request.getParameter("status");
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            // Validate username uniqueness
            if (username == null || username.trim().isEmpty()) {
                response.sendRedirect("manage-lecturers?error=Username+is+required");
                return;
            }
            if (userDAO.usernameExists(username.trim())) {
                response.sendRedirect("manage-lecturers?error=Username+already+exists");
                return;
            }

            Lecturer lecturer = new Lecturer(lecturerId, name, email, phone,
                    department, specialization, qualification,
                    joiningDate, status);
            boolean added = lecturerDAO.addLecturer(lecturer);

            // Create login account for the lecturer
            boolean userCreated = false;
            if (added) {
                String userId = userDAO.generateUserId();
                LecturerUser lecturerUser = new LecturerUser(userId, username.trim(), password, email, lecturerId);
                userCreated = userDAO.registerUser(lecturerUser);
            }

            if (added && userCreated) {
                response.sendRedirect("manage-lecturers?success=Lecturer+added+with+login+account");
            } else if (added) {
                response.sendRedirect("manage-lecturers?success=Lecturer+added+but+login+account+creation+failed");
            } else {
                response.sendRedirect("manage-lecturers?error=Failed+to+add+lecturer");
            }

        } else if ("update".equals(action)) {
            String lecturerId = request.getParameter("lecturerId");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String department = request.getParameter("department");
            String specialization = request.getParameter("specialization");
            String qualification = request.getParameter("qualification");
            String joiningDate = request.getParameter("joiningDate");
            String status = request.getParameter("status");

            Lecturer lecturer = new Lecturer(lecturerId, name, email, phone,
                    department, specialization, qualification,
                    joiningDate, status);
            boolean updated = lecturerDAO.updateLecturer(lecturer);

            if (updated) {
                response.sendRedirect("manage-lecturers?success=Lecturer+updated");
            } else {
                response.sendRedirect("manage-lecturers?error=Failed+to+update+lecturer");
            }

        } else if ("delete".equals(action)) {
            String lecturerId = request.getParameter("lecturerId");
            boolean deleted = lecturerDAO.deleteLecturer(lecturerId);

            if (deleted) {
                response.sendRedirect("manage-lecturers?success=Lecturer+deleted");
            } else {
                response.sendRedirect("manage-lecturers?error=Failed+to+delete+lecturer");
            }
        }
    }
}
