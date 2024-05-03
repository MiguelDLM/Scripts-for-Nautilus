#!/usr/bin/env python3

import os
import platform
import subprocess

def contiene_def_parms(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        for line in lines[:12]:
            if 'def parms(d={}):' in line or 'import os' in line or 'path = os.path.join' in line:
                return True
    return False

def execute_program(file):
    if platform.system() == "Linux":
        if os.path.isfile("/usr/bin/gnome-terminal"):
            wine_command = "wine" if os.path.isfile("/usr/bin/wine") else "wine64"
            wine_path = os.path.expanduser("~/.wine/drive_c/Program Files (x86)/Fossils/fossils.exe")
            subprocess.Popen(['gnome-terminal', '-e', f'{wine_command} "{wine_path}" "{file}" --nogui'])
        else:
            print("gnome-terminal is not installed. Please install gnome-terminal to run the script.")
            return

def main():
    # Get the selected files from the environment variable
    selected_files = os.getenv('NEMO_SCRIPT_SELECTED_FILE_PATHS', '').splitlines()

    for file in selected_files:
        if file.endswith(".py") and contiene_def_parms(file):
            execute_program(file)

if __name__ == "__main__":
    main()