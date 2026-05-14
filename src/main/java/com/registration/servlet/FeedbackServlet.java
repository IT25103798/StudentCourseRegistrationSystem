package com.registration.servlet;

import com.registration.dao.FeedbackDAO;
import com.registration.model.Feedback;
import com.registration.model.Student;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/submit-feedback")
public class FeedbackServlet extends HttpServlet {

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

        String courseId = request.getParameter("courseId");
        String courseName = request.getParameter("courseName");
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");

        String feedbackId = "FB" + System.currentTimeMillis();

        Feedback feedback = new Feedback(
                feedbackId, student.getId(), student.getUsername(),
                courseId, courseName, rating, comment,
                LocalDateTime.now(), "pending"
        );

        boolean saved = feedbackDAO.addFeedback(feedback);

        if (saved) {
            response.sendRedirect("student-courses.jsp?feedback=success");
        } else {
            response.sendRedirect("student-courses.jsp?feedback=error");
        }
    }
}