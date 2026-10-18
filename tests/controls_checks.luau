local makeButtons=(function()
-- INSERT BUTTONS
end)()
local gui=node("ScreenGui","TestShortcuts",coreGui)
local m={name="Fly",display="Fly",state=false,action=false}
function m:Get() return self.state end
function m:Toggle() self.state=not self.state end
local actions=0
local action={name="Grab Gun Now",action=true,callback=function() actions+=1 end}
local changes=0
local buttons=makeButtons({Gui=gui,Modules=function() return {m,action} end,Changed=function() changes+=1 end})
check(buttons.Pin(m),"could not pin real module")
check(not buttons.Pin(m) and not buttons.Pin({name="fake"}),"duplicate or foreign module pinned")
local entry=buttons.Entries[m]
entry.Button.Activated:Fire();check(m.state and entry.State.Text=="ON","shortcut did not toggle the actual module")
m.state=false;buttons.Sync();check(entry.State.Text=="OFF","external menu changes did not sync")
buttons.SetLocked(true)
local press={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(300,300,0)}
entry.Button.InputBegan:Fire(press);press.Position=Vector3.new(500,400,0);input.InputChanged:Fire(press)
local locked=entry.X;entry.Button.Activated:Fire()
check(m.state and entry.X==locked,"locking disabled clicking or allowed dragging")
buttons.SetLocked(false)
press.Position=Vector3.new(300,300,0);entry.Button.InputBegan:Fire(press)
press.Position=Vector3.new(-999,9999,0);input.InputChanged:Fire(press)
check(entry.X==0 and entry.Y==1,"drag did not clamp to viewport")
entry.Button.Activated:Fire();check(m.state,"drag was treated as a click")
input.InputEnded:Fire(press);entry.Button.Activated:Fire();check(m.state,"release after dragging toggled feature")
buttons.Pin(action);buttons.Entries[action].Button.Activated:Fire();flushSpawn()
check(actions==1 and buttons.Entries[action].State.Text=="TAP","action button was treated as toggle")
local saved=buttons.Serialize();check(saved.Pins.Fly.X==0 and saved.Pins.Fly.Y==1,"positions missing from config")
local previousChanges=changes;buttons.Restore(saved)
check(changes==previousChanges and buttons.IsPinned(m),"config restoration triggered partial autosaves")
local newEntry=buttons.Entries[m]
camera.ViewportSize=Vector2.new(390,844);buttons.Sync()
check(newEntry.Button.Position.X.Offset>=8 and newEntry.Button.Position.Y.Offset+44<=836,"portrait buttons outside screen")
buttons.Restore({Pins={Fly={X=0/0,Y=999}},Locked=true,Visible=true})
check(buttons.Entries[m].X==buttons.Entries[m].X and buttons.Locked,"invalid saved positions corrupted layout")
buttons.SetVisible(false);check(not buttons.Entries[m].Button.Visible,"hide buttons ignored")
buttons.SetVisible(true);buttons.Unpin(m);check(m.state,"removing shortcut disabled underlying feature")
buttons.Pin(m);buttons.ResetPositions();gui:Destroy()
check(next(buttons.Entries)==nil and not buttons.Pin(m),"destroyed UI left active shortcuts")
local leaks=0
for _,event in ipairs(allSignals) do for _,c in ipairs(event.handlers) do if c.Connected then leaks+=1 end end end
check(leaks==0,"shortcut controller leaked connections")
print("PASS: "..checks.." shortcut checks: real toggles, actions, lock, drag suppression, bounds, config restore, mobile resizing and teardown.")
