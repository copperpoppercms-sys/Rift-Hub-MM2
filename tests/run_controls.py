"""Run the actual embedded shortcut and short-shot controllers using simulated Roblox services."""
from pathlib import Path
import os,shutil,subprocess,tempfile
root=Path(__file__).resolve().parents[1]
luau=os.environ.get('LUAU_BIN') or shutil.which('luau')
if not luau: raise SystemExit('Set LUAU_BIN to a native Luau executable.')
source=(root/'main.lua').read_text()
for filename,marker in [('FloatingButtons.lua','local MakeFloatingButtons=(function()\n'),('QuickShot.lua','local MakeQuickShot=(function()\n')]:
    controller=(root/'src'/filename).read_text()
    assert marker+controller+'end)()' in source,'embedded controller differs from tested source'
with tempfile.TemporaryDirectory() as directory:
    for fixture,controller,marker in [('controls_checks.luau','FloatingButtons.lua','-- INSERT BUTTONS'),('quick_shot_checks.luau','QuickShot.lua','-- INSERT QUICK SHOT')]:
        text=(root/'tests/mock_client.luau').read_text()+(root/'tests'/fixture).read_text().replace(marker,(root/'src'/controller).read_text())
        path=Path(directory)/fixture;path.write_text(text);subprocess.run([luau,str(path)],check=True)
