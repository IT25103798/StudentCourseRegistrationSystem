package com.registration.model;

import java.io.Serializable;

public class Lecturer implements Serializable {
    private String lecturerId;
    private String name;
    private String email;
    private String phone;
    private String department;
    private String specialization;
    private String qualification;
    private String joiningDate;
    private String status; // active, inactive

    public Lecturer() {}

    public Lecturer(String lecturerId, String name, String email, String phone,
                    String department, String specialization, String qualification,
                    String joiningDate, String status) {
        this.lecturerId = lecturerId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.department = department;
        this.specialization = specialization;
        this.qualification = qualification;
        this.joiningDate = joiningDate;
        this.status = status;
    }

    // Getters and Setters
    public String getLecturerId() { return lecturerId; }
    public void setLecturerId(String lecturerId) { this.lecturerId = lecturerId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }

    public String getQualification() { return qualification; }
    public void setQualification(String qualification) { this.qualification = qualification; }

    public String getJoiningDate() { return joiningDate; }
    public void setJoiningDate(String joiningDate) { this.joiningDate = joiningDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return lecturerId + "|" + name + "|" + email + "|" + phone + "|" +
                department + "|" + specialization + "|" + qualification + "|" +
                joiningDate + "|" + status;
    }
}
