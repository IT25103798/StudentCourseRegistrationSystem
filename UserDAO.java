package com.registration.dao;

import com.registration.model.User;
import com.registration.model.Student;
import com.registration.model.Admin;
import com.registration.model.LecturerUser;
import com.registration.util.FileHandler;
import java.util.*;

public class UserDAO {

    private static final String USERS_FILE = "users.txt";
    private static final String STUDENTS_FILE = "students.txt";

    // CREATE - Register new user
    public boolean registerUser(User user) {
        try {
            String userLine;
            // LecturerUser.toString() includes the lecturerId at the end
            if (user instanceof com.registration.model.LecturerUser) {
                userLine = user.toString();
            } else {
                userLine = user.getId() + "|" + user.getUsername() + "|" +
                        user.getPassword() + "|" + user.getEmail() + "|" + user.getRole();
            }
            System.out.println("Registering user: " + userLine);
            return FileHandler.writeToFile(USERS_FILE, userLine, true);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // CREATE - Register student with details
    public boolean registerStudent(Student student) {
        try {
            // Format: id|username|password|email|role|studentId|department|semester
            String studentLine = student.getId() + "|" + student.getUsername() + "|" +
                    student.getPassword() + "|" + student.getEmail() + "|" +
                    student.getRole() + "|" + student.getStudentId() + "|" +
                    student.getDepartment() + "|" + student.getSemester();

            System.out.println("Registering student: " + studentLine);

            boolean studentSaved = FileHandler.writeToFile(STUDENTS_FILE, studentLine, true);
            boolean userSaved = registerUser(student);

            System.out.println("Student saved: " + studentSaved);
            System.out.println("User saved: " + userSaved);

            return studentSaved && userSaved;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // CREATE - Register admin
    public boolean registerAdmin(Admin admin) {
        try {
            String adminLine = admin.getId() + "|" + admin.getUsername() + "|" +
                    admin.getPassword() + "|" + admin.getEmail() + "|" +
                    admin.getRole() + "|" + admin.getAdminCode() + "|" + admin.getPermissions();

            System.out.println("Registering admin: " + adminLine);
            return FileHandler.writeToFile(USERS_FILE, adminLine, true);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Find user by username
    public User findUserByUsername(String username) {
        System.out.println("Looking for username: " + username);
        List<String> lines = FileHandler.readAllLines(USERS_FILE);
        System.out.println("Users file has " + lines.size() + " lines");

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5) {
                String fileUsername = parts[1];
                String fileRole = parts[4];

                System.out.println("Checking: " + fileUsername);

                if (fileUsername.equals(username)) {
                    System.out.println("Found user: " + username + " with role: " + fileRole);
                    if ("student".equals(fileRole)) {
                        return findStudentById(parts[0]);
                    } else if ("admin".equals(fileRole)) {
                        return new Admin(parts[0], parts[1], parts[2], parts[3],
                                parts.length > 5 ? parts[5] : "ADMIN001",
                                parts.length > 6 ? parts[6] : "full");
                    } else if ("lecturer".equals(fileRole)) {
                        return new LecturerUser(parts[0], parts[1], parts[2], parts[3],
                                parts.length > 5 ? parts[5] : "");
                    }
                }
            }
        }
        System.out.println("User not found: " + username);
        return null;
    }

    // READ - Find student by ID
    public Student findStudentById(String userId) {
        List<String> lines = FileHandler.readAllLines(STUDENTS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 8 && parts[0].equals(userId)) {
                return new Student(
                        parts[0], parts[1], parts[2], parts[3],
                        parts[5], parts[6], Integer.parseInt(parts[7])
                );
            }
        }
        return null;
    }

    // READ - Find admin by ID
    public Admin findAdminById(String userId) {
        List<String> lines = FileHandler.readAllLines(USERS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5 && parts[0].equals(userId) && "admin".equals(parts[4])) {
                return new Admin(
                        parts[0], parts[1], parts[2], parts[3],
                        parts.length > 5 ? parts[5] : "ADMIN001",
                        parts.length > 6 ? parts[6] : "full"
                );
            }
        }
        return null;
    }

    // READ - Validate login
    public User validateLogin(String username, String password) {
        System.out.println("=== VALIDATING LOGIN ===");
        System.out.println("Username: " + username);
        System.out.println("Password: " + password);

        List<String> lines = FileHandler.readAllLines(USERS_FILE);
        System.out.println("Users file has " + lines.size() + " lines");

        for (String line : lines) {
            System.out.println("Checking line: " + line);
            String[] parts = line.split("\\|");
            if (parts.length >= 5) {
                String fileUsername = parts[1];
                String filePassword = parts[2];
                String fileRole = parts[4];

                System.out.println("Comparing: " + fileUsername + " == " + username);
                System.out.println("Password match: " + filePassword.equals(password));

                if (fileUsername.equals(username) && filePassword.equals(password)) {
                    System.out.println("Login successful! Role: " + fileRole);
                    if ("student".equals(fileRole)) {
                        return findStudentById(parts[0]);
                    } else if ("admin".equals(fileRole)) {
                        return new Admin(parts[0], parts[1], parts[2], parts[3],
                                parts.length > 5 ? parts[5] : "ADMIN001",
                                parts.length > 6 ? parts[6] : "full");
                    } else if ("lecturer".equals(fileRole)) {
                        return new LecturerUser(parts[0], parts[1], parts[2], parts[3],
                                parts.length > 5 ? parts[5] : "");
                    }
                }
            }
        }
        System.out.println("Login failed for: " + username);
        return null;
    }

    // READ - Get all students
    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(STUDENTS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 8) {
                students.add(new Student(
                        parts[0], parts[1], parts[2], parts[3],
                        parts[5], parts[6], Integer.parseInt(parts[7])
                ));
            }
        }
        return students;
    }

    // READ - Get all admins
    public List<Admin> getAllAdmins() {
        List<Admin> admins = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(USERS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5 && "admin".equals(parts[4])) {
                admins.add(new Admin(
                        parts[0], parts[1], parts[2], parts[3],
                        parts.length > 5 ? parts[5] : "ADMIN001",
                        parts.length > 6 ? parts[6] : "full"
                ));
            }
        }
        return admins;
    }

    // READ - Get all users
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(USERS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5) {
                if ("student".equals(parts[4])) {
                    users.add(findStudentById(parts[0]));
                } else if ("admin".equals(parts[4])) {
                    users.add(new Admin(parts[0], parts[1], parts[2], parts[3],
                            parts.length > 5 ? parts[5] : "ADMIN001",
                            parts.length > 6 ? parts[6] : "full"));
                }
            }
        }
        return users;
    }

    // UPDATE - Update user information
    public boolean updateUser(User user) {
        String userLine = user.getId() + "|" + user.getUsername() + "|" +
                user.getPassword() + "|" + user.getEmail() + "|" + user.getRole();
        return FileHandler.updateLine(USERS_FILE, user.getId(), 0, userLine);
    }

    // UPDATE - Update student information
    public boolean updateStudent(Student student) {
        String studentLine = student.getId() + "|" + student.getUsername() + "|" +
                student.getPassword() + "|" + student.getEmail() + "|" +
                student.getRole() + "|" + student.getStudentId() + "|" +
                student.getDepartment() + "|" + student.getSemester();
        boolean userUpdated = updateUser(student);
        boolean studentUpdated = FileHandler.updateLine(STUDENTS_FILE, student.getId(), 0, studentLine);
        return userUpdated && studentUpdated;
    }

    // UPDATE - Update admin information
    public boolean updateAdmin(Admin admin) {
        String adminLine = admin.getId() + "|" + admin.getUsername() + "|" +
                admin.getPassword() + "|" + admin.getEmail() + "|" +
                admin.getRole() + "|" + admin.getAdminCode() + "|" + admin.getPermissions();
        return FileHandler.updateLine(USERS_FILE, admin.getId(), 0, adminLine);
    }

    // DELETE - Remove user
    public boolean deleteUser(String userId) {
        boolean deleted = FileHandler.deleteLine(USERS_FILE, userId, 0);
        FileHandler.deleteLine(STUDENTS_FILE, userId, 0);
        return deleted;
    }

    // DELETE - Remove student
    public boolean deleteStudent(String userId) {
        boolean userDeleted = FileHandler.deleteLine(USERS_FILE, userId, 0);
        boolean studentDeleted = FileHandler.deleteLine(STUDENTS_FILE, userId, 0);
        return userDeleted && studentDeleted;
    }

    // DELETE - Remove admin
    public boolean deleteAdmin(String userId) {
        return FileHandler.deleteLine(USERS_FILE, userId, 0);
    }

    // Generate new user ID
    public String generateUserId() {
        List<String> lines = FileHandler.readAllLines(USERS_FILE);
        int maxId = 0;

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length > 0) {
                String id = parts[0];
                if (id.startsWith("USR")) {
                    try {
                        int num = Integer.parseInt(id.substring(3));
                        if (num > maxId) maxId = num;
                    } catch (NumberFormatException e) {}
                }
            }
        }
        String newId = "USR" + (maxId + 1);
        System.out.println("Generated new user ID: " + newId);
        return newId;
    }

    // Check if username exists
    public boolean usernameExists(String username) {
        return findUserByUsername(username) != null;
    }

    // Check if email exists
    public boolean emailExists(String email) {
        List<String> lines = FileHandler.readAllLines(USERS_FILE);
        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 4 && parts[3].equals(email)) {
                return true;
            }
        }
        return false;
    }

    // Get user count
    public int getUserCount() {
        return FileHandler.readAllLines(USERS_FILE).size();
    }

    // Get student count
    public int getStudentCount() {
        return FileHandler.readAllLines(STUDENTS_FILE).size();
    }
}