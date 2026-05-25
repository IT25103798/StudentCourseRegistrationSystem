package com.registration.servlet;

import com.registration.dao.RegistrationDAO;
import com.registration.model.RegistrationRequest;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;  // ← IMPORT THIS!

@WebServlet("/queue-status")
public class QueueStatusServlet extends HttpServlet {

    private RegistrationDAO registrationDAO = new RegistrationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        List<RegistrationRequest> queue = registrationDAO.getQueueStatus();

        // Filter queue for current student if not admin
        if (!"admin".equals(role)) {
            queue.removeIf(req -> !req.getStudentId().equals(userId));
        }

        request.setAttribute("queue", queue);
        request.setAttribute("queueSize", queue.size());
        request.getRequestDispatcher("queue-status.jsp").forward(request, response);
    }
}
