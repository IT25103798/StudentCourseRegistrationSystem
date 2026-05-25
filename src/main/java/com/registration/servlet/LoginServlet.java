package com.registration.servlet;

import com.registration.model.User;
import com.registration.model.Student;
import com.registration.model.Admin;
import com.registration.dao.UserDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Username: " + username);
        System.out.println("Password: " + password);

        User user = userDAO.validateLogin(username, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());

            System.out.println("Login successful! Role: " + user.getRole());

            // Redirect based on role
            if ("admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("admin");
            } else if ("student".equalsIgnoreCase(user.getRole())) {
                // Redirect to STUDENT DASHBOARD
                response.sendRedirect("student-dashboard.jsp");
            } else if ("lecturer".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("lecturer-dashboard");
            } else {
                response.sendRedirect(user.getDashboardPath());
            }
        } else {
            System.out.println("Login failed for: " + username);
            request.setAttribute("error", "Invalid username or password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}
