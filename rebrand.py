import os
import re

ROOT_DIR = '.'

# Ignores
IGNORE_DIRS = {'.git', 'build', '.dart_tool', 'ios/Pods', 'android/.gradle'}
IGNORE_EXTS = {'.png', '.jpg', '.jpeg', '.gif', '.ttf', '.db', '.gz', '.zip', '.jar', '.class'}

def process_content():
    for root, dirs, files in os.walk(ROOT_DIR):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        
        for file in files:
            ext = os.path.splitext(file)[1].lower()
            if ext in IGNORE_EXTS:
                continue
                
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            except UnicodeDecodeError:
                # Likely a binary file
                continue
                
            # Replace case-sensitive
            new_content = re.sub(r'ExoChess', r'ExoChess', content)
            new_content = re.sub(r'exochess', r'exochess', new_content)
            new_content = re.sub(r'EXOCHESS', r'EXOCHESS', new_content)
            
            if new_content != content:
                print(f"Updating content: {file_path}")
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)

def rename_paths():
    # Do bottom-up traversal for safe renaming
    for root, dirs, files in os.walk(ROOT_DIR, topdown=False):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
        
        # Rename files first
        for name in files:
            if 'exochess' in name.lower():
                new_name = name.replace('exochess', 'exochess').replace('ExoChess', 'ExoChess')
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, new_name)
                print(f"Renaming file: {old_path} -> {new_path}")
                os.rename(old_path, new_path)
                
        # Rename directories
        for name in dirs:
            if 'exochess' in name.lower():
                new_name = name.replace('exochess', 'exochess').replace('ExoChess', 'ExoChess')
                old_path = os.path.join(root, name)
                new_path = os.path.join(root, new_name)
                print(f"Renaming directory: {old_path} -> {new_path}")
                os.rename(old_path, new_path)

if __name__ == '__main__':
    # It solves race conditions by changing content first while paths exist
    process_content()
    rename_paths()
    print("Rebranding complete.")
