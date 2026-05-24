package com.registration.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Registration implements Serializable {
    private String registrationId;
    private String studentId;
    private String courseId;
    private String status; // "pending", "approved", "rejected", "completed"
    private LocalDateTime registrationDate;

    public Registration() {}

    public Registration(String registrationId, String studentId, String courseId,
                        String status, LocalDateTime registrationDate) {
        this.registrationId = registrationId;
        this.studentId = studentId;
        this.courseId = courseId;
        this.status = status;
        this.registrationDate = registrationDate;
    }

    // Getters and Setters
    public String getRegistrationId() { return registrationId; }
    public void setRegistrationId(String registrationId) { this.registrationId = registrationId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(LocalDateTime registrationDate) { this.registrationDate = registrationDate; }

    @Override
    public String toString() {
        return registrationId + "|" + studentId + "|" + courseId + "|" + status + "|" + registrationDate;
    }
}
