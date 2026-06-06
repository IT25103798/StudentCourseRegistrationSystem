# 🎓 Student Course Registration System 

A full-stack **Java Web Application** for managing university course registrations, built with Java Servlets, JSP, and file-based persistence — no database required.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Structures & Algorithms](#data-structures--algorithms)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Default Credentials](#default-credentials)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

---

## Overview

The Student Course Registration System is a role-based web application that handles the complete lifecycle of course enrollment at a university. Students can browse and register for courses, lecturers can manage their course rosters, and administrators have full control over users, courses, and the registration pipeline.

Rather than relying on a traditional database, all data is persisted in pipe-delimited `.txt` files under the `data/` directory — making the system lightweight and easy to set up.

---

## ✨ Features

### 👤 Student
- Sign up and log in securely
- Browse available courses with seat availability
- Submit course registration requests (queued for admin approval)
- View enrolled courses and registration status
- Track queue position in real time
- Submit and manage course feedback
- Update profile settings

### 🛡️ Admin
- Dashboard with system-wide stats
- Approve or reject queued registration requests
- Manage students, lecturers, and other admins
- Create, update, and delete courses
- View and manage feedback submissions
- Generate enrollment reports

### 🎓 Lecturer
- Dedicated dashboard
- View registered students per course
- Manage course-specific feedback

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 17 |
| Web Layer | Java Servlets (javax.servlet 4.0) + JSP 2.3 |
| Templating | JSTL 1.2 |
| Build Tool | Apache Maven |
| Server | Apache Tomcat (via SmartTomcat) |
| Persistence | Flat file storage (pipe-delimited `.txt`) |
| Packaging | WAR |

---

## 📁 Project Structure

```
StudentCourseRegistrationSystem/
├── data/                                        # Flat-file data store
│   ├── courses.txt
│   ├── feedbacks.txt
│   ├── lecturers.txt
│   ├── queue.txt
│   ├── registrations.txt
│   ├── rejected_registrations.txt
│   ├── students.txt
│   └── users.txt
│
├── src/main/
│   ├── java/com/registration/
│   │   ├── dao/                                 # Data Access Objects
│   │   │   ├── CourseDAO.java
│   │   │   ├── FeedbackDAO.java
│   │   │   ├── LecturerDAO.java
│   │   │   ├── RegistrationDAO.java
│   │   │   └── UserDAO.java
│   │   │
│   │   ├── model/                               # Domain models
│   │   │   ├── Admin.java
│   │   │   ├── Course.java
│   │   │   ├── Feedback.java
│   │   │   ├── Lecturer.java
│   │   │   ├── LecturerUser.java
│   │   │   ├── Registration.java
│   │   │   ├── RegistrationRequest.java
│   │   │   ├── Student.java
│   │   │   └── User.java                        # Abstract base class
│   │   │
│   │   ├── servlet/                             # HTTP request handlers
│   │   │   ├── AdminManagementServlet.java
│   │   │   ├── AdminServlet.java
│   │   │   ├── ApproveFeedbackServlet.java
│   │   │   ├── CourseServlet.java
│   │   │   ├── DeleteStudentServlet.java
│   │   │   ├── EnrollmentManagementServlet.java
│   │   │   ├── FeedbackServlet.java
│   │   │   ├── LecturerDashboardServlet.java
│   │   │   ├── LecturerServlet.java
│   │   │   ├── LoginServlet.java
│   │   │   ├── LogoutServlet.java
│   │   │   ├── QueueStatusServlet.java
│   │   │   ├── RegisterServlet.java
│   │   │   ├── RegistrationServlet.java
│   │   │   ├── UpdateFeedbackServlet.java
│   │   │   ├── UpdateProfileServlet.java
│   │   │   └── UpdateStudentServlet.java
│   │   │
│   │   └── util/                                # Utilities
│   │       ├── FileHandler.java                 # File I/O abstraction
│   │       ├── QueueManager.java                # FIFO registration queue
│   │       └── SortUtil.java                    # Insertion sort algorithms
│   │
│   └── webapp/                                  # JSP views + web config
│       ├── WEB-INF/
│       │   └── web.xml                          # Servlet mappings
│       ├── admin-dashboard.jsp
│       ├── admin-feedback.jsp
│       ├── admin-queue.jsp
│       ├── course-list.jsp
│       ├── index.jsp
│       ├── lecturer-dashboard.jsp
│       ├── login.jsp
│       ├── manage-admins.jsp
│       ├── manage-enrollments.jsp
│       ├── manage-lecturers.jsp
│       ├── manage-students.jsp
│       ├── profile-settings.jsp
│       ├── queue-status.jsp
│       ├── register-course.jsp
│       ├── reports.jsp
│       ├── signup.jsp
│       ├── student-courses.jsp
│       └── student-dashboard.jsp
│
│
└── pom.xml                                      # Maven build configuration
```

---

## ⚙️ Data Structures & Algorithms

This project intentionally applies core CS concepts:

### Queue — Registration Pipeline
`QueueManager.java` implements a **FIFO queue** (`java.util.LinkedList`) for registration requests. When a student registers for a course, their request is enqueued and persisted to `queue.txt`. Admins process requests from the front of the queue, ensuring fair first-come-first-served handling.

```
Student submits request → enqueue() → queue.txt
Admin approves/rejects  → dequeue() → registrations.txt / rejected_registrations.txt
```

### Insertion Sort — Course Listing
`SortUtil.java` implements **insertion sort** in three flavors for course browsing:

| Method | Sort Key | Order |
|---|---|---|
| `sortCoursesByDemand()` | Available seats | Ascending (most demanded first) |
| `sortCoursesByName()` | Course name | Alphabetical |
| `sortCoursesByCredits()` | Credits | Descending |

### OOP Design Patterns
- **Inheritance & Abstraction** — `User` is an abstract class extended by `Student`, `Admin`, and `Lecturer`, each implementing `getDashboardPath()`.
- **Encapsulation** — All model fields are private with getters/setters.
- **DAO Pattern** — All file I/O is encapsulated in dedicated DAO classes, keeping servlets clean.

---

## 🚀 Getting Started

### Prerequisites

- Java 17+
- Apache Maven 3.6+
- Apache Tomcat 9.x

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/IT25103798/StudentCourseRegistrationSystem.git
   cd StudentCourseRegistrationSystem
   ```

2. **Build the project**
   ```bash
   mvn clean package
   ```

3. **Deploy to Tomcat**
   - Copy `target/CourseRegistrationSystem-1.0-SNAPSHOT.war` to your Tomcat `webapps/` directory, **or**
   - Use the IntelliJ IDEA **SmartTomcat** plugin (configuration is already included in `.smarttomcat/`).

4. **Configure the data directory**

   By default, `FileHandler.java` reads/writes files from a `data/` directory relative to the Tomcat working directory. Make sure the `data/` folder (with the provided `.txt` seed files) is accessible at runtime. You may need to set the working directory in your Tomcat run configuration to the project root.

5. **Start Tomcat and navigate to:**
   ```
   http://localhost:8080/CourseRegistrationSystem/
   ```

---

## 🔑 Default Credentials

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| Student | `Hansaka` | `asd123` |
| Lecturer | `sarah` | `sarah123` |

> ⚠️ **Note:** Passwords are stored in plain text in `data/users.txt`. This is suitable for academic/demo use only. For any real deployment, implement password hashing (e.g., BCrypt).

---

## 📖 Usage

### Student Flow
1. Sign up at `/signup.jsp` or log in with existing credentials.
2. Browse courses at **Register Course** — courses are sorted by demand, name, or credits.
3. Click **Register** on a course to submit a request to the queue.
4. Monitor your request status at **Queue Status**.
5. Once approved, the course appears under **My Courses**.

### Admin Flow
1. Log in as `admin`.
2. The **Admin Dashboard** shows system-wide stats.
3. Go to **Queue** to approve or reject pending registration requests.
4. Use **Manage Students / Lecturers / Admins** for user management.
5. Use **Manage Courses** to add, edit, or remove courses.
6. View enrollment summaries under **Reports**.

### Lecturer Flow
1. Log in as a lecturer.
2. The **Lecturer Dashboard** shows courses assigned to you.
3. View the student roster and submitted feedback per course.

---

## 🤝 Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request.

Please keep code style consistent and add comments for any new data structure or algorithm logic.

---

## 📄 License

This project was developed for academic purposes. Feel free to use and adapt it for learning.

---

## Group

**Group 53** — OOP Project, 2026

---

<p align="center">Built with ☕ Java · Servlets · JSP · Maven</p>
