pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "280020694900.dkr.ecr.ap-south-1.amazonaws.com/devsecops-cicd-01"
        IMAGE_TAG = "latest"

        SONARQUBE = "SonarQube"
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Manyad05/devsecops-cicd-01.git'
            }
        }

        // 🔍 Sonar Scan for HTML/CSS/JS
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh """
                    sonar-scanner \
                    -Dsonar.projectKey=devsecops-cicd-01 \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_TOKEN
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // 🐳 Build Docker Image (HTML → Nginx)
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t devsecops-html-app .'
            }
        }

        // 🔐 Security Scan
        stage('Trivy Scan') {
            steps {
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL devsecops-html-app'
            }
        }

        // 🔑 Login to ECR
        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds']]) {

                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        // 📦 Push Image
        stage('Tag & Push to ECR') {
            steps {
                sh '''
                docker tag devsecops-html-app:latest $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 🚀 Deploy to ECS
        stage('Deploy to ECS') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster devops-cluster \
                --service devops-service \
                --force-new-deployment \
                --region $AWS_REGION
                '''
            }
        }
    }

    post {
        success {
            emailext (
                subject: "✅ SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2 style="color:green;">Deployment Successful 🚀</h2>
                <p><b>Project:</b> DevSecOps HTML App</p>
                <p><b>Build:</b> ${env.BUILD_NUMBER}</p>
                <p><a href="${env.BUILD_URL}">View Build</a></p>
                """,
                to: "your-email@gmail.com",
                mimeType: 'text/html'
            )
        }

        failure {
            emailext (
                subject: "❌ FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                <h2 style="color:red;">Pipeline Failed ❌</h2>
                <p><b>Check logs:</b> <a href="${env.BUILD_URL}">Open</a></p>
                """,
                to: "your-email@gmail.com",
                mimeType: 'text/html'
            )
        }
    }
}