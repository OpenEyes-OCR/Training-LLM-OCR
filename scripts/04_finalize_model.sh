#!/bin/bash
set -euo pipefail

MODEL_NAME="${MODEL_NAME:?A variável MODEL_NAME não foi definida.}"
START_MODEL="por"

TESS_DIR="tesstrain"
OUTPUT_DIR="output/${MODEL_NAME}"
FINAL_MODEL_DIR="output/final_models"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Finalizando o modelo '${MODEL_NAME}' ---${NC}"
mkdir -p "$FINAL_MODEL_DIR"
LAST_CHECKPOINT=$(ls -t "${OUTPUT_DIR}"/*_checkpoint 2>/dev/null | head -1 || true)

if [ -z "$LAST_CHECKPOINT" ]; then
    echo -e "${YELLOW}!!! ERRO !!! Nenhum checkpoint encontrado.${NC}"
    exit 1
fi

echo "Usando o checkpoint: ${LAST_CHECKPOINT}"
cd "$TESS_DIR"
lstmtraining \
    --stop_training \
    --continue_from "../${LAST_CHECKPOINT}" \
    --traineddata "data/${START_MODEL}.traineddata" \
    --model_output "../${FINAL_MODEL_DIR}/${MODEL_NAME}.traineddata"
cd ..

echo -e "\n${GREEN}--- Modelo final '${MODEL_NAME}.traineddata' criado com sucesso! ---${NC}"
