package com.registration.model;

import java.io.Serializable;

public class Course implements Serializable {
    private String courseId;
    private String courseName;
    private String department;
    private String instructor;
    private int totalSeats;
    private int availableSeats;
    private int credits;
    private String schedule;

    public Course() {}

    public Course(String courseId, String courseName, String department, String instructor,
                  int totalSeats, int availableSeats, int credits, String schedule) {
        this.courseId = courseId;
        this.courseName = courseName;
        this.department = department;
        this.instructor = instructor;
        this.totalSeats = totalSeats;
        this.availableSeats = availableSeats;
        this.credits = credits;
        this.schedule = schedule;
    }

    // Getters and Setters
    public String getCourseId() { return courseId; }
    public void setCourseId(String courseId) { this.courseId = courseId; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getInstructor() { return instructor; }
    public void setInstructor(String instructor) { this.instructor = instructor; }

    public int getTotalSeats() { return totalSeats; }
    public void setTotalSeats(int totalSeats) { this.totalSeats = totalSeats; }

    public int getAvailableSeats() { return availableSeats; }
    public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }

    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public boolean isAvailable() { return availableSeats > 0; }

    @Override
    public String toString() {
        return courseId + "|" + courseName + "|" + department + "|" + instructor + "|" +
                totalSeats + "|" + availableSeats + "|" + credits + "|" + schedule;
    }
}
