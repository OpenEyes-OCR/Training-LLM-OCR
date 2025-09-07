#!/bin/bash

# --- 02_generate_training_files.sh ---
# (Versão Final de Controle Total)
# Gera os arquivos .lstmf de forma explícita e cria as listas de treinamento.

set -euo pipefail

MODEL_NAME="bressay"
TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
GROUND_TRUTH_DIR="${MODEL_DATA_DIR}-ground-truth"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Gerando arquivos .lstmf e listas de treinamento ---${NC}"

LIST_TRAIN_FILE="${TESS_DIR}/${MODEL_DATA_DIR}/list.train"
if [ ! -f "$LIST_TRAIN_FILE" ]; then
    echo -e "${YELLOW}!!! ERRO !!! '${LIST_TRAIN_FILE}' não encontrado.${NC}"
    exit 1
fi

cd "$TESS_DIR"

# PASSO 1: Construir a lista de alvos .lstmf que queremos que o make crie.
# Lemos o arquivo list.train, pegamos o nome base de cada arquivo .png,
# e adicionamos o caminho e a extensão .lstmf.
LSTMF_TARGETS=$(sed "s|^.*/||; s/\.png$/.lstmf/" "${MODEL_DATA_DIR}/list.train" | awk -v dir="${GROUND_TRUTH_DIR}/" '{print dir $0}')

echo "Alvos .lstmf a serem construídos:"
echo "$LSTMF_TARGETS"

# PASSO 2: Chamar o 'make' para construir explicitamente esses arquivos.
# Esta é a forma mais robusta de usar o Makefile.
make TESSDATA=$TESS_DATA_DIR MODEL_NAME=$MODEL_NAME $LSTMF_TARGETS

# PASSO 3: Criar as listas finais de treinamento ('train' e 'eval').
echo "Gerando as listas de treinamento finais ('train' e 'eval')..."
python3 shuffle.py 0 "data/${MODEL_NAME}/all-lstmf"
python3 generate_eval_train.py "data/${MODEL_NAME}/all-lstmf" 0.95

cd ..

echo -e "\n${GREEN}--- Geração de arquivos .lstmf e listas concluída! ---${NC}"