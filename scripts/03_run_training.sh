#!/bin/bash
set -euo pipefail

MODEL_NAME="${MODEL_NAME:?A variável MODEL_NAME não foi definida.}"
MAX_ITERATIONS="${MAX_ITERATIONS:?A variável MAX_ITERATIONS não foi definida.}"
START_MODEL="por"

TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
OUTPUT_DIR="output/${MODEL_NAME}"
LOG_FILE="${OUTPUT_DIR}/training.log"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando Treinamento (Modelo: '${MODEL_NAME}', Iterações: ${MAX_ITERATIONS}) ---${NC}"

mkdir -p "${OUTPUT_DIR}"
START_MODEL_PATH_ABS="${TESS_DIR}/${TESS_DATA_DIR}/${START_MODEL}.traineddata"

if [ ! -f "$START_MODEL_PATH_ABS" ]; then
    wget -O "$START_MODEL_PATH_ABS" "https://github.com/tesseract-ocr/tessdata_best/raw/main/${START_MODEL}.traineddata"
fi

EXTRACTED_LSTM_PATH="${MODEL_DATA_DIR}/${START_MODEL}.lstm"
if [ ! -f "${TESS_DIR}/${EXTRACTED_LSTM_PATH}" ]; then
    (cd "$TESS_DIR" && combine_tessdata -e "${TESS_DATA_DIR}/${START_MODEL}.traineddata" "$EXTRACTED_LSTM_PATH")
fi

TRAIN_LIST_FILE="${MODEL_DATA_DIR}/all-lstmf"
EVAL_LIST_FILE="${MODEL_DATA_DIR}/list.eval"

echo -e "\n${GREEN}Iniciando lstmtraining... As saídas serão salvas em '${LOG_FILE}'${NC}"
cd "$TESS_DIR"
LSTMTRAINING_CMD="lstmtraining \
    --model_output \"../${OUTPUT_DIR}/\" \
    --continue_from \"$EXTRACTED_LSTM_PATH\" \
    --traineddata \"${TESS_DATA_DIR}/${START_MODEL}.traineddata\" \
    --train_listfile \"$TRAIN_LIST_FILE\" \
    --max_iterations \"$MAX_ITERATIONS\""

if [ -s "$EVAL_LIST_FILE" ]; then
    LSTMTRAINING_CMD+=" --eval_listfile \"$EVAL_LIST_FILE\""
fi
eval $LSTMTRAINING_CMD 2>&1 | tee "../${LOG_FILE}"
cd ..

echo -e "\n${GREEN}--- Treinamento concluído! ---${NC}"