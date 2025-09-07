#!/bin/bash

# --- PRE-01_prepare_bressay_dataset.sh ---
# Script de uso único para extrair os dados do dataset BRESSAY de sua
# estrutura aninhada e prepará-los para o nosso pipeline.

set -euo pipefail

# --- Configuração ---
BRESSAY_SOURCE_DIR="bressay/data/words"
PIPELINE_INPUT_DIR="dataset/raw"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a preparação do dataset BRESSAY ---${NC}"

if [ ! -d "$BRESSAY_SOURCE_DIR" ]; then
    echo -e "${YELLOW}ERRO: Diretório fonte do BRESSAY ('${BRESSAY_SOURCE_DIR}') não encontrado.${NC}"
    exit 1
fi

echo "Limpando e recriando o diretório de entrada do pipeline: '${PIPELINE_INPUT_DIR}'..."
rm -rf "$PIPELINE_INPUT_DIR"
mkdir -p "$PIPELINE_INPUT_DIR"

echo "Encontrando todos os pares de .png/.txt e copiando para '${PIPELINE_INPUT_DIR}'..."
COUNTER=1
find "$BRESSAY_SOURCE_DIR" -name "*.png" | while read png_file; do
    txt_file="${png_file%.png}.txt"

    if [ -f "$txt_file" ]; then
        formatted_counter=$(printf "%06d" $COUNTER)
        
        # --- AQUI ESTAVA O ERRO ---
        # Corrigido de "$png_g_file" para "$png_file"
        cp "$png_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.png"
        
        cp "$txt_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.gt.txt"
        
        COUNTER=$((COUNTER + 1))
    fi
done

TOTAL_PAIRS=$((COUNTER - 1))
echo -e "\n${GREEN}--- Preparação do BRESSAY concluída! ---${NC}"
echo "${TOTAL_PAIRS} pares de imagem/texto foram extraídos e preparados em '${PIPELINE_INPUT_DIR}'."