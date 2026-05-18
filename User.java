package com.registration.model;

import java.io.Serializable;

public abstract class User implements Serializable {
    private String id;
    private String username;
    private String password;
    private String email;
    private String role; // "student" or "admin"

    public User() {}

    public User(String id, String username, String password, String email, String role) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.role = role;
    }

    // Getters and Setters (Encapsulation)
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    // Abstract method (Abstraction)
    public abstract String getDashboardPath();

    @Override
    public String toString() {
        return id + "|" + username + "|" + password + "|" + email + "|" + role;
    }
}