#!/bin/bash

# --- 02_generate_training_files.sh ---
# Gera os arquivos de treinamento no formato .lstmf a partir dos dados de ground truth.
# Utiliza o Makefile 'tesstrain' para automatizar o processo.
#
# COMO USAR:
# 1. Certifique-se de que os scripts anteriores foram executados com sucesso.
# 2. Execute a partir da raiz do projeto, de preferência dentro do container Docker.
#    ./scripts/02_generate_training_files.sh

set -euo pipefail

# --- Variáveis de Configuração ---
MODEL_NAME="bressay" # Deve ser o mesmo nome usado nos scripts anteriores
TESS_DIR="tesstrain"
TESS_DATA_DIR="${TESS_DIR}/data"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Início da Execução ---
echo -e "${GREEN}--- Iniciando a geração dos arquivos de treinamento (.lstmf) ---${NC}"

# Passo 1: Verificar se os arquivos de lista existem
TRAIN_LIST_FILE="${TESS_DATA_DIR}/${MODEL_NAME}.training_files.txt"
if [ ! -f "$TRAIN_LIST_FILE" ]; then
    echo -e "${YELLOW}!!! ERRO !!!${NC}"
    echo "Arquivo de lista de treinamento não encontrado em: ${TRAIN_LIST_FILE}"
    echo "Por favor, execute o script '01_prepare_data.sh' primeiro."
    exit 1
fi

# Passo 2: Entrar no diretório tesstrain para executar o Makefile
cd $TESS_DIR

# Passo 3: Executar o comando 'make' para gerar os arquivos .lstmf
# O Makefile do tesstrain é inteligente. Ele procurará pelos arquivos
# ${MODEL_NAME}.training_files.txt e ${MODEL_NAME}.evaluation_files.txt
# dentro da pasta 'data/' para processar.
echo "Executando o Makefile para gerar os arquivos .lstmf..."
make training MODEL_NAME=$MODEL_NAME TESSDATA=$TESS_DATA_DIR

# Passo 4: Voltar para a raiz do projeto
cd ..

# Contar quantos arquivos foram gerados para confirmação
LSTMF_COUNT=$(find "${TESS_DATA_DIR}/${MODEL_NAME}-ground-truth" -name '*.lstmf' | wc -l)

echo -e "\n${GREEN}--- Geração de arquivos concluída! ---${NC}"
echo "${LSTMF_COUNT} arquivos .lstmf foram gerados em: ${TESS_DATA_DIR}/${MODEL_NAME}-ground-truth/"
echo "O projeto está pronto para a etapa de fine-tuning (treinamento)."