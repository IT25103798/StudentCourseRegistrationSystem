package com.registration.dao;

import com.registration.model.Course;
import com.registration.model.Registration;
import com.registration.model.RegistrationRequest;
import com.registration.util.FileHandler;
import com.registration.util.QueueManager;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.List;

public class RegistrationDAO {

    private static final String REGISTRATIONS_FILE = "registrations.txt";
    private static final String REJECTED_FILE = "rejected_registrations.txt";  // NEW
    private CourseDAO courseDAO = new CourseDAO();
    private UserDAO userDAO = new UserDAO();

    // ==================== CREATE METHODS ====================

    // CREATE - Add registration request to queue
    public boolean addRegistrationRequest(String studentId, String studentName,
                                          String courseId, String courseName) {
        try {
            String requestId = generateRequestId();
            RegistrationRequest request = new RegistrationRequest(
                    requestId, studentId, studentName, courseId, courseName, 2
            );
            boolean added = QueueManager.enqueue(request);
            System.out.println("Registration request added to queue: " + requestId + " - Success: " + added);
            return added;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // CREATE - Approve registration from queue and save to registrations.txt
    public boolean approveRegistration(String requestId) {
        try {
            RegistrationRequest request = null;
            List<RegistrationRequest> queue = QueueManager.getAllQueueItems();

            for (RegistrationRequest req : queue) {
                if (req.getRequestId().equals(requestId)) {
                    request = req;
                    break;
                }
            }

            if (request != null) {
                Course course = courseDAO.findCourseById(request.getCourseId());
                if (course != null && course.getAvailableSeats() > 0) {
                    // Update available seats
                    course.setAvailableSeats(course.getAvailableSeats() - 1);
                    boolean courseUpdated = courseDAO.updateCourse(course);
                    System.out.println("Course seats updated: " + courseUpdated);

                    // Create registration record
                    String regId = generateRegistrationId();
                    Registration registration = new Registration(
                            regId, request.getStudentId(), request.getCourseId(),
                            "approved", LocalDateTime.now()
                    );

                    // SAVE TO registrations.txt
                    boolean saved = FileHandler.writeToFile(REGISTRATIONS_FILE, registration.toString(), true);
                    System.out.println("Registration saved to file: " + saved);
                    System.out.println("Registration data: " + registration.toString());

                    if (saved) {
                        // Remove from queue
                        boolean removed = QueueManager.removeFromQueue(requestId);
                        System.out.println("Request removed from queue: " + removed);
                        return true;
                    }
                } else {
                    System.out.println("Course not found or no seats available");
                }
            } else {
                System.out.println("Request not found in queue: " + requestId);
            }
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // CREATE - Reject registration (remove from queue and save to rejected file)
    public boolean rejectRegistration(String requestId) {
        try {
            RegistrationRequest request = null;
            List<RegistrationRequest> queue = QueueManager.getAllQueueItems();

            for (RegistrationRequest req : queue) {
                if (req.getRequestId().equals(requestId)) {
                    request = req;
                    break;
                }
            }

            if (request != null) {
                // Update status to rejected
                request.setStatus("rejected");

                // Save to rejected_registrations.txt
                String rejectedLine = request.getRequestId() + "|" +
                        request.getStudentId() + "|" +
                        request.getStudentName() + "|" +
                        request.getCourseId() + "|" +
                        request.getCourseName() + "|" +
                        request.getRequestTime() + "|" +
                        request.getPriority() + "|" +
                        "rejected";

                boolean saved = FileHandler.writeToFile(REJECTED_FILE, rejectedLine, true);
                System.out.println("Rejected registration saved to file: " + saved);
                System.out.println("Rejected data: " + rejectedLine);

                // Remove from queue
                boolean removed = QueueManager.removeFromQueue(requestId);
                System.out.println("Request removed from queue: " + removed);

                return saved && removed;
            }
            System.out.println("Request not found in queue: " + requestId);
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==================== READ METHODS ====================

    // READ - Get registrations by student
    public List<Registration> getRegistrationsByStudent(String studentId) {
        List<Registration> registrations = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(REGISTRATIONS_FILE);

        System.out.println("Reading registrations for student: " + studentId);
        System.out.println("Total lines in file: " + lines.size());

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5) {
                String fileStudentId = parts[1];

                if (fileStudentId.equals(studentId)) {
                    Registration reg = new Registration(
                            parts[0], parts[1], parts[2], parts[3], parseDateTime(parts[4])
                    );
                    registrations.add(reg);
                    System.out.println("Added registration: " + reg.getRegistrationId());
                }
            }
        }
        System.out.println("Total registrations found: " + registrations.size());
        return registrations;
    }

    // READ - Get rejected registrations for a student
    public List<String> getRejectedRegistrationsByStudent(String studentId) {
        List<String> rejected = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(REJECTED_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 3 && parts[1].equals(studentId)) {
                rejected.add(line);
            }
        }
        return rejected;
    }

    // READ - Get all rejected registrations
    public List<String> getAllRejectedRegistrations() {
        return FileHandler.readAllLines(REJECTED_FILE);
    }

    // READ - Get registration by ID
    public Registration getRegistrationById(String registrationId) {
        List<String> lines = FileHandler.readAllLines(REGISTRATIONS_FILE);
        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5 && parts[0].equals(registrationId)) {
                return new Registration(
                        parts[0], parts[1], parts[2], parts[3], parseDateTime(parts[4])
                );
            }
        }
        return null;
    }

    // READ - Get registrations by course
    public List<Registration> getRegistrationsByCourse(String courseId) {
        List<Registration> registrations = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(REGISTRATIONS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5 && parts[2].equals(courseId)) {
                Registration reg = new Registration(
                        parts[0], parts[1], parts[2], parts[3], parseDateTime(parts[4])
                );
                registrations.add(reg);
            }
        }
        return registrations;
    }

    // READ - Get all registrations
    public List<Registration> getAllRegistrations() {
        List<Registration> registrations = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(REGISTRATIONS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 5) {
                Registration reg = new Registration(
                        parts[0], parts[1], parts[2], parts[3], parseDateTime(parts[4])
                );
                registrations.add(reg);
            }
        }
        return registrations;
    }

    // READ - Get approved registrations count for a course
    public int getApprovedCountForCourse(String courseId) {
        int count = 0;
        List<Registration> registrations = getAllRegistrations();
        for (Registration reg : registrations) {
            if (reg.getCourseId().equals(courseId) && "approved".equals(reg.getStatus())) {
                count++;
            }
        }
        return count;
    }

    // READ - Get queue status (all requests)
    public List<RegistrationRequest> getQueueStatus() {
        return QueueManager.getAllQueueItems();
    }

    // READ - Get queue size
    public int getQueueSize() {
        return QueueManager.getQueueSize();
    }

    // READ - Get student's queue requests
    public List<RegistrationRequest> getStudentQueueRequests(String studentId) {
        List<RegistrationRequest> allQueue = QueueManager.getAllQueueItems();
        List<RegistrationRequest> studentQueue = new ArrayList<>();
        for (RegistrationRequest req : allQueue) {
            if (req.getStudentId().equals(studentId)) {
                studentQueue.add(req);
            }
        }
        return studentQueue;
    }

    // READ - Check if student is already in queue for a course
    public boolean isStudentInQueue(String studentId, String courseId) {
        List<RegistrationRequest> queue = QueueManager.getAllQueueItems();
        for (RegistrationRequest req : queue) {
            if (req.getStudentId().equals(studentId) && req.getCourseId().equals(courseId)) {
                return true;
            }
        }
        return false;
    }

    // READ - Get total rejected count
    public int getTotalRejectedCount() {
        return FileHandler.readAllLines(REJECTED_FILE).size();
    }

    // ==================== UPDATE METHODS ====================

    // UPDATE - Update registration status
    public boolean updateRegistrationStatus(String registrationId, String status) {
        Registration reg = getRegistrationById(registrationId);
        if (reg != null) {
            reg.setStatus(status);
            String regLine = reg.getRegistrationId() + "|" + reg.getStudentId() + "|" +
                    reg.getCourseId() + "|" + reg.getStatus() + "|" + reg.getRegistrationDate();
            return FileHandler.updateLine(REGISTRATIONS_FILE, registrationId, 0, regLine);
        }
        return false;
    }

    // ==================== DELETE METHODS ====================

    // DELETE - Cancel registration
    public boolean cancelRegistration(String registrationId) {
        boolean deleted = FileHandler.deleteLine(REGISTRATIONS_FILE, registrationId, 0);
        System.out.println("Registration cancelled: " + registrationId + " - Success: " + deleted);
        return deleted;
    }

    // DELETE - Cancel all registrations for a student
    public boolean cancelAllRegistrationsForStudent(String studentId) {
        List<Registration> registrations = getRegistrationsByStudent(studentId);
        boolean allDeleted = true;
        for (Registration reg : registrations) {
            boolean deleted = cancelRegistration(reg.getRegistrationId());
            if (!deleted) allDeleted = false;
        }
        return allDeleted;
    }

    // DELETE - Clear rejected registrations file
    public boolean clearRejectedRegistrations() {
        return FileHandler.overwriteFile(REJECTED_FILE, new ArrayList<>());
    }

    // ==================== STATISTICS METHODS ====================

    public int getTotalRegistrationsCount() {
        return getAllRegistrations().size();
    }

    public int getApprovedRegistrationsCount() {
        int count = 0;
        for (Registration reg : getAllRegistrations()) {
            if ("approved".equals(reg.getStatus())) count++;
        }
        return count;
    }

    public int getPendingRegistrationsCount() {
        int count = 0;
        for (Registration reg : getAllRegistrations()) {
            if ("pending".equals(reg.getStatus())) count++;
        }
        return count;
    }

    // ==================== HELPER METHODS ====================

    private String generateRegistrationId() {
        return "REG" + System.currentTimeMillis();
    }

    private String generateRequestId() {
        return "REQ" + System.currentTimeMillis();
    }

    /**
     * Safely parses a LocalDateTime string that may have more than 9 nanosecond digits.
     * Java's LocalDateTime.parse fails on timestamps like "2026-05-02T10:40:27.566523200"
     * because it has 9 fractional digits — we truncate to at most 9 before parsing.
     */
    private LocalDateTime parseDateTime(String raw) {
        try {
            // Truncate fractional seconds to max 9 digits
            String fixed = raw.replaceAll("(\\.\\d{1,9})\\d*$", "$1");
            return LocalDateTime.parse(fixed);
        } catch (Exception e) {
            System.err.println("Failed to parse date: " + raw + " - " + e.getMessage());
            return LocalDateTime.now();
        }
    }
}
