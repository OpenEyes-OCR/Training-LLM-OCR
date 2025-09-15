#!/bin/bash
set -euo pipefail

MODEL_NAME="${MODEL_NAME:?A variável MODEL_NAME não foi definida. Execute por um script mestre.}"

TESS_DIR="tesstrain"
TESS_DATA_DIR="data"
MODEL_DATA_DIR="${TESS_DATA_DIR}/${MODEL_NAME}"
GROUND_TRUTH_DIR="${MODEL_DATA_DIR}-ground-truth"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Gerando arquivos .lstmf e listas de treinamento para '${MODEL_NAME}'---${NC}"

cd "$TESS_DIR"

if [ ! -f "${MODEL_DATA_DIR}/list.train" ]; then
    echo -e "${YELLOW}!!! ERRO !!! '${MODEL_DATA_DIR}/list.train' não encontrado.${NC}"
    exit 1
fi

mapfile -t IMAGE_NAMES < <(find "${GROUND_TRUTH_DIR}" -maxdepth 1 -type f -name '*.png' -printf '%f\n' | sort)

if [ "${#IMAGE_NAMES[@]}" -eq 0 ]; then
    echo -e "${YELLOW}!!! ERRO !!! Nenhuma imagem encontrada em '${GROUND_TRUTH_DIR}'.${NC}"
    exit 1
fi

LSTMF_TARGETS=()
for img in "${IMAGE_NAMES[@]}"; do
    base="${img%.png}"
    LSTMF_TARGETS+=("${GROUND_TRUTH_DIR}/${base}.lstmf")
done

echo "Alvos .lstmf a serem construídos:"
printf '%s\n' "${LSTMF_TARGETS[@]}"

make TESSDATA=$TESS_DATA_DIR MODEL_NAME=$MODEL_NAME "${LSTMF_TARGETS[@]}"

# --- A CORREÇÃO CRÍTICA ---
# O comando 'make' acima cria os arquivos .lstmf, mas não a lista mestra.
# Nós criamos a lista 'all-lstmf' manualmente aqui.
echo "Criando a lista mestra de arquivos .lstmf ('all-lstmf')..."
printf '%s\n' "${LSTMF_TARGETS[@]}" > "data/${MODEL_NAME}/all-lstmf"

echo "Gerando as listas de treinamento finais ('train' e 'eval')..."
# Agora este script encontrará seu arquivo de entrada
python3 shuffle.py 0 "data/${MODEL_NAME}/all-lstmf"
python3 generate_eval_train.py "data/${MODEL_NAME}/all-lstmf" 0.95

cd ..

echo -e "\n${GREEN}--- Geração de arquivos .lstmf e listas concluída! ---${NC}"
