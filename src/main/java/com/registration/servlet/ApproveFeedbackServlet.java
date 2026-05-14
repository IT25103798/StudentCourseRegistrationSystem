package com.registration.servlet;

import com.registration.dao.FeedbackDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/approve-feedback")
public class ApproveFeedbackServlet extends HttpServlet {

    private FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String feedbackId = request.getParameter("feedbackId");
        String status = request.getParameter("status");

        if (feedbackId != null && status != null) {
            feedbackDAO.updateFeedbackStatus(feedbackId, status);
        }

        response.sendRedirect("admin-feedback.jsp");
    }
}