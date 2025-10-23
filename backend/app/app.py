import os, uuid
from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg
from psycopg.rows import dict_row

# Config
DATABASE_URL = os.getenv("DATABASE_URL")  
PORT = int(os.getenv("PORT", "8080"))

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*"}})

# Connexion DB (pool simple)
def get_conn():
    return psycopg.connect(DATABASE_URL, autocommit=True)

# Init table
def ensure_schema():
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                create table if not exists users (
                    id uuid primary key,
                    name text not null,
                    email text not null
                );
            """)

@app.get("/health")
def health():
    try:
        with get_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("select 1;")
        return jsonify({"ok": True}), 200
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500

@app.get("/api/users")
def list_users():
    with get_conn() as conn:
        with conn.cursor(row_factory=dict_row) as cur:
            cur.execute("select id, name, email from users order by name;")
            rows = cur.fetchall()
    return jsonify(rows), 200

@app.post("/api/users")
def create_user():
    data = request.get_json(silent=True) or {}
    name = (data.get("name") or "").strip()
    email = (data.get("email") or "").strip()
    if not name or not email:
        return jsonify({"error": "name and email required"}), 400
    uid = uuid.uuid4()
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute(
                "insert into users (id, name, email) values (%s, %s, %s)",
                (str(uid), name, email),
            )
    return jsonify({"id": str(uid), "name": name, "email": email}), 201

@app.delete("/api/users/<id>")
def delete_user(id):
    try:
        _ = uuid.UUID(id)
    except Exception:
        return jsonify({"error": "invalid id"}), 400
    with get_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("delete from users where id = %s", (id,))
            if cur.rowcount == 0:
                return jsonify({"error": "not found"}), 404
    return jsonify({"deleted": id}), 200

if __name__ == "__main__":
    ensure_schema()
    app.run(host="0.0.0.0", port=PORT)
