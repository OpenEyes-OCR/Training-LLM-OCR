#!/bin/bash
set -e
# --- Define o modo de operação para o modelo real ---
export MODEL_NAME="bressay"
# Define um número alto de iterações para o treinamento real
export MAX_ITERATIONS=200000

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE DE TREINAMENTO REAL (BRESSAY) ---${NC}"

echo -e "\n${CYAN}==> PASSO 0: Garantindo permissões...${NC}"
chmod +x scripts/*.sh

echo -e "\n${CYAN}==> PASSO 1: Configurando ambiente...${NC}"
./scripts/00_setup_env.sh

echo -e "\n${CYAN}==> PASSO 2: Preparando os arquivos em dataset/raw ...${NC}"
./scripts/PRE-01_prepare_bressay_dataset.sh

echo -e "\n${CYAN}==> PASSO 3: Organizando dados do BRESSAY...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4: Gerando arquivos .lstmf do BRESSAY...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${CYAN}==> PASSO 5: INICIANDO O TREINAMENTO REAL...${NC}"
./scripts/03_run_training.sh

echo -e "\n${CYAN}==> PASSO 6: Finalizando modelo REAL...${NC}"
./scripts/04_finalize_model.sh

echo -e "\n${GREEN}--- PIPELINE DE TREINAMENTO REAL CONCLUÍDO ---${NC}"