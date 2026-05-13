package com.registration.dao;

import com.registration.model.Course;
import com.registration.util.FileHandler;
import com.registration.util.SortUtil;
import java.util.*;

public class CourseDAO {

    private static final String COURSES_FILE = "courses.txt";

    // CREATE - Add new course
    public boolean addCourse(Course course) {
        try {
            // Format: ID|Name|Department|Instructor|TotalSeats|AvailableSeats|Credits|Schedule
            String courseLine = course.getCourseId() + "|" + course.getCourseName() + "|" +
                    course.getDepartment() + "|" + course.getInstructor() + "|" +
                    course.getTotalSeats() + "|" + course.getAvailableSeats() + "|" +
                    course.getCredits() + "|" + course.getSchedule();
            System.out.println("Adding course: " + courseLine);
            return FileHandler.writeToFile(COURSES_FILE, courseLine, true);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get all courses
    public List<Course> getAllCourses() {
        List<Course> courses = new ArrayList<>();
        List<String> lines = FileHandler.readAllLines(COURSES_FILE);

        System.out.println("=== READING COURSES ===");
        System.out.println("Number of lines read: " + lines.size());

        for (String line : lines) {
            System.out.println("Processing line: " + line);
            String[] parts = line.split("\\|");

            // Check if line has 8 columns (with department) or 7 columns (old format)
            if (parts.length >= 8) {
                try {
                    Course course = new Course();
                    course.setCourseId(parts[0].trim());
                    course.setCourseName(parts[1].trim());
                    course.setDepartment(parts[2].trim());  // Department column
                    course.setInstructor(parts[3].trim());
                    course.setTotalSeats(Integer.parseInt(parts[4].trim()));
                    course.setAvailableSeats(Integer.parseInt(parts[5].trim()));
                    course.setCredits(Integer.parseInt(parts[6].trim()));
                    course.setSchedule(parts[7].trim());
                    courses.add(course);
                    System.out.println("Successfully added course: " + course.getCourseName() + " - Dept: " + course.getDepartment());
                } catch (NumberFormatException e) {
                    System.err.println("Error parsing course: " + line);
                    e.printStackTrace();
                }
            } else if (parts.length >= 7) {
                // Old format (7 columns) - add default department
                try {
                    Course course = new Course();
                    course.setCourseId(parts[0].trim());
                    course.setCourseName(parts[1].trim());
                    course.setDepartment("General");  // Default department
                    course.setInstructor(parts[2].trim());
                    course.setTotalSeats(Integer.parseInt(parts[3].trim()));
                    course.setAvailableSeats(Integer.parseInt(parts[4].trim()));
                    course.setCredits(Integer.parseInt(parts[5].trim()));
                    course.setSchedule(parts[6].trim());
                    courses.add(course);
                    System.out.println("Successfully added course (old format): " + course.getCourseName());
                } catch (NumberFormatException e) {
                    System.err.println("Error parsing course: " + line);
                    e.printStackTrace();
                }
            } else {
                System.err.println("Invalid line format: " + line);
            }
        }

        System.out.println("Total courses loaded: " + courses.size());
        return courses;
    }

    // READ - Get courses sorted by demand
    public List<Course> getCoursesSortedByDemand() {
        List<Course> courses = getAllCourses();
        SortUtil.sortCoursesByDemand(courses);
        return courses;
    }

    // READ - Get courses sorted by name
    public List<Course> getCoursesSortedByName() {
        List<Course> courses = getAllCourses();
        SortUtil.sortCoursesByName(courses);
        return courses;
    }

    // READ - Find course by ID
    public Course findCourseById(String courseId) {
        List<Course> courses = getAllCourses();
        for (Course course : courses) {
            if (course.getCourseId().equals(courseId)) {
                return course;
            }
        }
        return null;
    }

    // READ - Search courses
    public List<Course> searchCoursesByName(String keyword) {
        List<Course> allCourses = getAllCourses();
        List<Course> results = new ArrayList<>();
        String lowerKeyword = keyword.toLowerCase();

        for (Course course : allCourses) {
            if (course.getCourseName().toLowerCase().contains(lowerKeyword) ||
                    course.getInstructor().toLowerCase().contains(lowerKeyword) ||
                    course.getCourseId().toLowerCase().contains(lowerKeyword)) {
                results.add(course);
            }
        }
        return results;
    }

    // UPDATE - Update course
    public boolean updateCourse(Course course) {
        try {
            // Format with 8 columns (including department)
            String courseLine = course.getCourseId() + "|" + course.getCourseName() + "|" +
                    course.getDepartment() + "|" + course.getInstructor() + "|" +
                    course.getTotalSeats() + "|" + course.getAvailableSeats() + "|" +
                    course.getCredits() + "|" + course.getSchedule();
            System.out.println("Updating course: " + courseLine);
            return FileHandler.updateLine(COURSES_FILE, course.getCourseId(), 0, courseLine);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // UPDATE - Update available seats
    public boolean updateAvailableSeats(String courseId, int newAvailableSeats) {
        Course course = findCourseById(courseId);
        if (course != null) {
            course.setAvailableSeats(newAvailableSeats);
            return updateCourse(course);
        }
        return false;
    }

    // DELETE - Remove course
    public boolean deleteCourse(String courseId) {
        try {
            System.out.println("Deleting course with ID: " + courseId);
            return FileHandler.deleteLine(COURSES_FILE, courseId, 0);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Generate new course ID
    public String generateCourseId() {
        List<Course> courses = getAllCourses();
        int maxId = 0;

        for (Course course : courses) {
            String id = course.getCourseId();
            if (id != null && id.startsWith("CRS")) {
                try {
                    int num = Integer.parseInt(id.substring(3));
                    if (num > maxId) maxId = num;
                } catch (NumberFormatException e) {}
            }
        }
        String newId = "CRS" + (maxId + 1);
        System.out.println("Generated new course ID: " + newId);
        return newId;
    }

    // Check if courses exist
    public boolean hasCourses() {
        List<String> lines = FileHandler.readAllLines(COURSES_FILE);
        return !lines.isEmpty();
    }

    // Get course count
    public int getCourseCount() {
        return getAllCourses().size();
    }
}