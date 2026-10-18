-- Short shot request: one replication step before firing, one before returning.
-- A sent request is not proof of a hit; the game server owns cooldown and hit validation.
return function(ctx)
    return function(target)
        if ctx.Busy() then return false,"Gun busy or cooling down" end
        if not ctx.CanShoot() or not target or target~=ctx.Murderer() then return false,"Requires a gun and a living murderer" end
        local character=ctx.Character();local root=ctx.Root(character)
        local targetCharacter=target.Character;local targetRoot=ctx.Root(targetCharacter)
        local gun=ctx.Gun();local shoot=gun and gun:FindFirstChild("Shoot")
        if not root or not targetRoot or not shoot or not shoot:IsA("RemoteEvent") then return false,"Gun or target unavailable" end
        local home,velocity,spin=root.CFrame,root.AssemblyLinearVelocity,root.AssemblyAngularVelocity
        ctx.SetBusy(true)
        local sent=false
        local ok,err=pcall(function()
            ctx.Equip(gun)
            if gun.Parent~=character or not ctx.CanShoot() then return end
            local aim=ctx.Aim(targetCharacter);if not aim then return end
            local offset=home.Position-aim;offset=Vector3.new(offset.X,0,offset.Z)
            offset=offset.Magnitude>0.1 and offset.Unit or Vector3.new(0,0,1)
            ctx.MarkTeleport();root.CFrame=CFrame.lookAt(aim+offset*5,aim)
            root.AssemblyLinearVelocity=Vector3.new();root.AssemblyAngularVelocity=Vector3.new()
            ctx.WaitFrame()
            if ctx.Character()~=character or target.Character~=targetCharacter or ctx.Root(character)~=root
                or target~=ctx.Murderer() or not ctx.CanShoot() or ctx.Transitioning() then return end
            aim=ctx.Aim(targetCharacter);if not aim then return end
            local origin=ctx.Origin();if not origin then return end
            local lead=math.clamp(ctx.Lead(),0,0.15)
            shoot:FireServer(origin,CFrame.new(aim+targetRoot.AssemblyLinearVelocity*lead))
            sent=true;ctx.Fired();ctx.WaitFrame()
        end)
        -- Never move a replacement character or undo a round-transition teleport.
        pcall(function()
            if ctx.Character()==character and ctx.Root(character)==root and root.Parent and not ctx.Transitioning() then
                ctx.MarkTeleport();root.CFrame=home
                root.AssemblyLinearVelocity=velocity;root.AssemblyAngularVelocity=spin
            end
        end)
        ctx.SetBusy(false)
        if not ok then return false,tostring(err) end
        return sent,sent and "Shot requested" or "Shot cancelled"
    end
end
