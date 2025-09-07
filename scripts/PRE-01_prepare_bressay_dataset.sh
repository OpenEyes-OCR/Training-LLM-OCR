#!/bin/bash

# --- PRE-01_prepare_bressay_dataset.sh ---
# Script de uso único para extrair os dados do dataset BRESSAY de sua
# estrutura aninhada e prepará-los para o nosso pipeline.

set -euo pipefail

# --- Configuração ---
# Caminho para a pasta descompactada do BRESSAY
BRESSAY_SOURCE_DIR="bressay/data/words"
# Pasta de entrada do nosso pipeline
PIPELINE_INPUT_DIR="dataset/raw"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando a preparação do dataset BRESSAY ---${NC}"

# 1. Validação e Limpeza
if [ ! -d "$BRESSAY_SOURCE_DIR" ]; then
    echo -e "${YELLOW}ERRO: Diretório fonte do BRESSAY ('${BRESSAY_SOURCE_DIR}') não encontrado.${NC}"
    exit 1
fi

echo "Limpando e recriando o diretório de entrada do pipeline: '${PIPELINE_INPUT_DIR}'..."
rm -rf "$PIPELINE_INPUT_DIR"
mkdir -p "$PIPELINE_INPUT_DIR"

# 2. Extração e Renomeação
echo "Encontrando todos os pares de .png/.txt e copiando para '${PIPELINE_INPUT_DIR}'..."
COUNTER=1
# Encontra todos os arquivos .png, não importa o quão fundo estejam na estrutura de pastas.
find "$BRESSAY_SOURCE_DIR" -name "*.png" | while read png_file; do
    # Define o nome do arquivo de texto correspondente
    txt_file="${png_file%.png}.txt"

    # Verifica se o par de texto realmente existe
    if [ -f "$txt_file" ]; then
        # Cria um nome de arquivo novo e único para evitar colisões
        formatted_counter=$(printf "%06d" $COUNTER)
        
        # Copia o arquivo de imagem
        cp "$png_g_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.png"
        
        # Copia o arquivo de texto, já renomeando para a extensão .gt.txt que nosso pipeline espera
        cp "$txt_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.gt.txt"
        
        COUNTER=$((COUNTER + 1))
    fi
done

# Subtrai 1 do contador para ter o número real de pares
TOTAL_PAIRS=$((COUNTER - 1))
echo -e "\n${GREEN}--- Preparação do BRESSAY concluída! ---${NC}"
echo "${TOTAL_PAIRS} pares de imagem/texto foram extraídos e preparados em '${PIPELINE_INPUT_DIR}'."