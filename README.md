# Khedmni-App
# 💼 Khedmni — Job & Internship Finder App

Khedmni is a **mobile application** developed using **Flutter** to help students and young professionals **find job and internship opportunities** easily.  
The app connects candidates and companies in one simple, modern, and user-friendly platform.

---

## 🧠 About the Project

**Khedmni** was built as part of our **Mobile Development Course Project** at **ENSIA**.  
Our goal is to create a practical app that simplifies internship and job seeking while improving our Flutter development skills and teamwork using GitHub.

---

## 🧑‍💻 Team Members
| Name | Role |
|------|------|
| Leena IKHLEF | Team Leader |
| Aya Hoggas | Developer |
| Oumaima Boucekkine | Developer |
| Lyna Selsabila Remadi | Developer |

---

## 🏗️ Project Structure
```bash
Khedmni/
├── app/ # Flutter application
│ ├── lib/
│ │ ├── main.dart
│ │ ├── screens/ # all app pages (Home, Login, etc.)
│ │ ├── widgets/ # reusable UI components
│ │ ├── models/ # data models (User, Job, etc.)
│ │ ├── services/ # API or Firebase logic
│ │ ├── providers/ # state management (if used)
│ │ └── utils/ # helper functions, constants
│ ├── assets/
│ │ ├── images/
│ │ ├── icons/
│ │ └── fonts/
│ ├── pubspec.yaml
│ └── README.md
│
├── docs/ # project documentation
│ ├── requirements.md
│ ├── design.md
│ ├── api_endpoints.md
│ └── screenshots/
│
├── presentations/ # slides, reports, etc.
│ └── final_presentation.pptx
│
├── .gitignore
├── README.md
└── LICENSE
```

## 🌿 Git Branching & Collaboration Workflow

To ensure smooth teamwork and avoid code conflicts, **Khedmni** follows a clear and organized Git branching model.  
This structure helps every developer work independently while keeping the main project stable.

---

### 🧭 Branching Model Overview

| Branch Name | Purpose |
|--------------|----------|
| `main` | The **stable release branch**. It always contains a working version of the app that can be presented or deployed. |
| `dev` | The **development branch**, where new features are merged and tested together before going to `main`. |
| `feature/<name>` | Temporary **feature branches** created by each team member for specific pages or features. |

---

## 🚀 Deployment
We added basic deployment instructions and GitHub Actions workflows to build the Flutter app and deploy the email service in `docs/deployment.md`. The service can be deployed to **Render** (free tier) with the included `Dockerfile` under `services/email_sender` and the workflows in `.github/workflows/`.


---

### 🌱 Step-by-Step: How to Work with Branches

#### 🪄 1. Clone the project (first time only)
```bash
https://github.com/lolo-ikh/Khedmni-App.git
cd khedmni
```
#### 2. Switch to the development branch

Before starting any work, make sure you're on the dev branch:
```bash
git checkout dev
```
#### 3. Create your own feature branch

Each team member should create a separate branch for their work.

Example — Leena works on the login screen:
```bash
git checkout -b feature/login_screen
```
