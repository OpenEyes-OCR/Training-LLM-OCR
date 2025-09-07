#!/bin/bash

# --- PRE-01_prepare_bressay_dataset.sh ---
# (Versão Final com Loop Corrigido)
# Extrai os dados do BRESSAY usando um loop robusto que evita subshells.

set -euo pipefail

BRESSAY_SOURCE_DIR="bressay/data/lines"
PIPELINE_INPUT_DIR="dataset/raw"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a preparação do dataset BRESSAY ---${NC}"

if [ ! -d "$BRESSAY_SOURCE_DIR" ]; then
    echo -e "${YELLOW}ERRO: Diretório fonte ('${BRESSAY_SOURCE_DIR}') não encontrado.${NC}"
    exit 1
fi

echo "Limpando e recriando o diretório de entrada do pipeline: '${PIPELINE_INPUT_DIR}'..."
rm -rf "$PIPELINE_INPUT_DIR"
mkdir -p "$PIPELINE_INPUT_DIR"

echo "Encontrando todos os pares de .png/.txt e copiando para '${PIPELINE_INPUT_DIR}'..."
COUNTER=1
# --- A CORREÇÃO ---
# Este padrão de loop com '< <(find...)' evita o problema do subshell,
# garantindo que a variável COUNTER seja atualizada corretamente.
while IFS= read -r -d '' png_file; do
    txt_file="${png_file%.png}.txt"

    if [ -f "$txt_file" ]; then
        formatted_counter=$(printf "%06d" $COUNTER)
        
        cp "$png_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.png"
        cp "$txt_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.gt.txt"
        
        COUNTER=$((COUNTER + 1))
    fi
done < <(find "$BRESSAY_SOURCE_DIR" -name "*.png" -print0)

TOTAL_PAIRS=$((COUNTER - 1))
echo -e "\n${GREEN}--- Preparação do BRESSAY concluída! ---${NC}"
echo "${TOTAL_PAIRS} pares de imagem/texto foram extraídos e preparados em '${PIPELINE_INPUT_DIR}'."