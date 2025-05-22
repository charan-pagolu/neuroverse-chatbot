# neuroverse_chatbot
# NeuroVerse Chatbot 🤖🧠

## Overview

NeuroVerse is a cross-platform AI-powered mental wellness chatbot developed using **Flutter** and **Flask**, integrated with **OpenAI GPT** and **Firebase**. It supports users in expressing and managing their emotions by:

* Offering mood-based conversational support.
* Recommending motivational or calming YouTube content.
* Tracking mood patterns to personalize future responses.

The app features a calming UI with dynamic response logic and is designed to provide emotional support, especially during low moods.

---

## Features

* **Mood Selection**: Users start by selecting how they feel – "Happy" or "Sad".
* **Emotionally Adaptive Chatbot**: Uses OpenAI GPT to respond with comforting or joyful tones.
* **Dynamic Survey Flow**: Tailored questions based on the user's mood and mood history.
* **YouTube Song Suggestions**: Recommends motivational or devotional songs for emotional relief.
* **Mood Pattern Detection**: Detects and uses trends in the last 3 mood entries (e.g., "GBB", "BBB").
* **Firebase Integration**: Stores mood data and fetches mood patterns per user.
* **Dark Mode UI**: Chat UI with typing animation, smooth scrolling, and minimal distraction.

---

## How It Works

1. **Mood Selection & Survey**:

   * Users pick their current emotional state.
   * For "Sad", the chatbot opens with a warm message and a context-aware follow-up survey.
   * For "Happy", the conversation is more playful and relaxed.

2. **LLM-Driven Conversation**:

   * Uses OpenAI GPT to generate responses.
   * Adapts tone based on both current mood and past mood patterns.

3. **Mood Pattern Awareness**:

   * Firebase Firestore stores the user’s last 3 moods.
   * Patterns (e.g., BBB, GGB) determine follow-up behavior and recommendations.

4. **Song Recommendations**:

   * For negative mood patterns, recommends motivational or spiritual YouTube content.
   * Includes clickable song buttons after survey response.

5. **User Experience**:

   * Seamless Flutter chat interface.
   * Typing effect and scrollable message history.
   * Button-based surveys and responses.

---

## Important Setup Steps

### 1. **Backend (Flask)**

* Navigate to the backend directory:

  ```bash
  cd neuroverse_chatbot/backend
  ```
* Create and activate a virtual environment:

  ```bash
  python -m venv venv
  venv\Scripts\activate  # Windows
  # or
  source venv/bin/activate  # macOS/Linux
  ```
* Install dependencies:

  ```bash
  pip install -r requirements.txt
  ```
* Add a `.env` file with:

  ```env
  OPENAI_API_KEY=your_openai_key_here
  FIREBASE_PROJECT_ID=your_firebase_project_id
  ```
* Start the server:

  ```bash
  python app.py
  ```

### 2. **Frontend (Flutter)**

* In project root:

  ```bash
  flutter pub get
  flutter run
  ```

---

## File Structure

### Backend

* `app.py`: Main Flask backend logic (chat flow, tone control, API endpoints).
* `tone_prompts.py`: Prompt templates and mood-to-tone mappings.
* `requirements.txt`: Python dependencies.
* `.env`: Secret keys and config (ignored via `.gitignore`).

### Frontend

* `lib/chatbot_screen.dart`: Primary chat UI and LLM integration.
* `lib/mood_tracker.dart`: Stores mood locally and sends to Firebase.
* `lib/screens/`: UI screens (home, onboarding).
* `lib/widgets/`: Custom components (chat bubbles, buttons, song cards).

---

## Components

* **ChatBotScreen**: Main interface for user interaction.
* **SurveyButtons**: Dynamically generated follow-up survey options.
* **MoodTracker**: Connects frontend mood entries to Firebase.
* **YouTubeLinks**: Embedded links for music suggestions.
* **TypingEffect**: Visual indicator to mimic real-time chat feel.

---

## GitHub Actions – CI Workflow

The project includes CI that:

* Runs `flutter analyze` for code issues.
* Compiles Python backend to catch syntax errors.

CI config file:
`.github/workflows/ci.yml`

---

## Future Enhancements

* Add journaling and visual mood trend charts.
* Include meditation and breathing exercises.
* Implement user login and persistent chat history.
* Add anonymous support group feature.
* Integrate voice-based interaction.

---

## Screenshots

> Coming soon: Screens showing mood selection, chatbot response flow, and recommendations.

---

## Credits

Built by **Charan Pagolu**
Created as part of the **Mental Health Support App Project**
University of Dayton

---

## Disclaimer

This app is for emotional support and educational use only.
It is **not a substitute for professional mental health care**.
