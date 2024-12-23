import React, { useState } from 'react';
import axios from 'axios';

function App() {
  const [regNo, setRegNo] = useState('');
  const [studentData, setStudentData] = useState(null);
  const [aiPrompt, setAiPrompt] = useState('');
  const [insights, setInsights] = useState('');

  const fetchStudent = async () => {
    try {
      const response = await axios.get(`/student/${regNo}`);
      setStudentData(response.data);
    } catch (error) {
      alert("Student not found");
    }
  };

  const fetchInsights = async () => {
    try {
      const response = await axios.post('/grade-insights', { prompt: aiPrompt });
      setInsights(response.data.insights);
    } catch (error) {
      alert("Error fetching insights");
    }
  };

  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif" }}>
      <h1>Student Search</h1>
      <input
        type="number"
        placeholder="Enter Registration Number"
        value={regNo}
        onChange={(e) => setRegNo(e.target.value)}
        style={{ padding: "10px", marginRight: "10px" }}
      />
      <button onClick={fetchStudent} style={{ padding: "10px" }}>Search</button>

      {studentData && (
        <div style={{ marginTop: "20px" }}>
          <h3>Student Details:</h3>
          <p>Name: {studentData.StudentName}</p>
          <p>Average Marks: {studentData.Average}</p>
          <p>Grade: {studentData.Grade}</p>
        </div>
      )}

      <div style={{ marginTop: "40px" }}>
        <h1>AI-Driven Insights</h1>
        <textarea
          rows="4"
          cols="50"
          placeholder="Enter a query for AI insights..."
          value={aiPrompt}
          onChange={(e) => setAiPrompt(e.target.value)}
          style={{ padding: "10px", marginBottom: "10px" }}
        />
        <br />
        <button onClick={fetchInsights} style={{ padding: "10px" }}>Get Insights</button>
        {insights && (
          <div style={{ marginTop: "20px" }}>
            <h3>AI Insights:</h3>
            <p>{insights}</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
