#!/bin/bash
echo "=============================="
echo "   CICD PROJECT DEMO"
echo "   Author: Nguyen Thanh Tam"
echo "=============================="

echo ""
echo "1. Services đang chạy:"
systemctl is-active jenkins && echo "   ✅ Jenkins"
systemctl is-active docker  && echo "   ✅ Docker"
systemctl is-active nginx   && echo "   ✅ Nginx"

echo ""
echo "2. Container đang chạy:"
docker ps --format "   ✅ {{.Names}} | {{.Status}} | Port: {{.Ports}}"

echo ""
echo "3. App response:"
curl -s http://localhost | python3 -m json.tool

echo ""
echo "4. Health check:"
curl -s http://localhost/health | python3 -m json.tool

echo ""
echo "5. Build history:"
ls -la /var/lib/jenkins/jobs/cicd-pipeline/builds/
