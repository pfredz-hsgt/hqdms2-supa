## HQDMS - Hospital Quota Drug Management System

A comprehensive web-based system for managing hospital drug quotas, patient enrollments, and prescription tracking. 

**Note: This project has been migrated to a Serverless architecture using Supabase.**

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Supabase Setup](#supabase-setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Mobile Support](#mobile-support)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## 🚀 Features

- **Drug Management**: Add, edit, and manage drug information with quota tracking.
- **Patient Management**: Register and manage patient information.
- **Enrollment System**: Enroll patients in drug programs with prescription tracking.
- **Department Management**: Organize drugs by medical departments.
- **Refill Tracking**: Monitor patient refill history and identify potential defaulters.
- **Reporting & Analytics**: Dashboard with key metrics and downloadable Excel reports.
- **System Control**: Admin settings to enable/disable enrollments, new drugs, etc.
- **User Authentication**: Secure login system powered by Supabase Auth (using IC Number as Login ID).
- **Responsive Design**: Optimized for desktop and mobile devices.

## 🏗 Architecture

- **Frontend**: React.js with Ant Design (UI Framework).
- **Backend/Database**: Supabase (PostgreSQL + Auth + Storage).
- **Mobile**: Capacitor (Android support).
- **Data Export**: XLSX for Excel report generation.

## 📋 Prerequisites

Before installing HQDMS, ensure you have:

1. **Node.js** (v16 or higher)
2. **npm** (comes with Node.js)
3. **Supabase Account**: A project created on [supabase.com](https://supabase.com/)

## 🛠 Installation

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd hqdms2s
```

### Step 2: Install Dependencies

```bash
npm install
```

## ☁️ Supabase Setup

To get the backend running, you need to set up your Supabase project:

1. **Database Schema**:
   - Go to your Supabase SQL Editor.
   - Run the contents of `database/supabase_schema.sql` to create the necessary tables (`departments`, `drugs`, `patients`, `enrollments`, `settings`, etc.).

2. **Authentication**:
   - Enable Email auth in Supabase (though the system uses fake emails under the hood to support IC Number login).
   - The system automatically handles registration of users via the Admin Panel.

3. **RPC Functions** (Optional/As Needed):
   - Some features like "Reset Password to IC" might require custom RPC functions defined in Supabase.

## ⚙️ Configuration

Create a `.env` file in the root directory and add your Supabase credentials:

```bash
REACT_APP_SUPABASE_URL=https://your-project-id.supabase.co
REACT_APP_SUPABASE_ANON_KEY=your-anon-public-key
```

## 🚀 Running the Application

### Development Mode

```bash
npm start
```
The application will start on `http://localhost:3000`.

### Production Build

```bash
npm run build
```

## 📱 Mobile Support (Capacitor)

The project includes Capacitor for Android deployment:

1. **Sync changes**: `npm run cap:sync`
2. **Open in Android Studio**: `npm run cap:open`
3. **Build Android**: `npm run android:build`

## 🚀 Deployment

### Static Hosting
Since the backend is fully handled by Supabase, the React frontend can be hosted as a static site on:
- Supabase Hosting
- Vercel / Netlify
- GitHub Pages

### Traditional Server (Apache/Nginx)
If deploying to a traditional server using the provided build scripts:
1. Build the project: `npm run build`
2. Copy the contents of the `build` folder to your web root (e.g., `/var/www/html/`).

## 🔧 Troubleshooting

### Common Issues

1. **Supabase Connectivity**:
   - Ensure your `.env` variables are correct.
   - Check Supabase "API" settings for the correct URL and Anon Key.
   - Verify that your IP is allowed in Supabase Database settings (if using standard SQL connection, though the app uses the REST API).

2. **Login Issues**:
   - The system uses `ic_number@hqdms.com` as a dummy email for Supabase Auth. Ensure the user exists in both the `users` table and Supabase Auth.

3. **Data Not Loading**:
   - Check the browser console for "Supabase API Error" messages.
   - Ensure you have run the migration script in `database/supabase_schema.sql`.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---
**HQDMS v0.8.0 (Beta)** - Hospital Quota Drug Management System
© 2026 Jabatan Farmasi Hospital Segamat. All Rights Reserved.
