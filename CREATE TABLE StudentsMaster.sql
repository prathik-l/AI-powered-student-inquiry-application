CREATE TABLE StudentsMaster (
    StudentName VARCHAR(100),
    Gender CHAR(1),
    DOB DATE,
    FatherName VARCHAR(100),
    MotherName VARCHAR(100),
    FathersOccupation VARCHAR(100),
    FathersIncome DECIMAL(10, 2),
    BloodGroup VARCHAR(5),
    Address TEXT,
    City VARCHAR(100),
    State VARCHAR(100),
    DateOfJoining DATE,
    DateOfRecordCreation DATE DEFAULT CURRENT_DATE,
    UniqueStudentRegNo SERIAL PRIMARY KEY
);


CREATE TABLE StudentsMarksheet (
    UniqueStudentRegNo INT REFERENCES StudentsMaster(UniqueStudentRegNo),
    Class VARCHAR(20),
    Section CHAR(1),
    TestTerm VARCHAR(50),
    Tamil INT,
    English INT,
    Maths INT,
    Science INT,
    SocialScience INT,
    Total INT GENERATED ALWAYS AS (Tamil + English + Maths + Science + SocialScience) STORED,
    Average DECIMAL(5, 2) GENERATED ALWAYS AS (Total / 5.0) STORED,
    Grade CHAR(1),
    PRIMARY KEY (UniqueStudentRegNo, TestTerm)
);


SELECT SM.StudentName, SM.City, SM.State, M.Class, M.Section, M.TestTerm, M.Average, M.Grade
FROM StudentsMaster SM
JOIN StudentsMarksheet M ON SM.UniqueStudentRegNo = M.UniqueStudentRegNo
WHERE M.Average > 80 AND M.Grade = 'A';


SELECT SM.StudentName, SM.FathersIncome, M.Class, M.Section, M.Average
FROM StudentsMaster SM
JOIN StudentsMarksheet M ON SM.UniqueStudentRegNo = M.UniqueStudentRegNo
WHERE SM.FathersIncome < 30000 AND M.Average > 75;


SELECT EXTRACT(YEAR FROM DateOfJoining) AS AcademicYear, COUNT(*) AS StudentsCount
FROM StudentsMaster
WHERE EXTRACT(YEAR FROM DateOfJoining) = 2024
GROUP BY EXTRACT(YEAR FROM DateOfJoining);













from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import nltk
from nltk.tokenize import word_tokenize

nltk.download('punkt')

app = Flask(__name__)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/student_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
ma = Marshmallow(app)

# Define models
class StudentsMaster(db.Model):
    UniqueStudentRegNo = db.Column(db.Integer, primary_key=True)
    StudentName = db.Column(db.String(100))
    Gender = db.Column(db.String(1))
    DOB = db.Column(db.Date)
    FatherName = db.Column(db.String(100))
    MotherName = db.Column(db.String(100))
    FathersOccupation = db.Column(db.String(100))
    FathersIncome = db.Column(db.Float)
    BloodGroup = db.Column(db.String(5))
    Address = db.Column(db.Text)
    City = db.Column(db.String(100))
    State = db.Column(db.String(100))
    DateOfJoining = db.Column(db.Date)
    DateOfRecordCreation = db.Column(db.Date)

class StudentsMarksheet(db.Model):
    UniqueStudentRegNo = db.Column(db.Integer, db.ForeignKey('students_master.UniqueStudentRegNo'), primary_key=True)
    Class = db.Column(db.String(20))
    Section = db.Column(db.String(1))
    TestTerm = db.Column(db.String(50), primary_key=True)
    Tamil = db.Column(db.Integer)
    English = db.Column(db.Integer)
    Maths = db.Column(db.Integer)
    Science = db.Column(db.Integer)
    SocialScience = db.Column(db.Integer)
    Total = db.Column(db.Integer)
    Average = db.Column(db.Float)
    Grade = db.Column(db.String(1))

# Define schemas
class StudentsMasterSchema(ma.SQLAlchemySchema):
    class Meta:
        model = StudentsMaster
    UniqueStudentRegNo = ma.auto_field()
    StudentName = ma.auto_field()
    DateOfJoining = ma.auto_field()

class StudentsMarksheetSchema(ma.SQLAlchemySchema):
    class Meta:
        model = StudentsMarksheet
    UniqueStudentRegNo = ma.auto_field()
    Grade = ma.auto_field()
    Average = ma.auto_field()
    TestTerm = ma.auto_field()

master_schema = StudentsMasterSchema()
marksheet_schema = StudentsMarksheetSchema()
masters_schema = StudentsMasterSchema(many=True)
marksheets_schema = StudentsMarksheetSchema(many=True)

# Natural Language Query Handler
@app.route('/query', methods=['POST'])
def handle_query():
    query = request.json.get('query', '')
    tokens = word_tokenize(query.lower())
    
    if 'admitted' in tokens and '2024' in tokens:
        results = StudentsMaster.query.filter(StudentsMaster.DateOfJoining.like('2024%')).all()
        return jsonify(masters_schema.dump(results))
    
    if 'grades' in tokens and 'above' in tokens:
        grade = tokens[tokens.index('above') + 1].upper()
        term = tokens[tokens.index('term') + 1] if 'term' in tokens else None
        results = StudentsMarksheet.query.filter(StudentsMarksheet.Grade > grade)
        if term:
            results = results.filter(StudentsMarksheet.TestTerm == term)
        return jsonify(marksheets_schema.dump(results))
    
    return jsonify({"message": "Query not understood"}), 400

# CRUD Endpoints (Example: StudentsMaster)
@app.route('/students', methods=['POST'])
def add_student():
    data = request.json
    student = StudentsMaster(**data)
    db.session.add(student)
    db.session.commit()
    return master_schema.jsonify(student)

@app.route('/students/<int:reg_no>', methods=['GET'])
def get_student(reg_no):
    student = StudentsMaster.query.get_or_404(reg_no)
    return master_schema.jsonify(student)

@app.route('/students/<int:reg_no>', methods=['PUT'])
def update_student(reg_no):
    student = StudentsMaster.query.get_or_404(reg_no)
    for key, value in request.json.items():
        setattr(student, key, value)
    db.session.commit()
    return master_schema.jsonify(student)

@app.route('/students/<int:reg_no>', methods=['DELETE'])
def delete_student(reg_no):
    student = StudentsMaster.query.get_or_404(reg_no)
    db.session.delete(student)
    db.session.commit()
    return jsonify({"message": "Student deleted"})

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)







SELECT SM.StudentName, SM.FathersIncome, M.Average, M.Grade
FROM StudentsMaster SM
JOIN StudentsMarksheet M ON SM.UniqueStudentRegNo = M.UniqueStudentRegNo
WHERE SM.FathersIncome < 30000
ORDER BY M.Average DESC;


SELECT SM.StudentName, M.TestTerm, M.Tamil, M.English, M.Maths, M.Science, M.SocialScience
FROM StudentsMaster SM
JOIN StudentsMarksheet M ON SM.UniqueStudentRegNo = M.UniqueStudentRegNo
WHERE M.Tamil < 35 OR M.English < 35 OR M.Maths < 35 OR M.Science < 35 OR M.SocialScience < 35;
