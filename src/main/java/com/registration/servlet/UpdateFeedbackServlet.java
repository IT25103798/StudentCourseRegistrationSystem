package com.registration.servlet;

import com.registration.dao.FeedbackDAO;
import com.registration.model.Feedback;
import com.registration.model.Student;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/update-feedback")
public class UpdateFeedbackServlet extends HttpServlet {

    private FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("user");

        if (student == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String feedbackId = request.getParameter("feedbackId");
        String ratingStr  = request.getParameter("rating");
        String comment    = request.getParameter("comment");

        if (feedbackId == null || ratingStr == null || comment == null) {
            response.sendRedirect("student-courses.jsp?feedback=error");
            return;
        }

        // Verify this feedback belongs to the current student
        List<Feedback> studentFeedbacks = feedbackDAO.getFeedbacksByStudent(student.getId());
        Feedback target = null;
        for (Feedback f : studentFeedbacks) {
            if (f.getFeedbackId().equals(feedbackId)) {
                target = f;
                break;
            }
        }

        if (target == null) {
            response.sendRedirect("student-courses.jsp?feedback=error");
            return;
        }

        target.setRating(Integer.parseInt(ratingStr));
        target.setComment(comment);
        target.setFeedbackDate(LocalDateTime.now());
        target.setStatus("pending"); // re-submitted for admin approval

        // Update via delete + re-add
        feedbackDAO.deleteFeedback(feedbackId);
        boolean saved = feedbackDAO.addFeedback(target);

        if (saved) {
            response.sendRedirect("student-courses.jsp?feedback=updated");
        } else {
            response.sendRedirect("student-courses.jsp?feedback=error");
        }
    }
}
