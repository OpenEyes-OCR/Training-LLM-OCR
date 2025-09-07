#!/bin/bash

# --- 03_run_training.sh ---
# (Versão Final e Inteligente)
# Executa o treinamento e lida dinamicamente com a ausência de dados de avaliação.

set -euo pipefail

MODEL_NAME="bressay"
START_MODEL="por"
MAX_ITERATIONS=20000 # Reduzido para um teste rápido

TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
OUTPUT_DIR="output/${MODEL_NAME}"
LOG_FILE="${OUTPUT_DIR}/training.log"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando o Pipeline de Treinamento para o modelo '${MODEL_NAME}' ---${NC}"

mkdir -p "${OUTPUT_DIR}"
START_MODEL_PATH_ABS="${TESS_DIR}/${TESS_DATA_DIR}/${START_MODEL}.traineddata"

if [ ! -f "$START_MODEL_PATH_ABS" ]; then
    echo "Baixando o modelo base '${START_MODEL}'..."
    wget -O "$START_MODEL_PATH_ABS" "https://github.com/tesseract-ocr/tessdata_best/raw/main/${START_MODEL}.traineddata"
fi

EXTRACTED_LSTM_PATH="${MODEL_DATA_DIR}/${START_MODEL}.lstm"
if [ ! -f "${TESS_DIR}/${EXTRACTED_LSTM_PATH}" ]; then
    echo "Extraindo a camada LSTM do modelo base..."
    (cd "$TESS_DIR" && combine_tessdata -e "${TESS_DATA_DIR}/${START_MODEL}.traineddata" "$EXTRACTED_LSTM_PATH")
fi

TRAIN_LIST_FILE="${MODEL_DATA_DIR}/all-lstmf"
EVAL_LIST_FILE="${MODEL_DATA_DIR}/list.eval" # Aponta para o arquivo que pode ou não ter conteúdo

echo -e "\n${GREEN}Iniciando o treinamento. Isso pode levar um tempo...${NC}"
echo "As saídas serão salvas em '${LOG_FILE}'"

cd "$TESS_DIR"

# --- A CORREÇÃO FINAL ---
# Constrói o comando dinamicamente.
# O comando base sempre existirá.
LSTMTRAINING_CMD="lstmtraining \
    --model_output \"../${OUTPUT_DIR}/\" \
    --continue_from \"$EXTRACTED_LSTM_PATH\" \
    --traineddata \"${TESS_DATA_DIR}/${START_MODEL}.traineddata\" \
    --train_listfile \"$TRAIN_LIST_FILE\" \
    --max_iterations \"$MAX_ITERATIONS\""

# Adiciona o argumento de avaliação APENAS se o arquivo de lista de avaliação existir E não estiver vazio.
# O '-s' no comando 'if' testa se o arquivo não está vazio.
if [ -s "$EVAL_LIST_FILE" ]; then
    echo "Arquivo de avaliação encontrado. Incluindo no treinamento."
    LSTMTRAINING_CMD+=" --eval_listfile \"$EVAL_LIST_FILE\""
else
    echo "Arquivo de avaliação está vazio ou não existe. Treinando sem avaliação."
fi

# Executa o comando final e envia a saída para a tela e para o log.
eval $LSTMTRAINING_CMD 2>&1 | tee "../${LOG_FILE}"

cd ..

echo -e "\n${GREEN}--- Treinamento concluído! ---${NC}"
echo "Os checkpoints do modelo foram salvos em: '${OUTPUT_DIR}'"