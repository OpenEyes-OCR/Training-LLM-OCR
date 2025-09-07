#!/bin/bash

# --- 01_prepare_data.sh ---
# Este script prepara os dados de ground truth para o treinamento.
# 1. Cria a estrutura de diretórios necessária dentro de 'tesstrain/data/'.
# 2. Copia os arquivos .tif e .gt.txt do diretório do dataset para o local de treinamento.
# 3. Divide os dados em conjuntos de treinamento e avaliação (list.train e list.eval).
#
# COMO USAR:
# 1. Coloque seus arquivos .tif e .gt.txt em 'dataset/raw/'.
# 2. Dê permissão de execução: chmod +x scripts/01_prepare_data.sh
# 3. Execute a partir da raiz do projeto: ./scripts/01_prepare_data.sh

set -euo pipefail

# --- Variáveis de Configuração ---
MODEL_NAME="bressay" # O nome do seu modelo. Mantenha consistente!
RAW_DATA_DIR="dataset/raw" # Onde seus arquivos de imagem e texto estão.
TESS_DATA_DIR="tesstrain/data"
GROUND_TRUTH_DIR="${TESS_DATA_DIR}/${MODEL_NAME}-ground-truth"
# Proporção dos dados para treinamento (o resto será para avaliação)
# 0.95 = 95% para treino, 5% para avaliação
TRAIN_RATIO=0.95

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Início da Execução ---
echo -e "${GREEN}--- Iniciando a preparação dos dados para o modelo '${MODEL_NAME}' ---${NC}"

# Passo 1: Verificar e criar diretórios
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

# Passo 2: Copiar e normalizar os dados (placeholder)
echo "Copiando arquivos de '${RAW_DATA_DIR}' para '${GROUND_TRUTH_DIR}'..."
# Aqui você poderia adicionar comandos para normalizar imagens ou texto se necessário.
# Por enquanto, vamos apenas copiar.
cp ${RAW_DATA_DIR}/*.tif ${GROUND_TRUTH_DIR}/
cp ${RAW_DATA_DIR}/*.gt.txt ${GROUND_TRUTH_DIR}/
echo "$(ls -1 ${GROUND_TRUTH_DIR}/*.tif | wc -l) arquivos de imagem copiados."

# Passo 3: Criar listas de treinamento e avaliação
echo "Gerando listas de arquivos de treino e avaliação..."
cd $GROUND_TRUTH_DIR

# Lista todos os arquivos .tif, embaralha, e salva em um arquivo temporário
find . -name "*.tif" -exec realpath {} \; | shuf > all-files.txt

# Calcula o número de arquivos para cada conjunto
TOTAL_FILES=$(wc -l < all-files.txt)
TRAIN_COUNT=$(printf "%.0f" $(echo "$TOTAL_FILES * $TRAIN_RATIO" | bc))
EVAL_COUNT=$((TOTAL_FILES - TRAIN_COUNT))

# Cria os arquivos de lista
head -n "$TRAIN_COUNT" all-files.txt > "${TESS_DATA_DIR}/${MODEL_NAME}.training_files.txt"
tail -n "$EVAL_COUNT" all-files.txt > "${TESS_DATA_DIR}/${MODEL_NAME}.evaluation_files.txt"

# Limpa o arquivo temporário
rm all-files.txt
cd ../../.. # Volta para a raiz do projeto

echo -e "\n${GREEN}--- Preparação dos dados concluída! ---${NC}"
echo "Total de arquivos: ${TOTAL_FILES}"
echo "Arquivos de Treino: ${TRAIN_COUNT} (lista em ${TESS_DATA_DIR}/${MODEL_NAME}.training_files.txt)"
echo "Arquivos de Avaliação: ${EVAL_COUNT} (lista em ${TESS_DATA_DIR}/${MODEL_NAME}.evaluation_files.txt)"