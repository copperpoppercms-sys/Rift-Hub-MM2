local makeQuickShot=(function()
-- INSERT QUICK SHOT
end)()
CFrame.new=function(pos) return CFrame.lookAt(pos,pos+Vector3.new(0,0,-1)) end
local own=localPlayer.Character;local root=own.PrimaryPart
local target=other.Character;local targetRoot=target.PrimaryPart;targetRoot.Position=Vector3.new(40,0,0)
root.AssemblyAngularVelocity=Vector3.new(1,2,3)
local home=root.CFrame;local originalVelocity=root.AssemblyLinearVelocity;local spin=root.AssemblyAngularVelocity
local gun=node("Tool","Gun",own);local remote=node("RemoteEvent","Shoot",gun)
local shots,frames,busy,transition=0,0,false,false
local onFrame,fireError
function remote:FireServer()
    check(root.CFrame~=home,"shot requested after returning home")
    if fireError then error("simulated server request error") end
    shots+=1
end
local ctx={Busy=function() return busy end,SetBusy=function(on) busy=on end,CanShoot=function() return true end,
 Character=function() return localPlayer.Character end,Root=function(char) return char and char.PrimaryPart end,
 Murderer=function() return other end,Gun=function() return gun end,Equip=function() end,Aim=function(char) return char.PrimaryPart.Position end,
 Origin=function() return root.CFrame end,MarkTeleport=function() end,Transitioning=function() return transition end,
 WaitFrame=function() frames+=1;if onFrame then onFrame(frames) end end,Lead=function() return 0.06 end,Fired=function() end}
local shoot=makeQuickShot(ctx)
check(shoot(other) and shots==1 and frames==2,"quick shot did not use exactly two simulation steps")
check(root.CFrame==home and root.AssemblyLinearVelocity==originalVelocity and root.AssemblyAngularVelocity==spin and not busy,"shot did not restore movement")
check(not shoot(localPlayer),"shot targeted someone other than murderer")
busy=true;check(not shoot(other),"concurrent shot accepted");busy=false
fireError=true;check(not shoot(other) and root.CFrame==home and not busy,"failed request did not return or release lock");fireError=false
frames=0;onFrame=function(n) if n==1 then localPlayer.Character=node("Model","Replacement",workspace);localPlayer.Character.PrimaryPart=node("Part","HumanoidRootPart",localPlayer.Character);localPlayer.Character.PrimaryPart.CFrame="NEW SPAWN" end end
check(not shoot(other) and localPlayer.Character.PrimaryPart.CFrame=="NEW SPAWN" and not busy,"shot moved replacement character to old home")
localPlayer.Character=own;root.CFrame=home;frames=0
onFrame=function(n) if n==1 then transition=true;root.CFrame="ROUND TRANSITION" end end
check(not shoot(other) and root.CFrame=="ROUND TRANSITION" and not busy,"shot undid game round teleport")
print("PASS: "..checks.." short-shot checks: request timing, target/busy guards, restoration, request error, respawn and round transitions.")
