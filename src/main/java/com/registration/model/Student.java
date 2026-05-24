package com.registration.model;

public class Student extends User {
    private String studentId;
    private String department;
    private int semester;

    public Student() {
        super();
    }

    public Student(String id, String username, String password, String email,
                   String studentId, String department, int semester) {
        super(id, username, password, email, "student");
        this.studentId = studentId;
        this.department = department;
        this.semester = semester;
    }

    // Getters and Setters
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public int getSemester() { return semester; }
    public void setSemester(int semester) { this.semester = semester; }

    @Override
    public String getDashboardPath() {
        // Return the path to student dashboard JSP
        return "student-dashboard.jsp";
    }

    @Override
    public String toString() {
        return getId() + "|" + getUsername() + "|" + getPassword() + "|" +
                getEmail() + "|" + getRole() + "|" + studentId + "|" + department + "|" + semester;
    }
}
