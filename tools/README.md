# Tools

This directory contains developer utility scripts for asset preparation and processing.

These scripts are **not part of the production app** — they are used locally during development for tasks like resizing icons and converting images.

## Scripts

| File | Purpose |
|---|---|
| `clean_res.py` | Clean up resource/asset directories |
| `convert_icon.py` | Convert icon formats |
| `create_transparent.py` | Create transparent PNG variants |
| `fix_icon_alpha.py` | Fix alpha channel issues in icons |
| `process_icon.py` | General icon processing pipeline |
| `resize_icons.py` | Resize icons to Android/iOS standard sizes |

## Requirements

All scripts require `Pillow`:
```bash
pip install Pillow
```

## Usage

Run from the project root:
```bash
python tools/resize_icons.py
```
