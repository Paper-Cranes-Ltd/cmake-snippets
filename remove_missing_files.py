from pathlib import Path
import shutil
import argparse

def sync_directories(source_dir, target_dir):
    source = Path(source_dir).resolve()
    target = Path(target_dir).resolve()

    if not source.is_dir() or not target.is_dir():
        raise ValueError("Both paths must be valid directories.")

    source_paths = {p.relative_to(source) for p in source.rglob('*')}

    for target_path in target.rglob('*'):
        relative_path = target_path.relative_to(target)

        if relative_path not in source_paths:
            if target_path.is_dir():
                shutil.rmtree(target_path)
                print(f"Deleted directory: {target_path}")
            else:
                target_path.unlink()
                print(f"Deleted file: {target_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Sync two directories by deleting files and directories in the target that do not exist in the source.")
    parser.add_argument("source_dir", help="Path to the source directory.")
    parser.add_argument("target_dir", help="Path to the target directory.")

    args = parser.parse_args()

    try:
        sync_directories(args.source_dir, args.target_dir)
    except ValueError as e:
        print(e)
