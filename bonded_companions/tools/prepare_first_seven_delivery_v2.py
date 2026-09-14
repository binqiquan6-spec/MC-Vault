from __future__ import annotations

from pathlib import Path
from shutil import copyfile

import numpy as np
from PIL import Image, ImageDraw

from prepare_first_seven_item_batch import (
    PALETTES as V1_PALETTES,
    checker_canvas,
    extract_foreground,
    load_font,
    quantize_to_palette,
)


ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "artwork" / "raw" / "first-seven-items-revision-v2"
V1_DIR = ROOT / "artwork" / "review" / "first-seven-items-delivery-v1"
OUTPUT_DIR = ROOT / "artwork" / "review" / "first-seven-items-delivery-v2"

GENERATED_PALETTES: dict[str, list[str]] = {
    "diamond_moonfang_blade": V1_PALETTES["diamond_moonfang_blade"],
    "netherite_moonfang_blade": V1_PALETTES["netherite_moonfang_blade"],
    "snow_golem_leather_wrap": [
        "#160D08", "#2A160D", "#412317", "#5A2E1B", "#773C20", "#985326",
        "#BB7434", "#D79A53", "#5B5248", "#8F8576", "#C7BBA6", "#EEE5D3",
        "#9DA3A4", "#D6D9D6",
    ],
    "snow_golem_iron_brace": [
        "#101214", "#25282A", "#3A3E40", "#555B5E", "#747C80", "#969EA1",
        "#BBC1C2", "#E3E5E2", "#2C180E", "#512A14", "#76431F", "#A26331",
    ],
    "snow_golem_diamond_frost_plate": [
        "#061719", "#0A3033", "#0D4B50", "#116A70", "#168B8F", "#25A9A9",
        "#42C7C3", "#6EDDD7", "#A9EEE7", "#DDF8F3", "#4C8E96", "#ECFEFA",
    ],
    "snow_golem_netherite_core_plate": [
        "#0E0C0F", "#1B161C", "#292029", "#382B36", "#493946", "#5D4B56",
        "#77656B", "#9B8B89", "#B8AEAA", "#3E2D25", "#6E3B16", "#A85B12",
        "#E08318", "#D5D2C8",
    ],
    "iron_golem_leather_padding": [
        "#160D08", "#28140C", "#3B1D10", "#542716", "#71351D", "#8E4825",
        "#AD622E", "#C97D3B", "#DCA15F", "#E3C082", "#303033", "#6B6C6C",
        "#AFB1AE", "#E0E1DB",
    ],
}

UNCHANGED = [
    "target_ledger",
    "spiked_collar",
    "pet_satchel",
    "axolotl_harness",
    "lapis_talisman",
    "iron_moonfang_blade",
    "gold_moonfang_blade",
    "control_core",
    "iron_ram_headpiece",
    "diamond_ram_headpiece",
    "netherite_ram_headpiece",
    "impact_harness",
    "echo_harness",
]

ADOPTED_V1_GOLEM_ART = {
    "iron_golem_iron_reinforcement": "iron_reinforcement",
    "iron_golem_diamond_reinforcement": "diamond_reinforcement",
    "iron_golem_netherite_reinforcement": "netherite_reinforcement",
}

NAMES = {
    "target_ledger": "目标名单册（已通过）",
    "spiked_collar": "带刺项圈（已通过）",
    "pet_satchel": "宠物收纳袋",
    "axolotl_harness": "美西螈背带",
    "lapis_talisman": "青金护符",
    "iron_moonfang_blade": "铁制衔月刃",
    "gold_moonfang_blade": "金制衔月刃",
    "diamond_moonfang_blade": "钻石衔月刃（2 rad）",
    "netherite_moonfang_blade": "下界合金衔月刃（2 rad）",
    "control_core": "控制核心",
    "snow_golem_leather_wrap": "雪傀儡·保温皮套",
    "snow_golem_iron_brace": "雪傀儡·铁制护架",
    "snow_golem_diamond_frost_plate": "雪傀儡·钻石凝霜甲片",
    "snow_golem_netherite_core_plate": "雪傀儡·下界合金熔芯甲片",
    "iron_golem_leather_padding": "铁傀儡·皮革缓冲层",
    "iron_golem_iron_reinforcement": "铁傀儡·铁质补强板",
    "iron_golem_diamond_reinforcement": "铁傀儡·钻石强化板",
    "iron_golem_netherite_reinforcement": "铁傀儡·下界合金强化板",
    "iron_ram_headpiece": "铁冲角",
    "diamond_ram_headpiece": "钻石冲角",
    "netherite_ram_headpiece": "下界合金冲角",
    "impact_harness": "缓冲背带",
    "echo_harness": "回声背带",
}

SHEET_ROWS: list[list[str | None]] = [
    ["target_ledger", "spiked_collar", "pet_satchel", "axolotl_harness", "lapis_talisman"],
    ["iron_moonfang_blade", "gold_moonfang_blade", "diamond_moonfang_blade", "netherite_moonfang_blade", "control_core"],
    ["snow_golem_leather_wrap", "snow_golem_iron_brace", "snow_golem_diamond_frost_plate", "snow_golem_netherite_core_plate", None],
    ["iron_golem_leather_padding", "iron_golem_iron_reinforcement", "iron_golem_diamond_reinforcement", "iron_golem_netherite_reinforcement", None],
    ["iron_ram_headpiece", "diamond_ram_headpiece", "netherite_ram_headpiece", "impact_harness", "echo_harness"],
]


def output_path(name: str) -> Path:
    return OUTPUT_DIR / f"{name}_64x64_v2.png"


def prepare_generated(name: str, palette: list[str]) -> None:
    with Image.open(RAW_DIR / f"{name}.png") as source:
        foreground = extract_foreground(source)
        sprite = quantize_to_palette(foreground, palette)
    sprite.save(output_path(name))


def copy_v1(source_name: str, output_name: str) -> None:
    copyfile(V1_DIR / f"{source_name}_64x64_v1.png", output_path(output_name))


def normalize_moonfang_masks() -> None:
    diamond_path = output_path("diamond_moonfang_blade")
    netherite_path = output_path("netherite_moonfang_blade")
    with Image.open(diamond_path) as diamond_source:
        diamond_alpha = np.asarray(diamond_source.convert("RGBA"), dtype=np.uint8)[:, :, 3]
    with Image.open(netherite_path) as netherite_source:
        netherite = np.asarray(netherite_source.convert("RGBA"), dtype=np.uint8).copy()

    target_visible = diamond_alpha == 255
    newly_visible = target_visible & (netherite[:, :, 3] == 0)
    netherite[newly_visible, :3] = np.array([16, 13, 16], dtype=np.uint8)
    netherite[~target_visible] = np.array([0, 0, 0, 0], dtype=np.uint8)
    netherite[:, :, 3] = diamond_alpha
    Image.fromarray(netherite, mode="RGBA").save(netherite_path)


def validate_sprite(path: Path) -> None:
    with Image.open(path) as image:
        rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    if rgba.shape != (64, 64, 4):
        raise ValueError(f"Unexpected size for {path.name}: {rgba.shape}")
    alpha_values = set(np.unique(rgba[:, :, 3]).tolist())
    if not alpha_values.issubset({0, 255}) or 255 not in alpha_values:
        raise ValueError(f"Invalid alpha for {path.name}: {sorted(alpha_values)}")
    visible = rgba[:, :, 3] == 255
    color_count = len(np.unique(rgba[visible, :3], axis=0))
    if color_count > 16:
        raise ValueError(f"Too many opaque colors for {path.name}: {color_count}")


def save_contact_sheet() -> None:
    cell_width = 230
    cell_height = 232
    sheet = Image.new("RGB", (cell_width * 5, cell_height * 5), "#152126")
    draw = ImageDraw.Draw(sheet)
    font = load_font(18)

    for row, entries in enumerate(SHEET_ROWS):
        for column, name in enumerate(entries):
            if name is None:
                continue
            left = column * cell_width
            top = row * cell_height
            with Image.open(output_path(name)) as source:
                sprite = source.convert("RGBA")
            tile = checker_canvas((192, 192), 12)
            scaled = sprite.resize((192, 192), Image.Resampling.NEAREST)
            tile.paste(scaled, (0, 0), scaled)
            sheet.paste(tile, (left + 19, top + 8))
            label = NAMES[name]
            bounds = draw.textbbox((0, 0), label, font=font)
            text_width = bounds[2] - bounds[0]
            draw.text((left + (cell_width - text_width) // 2, top + 204), label, fill="#E8F2F3", font=font)

    sheet.save(OUTPUT_DIR / "contact_sheet.png")


def main() -> None:
    if OUTPUT_DIR.exists():
        raise FileExistsError(f"Refusing to overwrite existing delivery: {OUTPUT_DIR}")
    OUTPUT_DIR.mkdir(parents=True)

    for name in UNCHANGED:
        copy_v1(name, name)
    for name, palette in GENERATED_PALETTES.items():
        prepare_generated(name, palette)
    for output_name, source_name in ADOPTED_V1_GOLEM_ART.items():
        copy_v1(source_name, output_name)
    normalize_moonfang_masks()

    paths = sorted(OUTPUT_DIR.glob("*_64x64_v2.png"))
    if len(paths) != 23:
        raise ValueError(f"Expected 23 sprites, found {len(paths)}")
    for path in paths:
        validate_sprite(path)
    save_contact_sheet()
    print(f"Prepared and validated {len(paths)} sprites in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
