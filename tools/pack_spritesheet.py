#!/usr/bin/env python3
"""Pack a folder of PNG frames into a simple grid spritesheet.

This utility script was AI-generated for this project. It is only used as a
file-processing helper: it copies existing PNG frames into a larger PNG grid.
It does not draw, repaint, reinterpret, generate, or otherwise artistically
alter the source images.

This script is not used for game logic or gameplay behavior. It is a build/art
pipeline convenience tool only, and the project author excludes this
AI-generated utility file itself from any copyright claims made over the
human-created game, artwork, design, writing, music, or other project assets.

Example usage:
    python tools/pack_spritesheet.py Assets/images/this_is_bilo_frames \
        Assets/images/this_is_bilo_backwards_sheet.png -c 16 --order backward
"""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

from PIL import Image


def natural_key(path: Path) -> list[object]:
    parts = re.split(r"(\d+)", path.stem.lower())
    return [int(part) if part.isdigit() else part for part in parts]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Pack PNG frames into a transparent spritesheet."
    )
    parser.add_argument("input_dir", type=Path, help="Directory containing PNG frames.")
    parser.add_argument("output", type=Path, help="Output spritesheet PNG path.")
    parser.add_argument(
        "-c",
        "--columns",
        type=int,
        default=0,
        help="Number of columns. Defaults to a roughly square sheet.",
    )
    parser.add_argument(
        "--cell-width",
        type=int,
        default=0,
        help="Cell width. Defaults to the widest frame.",
    )
    parser.add_argument(
        "--cell-height",
        type=int,
        default=0,
        help="Cell height. Defaults to the tallest frame.",
    )
    parser.add_argument(
        "--padding",
        type=int,
        default=0,
        help="Pixels between frames.",
    )
    parser.add_argument(
        "--margin",
        type=int,
        default=0,
        help="Pixels around the outside edge.",
    )
    parser.add_argument(
        "--align",
        choices=("top-left", "center", "bottom-center"),
        default="top-left",
        help="How to place smaller frames inside larger cells.",
    )
    parser.add_argument(
        "--order",
        choices=("forward", "backward"),
        default="forward",
        help="Frame order after natural filename sorting.",
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=None,
        help="Optional JSON atlas metadata output path.",
    )
    return parser.parse_args()


def frame_offset(
    frame: Image.Image, cell_width: int, cell_height: int, align: str
) -> tuple[int, int]:
    if align == "center":
        return ((cell_width - frame.width) // 2, (cell_height - frame.height) // 2)

    if align == "bottom-center":
        return ((cell_width - frame.width) // 2, cell_height - frame.height)

    return (0, 0)


def main() -> None:
    args = parse_args()
    files = sorted(args.input_dir.glob("*.png"), key=natural_key)
    if args.order == "backward":
        files.reverse()

    if not files:
        raise SystemExit(f"No PNG files found in {args.input_dir}")

    frames = [(path, Image.open(path).convert("RGBA")) for path in files]
    cell_width = args.cell_width or max(frame.width for _, frame in frames)
    cell_height = args.cell_height or max(frame.height for _, frame in frames)

    for path, frame in frames:
        if frame.width > cell_width or frame.height > cell_height:
            raise SystemExit(
                f"{path} is {frame.width}x{frame.height}, larger than "
                f"cell size {cell_width}x{cell_height}."
            )

    columns = args.columns or math.ceil(math.sqrt(len(frames)))
    if columns < 1:
        raise SystemExit("Columns must be at least 1.")

    rows = math.ceil(len(frames) / columns)
    width = args.margin * 2 + columns * cell_width + (columns - 1) * args.padding
    height = args.margin * 2 + rows * cell_height + (rows - 1) * args.padding
    sheet = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    atlas = {
        "image": str(args.output),
        "cell_width": cell_width,
        "cell_height": cell_height,
        "columns": columns,
        "rows": rows,
        "frames": [],
    }

    for index, (path, frame) in enumerate(frames):
        col = index % columns
        row = index // columns
        cell_x = args.margin + col * (cell_width + args.padding)
        cell_y = args.margin + row * (cell_height + args.padding)
        offset_x, offset_y = frame_offset(frame, cell_width, cell_height, args.align)
        x = cell_x + offset_x
        y = cell_y + offset_y

        sheet.alpha_composite(frame, (x, y))
        atlas["frames"].append(
            {
                "name": path.stem,
                "index": index,
                "cell": {"x": cell_x, "y": cell_y, "w": cell_width, "h": cell_height},
                "source": {"w": frame.width, "h": frame.height},
                "offset": {"x": offset_x, "y": offset_y},
            }
        )

    args.output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output)

    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(atlas, indent=2) + "\n", encoding="utf-8")

    print(
        f"Packed {len(frames)} frames into {args.output} "
        f"({columns}x{rows}, cells {cell_width}x{cell_height})."
    )


if __name__ == "__main__":
    main()
