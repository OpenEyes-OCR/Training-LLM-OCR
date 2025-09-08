#!/bin/bash

# --- run_test_pipeline.sh ---
# Executa um ciclo completo de ponta a ponta com um único arquivo de teste gerado.

set -e
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE DE TESTE ---${NC}"

echo -e "\n${CYAN}==> PASSO 0: Garantindo permissões...${NC}"
chmod +x scripts/*.sh

echo -e "\n${CYAN}==> PASSO 1: Configurando ambiente...${NC}"
./scripts/00_setup_env.sh

echo -e "\n${CYAN}==> PASSO 2: Criando dado de teste...${NC}"
./scripts/create_test_files.sh

echo -e "\n${CYAN}==> PASSO 3: Organizando dados...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4: Gerando arquivos .lstmf...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${CYAN}==> PASSO 5: Iniciando treinamento de TESTE...${NC}"
./scripts/03_run_training.sh

echo -e "\n${CYAN}==> PASSO 6: Finalizando modelo de TESTE...${NC}"
./scripts/04_finalize_model.sh

echo -e "\n${GREEN}--- PIPELINE DE TESTE CONCLUÍDO ---${NC}"