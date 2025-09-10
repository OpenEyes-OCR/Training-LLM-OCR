#!/bin/bash
set -euo pipefail

# Executa o treinamento, retomando automaticamente de um checkpoint se encontrado.

# --- Variáveis de Ambiente (definidas pelos scripts mestres) ---
MODEL_NAME="${MODEL_NAME:?A variável MODEL_NAME não foi definida.}"
MAX_ITERATIONS="${MAX_ITERATIONS:?A variável MAX_ITERATIONS não foi definida.}"
START_MODEL="por"

# --- Configuração de Caminhos ---
TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
OUTPUT_DIR="output/${MODEL_NAME}"
LOG_FILE="${OUTPUT_DIR}/training.log"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando Treinamento (Modelo: '${MODEL_NAME}', Iterações: ${MAX_ITERATIONS}) ---${NC}"
mkdir -p "${OUTPUT_DIR}"

# --- LÓGICA DE RETOMADA DE CHECKPOINT ---
# Define o caminho para o último checkpoint salvo
CHECKPOINT_TO_RESUME_FROM="${OUTPUT_DIR}/_checkpoint"
# Define o caminho para o ponto de partida inicial (modelo base)
BASE_MODEL_LSTM="${TESS_DIR}/${MODEL_DATA_DIR}/${START_MODEL}.lstm"

CONTINUE_FROM_ARG=""

if [ -f "$CHECKPOINT_TO_RESUME_FROM" ]; then
    echo -e "${YELLOW}Checkpoint encontrado! O treinamento será retomado de '${CHECKPOINT_TO_RESUME_FROM}'.${NC}"
    # O caminho deve ser relativo ao diretório 'tesstrain/' onde o comando roda
    CONTINUE_FROM_ARG="../${CHECKPOINT_TO_RESUME_FROM}"
else
    echo "Nenhum checkpoint encontrado. Iniciando um novo treinamento a partir do modelo base."
    START_MODEL_PATH_ABS="${TESS_DIR}/${TESS_DATA_DIR}/${START_MODEL}.traineddata"
    
    # Baixa o modelo base se necessário
    if [ ! -f "$START_MODEL_PATH_ABS" ]; then
        wget -O "$START_MODEL_PATH_ABS" "https://github.com/tesseract-ocr/tessdata_best/raw/main/${START_MODEL}.traineddata"
    fi
    
    # Extrai a camada LSTM do modelo base se ela ainda não foi extraída
    if [ ! -f "$BASE_MODEL_LSTM" ]; then
        (cd "$TESS_DIR" && combine_tessdata -e "${TESS_DATA_DIR}/${START_MODEL}.traineddata" "${MODEL_DATA_DIR}/${START_MODEL}.lstm")
    fi
    CONTINUE_FROM_ARG="${MODEL_DATA_DIR}/${START_MODEL}.lstm"
fi
# --- FIM DA LÓGICA DE RETOMADA ---


echo -e "\n${GREEN}Iniciando lstmtraining... As saídas serão salvas em '${LOG_FILE}'${NC}"

cd "$TESS_DIR"

# Constrói o comando dinamicamente
LSTMTRAINING_CMD="lstmtraining \
    --model_output \"../${OUTPUT_DIR}/\" \
    --continue_from \"$CONTINUE_FROM_ARG\" \
    --traineddata \"${TESS_DATA_DIR}/${START_MODEL}.traineddata\" \
    --train_listfile \"${MODEL_DATA_DIR}/all-lstmf\" \
    --max_iterations \"$MAX_ITERATIONS\""

EVAL_LIST_FILE="${MODEL_DATA_DIR}/list.eval"
if [ -s "$EVAL_LIST_FILE" ]; then
    LSTMTRAINING_CMD+=" --eval_listfile \"$EVAL_LIST_FILE\""
fi

# Executa o comando e anexa a saída ao log existente (usando 'tee -a')
eval $LSTMTRAINING_CMD 2>&1 | tee -a "../${LOG_FILE}"

cd ..

echo -e "\n${GREEN}--- Treinamento concluído! ---${NC}"