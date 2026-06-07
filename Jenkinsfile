pipeline {
    agent any

    environment {
        AWS_REGION      = 'ap-south-1'
        AWS_ACCOUNT_ID  = '515241426563'
        ECR_REPO_NAME   = 'nodejs-secure-app'
        IMAGE_TAG       = "build-${env.BUILD_NUMBER}"
        ECR_REGISTRY    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_FULL_NAME = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo 'Cloning source code from GitHub...'
                git branch: 'main',
                    url: 'https://github.com/Eldho2827/jenkins-docker-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_FULL_NAME}"
                sh """
                    docker build \
                        --no-cache \
                        -t ${IMAGE_FULL_NAME} \
                        -t ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest \
                        .
                """
            }
        }

        stage('Login to AWS ECR') {
            steps {
                echo 'Authenticating Docker with AWS ECR...'
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                echo "Pushing ${IMAGE_FULL_NAME} to ECR..."
                sh "docker push ${IMAGE_FULL_NAME}"
                sh "docker push ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest"
                echo 'Image pushed successfully.'
            }
        }

    }

    post {
        success {
            echo "Pipeline SUCCESS — Image: ${IMAGE_FULL_NAME}"
        }
        failure {
            echo 'Pipeline FAILED. Check the logs above.'
        }
        always {
            echo 'Cleaning up local Docker images...'
            sh """
                docker rmi ${IMAGE_FULL_NAME} || true
                docker rmi ${ECR_REGISTRY}/${ECR_REPO_NAME}:latest || true
            """
        }
    }
}
