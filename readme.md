<img width="1536" height="1024" alt="sonar1" src="https://github.com/user-attachments/assets/f56f7a93-4fcc-4fa9-9331-330923c753f1" />
<img width="1095" height="503" alt="Screenshot 2026-03-23 120539" src="https://github.com/user-attachments/assets/8ad38294-39d1-48d4-b759-187d872b6513" />
<img width="1103" height="313" alt="Screenshot 2026-03-23 120517" src="https://github.com/user-attachments/assets/aca80e85-8cea-486f-a815-28d9cc3e478b" />
<img width="1080" height="434" alt="Screenshot 2026-03-23 120500" src="https://github.com/user-attachments/assets/7282622e-9691-42c0-a235-2b11bb069cdc" />
<img width="1086" height="492" alt="Screenshot 2026-03-23 120441" src="https://github.com/user-attachments/assets/c14a436d-dd32-439c-a45e-6d6d061c5032" />
<img width="1108" height="494" alt="Screenshot 2026-03-23 120328" src="https://github.com/user-attachments/assets/be502b3b-45a8-4fb5-bc5d-6953c8ce5d23" />
<img width="1536" height="1024" alt="jenkins1" src="https://github.com/user-attachments/assets/7fc0133b-34ea-4ead-be71-a1586154115d" />
<img width="1536" height="1024" alt="DevOps pipeline" src="https://github.com/user-attachments/assets/f6276d67-c5fd-4026-ad61-1e4a3c0e8fe9" />
🚀 **End-to-End DevSecOps CI/CD Pipeline on AWS – My Hands-on Journey**

I recently built a complete **DevSecOps CI/CD pipeline from scratch**, focusing on *how different tools integrate, what problems arise, and how to solve them in real-world scenarios.*

---

## 🏗️ Architecture (What & Why)

**GitHub → Jenkins → SonarQube → Docker → Trivy → AWS ECR → AWS ECS (via ALB)**

* **GitHub** → Code version control
* **Jenkins** → Automates CI/CD pipeline
* **SonarQube** → Code quality analysis
* **Docker** → Containerization
* **Trivy** → Security scanning
* **ECR** → Image storage
* **ECS (Fargate)** → Container deployment
* **ALB** → Traffic routing

👉 Goal: **Automated, secure, and zero-manual deployment**

---

## ☁️ AWS Setup (What & Why)

* **EC2** → Hosted Jenkins & SonarQube (custom environment setup)
* **Elastic IP** → Static public access (learned cost impact if unused)
* **IAM** → Secure permissions (critical for ECS/ECR access)
* **ALB** → Expose application publicly
* **ECR** → Store Docker images
* **ECS** → Run containers without managing servers

---

## ⚙️ Pipeline Setup (How I Built It)

* Created Jenkins **Pipeline from SCM**
* Integrated GitHub using credentials
* Configured **Webhook** for auto-trigger
* Wrote Jenkinsfile with stages:
  ✔ Checkout
  ✔ SonarQube Analysis
  ✔ Quality Gate
  ✔ Docker Build
  ✔ Trivy Scan
  ✔ Push to ECR
  ✔ Deploy to ECS

---

## 🔄 Pipeline Flow

1. Code push → GitHub
2. Webhook → Jenkins trigger
3. SonarQube → Quality check
4. Docker → Build image
5. Trivy → Security scan
6. ECR → Store image
7. ECS → Deploy latest version

---

## 🔑 Commands Used (What & Why)

### 🐳 Docker

```bash
docker build -t my-app .        # Build container image
docker tag my-app:latest <ECR_URI>   # Prepare for ECR
docker push <ECR_URI>          # Upload image
docker system prune -f         # Clean disk space
```

### ☁️ AWS ECS & ECR

```bash
aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin <ECR_URI>   # Auth ECR

aws ecs list-services --cluster devops-cluster           # Find service

aws ecs update-service \
--cluster devops-cluster \
--service <service-name> \
--force-new-deployment                                  # Deploy
```

### 🔄 Start/Stop ECS (Cost Control)

```bash
aws ecs update-service --cluster devops-cluster --service <service> --desired-count 0
aws ecs update-service --cluster devops-cluster --service <service> --desired-count 1
```

### 🔍 SonarQube

```bash
sonar-scanner -Dsonar.projectKey=devsecops-cicd-01 -Dsonar.sources=.
```

### 🔐 Trivy

```bash
trivy image my-app
```

### 🐧 Linux

```bash
sudo apt install docker.io -y
sudo systemctl start docker
aws configure
df -h
```

### 🔗 Git

```bash
git add .
git commit -m "update"
git push origin main
git pull origin main --rebase
```

---

## ⚠️ Problems I Faced & Solved

* ❌ **IAM Access Denied (ecs:UpdateService)**
  ✔ Added correct IAM role policies

* ❌ **ECS Service Not Found**
  ✔ Used `aws ecs list-services` to get correct name

* ❌ **ECR Push Failed (Token Expired)**
  ✔ Re-authenticated using login command

* ❌ **SonarQube Timeout Issue**
  ✔ Fixed Security Group + correct server URL

* ❌ **Trivy Error (snap restriction)**
  ✔ Reinstalled properly / adjusted HOME path

* ❌ **Dockerfile Errors**
  ✔ Fixed incorrect instructions

* ❌ **Webhook Not Triggering Jenkins**
  ✔ Fixed GitHub webhook URL and Jenkins config

* ❌ **Disk Space Issue (EC2)**
  ✔ Used `docker system prune -f`

---

## ✅ Final Outcome

✔ Fully automated CI/CD pipeline
✔ Integrated code quality + security checks
✔ Live deployment on ECS with ALB
✔ Real-world debugging experience

---

## 💡 Key Learning

> DevOps is not just about building pipelines — it's about solving real integration, permission, and infrastructure problems.

---

This project helped me gain strong practical experience in **CI/CD, AWS architecture, and DevSecOps workflows**.

Open to feedback and discussions 🙌

#DevOps #AWS #Jenkins #Docker #ECS #ECR #SonarQube #CI_CD #Cloud #Learning
