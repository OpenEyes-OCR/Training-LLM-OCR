#!/bin/bash

# --- run_everything.sh ---
# Script mestre que executa TODO o pipeline, desde a permissão até o treinamento.

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE COMPLETO ---${NC}"

echo -e "\n${CYAN}==> PASSO 0: Garantindo permissões de execução...${NC}"
chmod +x scripts/*.sh

echo -e "\n${CYAN}==> PASSO 1: Configurando o ambiente (pip install)...${NC}"
./scripts/00_setup_env.sh

echo -e "\n${CYAN}==> PASSO 2: Criando arquivos de dados de teste...${NC}"
./scripts/create_test_files.sh

echo -e "\n${CYAN}==> PASSO 3: Organizando dados e criando listas...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4: Gerando arquivos .lstmf...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${CYAN}==> PASSO 5: INICIANDO O TREINAMENTO...${NC}"
./scripts/03_run_training.sh

echo -e "\n${GREEN}--- PIPELINE COMPLETO EXECUTADO ---${NC}"