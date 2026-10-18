# Rift Hub MM2

The Murder Mystery 2 script for Rift Hub, maintained separately from the universal hub.

Run inside Murder Mystery 2:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/copperpoppercms-sys/Rift-Hub-MM2/main/main.lua"))()
```

The script embeds its UI library and uses the existing Lucide icon source. Its default window is 680×430, with smaller mobile bounds. Starting it unloads an open Rift Hub main window.

The universal hub's **Hub → Murder Mystery 2 → Execute** button loads this repository. The main repository also includes a small forwarding loader at `games/mm2.lua`.

Original script and UI credits are preserved in `main.lua`, including the original author [Fleece](https://robloxscripts.com/user/Fleece).

Published as `copperpoppercms-sys/Rift-Hub-MM2`, separate from the universal `Rift-Hub` repository.

## Validation

Install the standalone Luau compiler, then run:

```sh
python tests/check_script.py
```

Alternatively set `LUAU_COMPILE_BIN` to its executable path. These checks compile both the outer script and its embedded UI; MM2 gameplay must be tested inside Roblox.

## Execute snippet

`execute.lua` contains the copy/paste execution snippet for this repository.

## Rift branding

The header uses the user-supplied Rift Hub R emblem from `assets/rift_logo.jpg`. Existing minimized controls use the same emblem. The original JPEG is preserved unchanged; logo cache names include its content hash. If custom images are unavailable, text branding remains usable.

## Buttons and MM2 update

Open **Buttons**, then use **Add** beside any feature to place its floating shortcut. Toggle buttons show ON/OFF and stay synchronized with Modules; action buttons show TAP. Drag to reposition. In Settings, **Lock Button Positions** stops dragging while retaining taps. You can also hide, reset or remove shortcuts. Configs and Auto Save Toggles include button choices, normalized positions, visibility and lock state. Buttons remain usable while the main window is minimized.

**Gun Through Walls** now routes a sheriff/hero trigger to a short visit near the detected murderer, sends a shot request, and returns. **Shoot Murderer** provides that same path as a one-tap action you can pin. It uses one simulation step before the request and one before returning, retains the existing 3.25-second request cooldown, and cancels on character changes or round teleports. It cannot guarantee invisible movement, hit registration or server acceptance. The longer Auto Kill visit also avoids restoring a replacement character to the previous spawn.

Credits include **N0VA_0100** as Rift Hub owner and retain fleece's original script/UI credit. Normalized logo clipping fixes fixed-pixel crop alignment when textures are resized.

Download `docs/MM2_Editor.html` and open it in a browser for the complete editable code, Copy all code and Download .lua. Run `python tests/run_controls.py` with `LUAU_BIN` set to exercise shortcut behavior, configuration, mobile layout, cleanup and the short-shot controller using simulated services. Live MM2 mechanics require in-game testing.
