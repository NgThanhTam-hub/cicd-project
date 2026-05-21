#!/bin/bash

# Định nghĩa các biến cơ bản
CONTAINER_NAME="my-web-app"
IMAGE_NAME="my-docker-reg/app:latest" # Thay bằng tên image của bạn
PORT_MAPPING="5000:5000"

echo "=== BẮT ĐẦU QUÁ TRÌNH DEPLOY ZERO-DOWNTIME ==="

# 1. Pull Image mới nhất về máy
echo "-> Đang kéo Image mới nhất..."
docker pull $IMAGE_NAME

# 2. Khởi động Container mới trên một cổng tạm thời để test (ví dụ: 5001)
echo "-> Đang chạy Container mới thử nghiệm..."
docker run -d --name "${CONTAINER_NAME}_new" -p 5001:5000 $IMAGE_NAME

# 3. Kiểm tra xem Container mới đã thực sự hoạt động chưa (Healthcheck cơ bản)
echo "-> Đang kiểm tra trạng thái Container mới..."
sleep 5 # Chờ 5 giây để app khởi động
if curl -s http://127.0.0.1:5001 > /dev/null; then
    echo "✅ Container mới hoạt động hoàn hảo!"
else
    echo "❌ Lỗi: Container mới không phản hồi. Huỷ bỏ deploy!"
    docker stop "${CONTAINER_NAME}_new"
    docker rm "${CONTAINER_NAME}_new"
    exit 1
fi

# 4. Nếu container mới OK, tiến hành hoán đổi: Dừng container cũ
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "-> Đang dừng Container cũ..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# 5. Đổi tên container mới thành tên chính thức và chuyển về cổng chuẩn 5000
echo "-> Hoàn tất hoán đổi Container..."
docker stop "${CONTAINER_NAME}_new"
docker rm "${CONTAINER_NAME}_new"
docker run -d --name $CONTAINER_NAME -p $PORT_MAPPING --restart unless-stopped $IMAGE_NAME

# 6. Dọn dẹp các image cũ không dùng tới để tránh đầy ổ cứng
echo "-> Đang dọn dẹp hệ thống..."
docker image prune -f

echo "=== DEPLOY THÀNH CÔNG VỚI ZERO-DOWNTIME! ==="
