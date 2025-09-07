#!/bin/bash

# --- 00a_create_test_files.sh ---
# Gera um par de arquivos (.tif e .gt.txt) para testar o pipeline.

set -euo pipefail

RAW_DATA_DIR="dataset/raw"
TEST_TEXT="um texto simples para teste de OCR"
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}--- Gerando arquivos de teste ---${NC}"

echo "Criando diretório '${RAW_DATA_DIR}' se não existir..."
mkdir -p $RAW_DATA_DIR

echo "Gerando imagem de teste: '${RAW_DATA_DIR}/teste.tif'"
convert -background white -fill black \
        -font "Courier" -pointsize 24 \
        label:"${TEST_TEXT}" \
        -trim +repage \
        "${RAW_DATA_DIR}/teste.tif"

echo "Gerando texto de ground truth: '${RAW_DATA_DIR}/teste.gt.txt'"
echo "${TEST_TEXT}" > "${RAW_DATA_DIR}/teste.gt.txt"

echo -e "\n${GREEN}Arquivos de teste gerados com sucesso!${NC}"