#!/bin/bash

# --- run_test_pipeline.sh ---
# (Versão Corrigida com Limpeza)
# Executa um ciclo de teste rápido, garantindo que o ambiente esteja limpo.

set -e
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- INICIANDO PIPELINE DE TESTE ---${NC}"

# --- A CORREÇÃO CRÍTICA ---
echo -e "\n${YELLOW}==> PASSO A: Limpando o diretório de dados para garantir um teste isolado...${NC}"
rm -rf dataset/raw
mkdir -p dataset/raw

echo -e "\n${CYAN}==> PASSO 0: Garantindo permissões...${NC}"
chmod +x scripts/*.sh

echo -e "\n${CYAN}==> PASSO 1: Configurando ambiente...${NC}"
./scripts/00_setup_env.sh

echo -e "\n${CYAN}==> PASSO 2: Criando dado de teste...${NC}"
./scripts/create_test_files.sh

echo -e "\n${CYAN}==> PASSO 3: Organizando dados de teste...${NC}"
./scripts/01_prepare_data.sh

echo -e "\n${CYAN}==> PASSO 4: Gerando arquivos .lstmf de teste...${NC}"
./scripts/02_generate_training_files.sh

echo -e "\n${CYAN}==> PASSO 5: Iniciando treinamento de TESTE...${NC}"
./scripts/03_run_training.sh

echo -e "\n${CYAN}==> PASSO 6: Finalizando modelo de TESTE...${NC}"
./scripts/04_finalize_model.sh

echo -e "\n${GREEN}--- PIPELINE DE TESTE CONCLUÍDO ---${NC}"