#!/bin/bash

# --- 04_finalize_model.sh ---
# Pega o último checkpoint do treinamento e o combina para criar o arquivo
# .traineddata final e utilizável.

set -euo pipefail

MODEL_NAME="bressay"
TESS_DIR="tesstrain"
OUTPUT_DIR="output/${MODEL_NAME}"
FINAL_MODEL_DIR="output/final_models"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Finalizando o modelo '${MODEL_NAME}' ---${NC}"
mkdir -p "$FINAL_MODEL_DIR"

# Encontra o último (melhor) checkpoint salvo pelo treinamento.
LAST_CHECKPOINT=$(ls -tr "${OUTPUT_DIR}"/*.checkpoint | tail -1)

if [ -z "$LAST_CHECKPOINT" ]; then
    echo -e "${YELLOW}!!! ERRO !!! Nenhum arquivo de checkpoint encontrado em '${OUTPUT_DIR}'.${NC}"
    echo "Execute o script de treinamento (03) primeiro."
    exit 1
fi

echo "Usando o checkpoint: ${LAST_CHECKPOINT}"

cd "$TESS_DIR"

# O comando lstmtraining com a flag --stop_training faz a combinação final.
lstmtraining \
    --stop_training \
    --continue_from "../${LAST_CHECKPOINT}" \
    --traineddata "data/${MODEL_NAME}/${MODEL_NAME}.traineddata" \
    --model_output "../${FINAL_MODEL_DIR}/${MODEL_NAME}.traineddata"

cd ..

echo -e "\n${GREEN}--- Modelo final criado com sucesso! ---${NC}"
echo "Seu modelo está pronto em: ${FINAL_MODEL_DIR}/${MODEL_NAME}.traineddata"