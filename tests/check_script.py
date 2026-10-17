"""Compile the standalone script and embedded UI without executing Roblox game logic."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
compiler = os.environ.get('LUAU_COMPILE_BIN') or shutil.which('luau-compile')
if not compiler:
    raise SystemExit('Install Luau or set LUAU_COMPILE_BIN.')
source = (root / 'main.lua').read_text()
ui = source.split('local MONOUI_SOURCE = [==[', 1)[1].split(']==]', 1)[0]
assert 'Title = "Rift Hub", Version = "MM2", Width = 680, Height = 430' in source
assert 'LogoUrl = "https://raw.githubusercontent.com/fleecewtf/' not in source
assert 'local TEXT_SCALE = MOBILE and 1.10 or 1.0' in ui
assert 'self.midIcons.Visible = self.root.AbsoluteSize.X >= 520' in ui
assert 'https://robloxscripts.com/user/Fleece' in source, 'original credits removed'
for mobile, x, y, inset in [(False, 1920, 1080, 36), (True, 844, 390, 36), (True, 390, 844, 36)]:
    fraction = .86 if mobile else .92
    width = max(240, int(min(680, (x - 24) * fraction)))
    height = max(200, int(min(430, (y - inset - 24) * fraction)))
    assert width < x and height < y - inset
with tempfile.TemporaryDirectory() as directory:
    embedded = Path(directory) / 'mm2_ui.luau'
    embedded.write_text(ui)
    for file in [root / 'main.lua', embedded]:
        result = subprocess.run([compiler, '--null', str(file)], text=True, capture_output=True)
        if result.returncode:
            raise SystemExit(result.stdout + result.stderr)
print('PASS: standalone and embedded UI compilation; compact defaults and original credits preserved.')
