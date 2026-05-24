package com.registration.servlet;

import com.registration.dao.UserDAO;
import com.registration.dao.LecturerDAO;
import com.registration.model.User;
import com.registration.model.Student;
import com.registration.model.Admin;
import com.registration.model.LecturerUser;
import com.registration.model.Lecturer;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private LecturerDAO lecturerDAO = new LecturerDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role     = (String) session.getAttribute("role");
        String action   = request.getParameter("action"); // "profile" or "password"
        String redirect = getDashboard(role);

        if ("password".equals(action)) {
            handlePasswordChange(request, response, session, role, redirect);
        } else {
            handleProfileUpdate(request, response, session, role, redirect);
        }
    }

    // ── PASSWORD CHANGE ──────────────────────────────────────────────────────

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, String role, String redirect)
            throws IOException {

        String currentPassword = request.getParameter("currentPassword");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        User user = (User) session.getAttribute("user");

        if (!user.getPassword().equals(currentPassword)) {
            response.sendRedirect("profile-settings.jsp?error=wrong_password");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect("profile-settings.jsp?error=password_mismatch");
            return;
        }
        if (newPassword.length() < 6) {
            response.sendRedirect("profile-settings.jsp?error=password_short");
            return;
        }

        user.setPassword(newPassword);

        boolean saved = saveUser(user, role);
        if (saved) {
            session.setAttribute("user", user);
            response.sendRedirect("profile-settings.jsp?success=password_changed");
        } else {
            response.sendRedirect("profile-settings.jsp?error=save_failed");
        }
    }

    // ── PROFILE UPDATE ───────────────────────────────────────────────────────

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response,
                                     HttpSession session, String role, String redirect)
            throws IOException {

        String newEmail    = request.getParameter("email");
        String newUsername = request.getParameter("username");

        User user = (User) session.getAttribute("user");

        // Validate: username taken by someone else
        if (!newUsername.equals(user.getUsername()) && userDAO.usernameExists(newUsername)) {
            response.sendRedirect("profile-settings.jsp?error=username_taken");
            return;
        }
        // Validate: email taken by someone else
        if (!newEmail.equals(user.getEmail()) && userDAO.emailExists(newEmail)) {
            response.sendRedirect("profile-settings.jsp?error=email_taken");
            return;
        }

        user.setUsername(newUsername);
        user.setEmail(newEmail);

        // Role-specific extra fields
        if ("student".equals(role)) {
            Student s = (Student) user;
            String dept = request.getParameter("department");
            String semStr = request.getParameter("semester");
            if (dept != null && !dept.isEmpty()) s.setDepartment(dept);
            if (semStr != null && !semStr.isEmpty()) {
                try { s.setSemester(Integer.parseInt(semStr)); } catch (NumberFormatException ignored) {}
            }
        } else if ("lecturer".equals(role)) {
            LecturerUser lu = (LecturerUser) user;
            Lecturer lecturer = lecturerDAO.getLecturerById(lu.getLecturerId());
            if (lecturer != null) {
                String phone = request.getParameter("phone");
                String specialization = request.getParameter("specialization");
                if (phone != null && !phone.isEmpty()) lecturer.setPhone(phone);
                if (specialization != null && !specialization.isEmpty()) lecturer.setSpecialization(specialization);
                lecturer.setEmail(newEmail); // keep in sync
                lecturerDAO.updateLecturer(lecturer);
            }
        }

        boolean saved = saveUser(user, role);
        if (saved) {
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());
            response.sendRedirect("profile-settings.jsp?success=profile_updated");
        } else {
            response.sendRedirect("profile-settings.jsp?error=save_failed");
        }
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────

    private boolean saveUser(User user, String role) {
        if ("student".equals(role))  return userDAO.updateStudent((Student) user);
        if ("admin".equals(role))    return userDAO.updateAdmin((Admin) user);
        if ("lecturer".equals(role)) return userDAO.updateUser(user); // LecturerUser goes to users.txt only
        return false;
    }

    private String getDashboard(String role) {
        if ("student".equals(role))  return "student-dashboard.jsp";
        if ("admin".equals(role))    return "admin";
        if ("lecturer".equals(role)) return "lecturer-dashboard";
        return "login.jsp";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("profile-settings.jsp");
    }
}
