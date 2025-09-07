#!/bin/bash

# --- 01_prepare_data.sh ---
# (Robust Version - No 'cd')
# Prepares ground truth data without changing directories.

set -euo pipefail

MODEL_NAME="bressay"
RAW_DATA_DIR="dataset/raw"
TESS_DATA_DIR="tesstrain/data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
GROUND_TRUTH_DIR="${MODEL_DATA_DIR}-ground-truth"
TRAIN_RATIO=0.95

TRAIN_LIST_FILE="${MODEL_DATA_DIR}/list.train"
EVAL_LIST_FILE="${MODEL_DATA_DIR}/list.eval"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a preparação dos dados para o modelo '${MODEL_NAME}' ---${NC}"

if [ ! -d "$RAW_DATA_DIR" ] || [ -z "$(ls -A "$RAW_DATA_DIR")" ]; then
    echo -e "${YELLOW}!!! AVISO !!!${NC}"
    echo "O diretório '${RAW_DATA_DIR}' não existe ou está vazio."
    exit 1
fi

echo "Criando diretórios necessários..."
mkdir -p "$GROUND_TRUTH_DIR"
mkdir -p "$MODEL_DATA_DIR"

echo "Copiando arquivos de '${RAW_DATA_DIR}' para '${GROUND_TRUTH_DIR}'..."
cp "$RAW_DATA_DIR"/*.png "$GROUND_TRUTH_DIR"/
cp "$RAW_DATA_DIR"/*.gt.txt "$GROUND_TRUTH_DIR"/
echo "$(ls -1 "$GROUND_TRUTH_DIR"/*.png | wc -l) arquivos de imagem copiados."

echo "Gerando listas de arquivos de treino e avaliação..."

# Find files in the target directory and get their absolute paths, without using 'cd'.
find "$GROUND_TRUTH_DIR" -name "*.png" -exec realpath {} \; | shuf > all-files.txt

TOTAL_FILES=$(wc -l < all-files.txt)
TRAIN_COUNT=$(awk -v total=$TOTAL_FILES -v ratio=$TRAIN_RATIO 'BEGIN { printf "%.0f", total * ratio }')
EVAL_COUNT=$((TOTAL_FILES - TRAIN_COUNT))

# Write to the list files. This now works because we are still in the project root.
head -n "$TRAIN_COUNT" all-files.txt > "${TRAIN_LIST_FILE}"
tail -n "$EVAL_COUNT" all-files.txt > "${EVAL_LIST_FILE}"

# Clean up the temporary file
rm all-files.txt

echo -e "\n${GREEN}--- Preparação dos dados concluída! ---${NC}"
echo "Total de arquivos: ${TOTAL_FILES}"
echo "Arquivos de Treino: ${TRAIN_COUNT} (lista em ${TRAIN_LIST_FILE})"
echo "Arquivos de Avaliação: ${EVAL_COUNT} (lista em ${EVAL_LIST_FILE})"