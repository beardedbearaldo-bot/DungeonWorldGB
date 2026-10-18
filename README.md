# DungeonWorld

Game Boy game written in Assembly based on the Dungeon World RPG.

## Splash screen ROM

The RGBDS source in `src/main.asm` starts a ROM, converts the image in
`Images/plashscreen.png` to the Game Boy's four-shade palette, and displays it
as a full-screen background. The generated tile and map data is in
`src/splash_data.inc`.

With RGBDS (`rgbasm`, `rgblink`, and `rgbfix`) available on `PATH`, build the
ROM from the repository root in PowerShell:

```powershell
rgbasm -l -I . -o splash.o src\main.asm
rgblink -o DungeonWorld.gb splash.o
rgbfix -v -p 0 -t DUNGEON DungeonWorld.gb
```

To regenerate the assembly data after changing the PNG, install Pillow for the
Python interpreter in use and run:

```powershell
python tools\generate_splash.py
```

The source image must remain 160x144 pixels. The converter maps its luminance
to four shades and deduplicates 8x8 tiles.
