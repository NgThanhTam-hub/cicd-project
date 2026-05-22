#!/bin/bash

# ─────────────────────────────
# CẤU HÌNH — thay 2 dòng này
# ─────────────────────────────
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# ─────────────────────────────
# NHẬN THAM SỐ TỪ JENKINS
# ─────────────────────────────
STATUS="$1"       # success / failure
BUILD_NUM="$2"    # số build
JOB_NAME="$3"     # tên job

# ─────────────────────────────
# TẠO NỘI DUNG TIN NHẮN
# ─────────────────────────────
if [ "$STATUS" = "success" ]; then
    ICON="✅"
    TEXT="DEPLOY THÀNH CÔNG"
else
    ICON="❌"
    TEXT="DEPLOY THẤT BẠI"
fi

MESSAGE="${ICON} ${TEXT}
━━━━━━━━━━━━━━━━━━
📦 Job     : ${JOB_NAME}
🔢 Build   : #${BUILD_NUM}
🕐 Thời gian: $(date '+%Y-%m-%d %H:%M:%S')
━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────
# GỬI TIN NHẮN
# ─────────────────────────────
curl -s -X POST \
    "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${MESSAGE}" \
    > /dev/null

echo "Notification sent: ${STATUS}"
