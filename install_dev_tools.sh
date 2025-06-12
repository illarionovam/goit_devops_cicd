#!/bin/bash

set -e

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_docker() {
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
}

install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_python() {
    echo "Installing Python 3.9+..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
}

install_django() {
    echo "Installing Django..."
    pip3 install --user Django
}

if is_installed docker; then
    echo "Docker is already installed."
else
    install_docker
fi

if is_installed docker-compose; then
    echo "Docker Compose is already installed."
else
    install_docker_compose
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))' 2>/dev/null || echo "0")
if [[ $(echo -e "$PYTHON_VERSION\n3.9" | sort -V | head -n1) == "3.9" ]]; then
    echo "Python $PYTHON_VERSION is already installed."
else
    install_python
fi

if python3 -c "import django" &>/dev/null; then
    echo "Django is already installed."
else
    install_django
fi
