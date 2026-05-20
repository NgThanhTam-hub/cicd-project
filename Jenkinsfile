pipeline {
    agent any

    environment {
        APP_NAME    = "cicd-app"
        IMAGE_TAG   = "build-${BUILD_NUMBER}"
        CONTAINER   = "cicd-running"
        APP_PORT    = "5000"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "===== Pulling code from GitHub ====="
                checkout scm
            }
        }

        stage('Run Tests') {
            steps {
                echo "===== Running Unit Tests ====="
                sh '''
                    pip3 install -r app/requirements.txt --quiet
                    python3 -m pytest app/test_app.py -v
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "===== Building Docker Image ====="
                sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${APP_NAME}:${IMAGE_TAG} ${APP_NAME}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                echo "===== Deploying Container ====="
                sh '''
                    # Dừng container cũ nếu đang chạy
                    docker stop cicd-running || true
                    docker rm cicd-running   || true

                    # Chạy container mới
                    docker run -d \
                        --name cicd-running \
                        -p 5000:5000 \
                        --restart unless-stopped \
                        cicd-app:latest
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo "===== Checking App Health ====="
                sh '''
                    sleep 3
                    curl -f http://localhost:5000/health || exit 1
                    echo "App is healthy!"
                '''
            }
        }
    }

    post {
        success {
            echo "PIPELINE SUCCESS - Build #${BUILD_NUMBER} deployed!"
        }
        failure {
            echo "PIPELINE FAILED - Check logs above!"
            sh "docker stop cicd-running || true"
        }
    }
}
