from flask import Blueprint, render_template, request, redirect, url_for, session, flash, g
import psycopg2
import psycopg2.extras
import bcrypt
import os

auth = Blueprint("auth", __name__)

# ── DB ────────────────────────────────────────────────────────
# Paramètres lus depuis les variables d'environnement (.env).
# Le chargement du .env se fait une seule fois, au démarrage, dans app.py.
DB_CONFIG = {
    "host":     os.environ.get("DB_HOST", "localhost"),
    "port":     int(os.environ.get("DB_PORT", 5432)),
    "dbname":   os.environ.get("DB_NAME", "docclassify"),
    "user":     os.environ.get("DB_USER", "postgres"),
    "password": os.environ.get("DB_PASSWORD", ""),
}

def get_db():
    if "db" not in g:
        conn = psycopg2.connect(**DB_CONFIG, cursor_factory=psycopg2.extras.RealDictCursor)
        conn.set_client_encoding("UTF8")
        g.db = conn
    return g.db

def close_db(exc=None):
    db = g.pop("db", None)
    if db:
        db.close()

# ── Register ──────────────────────────────────────────────────
@auth.route("/register", methods=["GET", "POST"])
def register():
    if "user_id" in session:
        return redirect(url_for("classify_document"))

    if request.method == "POST":
        username = request.form.get("username", "").strip()
        email    = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "")

        if not username or not email or not password:
            flash("Tous les champs sont obligatoires.", "danger")
            return render_template("register.html")

        if len(password) < 8:
            flash("Le mot de passe doit contenir au moins 8 caractères.", "danger")
            return render_template("register.html")

        db  = get_db()
        cur = db.cursor()
        cur.execute("SELECT id FROM users WHERE email=%s OR username=%s", (email, username))
        if cur.fetchone():
            flash("Email ou nom d'utilisateur déjà utilisé.", "danger")
            return render_template("register.html")

        
        # pw_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("latin-1")
        pw_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
        cur.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
            (username, email, pw_hash)
        )
        db.commit()
        flash("Compte créé ! Connectez-vous.", "success")
        return redirect(url_for("auth.login"))

    return render_template("register.html")

# ── Login ─────────────────────────────────────────────────────
@auth.route("/login", methods=["GET", "POST"])
def login():
    if "user_id" in session:
        next_page = request.args.get("next") or url_for("classify_document")
        return redirect(next_page)

    if request.method == "POST":
        email    = request.form.get("email", "").strip().lower()
        password = request.form.get("password", "")

        db  = get_db()
        cur = db.cursor()
        cur.execute("SELECT * FROM users WHERE email=%s AND is_active=TRUE", (email,))
        user = cur.fetchone()

        if user:
            # Decode hash safely — bcrypt may store non-UTF-8 bytes
            stored_hash = user["password_hash"]
            # if isinstance(stored_hash, str):
            #       stored_hash = stored_hash.encode("utf-8")
            if isinstance(stored_hash, memoryview):
                   stored_hash = stored_hash.tobytes()
                
                # stored_hash = stored_hash.encode("latin-1")  # pas utf-8

            if bcrypt.checkpw(password.encode("utf-8"), stored_hash):
                session.clear()
                session["user_id"]  = user["id"]
                session["username"] = user["username"]
                cur.execute("UPDATE users SET last_login=NOW() WHERE id=%s", (user["id"],))
                db.commit()
                flash(f"Bienvenue, {user['username']} !", "success")
                next_page = request.args.get("next") or url_for("classify_document")
                return redirect(next_page)

        flash("Email ou mot de passe incorrect.", "danger")

    return render_template("login.html")

# ── Logout ────────────────────────────────────────────────────
@auth.route("/logout")
def logout():
    session.clear()
    flash("Vous êtes déconnecté.", "info")
    return redirect(url_for("auth.login"))