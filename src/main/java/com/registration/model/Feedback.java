package com.registration.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Feedback implements Serializable {
    private String feedbackId;
    private String studentId;
    private String studentName;
    private String courseId;
    private String courseName;
    private int rating; // 1-5 stars
    private String comment;
    private LocalDateTime feedbackDate;
    private String status; // "pending", "approved", "rejected"

    public Feedback() {}

    public Feedback(String feedbackId, String studentId, String studentName,
                    String courseId, String courseName, int rating,
                    String comment, LocalDateTime feedbackDate, String status) {
        this.feedbackId = feedbackId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.courseId = courseId;
        this.courseName = courseName;
        this.rating = rating;
        this.comment = comment;
        this.feedbackDate = feedbackDate;
        this.status = status;
    }

    // Getters and Setters
    public String getFeedbackId() { return feedbackId; }
    public void setFeedbackId(String feedbackId) { this.feedbackId = feedbackId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public LocalDateTime getFeedbackDate() { return feedbackDate; }
    public void setFeedbackDate(LocalDateTime feedbackDate) { this.feedbackDate = feedbackDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return feedbackId + "|" + studentId + "|" + studentName + "|" +
                courseId + "|" + courseName + "|" + rating + "|" +
                comment + "|" + feedbackDate + "|" + status;
    }
}