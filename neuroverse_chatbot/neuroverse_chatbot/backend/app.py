from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import openai
import os
import re
from tone_prompts import get_tone_prompt

load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

app = Flask(__name__)
CORS(app)

chat_history = []

RECOMMENDATIONS = {
    "BBB": [
        ("Relaxing Krishna Flute", "https://www.youtube.com/watch?v=1kIFrf5OPxE"),
        ("Hanuman Chalisa", "https://www.youtube.com/watch?v=BLlTFapgvOo")
    ],
    "GBB": [("Believer – Imagine Dragons", "https://www.youtube.com/watch?v=7wtfhZwyrcc")],
    "BGB": [("Uptown Funk", "https://www.youtube.com/watch?v=OPf0YbXqDm0")],
    "BBG": [("Count on Me - Bruno Mars", "https://www.youtube.com/watch?v=6k8cpUkKK4c")],
    "GGB": [("Don't Stop Me Now", "https://www.youtube.com/watch?v=HgzGwKwLmgM")],
    "GBG": [("Something Just Like This", "https://www.youtube.com/watch?v=FM7MFYoylVs")],
    "BGG": [("Despacito", "https://www.youtube.com/watch?v=kJQP7kiw5Fk")],
    "GGG": [
        ("Happy – Pharrell", "https://www.youtube.com/watch?v=ZbZSe6N_BXs"),
        ("On Top of the World", "https://www.youtube.com/watch?v=w5tWYmIOWGk")
    ]
}

SURVEYS = {
    "BBB": {
        "question": "What’s been weighing on your mind?",
        "options": ["Loneliness", "Lack of motivation", "Anxiety"]
    },
    "GBB": {
        "question": "Please share what’s affecting your mood:",
        "options": ["Feeling ignored", "Low energy", "Stressful deadlines"]
    },
    "BGB": {
        "question": "Are your emotions shifting often?",
        "options": ["Mood swings", "Mixed feelings", "Unstable energy"]
    },
    "BBG": {
        "question": "What type of support would help right now?",
        "options": ["Encouraging words", "A friendly chat", "Just some calm"]
    },
    "GGB": {
        "question": "Is something challenging your optimism lately?",
        "options": ["Fatigue", "Minor setbacks", "Need encouragement"]
    },
    "GBG": {
        "question": "Do you feel emotionally balanced?",
        "options": ["A bit unsure", "Ups and downs", "Doing okay"]
    },
    "BGG": {
        "question": "What recently helped uplift you?",
        "options": ["Supportive friend", "Good news", "New routine"]
    },
    "GGG": {
        "question": "What’s keeping your spirits high today?",
        "options": ["Achievement", "Time with friends", "Just vibing"]
    }
}

def clean_prefix(text):
    return re.sub(r"^(NeuroVerse:|AI:)?\s*", "", text.strip())

@app.route('/chatbot-response', methods=['POST'])
def chatbot_response():
    try:
        data = request.get_json()
        moods = data.get("moods", [])
        name = data.get("name", "User")
        time_of_day = data.get("time_of_day", "evening")
        
        mood_pattern = "".join(["G" if m.lower() == "good" else "B" for m in moods])

        opening_prompt = get_tone_prompt(mood_pattern, reason=None, include_songs=False)

        chat_history.clear()
        chat_history.append({"role": "user", "content": opening_prompt})

        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=chat_history,
            max_tokens=80,  #  Limit response length
            temperature=0.7,

        )
        reply = clean_prefix(response.choices[0].message.content.strip())
        songs = RECOMMENDATIONS.get(mood_pattern, [])
        song_titles = [title for title, _ in songs]
        song_links = [url for _, url in songs]
        survey = SURVEYS.get(mood_pattern, {"question": "Would you like to tell me more?", "options": ["Tell me more"]})

        return jsonify({
            "chatbot_response": reply,
            "survey_question": survey["question"],
            "survey_options": survey["options"],
            "song_links": [],
            "song_titles": []
        })

    except Exception as e:
        print("❌ Error in /chatbot-response:", e)
        return jsonify({"error": str(e)}), 500

@app.route('/chatbot-followup', methods=['POST'])
def chatbot_followup():
    try:
        data = request.get_json()
        user_msg = data.get("message", "")
        raw_pattern = data.get("mood_pattern", "")
        mood_pattern = "".join(
           ["G" if m.lower().startswith("g") else "B" for m in re.findall(r'Good|Bad', raw_pattern, re.IGNORECASE)]
        )

        print("🧠 Normalized mood pattern:", mood_pattern)
        print("🎵 Found songs:", RECOMMENDATIONS.get(mood_pattern, []))
        
        survey_completed = data.get("survey_completed", False)

        songs = RECOMMENDATIONS.get(mood_pattern, [])
        song_titles = [title for title, _ in songs]
        song_links = [url for _, url in songs]

        trigger_song_phrases = ["song", "music", "listen", "recommend", "suggest"]
        send_songs = any(phrase in user_msg.lower() for phrase in trigger_song_phrases)

        if not survey_completed:
            system_prompt = (
                f"You are NeuroVerse, an emotionally supportive chatbot. "
                f"The user has the mood pattern '{mood_pattern}'. "
                "Do NOT suggest songs yet. Focus only on emotional support."
            )
        else:
            system_prompt = (
                "You are NeuroVerse, an emotionally supportive chatbot. "
                "Continue conversation. If the user asks for songs, songs will be sent separately."
            )

        chat_history.clear()
        chat_history.append({"role": "system", "content": system_prompt})
        chat_history.append({"role": "user", "content": user_msg})

        followup = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=chat_history
        )
        reply = clean_prefix(followup.choices[0].message.content.strip())

        send_songs = survey_completed or any(phrase in user_msg.lower() for phrase in trigger_song_phrases)

        response_payload = {
            "chatbot_response": reply,
            "song_titles": song_titles if send_songs else [],
            "song_links": song_links if send_songs else []
        }

        

        return jsonify(response_payload)

    except Exception as e:
        print("❌ Error in /chatbot-followup:", e)
        return jsonify({"error": str(e)}), 500



if __name__ == '__main__':
    print("🚀 NeuroVerse backend running...")
    app.run(debug=True)
