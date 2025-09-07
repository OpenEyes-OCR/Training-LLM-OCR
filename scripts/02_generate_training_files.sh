#!/bin/bash

# --- 02_generate_training_files.sh ---
# Gera os arquivos de treinamento no formato .lstmf.

set -euo pipefail

MODEL_NAME="bressay"
TESS_DIR="tesstrain"
TESS_DATA_DIR="${TESS_DIR}/data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a geração dos arquivos de treinamento (.lstmf) ---${NC}"

if [ ! -f "${MODEL_DATA_DIR}/list.train" ]; then
    echo -e "${YELLOW}!!! ERRO !!!${NC}"
    echo "Arquivo de lista de treinamento '${MODEL_DATA_DIR}/list.train' não encontrado."
    echo "Por favor, execute o script '01_prepare_data.sh' primeiro."
    exit 1
fi

echo "Executando o Makefile para gerar os arquivos .lstmf..."
# --- CORREÇÃO: Entra no diretório 'tesstrain' antes de executar o make ---
cd "$TESS_DIR"

make TESSDATA="../${TESS_DATA_DIR}" MODEL_NAME=$MODEL_NAME training

# --- CORREÇÃO: Volta para o diretório raiz do projeto ---
cd ..

LSTMF_COUNT=$(find "${MODEL_DATA_DIR}-ground-truth" -name '*.lstmf' | wc -l)

echo -e "\n${GREEN}--- Geração de arquivos concluída! ---${NC}"
echo "${LSTMF_COUNT} arquivos .lstmf foram gerados em: ${MODEL_DATA_DIR}-ground-truth/"
echo "O projeto está pronto para a próxima fase: o treinamento."