package com.registration.servlet;

import com.registration.dao.CourseDAO;
import com.registration.dao.RegistrationDAO;
import com.registration.dao.UserDAO;
import com.registration.model.RegistrationRequest;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private RegistrationDAO registrationDAO = new RegistrationDAO();
    private CourseDAO courseDAO = new CourseDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        System.out.println("AdminServlet - Role: " + role);

        if (!"admin".equals(role)) {
            System.out.println("Not admin, redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("queue".equals(action)) {
            List<RegistrationRequest> queue = registrationDAO.getQueueStatus();
            request.setAttribute("queue", queue);
            request.setAttribute("queueSize", registrationDAO.getQueueSize());
            request.getRequestDispatcher("admin-queue.jsp").forward(request, response);
            return;

        } else if ("approve".equals(action)) {
            String requestId = request.getParameter("requestId");
            boolean approved = registrationDAO.approveRegistration(requestId);
            if (approved) {
                response.sendRedirect("admin?action=queue&success=Registration+approved");
            } else {
                response.sendRedirect("admin?action=queue&error=Approval+failed");
            }
            return;

        } else if ("reject".equals(action)) {
            // NEW: Handle reject action
            String requestId = request.getParameter("requestId");
            boolean rejected = registrationDAO.rejectRegistration(requestId);
            if (rejected) {
                response.sendRedirect("admin?action=queue&success=Registration+rejected+and+removed");
            } else {
                response.sendRedirect("admin?action=queue&error=Rejection+failed");
            }
            return;
        }

        // Dashboard stats
        request.setAttribute("totalCourses", courseDAO.getAllCourses().size());
        request.setAttribute("totalStudents", userDAO.getAllStudents().size());
        request.setAttribute("queueSize", registrationDAO.getQueueSize());
        request.setAttribute("pendingRegistrations", registrationDAO.getQueueSize());

        request.getRequestDispatcher("admin-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}