#!/bin/bash

# --- 03_run_training.sh ---
# (Versão de Controle Total)
# Executa o processo de treinamento usando as listas de .lstmf corretas.

set -euo pipefail

MODEL_NAME="bressay"
START_MODEL="por"
MAX_ITERATIONS=5000

TESS_DIR="tesstrain"
TESS_DATA_DIR="data" # Caminho relativo esperado pelo lstmtraining quando dentro de /tesstrain
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
OUTPUT_DIR="output/${MODEL_NAME}"
LOG_FILE="${OUTPUT_DIR}/training.log"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando o Pipeline de Treinamento para o modelo '${MODEL_NAME}' ---${NC}"

mkdir -p "${OUTPUT_DIR}"
START_MODEL_PATH_REL="${TESS_DATA_DIR}/${START_MODEL}.traineddata" # Caminho relativo
START_MODEL_PATH_ABS="${TESS_DIR}/${TESS_DATA_DIR}/${START_MODEL}.traineddata" # Caminho absoluto

if [ ! -f "$START_MODEL_PATH_ABS" ]; then
    echo "Baixando o modelo base '${START_MODEL}'..."
    wget -O "$START_MODEL_PATH_ABS" "https://github.com/tesseract-ocr/tessdata_best/raw/main/${START_MODEL}.traineddata"
fi

EXTRACTED_LSTM_PATH="${MODEL_DATA_DIR}/${START_MODEL}.lstm"
if [ ! -f "${TESS_DIR}/${EXTRACTED_LSTM_PATH}" ]; then
    echo "Extraindo a camada LSTM do modelo base..."
    (cd "$TESS_DIR" && combine_tessdata -e "$START_MODEL_PATH_REL" "$EXTRACTED_LSTM_PATH")
fi

echo -e "\n${GREEN}Iniciando o treinamento. Isso pode levar um tempo...${NC}"
echo "As saídas serão salvas em '${LOG_FILE}'"

# Entramos no diretório para que os caminhos relativos funcionem como o tesseract espera.
cd "$TESS_DIR"

# --- A CORREÇÃO CRÍTICA ---
# Chamamos lstmtraining diretamente, garantindo que --train_listfile aponte
# para a lista de .lstmf ('train'), e não para a lista de .png ('list.train').
lstmtraining \
    --model_output "../${OUTPUT_DIR}/" \
    --continue_from "$EXTRACTED_LSTM_PATH" \
    --traineddata "$START_MODEL_PATH_REL" \
    --train_listfile "${MODEL_DATA_DIR}/train" \
    --eval_listfile "${MODEL_DATA_DIR}/eval" \
    --max_iterations "$MAX_ITERATIONS" \
    2>&1 | tee "../${LOG_FILE}"
    
cd ..

echo -e "\n${GREEN}--- Treinamento concluído! ---${NC}"
echo "Os checkpoints do modelo foram salvos em: '${OUTPUT_DIR}'"