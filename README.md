# Pipeline de Treinamento de OCR com Tesseract

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Technology: Docker](https://img.shields.io/badge/Technology-Docker-blue.svg)
![Language: Shell](https://img.shields.io/badge/Language-Shell-lightgrey.svg)
![Engine: Tesseract](https://img.shields.io/badge/Engine-Tesseract-orange.svg)

Este projeto contém um pipeline automatizado e containerizado para treinar modelos de Reconhecimento Ótico de Caracteres (OCR) customizados com a engine Tesseract. Ele foi projetado para ser robusto, reproduzível e fácil de usar, transformando um dataset bruto de imagens e textos em um modelo `.traineddata` pronto para uso.

### Siga-nos

Acompanhe o desenvolvimento e as novidades do nosso projeto no Instagram!

[![Instagram](https://img.shields.io/badge/Instagram-%40openeyesocr-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/openeyesocr)

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

#### Passo 2: Baixar e Preparar o Dataset BRESSAY

Você pode baixar o dataset manualmente pelo link ou usar os comandos abaixo para fazer o download e a descompactação.

  * **Link para Download:** [BRESSAY Dataset](https://tc11.cvc.uab.es/index.php?com=upload&action=file_down&section=dataset&section_id=360&file=324)

  * **Opção: Via Linha de Comando**

    ```bash
    # Baixa o arquivo do link fornecido e o salva como bressay.zip
    wget -O bressay.zip "https://tc11.cvc.uab.es/index.php?com=upload&action=file_down&section=dataset&section_id=360&file=324"

    # Descompacta o arquivo (requer o p7zip-full: sudo apt install p7zip-full)
    7z x bressay.zip
    ```

 > ⚠️ **Importante:** A pasta `bressay/` deve ser extraída na **raiz do projeto** para que os scripts de preparação a encontrem corretamente.

*Observação: A pasta `bressay/` e o arquivo `bressay.zip` serão ignorados pelo Git, conforme definido no `.gitignore`.*

#### Passo 3: Construir a Imagem Docker

Este comando lê o `Dockerfile` e constrói o ambiente com todas as dependências. Pode levar vários minutos.

```bash
docker build -t ocr-training-env .
```

-----

## workflows Como Usar

O projeto possui dois fluxos de trabalho principais, executados de dentro do container.

### Fluxo de Trabalho 1: Teste Rápido do Pipeline

Para validar rapidamente se todo o sistema está funcional. Executa um ciclo completo em poucos minutos.

1.  **Inicie o Container:**
    ```bash
    docker run -it --rm -v "$(pwd)":/app --name ocr_teste ocr-training-env
    ```
2.  **Execute o Pipeline de Teste (Dentro do container):**
    ```bash
    ./run_test_pipeline.sh
    ```
3.  **Verifique o Resultado:** Ao final, um modelo `teste.traineddata` será criado. Verifique-o com:
    ```bash
    tesseract dataset/raw/teste.png stdout --tessdata-dir ./output/final_models -l teste
    ```
    A saída esperada é `um texto simples para teste de OCR`.

### Fluxo de Trabalho 2: Treinamento Real (Dataset BRESSAY)

Para treinar o modelo com o dataset completo.

1.  **Inicie o Container (Dê um nome a ele):**
    ```bash
    docker run -it --rm -v "$(pwd)":/app --name ocr_treinamento ocr-training-env
    ```
2.  **Prepare os Dados do BRESSAY (Dentro do container, apenas uma vez):**
    Este script prepara os \~30.000 arquivos para o pipeline.
    ```bash
    ./scripts/PRE-01_prepare_bressay_dataset.sh
    ```

3.  **Inicie o Treinamento Real (Dentro do container):**
    Este processo será **longo (horas ou dias)**. Lembre-se de ajustar a variável `MAX_ITERATIONS` no script `run_training_bressay.sh` para um valor alto (ex: `20000`).
    ```bash
    ./run_training_bressay.sh
    ```
    Ao final, seu modelo `bressay.traineddata` estará pronto na pasta `output/final_models/`.

### Monitorando o Progresso (GUI)

Enquanto o treinamento longo (Passo 3 acima) está em execução, você pode monitorá-lo em tempo real.

1.  Garanta que o container de treinamento foi iniciado com a flag `--name ocr_treinamento`.
2.  Abra um **segundo terminal na sua máquina host**.
3.  Execute o script da interface gráfica, passando o nome do container como argumento:
    ```bash
    python3 monitor_gui.py <Nome do container>/<ID do container>
    ```

Uma janela com será aberta, exibindo o progresso e o uso de CPU/RAM e armazenamento utilizado.

-----

### Estrutura de pastas 

```
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
```

## 🛠️ Tecnologias Utilizadas

Este projeto foi construído utilizando um conjunto de ferramentas robustas e de código aberto, focadas em automação e reprodutibilidade.


* **Tesseract:** O motor de OCR de código aberto do Google, utilizado como base para o treinamento e reconhecimento de texto. 
![Tesseract](https://img.shields.io/badge/Tesseract-OCR-orange?style=for-the-badge&logo=tesseract) 

* **Docker:** Ferramenta de containerização usada para criar um ambiente de desenvolvimento e execução isolado e consistente. 
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white) 

* **Shell Script (Bash):** A "cola" do projeto. Utilizado para automatizar e orquestrar todas as etapas do pipeline.  
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white) 

* **Python:** Utilizado para os scripts auxiliares do `tesstrain` e para a construção da interface gráfica de monitoramento. 
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white) 

* **Tkinter:** A biblioteca padrão do Python usada para criar o painel de monitoramento gráfico (GUI) em tempo real. 
![Tkinter](https://img.shields.io/badge/Tkinter-GUI-blue?style=for-the-badge&logo=python&logoColor=white) 


### Licença e Copyright

Este projeto é distribuído sob a Licença MIT. 

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Copyright (c) 2025 OpenEyesOCR. Todos os direitos reservados.



