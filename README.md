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

## Começando

Siga estes passos para configurar o ambiente pela primeira vez.

#### 1. Clone o Repositório
```bash
git clone [https://github.com/OpenEyes-OCR/Training-LLM-OCR](https://github.com/OpenEyes-OCR/Training-LLM-OCR)
cd Training-LLM-OCR
2. Adicione o Dataset (Para Treinamento Real)
Este pipeline foi projetado para usar o dataset BRESSAY.

Baixe e descompacte o dataset.

Coloque a pasta descompactada (bressay/) na raiz do projeto. Este diretório é ignorado pelo Git.

3. Construa a Imagem Docker
Este comando lê o Dockerfile e constrói o ambiente com todas as dependências. Pode levar vários minutos.

Bash

docker build -t ocr-training-env .
workflows Como Usar
O projeto possui dois fluxos de trabalho principais, executados de dentro do container.

Fluxo de Trabalho 1: Teste Rápido do Pipeline
Para validar rapidamente se todo o sistema está funcional. Executa um ciclo completo em poucos minutos.

Inicie o Container:

Bash

docker run -it --rm -v "$(pwd)":/app --name ocr_teste ocr-training-env
Execute o Pipeline de Teste (Dentro do container):

Bash

./run_test_pipeline.sh
Verifique o Resultado: Ao final, um modelo teste.traineddata será criado. Verifique-o com:

Bash

tesseract dataset/raw/teste.png stdout --tessdata-dir ./output/final_models -l teste
A saída esperada é um texto simples para teste de OCR.

Fluxo de Trabalho 2: Treinamento Real (Dataset BRESSAY)
Para treinar o modelo com o dataset completo.

Inicie o Container (Dê um nome a ele):

Bash

docker run -it --rm -v "$(pwd)":/app --name ocr_treinamento ocr-training-env
Prepare os Dados do BRESSAY (Dentro do container, apenas uma vez):
Este script prepara os ~30.000 arquivos para o pipeline.

Bash

./scripts/PRE-01_prepare_bressay_dataset.sh
Inicie o Treinamento Real (Dentro do container):
Este processo será longo (horas ou dias). Lembre-se de ajustar a variável MAX_ITERATIONS no script run_training_bressay.sh para um valor alto (ex: 20000).

Bash

./run_training_bressay.sh
Ao final, seu modelo bressay.traineddata estará pronto na pasta output/final_models/.

Monitorando o Progresso (GUI)
Enquanto o treinamento longo (Passo 3 acima) está em execução, você pode monitorá-lo em tempo real.

Garanta que o container de treinamento foi iniciado com a flag --name ocr_treinamento.

Abra um segundo terminal na sua máquina host.

Execute o script da interface gráfica, passando o nome do container como argumento:

Bash

python3 monitor_gui.py ocr_treinamento
Uma janela com tema Dracula será aberta, exibindo o progresso e o uso de CPU/RAM.

  Estrutura do Projeto
Training-LLM-OCR/
├── .gitignore
├── Dockerfile
├── monitor_gui.py
├── run_test_pipeline.sh
├── run_training_bressay.sh
│
├── bressay/
│
├── dataset/
│   ├── raw/
│   └── bad_files.log
│
├── output/
│   ├── bressay/
│   ├── teste/
│   └── final_models/
│
└── scripts/
    ├── PRE-01_prepare_bressay_dataset.sh
    ├── 00_setup_env.sh
    ├── 01_prepare_data.sh
    ├── 02_generate_training_files.sh
    ├── 03_run_training.sh
    ├── 04_finalize_model.sh
    └── create_test_files.sh

Licença:
Este projeto está sob a licença MIT.
