#!/bin/bash

# --- run_training_bressay.sh ---
# Executa o ciclo de treinamento e finalização usando os dados previamente
# preparados pelo script PRE-01.

set -e
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE DE TREINAMENTO REAL (BRESSAY) ---${NC}"

echo -e "\n${CYAN}==> PASSO 0: Garantindo permissões...${NC}"
chmod +x scripts/*.sh

echo -e "\n${CYAN}==> PASSO 1: Configurando ambiente...${NC}"
./scripts/00_setup_env.sh

# AVISO: Este script assume que você já executou o PRE-01 para popular 'dataset/raw'

echo -e "\n${CYAN}==> PASSO 3: Organizando dados do BRESSAY...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4: Gerando arquivos .lstmf do BRESSAY...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${CYAN}==> PASSO 5: INICIANDO O TREINAMENTO REAL...${NC}"
# Lembre-se de ajustar MAX_ITERATIONS em 03_run_training.sh para um valor alto!
./scripts/03_run_training.sh

echo -e "\n${CYAN}==> PASSO 6: Finalizando modelo REAL...${NC}"
./scripts/04_finalize_model.sh

echo -e "\n${GREEN}--- PIPELINE DE TREINAMENTO REAL CONCLUÍDO ---${NC}"