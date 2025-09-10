import tkinter as tk
import json
import subprocess
import threading
import time
import sys

# --- Configuração ---

# Paleta de cores COMPLETA do tema Dracula
DRACULA_BG = "#282a36"
DRACULA_FG = "#f8f8f2"
DRACULA_COMMENT = "#6272a4"
DRACULA_CYAN = "#8be9fd"
DRACULA_GREEN = "#50fa7b"
DRACULA_ORANGE = "#ffb86c"
DRACULA_PINK = "#ff79c6"
DRACULA_PURPLE = "#bd93f9"
DRACULA_RED = "#ff5555"
DRACULA_YELLOW = "#f1fa8c"

# Lógica para pegar o nome do container da linha de comando
if len(sys.argv) > 1:
    CONTAINER_NAME = sys.argv[1]
else:
    print("ERRO: O nome ou ID do container não foi fornecido.")
    print("Uso: python3 monitor_gui.py <nome_do_container>")
    sys.exit(1)

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Painel de Monitoramento OCR")
        self.geometry("800x400")
        self.configure(bg=DRACULA_BG)

        self.data = {}
        self.create_widgets()
        
        self.running = True
        self.thread = threading.Thread(target=self.fetch_data_loop)
        self.thread.daemon = True
        self.thread.start()
        
        self.update_gui_loop()

    def create_widgets(self):
        self.grid_columnconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=2)

        tk.Label(self, text="Status do Pipeline", fg=DRACULA_PURPLE, bg=DRACULA_BG, font=("Segoe UI", 16, "bold")).grid(row=0, column=0, columnspan=2, pady=10)
        
        tk.Label(self, text="Fase Atual:", fg=DRACULA_FG, bg=DRACULA_BG, font=("Segoe UI", 12)).grid(row=1, column=0, sticky="w", padx=20, pady=5)
        self.phase_var = tk.StringVar(value="Aguardando dados...")
        tk.Label(self, textvariable=self.phase_var, fg=DRACULA_CYAN, bg=DRACULA_BG, font=("Segoe UI", 12, "bold")).grid(row=1, column=1, sticky="w", padx=20, pady=5)
        
        tk.Label(self, text="Progresso:", fg=DRACULA_FG, bg=DRACULA_BG, font=("Segoe UI", 12)).grid(row=2, column=0, sticky="w", padx=20, pady=5)
        self.progress_var = tk.StringVar(value="...")
        tk.Label(self, textvariable=self.progress_var, fg=DRACULA_GREEN, bg=DRACULA_BG, font=("Segoe UI Mono", 10, "bold"), justify=tk.LEFT).grid(row=2, column=1, sticky="w", padx=20, pady=5)

        tk.Label(self, text="Recursos do Sistema", fg=DRACULA_PURPLE, bg=DRACULA_BG, font=("Segoe UI", 16, "bold")).grid(row=3, column=0, columnspan=2, pady=20)
        
        tk.Label(self, text="Uso de CPU:", fg=DRACULA_FG, bg=DRACULA_BG, font=("Segoe UI", 12)).grid(row=4, column=0, sticky="w", padx=20, pady=5)
        self.cpu_var = tk.StringVar(value="... %")
        tk.Label(self, textvariable=self.cpu_var, fg=DRACULA_ORANGE, bg=DRACULA_BG, font=("Segoe UI", 12, "bold")).grid(row=4, column=1, sticky="w", padx=20, pady=5)
        
        tk.Label(self, text="Uso de RAM:", fg=DRACULA_FG, bg=DRACULA_BG, font=("Segoe UI", 12)).grid(row=5, column=0, sticky="w", padx=20, pady=5)
        self.ram_var = tk.StringVar(value="... %")
        tk.Label(self, textvariable=self.ram_var, fg=DRACULA_PINK, bg=DRACULA_BG, font=("Segoe UI", 12, "bold")).grid(row=5, column=1, sticky="w", padx=20, pady=5)

        tk.Label(self, text="Uso de Disco:", fg=DRACULA_FG, bg=DRACULA_BG, font=("Segoe UI", 12)).grid(row=6, column=0, sticky="w", padx=20, pady=5)
        self.disk_var = tk.StringVar(value="... %")
        tk.Label(self, textvariable=self.disk_var, fg=DRACULA_YELLOW, bg=DRACULA_BG, font=("Segoe UI", 12, "bold")).grid(row=6, column=1, sticky="w", padx=20, pady=5)

    def fetch_data_loop(self):
        while self.running:
            try:
                command = f"docker exec {CONTAINER_NAME} python3 scripts/monitor_data.py"
                result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
                self.data = json.loads(result.stdout)
            except subprocess.CalledProcessError:
                self.data = {"error": f"Container '{CONTAINER_NAME}' não encontrado ou erro no script."}
            except json.JSONDecodeError:
                self.data = {"error": "Erro ao decodificar a saída do script."}
            
            time.sleep(2)

    def update_gui_loop(self):
        if "error" in self.data:
            self.phase_var.set(self.data["error"])
            self.progress_var.set("---")
        elif self.data:
            self.phase_var.set(self.data.get("pipeline", {}).get("phase", "..."))
            self.progress_var.set(self.data.get("pipeline", {}).get("progress_text", "..."))
            self.cpu_var.set(f'{self.data.get("system", {}).get("cpu_usage", 0):.2f} %')
            self.ram_var.set(f'{self.data.get("system", {}).get("ram_usage", 0):.2f} %')
            self.disk_var.set(f'{self.data.get("system", {}).get("disk_usage", 0):.2f} %')

        self.after(1000, self.update_gui_loop)

    def on_closing(self):
        self.running = False
        self.destroy()

if __name__ == "__main__":
    app = App()
    app.protocol("WM_DELETE_WINDOW", app.on_closing)
    app.mainloop()