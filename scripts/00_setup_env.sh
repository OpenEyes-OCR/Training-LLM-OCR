#!/bin/bash

# --- 00_setup_env.sh ---
# Este script prepara o ambiente para o treinamento do modelo Tesseract.
# Ele instala as dependências necessárias (Tesseract, ferramentas de dev, git)
# e clona o repositório 'tesstrain' oficial.
#
# COMO USAR:
# 1. Dê permissão de execução: chmod +x scripts/00_setup_env.sh
# 2. Execute a partir da raiz do projeto: ./scripts/00_setup_env.sh

# --- Configuração de Segurança ---
# 'set -e' termina o script imediatamente se um comando falhar.
# 'set -u' trata o uso de variáveis não definidas como um erro.
# 'set -o pipefail' garante que um pipeline de comandos retorne o status do último comando que falhou.
set -euo pipefail

# --- Variáveis ---
# Repositório oficial do Tesseract para treinamento
TESS_REPO="https://github.com/tesseract-ocr/tesstrain.git"
TESS_DIR="tesstrain"

# Cores para o terminal
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --- Início da Execução ---
echo -e "${GREEN}--- Iniciando a configuração do ambiente ---${NC}"

echo "Passo 1: Atualizando a lista de pacotes..."
sudo apt-get update

echo "Passo 2: Instalando dependências essenciais (Tesseract, Git, Ferramentas de Build)..."
sudo apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-por \
    libtesseract-dev \
    libleptonica-dev \
    git \
    make \
    g++ \
    pkg-config

echo "Passo 3: Verificando e clonando o repositório de treinamento do Tesseract..."
if [ ! -d "$TESS_DIR" ]; then
    echo "Clonando o repositório '$TESS_REPO'..."
    git clone $TESS_REPO $TESS_DIR
else
    echo "O diretório '$TESS_DIR' já existe. Pulando a clonagem."
fi

echo -e "\n${GREEN}--- Configuração do ambiente concluída com sucesso! ---${NC}"
echo "O repositório de treinamento está em: $(pwd)/$TESS_DIR"
echo "Próximo passo: Preparar os dados do dataset."