#!/bin/bash

# --- monitor.sh ---
# Script de monitoramento para o pipeline de treinamento do Tesseract.
# Exibe o progresso do pipeline e o uso de recursos do sistema.

# --- Configuração ---
PREPARATION_TARGET_DIR="tesstrain/data/bressay-ground-truth"
RAW_DATA_DIR="dataset/raw"
TRAINING_LOG_FILE="output/bressay/training.log"
# O script irá atualizar a cada X segundos
SLEEP_INTERVAL=5

# --- Funções de Exibição ---

function display_preparation_stats() {
    echo "--- FASE: Preparação de Dados (gerando .lstmf) ---"
    
    # Conta os arquivos .png de origem e os .lstmf já criados
    TOTAL_PNGS=$(ls -1 "$RAW_DATA_DIR"/*.png 2>/dev/null | wc -l)
    CURRENT_LSTMF=$(find "$PREPARATION_TARGET_DIR" -name "*.lstmf" 2>/dev/null | wc -l)

    if [ "$TOTAL_PNGS" -gt 0 ]; then
        PERCENT=$(( (CURRENT_LSTMF * 100) / TOTAL_PNGS ))
        
        # Barra de Progresso Simples
        BAR_LENGTH=50
        COMPLETED_LENGTH=$(( (PERCENT * BAR_LENGTH) / 100 ))
        REMAINING_LENGTH=$((BAR_LENGTH - COMPLETED_LENGTH))
        BAR=$(printf "%${COMPLETED_LENGTH}s" "" | tr ' ' '#')
        REMAINING=$(printf "%${REMAINING_LENGTH}s" "")
        
        echo -ne "Progresso: [${BAR}${REMAINING}] ${PERCENT}%"
        echo " (${CURRENT_LSTMF} de ${TOTAL_PNGS} arquivos .lstmf criados)"
    else
        echo "Aguardando início da preparação (0 arquivos .png em '${RAW_DATA_DIR}')..."
    fi
}

function display_training_stats() {
    echo "--- FASE: Treinamento (lstmtraining) ---"
    echo "Últimas 5 linhas do log de treinamento:"
    echo "-----------------------------------------------------"
    # Exibe as últimas linhas do log, que contêm o progresso da iteração e erro
    tail -n 5 "$TRAINING_LOG_FILE"
    echo "-----------------------------------------------------"
}

function display_system_stats() {
    echo -e "\n--- Status dos Recursos do Sistema ---"
    
    # Uso de CPU (calculado a partir do 'top')
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "Uso de CPU: ${CPU_USAGE}%"
    
    # Temperatura da CPU (pode não funcionar em todos os sistemas)
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "Temperatura da CPU: $((CPU_TEMP / 1000))°C"
    fi
    
    # Memória RAM
    echo -n "Uso de RAM: "
    free -h | awk '/Mem:/ {print $3 "/" $2 " (" $3*100/$2 "%)"}'
    
    # Armazenamento (no volume do projeto)
    echo -n "Uso de Disco (/app): "
    df -h /app | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}'
}

# --- Loop Principal ---
while true; do
    clear # Limpa o terminal para a nova atualização
    echo "### PAINEL DE MONITORAMENTO - OCR BRESSAY ###"
    echo "Atualizado em: $(date)"
    echo "================================================="
    
    # Lógica para decidir qual fase exibir
    if [ -f "$TRAINING_LOG_FILE" ]; then
        display_training_stats
    else
        display_preparation_stats
    fi
    
    display_system_stats
    
    sleep "$SLEEP_INTERVAL"
done