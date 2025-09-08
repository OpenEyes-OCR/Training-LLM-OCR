#!/bin/bash
set -euo pipefail

MODEL_NAME="${MODEL_NAME:?A variável MODEL_NAME não foi definida. Execute por um script mestre.}"

TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
GROUND_TRUTH_DIR="${MODEL_DATA_DIR}-ground-truth"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Gerando arquivos .lstmf e listas de treinamento para '${MODEL_NAME}'---${NC}"

LIST_TRAIN_FILE="${TESS_DIR}/${MODEL_DATA_DIR}/list.train"
if [ ! -f "$LIST_TRAIN_FILE" ]; then
    echo -e "${YELLOW}!!! ERRO !!! '${LIST_TRAIN_FILE}' não encontrado.${NC}"
    exit 1
fi

cd "$TESS_DIR"

LSTMF_TARGETS=$(sed "s|^.*/||; s/\.png$/.lstmf/" "${MODEL_DATA_DIR}/list.train" | awk -v dir="${GROUND_TRUTH_DIR}/" '{print dir $0}')
echo "Alvos .lstmf a serem construídos:"
echo "$LSTMF_TARGETS"

make TESSDATA=$TESS_DATA_DIR MODEL_NAME=$MODEL_NAME $LSTMF_TARGETS

# --- A CORREÇÃO CRÍTICA ---
# O comando 'make' acima cria os arquivos .lstmf, mas não a lista mestra.
# Nós criamos a lista 'all-lstmf' manualmente aqui.
echo "Criando a lista mestra de arquivos .lstmf ('all-lstmf')..."
# O comando 'tr' garante que cada nome de arquivo fique em sua própria linha.
echo "$LSTMF_TARGETS" | tr ' ' '\n' > "data/${MODEL_NAME}/all-lstmf"

echo "Gerando as listas de treinamento finais ('train' e 'eval')..."
# Agora este script encontrará seu arquivo de entrada
python3 shuffle.py 0 "data/${MODEL_NAME}/all-lstmf"
python3 generate_eval_train.py "data/${MODEL_NAME}/all-lstmf" 0.95

cd ..

echo -e "\n${GREEN}--- Geração de arquivos .lstmf e listas concluída! ---${NC}"