#!/bin/bash

# --- run_preparation_pipeline.sh ---
# Script mestre que executa todo o pipeline de preparação de dados na ordem correta.

# 'set -e' garante que o script pare imediatamente se qualquer um dos sub-scripts falhar.
set -e

# Cores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE COMPLETO DE PREPARAÇÃO DE DADOS ---${NC}"

echo -e "\n${CYAN}==> PASSO 1/4: Configurando o ambiente e instalando dependências Python...${NC}"
./scripts/00_setup_env.sh

echo -e "\n${CYAN}==> PASSO 2/4: Criando arquivos de dados de teste...${NC}"
./scripts/create_test_files.sh

echo -e "\n${CYAN}==> PASSO 3/4: Organizando dados e criando listas de treinamento...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4/4: Gerando arquivos de treinamento no formato .lstmf...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${GREEN}--- PIPELINE DE PREPARAÇÃO DE DADOS CONCLUÍDO COM SUCESSO ---${NC}"