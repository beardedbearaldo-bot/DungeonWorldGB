DEF rLCDC EQU $FF40
DEF rBGP  EQU $FF47
DEF rLY   EQU $FF44
DEF rSCY  EQU $FF42
DEF rSCX  EQU $FF43
DEF VRAM_START EQU $8000
DEF BG_MAP     EQU $9800

SECTION "Cartridge Header", ROM0[$0100]
    nop
    jp Start
    ds $0150 - @, 0

SECTION "Boot", ROM0[$0150]
Start:
    di
    ld sp, $FFFE

    ld a, [rLCDC]
    bit 7, a
    jr z, LCDOff

WaitForVBlank:
    ld a, [rLY]
    cp 144
    jr c, WaitForVBlank

LCDOff:
    xor a
    ld [rLCDC], a

    ld hl, SplashTiles
    ld de, VRAM_START
    ld bc, SplashTilesEnd - SplashTiles
    call CopyBytes

    ld hl, SplashTilemap
    ld de, BG_MAP
    ld bc, SplashTilemapEnd - SplashTilemap
    call CopyBytes

    xor a
    ld [rSCY], a
    ld [rSCX], a
    ld a, %00011011
    ld [rBGP], a
    ld a, %10010001
    ld [rLCDC], a

Idle:
    jr Idle

CopyBytes:
    ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, CopyBytes
    ret

INCLUDE "src/splash_data.inc"
