# Pipeline de Treinamento de OCR com Tesseract

Este projeto contém um pipeline automatizado e containerizado para treinar modelos de Reconhecimento Ótico de Caracteres (OCR) customizados com a engine Tesseract. Ele foi projetado para ser robusto, reproduzível e fácil de usar, transformando um dataset bruto de imagens e textos em um modelo `.traineddata` pronto para uso.

O sistema foi desenvolvido e testado com o dataset de caligrafia em português **BRESSAY**.

## Pré-requisitos

Antes de começar, garanta que você tenha os seguintes softwares instalados na sua máquina:

  * **Git:** Para clonar o repositório.
  * **Docker:** Para construir e executar o ambiente de treinamento containerizado. (ex: [Docker Desktop](https://www.docker.com/products/docker-desktop/) ou Docker Engine no Linux).

## Instalação e Configuração

Siga estes passos para configurar o ambiente pela primeira vez.

#### Passo 1: Clonar o Repositório

Clone este projeto para a sua máquina local.

```bash
git clone <URL_DO_SEU_REPOSITORIO>
cd Training-LLM-OCR
```

#### Passo 2: Adicionar o Dataset (Para Treinamento Real)

Este pipeline foi projetado para usar o dataset BRESSAY.

1.  Baixe e descompacte o dataset BRESSAY.
2.  Coloque a pasta descompactada (`bressay/`) e, opcionalmente, o arquivo `.zip` na raiz do projeto.
      * *Observação: Estes arquivos serão ignorados pelo Git, conforme definido no `.gitignore`, para não sobrecarregar o repositório.*

#### Passo 3: Construir a Imagem Docker

Este comando lê o `Dockerfile` e constrói o ambiente de software com todas as dependências necessárias. Este processo pode levar vários minutos na primeira vez.

```bash
docker build -t ocr-training-env .
```

Ao final deste passo, seu ambiente estará pronto para ser usado.

-----

## Como Usar

O projeto possui dois fluxos de trabalho principais: um para um teste rápido de ponta a ponta e outro para o treinamento de produção com o dataset completo.

### Fluxo de Trabalho 1: Executando um Teste Rápido

Use este fluxo para validar rapidamente se todo o pipeline está funcional. Ele cria um dado de teste sintético e executa um ciclo completo em poucos minutos.

#### 1\. Inicie o Container

```bash
docker run -it --rm -v "$(pwd)":/app --name ocr_teste ocr-training-env
```

#### 2\. Execute o Pipeline de Teste

Dentro do container (o prompt mudará para `root@...:/app#`), execute o script mestre de teste:

```bash
./run_test_pipeline.sh
```

#### 3\. Verifique o Resultado

Após a conclusão, o script terá gerado um modelo chamado `teste.traineddata`. Você pode verificá-lo imediatamente com o comando:

```bash
tesseract dataset/raw/teste.png stdout --tessdata-dir ./output/final_models -l teste
```

A saída esperada é `um texto simples para teste de OCR`.

-----

### Fluxo de Trabalho 2: Executando o Treinamento Real (Dataset BRESSAY)

Use este fluxo para treinar o modelo com o dataset completo.

#### 1\. Prepare os Dados do BRESSAY (Apenas uma vez)

Este passo varre a estrutura complexa do BRESSAY, valida as imagens e as copia para a pasta de entrada do pipeline.

  * Inicie o container:
    ```bash
    docker run -it --rm -v "$(pwd)":/app --name ocr_preparacao ocr-training-env
    ```
  * Dentro do container, execute:
    ```bash
    ./scripts/PRE-01_prepare_bressay_dataset.sh
    ```
    Ao final, a pasta `dataset/raw` estará populada com todos os arquivos do BRESSAY.

#### 2\. Ajuste as Iterações de Treinamento (Recomendado)

Para um treinamento real, você precisa de mais iterações. Fora do container, edite o arquivo `run_training_bressay.sh` e ajuste a variável `MAX_ITERATIONS` para um valor alto (ex: `20000`).

#### 3\. Inicie o Treinamento Real

Este processo será longo (pode levar horas ou dias).

  * Inicie o container (dando a ele um nome descritivo):
    ```bash
    docker run -it --rm -v "$(pwd)":/app --name ocr_treinamento ocr-training-env
    ```
  * Dentro do container, execute o script mestre de treinamento:
    ```bash
    ./run_training_bressay.sh
    ```

#### 4\. Monitore o Progresso (Opcional)

Enquanto o Terminal 1 está treinando, abra um **segundo terminal** no seu computador e entre no mesmo container com o comando `docker exec`:

```bash
docker exec -it ocr_treinamento bash
```

Dentro desta nova sessão, inicie o painel de monitoramento:

```bash
./monitor.sh
```

Isso exibirá o progresso e o uso de recursos, atualizando a cada 5 segundos.

-----

### Estrutura do Projeto

```
Training-LLM-OCR/
├── .gitignore               # Define arquivos a serem ignorados pelo Git.
├── Dockerfile               # Blueprint do ambiente Docker.
├── monitor.sh               # Painel de monitoramento de progresso e recursos.
├── run_test_pipeline.sh     # SCRIPT MESTRE: Executa um ciclo de teste rápido.
├── run_training_bressay.sh  # SCRIPT MESTRE: Executa o treinamento com dados reais.
│
├── dataset/                 # Pasta para os dados de trabalho.
├── output/                  # Pasta para os resultados (checkpoints, logs, modelos).
└── scripts/                 # Contém todos os scripts auxiliares do pipeline.
```
