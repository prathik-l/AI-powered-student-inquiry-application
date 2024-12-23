from flask import Flask, jsonify
from ffrom flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
import pandas as pd

app = Flask(__name__)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/student_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Define models
class StudentsMaster(db.Model):
    __tablename__ = 'studentsmaster'
    UniqueStudentRegNo = db.Column(db.Integer, primary_key=True)
    StudentName = db.Column(db.String(100))
    DateOfJoining = db.Column(db.Date)

class StudentsMarksheet(db.Model):
    __tablename__ = 'studentsmarksheet'
    UniqueStudentRegNo = db.Column(db.Integer, db.ForeignKey('studentsmaster.UniqueStudentRegNo'), primary_key=True)
    TestTerm = db.Column(db.String(50), primary_key=True)
    Average = db.Column(db.Float)
    Grade = db.Column(db.String(1))

# API to fetch admission statistics
@app.route('/admission-stats', methods=['GET'])
def admission_stats():
    results = db.session.query(
        db.func.extract('year', StudentsMaster.DateOfJoining).label('Year'),
        db.func.count(StudentsMaster.UniqueStudentRegNo).label('Count')
    ).group_by('Year').order_by('Year').all()

    data = [{"Year": int(row.Year), "Count": row.Count} for row in results]
    return jsonify(data)

# API to fetch student performance
@app.route('/student-performance', methods=['GET'])
def student_performance():
    query = db.session.query(
        StudentsMaster.StudentName,
        StudentsMarksheet.TestTerm,
        StudentsMarksheet.Average,
        StudentsMarksheet.Grade
    ).join(StudentsMarksheet, StudentsMaster.UniqueStudentRegNo == StudentsMarksheet.UniqueStudentRegNo).all()

    data = [{"StudentName": row.StudentName, "TestTerm": row.TestTerm, "Average": row.Average, "Grade": row.Grade} for row in query]
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
lask_sqlalchemy import SQLAlchemy
import pandas as pd

app = Flask(__name__)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/student_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Define models
class StudentsMaster(db.Model):
    __tablename__ = 'studentsmaster'
    UniqueStudentRegNo = db.Column(db.Integer, primary_key=True)
    StudentName = db.Column(db.String(100))
    DateOfJoining = db.Column(db.Date)

class StudentsMarksheet(db.Model):
    __tablename__ = 'studentsmarksheet'
    UniqueStudentRegNo = db.Column(db.Integer, db.ForeignKey('studentsmaster.UniqueStudentRegNo'), primary_key=True)
    TestTerm = db.Column(db.String(50), primary_key=True)
    Average = db.Column(db.Float)
    Grade = db.Column(db.String(1))

# API to fetch admission statistics
@app.route('/admission-stats', methods=['GET'])
def admission_stats():
    results = db.session.query(
        db.func.extract('year', StudentsMaster.DateOfJoining).label('Year'),
        db.func.count(StudentsMaster.UniqueStudentRegNo).label('Count')
    ).group_by('Year').order_by('Year').all()

    data = [{"Year": int(row.Year), "Count": row.Count} for row in results]
    return jsonify(data)

# API to fetch student performance
@app.route('/student-performance', methods=['GET'])
def student_performance():
    query = db.session.query(
        StudentsMaster.StudentName,
        StudentsMarksheet.TestTerm,
        StudentsMarksheet.Average,
        StudentsMarksheet.Grade
    ).join(StudentsMarksheet, StudentsMaster.UniqueStudentRegNo == StudentsMarksheet.UniqueStudentRegNo).all()

    data = [{"StudentName": row.StudentName, "TestTerm": row.TestTerm, "Average": row.Average, "Grade": row.Grade} for row in query]
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True)
