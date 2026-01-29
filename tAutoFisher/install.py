import PyInstaller.__main__

import sys
from pathlib import Path

HERE = Path(__file__).parent.absolute()
path_to_main = str(HERE / "__main__.py")

def main():
    PyInstaller.__main__.run([
        path_to_main,
        "-n",
        "tAutoFisher"
        # other pyinstaller options... 
    ])

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('[!] Exiting... (SIGINT)')
        sys.exit(1)
    except EOFError:
        print("[!] Exiting... (EOF)")
        sys.exit(1)
