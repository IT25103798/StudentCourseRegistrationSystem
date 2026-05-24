package com.registration.util;

import com.registration.model.RegistrationRequest;
import java.io.*;
import java.util.*;

public class QueueManager {
    private static Queue<RegistrationRequest> registrationQueue = new LinkedList<>();
    private static final String QUEUE_FILE = "queue.txt";

    // Load queue from file on startup
    static {
        loadQueueFromFile();
    }

    // Add to queue (FIFO) and save to file
    public static synchronized boolean enqueue(RegistrationRequest request) {
        try {
            registrationQueue.add(request);
            saveQueueToFile();
            System.out.println("Queue: Added request " + request.getRequestId() + " to queue. Queue size: " + registrationQueue.size());
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Remove from queue (FIFO) and save to file
    public static synchronized RegistrationRequest dequeue() {
        RegistrationRequest request = registrationQueue.poll();
        if (request != null) {
            saveQueueToFile();
            System.out.println("Queue: Removed request " + request.getRequestId() + " from queue. Queue size: " + registrationQueue.size());
        }
        return request;
    }

    // Peek at front of queue
    public static synchronized RegistrationRequest peek() {
        return registrationQueue.peek();
    }

    // Get all queue items
    public static synchronized List<RegistrationRequest> getAllQueueItems() {
        return new ArrayList<>(registrationQueue);
    }

    // Get queue size
    public static synchronized int getQueueSize() {
        return registrationQueue.size();
    }

    // Remove specific request by ID and save to file
    public static synchronized boolean removeFromQueue(String requestId) {
        Queue<RegistrationRequest> newQueue = new LinkedList<>();
        boolean removed = false;

        while (!registrationQueue.isEmpty()) {
            RegistrationRequest req = registrationQueue.poll();
            if (!req.getRequestId().equals(requestId)) {
                newQueue.add(req);
            } else {
                removed = true;
                System.out.println("Queue: Removed specific request " + requestId);
            }
        }

        registrationQueue = newQueue;
        if (removed) {
            saveQueueToFile();
        }
        return removed;
    }

    // Save queue to file
    private static void saveQueueToFile() {
        try {
            List<String> lines = new ArrayList<>();
            for (RegistrationRequest req : registrationQueue) {
                lines.add(req.toString());
            }
            boolean saved = FileHandler.overwriteFile(QUEUE_FILE, lines);
            System.out.println("Queue saved to file: " + saved + " | Items: " + lines.size());
        } catch (Exception e) {
            System.err.println("Error saving queue to file");
            e.printStackTrace();
        }
    }

    // Load queue from file
    private static void loadQueueFromFile() {
        registrationQueue.clear();
        List<String> lines = FileHandler.readAllLines(QUEUE_FILE);

        System.out.println("Loading queue from file. Found " + lines.size() + " lines");

        for (String line : lines) {
            String[] parts = line.split("\\|");
            if (parts.length >= 7) {
                try {
                    RegistrationRequest req = new RegistrationRequest(
                            parts[0], parts[1], parts[2], parts[3], parts[4], Integer.parseInt(parts[6])
                    );
                    registrationQueue.add(req);
                    System.out.println("Loaded request: " + parts[0]);
                } catch (Exception e) {
                    System.err.println("Error parsing queue line: " + line);
                }
            }
        }
        System.out.println("Queue loaded. Size: " + registrationQueue.size());
    }
}
