#!/bin/bash

# --- 02_generate_training_files.sh ---
# Gera os arquivos de treinamento no formato .lstmf.

set -euo pipefail

MODEL_NAME="bressay"
TESS_DIR="tesstrain"
TESS_DATA_DIR="data" # O Makefile espera que este seja o caminho relativo 'data'
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a geração dos arquivos de treinamento (.lstmf) ---${NC}"

if [ ! -f "${TESS_DIR}/${MODEL_DATA_DIR}/list.train" ]; then
    echo -e "${YELLOW}!!! ERRO !!!${NC}"
    echo "Arquivo de lista de treinamento '${TESS_DIR}/${MODEL_DATA_DIR}/list.train' não encontrado."
    echo "Por favor, execute o script '01_prepare_data.sh' primeiro."
    exit 1
fi

echo "Executando o Makefile para gerar os arquivos .lstmf..."
cd "$TESS_DIR"

# --- A CORREÇÃO DEFINITIVA ---
# Forçamos o Makefile a usar as listas de arquivos .lstmf (chamadas 'train' e 'eval')
# que são geradas no meio do processo, em vez das listas de .png originais.
make TESSDATA=$TESS_DATA_DIR \
     MODEL_NAME=$MODEL_NAME \
     TRAINING_LIST=$MODEL_DATA_DIR/train \
     EVAL_LIST=$MODEL_DATA_DIR/eval \
     training

cd ..

LSTMF_COUNT=$(find "${TESS_DIR}/${MODEL_DATA_DIR}-ground-truth" -name '*.lstmf' | wc -l)

echo -e "\n${GREEN}--- Geração de arquivos concluída! ---${NC}"
echo "${LSTMF_COUNT} arquivos .lstmf foram gerados."
echo "O projeto está pronto para a fase de treinamento."