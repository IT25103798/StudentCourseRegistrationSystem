package com.registration.model;

public class LecturerUser extends User {

    private String lecturerId; // Links to lecturers.txt

    public LecturerUser() {
        super();
    }

    public LecturerUser(String id, String username, String password, String email, String lecturerId) {
        super(id, username, password, email, "lecturer");
        this.lecturerId = lecturerId;
    }

    public String getLecturerId() { return lecturerId; }
    public void setLecturerId(String lecturerId) { this.lecturerId = lecturerId; }

    @Override
    public String getDashboardPath() {
        return "lecturer-dashboard";
    }

    @Override
    public String toString() {
        return getId() + "|" + getUsername() + "|" + getPassword() + "|" + getEmail() + "|" + getRole() + "|" + lecturerId;
    }
}
