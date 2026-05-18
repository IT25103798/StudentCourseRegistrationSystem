package com.registration.model;

public class Admin extends User {
    private String adminCode;
    private String permissions;

    // Default constructor
    public Admin() {
        super();
    }

    // Parameterized constructor
    public Admin(String id, String username, String password, String email,
                 String adminCode, String permissions) {
        super(id, username, password, email, "admin");
        this.adminCode = adminCode;
        this.permissions = permissions;
    }

    // Getters and Setters
    public String getAdminCode() {
        return adminCode;
    }

    public void setAdminCode(String adminCode) {
        this.adminCode = adminCode;
    }

    public String getPermissions() {
        return permissions;
    }

    public void setPermissions(String permissions) {
        this.permissions = permissions;
    }

    @Override
    public String getDashboardPath() {
        return "admin";
    }

    @Override
    public String toString() {
        return getId() + "|" + getUsername() + "|" + getPassword() + "|" +
                getEmail() + "|" + getRole() + "|" + adminCode + "|" + permissions;
    }
}