package com.registration.servlet;

import com.registration.dao.UserDAO;
import com.registration.model.Admin;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manage-admins")
public class AdminManagementServlet extends HttpServlet {

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

        if ("delete".equals(action)) {
            String adminId = request.getParameter("adminId");
            String currentUserId = (String) session.getAttribute("userId");

            if (adminId != null && !adminId.equals(currentUserId)) {
                boolean deleted = userDAO.deleteAdmin(adminId);
                if (deleted) {
                    response.sendRedirect("manage-admins?success=Admin+deleted+successfully");
                } else {
                    response.sendRedirect("manage-admins?error=Failed+to+delete+admin");
                }
            } else {
                response.sendRedirect("manage-admins?error=Cannot+delete+your+own+account");
            }
            return;
        }

        List<Admin> admins = userDAO.getAllAdmins();
        request.setAttribute("admins", admins);
        request.getRequestDispatcher("manage-admins.jsp").forward(request, response);
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

        if ("create".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String email    = request.getParameter("email");
            String adminCode = request.getParameter("adminCode");
            String permissions = request.getParameter("permissions");

            if (userDAO.usernameExists(username)) {
                response.sendRedirect("manage-admins?error=Username+already+exists");
                return;
            }
            if (userDAO.emailExists(email)) {
                response.sendRedirect("manage-admins?error=Email+already+exists");
                return;
            }

            String newId = userDAO.generateUserId();
            Admin newAdmin = new Admin(newId, username, password, email, adminCode, permissions);
            boolean created = userDAO.registerAdmin(newAdmin);
            if (created) {
                response.sendRedirect("manage-admins?success=Admin+created+successfully");
            } else {
                response.sendRedirect("manage-admins?error=Failed+to+create+admin");
            }

        } else if ("update".equals(action)) {
            String adminId    = request.getParameter("adminId");
            String password   = request.getParameter("password");
            String permissions = request.getParameter("permissions");

            Admin existing = userDAO.findAdminById(adminId);
            if (existing != null) {
                if (password != null && !password.trim().isEmpty()) {
                    existing.setPassword(password);
                }
                if (permissions != null && !permissions.trim().isEmpty()) {
                    existing.setPermissions(permissions);
                }
                boolean updated = userDAO.updateAdmin(existing);
                if (updated) {
                    response.sendRedirect("manage-admins?success=Admin+updated+successfully");
                } else {
                    response.sendRedirect("manage-admins?error=Failed+to+update+admin");
                }
            } else {
                response.sendRedirect("manage-admins?error=Admin+not+found");
            }
        }
    }
}
