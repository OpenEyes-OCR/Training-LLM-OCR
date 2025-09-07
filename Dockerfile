# Usar a imagem base do Ubuntu 22.04
FROM ubuntu:22.04

# Evitar prompts interativos durante a instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar todas as dependências do projeto
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-por \
    libtesseract-dev \
    libleptonica-dev \
    libtiff5-dev \
    git \
    make \
    g++ \
    pkg-config \
    bc \
    imagemagick \
    python3 \
    python3-pip \
    wget \
    # Ferramentas úteis para debug
    nano \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir o diretório de trabalho padrão
WORKDIR /app

# Copiar os arquivos do projeto
COPY . .

# Comando padrão ao iniciar o container
CMD ["bash"]