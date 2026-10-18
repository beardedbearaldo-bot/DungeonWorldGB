from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
IMAGE_PATH = ROOT / "Images" / "plashscreen.png"
OUTPUT_PATH = ROOT / "src" / "splash_data.inc"
WIDTH = 160
HEIGHT = 144
TILE_SIZE = 8
SHADE_THRESHOLDS = (48, 112, 176)


def main() -> None:
    image = Image.open(IMAGE_PATH).convert("RGB")
    if image.size != (WIDTH, HEIGHT):
        raise ValueError(f"Expected a {WIDTH}x{HEIGHT} image, got {image.size}")

    tiles: list[bytes] = []
    tile_ids: dict[bytes, int] = {}
    tilemap: list[int] = []

    for tile_y in range(0, HEIGHT, TILE_SIZE):
        for tile_x in range(0, WIDTH, TILE_SIZE):
            tile_data = bytearray()
            for y in range(tile_y, tile_y + TILE_SIZE):
                low_plane = 0
                high_plane = 0
                for x in range(tile_x, tile_x + TILE_SIZE):
                    red, green, blue = image.getpixel((x, y))
                    luminance = (299 * red + 587 * green + 114 * blue) // 1000
                    shade = sum(luminance >= threshold for threshold in SHADE_THRESHOLDS)
                    bit = 7 - (x - tile_x)
                    low_plane |= (shade & 1) << bit
                    high_plane |= ((shade >> 1) & 1) << bit
                tile_data.extend((low_plane, high_plane))

            encoded_tile = bytes(tile_data)
            tile_id = tile_ids.get(encoded_tile)
            if tile_id is None:
                tile_id = len(tiles)
                if tile_id >= 256:
                    raise ValueError("The image needs more than 256 unique Game Boy tiles")
                tile_ids[encoded_tile] = tile_id
                tiles.append(encoded_tile)
            tilemap.append(tile_id)

    lines = [
        "; Generated from Images/plashscreen.png by tools/generate_splash.py.",
        "SplashTiles:",
    ]
    tile_bytes = b"".join(tiles)
    for offset in range(0, len(tile_bytes), 16):
        lines.append("    db " + ", ".join(f"${byte:02X}" for byte in tile_bytes[offset : offset + 16]))
    lines.extend(("SplashTilesEnd:", "SplashTilemap:"))
    for offset in range(0, len(tilemap), 16):
        values = tilemap[offset : offset + 16]
        lines.append("    db " + ", ".join(f"${tile_id:02X}" for tile_id in values))
    lines.append("SplashTilemapEnd:")
    OUTPUT_PATH.write_text("\n".join(lines) + "\n", encoding="ascii")
    print(f"Wrote {len(tiles)} tiles and {len(tilemap)} tile-map entries to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
