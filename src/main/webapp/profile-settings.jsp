<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.registration.model.User" %>
<%@ page import="com.registration.model.Student" %>
<%@ page import="com.registration.model.Admin" %>
<%@ page import="com.registration.model.LecturerUser" %>
<%@ page import="com.registration.model.Lecturer" %>
<%@ page import="com.registration.dao.LecturerDAO" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User user       = (User) sess.getAttribute("user");
    String username = (String) sess.getAttribute("username");
    String role     = (String) sess.getAttribute("role");

    // Role-specific data
    Student  student  = "student".equals(role)  ? (Student)  user : null;
    Admin    admin    = "admin".equals(role)     ? (Admin)    user : null;
    LecturerUser lu   = "lecturer".equals(role) ? (LecturerUser) user : null;
    Lecturer lecturer = null;
    if (lu != null) {
        LecturerDAO lDAO = new LecturerDAO();
        lecturer = lDAO.getLecturerById(lu.getLecturerId());
    }

    // Dashboard back-link
    String dashUrl = "student".equals(role) ? "student-dashboard.jsp"
                   : "admin".equals(role)   ? "admin"
                   : "lecturer-dashboard";

    // Flash messages
    String success = request.getParameter("success");
    String error   = request.getParameter("error");

    String successMsg = null;
    if ("profile_updated".equals(success)) successMsg = "Profile updated successfully!";
    else if ("password_changed".equals(success)) successMsg = "Password changed successfully!";

    String errorMsg = null;
    if ("wrong_password".equals(error))    errorMsg = "Current password is incorrect.";
    else if ("password_mismatch".equals(error)) errorMsg = "New passwords do not match.";
    else if ("password_short".equals(error))    errorMsg = "Password must be at least 6 characters.";
    else if ("username_taken".equals(error))    errorMsg = "That username is already taken.";
    else if ("email_taken".equals(error))       errorMsg = "That email is already in use.";
    else if ("save_failed".equals(error))       errorMsg = "Could not save changes. Please try again.";

    // Avatar initial
    String initial = username.substring(0, 1).toUpperCase();

    // Accent colour by role
    String accent    = "student".equals(role) ? "#a855f7" : "admin".equals(role) ? "#3b82f6" : "#06b6d4";
    String accentDim = "student".equals(role) ? "rgba(168,85,247,0.2)" : "admin".equals(role) ? "rgba(59,130,246,0.2)" : "rgba(6,182,212,0.2)";
    String gradient  = "student".equals(role) ? "linear-gradient(135deg,#a855f7,#7c3aed)"
                     : "admin".equals(role)   ? "linear-gradient(135deg,#3b82f6,#1d4ed8)"
                     : "linear-gradient(135deg,#06b6d4,#0891b2)";
    String roleLabel = "student".equals(role) ? "Student" : "admin".equals(role) ? "Administrator" : "Lecturer";
    String roleIcon  = "student".equals(role) ? "fa-graduation-cap" : "admin".equals(role) ? "fa-shield-halved" : "fa-chalkboard-teacher";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings | CourseReg</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --accent: <%= accent %>;
            --accent-dim: <%= accentDim %>;
            --gradient: <%= gradient %>;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Blobs */
        .blob { position: fixed; border-radius: 50%; filter: blur(80px); opacity: 0.25; animation: float 7s ease-in-out infinite; pointer-events: none; z-index: 0; }
        .blob-1 { width: 420px; height: 420px; background: var(--gradient); top: 5%; left: -6%; }
        .blob-2 { width: 520px; height: 520px; background: linear-gradient(135deg,#06b6d4,#3b82f6); bottom: -5%; right: -6%; animation-delay: -3s; }
        @keyframes float { 0%,100% { transform: translate(0,0) scale(1); } 50% { transform: translate(25px,-25px) scale(1.04); } }

        /* Navbar */
        .navbar { background: rgba(255,255,255,0.05); backdrop-filter: blur(20px); padding: .8rem 0; border-bottom: 1px solid rgba(255,255,255,.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        .navbar-brand { font-size: 1.6rem; font-weight: 800; background: linear-gradient(135deg,#fff,var(--accent)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-back { color: rgba(255,255,255,.8); text-decoration: none; font-weight: 500; padding: 8px 18px; border-radius: 40px; transition: .25s; border: 1px solid rgba(255,255,255,.15); font-size: .85rem; }
        .nav-back:hover { background: rgba(255,255,255,.1); color: #fff; }

        /* Page Layout */
        .page { padding: 100px 0 60px; position: relative; z-index: 1; }

        /* Header */
        .profile-header {
            background: rgba(255,255,255,.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 28px;
            padding: 28px 32px;
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            gap: 22px;
        }
        .avatar-xl {
            width: 76px; height: 76px;
            background: var(--gradient);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem; font-weight: 700; color: #fff;
            flex-shrink: 0;
            box-shadow: 0 8px 24px rgba(0,0,0,.35);
        }
        .profile-header h1 { font-size: 1.6rem; font-weight: 700; margin-bottom: 4px; }
        .role-pill {
            display: inline-flex; align-items: center; gap: 6px;
            background: var(--accent-dim); color: var(--accent);
            border: 1px solid var(--accent); border-radius: 30px;
            padding: 4px 14px; font-size: .75rem; font-weight: 600;
        }

        /* Tabs */
        .tab-bar {
            display: flex; gap: 8px;
            background: rgba(255,255,255,.05);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 16px;
            padding: 6px;
            margin-bottom: 24px;
        }
        .tab-btn {
            flex: 1; padding: 10px 16px; border: none; border-radius: 12px;
            background: transparent; color: rgba(255,255,255,.6);
            font-weight: 600; font-size: .875rem; cursor: pointer; transition: .25s;
        }
        .tab-btn.active { background: var(--gradient); color: #fff; box-shadow: 0 4px 12px rgba(0,0,0,.25); }
        .tab-btn:hover:not(.active) { background: rgba(255,255,255,.08); color: #fff; }

        /* Cards */
        .settings-card {
            background: rgba(255,255,255,.05);
            backdrop-filter: blur(14px);
            border: 1px solid rgba(255,255,255,.1);
            border-radius: 24px;
            padding: 28px 32px;
        }
        .settings-card .section-label {
            font-size: .7rem; font-weight: 700; letter-spacing: .1em;
            color: var(--accent); text-transform: uppercase;
            margin-bottom: 20px; display: flex; align-items: center; gap: 8px;
        }
        .settings-card .section-label::after {
            content: ''; flex: 1; height: 1px; background: rgba(255,255,255,.08);
        }

        /* Form fields */
        .field-group { margin-bottom: 18px; }
        .field-group label { display: block; font-size: .8rem; font-weight: 600; color: rgba(255,255,255,.7); margin-bottom: 7px; }
        .field-group label i { margin-right: 6px; color: var(--accent); }
        .form-ctrl {
            width: 100%; padding: 12px 16px;
            background: rgba(255,255,255,.07);
            border: 1px solid rgba(255,255,255,.15);
            border-radius: 12px; color: #fff;
            font-size: .875rem; font-family: 'Inter', sans-serif;
            transition: border-color .25s, background .25s;
            outline: none;
        }
        .form-ctrl:focus { border-color: var(--accent); background: rgba(255,255,255,.1); }
        .form-ctrl::placeholder { color: rgba(255,255,255,.3); }
        .form-ctrl[disabled] { opacity: .45; cursor: not-allowed; }
        select.form-ctrl option { background: #1e1b4b; color: #fff; }

        /* Password field with toggle */
        .pw-wrap { position: relative; }
        .pw-wrap .form-ctrl { padding-right: 44px; }
        .pw-toggle {
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            background: none; border: none; color: rgba(255,255,255,.4); cursor: pointer;
            transition: color .2s; padding: 0;
        }
        .pw-toggle:hover { color: var(--accent); }

        /* Hint text */
        .field-hint { font-size: .72rem; color: rgba(255,255,255,.4); margin-top: 5px; }

        /* Strength bar */
        .strength-bar { height: 4px; border-radius: 4px; background: rgba(255,255,255,.1); margin-top: 8px; overflow: hidden; }
        .strength-fill { height: 100%; width: 0; border-radius: 4px; transition: width .3s, background .3s; }

        /* Submit button */
        .btn-save {
            display: inline-flex; align-items: center; gap: 8px;
            background: var(--gradient); color: #fff; border: none;
            padding: 12px 28px; border-radius: 40px; font-weight: 700;
            font-size: .875rem; cursor: pointer; transition: .25s;
        }
        .btn-save:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0,0,0,.3); }
        .btn-save:active { transform: translateY(0); }

        /* Alert banners */
        .alert-banner {
            border-radius: 14px; padding: 13px 18px;
            font-size: .85rem; margin-bottom: 20px;
            display: flex; align-items: center; gap: 10px;
            animation: fadeSlide .35s ease;
        }
        @keyframes fadeSlide { from { opacity: 0; transform: translateY(-6px); } to { opacity: 1; transform: translateY(0); } }
        .alert-success { background: rgba(16,185,129,.15); border: 1px solid rgba(16,185,129,.35); color: #6ee7b7; }
        .alert-error   { background: rgba(239,68,68,.15);  border: 1px solid rgba(239,68,68,.35);  color: #fca5a5; }

        /* Read-only info rows */
        .info-row {
            background: rgba(255,255,255,.04);
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 12px; padding: 12px 16px;
            display: flex; align-items: center; gap: 12px;
            margin-bottom: 10px; font-size: .85rem;
        }
        .info-row i { width: 20px; color: var(--accent); }
        .info-row .lbl { color: rgba(255,255,255,.5); font-size: .75rem; }
        .info-row .val { color: rgba(255,255,255,.9); font-weight: 500; }

        /* Tab panes */
        .tab-pane { display: none; }
        .tab-pane.active { display: block; }

        @media (max-width: 768px) {
            .page { padding: 90px 0 50px; }
            .profile-header { flex-direction: column; text-align: center; gap: 14px; }
            .settings-card { padding: 20px 18px; }
        }
    </style>
</head>
<body>

<div class="blob blob-1"></div>
<div class="blob blob-2"></div>

<!-- Navbar -->
<nav class="navbar">
    <div class="container d-flex align-items-center justify-content-between">
        <a class="navbar-brand" href="<%= dashUrl %>">Course<span>Reg</span></a>
        <a class="nav-back" href="<%= dashUrl %>">
            <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
        </a>
    </div>
</nav>

<!-- Page -->
<div class="page">
    <div class="container" style="max-width: 760px;">

        <!-- Alert banners -->
        <% if (successMsg != null) { %>
        <div class="alert-banner alert-success">
            <i class="fas fa-check-circle fa-lg"></i>
            <span><%= successMsg %></span>
        </div>
        <% } %>
        <% if (errorMsg != null) { %>
        <div class="alert-banner alert-error">
            <i class="fas fa-exclamation-circle fa-lg"></i>
            <span><%= errorMsg %></span>
        </div>
        <% } %>

        <!-- Profile header -->
        <div class="profile-header">
            <div class="avatar-xl"><%= initial %></div>
            <div>
                <h1><%= username %></h1>
                <div class="role-pill">
                    <i class="fas <%= roleIcon %>"></i> <%= roleLabel %>
                </div>
                <div class="mt-2" style="color:rgba(255,255,255,.5); font-size:.8rem;">
                    <i class="fas fa-envelope me-1"></i><%= user.getEmail() %>
                    &nbsp;&nbsp;<i class="fas fa-id-badge me-1"></i><%= user.getId() %>
                </div>
            </div>
        </div>

        <!-- Tab bar -->
        <div class="tab-bar">
            <button class="tab-btn active" onclick="switchTab('profile', this)">
                <i class="fas fa-user-pen me-2"></i>Edit Profile
            </button>
            <button class="tab-btn" onclick="switchTab('password', this)">
                <i class="fas fa-lock me-2"></i>Change Password
            </button>
            <button class="tab-btn" onclick="switchTab('info', this)">
                <i class="fas fa-circle-info me-2"></i>Account Info
            </button>
        </div>

        <!-- ── TAB: EDIT PROFILE ── -->
        <div id="tab-profile" class="tab-pane active">
            <div class="settings-card">
                <div class="section-label"><i class="fas fa-user-pen"></i> Profile Information</div>
                <form action="update-profile" method="post" onsubmit="return confirmSave()">
                    <input type="hidden" name="action" value="profile">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-at"></i>Username</label>
                                <input type="text" name="username" class="form-ctrl"
                                       value="<%= user.getUsername() %>" required
                                       minlength="3" maxlength="30"
                                       pattern="[a-zA-Z0-9_.]+"
                                       title="Letters, numbers, underscores and dots only">
                                <div class="field-hint">Used to log in. Letters, numbers, _ and . only.</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-envelope"></i>Email Address</label>
                                <input type="email" name="email" class="form-ctrl"
                                       value="<%= user.getEmail() %>" required>
                            </div>
                        </div>

                        <%-- Student-specific fields --%>
                        <% if (student != null) { %>
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-building-columns"></i>Department</label>
                                <input type="text" name="department" class="form-ctrl"
                                       value="<%= student.getDepartment() %>" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-calendar-days"></i>Semester</label>
                                <select name="semester" class="form-ctrl">
                                    <% for (int i = 1; i <= 8; i++) { %>
                                        <option value="<%= i %>" <%= student.getSemester() == i ? "selected" : "" %>>
                                            Semester <%= i %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        <% } %>

                        <%-- Lecturer-specific fields --%>
                        <% if (lecturer != null) { %>
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-phone"></i>Phone Number</label>
                                <input type="text" name="phone" class="form-ctrl"
                                       value="<%= lecturer.getPhone() %>">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="field-group">
                                <label><i class="fas fa-flask"></i>Specialization</label>
                                <input type="text" name="specialization" class="form-ctrl"
                                       value="<%= lecturer.getSpecialization() %>">
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <div class="mt-3 d-flex gap-3 align-items-center flex-wrap">
                        <button type="submit" class="btn-save">
                            <i class="fas fa-floppy-disk"></i> Save Changes
                        </button>
                        <a href="<%= dashUrl %>" style="color:rgba(255,255,255,.5); font-size:.85rem; text-decoration:none;">
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- ── TAB: CHANGE PASSWORD ── -->
        <div id="tab-password" class="tab-pane">
            <div class="settings-card">
                <div class="section-label"><i class="fas fa-key"></i> Change Password</div>
                <form action="update-profile" method="post" id="pwForm">
                    <input type="hidden" name="action" value="password">

                    <div class="field-group">
                        <label><i class="fas fa-lock-open"></i>Current Password</label>
                        <div class="pw-wrap">
                            <input type="password" name="currentPassword" id="currentPw"
                                   class="form-ctrl" required placeholder="Enter your current password">
                            <button type="button" class="pw-toggle" onclick="togglePw('currentPw', this)">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="field-group">
                        <label><i class="fas fa-lock"></i>New Password</label>
                        <div class="pw-wrap">
                            <input type="password" name="newPassword" id="newPw"
                                   class="form-ctrl" required placeholder="At least 6 characters"
                                   minlength="6" oninput="checkStrength(this.value)">
                            <button type="button" class="pw-toggle" onclick="togglePw('newPw', this)">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                        <div class="field-hint" id="strengthText">Enter a new password</div>
                    </div>

                    <div class="field-group">
                        <label><i class="fas fa-lock"></i>Confirm New Password</label>
                        <div class="pw-wrap">
                            <input type="password" name="confirmPassword" id="confirmPw"
                                   class="form-ctrl" required placeholder="Repeat new password"
                                   oninput="checkMatch()">
                            <button type="button" class="pw-toggle" onclick="togglePw('confirmPw', this)">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <div class="field-hint" id="matchHint"></div>
                    </div>

                    <div class="mt-3">
                        <button type="submit" class="btn-save" onclick="return validatePwForm()">
                            <i class="fas fa-key"></i> Update Password
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- ── TAB: ACCOUNT INFO ── -->
        <div id="tab-info" class="tab-pane">
            <div class="settings-card">
                <div class="section-label"><i class="fas fa-circle-info"></i> Account Details</div>

                <div class="info-row">
                    <i class="fas fa-id-badge"></i>
                    <div><div class="lbl">User ID</div><div class="val"><%= user.getId() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-at"></i>
                    <div><div class="lbl">Username</div><div class="val"><%= user.getUsername() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-envelope"></i>
                    <div><div class="lbl">Email</div><div class="val"><%= user.getEmail() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas <%= roleIcon %>"></i>
                    <div><div class="lbl">Role</div><div class="val"><%= roleLabel %></div></div>
                </div>

                <% if (student != null) { %>
                <div class="info-row">
                    <i class="fas fa-id-card"></i>
                    <div><div class="lbl">Student ID</div><div class="val"><%= student.getStudentId() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-building-columns"></i>
                    <div><div class="lbl">Department</div><div class="val"><%= student.getDepartment() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-calendar-days"></i>
                    <div><div class="lbl">Semester</div><div class="val">Semester <%= student.getSemester() %></div></div>
                </div>
                <% } %>

                <% if (admin != null) { %>
                <div class="info-row">
                    <i class="fas fa-shield-halved"></i>
                    <div><div class="lbl">Admin Code</div><div class="val"><%= admin.getAdminCode() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-unlock-keyhole"></i>
                    <div><div class="lbl">Permissions</div><div class="val"><%= admin.getPermissions() %></div></div>
                </div>
                <% } %>

                <% if (lecturer != null) { %>
                <div class="info-row">
                    <i class="fas fa-id-card"></i>
                    <div><div class="lbl">Lecturer ID</div><div class="val"><%= lecturer.getLecturerId() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-building-columns"></i>
                    <div><div class="lbl">Department</div><div class="val"><%= lecturer.getDepartment() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-flask"></i>
                    <div><div class="lbl">Specialization</div><div class="val"><%= lecturer.getSpecialization() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-certificate"></i>
                    <div><div class="lbl">Qualification</div><div class="val"><%= lecturer.getQualification() %></div></div>
                </div>
                <div class="info-row">
                    <i class="fas fa-calendar-check"></i>
                    <div><div class="lbl">Joining Date</div><div class="val"><%= lecturer.getJoiningDate() %></div></div>
                </div>
                <% } %>
            </div>
        </div>

    </div><!-- /container -->
</div><!-- /page -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Tab switching ────────────────────────────────────────────────────────
    function switchTab(name, btn) {
        document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + name).classList.add('active');
        btn.classList.add('active');
    }

    // Auto-open password tab if error was password-related
    window.addEventListener('DOMContentLoaded', function () {
        const param = new URLSearchParams(window.location.search);
        const err   = param.get('error');
        const ok    = param.get('success');
        if (err === 'wrong_password' || err === 'password_mismatch' || err === 'password_short' || ok === 'password_changed') {
            document.querySelectorAll('.tab-btn')[1].click();
        }
    });

    // ── Password visibility toggle ───────────────────────────────────────────
    function togglePw(id, btn) {
        const input = document.getElementById(id);
        const icon  = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    }

    // ── Password strength ────────────────────────────────────────────────────
    function checkStrength(pw) {
        const fill = document.getElementById('strengthFill');
        const hint = document.getElementById('strengthText');
        let score = 0;
        if (pw.length >= 6)  score++;
        if (pw.length >= 10) score++;
        if (/[A-Z]/.test(pw) && /[a-z]/.test(pw)) score++;
        if (/\d/.test(pw)) score++;
        if (/[^a-zA-Z0-9]/.test(pw)) score++;

        const levels = [
            { w: '0%',   c: 'transparent',   t: 'Enter a new password' },
            { w: '25%',  c: '#ef4444',        t: 'Weak' },
            { w: '50%',  c: '#f59e0b',        t: 'Fair' },
            { w: '75%',  c: '#3b82f6',        t: 'Good' },
            { w: '100%', c: '#10b981',        t: 'Strong ✓' },
        ];
        const lvl = levels[Math.min(score, 4)];
        fill.style.width      = lvl.w;
        fill.style.background = lvl.c;
        hint.textContent      = lvl.t;
        hint.style.color      = lvl.c === 'transparent' ? 'rgba(255,255,255,.4)' : lvl.c;
    }

    // ── Password match ───────────────────────────────────────────────────────
    function checkMatch() {
        const nw   = document.getElementById('newPw').value;
        const conf = document.getElementById('confirmPw').value;
        const hint = document.getElementById('matchHint');
        if (!conf) { hint.textContent = ''; return; }
        if (nw === conf) {
            hint.textContent = '✓ Passwords match';
            hint.style.color = '#10b981';
        } else {
            hint.textContent = '✗ Passwords do not match';
            hint.style.color = '#ef4444';
        }
    }

    function validatePwForm() {
        const nw   = document.getElementById('newPw').value;
        const conf = document.getElementById('confirmPw').value;
        if (nw !== conf) { alert('New passwords do not match.'); return false; }
        if (nw.length < 6) { alert('Password must be at least 6 characters.'); return false; }
        return true;
    }

    // ── Confirm profile save ─────────────────────────────────────────────────
    function confirmSave() { return true; } // Could add a confirm dialog here
</script>
</body>
</html>
