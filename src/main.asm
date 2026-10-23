INCLUDE "src/hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jr c, WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data into VRAM Block 1 ($8000-$8FFF)
	ld de, Tiles
	ld hl, $8000       ; CHANGED: Using $8000 establishes a natural 0-255 tile sequence
	ld bc, Tiles.End - Tiles
CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jr nz, CopyTiles

	; Copy the tilemap into BG Map 0 ($9800-$9BFF)
	ld de, Tilemap
	ld hl, $9800
	ld b, 18           ; 18 rows of 20 tiles; BG map rows are 32 tiles wide
CopyTilemapRow:
	ld c, 20
CopyTilemapTile:
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, CopyTilemapTile
	ld a, l
	add a, 12
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry:
	dec b
	jr nz, CopyTilemapRow

	; During the frame layout, initialize your display palettes first
	ld a, %11100100
	ld [rBGP], a

	; Turn the LCD on
	; ADDED: LCDC_BG_8000 matches our change above so tile indices map correctly
	ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK01
	ld [rLCDC], a

Done:
	jr Done


SECTION "Tile data", ROM0

Tiles:
	INCBIN "Images/Splashscreen/tiles.2bpp"
.End:

SECTION "Tilemap", ROM0

Tilemap:
	INCBIN "Images/Splashscreen/tilemap.bin"
.End:
