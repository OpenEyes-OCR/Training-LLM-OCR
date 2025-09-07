#!/bin/bash

# --- 01_prepare_data.sh ---
# Este script prepara os dados de ground truth para o treinamento.

set -euo pipefail

# --- Variáveis de Configuração ---
MODEL_NAME="bressay"
RAW_DATA_DIR="dataset/raw"
TESS_DATA_DIR="tesstrain/data"
GROUND_TRUTH_DIR="${TESS_DATA_DIR}/${MODEL_NAME}-ground-truth"
TRAIN_RATIO=0.95

# --- Definindo caminhos absolutos para os arquivos de saída ANTES de mudar de diretório ---
# Isso evita erros de 'path not found'
TRAIN_LIST_FILE="$(realpath ${TESS_DATA_DIR})/${MODEL_NAME}.training_files.txt"
EVAL_LIST_FILE="$(realpath ${TESS_DATA_DIR})/${MODEL_NAME}.evaluation_files.txt"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Início da Execução ---
echo -e "${GREEN}--- Iniciando a preparação dos dados para o modelo '${MODEL_NAME}' ---${NC}"

echo "Verificando se o diretório de dados brutos '${RAW_DATA_DIR}' existe..."
if [ ! -d "$RAW_DATA_DIR" ] || [ -z "$(ls -A $RAW_DATA_DIR)" ]; then
    echo -e "${YELLOW}!!! AVISO !!!${NC}"
    echo "O diretório '${RAW_DATA_DIR}' não existe ou está vazio."
    echo "Por favor, crie-o e coloque seus arquivos .tif e .gt.txt dentro dele antes de continuar."
    mkdir -p $RAW_DATA_DIR
    exit 1
fi

echo "Criando o diretório de ground truth em: '${GROUND_TRUTH_DIR}'"
mkdir -p $GROUND_TRUTH_DIR

echo "Copiando arquivos de '${RAW_DATA_DIR}' para '${GROUND_TRUTH_DIR}'..."
cp ${RAW_DATA_DIR}/*.tif ${GROUND_TRUTH_DIR}/
cp ${RAW_DATA_DIR}/*.gt.txt ${GROUND_TRUTH_DIR}/
echo "$(ls -1 ${GROUND_TRUTH_DIR}/*.tif | wc -l) arquivos de imagem copiados."

echo "Gerando listas de arquivos de treino e avaliação..."
# Entra no diretório para facilitar o 'find'
cd $GROUND_TRUTH_DIR

# Lista todos os arquivos .tif com caminho absoluto, embaralha, e salva em um arquivo temporário
find . -name "*.tif" -exec realpath {} \; | shuf > all-files.txt

TOTAL_FILES=$(wc -l < all-files.txt)
# Usando 'awk' para cálculo de ponto flutuante mais seguro
TRAIN_COUNT=$(awk -v total=$TOTAL_FILES -v ratio=$TRAIN_RATIO 'BEGIN { printf "%.0f", total * ratio }')
EVAL_COUNT=$((TOTAL_FILES - TRAIN_COUNT))

# Cria os arquivos de lista usando os caminhos absolutos definidos no início
head -n "$TRAIN_COUNT" all-files.txt > "${TRAIN_LIST_FILE}"
tail -n "$EVAL_COUNT" all-files.txt > "${EVAL_LIST_FILE}"

rm all-files.txt
cd ../../.. # Volta para a raiz do projeto

echo -e "\n${GREEN}--- Preparação dos dados concluída! ---${NC}"
echo "Total de arquivos: ${TOTAL_FILES}"
echo "Arquivos de Treino: ${TRAIN_COUNT} (lista em ${TRAIN_LIST_FILE})"
echo "Arquivos de Avaliação: ${EVAL_COUNT} (lista em ${EVAL_LIST_FILE})"