package com.registration.util;

import java.io.*;
import java.util.*;

public class FileHandler {

    // YOUR EXACT PATH - Use this absolute path
    private static final String DATA_DIR = "D:\\Student CourseRegistration System\\StudentCourseRegistrationSystem\\data\\";

    // Make sure directory exists when class loads
    static {
        createDataDirectory();
    }

    private static void createDataDirectory() {
        File dir = new File(DATA_DIR);
        if (!dir.exists()) {
            System.out.println("Creating data directory: " + DATA_DIR);
            boolean created = dir.mkdirs();
            if (created) {
                System.out.println("Data directory created successfully!");
            } else {
                System.err.println("Failed to create data directory: " + DATA_DIR);
            }
        } else {
            System.out.println("Data directory already exists: " + DATA_DIR);
        }
    }

    // Helper method to get full file path
    private static String getFullPath(String filename) {
        return DATA_DIR + filename;
    }

    // Generic write to file
    public static synchronized boolean writeToFile(String filename, String data, boolean append) {
        try {
            String fullPath = getFullPath(filename);
            File file = new File(fullPath);

            // Ensure parent directory exists
            File parent = file.getParentFile();
            if (parent != null && !parent.exists()) {
                parent.mkdirs();
            }

            System.out.println("========================================");
            System.out.println("WRITING TO FILE:");
            System.out.println("Full path: " + fullPath);
            System.out.println("Data: " + data);
            System.out.println("Append mode: " + append);
            System.out.println("========================================");

            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file, append))) {
                writer.write(data);
                writer.newLine();
                writer.flush();
                System.out.println("SUCCESS: Data written to file!");
                return true;
            }
        } catch (IOException e) {
            System.err.println("ERROR: Failed to write to file: " + filename);
            e.printStackTrace();
            return false;
        }
    }

    // Generic read all lines from file
    public static synchronized List<String> readAllLines(String filename) {
        List<String> lines = new ArrayList<>();
        String fullPath = getFullPath(filename);
        File file = new File(fullPath);

        System.out.println("========================================");
        System.out.println("READING FROM FILE:");
        System.out.println("Full path: " + fullPath);
        System.out.println("========================================");

        if (!file.exists()) {
            System.out.println("File does not exist, creating: " + fullPath);
            try {
                file.createNewFile();
                System.out.println("File created successfully!");
            } catch (IOException e) {
                System.err.println("Failed to create file: " + fullPath);
                e.printStackTrace();
            }
            return lines;
        }

        try (BufferedReader reader = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    lines.add(line);
                    System.out.println("Read line: " + line);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading file: " + fullPath);
            e.printStackTrace();
        }
        System.out.println("Total lines read: " + lines.size());
        return lines;
    }

    // Overwrite file
    public static synchronized boolean overwriteFile(String filename, List<String> data) {
        try {
            String fullPath = getFullPath(filename);
            File file = new File(fullPath);

            System.out.println("Overwriting file: " + fullPath);

            try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
                for (String line : data) {
                    writer.write(line);
                    writer.newLine();
                }
                writer.flush();
            }
            System.out.println("File overwritten successfully!");
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete a specific line
    public static synchronized boolean deleteLine(String filename, String identifier, int columnIndex) {
        List<String> lines = readAllLines(filename);
        List<String> newLines = new ArrayList<>();
        boolean deleted = false;

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length > columnIndex && parts[columnIndex].equals(identifier)) {
                deleted = true;
                System.out.println("Deleting line: " + line);
                continue;
            }
            newLines.add(line);
        }

        if (deleted) {
            return overwriteFile(filename, newLines);
        }
        return false;
    }

    // Update a specific line
    public static synchronized boolean updateLine(String filename, String identifier,
                                                  int columnIndex, String newData) {
        List<String> lines = readAllLines(filename);
        List<String> newLines = new ArrayList<>();
        boolean updated = false;

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length > columnIndex && parts[columnIndex].equals(identifier)) {
                newLines.add(newData);
                updated = true;
                System.out.println("Updating line: " + line + " -> " + newData);
            } else {
                newLines.add(line);
            }
        }

        if (updated) {
            return overwriteFile(filename, newLines);
        }
        return false;
    }

    // Check if file exists
    public static boolean fileExists(String filename) {
        String fullPath = getFullPath(filename);
        File file = new File(fullPath);
        return file.exists();
    }

    // Delete entire file
    public static boolean deleteFile(String filename) {
        String fullPath = getFullPath(filename);
        File file = new File(fullPath);
        if (file.exists()) {
            return file.delete();
        }
        return false;
    }

    // Get data directory path
    public static String getDataDirectory() {
        return DATA_DIR;
    }

    // List all files in data directory
    public static List<String> getAllDataFiles() {
        List<String> files = new ArrayList<>();
        File dir = new File(DATA_DIR);
        if (dir.exists() && dir.isDirectory()) {
            File[] fileList = dir.listFiles();
            if (fileList != null) {
                for (File file : fileList) {
                    files.add(file.getName());
                }
            }
        }
        return files;
    }
}