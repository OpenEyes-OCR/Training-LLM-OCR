#!/bin/bash

# Prepara o ambiente e só instala as dependências Python se necessário.

set -euo pipefail

TESS_REPO="https://github.com/tesseract-ocr/tesstrain.git"
TESS_DIR="tesstrain"
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a configuração do ambiente (Docker Mode) ---${NC}"

if [ ! -d "$TESS_DIR" ]; then
    echo "Clonando o repositório '$TESS_REPO'..."
    git clone $TESS_REPO $TESS_DIR
else
    echo "O diretório 'tesstrain' já existe. Pulando a clonagem."
fi

# --- Verificação Inteligente ---
# Verifica se um pacote chave (Pillow) já está instalado.
if pip3 list | grep -q "Pillow"; then
    echo "Dependências Python já estão instaladas no volume. Pulando."
else
    echo "Instalando dependências Python do tesstrain no volume pela primeira vez..."
    pip3 install -r ${TESS_DIR}/requirements.txt
fi

echo -e "\n${GREEN}--- Configuração do ambiente concluída com sucesso! ---${NC}"