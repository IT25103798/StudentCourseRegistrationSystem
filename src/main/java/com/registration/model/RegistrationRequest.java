package com.registration.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class RegistrationRequest implements Serializable {
    private String requestId;
    private String studentId;
    private String studentName;
    private String courseId;
    private String courseName;
    private LocalDateTime requestTime;
    private int priority;
    private String status; // "pending", "approved", "rejected"

    public RegistrationRequest() {}

    public RegistrationRequest(String requestId, String studentId, String studentName,
                               String courseId, String courseName, int priority) {
        this.requestId = requestId;
        this.studentId = studentId;
        this.studentName = studentName;
        this.courseId = courseId;
        this.courseName = courseName;
        this.requestTime = LocalDateTime.now();
        this.priority = priority;
        this.status = "pending";
    }

    // Getters and Setters
    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public LocalDateTime getRequestTime() { return requestTime; }
    public void setRequestTime(LocalDateTime requestTime) { this.requestTime = requestTime; }

    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return requestId + "|" + studentId + "|" + studentName + "|" + courseId + "|" +
                courseName + "|" + requestTime + "|" + priority + "|" + status;
    }
}
