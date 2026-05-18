package com.registration.servlet;

import com.registration.model.Student;
import com.registration.dao.UserDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get form parameters
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String email = request.getParameter("email");
            String studentId = request.getParameter("studentId");
            String department = request.getParameter("department");
            String semesterStr = request.getParameter("semester");

            // Debug - print to console
            System.out.println("=== Registration Attempt ===");
            System.out.println("Username: " + username);
            System.out.println("Student ID: " + studentId);
            System.out.println("Email: " + email);
            System.out.println("Department: " + department);
            System.out.println("Semester: " + semesterStr);

            // Validation
            if (username == null || username.trim().isEmpty()) {
                request.setAttribute("error", "Username is required!");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            if (password == null || password.length() < 6) {
                request.setAttribute("error", "Password must be at least 6 characters!");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            if (email == null || !email.contains("@")) {
                request.setAttribute("error", "Valid email is required!");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            if (studentId == null || studentId.trim().isEmpty()) {
                request.setAttribute("error", "Student ID is required!");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            int semester = 1;
            try {
                semester = Integer.parseInt(semesterStr);
            } catch (NumberFormatException e) {
                semester = 1;
            }

            // Check if username already exists
            if (userDAO.findUserByUsername(username) != null) {
                request.setAttribute("error", "Username already exists! Please choose another one.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            // Generate user ID
            String userId = userDAO.generateUserId();
            System.out.println("Generated User ID: " + userId);

            // Create student object
            Student student = new Student(userId, username, password, email,
                    studentId, department, semester);

            // Register student
            boolean success = userDAO.registerStudent(student);
            System.out.println("Registration success: " + success);

            if (success) {
                // Registration successful - redirect to login
                response.sendRedirect("login.jsp?success=Account created successfully! Please login.");
            } else {
                request.setAttribute("error", "Registration failed! Please try again.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("signup.jsp");
    }
}