#!/usr/bin/env bash
# End-to-end helper for preparar ambiente do treinador e validar o pipeline curto.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_IMAGE_NAME="ocr-training-env"
DEFAULT_TEST_CONTAINER_NAME="ocr_test_pipeline"

IMAGE_NAME="${IMAGE_NAME:-$DEFAULT_IMAGE_NAME}"
TEST_CONTAINER_NAME="${TEST_CONTAINER_NAME:-$DEFAULT_TEST_CONTAINER_NAME}"

BRESSAY_SOURCE_ROOT_ARG="${1:-"$PROJECT_ROOT/../bressay/data"}"
BRESSAY_SOURCE_SUBDIR="${BRESSAY_SOURCE_SUBDIR:-words}"

if ! command -v docker >/dev/null 2>&1; then
    echo "[ERRO] Docker não encontrado. Instale o Docker antes de continuar." >&2
    exit 1
fi

if [ ! -d "$BRESSAY_SOURCE_ROOT_ARG" ]; then
    cat <<EOF >&2
[ERRO] Diretório do dataset não encontrado: $BRESSAY_SOURCE_ROOT_ARG
Informe o caminho onde o dataset BRESSAY foi extraído, por exemplo:
    ./trainer_bootstrap.sh /dados/bressay/data
EOF
    exit 1
fi

echo "[INFO] Construindo imagem Docker '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" "$PROJECT_ROOT"

echo "[INFO] Preparando dataset BRESSAY dentro do container..."
docker run --rm \
    -v "$PROJECT_ROOT":/app \
    -v "$BRESSAY_SOURCE_ROOT_ARG":/bressay_data \
    --workdir /app \
    "$IMAGE_NAME" \
    bash -lc "BRESSAY_SOURCE_ROOT=/bressay_data BRESSAY_SOURCE_SUBDIR=$BRESSAY_SOURCE_SUBDIR ./scripts/PRE-01_prepare_bressay_dataset.sh"

echo "[INFO] Executando pipeline de teste dentro do container..."
docker run --rm \
    -v "$PROJECT_ROOT":/app \
    --name "$TEST_CONTAINER_NAME" \
    --workdir /app \
    "$IMAGE_NAME" \
    bash -lc "./run_test_pipeline.sh"

cat <<EOF

[SUCESSO] Ambiente validado. Resultado esperado:
  - Arquivos preparados em 'dataset/raw/'.
  - Modelo de teste em 'output/final_models/teste.traineddata'.

Para iniciar o treinamento completo do BRESSAY rode:
  docker run -it --rm \
    -v "$PROJECT_ROOT":/app \
    --name ocr_treinamento \
    --workdir /app \
    "$IMAGE_NAME" \
    bash -lc './run_training_bressay.sh'

EOF
