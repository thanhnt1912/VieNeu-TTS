#!/usr/bin/env bash
set -e

echo "=== [1/4] Cập nhật APT và cài đặt NVIDIA Driver (580) ==="
sudo apt-get update
sudo apt-get install -y nvidia-driver-580

echo "=== [2/4] Cấu hình repository NVIDIA Container Toolkit ==="
sudo apt-get install -y curl gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

echo "=== [3/4] Cài đặt NVIDIA Container Toolkit ==="
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "=== [4/4] Kiểm tra GPU trong Docker ==="
echo "Đang kiểm tra nvidia-smi trên host..."
nvidia-smi || echo "Lưu ý: Nếu nvidia-smi chưa nhận, có thể bạn cần khởi động lại máy (sudo reboot) để nạp kernel module."

echo "Đang kiểm tra Docker GPU pass-through..."
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi || echo "Nếu lệnh này báo lỗi, vui lòng reboot máy rồi thử lại."

echo "=== HOÀN TẤT SETUP GPU DRIVER VÀ CONTAINER TOOLKIT ==="
