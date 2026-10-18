-- Floating shortcuts use the existing module API so menu and shortcut states stay synchronized.
return function(options)
    local Input=game:GetService("UserInputService")
    local Run=game:GetService("RunService")
    local M={Locked=false,Visible=true,Entries={}}
    local connections,drag={},nil
    local dead,suspended=false,false
    local function connect(event,fn) local c=event:Connect(fn);table.insert(connections,c);return c end
    local function make(class,props,parent)
        local item=Instance.new(class);for k,v in pairs(props) do item[k]=v end;item.Parent=parent;return item
    end
    local function changed() if not suspended and options.Changed then options.Changed() end end
    local function dimensions()
        local view=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
        return math.max(1,view.X),math.max(1,view.Y)
    end
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function position(entry)
        local w,h=dimensions();local width=math.min(146,math.max(72,w-16));local height=44
        entry.Button.Size=UDim2.fromOffset(width,height)
        entry.Button.Position=UDim2.fromOffset(8+entry.X*math.max(0,w-width-16),8+entry.Y*math.max(0,h-height-16))
    end
    local function defaultPosition(index)
        local _,h=dimensions();local rows=math.max(1,math.floor((h-100)/52))
        return math.max(0,1-math.floor((index-1)/rows)*0.3),math.clamp(0.12+((index-1)%rows)*52/math.max(1,h-60),0,1)
    end
    function M.Sync()
        if dead then return end
        for module,entry in pairs(M.Entries) do
            local on=not module.action and module:Get()
            entry.State.Text=module.action and "TAP" or on and "ON" or "OFF"
            entry.State.TextColor3=on and Color3.fromRGB(136,230,143) or Color3.fromRGB(154,161,171)
            entry.Button.BackgroundColor3=on and Color3.fromRGB(33,54,39) or Color3.fromRGB(24,27,33)
            entry.Button.Visible=M.Visible
            position(entry)
        end
    end
    function M.IsPinned(module) return M.Entries[module]~=nil end
    function M.Pin(module,saved)
        if dead or M.Entries[module] then return false end
        local found=false
        for _,candidate in ipairs(options.Modules()) do if candidate==module then found=true;break end end
        if not found then return false end
        local count=0;for _ in pairs(M.Entries) do count+=1 end
        local x,y=defaultPosition(count+1)
        if type(saved)=="table" and finite(saved.X) and finite(saved.Y) then x,y=math.clamp(saved.X,0,1),math.clamp(saved.Y,0,1) end
        local b=make("TextButton",{Name="RiftShortcut_"..module.name,Text="",AutoButtonColor=false,BorderSizePixel=0,
            BackgroundColor3=Color3.fromRGB(24,27,33),ZIndex=40,Active=true},options.Gui)
        make("UICorner",{CornerRadius=UDim.new(0,11)},b)
        make("UIStroke",{Color=Color3.fromRGB(67,74,82),Transparency=0.15,Thickness=1},b)
        make("TextLabel",{Position=UDim2.fromOffset(10,3),Size=UDim2.new(1,-46,1,-6),BackgroundTransparency=1,Text=module.display or module.name,
            TextWrapped=true,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(235,237,241),ZIndex=41},b)
        local state=make("TextLabel",{Position=UDim2.new(1,-38,0,0),Size=UDim2.new(0,30,1,0),BackgroundTransparency=1,
            Font=Enum.Font.GothamBold,TextSize=9,ZIndex=41},b)
        local entry={Button=b,State=state,X=x,Y=y,Connections={},SuppressUntil=0}
        M.Entries[module]=entry
        local function own(event,fn) local c=event:Connect(fn);table.insert(entry.Connections,c) end
        own(b.InputBegan,function(input)
            if M.Locked or not M.Visible or Input:GetFocusedTextBox() then return end
            if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
                drag={Input=input,Entry=entry,Start=input.Position,Origin=b.Position,Moved=false}
            end
        end)
        own(b.Activated,function()
            if dead or not M.Visible or Input:GetFocusedTextBox() then return end
            if drag and drag.Entry==entry and drag.Moved or os.clock()<entry.SuppressUntil then return end
            local ok,err=pcall(function()
                if module.action then if module.callback then task.spawn(module.callback,true) end
                else module:Toggle() end
            end)
            if not ok and options.Error then options.Error(tostring(err)) end
            M.Sync()
        end)
        M.Sync();changed();return true
    end
    function M.Unpin(module)
        local entry=M.Entries[module];if not entry then return end
        if drag and drag.Entry==entry then drag=nil end
        for _,c in ipairs(entry.Connections) do c:Disconnect() end
        entry.Button:Destroy();M.Entries[module]=nil;changed()
    end
    function M.Clear()
        local modules={};for module in pairs(M.Entries) do table.insert(modules,module) end
        for _,module in ipairs(modules) do M.Unpin(module) end
    end
    function M.SetLocked(on)
        M.Locked=on==true
        if drag then drag.Entry.SuppressUntil=os.clock()+0.25;drag=nil end
        changed()
    end
    function M.SetVisible(on) M.Visible=on==true;drag=nil;M.Sync();changed() end
    function M.ResetPositions()
        local index=0
        for _,module in ipairs(options.Modules()) do
            local entry=M.Entries[module]
            if entry then index+=1;entry.X,entry.Y=defaultPosition(index);position(entry) end
        end
        drag=nil;changed()
    end
    function M.Serialize()
        local pins={}
        for module,entry in pairs(M.Entries) do pins[module.name]={X=entry.X,Y=entry.Y} end
        return {Pins=pins,Locked=M.Locked,Visible=M.Visible}
    end
    function M.Restore(data)
        if type(data)~="table" then return end
        suspended=true;M.Clear();M.Locked=data.Locked==true;M.Visible=data.Visible~=false
        if type(data.Pins)=="table" then
            for _,module in ipairs(options.Modules()) do
                if type(data.Pins[module.name])=="table" then M.Pin(module,data.Pins[module.name]) end
            end
        end
        suspended=false;M.Sync()
    end
    connect(Input.InputChanged,function(input)
        if not drag or M.Locked then return end
        if input~=drag.Input and not (input.UserInputType==Enum.UserInputType.MouseMovement and drag.Input.UserInputType==Enum.UserInputType.MouseButton1) then return end
        local delta=input.Position-drag.Start;if delta.Magnitude>7 then drag.Moved=true end
        if not drag.Moved then return end
        local entry=drag.Entry;local w,h=dimensions();local size=entry.Button.Size
        local x=drag.Origin.X.Offset+delta.X;local y=drag.Origin.Y.Offset+delta.Y
        entry.X=math.clamp((x-8)/math.max(1,w-size.X.Offset-16),0,1)
        entry.Y=math.clamp((y-8)/math.max(1,h-size.Y.Offset-16),0,1);position(entry)
    end)
    connect(Input.InputEnded,function(input)
        if drag and (input==drag.Input or input.UserInputType==Enum.UserInputType.MouseButton1 and drag.Input.UserInputType==Enum.UserInputType.MouseButton1) then
            if drag.Moved then drag.Entry.SuppressUntil=os.clock()+0.25;changed() end
            drag=nil
        end
    end)
    connect(Input.WindowFocusReleased,function() if drag then drag.Entry.SuppressUntil=os.clock()+0.25;drag=nil end end)
    local age=0
    connect(Run.Heartbeat,function(dt) age+=dt;if age>=0.2 then age=0;M.Sync() end end)
    function M.Destroy()
        if dead then return end;dead=true;drag=nil
        for _,c in ipairs(connections) do c:Disconnect() end;table.clear(connections)
        for _,entry in pairs(M.Entries) do
            for _,c in ipairs(entry.Connections) do c:Disconnect() end
            entry.Button:Destroy()
        end
        table.clear(M.Entries)
    end
    connect(options.Gui.Destroying,M.Destroy)
    return M
end
