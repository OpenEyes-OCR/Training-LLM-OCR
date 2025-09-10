# Pipeline de Treinamento de OCR com Tesseract

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Technology: Docker](https://img.shields.io/badge/Technology-Docker-blue.svg)
![Language: Shell](https://img.shields.io/badge/Language-Shell-lightgrey.svg)
![Engine: Tesseract](https://img.shields.io/badge/Engine-Tesseract-orange.svg)

Este projeto contém um pipeline automatizado e containerizado para treinar modelos de Reconhecimento Ótico de Caracteres (OCR) customizados com a engine Tesseract. Ele foi projetado para ser robusto, reproduzível e fácil de usar, transformando um dataset bruto de imagens e textos em um modelo `.traineddata` pronto para uso.

O sistema foi desenvolvido e testado com o dataset de caligrafia em português **BRESSAY**.

## Funcionalidades

* **Ambiente 100% Reproduzível:** Utiliza Docker para encapsular todas as dependências, garantindo que o pipeline funcione da mesma forma em qualquer máquina.
* **Pipeline Automatizado:** Scripts mestres orquestram todo o processo, desde a preparação dos dados até a finalização do modelo.
* **Fluxos de Trabalho Separados:** Scripts dedicados para um ciclo de **teste rápido** e para o **treinamento de produção**, evitando contaminação de dados.
* **Resiliência a Dados:** O script de preparação valida as imagens de entrada, descartando arquivos corrompidos para evitar que o treinamento seja interrompido.
* **Monitoramento Gráfico:** Um painel de controle em tempo real (GUI) para acompanhar o progresso e o uso de recursos do sistema durante os processos longos.

## Pré-requisitos

Antes de começar, garanta que você tenha os seguintes softwares instalados na sua máquina **host**:
* **Git:** Para clonar o repositório.
* **Docker:** Para construir e executar o ambiente de treinamento. ([Instruções de Instalação](https://docs.docker.com/engine/install/)).
    * *Observação para Linux:* É altamente recomendado adicionar seu usuário ao grupo `docker` para executar comandos sem `sudo`.
* **Python 3 e Tkinter:** Necessários para a interface gráfica de monitoramento. Na maioria dos sistemas baseados em Debian/Ubuntu, pode ser instalado com:
    ```bash
    sudo apt-get update && sudo apt-get install python3-tk
    ```
