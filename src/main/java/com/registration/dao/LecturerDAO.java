package com.registration.dao;

import com.registration.model.Lecturer;
import com.registration.util.FileHandler;
import java.util.*;

public class LecturerDAO {

    private static final String LECTURERS_FILE = "lecturers.txt";

    // CREATE - Add new lecturer
    public boolean addLecturer(Lecturer lecturer) {
        try {
            String lecturerLine = lecturer.toString();
            System.out.println("Adding lecturer: " + lecturerLine);
            return FileHandler.writeToFile(LECTURERS_FILE, lecturerLine, true);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get all lecturers
    public List<Lecturer> getAllLecturers() {
        List<Lecturer> lecturers = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(LECTURERS_FILE);

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 9) {
                Lecturer lecturer = new Lecturer(
                        parts[0], parts[1], parts[2], parts[3],
                        parts[4], parts[5], parts[6], parts[7], parts[8]
                );
                lecturers.add(lecturer);
            }
        }
        return lecturers;
    }

    // READ - Get lecturer by ID
    public Lecturer getLecturerById(String lecturerId) {
        List<Lecturer> lecturers = getAllLecturers();
        for (Lecturer l : lecturers) {
            if (l.getLecturerId().equals(lecturerId)) {
                return l;
            }
        }
        return null;
    }

    // READ - Get lecturers by department
    public List<Lecturer> getLecturersByDepartment(String department) {
        List<Lecturer> allLecturers = getAllLecturers();
        List<Lecturer> filtered = new ArrayList<>();
        for (Lecturer l : allLecturers) {
            if (l.getDepartment().equals(department)) {
                filtered.add(l);
            }
        }
        return filtered;
    }

    // READ - Search lecturers
    public List<Lecturer> searchLecturers(String keyword) {
        List<Lecturer> allLecturers = getAllLecturers();
        List<Lecturer> results = new ArrayList<>();
        String lowerKeyword = keyword.toLowerCase();

        for (Lecturer l : allLecturers) {
            if (l.getName().toLowerCase().contains(lowerKeyword) ||
                    l.getEmail().toLowerCase().contains(lowerKeyword) ||
                    l.getDepartment().toLowerCase().contains(lowerKeyword) ||
                    l.getSpecialization().toLowerCase().contains(lowerKeyword)) {
                results.add(l);
            }
        }
        return results;
    }

    // UPDATE - Update lecturer
    public boolean updateLecturer(Lecturer lecturer) {
        String lecturerLine = lecturer.toString();
        return FileHandler.updateLine(LECTURERS_FILE, lecturer.getLecturerId(), 0, lecturerLine);
    }

    // DELETE - Delete lecturer
    public boolean deleteLecturer(String lecturerId) {
        return FileHandler.deleteLine(LECTURERS_FILE, lecturerId, 0);
    }

    // Get statistics
    public int getTotalLecturers() {
        return getAllLecturers().size();
    }

    public int getActiveLecturers() {
        int count = 0;
        for (Lecturer l : getAllLecturers()) {
            if ("active".equals(l.getStatus())) count++;
        }
        return count;
    }

    public Map<String, Integer> getLecturersByDepartmentStats() {
        Map<String, Integer> stats = new LinkedHashMap<>();
        for (Lecturer l : getAllLecturers()) {
            String dept = l.getDepartment();
            stats.put(dept, stats.getOrDefault(dept, 0) + 1);
        }
        return stats;
    }

    // Generate new lecturer ID
    public String generateLecturerId() {
        List<Lecturer> lecturers = getAllLecturers();
        int maxId = 0;
        for (Lecturer l : lecturers) {
            String id = l.getLecturerId();
            if (id != null && id.startsWith("LEC")) {
                try {
                    int num = Integer.parseInt(id.substring(3));
                    if (num > maxId) maxId = num;
                } catch (NumberFormatException e) {}
            }
        }
        return String.format("LEC%03d", maxId + 1);
    }
}
