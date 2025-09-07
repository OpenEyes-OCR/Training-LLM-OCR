# Usar a imagem base do Ubuntu 22.04, que é estável e moderna
FROM ubuntu:22.04

# Evitar prompts interativos durante a instalação de pacotes
ENV DEBIAN_FRONTEND=noninteractive

# Instalar todas as dependências do projeto em um único passo para otimizar o cache
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-por \
    libtesseract-dev \
    libleptonica-dev \
    git \
    make \
    g++ \
    pkg-config \
    bc \
    imagemagick \
    # Ferramentas úteis para debug dentro do container
    nano \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir o diretório de trabalho padrão dentro do container
WORKDIR /app

# Copiar os arquivos do projeto para dentro do container.
# O .dockerignore pode ser usado para excluir arquivos/pastas.
COPY . .

# Comando padrão ao iniciar o container: um shell interativo
CMD ["bash"]