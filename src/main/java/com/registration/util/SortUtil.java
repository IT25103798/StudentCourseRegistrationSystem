package com.registration.util;

import com.registration.model.Course;
import java.util.List;

public class SortUtil {

    // Insertion Sort - Sort courses by available seats (ascending)
    // Fewer seats = higher priority for registration
    public static void sortCoursesByDemand(List<Course> courses) {
        for (int i = 1; i < courses.size(); i++) {
            Course key = courses.get(i);
            int j = i - 1;

            // Sort by available seats (ascending)
            while (j >= 0 && courses.get(j).getAvailableSeats() > key.getAvailableSeats()) {
                courses.set(j + 1, courses.get(j));
                j--;
            }
            courses.set(j + 1, key);
        }
    }

    // Sort courses by name (alphabetical)
    public static void sortCoursesByName(List<Course> courses) {
        for (int i = 1; i < courses.size(); i++) {
            Course key = courses.get(i);
            int j = i - 1;

            while (j >= 0 && courses.get(j).getCourseName().compareTo(key.getCourseName()) > 0) {
                courses.set(j + 1, courses.get(j));
                j--;
            }
            courses.set(j + 1, key);
        }
    }

    // Sort courses by credits (descending)
    public static void sortCoursesByCredits(List<Course> courses) {
        for (int i = 1; i < courses.size(); i++) {
            Course key = courses.get(i);
            int j = i - 1;

            while (j >= 0 && courses.get(j).getCredits() < key.getCredits()) {
                courses.set(j + 1, courses.get(j));
                j--;
            }
            courses.set(j + 1, key);
        }
    }
}
