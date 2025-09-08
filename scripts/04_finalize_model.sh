#!/bin/bash

# --- 04_finalize_model.sh ---
# (Versão Corrigida)
# Pega o último checkpoint e o combina com o modelo BASE para criar
# o arquivo .traineddata final.

set -euo pipefail

MODEL_NAME="bressay"
# O nome do modelo que usamos como base no treinamento
START_MODEL="por"
TESS_DIR="tesstrain"
OUTPUT_DIR="output/${MODEL_NAME}"
FINAL_MODEL_DIR="output/final_models"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Finalizando o modelo '${MODEL_NAME}' ---${NC}"
mkdir -p "$FINAL_MODEL_DIR"

LAST_CHECKPOINT=$(ls -tr "${OUTPUT_DIR}"/*.checkpoint | tail -1)

if [ -z "$LAST_CHECKPOINT" ]; then
    echo -e "${YELLOW}!!! ERRO !!! Nenhum arquivo de checkpoint encontrado em '${OUTPUT_DIR}'.${NC}"
    echo "Execute o script de treinamento (03) primeiro."
    exit 1
fi

echo "Usando o checkpoint: ${LAST_CHECKPOINT}"

cd "$TESS_DIR"

# --- A CORREÇÃO ---
# A flag --traineddata agora aponta para o modelo base original (por.traineddata).
# Isso permite que o Tesseract mapeie corretamente os caracteres.
lstmtraining \
    --stop_training \
    --continue_from "../${LAST_CHECKPOINT}" \
    --traineddata "data/${START_MODEL}.traineddata" \
    --model_output "../${FINAL_MODEL_DIR}/${MODEL_NAME}.traineddata"

cd ..

echo -e "\n${GREEN}--- Modelo final criado com sucesso! ---${NC}"
echo "Seu modelo está pronto em: ${FINAL_MODEL_DIR}/${MODEL_NAME}.traineddata"