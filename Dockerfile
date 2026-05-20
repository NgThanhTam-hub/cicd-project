# Base image
FROM python:3.12-slim

# Thư mục làm việc trong container
WORKDIR /app

# Copy requirements trước (tận dụng Docker cache)
COPY app/requirements.txt .

# Cài dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ source code
COPY app/ .

# Mở port 5000
EXPOSE 5000

# Lệnh chạy app
CMD ["python3", "app.py"]
