pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "280020694900.dkr.ecr.ap-south-1.amazonaws.com/my-app"
        IMAGE_TAG = "latest"

        SONARQUBE = "sonarqube"
        SONAR_TOKEN = credentials('sonar-token')
    }

    tools {
        git 'Default'
    }

    stages {

        // 🔽 AUTO TRIGGER VIA GITHUB WEBHOOK
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Manyad05/devsecops-cicd-01.git'
            }
        }

        // 🔍 SONARQUBE SCAN
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv("${SONARQUBE}") {
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=devsecops-cicd-01 \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }

        // ✅ QUALITY GATE
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // 🐳 BUILD DOCKER IMAGE
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-app .'
            }
        }

        // 🔐 TRIVY SCAN
        stage('Trivy Scan') {
            steps {
                sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL my-app || true'
            }
        }

        // 🔑 LOGIN TO ECR
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

        // 📦 PUSH IMAGE
        stage('Push Image to ECR') {
            steps {
                sh '''
                docker tag my-app:latest $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:$IMAGE_TAG
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
    }

    post {
        success {
            echo "✅ Pipeline Success - Deployment Completed 🚀"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}