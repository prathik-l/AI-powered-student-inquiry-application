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
