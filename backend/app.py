from flask import Flask, request, jsonify
from flask_cors import CORS
from models import get_conn
from utils import hash_password, verify_password, generate_jwt, decode_jwt
import json
import datetime
from functools import wraps

app = Flask(__name__)
CORS(app)

# -----------------------
# Helpers
# -----------------------
def get_user_by_email(email):
    """Busca um usuário no banco de dados pelo email."""
    conn = get_conn()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM users WHERE email=%s", (email,))
    user = cur.fetchone()
    cur.close(); conn.close()
    return user

def get_user_by_id(uid):
    """Busca um usuário no banco de dados pelo ID."""
    conn = get_conn()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM users WHERE id=%s", (uid,))
    user = cur.fetchone()
    cur.close(); conn.close()
    return user

def auth_required(f):
    """Decorator para exigir autenticação JWT nos endpoints."""
    @wraps(f)
    def wrapper(*args, **kwargs):
        token = None
        # Tenta extrair o token do cabeçalho Authorization
        if 'Authorization' in request.headers:
            auth_header = request.headers.get('Authorization')
            if auth_header.startswith("Bearer "):
                token = auth_header.split("Bearer ")[-1]
        
        if not token:
            return jsonify({'error':'token_missing'}), 401
        
        payload = decode_jwt(token)
        if not payload:
            return jsonify({'error':'token_invalid'}), 401
        
        # Anexa o user_id do token à requisição
        request.user_id = payload['user_id']
        return f(*args, **kwargs)
    return wrapper

# -----------------------
# Auth endpoints
# -----------------------
@app.route('/api/register', methods=['POST'])
def register():
    """Rota para registrar um novo usuário."""
    data = request.json
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')

    if not email or not password:
        return jsonify({'error':'email_and_password_required'}), 400
    if get_user_by_email(email):
        return jsonify({'error':'email_exists'}), 400

    pw_hash = hash_password(password)
    conn = get_conn()
    cur = conn.cursor()
    
    # CORREÇÃO: Adicionado o 10º placeholder (%s) para 'lgpd_consent'
    cur.execute("""
        INSERT INTO users (name,email,password_hash,age,sex,contact,diagnosis,comorbidities,accessibility_preferences,lgpd_consent)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        name, 
        email, 
        pw_hash,
        data.get('age'),
        data.get('sex'),
        data.get('contact'),
        data.get('diagnosis'),
        data.get('comorbidities'),
        json.dumps(data.get('accessibility_preferences') or {}),
        bool(data.get('lgpd_consent', False)) # Usa False como padrão se ausente
    ))
    conn.commit()
    uid = cur.lastrowid
    cur.close(); conn.close()

    token = generate_jwt(uid)
    return jsonify({'token': token, 'user_id': uid})

@app.route('/api/login', methods=['POST'])
def login():
    """Rota para login de usuário."""
    data = request.json
    email = data.get('email'); password = data.get('password')
    if not email or not password:
        return jsonify({'error':'email_and_password_required'}), 400
    user = get_user_by_email(email)
    if not user:
        return jsonify({'error':'invalid_credentials'}), 400
    if not verify_password(password, user['password_hash']):
        return jsonify({'error':'invalid_credentials'}), 400
    token = generate_jwt(user['id'])
    return jsonify({'token': token, 'user_id': user['id']})

# -----------------------
# Profile endpoints
# -----------------------
@app.route('/api/profile', methods=['GET'])
@auth_required
def get_profile():
    """Busca os dados de perfil do usuário logado."""
    uid = request.user_id
    user = get_user_by_id(uid)
    if not user:
        return jsonify({'error':'not_found'}), 404
    # remove campos sensíveis
    user.pop('password_hash', None)
    return jsonify(user)

@app.route('/api/profile', methods=['PUT'])
@auth_required
def update_profile():
    """Atualiza os dados de perfil do usuário logado."""
    uid = request.user_id
    data = request.json
    conn = get_conn(); cur = conn.cursor()
    cur.execute("""
        UPDATE users SET name=%s, age=%s, sex=%s, contact=%s, diagnosis=%s, comorbidities=%s, accessibility_preferences=%s, lgpd_consent=%s
        WHERE id=%s
    """, (
        data.get('name'),
        data.get('age'),
        data.get('sex'),
        data.get('contact'),
        data.get('diagnosis'),
        data.get('comorbidities'),
        json.dumps(data.get('accessibility_preferences') or {}),
        bool(data.get('lgpd_consent')),
        uid
    ))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

# -----------------------
# Pain entries
# -----------------------
@app.route('/api/pain', methods=['POST'])
@auth_required
def create_pain():
    """Registra uma nova entrada de dor."""
    uid = request.user_id
    data = request.json
    date = data.get('date') or datetime.date.today().isoformat()
    # Adiciona um padrão robusto para 'time' se não for fornecido
    time = data.get('time') or datetime.datetime.now().strftime('%H:%M:%S') 
    
    # Garante que 'pain_index' é um inteiro, usando 0 como fallback
    pain_index = int(data.get('pain_index', 0))

    conn = get_conn(); cur = conn.cursor()
    cur.execute("""
        INSERT INTO pain_entries (user_id, date, time, pain_index, body_location, note)
        VALUES (%s,%s,%s,%s,%s,%s)
    """, (uid, date, time, pain_index, data.get('body_location'), data.get('note')))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

@app.route('/api/pain', methods=['GET'])
@auth_required
def list_pain():
    """Lista todas as entradas de dor do usuário logado."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM pain_entries WHERE user_id=%s ORDER BY date DESC, created_at DESC", (uid,))
    rows = cur.fetchall()
    cur.close(); conn.close()
    return jsonify(rows)

# Endpoint para estatísticas mensais (média por dia/mês) para gráfico
@app.route('/api/pain/stats', methods=['GET'])
@auth_required
def pain_stats():
    """Calcula estatísticas mensais de dor (média) para gráficos."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor(dictionary=True)
    cur.execute("""
        SELECT DATE_FORMAT(date, '%%Y-%%m') as ym, AVG(pain_index) as avg_index, COUNT(*) as cnt
        FROM pain_entries WHERE user_id=%s
        GROUP BY ym ORDER BY ym ASC
    """, (uid,))
    rows = cur.fetchall()
    cur.close(); conn.close()
    return jsonify(rows)

# -----------------------
# Reminders
# -----------------------
@app.route('/api/reminders', methods=['POST'])
@auth_required
def create_reminder():
    """Cria um novo lembrete."""
    uid = request.user_id
    data = request.json
    conn = get_conn(); cur = conn.cursor()
    cur.execute("INSERT INTO reminders (user_id, date, time, description) VALUES (%s,%s,%s,%s)",
                (uid, data.get('date'), data.get('time'), data.get('description')))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

@app.route('/api/reminders', methods=['GET'])
@auth_required
def list_reminders():
    """Lista todos os lembretes do usuário."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM reminders WHERE user_id=%s ORDER BY date ASC, time ASC", (uid,))
    rows = cur.fetchall(); cur.close(); conn.close()
    return jsonify(rows)

@app.route('/api/reminders/<int:id>', methods=['DELETE'])
@auth_required
def delete_reminder(id):
    """Deleta um lembrete específico do usuário logado."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor()
    cur.execute("DELETE FROM reminders WHERE id=%s AND user_id=%s", (id, uid))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

# -----------------------
# Feedbacks
# -----------------------
@app.route('/api/feedbacks', methods=['POST'])
@auth_required
def create_feedback():
    """Cria um novo feedback."""
    uid = request.user_id
    data = request.json
    conn = get_conn(); cur = conn.cursor()
    cur.execute("INSERT INTO feedbacks (user_id, text) VALUES (%s,%s)", (uid, data.get('text')))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

@app.route('/api/feedbacks', methods=['GET'])
@auth_required
def list_feedbacks():
    """Lista todos os feedbacks do usuário."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM feedbacks WHERE user_id=%s ORDER BY created_at DESC", (uid,))
    rows = cur.fetchall(); cur.close(); conn.close()
    return jsonify(rows)

@app.route('/api/feedbacks/<int:id>', methods=['PUT'])
@auth_required
def update_feedback(id):
    """Atualiza o texto de um feedback."""
    uid = request.user_id
    data = request.json
    conn = get_conn(); cur = conn.cursor()
    cur.execute("UPDATE feedbacks SET text=%s WHERE id=%s AND user_id=%s", (data.get('text'), id, uid))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

@app.route('/api/feedbacks/<int:id>', methods=['DELETE'])
@auth_required
def delete_feedback(id):
    """Deleta um feedback."""
    uid = request.user_id
    conn = get_conn(); cur = conn.cursor()
    cur.execute("DELETE FROM feedbacks WHERE id=%s AND user_id=%s", (id, uid))
    conn.commit(); cur.close(); conn.close()
    return jsonify({'ok': True})

# -----------------------
# Técnicas & Educação (conteúdos estáticos)
# -----------------------
@app.route('/api/techniques', methods=['GET'])
def techniques():
    """Retorna uma lista de técnicas de alívio e bem-estar."""
    techniques_data = [
      {"key":"alongamento_maos","title":"Alongamento de Mãos","text":"TÉCNICA: Alongamento de Mãos\\nDURAÇÃO: 5 minutos\\nBOM PARA: Rigidez matinal\\nCOMO FAZER: 1. Sente-se confortavelmente ... ATENÇÃO: Pare se sentir dor forte"},
      {"key":"resp_profunda","title":"Respiração Profunda","text":"RESPIRAÇÃO PROFUNDA 5 minutos\\nReduz tensão e ansiedade\\nCOMO FAZER: 1. Sente-se..."},
      {"key":"resp_4_7_8","title":"Respiração 4-7-8","text":"RESPIRAÇÃO 4-7-8 3-5 minutos..."},
      {"key":"suspiro","title":"Suspiro de Alívio","text":"SUSPIRO DE ALÍVIO 2 minutos..."},
      {"key":"relaxamento","title":"Relaxamento Muscular","text":"RELAXAMENTO MUSCULAR 10-15 minutos..."},
      {"key":"toque","title":"Toque Calmante","text":"TOQUE CALMANTE 5 minutos..."}
    ]
    return jsonify(techniques_data)

@app.route('/api/education', methods=['GET'])
def education():
    """Retorna o conteúdo de educação sobre a condição."""
    # Nota: O conteúdo de educação completo deve ser inserido aqui ou lido de um arquivo
    ed = {"title":"Entendendo sua condição", "text":"A osteoartrite é uma doença crônica que afeta as articulações. É a forma mais comum de artrite e ocorre quando a cartilagem, o tecido que amortece as extremidades dos ossos, se desgasta ao longo do tempo. SINTOMAS: Dor, rigidez, perda de flexibilidade e inchaço. TRATAMENTO: O tratamento envolve uma combinação de exercícios, controle de peso, fisioterapia e medicamentos para alívio da dor."}
    return jsonify([ed])

# -----------------------
# Health check
# -----------------------
@app.route('/api/ping')
def ping():
    """Health check endpoint."""
    return jsonify({'ok': True})

if __name__ == '__main__':
    # Usado apenas para ambiente de desenvolvimento local
    # No PythonAnywhere, este bloco não é executado
    pass