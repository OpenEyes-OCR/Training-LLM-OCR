#!/bin/bash

# --- PRE-01_prepare_bressay_dataset.sh ---
# (Versão Resiliente com Validação de Imagem)
# Extrai os dados do BRESSAY, validando cada imagem para pular arquivos corrompidos.

set -euo pipefail

# --- Configuração ---
BRESSAY_SOURCE_DIR="bressay/data/lines"
PIPELINE_INPUT_DIR="dataset/raw"
# Arquivo de log para registrar imagens que falharam na validação
BAD_FILES_LOG="dataset/bad_files.log"

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
# Limpa o log de arquivos ruins
rm -f "$BAD_FILES_LOG"
touch "$BAD_FILES_LOG"

echo "Validando, encontrando e copiando todos os pares de arquivos..."
COUNTER=1
SKIPPED_COUNTER=0

while IFS= read -r -d '' png_file; do
    txt_file="${png_file%.png}.txt"

    # --- CONTROLE DE QUALIDADE ---
    # Verifica se o arquivo de texto existe E se a imagem é válida.
    # O comando 'identify' retorna um erro se a imagem for corrompida.
    # Redirecionamos a saída e o erro para /dev/null para manter o log limpo.
    if [ -f "$txt_file" ] && identify "$png_file" > /dev/null 2>&1; then
        formatted_counter=$(printf "%06d" $COUNTER)
        
        cp "$png_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.png"
        cp "$txt_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.gt.txt"
        
        COUNTER=$((COUNTER + 1))
    else
        # Se a imagem for inválida ou o .txt não existir, registra no log.
        echo "Arquivo pulado (corrompido ou sem par .txt): ${png_file}" >> "$BAD_FILES_LOG"
        SKIPPED_COUNTER=$((SKIPPED_COUNTER + 1))
    fi
done < <(find "$BRESSAY_SOURCE_DIR" -name "*.png" -print0)

TOTAL_PAIRS=$((COUNTER - 1))
echo -e "\n${GREEN}--- Preparação do BRESSAY concluída! ---${NC}"
echo "Pares de imagem/texto VÁLIDOS extraídos: ${TOTAL_PAIRS}"
echo "Arquivos corrompidos ou sem par pulados: ${SKIPPED_COUNTER} (detalhes em ${BAD_FILES_LOG})"