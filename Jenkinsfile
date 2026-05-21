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
