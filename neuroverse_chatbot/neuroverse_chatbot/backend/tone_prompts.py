RECOMMENDATIONS = {
    "GGG": [
        ("Happy - Pharrell", "https://www.youtube.com/watch?v=ZbZSe6N_BXs"),
        ("On Top of the World", "https://www.youtube.com/watch?v=w5tWYmIOWGk")
    ],
    "BBB": [
        ("Relaxing Krishna Flute", "https://www.youtube.com/watch?v=1kIFrf5OPxE"),
        ("Hanuman Chalisa", "https://www.youtube.com/watch?v=BLlTFapgvOo"),
        
    ],
    "BBG": [("Count on Me - Bruno Mars", "https://www.youtube.com/watch?v=6k8cpUkKK4c")],
    "GBB": [("Believer - Imagine Dragons", "https://www.youtube.com/watch?v=7wtfhZwyrcc")],
    "BGB": [("Uptown Funk - Bruno Mars", "https://www.youtube.com/watch?v=OPf0YbXqDm0")],
    "GGB": [("Don't Stop Me Now - Queen", "https://www.youtube.com/watch?v=HgzGwKwLmgM")],
    "GBG": [("Something Just Like This", "https://www.youtube.com/watch?v=FM7MFYoylVs")],
    "BGG": [("Despacito - Luis Fonsi", "https://www.youtube.com/watch?v=kJQP7kiw5Fk")]
}

def get_tone_prompt(mood_pattern: str, reason: str = None, include_songs: bool = False, user_msg: str = "") -> str:
    """
    Returns a tone-specific prompt based on mood pattern, optional reason, and optional user message.
    Can include optional song recommendations if needed.
    """
    tone_map = {
        "BBB": "gentle and calming",
        "GBB": "cautious but supportive",
        "BGB": "balanced and encouraging",
        "BBG": "lightly optimistic",
        "GGB": "uplifting and hopeful",
        "BGG": "reassuring and optimistic",
        "GBG": "positive and empathetic",
        "GGG": "joyful and playful"
    }

    reason_tones = {
        "Academic stress": "encouraging and empowering",
        "Loneliness": "warm and soothing",
        "Relationship issues": "compassionate and understanding",
        "Career pressure": "motivational and focused",
        "Health issues": "gentle and caring"
    }

    tone = tone_map.get(mood_pattern, "empathetic and supportive")
    if reason:
        tone = reason_tones.get(reason, tone)

    intro = "You are NeuroVerse, a caring and emotionally-aware AI companion."
    tone_line = f"Speak in a {tone} tone."

    context = ""
    if reason:
        context = f"The user might be feeling this way due to {reason.lower()}."
    elif user_msg:
        context = f"The user said: \"{user_msg}\". Be mindful and adaptive."

    outro = "Start with a short, comforting message. Avoid mentioning mood patterns directly."

    if include_songs:
        recs = RECOMMENDATIONS.get(mood_pattern, [])
        if recs:
            links = "\n".join([f"- {title}: {url}" for title, url in recs])
            outro += f"\nYou may gently suggest one or two of these songs if it feels appropriate:\n{links}"

    return f"{intro}\n\n{tone_line}\n\n{context}\n\n{outro}"

# Example Usage
if __name__ == "__main__":
    print(get_tone_prompt("GBB", "Academic stress", include_songs=True))
