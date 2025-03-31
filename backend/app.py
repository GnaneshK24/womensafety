from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import time

app = Flask(__name__)
CORS(app)  # This allows your Flutter app to access the API

# Set API Key
AIXPLAIN_API_KEY = "991e68fde40cc339c9b237c8273f0a0faea93a1d855ba5b4608fca80295a337b"  # Replace with your API key
AGENT_ID = "67911be96217a7d8cf00b495"  # Location agent ID
POST_URL = f"https://platform-api.aixplain.com/sdk/agents/{AGENT_ID}/run"

headers = {
    "x-api-key": AIXPLAIN_API_KEY,
    "Content-Type": "application/json"
}

# Function to Query the Location Agent
def query_location_agent(query_text, session_id=None):
    data = {"query": query_text}
    if session_id:
        data["sessionId"] = session_id

    response = requests.post(POST_URL, headers=headers, json=data)
    response_data = response.json()
    request_id = response_data.get("requestId")

    get_url = f"https://platform-api.aixplain.com/sdk/agents/{request_id}/result"

    while True:
        get_response = requests.get(get_url, headers=headers)
        result = get_response.json()

        if result.get("completed"):
            return result
        else:
            time.sleep(5)

@app.route("/")
def home():
    return jsonify({"message": "Flask server is running!"})

@app.route("/chatbot", methods=["POST"])
def chatbot():
    data = request.json
    user_input = data.get("message", "")

    # Call your chatbot logic
    response_data = query_location_agent(user_input)

    # Extract the AI's response
    ai_response = response_data.get("data", {}).get("output", "Sorry, I couldn't find an answer.")

    return jsonify({"response": ai_response})

if __name__ == "__main__":
    app.run(debug=True, host='172.16.146.61', port=5000)  # Make sure to run on all interfaces