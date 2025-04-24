# DailySpark(BETA_VERSION) - The Ultimate Discipline Builder

Welcome to **SparkVow**, a Flutter-based mobile application designed to help warriors forge unbreakable discipline through daily task tracking, focus timers, motivational features, and reflective journaling.
currently under development!!!, "Stay Tuned"

## Table of Contents
*   [Overview](#overview)
*   [Features](#features)
*   [Screenshots](#screenshots)
*   [Installation](#installation)
*   [Usage](#usage)
*   [Contributing](#contributing)
*   [License](#license)
*   [Future Plans and Updates](#future-plans-and-updates)
*   [Acknowledgements](#acknowledgements)

## Overview
SparkVow is an app for individuals committed to self-improvement, inspired by the philosophy that every second counts and every discipline matters. It combines task management with a Pomodoro timer, achievement badges, and a diary to track your journey.

## Features
### Current Features
*   **Discipline Tracking:** Add and manage daily disciplines with streak tracking and commitment options (e.g., 48-day challenges).
*   **Pomodoro Timer:** A 25-minute focus timer to boost productivity, with start, stop, and reset functionality.
*   **Achievement Badges:** Earn Gold and Silver badges for completing tasks, with confetti celebrations for milestones (e.g., 7-day Quick Wins, 48-day stars).
*   **Time Wasted Counter:** Tracks seconds wasted to motivate users to stay focused.
*   **Motivational Quotes:** Dynamic quotes to inspire daily discipline.
*   **Diary Reflections:** Write daily thoughts with mood tracking (Happy, Stressed, Motivated, Tired) and a reflection streak counter.
*   **Notifications:** Daily reminders and achievement notifications to keep you on track.
*   **Theme Toggle:** Switch between light and dark modes.
*   **Statistics Dashboard:** View completion rates, longest streaks, and total disciplines.
*   **Empty State Enhancement:** A glowing flame icon in the empty state to encourage users to add their first discipline.

## Screenshots
*   **Discipline Screen**: \[Insert image of DailySparkScreen with disciplines and timer]
*   **Diary Screen**: \[Insert image of DiaryScreen with mood dropdown and reflections]
*   **Achievement Popup**: \[Insert image of Gold/Silver badge popup with confetti]
*   **Empty State**: \[Insert image of EmptyStateWidget with glowing flame]

## Installation
### Prerequisites
*   Flutter SDK (latest stable version recommended)
*   Dart
*   An IDE (e.g., Android Studio, VS Code) with Flutter support
*   Android Emulator or iOS Simulator (or a physical device)

### Steps
1.  **Clone the Repository**
    bash
git clone https://github.com/ganesh12122/Spark_Vow.git
cd Spark_Vow

2. *Install Dependencies*
Run the following command to fetch all required packages:

bash

flutter pub get

3.  *Configure Assets*
    *   Ensure the pubspec.yaml includes all necessary assets (e.g., sounds/chime.mp3 for the Pomodoro chime).
    *   Add any custom images or assets to the assets/ directory and declare them in pubspec.yaml if needed.
4.  *Set Up Notifications*
    *   For Android, update android/app/src/main/AndroidManifest.xml with notification permissions.
    *   For iOS, configure Info.plist with notification settings (refer to flutter_local_notifications documentation).
5.  *Run the App*
    Connect a device or start an emulator, then run:
    bash
flutter run


Usage
1. Onboarding: Launch the app to see an onboarding flow introducing SparkVow’s features. Complete it to access the main screens.
2. Discipline Management: Tap the + button to add disciplines, toggle them as completed, and set reminders.
3. Focus with Pomodoro: Use the Focus Timer card to start a 25-minute session and reset as needed.
4. Track Progress: View stats or earn badges for consistency.
5. Reflect: Add daily thoughts and moods via the Diary screen.
6. Customize: Toggle between light and
