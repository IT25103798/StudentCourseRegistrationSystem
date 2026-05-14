package com.registration.dao;

import com.registration.model.Feedback;
import com.registration.util.FileHandler;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    private static final String FEEDBACK_FILE = "feedbacks.txt";

    // CREATE - Add feedback
    public boolean addFeedback(Feedback feedback) {
        try {
            String feedbackLine = feedback.toString();
            boolean saved = FileHandler.writeToFile(FEEDBACK_FILE, feedbackLine, true);
            System.out.println("Feedback saved: " + saved);
            return saved;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get all feedbacks
    public List<Feedback> getAllFeedbacks() {
        List<Feedback> feedbacks = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(FEEDBACK_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 9) {
                Feedback feedback = new Feedback(
                        parts[0], parts[1], parts[2], parts[3], parts[4],
                        Integer.parseInt(parts[5]), parts[6],
                        LocalDateTime.parse(parts[7]), parts[8]
                );
                feedbacks.add(feedback);
            }
        }
        return feedbacks;
    }

    // READ - Get feedbacks by course
    public List<Feedback> getFeedbacksByCourse(String courseId) {
        List<Feedback> allFeedbacks = getAllFeedbacks();
        List<Feedback> courseFeedbacks = new ArrayList<>();
        for (Feedback f : allFeedbacks) {
            if (f.getCourseId().equals(courseId) && "approved".equals(f.getStatus())) {
                courseFeedbacks.add(f);
            }
        }
        return courseFeedbacks;
    }

    // READ - Get feedbacks by student
    public List<Feedback> getFeedbacksByStudent(String studentId) {
        List<Feedback> allFeedbacks = getAllFeedbacks();
        List<Feedback> studentFeedbacks = new ArrayList<>();
        for (Feedback f : allFeedbacks) {
            if (f.getStudentId().equals(studentId)) {
                studentFeedbacks.add(f);
            }
        }
        return studentFeedbacks;
    }

    // READ - Get average rating for a course
    public double getAverageRatingForCourse(String courseId) {
        List<Feedback> feedbacks = getFeedbacksByCourse(courseId);
        if (feedbacks.isEmpty()) return 0;
        int sum = 0;
        for (Feedback f : feedbacks) {
            sum += f.getRating();
        }
        return (double) sum / feedbacks.size();
    }

    // UPDATE - Update feedback status (admin)
    public boolean updateFeedbackStatus(String feedbackId, String status) {
        List<Feedback> allFeedbacks = getAllFeedbacks();
        for (int i = 0; i < allFeedbacks.size(); i++) {
            if (allFeedbacks.get(i).getFeedbackId().equals(feedbackId)) {
                allFeedbacks.get(i).setStatus(status);
                return saveAllFeedbacks(allFeedbacks);
            }
        }
        return false;
    }

    // DELETE - Delete feedback
    public boolean deleteFeedback(String feedbackId) {
        return FileHandler.deleteLine(FEEDBACK_FILE, feedbackId, 0);
    }

    private boolean saveAllFeedbacks(List<Feedback> feedbacks) {
        List<String> lines = new ArrayList<>();
        for (Feedback f : feedbacks) {
            lines.add(f.toString());
        }
        return FileHandler.overwriteFile(FEEDBACK_FILE, lines);
    }

    private String generateFeedbackId() {
        return "FB" + System.currentTimeMillis();
    }
}