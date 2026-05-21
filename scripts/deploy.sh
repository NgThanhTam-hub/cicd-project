#!/bin/bash
set -e  # Dừng ngay nếu có lỗi

# ─────────────────────────────────────
# BIẾN CẤU HÌNH
# ─────────────────────────────────────
APP_NAME="cicd-app"
CONTAINER_NAME="cicd-running"
APP_PORT="5000"
BUILD_TAG="${1:-latest}"   # Nhận tham số từ Jenkins, mặc định là latest
HEALTH_URL="http://localhost:${APP_PORT}/health"
MAX_RETRY=5

# ─────────────────────────────────────
# HÀM TIỆN ÍCH
# ─────────────────────────────────────
log()     { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }
success() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1"; }
error()   { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1"; exit 1; }

# ─────────────────────────────────────
# BƯỚC 1: KIỂM TRA IMAGE TỒN TẠI
# ─────────────────────────────────────
log "Checking image: ${APP_NAME}:${BUILD_TAG}"
if ! docker image inspect "${APP_NAME}:${BUILD_TAG}" > /dev/null 2>&1; then
    error "Image ${APP_NAME}:${BUILD_TAG} not found!"
fi
success "Image found"

# ─────────────────────────────────────
# BƯỚC 2: DỪNG CONTAINER CŨ (GRACEFUL)
# ─────────────────────────────────────
log "Stopping old container..."
if docker ps -q --filter "name=${CONTAINER_NAME}" | grep -q .; then
    docker stop --time=10 "${CONTAINER_NAME}"
    docker rm "${CONTAINER_NAME}"
    log "Old container stopped"
else
    log "No running container found, skipping"
fi

# ─────────────────────────────────────
# BƯỚC 3: CHẠY CONTAINER MỚI
# ─────────────────────────────────────
log "Starting new container: ${APP_NAME}:${BUILD_TAG}"
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${APP_PORT}:${APP_PORT}" \
    --restart unless-stopped \
    "${APP_NAME}:${BUILD_TAG}"
success "Container started"

# ─────────────────────────────────────
# BƯỚC 4: HEALTH CHECK (RETRY)
# ─────────────────────────────────────
log "Waiting for app to be healthy..."
for i in $(seq 1 $MAX_RETRY); do
    sleep 3
    if curl -sf "${HEALTH_URL}" > /dev/null; then
        success "Health check passed (attempt ${i}/${MAX_RETRY})"
        break
    fi
    log "Attempt ${i}/${MAX_RETRY} failed, retrying..."
    if [ "$i" -eq "$MAX_RETRY" ]; then
        error "Health check failed after ${MAX_RETRY} attempts!"
    fi
done

# ─────────────────────────────────────
# BƯỚC 5: DỌN IMAGE CŨ
# ─────────────────────────────────────
log "Cleaning up old images..."
docker image prune -f --filter "label=app=${APP_NAME}" 2>/dev/null || true
success "Cleanup done"

success "Deploy completed: ${APP_NAME}:${BUILD_TAG} is live!"
