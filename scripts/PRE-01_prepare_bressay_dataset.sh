#!/bin/bash

# --- PRE-01_prepare_bressay_dataset.sh ---
# (Versão Profissional com Estimativa de Tempo e Barra de Progresso)
# Extrai os dados do BRESSAY e fornece feedback sobre o progresso.

set -euo pipefail

# --- Configuração ---
BRESSAY_SOURCE_DIR="bressay/data/lines"
PIPELINE_INPUT_DIR="dataset/raw"
# Estimativa de arquivos processados por segundo. Ajuste conforme sua máquina.
# Um valor conservador para I/O de disco.
ARQUIVOS_POR_SEGUNDO=250

# Cores e Variáveis
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
ESTIMATE_ONLY=false

# --- Processamento de Flags ---
if [[ "$#" -gt 0 && "$1" == "--estimar-tempo" ]]; then
    ESTIMATE_ONLY=true
fi

# --- Funções ---
function estimar_tempo() {
    echo "Calculando o total de arquivos para a estimativa..."
    TOTAL_FILES=$(find "$BRESSAY_SOURCE_DIR" -name "*.png" | wc -l)
    
    if [ "$TOTAL_FILES" -eq 0 ]; then
        echo -e "${YELLOW}Nenhum arquivo .png encontrado em '${BRESSAY_SOURCE_DIR}'. Abortando.${NC}"
        exit 1
    fi

    ESTIMATED_SECONDS=$((TOTAL_FILES / ARQUIVOS_POR_SEGUNDO))
    ESTIMATED_MINUTES=$((ESTIMATED_SECONDS / 60))
    REMAINING_SECONDS=$((ESTIMATED_SECONDS % 60))

    echo "Total de arquivos .png encontrados: ${TOTAL_FILES}"
    echo -e "Tempo estimado para a preparação: ${YELLOW}${ESTIMATED_MINUTES} minuto(s) e ${REMAINING_SECONDS} segundo(s)${NC}."
    echo "Esta é uma estimativa aproximada e pode variar."
}

# --- Início da Execução ---
echo -e "${GREEN}--- Iniciando a preparação do dataset BRESSAY ---${NC}"

if [ ! -d "$BRESSAY_SOURCE_DIR" ]; then
    echo -e "${YELLOW}ERRO: Diretório fonte ('${BRESSAY_SOURCE_DIR}') não encontrado.${NC}"
    exit 1
fi

# Se a flag --estimar-tempo foi passada, mostra a estimativa e pergunta se continua.
if [ "$ESTIMATE_ONLY" = true ]; then
    estimar_tempo
    read -p "Deseja continuar com a preparação dos arquivos? (s/N) " response
    if [[ ! "$response" =~ ^[sS]$ ]]; then
        echo "Operação cancelada pelo usuário."
        exit 0
    fi
fi

echo "Limpando e recriando o diretório de entrada do pipeline: '${PIPELINE_INPUT_DIR}'..."
rm -rf "$PIPELINE_INPUT_DIR"
mkdir -p "$PIPELINE_INPUT_DIR"

echo "Encontrando e copiando todos os pares de arquivos..."

# Precisamos do total de arquivos para a barra de progresso
TOTAL_FILES=$(find "$BRESSAY_SOURCE_DIR" -name "*.png" | wc -l)
COUNTER=1

while IFS= read -r -d '' png_file; do
    txt_file="${png_file%.png}.txt"

    if [ -f "$txt_file" ]; then
        # Lógica da Barra de Progresso
        # Atualiza a cada 100 arquivos para não sobrecarregar o terminal
        if (( COUNTER % 100 == 0 )); then
            PERCENT=$(( (COUNTER * 100) / TOTAL_FILES ))
            # O comando 'echo -ne' imprime sem nova linha e '\r' retorna ao início da linha
            echo -ne "Progresso: ${PERCENT}% (${COUNTER}/${TOTAL_FILES})\r"
        fi

        formatted_counter=$(printf "%06d" $COUNTER)
        cp "$png_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.png"
        cp "$txt_file" "${PIPELINE_INPUT_DIR}/bressay_${formatted_counter}.gt.txt"
        
        COUNTER=$((COUNTER + 1))
    fi
done < <(find "$BRESSAY_SOURCE_DIR" -name "*.png" -print0)

# Garante que a linha de progresso seja limpa no final
echo -ne "\n"
TOTAL_PAIRS=$((COUNTER - 1))
echo -e "\n${GREEN}--- Preparação do BRESSAY concluída! ---${NC}"
echo "${TOTAL_PAIRS} pares de imagem/texto foram extraídos e preparados em '${PIPELINE_INPUT_DIR}'."