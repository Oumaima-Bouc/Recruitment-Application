# 📱 MVP Development Plan - Khedmni App
**Deadline:** 6 December 2025
**Team:** Lina (Lead), Sirine, Oumaima, Salsabil (Admin/Video)

---

## **📌 EPIC FORMAT (MANDATORY)**

### **Epic Title**

**Epic Description**
**User Story** (written in this format):
> As a *user type*, I want *functionality* so that *expected benefit*.

### **Definition of Done (DoD)**
Use bullet points. Example:
* UI implemented using Flutter best practices
* Bloc/Cubit implemented
* Local DB integrated
* Navigation works without errors
* Screen tested on a real device
* Localization applied
* Dummy data used where backend is missing

### **Subtasks (Assigned to 4 members)**
Each subtask must contain:
* Clear title
* Responsibility
* Expected output (file or functionality)
* Assigned developer (Lina / Sirine / Oumaima / Salsabil)
* Estimated difficulty (S/M/L)

---

# 📚 **EPICS**

## **EPIC 1 — Project Architecture & Folder Structure Setup**

**Epic Description**
Initialize the project with necessary dependencies, folder structure, and core configurations to support a scalable MVP. This sets the foundation for State Management, Localization, and Database.

**User Story**
> As a *developer*, I want *a clean and organized project structure* so that *we can work efficiently without conflicts and manage state/data properly*.

### **Definition of Done (DoD)**
* `pubspec.yaml` updated with all MVP dependencies (Bloc, Sqflite, Intl).
* Folder structure reorganized (Logic, Data, Core).
* Theme and Constants defined.
* Main entry point cleaned and configured.
* Git ignore configured properly.

### **Subtasks**

1. **Add State Management Dependencies**
   * Add `flutter_bloc`, `equatable` to `pubspec.yaml`.
   * `pubspec.yaml`
   * **Lina** (S)

2. **Add Database & Utils Dependencies**
   * Add `sqflite`, `path`, `intl`, `shared_preferences`.
   * `pubspec.yaml`
   * **Lina** (S)

3. **Create Logic/Bloc Directory Structure**
   * Create `lib/logic/cubits` and `lib/logic/states`.
   * Folder Structure
   * **Sirine** (S)

4. **Create Data Layer Structure**
   * Create `lib/data/repositories` and `lib/data/dataproviders`.
   * Folder Structure
   * **Sirine** (S)

5. **Define App Colors & Constants**
   * Create `lib/core/constants/colors.dart` and `strings.dart`.
   * `colors.dart`
   * **Oumaima** (S)

6. **Setup App Theme**
   * Create `lib/core/theme/app_theme.dart` with light/dark mode basics.
   * `app_theme.dart`
   * **Oumaima** (M)

7. **Clean Main.dart**
   * Refactor `main.dart` to use `MultiBlocProvider` (placeholder) and Theme.
   * `main.dart`
   * **Lina** (M)

8. **Setup Asset Manager**
   * Create a helper class to manage image paths in `lib/core/utils/assets.dart`.
   * `assets.dart`
   * **Oumaima** (S)

---

## **EPIC 2 — Navigation & Routing Setup**

**Epic Description**
Implement a robust navigation system to handle transitions between all screens, including passing arguments and handling back navigation.

**User Story**
> As a *user*, I want *smooth navigation between screens* so that *I can easily access different features of the app without getting stuck*.

### **Definition of Done (DoD)**
* Named routes or Router defined for all screens.
* Navigation Service or Helper implemented.
* Bottom Navigation Bar functional.
* No "black screen" errors during navigation.

### **Subtasks**

1. **Define Route Names**
   * Create `lib/core/routes/route_names.dart` with static strings.
   * `route_names.dart`
   * **Lina** (S)

2. **Implement App Router**
   * Create `lib/core/routes/app_router.dart` with `onGenerateRoute`.
   * `app_router.dart`
   * **Lina** (M)

3. **Setup Bottom Navigation Widget**
   * Refactor `lib/widgets/custom_nav_bar.dart` to accept current index and callback.
   * `custom_nav_bar.dart`
   * **Sirine** (M)

4. **Integrate Bottom Nav in Main Layout**
   * Create a `MainLayout` screen that holds the `Scaffold` with BottomNav.
   * `main_layout.dart`
   * **Sirine** (M)

5. **Connect Auth Navigation**
   * Define flow: Welcome -> Onboarding -> Login -> Home.
   * Navigation Logic
   * **Oumaima** (M)

6. **Connect Profile Navigation**
   * Define flow: Signup -> Create Profile -> Home.
   * Navigation Logic
   * **Oumaima** (M)

7. **Handle Back Button Logic**
   * Ensure Android back button works as expected (WillPopScope).
   * `main_layout.dart`
   * **Sirine** (S)

8. **Test Navigation Flows**
   * Manual test of all defined routes.
   * Testing Report
   * **Lina** (S)

---

## **EPIC 3 — Authentication Flow**

**Epic Description**
Implement the complete authentication journey from Welcome screen to Profile creation, managed by AuthCubit.

**User Story**
> As a *new user*, I want *to sign up and create a profile* so that *I can access job offers and apply*.

### **Definition of Done (DoD)**
* UI for Welcome, Onboarding, Login, Signup, Create Profile finished.
* AuthCubit handles Login/Signup state (Loading, Success, Error).
* Input validation (email, password) implemented.
* Dummy Auth Repository simulates network delay.

### **Subtasks**

1. **Refine Welcome Screen UI**
   * Polish `lib/screens/welcome_screen.dart`.
   * `welcome_screen.dart`
   * **Oumaima** (S)

2. **Refine Onboarding Screen UI**
   * Polish `lib/screens/onboarding_screen.dart` with PageView.
   * `onboarding_screen.dart`
   * **Sirine** (M)

3. **Implement Login Screen UI**
   * Update `lib/screens/log_in.dart` with TextFields and Validation.
   * `log_in.dart`
   * **Oumaima** (M)

4. **Implement Signup Screen UI**
   * Update `lib/screens/sign_up.dart` (or `signup_screen.dart`) with Form.
   * `sign_up.dart`
   * **Sirine** (M)

5. **Implement Create Profile UI**
   * Update `lib/screens/create_profile.dart` with inputs for Name, Skills.
   * `create_profile.dart`
   * **Sirine** (M)

6. **Create AuthCubit & State**
   * Create `AuthCubit`, `AuthState` (Initial, Loading, Authenticated, Error).
   * `auth_cubit.dart`
   * **Lina** (M)

7. **Implement Dummy Auth Repository**
   * Create `AuthRepository` with `login()` and `signup()` mocking delay.
   * `auth_repository.dart`
   * **Lina** (S)

8. **Integrate Cubit in Login Screen**
   * Use `BlocConsumer` to show loading/error/navigation in Login.
   * `log_in.dart`
   * **Oumaima** (M)

9. **Integrate Cubit in Signup Screen**
   * Use `BlocConsumer` in Signup.
   * `sign_up.dart`
   * **Sirine** (M)

10. **Save User Session**
    * Use `SharedPreferences` to persist login state.
    * `auth_repository.dart`
    * **Lina** (M)

---

## **EPIC 4 — Home + Job Feed Module**

**Epic Description**
The core functionality where users view job offers. Includes the Home screen and Job Feed with filtering/listing.

**User Story**
> As a *job seeker*, I want *to browse job offers* so that *I can find a suitable position*.

### **Definition of Done (DoD)**
* Home Screen displays categories/featured jobs.
* Job Feed displays list of jobs.
* JobCubit manages list state.
* Dummy Data for jobs is rich and realistic.

### **Subtasks**

1. **Design Home Screen Header**
   * User greeting and search bar in `home_screen.dart`.
   * `home_screen.dart`
   * **Sirine** (S)

2. **Design Category Widget**
   * Horizontal list of job categories.
   * `widgets/category_item.dart`
   * **Sirine** (S)

3. **Design Job Card Widget**
   * Reusable widget for displaying a job offer summary.
   * `widgets/job_card.dart`
   * **Oumaima** (M)

4. **Implement Job Feed Screen**
   * ListView of Job Cards in `job_feed_screen.dart`.
   * `job_feed_screen.dart`
   * **Oumaima** (M)

5. **Create Job Model**
   * Define `Job` class in `lib/data/models/job.dart`.
   * `job.dart`
   * **Lina** (S)

6. **Create JobCubit**
   * Manage list of jobs, filtering logic.
   * `job_cubit.dart`
   * **Lina** (M)

7. **Generate Dummy Job Data**
   * Create a list of 10-20 dummy jobs.
   * `dummy_data.dart`
   * **Oumaima** (S)

8. **Integrate JobCubit with UI**
   * Use `BlocBuilder` to display jobs in Home and Feed.
   * `home_screen.dart`
   * **Lina** (M)

---

## **EPIC 5 — Company Profile & Job Posting Module**

**Epic Description**
Functionality for companies to view their profile and post new job offers.

**User Story**
> As a *recruiter*, I want *to post a job offer* so that *candidates can apply*.

### **Definition of Done (DoD)**
* Company Profile screen implemented.
* Post Offer screen with form validation.
* CompanyCubit manages company data and posting.
* New posts are added to the local list (in memory or DB).

### **Subtasks**

1. **Design Company Profile UI**
   * Info, Logo, and active jobs list in `company_view_screen.dart`.
   * `company_view_screen.dart`
   * **Sirine** (M)

2. **Design Post Offer Form**
   * Inputs for Title, Description, Salary in `post_offer.dart`.
   * `post_offer.dart`
   * **Sirine** (M)

3. **Create Company Model**
   * Define `Company` class.
   * `company.dart`
   * **Oumaima** (S)

4. **Create CompanyCubit**
   * Logic for fetching company info and posting jobs.
   * `company_cubit.dart`
   * **Lina** (M)

5. **Implement Post Job Logic**
   * Function to add a new job to the list.
   * `company_cubit.dart`
   * **Lina** (M)

6. **Integrate Post Offer UI**
   * Connect Form to Cubit.
   * `post_offer.dart`
   * **Sirine** (M)

7. **Dummy Company Data**
   * Create dummy data for company profile.
   * `dummy_data.dart`
   * **Oumaima** (S)

8. **Link Job Feed to Company**
   * Clicking a job should show Company Profile (Navigation).
   * Navigation Logic
   * **Lina** (S)

---

## **EPIC 6 — Notifications Module**

**Epic Description**
A system to notify users about job applications or new offers.

**User Story**
> As a *user*, I want *to receive notifications* so that *I stay updated on my activities*.

### **Definition of Done (DoD)**
* Notification Screen UI implemented.
* NotificationCubit manages list.
* Mark as read functionality.
* Dummy notifications.

### **Subtasks**

1. **Design Notification Item**
   * Widget for a single notification row.
   * `widgets/notification_item.dart`
   * **Oumaima** (S)

2. **Implement Notification Screen**
   * ListView in `notification_screen.dart`.
   * `notification_screen.dart`
   * **Oumaima** (M)

3. **Create Notification Model**
   * `NotificationModel` class.
   * `notification_model.dart`
   * **Sirine** (S)

4. **Create NotificationCubit**
   * Logic to fetch and delete notifications.
   * `notification_cubit.dart`
   * **Lina** (M)

5. **Generate Dummy Notifications**
   * List of sample notifications.
   * `dummy_data.dart`
   * **Sirine** (S)

6. **Integrate UI with Cubit**
   * Display list using BlocBuilder.
   * `notification_screen.dart`
   * **Sirine** (M)

7. **Implement "Mark as Read"**
   * Logic to change status of notification.
   * `notification_cubit.dart`
   * **Lina** (S)

8. **Empty State UI**
   * Design for when there are no notifications.
   * `notification_screen.dart`
   * **Oumaima** (S)

---

## **EPIC 7 — Local Database Integration**

**Epic Description**
Persist data locally using `sqflite` so that data remains available after app restart.

**User Story**
> As a *user*, I want *my data to be saved* so that *I don't lose my profile or posts when I close the app*.

### **Definition of Done (DoD)**
* SQLite database initialized.
* Tables created (User, Job, Company).
* CRUD operations implemented.
* Repositories updated to use DB instead of just dummy lists.

### **Subtasks**

1. **Initialize Database**
   * Create `lib/data/local/database_helper.dart` with `openDatabase`.
   * `database_helper.dart`
   * **Lina** (M)

2. **Create User Table Schema**
   * SQL query for User table.
   * `database_helper.dart`
   * **Lina** (S)

3. **Create Job Table Schema**
   * SQL query for Job table.
   * `database_helper.dart`
   * **Sirine** (S)

4. **Implement User CRUD**
   * Insert and Get User methods.
   * `user_dao.dart`
   * **Lina** (M)

5. **Implement Job CRUD**
   * Insert, Get All, and Delete Job methods.
   * `job_dao.dart`
   * **Sirine** (M)

6. **Seed Database with Dummy Data**
   * Script to insert dummy data on first launch.
   * `database_helper.dart`
   * **Oumaima** (M)

7. **Update JobRepository**
   * Switch from in-memory list to `JobDao`.
   * `job_repository.dart`
   * **Lina** (M)

8. **Update AuthRepository**
   * Switch from dummy auth to DB check.
   * `auth_repository.dart`
   * **Lina** (M)

---

## **EPIC 8 — Localization (AR/EN/FR)**

**Epic Description**
Make the app accessible to a wider audience by supporting Arabic, English, and French.

**User Story**
> As a *user*, I want *to switch the app language* so that *I can use it in my preferred language*.

### **Definition of Done (DoD)**
* `flutter_localizations` setup.
* AR, EN, FR ARB files created.
* Language switcher in Profile or Settings.
* UI supports RTL (Right-to-Left) for Arabic.

### **Subtasks**

1. **Setup Localization Config**
   * Configure `l10n.yaml` and `pubspec.yaml`.
   * Configuration
   * **Lina** (S)

2. **Create English ARB File**
   * Extract strings from Welcome/Auth screens.
   * `app_en.arb`
   * **Oumaima** (M)

3. **Create French ARB File**
   * Translate strings to French.
   * `app_fr.arb`
   * **Sirine** (M)

4. **Create Arabic ARB File**
   * Translate strings to Arabic.
   * `app_ar.arb`
   * **Sirine** (M)

5. **Implement Language Cubit**
   * Manage selected Locale state.
   * `language_cubit.dart`
   * **Lina** (S)

6. **Add Language Switcher UI**
   * Widget to toggle languages in Profile/Drawer.
   * `profile_screen.dart`
   * **Sirine** (S)

7. **Apply Translations to Auth Screens**
   * Replace hardcoded strings with `AppLocalizations`.
   * Auth Screens
   * **Oumaima** (M)

8. **Verify RTL Layout**
   * Test Arabic layout on all screens.
   * Testing
   * **Lina** (S)

---

## **EPIC 9 — State Management with Cubit/Bloc**

**Epic Description**
Finalize and refine the state management architecture. Ensure all modules are correctly using Cubits and that the global state is consistent.

**User Story**
> As a *developer*, I want *consistent state management* so that *the app behaves predictably and is easy to debug*.

### **Definition of Done (DoD)**
* All screens use `BlocBuilder`/`BlocConsumer`.
* No `setState` used for complex logic.
* Global providers (MultiBlocProvider) configured in `main.dart`.
* Error handling is consistent across Cubits.

### **Subtasks**

1. **Review AuthCubit Logic**
   * Ensure proper error handling and state updates.
   * Code Review
   * **Lina** (S)

2. **Review JobCubit Logic**
   * Optimize list updates and filtering.
   * Code Review
   * **Lina** (S)

3. **Global MultiBlocProvider Setup**
   * Ensure all Cubits are provided at the root or correct scope.
   * `main.dart`
   * **Sirine** (S)

4. **Implement Loading States UI**
   * Ensure all screens show spinners when Cubit is loading.
   * UI Polish
   * **Oumaima** (M)

5. **Implement Error States UI**
   * Show Snackbars or Error widgets on Cubit errors.
   * UI Polish
   * **Oumaima** (M)

6. **Refactor Legacy Code**
   * Remove any old `Provider` or `setState` logic if exists.
   * Refactoring
   * **Lina** (M)

7. **Unit Test: AuthCubit**
   * Write basic test for login flow.
   * `auth_cubit_test.dart`
   * **Sirine** (M)

8. **Unit Test: JobCubit**
   * Write basic test for fetching jobs.
   * `job_cubit_test.dart`
   * **Oumaima** (M)

---

## **EPIC 10 — Final MVP Integration + Phone Testing + Video Preparation + Excel Contribution File**

**Epic Description**
The final sprint to assemble the MVP, test it on real devices, record the demo, and document contributions.

**User Story**
> As a *team*, I want *to deliver a polished MVP* so that *we meet the deadline and requirements*.

### **Definition of Done (DoD)**
* App runs on real Android/iOS device.
* No critical bugs.
* Video recording (screen capture) ready.
* Excel file with tasks/hours ready.
* Code cleaned and formatted.

### **Subtasks**

1. **Full App Integration Test**
   * Walkthrough of the entire app flow together.
   * Testing
   * **Lina, Sirine, Oumaima** (L)

2. **Fix UI/UX Bugs**
   * Address visual glitches found during testing.
   * Bug Fixing
   * **Sirine & Oumaima** (M)

3. **Fix Logic Bugs**
   * Address navigation or state bugs.
   * Bug Fixing
   * **Lina & Sirine** (M)

4. **Prepare Excel Contribution File**
   * List all tasks and assignees in Excel.
   * `contributions.xlsx`
   * **Salsabil** (S)

5. **Record App Navigation Video**
   * Screen record the user stories on a real phone.
   * `demo_video.mp4`
   * **Salsabil** (M)

6. **Video Editing (Optional)**
   * Add voiceover or text overlays if needed.
   * Video Editing
   * **Salsabil** (S)

7. **Final Code Cleanup**
   * Run `flutter format` and remove unused imports.
   * Code Quality
   * **Lina** (S)

8. **Project Packaging**
   * Prepare the zip or repo for submission.
   * Submission
   * **Salsabil** (S)
