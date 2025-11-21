#!/bin/bash
set -e  # 에러 발생 시 중단

echo "🚀 LIMO Smart Sentinel 설치를 시작합니다..."

# 1. 워크스페이스 준비
echo "📂 워크스페이스 생성 중 (wego_ws)..."
mkdir -p ~/wego_ws/src
cd ~/wego_ws

# 2. 패키지 다운로드
echo "📥 패키지 다운로드 중..."
vcs import src < ~/LIMO_Smart_Sentinel/limo.repos

# 3. [중요] 빈 폴더 강제 생성 (Git이 누락한 폴더 복구)
echo "🔧 LIMO 패키지 누락 폴더 복구 중..."
mkdir -p src/limo_ros2/limo_car/{worlds,models,maps,launch,urdf,params,log,src}
mkdir -p src/limo_ros2/limo_base/launch

# 4. 의존성 설치
echo "📦 필수 라이브러리 설치 중..."
sudo apt update
rosdep update
rosdep install --from-paths src --ignore-src -r -y

# 5. YDLidar-SDK 수동 설치 (없을 경우 대비)
if [ ! -d "/usr/local/include/ydlidar" ]; then
    echo "📡 YDLidar SDK가 없어 설치합니다..."
    cd ~
    git clone https://github.com/YDLIDAR/YDLidar-SDK.git
    cd YDLidar-SDK/build
    cmake ..
    make
    sudo make install
    cd ~/wego_ws
fi

# 6. 빌드
echo "🔨 전체 빌드 시작..."
colcon build --symlink-install

# 7. 환경 설정
echo "✅ 빌드 완료! 환경 변수를 설정합니다."
if ! grep -q "source ~/wego_ws/install/setup.bash" ~/.bashrc; then
    echo "source ~/wego_ws/install/setup.bash" >> ~/.bashrc
fi

echo "🎉 모든 설치가 완료되었습니다! 'source ~/.bashrc'를 입력하세요."
