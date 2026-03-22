pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REGISTRY = "280020694900.dkr.ecr.ap-south-1.amazonaws.com"
        ECR_REPO = "my-app"
        IMAGE_TAG = "latest"
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // 🔍 SONARQUBE
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonarqube') {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=devsecops-cicd-01 \
                        -Dsonar.sources=. \
                        -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        // ✅ QUALITY GATE
        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // 🐳 BUILD
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        // 🔐 TRIVY FIXED
        stage('Trivy Scan') {
            steps {
                sh '''
                HOME=/home/ubuntu trivy image --exit-code 0 --severity HIGH,CRITICAL $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 🔑 LOGIN ECR
        stage('Login to AWS ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
            }
        }

        // 📦 PUSH
        stage('Push Image to ECR') {
            steps {
                sh '''
                docker tag $ECR_REPO:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
                docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        // 🚀 DEPLOY ECS
        stage('Deploy to ECS') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster devops-cluster \
                --service devops-task-service-esru9f61 \
                --force-new-deployment \
                --region $AWS_REGION
                '''
            }
        }

        // 🧹 CLEANUP (IMPORTANT)
        stage('Cleanup') {
            steps {
                sh 'docker system prune -f'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful 🚀"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
