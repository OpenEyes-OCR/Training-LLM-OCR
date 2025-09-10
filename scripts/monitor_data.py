#!/usr/bin/env python3
import json
import os
import psutil
import subprocess

# --- Configuração ---
PREPARATION_TARGET_DIR = "tesstrain/data/{model_name}-ground-truth"
RAW_DATA_DIR = "dataset/raw"
TRAINING_LOG_FILE = "output/{model_name}/training.log"

def get_system_stats():
    # Coleta dados de CPU, RAM e Disco usando psutil
    return {
        "cpu_usage": psutil.cpu_percent(),
        "ram_usage": psutil.virtual_memory().percent,
        "disk_usage": psutil.disk_usage('/app').percent
    }

def get_pipeline_stats(model_name):
    log_file = TRAINING_LOG_FILE.format(model_name=model_name)
    
    # Verifica se o log de treinamento já existe para determinar a fase
    if os.path.exists(log_file):
        # FASE DE TREINAMENTO
        try:
            # Pega a última linha do log de treinamento
            last_line = subprocess.check_output(['tail', '-n', '1', log_file]).decode('utf-8').strip()
            return {
                "phase": "Treinamento (lstmtraining)",
                "progress_text": last_line
            }
        except Exception:
            return { "phase": "Treinamento (iniciando)", "progress_text": "Aguardando primeiro log..." }
    else:
        # FASE DE PREPARAÇÃO
        prep_dir = PREPARATION_TARGET_DIR.format(model_name=model_name)
        
        # Conta arquivos .png na origem e .lstmf no destino
        total_pngs = len([f for f in os.listdir(RAW_DATA_DIR) if f.endswith('.png')]) if os.path.exists(RAW_DATA_DIR) else 0
        current_lstmf = len([f for f in os.listdir(prep_dir) if f.endswith('.lstmf')]) if os.path.exists(prep_dir) else 0
        
        percent = int((current_lstmf * 100) / total_pngs) if total_pngs > 0 else 0
        
        return {
            "phase": "Preparação (gerando .lstmf)",
            "progress_text": f"Progresso: {percent}% ({current_lstmf}/{total_pngs} arquivos .lstmf)"
        }

def main():
    # Detecta o modelo em uso (teste ou bressay) verificando as pastas de output
    model_name = "bressay" if os.path.exists("output/bressay") else "teste"
    
    all_data = {
        "system": get_system_stats(),
        "pipeline": get_pipeline_stats(model_name)
    }
    
    # Imprime tudo como um único objeto JSON
    print(json.dumps(all_data, indent=4))

if __name__ == "__main__":
    main()