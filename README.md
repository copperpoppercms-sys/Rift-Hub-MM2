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
