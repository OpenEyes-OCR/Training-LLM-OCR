#!/bin/bash

# --- 00_setup_env.sh ---
# (Versão para Docker
# Este script prepara o ambiente para o treinamento do modelo Tesseract.
# Ele instala as dependências necessárias e clona o repositório 'tesstrain'.

set -euo pipefail

TESS_REPO="https://github.com/tesseract-ocr/tesstrain.git"
TESS_DIR="tesstrain"
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a configuração do ambiente (Docker Mode) ---${NC}"

echo "Passo 1: Atualizando a lista de pacotes..."

apt-get update

echo "Passo 2: Instalando dependências essenciais..."

apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-por \
    libtesseract-dev \
    libleptonica-dev \
    git \
    make \
    g++ \
    pkg-config \
    bc \
    imagemagick

echo "Passo 3: Verificando e clonando o repositório de treinamento do Tesseract..."
if [ ! -d "$TESS_DIR" ]; then
    echo "Clonando o repositório '$TESS_REPO'..."
    git clone $TESS_REPO $TESS_DIR
else
    echo "O diretório '$TESS_DIR' já existe. Pulando a clonagem."
fi

echo -e "\n${GREEN}--- Configuração do ambiente concluída com sucesso! ---${NC}"