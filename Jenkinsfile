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
                echo "===== Building Docker Image: ${IMAGE_TAG} ====="
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
                echo "===== Verifying through Nginx (port 80) ====="
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
        }
        failure {
            echo "DEPLOY FAILED - Rolling back..."
            sh "docker stop cicd-running || true"
            sh "docker rm   cicd-running || true"
        }
    }
}
post {
        always {
            // Dọn dẹp không gian làm việc cho sạch máy sau khi build xong
            cleanWs()
        }
        success {
            script {
                // THAY THÔNG TIN CỦA BẠN VÀO 2 DÒNG DƯỚI ĐÂY
                def TOKEN = "784521963:AAH_xXyY_zzZ12345..." 
                def CHAT_ID = "123456789"
                
                // Nội dung tin nhắn khi thành công (Ký tự %0A là lệnh xuống dòng)
                def MESSAGE = "✅ *JENKINS: DEPLOY THÀNH CÔNG* 🚀%0A%0A• *Dự án:* ${env.JOB_NAME}%0A• *Build số:* #${env.BUILD_NUMBER}%0A• *Trạng thái:* Đã cập nhật phiên bản mới lên CentOS Stream 10 thành công với Zero-downtime!"
                
                // Chạy lệnh curl gửi dữ liệu đến API của Telegram
                sh "curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text='${MESSAGE}' -d parse_mode='Markdown'"
            }
        }
        failure {
            script {
                // THAY THÔNG TIN CỦA BẠN VÀO 2 DÒNG DƯỚI ĐÂY
                def TOKEN = "784521963:AAH_xXyY_zzZ12345..."
                def CHAT_ID = "123456789"
                
                // Nội dung tin nhắn khi thất bại
                def MESSAGE = "❌ *JENKINS: DEPLOY THẤT BẠI* ⚠️%0A%0A• *Dự án:* ${env.JOB_NAME}%0A• *Build số:* #${env.BUILD_NUMBER}%0A• *Trạng thái:* Quá trình build/deploy gặp lỗi, hệ thống giữ nguyên phiên bản cũ để an toàn. Vui lòng check log!"
                
                sh "curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text='${MESSAGE}' -d parse_mode='Markdown'"
            }
        }
    }
