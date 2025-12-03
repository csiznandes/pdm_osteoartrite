from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import json
import os

app = Flask(__name__)
#Configuração do Banco de Dados
app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get(
    "DATABASE_URL",
    "sqlite:///database.db"
)

app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
CORS(app)   #Habilita CORS para permitir que o frontend Flutter se conecte
db = SQLAlchemy(app)
#Modelos do Banco de Dados
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    name = db.Column(db.String(150))
    age = db.Column(db.Integer)
    sex = db.Column(db.String(20))
    contact = db.Column(db.String(150))
    diagnosis = db.Column(db.Text)
    comorbidities = db.Column(db.Text)
    accessibility = db.Column(db.Text)
    lgpd_consent = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class PainEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    score = db.Column(db.Integer)
    location = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class AgendaItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    date = db.Column(db.Date)
    time = db.Column(db.Time)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False)
    text = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
#Cria as tabelas do banco de dados se não existirem
with app.app_context():
    db.create_all()

import re
#Funções de Validação
def is_valid_email(email):
    return re.match(r"^[\w\.-]+@[\w\.-]+\.\w+$", email)

def is_valid_phone(phone):
    return re.match(r"^\d{8,11}$", phone)

def validate_register(data):
    errors = []

    email = data.get("email")
    if not email or not is_valid_email(email):
        errors.append("Email inválido")

    password = data.get("password")
    if not password or len(password) < 6:
        errors.append("Senha deve ter pelo menos 6 caracteres")

    age = data.get("age")
    if age is not None:
        try:
            age = int(age)
            if age < 1 or age > 120:
                errors.append("Idade deve estar entre 1 e 120")
        except:
            errors.append("Idade deve ser numérica")

    contact = data.get("contact")
    if contact:
        only_numbers = re.sub(r"\D", "", contact)
        if not is_valid_phone(only_numbers):
            errors.append("Telefone inválido (use 8 a 11 números)")

    if not data.get("lgpd_consent"):
        errors.append("É obrigatório aceitar o consentimento LGPD")

    return errors
#Endpoints de Autenticação e Usuário
@app.route("/register", methods=["POST"])
def register():
    data = request.json

    errors = validate_register(data)
    if errors:
        return jsonify({"error": errors}), 400

    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"error": "Email já cadastrado"}), 400

    user = User(
        email=data["email"],
        password_hash=generate_password_hash(data["password"]),
        name=data.get("name"),
        age=data.get("age"),
        sex=data.get("sex"),
        contact=data.get("contact"),
        diagnosis=data.get("diagnosis"),
        comorbidities=data.get("comorbidities"),
        accessibility=json.dumps(data.get("accessibility", {})),
        lgpd_consent=data.get("lgpd_consent")
    )

    db.session.add(user)
    db.session.commit()

    return jsonify({"message": "Registro efetuado", "user_id": user.id}), 201


@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user = User.query.filter_by(email=data.get("email")).first()

    if not user or not check_password_hash(user.password_hash, data.get("password","")):
        return jsonify({"error": "Credenciais inválidas"}), 401

    return jsonify({"message": "ok", "user_id": user.id}), 200

@app.route("/user/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify({
        "id": user.id,
        "email": user.email,
        "name": user.name,
        "age": user.age,
        "sex": user.sex,
        "contact": user.contact,
        "diagnosis": user.diagnosis,
        "comorbidities": user.comorbidities,
        "accessibility": json.loads(user.accessibility or "{}"),
        "lgpd_consent": user.lgpd_consent
    })

@app.route("/user/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.json

    user.name = data.get("name", user.name)
    user.age = data.get("age", user.age)
    user.sex = data.get("sex", user.sex)
    user.contact = data.get("contact", user.contact)
    user.diagnosis = data.get("diagnosis", user.diagnosis)
    user.comorbidities = data.get("comorbidities", user.comorbidities)
    #Atualiza a senha se um novo valor for fornecido
    if "password" in data and data["password"]:
        if len(data["password"]) < 6:
            return jsonify({"error": "Senha deve ter pelo menos 6 caracteres"}), 400 
        user.password_hash = generate_password_hash(data["password"])

    if "accessibility" in data:
        user.accessibility = json.dumps(data["accessibility"])

    if "lgpd_consent" in data:
        user.lgpd_consent = bool(data["lgpd_consent"])

    db.session.commit()
    return jsonify({"message": "Perfil atualizado"})
#Endpoints de Dados
@app.route("/user/<int:user_id>/pain", methods=["POST"])
def add_pain(user_id):
    data = request.json
    entry = PainEntry(
        user_id=user_id,
        score=int(data["score"]),
        location=data.get("location","")
    )
    db.session.add(entry)
    db.session.commit()

    return jsonify({"message": "Salvo", "id": entry.id})

@app.route("/user/<int:user_id>/pain", methods=["GET"])
def get_pains(user_id):
    entries = PainEntry.query.filter_by(user_id=user_id).order_by(PainEntry.created_at.asc()).all()
    return jsonify([
        {
            "id": e.id,
            "score": e.score,
            "location": e.location,
            "created_at": e.created_at.isoformat()
        } for e in entries
    ])

@app.route("/user/<int:user_id>/agenda", methods=["POST"])
def add_agenda(user_id):
    data = request.json
    date = datetime.strptime(data["date"], "%Y-%m-%d").date()
    time = datetime.strptime(data["time"], "%H:%M:%S").time()

    item = AgendaItem(
        user_id=user_id,
        date=date,
        time=time,
        description=data.get("description","")
    )
    db.session.add(item)
    db.session.commit()

    return jsonify({"message": "Criado", "id": item.id})

@app.route("/user/<int:user_id>/agenda", methods=["GET"])
def list_agenda(user_id):
    items = AgendaItem.query.filter_by(user_id=user_id).order_by(AgendaItem.date.asc()).all()
    return jsonify([
        {
            "id": i.id,
            "date": i.date.isoformat(),
            "time": i.time.isoformat(),
            "description": i.description
        } for i in items
    ])

@app.route("/user/<int:user_id>/agenda/<int:item_id>", methods=["DELETE"])
def del_agenda(user_id, item_id):
    it = AgendaItem.query.get_or_404(item_id)
    db.session.delete(it)
    db.session.commit()
    return jsonify({"message":"Apagado"})

@app.route("/user/<int:user_id>/feedback", methods=["POST"])
def add_feedback(user_id):
    data = request.json
    fb = Feedback(user_id=user_id, text=data.get("text",""))
    db.session.add(fb)
    db.session.commit()
    return jsonify({"id": fb.id})

@app.route("/user/<int:user_id>/feedback", methods=["GET"])
def list_feedback(user_id):
    fbs = Feedback.query.filter_by(user_id=user_id).order_by(Feedback.created_at.desc()).all()
    return jsonify([
        {
            "id": f.id,
            "text": f.text,
            "created_at": f.created_at.isoformat()
        } for f in fbs
    ])

@app.route("/user/<int:user_id>/feedback/<int:fb_id>", methods=["DELETE"])
def del_feedback(user_id, fb_id):
    f = Feedback.query.get_or_404(fb_id)
    db.session.delete(f)
    db.session.commit()
    return jsonify({"message":"Apagado"})
#Endpoints de Conteúdo Estático
@app.route("/techniques", methods=["GET"])
def techniques():
    return jsonify({
        "alongamentos": "TÉCNICA: Alongamento de mãos... (texto completo)",
        "respiracao_profunda": "RESPIRAÇÃO PROFUNDA... (texto completo)",
        "respiracao_478": "RESPIRAÇÃO 4-7-8... (texto completo)",
        "suspiro": "SUSPIRO DE ALÍVIO... (texto completo)",
        "relaxamento": "RELAXAMENTO MUSCULAR... (texto completo)",
        "toque": "TOQUE CALMANTE... (texto completo)"
    })

@app.route("/education", methods=["GET"])
def education():
    return jsonify({
        "conteudo": "Texto extenso de educação sobre osteoartrite..."
    })

@app.route("/alerts", methods=["GET"])
def alerts():
    return jsonify([
        "Pare se sentir tontura intensa",
        "Não force se tiver dor",
        "Consulte seu médico se tiver dúvidas"
    ])

@app.route("/reset_password", methods=["POST"])
def reset_password():
    data = request.get_json()
    email = data.get("email")

    if not email:
        return jsonify({"error": "Email obrigatório"}), 400

    user = User.query.filter_by(email=email).first()

    if not user:
        print(f"Tentativa de redefinição de senha para email não cadastrado: {email}")
        return jsonify({"message": "Email de redefinição enviado (se a conta existir)"}), 200

    import string
    import random
    #Gera uma senha temporária aleatória de 10 caracteres
    temp_password = ''.join(random.choices(string.ascii_letters + string.digits, k=10)) 

    user.password_hash = generate_password_hash(temp_password)
    db.session.commit()

    print(f"ATENÇÃO: Senha temporária definida para {email}: {temp_password}. Usuário deve fazer login com esta senha.")

    return jsonify({
        "message": "password_reset_success"
    }), 200

if __name__ == "__main__":
    app.run(debug=True)
