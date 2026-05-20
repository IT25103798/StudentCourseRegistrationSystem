package com.registration.servlet;

import com.registration.dao.UserDAO;
import com.registration.model.Student;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/UpdateStudentServlet")
public class UpdateStudentServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        // Check if user is admin
        if (role == null || !"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get form parameters
        String userId = request.getParameter("userId");
        String username = request.getParameter("username");
        String studentId = request.getParameter("studentId");
        String email = request.getParameter("email");
        String department = request.getParameter("department");
        String semesterStr = request.getParameter("semester");
        String newPassword = request.getParameter("newPassword");

        System.out.println("=== UPDATING STUDENT ===");
        System.out.println("User ID: " + userId);
        System.out.println("Username: " + username);
        System.out.println("Student ID: " + studentId);
        System.out.println("Email: " + email);
        System.out.println("Department: " + department);
        System.out.println("Semester: " + semesterStr);

        // Validation
        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect("manage-students.jsp?error=Invalid student ID");
            return;
        }

        if (username == null || username.trim().isEmpty()) {
            response.sendRedirect("manage-students.jsp?error=Username is required");
            return;
        }

        if (studentId == null || studentId.trim().isEmpty()) {
            response.sendRedirect("manage-students.jsp?error=Student ID is required");
            return;
        }

        if (email == null || !email.contains("@")) {
            response.sendRedirect("manage-students.jsp?error=Valid email is required");
            return;
        }

        int semester = 1;
        try {
            semester = Integer.parseInt(semesterStr);
        } catch (NumberFormatException e) {
            semester = 1;
        }

        // Get existing student
        Student existingStudent = userDAO.findStudentById(userId);

        if (existingStudent == null) {
            response.sendRedirect("manage-students.jsp?error=Student not found");
            return;
        }

        // Update student information
        String password = existingStudent.getPassword();
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            password = newPassword;
        }

        Student updatedStudent = new Student(
                userId,
                username,
                password,
                email,
                studentId,
                department,
                semester
        );

        boolean updated = userDAO.updateStudent(updatedStudent);
        System.out.println("Student updated: " + updated);

        if (updated) {
            response.sendRedirect("manage-students.jsp?success=Student updated successfully");
        } else {
            response.sendRedirect("manage-students.jsp?error=Failed to update student");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("manage-students.jsp");
    }
}