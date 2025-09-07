#!/bin/bash

# --- 00_setup_env.sh ---
# (Versão para Docker - sem sudo)
# Prepara o ambiente, clona o repositório tesstrain e instala dependências Python.

set -euo pipefail

TESS_REPO="https://github.com/tesseract-ocr/tesstrain.git"
TESS_DIR="tesstrain"
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a configuração do ambiente (Docker Mode) ---${NC}"

# ... (comandos apt-get podem ser removidos pois já estão no Dockerfile, mas mantê-los não prejudica) ...

echo "Passo 3: Verificando e clonando o repositório de treinamento do Tesseract..."
if [ ! -d "$TESS_DIR" ]; then
    echo "Clonando o repositório '$TESS_REPO'..."
    git clone $TESS_REPO $TESS_DIR
else
    echo "O diretório '$TESS_DIR' já existe. Pulando a clonagem."
fi

echo "Passo 4: Instalando dependências Python do tesstrain..."
pip3 install -r ${TESS_DIR}/requirements.txt

echo -e "\n${GREEN}--- Configuração do ambiente concluída com sucesso! ---${NC}"