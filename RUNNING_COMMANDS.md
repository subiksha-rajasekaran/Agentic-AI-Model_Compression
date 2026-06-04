# 🚀 Agentic AI Model Compression: Running Commands

This guide provides the necessary commands to run the Agentic Model Compression project.

## 🌟 Recommended: Docker Compose (Efficient & Scalable)

Docker Compose is the most stable and efficient way to run the entire project. It handles all networking, port assignments, and starts Redis automatically.

### 1. Setup Environment
Create a `.env` file in the root directory (copy from `.env.example`) and add your Gemini API Key:
```bash
GEMINI_API_KEY=your_actual_key_here
```

### 2. Launch the Stack
```powershell
# Build and start all services in detached mode
docker-compose up -d --build
```

### 3. Access
- **Web Dashboard**: [http://localhost:8003](http://localhost:8003)
- **Orchestrator API**: [http://localhost:8000](http://localhost:8000)

### 4. Stop and Cleanup
```powershell
docker-compose down
```

---

## 🛠️ Alternative: Manual Terminal Startup (For Debugging)

If you prefer to run services manually for debugging purposes:

### 1. Environment Setup
```powershell
# Install dependencies
pip install -r requirements.txt

# Set PYTHONPATH
$env:PYTHONPATH = "$(Get-Location);$(Get-Location)\libs"

# Kill any ghost processes on ports
Stop-Process -Name python -ErrorAction SilentlyContinue
```

## 2. Infrastructure (Redis)

Redis is required for job state persistence and traversal path learning.

```powershell
# If using Docker
docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 redis/redis-stack:latest

# If running locally (Standard Windows Redis)
redis-server.exe
```

## 3. Microservices (Individual Startup)

Run each service in a separate terminal window for better logging:

### Orchestrator (Port 8000)
*The brain of the system.*
```powershell
python microservices/orchestrator/src/main.py
```

### Distillation Service (Port 8001)
*Handles synthetic dataset generation and student training.*
```powershell
python microservices/distillation/src/app.py
```

### Evaluation Service (Port 8002)
*Analyzes model speed, size, and accuracy.*
```powershell
python microservices/evaluation/src/app.py
```

### Web Dashboard (Port 8003)
*The Django-based visualization interface.*
```powershell
cd microservices/web_ui
python manage.py runserver 8003
```

### Pruning Service (Port 8004)
*Implements Structured/WANDA pruning.*
```powershell
python microservices/pruning/src/app.py
```

### Quantization Service (Port 8005)
*Implements 4-bit (NF4) and 8-bit quantization.*
```powershell
python microservices/quantization/src/app.py
```

---

## 4. Automated Startup (PowerShell)

You can trigger all background services at once using the provided script:

```powershell
.\start_services.ps1
```

## 5. API Testing (Optional)

You can test if the orchestrator is alive by hitting the health endpoint:

```powershell
Invoke-RestMethod -Uri http://localhost:8000/health
```

## 6. Cleanup

To stop all background python processes:

```powershell
Stop-Process -Name python
```
