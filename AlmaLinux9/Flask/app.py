from flask import Flask, jsonify

app = Flask(__name__)
app.json.ensure_ascii = False  # type: ignore


@app.route("/")
def index():
    return jsonify({"code": 200, "message": "Hello, World!"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
