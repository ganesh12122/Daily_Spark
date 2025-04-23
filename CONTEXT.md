SparkVow Project Context
Overview
SparkVow (formerly Daily Spark) is a productivity app designed to help users build discipline through daily task tracking, a Pomodoro timer, and motivational features. This document provides context for the project, including its purpose, features, setup instructions, and future plans, to guide development and maintenance.
Current Version: Beta (as of April 22, 2025)Platform: Android (primary), Web (secondary for testing)Tech Stack: Flutter, Dart
Purpose
SparkVow aims to:

Encourage users to commit to daily disciplines (e.g., exercise, study, meditation).
Provide tools to boost focus and productivity (Pomodoro timer, time-wasted counter).
Motivate users with streaks, stars, medals, and daily quotes.
Collect beta feedback to refine features for a full release.

The app targets users seeking to improve self-discipline and productivity, with a bold, motivational tone ("warriors who refuse to waste time").
Features
Core Features

Discipline Tracking:
Add, toggle, and delete disciplines (with optional restrictions).
Optional 48-day Commitment: Users can choose to commit to a discipline for 48 days, requiring a 48-day streak before deletion. If unchecked, disciplines can be deleted anytime, earning a Quick Win badge after a 7-day streak.
Track streaks, success rates, and stars (1 star per 48-day cycle for committed disciplines, 1 star for Quick Wins).
Animated list with slide transitions for adding/deleting tasks.


Pomodoro Timer:
25-minute focus sessions with start, stop, and reset options.
Visual feedback (green when active, grey when inactive).


Time-Wasted Counter:
Tracks seconds elapsed since app launch to emphasize time management.


Achievements and Rewards:
Daily Badges: Gold (100% completion), Silver (75%+ completion).
Stars: 1 star for first 48-day streak, 2 stars for next 48 days, etc. (committed disciplines); 1 star for 7-day streak (non-committed).
Gold Medals: 100 for first 48-day streak, 50 per subsequent streak (committed disciplines).
Quick Win Badge: Awarded for 7-day streak on non-committed disciplines.
Iron Will Badge: Awarded after three 48-day cycles (144 days, committed disciplines).
Animated pop-ups with confetti for milestones.


Notifications:
Daily reminders at 8 AM, 1 PM, and 8 PM.
Achievement, milestone, Quick Win, and failure notifications.


Dark/Light Mode:
Toggle between themes with persistent storage.


Empty State:
Displays a responsive image (empty_state.png) with animated glowing corners (fire-like effect) when no disciplines are added.



Beta-Specific Features

Onboarding: 3-slide introduction for new users (stored in SharedPreferences).
Analytics: Basic event logging (e.g., discipline added, badge earned) to SharedPreferences.
Feedback: Email-based feedback to peacemakers.dev@gmail.com.
Privacy Policy: Hosted at https://raw.githubusercontent.com/ganesh12122/Spark_Vow/refs/heads/main/privacy_policy.md.
Haptic Feedback: Vibrations on key interactions (e.g., adding tasks, toggling completion).

UI/UX

Full-Screen Scrolling: CustomScrollView with SliverAppBar for LinkedIn-like scrolling.
Dynamic AppBar: Hides on scroll up, reappears on scroll down.
BottomAppBar with FAB: Prevents FAB from obscuring disciplines.
Modern Design: Uses Poppins font, rounded cards, and micro-animations (e.g., button pulses, quote fade, confetti, glowing empty state).
Color Palette: Deep purple (primary), green (Pomodoro), orange (streaks), red (errors), amber (rewards).

Project Structure
spark_vow/
├── lib/
│   ├── core/
│   │   ├── models/
│   │   │   └── discipline_manager.dart
│   │   ├── providers/
│   │   │   └── discipline_provider.dart
│   │   ├── services/
│   │   │   ├── analytics_service.dart
│   │   │   └── notification_service.dart
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── daily_spark_screen.dart
│   │   │   └── onboarding_screen.dart
│   │   ├── widgets/
│   │   │   ├── empty_state_widget.dart
│   │   │   ├── motivational_quote_widget.dart
│   │   │   └── discipline_item_widget.dart
│   ├── main.dart
├── assets/
│   ├── images/
│   │   └── empty_state.png
│   ├── sounds/
│   │   └── warning.mp3
├── context.md
├── pubspec.yaml
├── android/

Setup Instructions
Prerequisites

Flutter SDK: 3.22.x or later
Dart: 3.x
Android Studio or VS Code
Android device/emulator (API 21+)

Dependencies (pubspec.yaml)
dependencies:
flutter:
sdk: flutter
provider: ^6.1.2
audioplayers: ^5.2.1
flutter_local_notifications: ^17.2.1
timezone: ^0.9.4
flutter_native_timezone: ^2.0.0
intl: ^0.19.0
shared_preferences: ^2.2.3
permission_handler: ^11.3.1
package_info_plus: ^8.0.2
url_launcher: ^6.3.0
introduction_screen: ^3.1.14
google_fonts: ^6.2.1
confetti: ^0.7.0

assets:
- assets/sounds/warning.mp3
- assets/images/empty_state.png

Android Configuration

build.gradle:
android/app/build.gradle: Set compileSdkVersion 33, targetSdkVersion 33, minSdkVersion 21.
android/build.gradle: Use com.android.tools.build:gradle:8.5.2.


settings.gradle.kts:
Configure Flutter plugin loader and repositories.


AndroidManifest.xml:
Add permissions: SCHEDULE_EXACT_ALARM, RECEIVE_BOOT_COMPLETED, POST_NOTIFICATIONS.



Build and Run

Clone the project:git clone <repository>
cd spark_vow


Install dependencies:flutter pub get


Fix Gradle cache (if needed):cd android
./gradlew cleanBuildCache
rm -rf ~/.gradle/caches/


Run the app:flutter run


Build for release:flutter build apk --release
flutter build appbundle --release



Assets

empty_state.png: Responsive image (recommended 300x300 px, rounded corners in code) with animated glowing corners.
warning.mp3: Sound for future alerts (currently unused).

Future Plans

Full Release:
Add Firebase Analytics/Crashlytics for advanced tracking.
Implement custom reminder times per discipline.
Enhance onboarding with custom images.
Add export/import for discipline data.
Add due date for short-term disciplines (auto-delete after completion).


UI Improvements:
Animated progress charts in stats dialog.
Customizable themes (e.g., color picker).


Features:
Categories for disciplines (e.g., Health, Work, Learning).
Offline backup to local storage.
Integration with calendar apps.
Social sharing of milestones (e.g., “I earned 2 stars in SparkVow!”).


Performance:
Optimize SliverAnimatedList for large lists.
Reduce memory usage for timers and animations.



Beta Release Notes

Testing: Use Google Play Internal Test track with a small group.
Feedback: Collect via email (peacemakers.dev@gmail.com) and analytics logs in SharedPreferences.
Play Store:
Name: SparkVow (Beta)
Description: “Track disciplines, earn stars and medals, boost focus with Pomodoro! Beta - share feedback!”
Screenshots: Onboarding, discipline list with stars, Pomodoro, milestone pop-up, commitment dialog.
Privacy Policy: Hosted at https://raw.githubusercontent.com/ganesh12122/Spark_Vow/refs/heads/main/privacy_policy.md.



Known Issues

None after recent fixes (task completion bug resolved, linter issues cleared).

Contact

Feedback: peacemakers.dev@gmail.com
Developer: Ganesh

Last Updated: April 22, 2025
