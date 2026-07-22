#!/usr/bin/env python3
import subprocess
import shutil
import sys
from pathlib import Path


def find_chromium() -> str:
    for name in ("chromium", "chromium-browser", "google-chrome"):
        path = shutil.which(name)
        if path:
            return path
    print("Error: Chromium not found. Install chromium or google-chrome.", file=sys.stderr)
    sys.exit(1)


def build_pdf(html_path: str, pdf_path: str) -> None:
    html_file = Path(html_path).resolve()
    pdf_file = Path(pdf_path).resolve()

    if not html_file.exists():
        print(f"Error: {html_file} not found", file=sys.stderr)
        sys.exit(1)

    chromium = find_chromium()
    cmd = [
        chromium,
        "--headless",
        "--disable-gpu",
        "--no-sandbox",
        "--no-pdf-header-footer",
        "--print-to-pdf=" + str(pdf_file),
        f"file://{html_file}",
    ]
    subprocess.run(cmd, check=True, capture_output=True)
    print(f"Generated {pdf_file}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.html> <output.pdf>", file=sys.stderr)
        sys.exit(1)
    build_pdf(sys.argv[1], sys.argv[2])
