import React, { useEffect, useState } from "react";

const API_URL = process.env.REACT_APP_API_URL || "/api/v1";

function App() {
  const [status, setStatus] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(`${API_URL}/status`)
      .then((res) => res.json())
      .then(setStatus)
      .catch(() => setError("Could not reach backend"));
  }, []);

  return (
    <div style={{ fontFamily: "sans-serif", padding: "2rem", maxWidth: 600, margin: "0 auto" }}>
      <h1>StartTech</h1>
      <p>React frontend → S3 / CloudFront</p>
      <p>Go backend → EC2 / ALB</p>
      <hr />
      <h2>Backend Status</h2>
      {error && <p style={{ color: "red" }}>{error}</p>}
      {status && (
        <pre style={{ background: "#f4f4f4", padding: "1rem", borderRadius: 4 }}>
          {JSON.stringify(status, null, 2)}
        </pre>
      )}
      {!status && !error && <p>Loading...</p>}
    </div>
  );
}

export default App;