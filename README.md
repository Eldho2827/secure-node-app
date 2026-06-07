# 🔐 Secure Node.js App — Docker + AWS ECR + Jenkins CI/CD

![Docker](https://img.shields.io/badge/Docker-29.1.3-2496ED?style=flat-square&logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18--alpine-339933?style=flat-square&logo=node.js&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-2.555.2-D24939?style=flat-square&logo=jenkins&logoColor=white)
![AWS ECR](https://img.shields.io/badge/AWS-ECR-FF9900?style=flat-square&logo=amazonaws&logoColor=white)
![AWS EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=flat-square&logo=amazonaws&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Source-181717?style=flat-square&logo=github&logoColor=white)

A production-ready, secure Node.js web application containerised with a **multi-stage Dockerfile**, deployed using **Docker volumes and custom networks**, pushed to **AWS ECR**, and automated end-to-end with a **Jenkins CI/CD Pipeline** — all running on AWS EC2.

---

## 📌 Table of Contents

- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Docker Setup](#-docker-setup)
- [AWS ECR](#-aws-ecr)
- [Jenkins CI/CD Pipeline](#-jenkins-cicd-pipeline)
- [Security Best Practices](#-security-best-practices)
- [Pipeline Stages](#-pipeline-stages)

---

## 🏗 Architecture

```
Developer Push
      │
      ▼
 GitHub Repo
      │
      ▼
Jenkins Pipeline (AWS EC2 - ap-south-1)
      │
      ├── Clone Repository
      ├── Build Docker Image (Multi-Stage)
      ├── Login to AWS ECR
      └── Push Image to ECR
                │
                ▼
         AWS ECR Registry
   515241426563.dkr.ecr.ap-south-1.amazonaws.com
```

---

## 📁 Project Structure

```
secure-node-app/
├── app.js              # Node.js application entry point
├── package.json        # Dependencies and scripts
├── Dockerfile          # Multi-stage Docker build
├── Jenkinsfile         # Jenkins declarative pipeline
├── .gitignore          # Excludes node_modules, .env
└── README.md           # Project documentation
```

---

## ✨ Features

- ✅ Secure Node.js application running on port 3000
- ✅ Multi-stage Dockerfile — minimal image size with `node:18-alpine`
- ✅ Non-root user inside container (`appuser`) — security hardened
- ✅ Docker named volume for log persistence (`app-volume:/app/logs`)
- ✅ Custom Docker bridge network (`secure-network`)
- ✅ AWS ECR private registry integration
- ✅ Fully automated Jenkins CI/CD pipeline
- ✅ Auto-tagged images (`build-N` + `latest`) on every pipeline run
- ✅ Post-build cleanup of local Docker images

---

## 🛠 Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18-alpine | Application runtime |
| Docker | 29.1.3 | Containerisation |
| Jenkins | 2.555.2 | CI/CD automation |
| AWS EC2 | Ubuntu 24.04 LTS | Cloud infrastructure |
| AWS ECR | ap-south-1 | Container image registry |
| AWS CLI | v2 | AWS service interaction |
| GitHub | — | Source code & pipeline trigger |

---

## 🚀 Getting Started

### Prerequisites

- AWS EC2 instance (Ubuntu 24.04 LTS)
- Docker installed
- AWS CLI configured with IAM credentials
- Jenkins running as a Docker container

### Clone the Repository

```bash
git clone https://github.com/Eldho2827/secure-node-app.git
cd secure-node-app
```

### Run Locally

```bash
npm install
node app.js
# Server running on port 3000
```

---

## 🐳 Docker Setup

### Build the Image

```bash
docker build --no-cache -t secure-node-app:v1 .
```

### Run the Container

```bash
docker run -d \
  --name secure-app \
  -p 3000:3000 \
  secure-node-app:v1
```

### Run with Volume and Network

```bash
# Create volume and network
docker volume create app-volume
docker network create secure-network

# Run with volume mount and custom network
docker run -d \
  --name secure-app \
  -p 3000:3000 \
  -v app-volume:/app/logs \
  --network secure-network \
  secure-node-app:v1
```

### Verify

```bash
docker ps
docker logs secure-app
```

Visit `http://<EC2-PUBLIC-IP>:3000`

---

## ☁️ AWS ECR

### Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name nodejs-secure-app \
  --region ap-south-1
```

### Login to ECR

```bash
aws ecr get-login-password --region ap-south-1 | \
  docker login --username AWS --password-stdin \
  515241426563.dkr.ecr.ap-south-1.amazonaws.com
```

### Tag and Push

```bash
docker tag secure-node-app:v1 \
  515241426563.dkr.ecr.ap-south-1.amazonaws.com/nodejs-secure-app:v1

docker push \
  515241426563.dkr.ecr.ap-south-1.amazonaws.com/nodejs-secure-app:v1
```

---

## 🔧 Jenkins CI/CD Pipeline

Jenkins runs as a Docker container on the EC2 instance with the Docker socket mounted.

### Start Jenkins

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  jenkins/jenkins:lts

# Fix Docker socket permissions
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Configure the Pipeline

1. Jenkins Dashboard → **New Item** → **Pipeline**
2. Name: `secure-node-app-pipeline`
3. Pipeline → **Pipeline script from SCM**
4. SCM → **Git** → `https://github.com/Eldho2827/secure-node-app.git`
5. Branch → `*/main`
6. Script Path → `Jenkinsfile`
7. **Save** → **Build Now**

---

## 🔒 Security Best Practices

| Practice | Implementation |
|----------|---------------|
| Non-root user | `adduser -S appuser` in Dockerfile |
| Minimal base image | `node:18-alpine` — reduced attack surface |
| Multi-stage build | Dev tools excluded from production image |
| Volume isolation | Logs on separate named volume |
| Network isolation | Custom bridge network `secure-network` |
| Port restriction | Only port 3000 exposed |
| IAM credentials | Stored in `~/.aws/` — not hardcoded |

---

## 📊 Pipeline Stages

```
┌─────────────────┐
│  Checkout SCM   │  ← Reads Jenkinsfile from GitHub
└────────┬────────┘
         │
┌────────▼────────┐
│ Clone Repository│  ← git clone main branch
└────────┬────────┘
         │
┌────────▼────────┐
│  Build Docker   │  ← docker build --no-cache (multi-stage)
│     Image       │
└────────┬────────┘
         │
┌────────▼────────┐
│  Login to ECR   │  ← aws ecr get-login-password | docker login
└────────┬────────┘
         │
┌────────▼────────┐
│  Push to ECR    │  ← Pushes build-N + latest tags
└────────┬────────┘
         │
┌────────▼────────┐
│  Post: Cleanup  │  ← docker rmi (frees EC2 disk space)
└─────────────────┘
```

**Build #4 — All stages passed ✅ — June 07, 2026**

ECR Image: `515241426563.dkr.ecr.ap-south-1.amazonaws.com/nodejs-secure-app:build-4`

---

## 👨‍💻 Author

**Eldho Sabu**
AWS DevOps Intern
🔗 [LinkedIn](https://linkedin.com/in/eldhosabu08) · 🐙 [GitHub](https://github.com/Eldho2827)
