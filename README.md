# 🚀 Agentic LLM Compression System

A production-grade, modular, and scalable system for intelligent model compression using agentic decision-making and response-based distillation via Gemini Pro API.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture & Microservices (Detailed)](MICROSERVICES_ARCHITECTURE.md)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Components](#components)
- [Examples](#examples)
- [Development](#development)
- [Contributing](#contributing)

---

## 🎯 Overview

This system automates the decision to compress LLM models and applies supervised fine-tuning distillation using a teacher model (Gemini Pro) to create efficient student models (default: distilgpt2).

### Key Features

✅ **Intelligent Agent Decision System** - Rule-based logic to determine if compression is beneficial
✅ **Automated Dataset Generation** - Generates instruction-response pairs using Gemini Pro API
✅ **Efficient Student Training** - Lightweight, configurable SFT-style distillation
✅ **Comprehensive Evaluation** - Metrics on size, latency, and accuracy
✅ **Microservices Architecture** - Clean separation of concerns with independent services
✅ **Production-Ready** - Error handling, logging, configuration management
✅ **Extensible Design** - Easy to add new models, strategies, or services

---

## 🏗️ Architecture

### Services

```
┌─────────────────────────────────────────────┐
│   ORCHESTRATOR SERVICE (PORT 8000)          │
│   - Main API endpoint (/optimize)           │
│   - Coordinates the pipeline                │
│   - Makes agent decisions                   │
└──────────┬──────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    │             │              │              │
    ▼             ▼              ▼              ▼
┌────────┐  ┌──────────────┐  ┌──────────────┐ ┌──────────────┐
│ANALYZER│  │ DISTILLATION │  │   PRUNING    │ │ QUANTIZATION │
│        │  │  (PORT 8001) │  │  (PORT 8004) │ │  (PORT 8005) │
│- Model │  │- Gemini Api  │  │- Magnitude   │ │- 4/8 bit     │
│  Metrics│  │- Dataset Gen │  │- 2:4 Sparse  │ │- float16     │
│        │  │- Training    │  │              │ │              │
└────────┘  └──────────────┘  └──────────────┘ └──────────────┘
```

### Pipeline Flow

```
1. User Request
   ↓
2. Analyzer: Compute model metrics
   ↓
3. Agent: Decide on compression (rule-based)
   ↓
4. If Distillation Needed:
   a. Generate dataset (Gemini)
   b. Train student model
   c. Save compressed model
   ↓
5. Quality Gate: Compute final metrics and compare
   ↓
6. Return: Optimization results + compression gains
```

---

## 📁 Project Structure

```
microservices/                   # Microservices and Algorithms
│   ├── orchestrator/           # Main orchestration logic
│   ├── distillation/           # Distillation core and service
│   ├── evaluation/             # Metrics and benchmarking
│   ├── pruning/                # Pruning implementation (Wanda, etc.)
│   ├── quantization/           # Quantization implementation
│   └── web_ui/                 # User interface
│
├── libs/                        # Shared libraries
│   └── common/                  # Configuration and utilities
│
├── models/                      # Model storage
├── datasets/                    # Dataset storage
├── logs/                        # Logging directory
├── infra/                       # Infrastructure (Docker, K8s)
├── docs/                        # Documentation
├── scripts/                     # Utility scripts
├── requirements.txt             # Python dependencies
└── README.md                    # This file
```

---

## 🔧 Installation

### 1. Prerequisites

- Python 3.10+
- pip or conda
- GPU (optional, for faster training)
- Google Gemini API key

### 2. Clone & Setup

```bash
cd project

# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Linux/Mac:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Set Environment Variables

```bash
# Create .env file
cat > .env << 'EOF'
GEMINI_API_KEY=your-gemini-api-key-here
EOF

# Or set directly
export GEMINI_API_KEY=your-api-key
```

**Get Gemini API Key:**
- Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
- Create a new API key
- Set it in environment variable

---

## ⚙️ Configuration

Key configurations in `common/config.py`:

```python
# Decision Thresholds (model exceeds → apply distillation)
DECISION_THRESHOLDS = {
    "max_model_size_mb": 1000,      # Size threshold
    "max_latency_ms": 500,          # Latency threshold
    "min_accuracy_score": 0.7,      # Accuracy threshold
}

# Dataset Generation
DATASET_CONFIG = {
    "num_samples": 150,             # Samples to generate
    "sample_size": 150,
    "batch_size": 4,
    "max_length": 256,
}

# Training
TRAINING_CONFIG = {
    "num_epochs": 2,
    "learning_rate": 5e-5,
    "batch_size": 8,
    "max_steps": 100,
}
```

---

## 🚀 Usage

### Option 1: Running All Services

```bash
# Terminal 1: Start Orchestrator (port 8000)
python microservices/orchestrator/src/main.py

# Terminal 2: Start Distillation Service (port 8001)
python microservices/distillation/src/app.py

# Terminal 3: Start Pruning Service (port 8004)
python microservices/pruning/src/app.py

# Terminal 4: Start Quantization Service (port 8005)
python microservices/quantization/src/app.py

# Terminal 5: Start Web UI (port 8003)
python microservices/web_ui/manage.py runserver 0.0.0.0:8003
```

### Option 2: Using Docker (Optional)

```bash
# Build & run with docker-compose (if docker-compose.yml exists)
docker-compose up
```

### Option 3: Development Mode

```bash
# For quick testing without services
from orchestrator.agent import CompressionAgent
from orchestrator.analyzer import ModelAnalyzer

analyzer = ModelAnalyzer()
analysis = analyzer.analyze("distilgpt2")

agent = CompressionAgent()
decision = agent.decide(analysis)
print(decision.to_dict())
```

---

## 📡 API Endpoints

### Orchestrator Service (Port 8000)

#### 1. **POST /optimize** - Main Optimization Endpoint

Orchestrates the complete compression pipeline.

**Request:**
```json
{
  "model_name": "distilgpt2",
  "student_model": "distilgpt2",
  "num_epochs": 2,
  "batch_size": 8,
  "gemini_api_key": "your-key-or-use-env",
  "skip_distillation": false
}
```

**Response:**
```json
{
  "status": "success",
  "original_model": "distilgpt2",
  "original_metrics": {
    "model_size_mb": 350.5,
    "inference_latency_ms": 45.2,
    "accuracy_score": 0.82,
    "num_parameters": 82000000
  },
  "agent_decision": {
    "plan": ["no_compression"],
    "reasoning": "Model meets performance criteria",
    "strategy": "no_compression",
    "confidence": 0.65
  },
  "optimization_applied": false,
  "model_path": null,
  "compression_ratio_percent": null,
  "speedup_factor": null
}
```

#### 2. **POST /analyze** - Analyze Model Only

```bash
curl -X POST "http://localhost:8000/analyze?model_name=distilgpt2"
```

#### 3. **POST /decide** - Get Agent Decision

```bash
curl -X POST "http://localhost:8000/decide" \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "gpt2",
    "analysis": {
      "model_size_mb": 1500,
      "inference_latency_ms": 250,
      "accuracy_score": 0.80,
      "num_parameters": 124000000
    }
  }'
```

#### 4. **GET /config** - View Configuration

```bash
curl http://localhost:8000/config
```

#### 5. **GET /health** - Health Check

```bash
curl http://localhost:8000/health
```

---

### Distillation Service (Port 8001)

#### 1. **POST /distill** - Full Distillation Pipeline

```bash
curl -X POST "http://localhost:8001/distill" \
  -H "Content-Type: application/json" \
  -d '{
    "student_model": "distilgpt2",
    "num_samples": 150,
    "num_epochs": 2,
    "batch_size": 8,
    "gemini_api_key": "your-key"
  }'
```

#### 2. **POST /distill/generate-dataset** - Generate Dataset Only

```bash
curl -X POST "http://localhost:8001/distill/generate-dataset" \
  -d '{"num_samples": 100}'
```

#### 3. **POST /distill/train** - Train on Existing Dataset

```bash
curl -X POST "http://localhost:8001/distill/train" \
  -d '{"student_model": "distilgpt2", "num_epochs": 2}'
```

---

### Evaluation Service (Port 8002)

#### 1. **POST /evaluate** - Evaluate Model

```bash
curl -X POST "http://localhost:8002/evaluate" \
  -H "Content-Type: application/json" \
  -d '{"model_name": "distilgpt2"}'
```

#### 2. **POST /evaluate/batch** - Evaluate Multiple Models

```bash
curl -X POST "http://localhost:8002/evaluate/batch" \
  -H "Content-Type: application/json" \
  -d '{"models": ["distilgpt2", "gpt2"]}'
```

#### 3. **GET /evaluate/compare** - Compare Two Models

```bash
curl "http://localhost:8002/evaluate/compare?model1=distilgpt2&model2=gpt2"
```

---

## 🧠 Components

### 1. Agent Module (`orchestrator/agent.py`)

**Purpose:** Intelligent decision-making for compression

**Key Classes:**
- `CompressionAgent`: Rule-based decision logic
- `LLMReasoningAgent`: Extensible for LLM-based reasoning
- `AgentDecision`: Decision output structure

**Decision Flow:**
1. Check model size vs. threshold
2. Check inference latency vs. threshold
3. Check accuracy vs. threshold
4. Calculate confidence score
5. Return decision with reasoning

**Example:**
```python
from orchestrator.agent import CompressionAgent

agent = CompressionAgent()
analysis = {
    "model_size_mb": 1200,
    "inference_latency_ms": 600,
    "accuracy_score": 0.75,
    "num_parameters": 150_000_000,
}

decision = agent.decide(analysis)
print(decision.plan)  # ["distillation"]
print(decision.confidence)  # 0.78
```

---

### 2. Analyzer Module (`orchestrator/analyzer.py`)

**Purpose:** Compute model metrics

**Key Classes:**
- `ModelAnalyzer`: Load and analyze HuggingFace models

**Metrics Computed:**
- **Model Size (MB)**: Memory footprint
- **Latency (ms)**: Inference speed on sample input
- **Accuracy Proxy**: Loss-based approximation
- **Parameter Count**: Number of trainable parameters

**Example:**
```python
from orchestrator.analyzer import ModelAnalyzer

analyzer = ModelAnalyzer(device="cuda")
metrics = analyzer.analyze("distilgpt2")
# Returns: {
#   "model_size_mb": 350.5,
#   "inference_latency_ms": 45.2,
#   "accuracy_score": 0.82,
#   "num_parameters": 82_000_000
# }
```

---

### 3. Gemini Client (`services/distill/gemini_client.py`)

**Purpose:** Interface with Google Gemini Pro API

**Key Methods:**
- `generate_response()`: Single prompt response
- `generate_batch()`: Multiple prompts
- `test_connection()`: Verify API access

**Example:**
```python
from services.distill.gemini_client import GeminiClient

client = GeminiClient(api_key="your-key")
response = client.generate_response(
    "Explain machine learning in 2 sentences"
)
print(response)
```

---

### 4. Dataset Generator (`services/distill/generate_data.py`)

**Purpose:** Create instruction-response training data

**Key Methods:**
- `generate_dataset()`: Full pipeline
- `_generate_instructions()`: Create diverse prompts
- `create_huggingface_dataset()`: Format for training

**Dataset Format:**
```json
{
  "dataset": [
    {
      "instruction": "Explain machine learning in 2-3 sentences.",
      "response": "Machine learning is a subset..."
    },
    ...
  ],
  "num_samples": 150,
  "metadata": {...}
}
```

---

### 5. Student Trainer (`services/distill/train.py`)

**Purpose:** Fine-tune student model on generated data

**Key Classes:**
- `StudentTrainer`: Handles training pipeline

**Training Configuration:**
- Model: distilgpt2 (default)
- Epochs: 1-2 (lightweight)
- Learning Rate: 5e-5
- Max Steps: 100 (for efficiency)

**Example:**
```python
from services.distill.train import StudentTrainer

trainer = StudentTrainer(student_model_name="distilgpt2")
results = trainer.train(
    dataset_path="path/to/dataset.json",
    num_epochs=2
)
```

---

## 📊 Examples

### Example 1: Full Optimization Pipeline

```bash
# Start all services in separate terminals
python orchestrator/main.py
python services/distill/app.py
python services/evaluate/app.py

# Make optimization request
curl -X POST "http://localhost:8000/optimize" \
  -H "Content-Type: application/json" \
  -d '{
    "model_name": "gpt2",
    "student_model": "distilgpt2",
    "gemini_api_key": "your-api-key"
  }'
```

### Example 2: Python Script

```python
import asyncio
from orchestrator.agent import CompressionAgent
from orchestrator.analyzer import ModelAnalyzer
from services.distill.generate_data import DatasetGenerator
from services.distill.gemini_client import GeminiClient
from services.distill.train import StudentTrainer

async def compress_model(model_name: str, api_key: str):
    # 1. Analyze
    analyzer = ModelAnalyzer()
    analysis = analyzer.analyze(model_name)
    print(f"Original Model Metrics: {analysis}")
    
    # 2. Decide
    agent = CompressionAgent()
    decision = agent.decide(analysis)
    print(f"Agent Decision: {decision.to_dict()}")
    
    if decision.strategy.value == "distillation":
        # 3. Generate dataset
        client = GeminiClient(api_key=api_key)
        dataset_gen = DatasetGenerator(client)
        dataset = dataset_gen.generate_dataset(num_samples=100)
        print(f"Generated {len(dataset['dataset'])} samples")
        
        # 4. Train student
        trainer = StudentTrainer()
        result = trainer.train(dataset_path="path/to/dataset.json")
        print(f"Training complete: {result}")

# Run
asyncio.run(compress_model("gpt2", "your-api-key"))
```

---

## 💻 Development

### Running Tests

```bash
# Run all tests
pytest

# Run specific module
pytest tests/test_agent.py -v

# With coverage
pytest --cov=orchestrator --cov=services
```

### Code Quality

```bash
# Format code
black orchestrator/ services/ common/

# Lint
flake8 orchestrator/ services/ common/

# Import sorting
isort orchestrator/ services/ common/
```

### Logging

Logs are written to `logs/compression_system.log` with:
- Console output: INFO level
- File output: DEBUG level
- Structured format with timestamps and line numbers

**View logs:**
```bash
tail -f logs/compression_system.log
```

---

## 🔐 Security Considerations

1. **API Keys**: Use environment variables, never hardcode
2. **Input Validation**: All requests validated with Pydantic
3. **Error Handling**: Comprehensive try-catch with logging
4. **Rate Limiting**: Can be added to FastAPI middleware if needed
5. **CORS**: Currently allows all origins (restrict in production)

---

## 🚀 Deployment

### Docker Deployment

```dockerfile
# Create Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY orchestrator/ orchestrator/
COPY services/ services/
COPY common/ common/

ENV GEMINI_API_KEY=${GEMINI_API_KEY}

CMD ["python", "orchestrator/main.py"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  orchestrator:
    build: .
    ports:
      - "8000:8000"
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
    
  distillation:
    build: .
    ports:
      - "8001:8001"
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
    command: python services/distill/app.py
    
  evaluation:
    build: .
    ports:
      - "8002:8002"
    command: python services/evaluate/app.py
```

---

## 📈 Performance Notes

- **Latency**: ~2-5 minutes for full pipeline (dataset generation + training)
- **Memory**: ~4GB for model analysis and training
- **GPU**: Significantly faster with CUDA-enabled GPU
- **API Calls**: ~150 calls to Gemini for dataset generation

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/xyz`
3. Commit changes: `git commit -am 'Add xyz'`
4. Push branch: `git push origin feature/xyz`
5. Submit pull request

---

## 📝 License

MIT License - See LICENSE file

---

## 📧 Support

For issues, questions, or suggestions:
- Open an GitHub issue
- Check existing documentation
- Review logs in `logs/compression_system.log`

---

## 🗺️ Roadmap

- [ ] LLM-based agent reasoning (Claude/GPT integration)
- [ ] Multi-model ensemble distillation
- [ ] Quantization support
- [ ] Web UI dashboard
- [ ] Model registry with versioning
- [ ] Automated benchmarking
- [ ] Kubernetes deployment templates

---

**Built with ❤️ for production-grade ML systems**
