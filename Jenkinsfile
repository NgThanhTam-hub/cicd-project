pipeline {
    agent any

    environment {
        APP_NAME  = "cicd-app"
        IMAGE_TAG = "build-${BUILD_NUMBER}"
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
                    python3 -m pytest app/test_app.py -v --tb=short
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "===== Building Docker Image ====="
                sh """
                    docker build -t ${APP_NAME}:${IMAGE_TAG} .
                    docker tag  ${APP_NAME}:${IMAGE_TAG} ${APP_NAME}:latest
                """
            }
        }

        stage('Deploy') {
            steps {
                echo "===== Deploying via Script ====="
                sh "bash scripts/deploy.sh ${IMAGE_TAG}"
            }
        }

        stage('Verify via Nginx') {
            steps {
                echo "===== Verifying through Nginx ====="
                sh '''
                    sleep 2
                    curl -sf http://localhost/health || exit 1
                    echo "App is live via Nginx!"
                '''
            }
        }
    }

    post {
        success {
            echo "DEPLOY SUCCESS - Build #${BUILD_NUMBER} is live!"
            sh "bash scripts/notify.sh success ${BUILD_NUMBER} ${JOB_NAME}"
        }
        failure {
            echo "DEPLOY FAILED - Rolling back..."
            sh "docker stop cicd-running || true"
            sh "docker rm   cicd-running || true"
            sh "bash scripts/notify.sh failure ${BUILD_NUMBER} ${JOB_NAME}"
        }
    }
}
