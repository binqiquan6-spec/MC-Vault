from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
INPUT_DIR = ROOT / "artwork" / "raw" / "first-seven-items"
OUTPUT_DIR = ROOT / "artwork" / "review" / "first-seven-items"

PALETTES: dict[str, list[str]] = {
    "pet_satchel": [
        "#160D08", "#28150C", "#3B1F10", "#542A13", "#6E3719", "#88461F",
        "#A96027", "#C27A36", "#E0AA62", "#F0CB82", "#6B4A0A", "#A97808",
        "#D6A70A", "#F4D552",
    ],
    "axolotl_harness": [
        "#071617", "#0C2928", "#123D39", "#18544B", "#216B5C", "#2D826E",
        "#419982", "#64B59A", "#8AD0B7", "#B4E1D0", "#252B2C", "#515B5C",
        "#858F8F", "#C0C8C6",
    ],
    "lapis_talisman": [
        "#090D18", "#10182D", "#132852", "#173B7A", "#1D53A2", "#2D70C6",
        "#55A1E0", "#9ACAE9", "#4B3108", "#75500D", "#A57818", "#CFA139",
        "#E6C36C", "#2B1A10",
    ],
    "iron_moonfang_blade": [
        "#111315", "#24282B", "#3B4145", "#596166", "#7A8388", "#A3AAAD",
        "#CCD0D0", "#ECEDEA", "#21130C", "#3C2010", "#603318", "#8A4E24",
    ],
    "gold_moonfang_blade": [
        "#17110A", "#35240A", "#5B3B08", "#865A08", "#B17C0B", "#D9A418",
        "#F0C743", "#FFE887", "#23272A", "#4C5356", "#28150C", "#542A13",
        "#85461E",
    ],
    "diamond_moonfang_blade": [
        "#07191A", "#0B3335", "#0F5153", "#147374", "#1A9693", "#30B9B2",
        "#68D8CF", "#B4F0E8", "#24292B", "#50585B", "#27150D", "#542B16",
        "#86502A",
    ],
    "netherite_moonfang_blade": [
        "#100D10", "#1D171D", "#2A202A", "#3A2A38", "#4C3647", "#604957",
        "#7B686B", "#A2938B", "#3B1B20", "#663038", "#23140D", "#4C2816",
    ],
    "control_core": [
        "#0A1012", "#162126", "#243238", "#39494D", "#59676A", "#0B2E32",
        "#11515A", "#1C7881", "#43A9AD", "#85D2D0", "#C5ECE6", "#F0F3E9",
        "#73500D", "#B68A25", "#E0BD58",
    ],
    "leather_reinforcement": [
        "#160D08", "#28140C", "#3C1D11", "#57271A", "#713326", "#8E4730",
        "#A85E3D", "#C47C4D", "#D8A066", "#E7C08A", "#25201C", "#5A5047",
    ],
    "iron_reinforcement": [
        "#111315", "#24282B", "#3C4246", "#596166", "#7B8387", "#9EA5A7",
        "#C7CBCA", "#E6E7E3", "#20130D", "#452617", "#704125", "#A06A3A",
    ],
    "diamond_reinforcement": [
        "#061719", "#0A3033", "#0E4C50", "#126A6E", "#168B8D", "#28AAA7",
        "#4CCBC3", "#83E2D8", "#B9F2E9", "#17353A", "#2A555B", "#587A7C",
    ],
    "netherite_reinforcement": [
        "#0E0C0F", "#1B161C", "#292029", "#382A36", "#493846", "#5C4A55",
        "#74636A", "#958689", "#B5AAA2", "#401A20", "#672833", "#8B3B43",
    ],
    "iron_ram_headpiece": [
        "#171515", "#292B2C", "#454A4D", "#666D70", "#8F9697", "#BBC0BE",
        "#E1E1DA", "#F1EAD8", "#CFC4A9", "#A39475", "#26150C", "#4D2A16",
        "#774722",
    ],
    "diamond_ram_headpiece": [
        "#071719", "#0C3436", "#115557", "#167A7A", "#1FA09C", "#3BC2BA",
        "#74DED4", "#B4F1E8", "#EFE7D3", "#C9BFA4", "#97886C", "#25140C",
        "#4E2A16", "#7B4722",
    ],
    "netherite_ram_headpiece": [
        "#0E0C0F", "#1B161C", "#2A202A", "#3B2B38", "#4D3948", "#62505B",
        "#7E6B70", "#A0928C", "#EDE5D2", "#C8BDA3", "#96876B", "#3F1A20",
        "#25140D", "#502A17",
    ],
    "impact_harness": [
        "#160D08", "#2A170D", "#422515", "#60391F", "#83532E", "#55472F",
        "#786744", "#9D8A5E", "#C0AD7D", "#DECFA3", "#292C2D", "#62686A",
        "#A2A7A5", "#85401B", "#B65E24",
    ],
    "echo_harness": [
        "#061117", "#081E2B", "#0B3044", "#0D4660", "#105F78", "#127B8F",
        "#1C98A7", "#3AB7BC", "#72D0CA", "#A4E3D8", "#153C3A", "#23635B",
        "#3B8877", "#72B49A",
    ],
}

CHINESE_NAMES = {
    "target_ledger": "目标名单册（已通过）",
    "spiked_collar": "带刺项圈（已通过）",
    "pet_satchel": "宠物收纳袋",
    "axolotl_harness": "美西螈背带",
    "lapis_talisman": "青金护符",
    "iron_moonfang_blade": "铁制衔月刃",
    "gold_moonfang_blade": "金制衔月刃",
    "diamond_moonfang_blade": "钻石衔月刃",
    "netherite_moonfang_blade": "下界合金衔月刃",
    "control_core": "控制核心",
    "leather_reinforcement": "皮革装甲补强",
    "iron_reinforcement": "铁装甲补强",
    "diamond_reinforcement": "钻石装甲补强",
    "netherite_reinforcement": "下界合金装甲补强",
    "iron_ram_headpiece": "铁冲角",
    "diamond_ram_headpiece": "钻石冲角",
    "netherite_ram_headpiece": "下界合金冲角",
    "impact_harness": "缓冲背带",
    "echo_harness": "回声背带",
}


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def connected_external_background(candidate: np.ndarray) -> np.ndarray:
    height, width = candidate.shape
    external = np.zeros(candidate.shape, dtype=bool)
    queue: deque[tuple[int, int]] = deque()

    def add(y: int, x: int) -> None:
        if candidate[y, x] and not external[y, x]:
            external[y, x] = True
            queue.append((y, x))

    for x in range(width):
        add(0, x)
        add(height - 1, x)
    for y in range(height):
        add(y, 0)
        add(y, width - 1)

    while queue:
        y, x = queue.popleft()
        if y > 0:
            add(y - 1, x)
        if y + 1 < height:
            add(y + 1, x)
        if x > 0:
            add(y, x - 1)
        if x + 1 < width:
            add(y, x + 1)
    return external


def enclosed_checker_components(candidate: np.ndarray, external: np.ndarray, lightness: np.ndarray) -> np.ndarray:
    remaining = candidate & ~external
    visited = np.zeros(remaining.shape, dtype=bool)
    remove = np.zeros(remaining.shape, dtype=bool)
    height, width = remaining.shape

    for start_y, start_x in zip(*np.nonzero(remaining)):
        if visited[start_y, start_x]:
            continue
        queue: deque[tuple[int, int]] = deque([(int(start_y), int(start_x))])
        visited[start_y, start_x] = True
        component: list[tuple[int, int]] = []
        while queue:
            y, x = queue.popleft()
            component.append((y, x))
            for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if 0 <= next_y < height and 0 <= next_x < width:
                    if remaining[next_y, next_x] and not visited[next_y, next_x]:
                        visited[next_y, next_x] = True
                        queue.append((next_y, next_x))

        if len(component) < 128:
            continue
        ys = np.fromiter((point[0] for point in component), dtype=np.int32)
        xs = np.fromiter((point[1] for point in component), dtype=np.int32)
        values = lightness[ys, xs]
        bright_fraction = float(np.mean(values >= 238))
        middle_fraction = float(np.mean((values >= 185) & (values <= 232)))
        if bright_fraction >= 0.08 and middle_fraction >= 0.08 and float(np.std(values)) >= 10.0:
            remove[ys, xs] = True
    return remove


def extract_foreground(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA"), dtype=np.uint8)
    rgb = rgba[:, :, :3]
    alpha = rgba[:, :, 3]
    minimum = rgb.min(axis=2)
    maximum = rgb.max(axis=2)
    chroma = maximum.astype(np.int16) - minimum.astype(np.int16)
    lightness = rgb.mean(axis=2)
    candidate = (alpha < 128) | ((minimum >= 170) & (chroma <= 18))
    external = connected_external_background(candidate)
    enclosed = enclosed_checker_components(candidate, external, lightness)
    background = external | enclosed | (alpha < 128)

    result = rgba.copy()
    result[background] = np.array([0, 0, 0, 0], dtype=np.uint8)
    result[~background, 3] = 255
    return Image.fromarray(result, mode="RGBA")


def quantize_to_palette(image: Image.Image, palette_hex: list[str]) -> Image.Image:
    alpha = np.asarray(image.getchannel("A"), dtype=np.uint8)
    bounds = Image.fromarray(alpha, mode="L").getbbox()
    if bounds is None:
        raise ValueError("No visible foreground remained after background extraction")

    cropped = image.crop(bounds)
    width, height = cropped.size
    scale = min(60 / width, 60 / height)
    target_size = (max(1, round(width * scale)), max(1, round(height * scale)))
    resized = cropped.resize(target_size, Image.Resampling.LANCZOS)

    data = np.asarray(resized, dtype=np.uint8)
    visible = data[:, :, 3] >= 128
    palette = np.asarray([hex_to_rgb(value) for value in palette_hex], dtype=np.int16)
    source_rgb = data[:, :, :3].astype(np.int16)
    difference = source_rgb[:, :, None, :] - palette[None, None, :, :]
    weights = np.asarray([0.30, 0.59, 0.11], dtype=np.float32)
    distance = np.sum(difference.astype(np.float32) ** 2 * weights, axis=3)
    nearest = palette[np.argmin(distance, axis=2)].astype(np.uint8)

    output = np.zeros((64, 64, 4), dtype=np.uint8)
    offset_x = (64 - target_size[0]) // 2
    offset_y = (64 - target_size[1]) // 2
    region = output[offset_y : offset_y + target_size[1], offset_x : offset_x + target_size[0]]
    region[visible, :3] = nearest[visible]
    region[visible, 3] = 255
    return Image.fromarray(output, mode="RGBA")


def checker_canvas(size: tuple[int, int], cell: int = 12) -> Image.Image:
    canvas = Image.new("RGB", size, "#D9EEF2")
    draw = ImageDraw.Draw(canvas)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if ((x // cell) + (y // cell)) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill="#BBDDE4")
    return canvas


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in (Path("C:/Windows/Fonts/msyh.ttc"), Path("C:/Windows/Fonts/simhei.ttf")):
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def save_contact_sheet(processed: dict[str, Image.Image], version: str = "v1") -> None:
    entries: list[tuple[str, Image.Image]] = [
        ("target_ledger", Image.open(ROOT / "artwork" / "review" / "target_ledger_64x64_v1.png").convert("RGBA")),
        ("spiked_collar", Image.open(ROOT / "artwork" / "approved-concepts" / "spiked_collar_64x64_v1.png").convert("RGBA")),
    ]
    for name in PALETTES:
        if name in processed:
            entries.append((name, processed[name]))
        else:
            fallback = OUTPUT_DIR / f"{name}_64x64_v1.png"
            entries.append((name, Image.open(fallback).convert("RGBA")))

    columns = 5
    cell_width = 220
    cell_height = 230
    rows = (len(entries) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * cell_width, rows * cell_height), "#152126")
    draw = ImageDraw.Draw(sheet)
    font = load_font(20)
    for index, (name, sprite) in enumerate(entries):
        column = index % columns
        row = index // columns
        left = column * cell_width
        top = row * cell_height
        tile = checker_canvas((192, 192), 12)
        scaled = sprite.resize((192, 192), Image.Resampling.NEAREST)
        tile.paste(scaled, (0, 0), scaled)
        sheet.paste(tile, (left + 14, top + 8))
        label = CHINESE_NAMES[name]
        text_bounds = draw.textbbox((0, 0), label, font=font)
        text_width = text_bounds[2] - text_bounds[0]
        draw.text((left + (cell_width - text_width) // 2, top + 202), label, fill="#E8F2F3", font=font)

    path = OUTPUT_DIR / f"contact_sheet_{version}.png"
    if path.exists():
        raise FileExistsError(f"Refusing to overwrite existing contact sheet: {path}")
    sheet.save(path)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    processed: dict[str, Image.Image] = {}
    for name, palette in PALETTES.items():
        input_path = INPUT_DIR / f"{name}.png"
        output_path = OUTPUT_DIR / f"{name}_64x64_v1.png"
        if output_path.exists():
            raise FileExistsError(f"Refusing to overwrite existing texture: {output_path}")
        with Image.open(input_path) as source:
            foreground = extract_foreground(source)
            sprite = quantize_to_palette(foreground, palette)
        sprite.save(output_path)
        processed[name] = sprite

    save_contact_sheet(processed)
    print(f"Prepared {len(processed)} textures in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
