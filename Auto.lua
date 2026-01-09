local TargetID = 123557829667240
if game.GameId ~= TargetID and game.PlaceId ~= TargetID then 
    warn("สคริปต์นี้ไม่รองรับเกมนี้ (ID ไม่ถูกต้อง)")
    return 
end

local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local isBuy, isLucky, isHop, targetPos = false, false, false, Vector3.new(9.3, 19.92, -37.65)

local fName = "MinMenuConfig.json"

local function saveC()
    local data = {buy = isBuy, lucky = isLucky, hop = isHop}
    pcall(function() writefile(fName, Http:JSONEncode(data)) end)
end

local function loadC()
    if isfile and isfile(fName) then
        local s, data = pcall(function() return Http:JSONDecode(readfile(fName)) end)
        if s then isBuy, isLucky, isHop = data.buy, data.lucky, data.hop end
    end
end

loadC()

local sg = Instance.new("ScreenGui", player.PlayerGui); sg.Name = "MinMenu"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999
local function drag(obj)
    local dStart, sPos, dragging
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dStart, sPos = true, i.Position, obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dStart; obj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y) end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local btn = Instance.new("TextButton", sg); btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,60,0,60), UDim2.new(0,10,0,10), "MENU", Color3.new(0.2,0.2,0.2); Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0); btn.ZIndex = 10; drag(btn)
local frm = Instance.new("Frame", sg); frm.Size, frm.Position, frm.Visible, frm.BackgroundColor3 = UDim2.new(0,180,0,200), UDim2.new(0,10,0,80), false, Color3.new(0.1,0.1,0.1); Instance.new("UICorner", frm); frm.ZIndex = 9; drag(frm)

local function createBtn(name, pos, val)
    local b = Instance.new("TextButton", frm); b.Size, b.Position = UDim2.new(0.8,0,0,40), UDim2.new(0.1,0,0,pos)
    b.Text = name..": "..(val and "ON" or "OFF"); b.BackgroundColor3 = val and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2); Instance.new("UICorner", b); b.ZIndex = 11; return b
end

local tB = createBtn("Auto Buy", 15, isBuy)
local tL = createBtn("Lucky", 65, isLucky)
local tH = createBtn("Auto Hop LB", 115, isHop)

-- ระบบ Hop (15 วินาที)
local function Hop()
    if not isHop then return end
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local s, r = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
    if s and r.data then
        for _, v in pairs(r.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                return
            end
        end
    end
    task.wait(3) if isHop then Hop() end
end

task.spawn(function()
    while true do task.wait(1)
        if isHop then
            for i = 15, 1, -1 do 
                if not isHop then break end
                tH.Text = "Hop in: "..i.."s"
                task.wait(1) 
            end
            if isHop then Hop() end
        else tH.Text = "Auto Hop LB: OFF" end
    end
end)

-- Logic Farm
task.spawn(function()
    while true do task.wait(0.5)
        if isLucky and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, o in pairs(workspace:GetDescendants()) do
                    if not isLucky then break end
                    if o.Name == "Main" and o.Parent and (o.Parent.Name == "Normal" or o.Parent.Name == "Rainbow") then
                        local p = o:FindFirstChildOfClass("ProximityPrompt")
                        if p then hrp.CFrame = o.CFrame * CFrame.new(0,3,0); p:InputHoldBegin(); task.wait(3.1); p:InputHoldEnd(); fireproximityprompt(p); break end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do task.wait(2)
        if isBuy and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos); task.wait(0.5)
            VIM:SendKeyEvent(true, 101, false, game); task.wait(0.05); VIM:SendKeyEvent(false, 101, false, game); task.wait(1.2)
            for _, v in pairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                    local p = v.AbsolutePosition; VIM:SendMouseButtonEvent(p.X+v.AbsoluteSize.X/2, p.Y+v.AbsoluteSize.Y/2+58, 0, true, game, 0); task.wait(0.1); VIM:SendMouseButtonEvent(p.X+v.AbsoluteSize.X/2, p.Y+v.AbsoluteSize.Y/2+58, 0, false, game, 0)
                    task.wait(3)
                end
            end
        end
    end
end)

btn.MouseButton1Click:Connect(function()
    frm.Visible = not frm.Visible
end)

local function update(b, v, n) b.Text = n..": "..(v and "ON" or "OFF"); b.BackgroundColor3 = v and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2); saveC() end
tB.MouseButton1Click:Connect(function() isBuy = not isBuy; update(tB, isBuy, "Auto Buy") end)
tL.MouseButton1Click:Connect(function() isLucky = not isLucky; update(tL, isLucky, "Lucky") end)
tH.MouseButton1Click:Connect(function() isHop = not isHop; update(tH, isHop, "Auto Hop LB") end)
