package com.registration.servlet;

import com.registration.dao.UserDAO;
import com.registration.dao.RegistrationDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/DeleteStudentServlet")
public class DeleteStudentServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        // Check if user is admin
        if (role == null || !"admin".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userId = request.getParameter("userId");
        String studentName = request.getParameter("studentName");

        System.out.println("=== DELETING STUDENT ===");
        System.out.println("User ID: " + userId);
        System.out.println("Student Name: " + studentName);

        if (userId == null || userId.trim().isEmpty()) {
            response.sendRedirect("manage-students.jsp?error=Invalid student ID");
            return;
        }

        // First, delete all registrations for this student
        boolean registrationsDeleted = deleteStudentRegistrations(userId);
        System.out.println("Registrations deleted: " + registrationsDeleted);

        // Then delete the student user
        boolean studentDeleted = userDAO.deleteUser(userId);
        System.out.println("Student deleted: " + studentDeleted);

        if (studentDeleted) {
            response.sendRedirect("manage-students.jsp?success=Student deleted successfully");
        } else {
            response.sendRedirect("manage-students.jsp?error=Failed to delete student");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private boolean deleteStudentRegistrations(String userId) {
        try {
            // Get all registrations and delete those belonging to this student
            java.util.List<com.registration.model.Registration> registrations = registrationDAO.getRegistrationsByStudent(userId);
            boolean allDeleted = true;

            for (com.registration.model.Registration reg : registrations) {
                boolean deleted = registrationDAO.cancelRegistration(reg.getRegistrationId());
                if (!deleted) {
                    allDeleted = false;
                }
            }

            // Also remove from queue if present
            removeFromQueue(userId);

            return allDeleted;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void removeFromQueue(String userId) {
        try {
            java.util.List<com.registration.model.RegistrationRequest> queue = registrationDAO.getQueueStatus();
            for (com.registration.model.RegistrationRequest req : queue) {
                if (req.getStudentId().equals(userId)) {
                    com.registration.util.QueueManager.removeFromQueue(req.getRequestId());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}