Local TargetID = 9228045253
if game.GameId ~= TargetID and game.PlaceId ~= TargetID then return end

local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local isBuy, isLucky, isHop, isSend = false, false, false, false -- เพิ่ม isSend
local targetPos = Vector3.new(9.3, 19.92, -37.65)

local fName = "MinMenuConfig.json"
local globalFile = "UsedServers.json"
local myToken = tostring(math.random(100000, 999999)) 

-- [[ SYSTEM FUNCTIONS ]]
local function getUsedServers()
    if isfile(globalFile) then
        local s, res = pcall(function() return Http:JSONDecode(readfile(globalFile)) end)
        return s and res or {}
    end
    return {}
end

local function markServerUsed()
    local used = getUsedServers()
    used[game.JobId] = {time = os.time(), token = myToken}
    for id, data in pairs(used) do
        if type(data) == "table" and os.time() - data.time > 480 then used[id] = nil end
    end
    pcall(function() writefile(globalFile, Http:JSONEncode(used)) end)
end

markServerUsed()

local function saveC()
    local data = {buy = isBuy, lucky = isLucky, hop = isHop, send = isSend}
    pcall(function() writefile(fName, Http:JSONEncode(data)) end)
end

local function loadC()
    if isfile and isfile(fName) then
        local s, data = pcall(function() return Http:JSONDecode(readfile(fName)) end)
        if s then isBuy, isLucky, isHop, isSend = data.buy, data.lucky, data.hop, (data.send or false) end
    end
end
loadC()

-- [[ ระบบ Hop ]]
local function Hop()
    if not isHop then return end
    markServerUsed()
    task.wait(1) 
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local s, r = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
    if s and r.data then
        local servers = r.data
        for i = #servers, 2, -1 do
            local j = math.random(i)
            servers[i], servers[j] = servers[j], servers[i]
        end
        for _, v in pairs(servers) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId and not used[v.id] then
                TS:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                return
            end
        end
    end
    task.wait(5)
    if isHop then Hop() end
end

-- [[ UI SYSTEM ]]
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "MinMenuSystem"; sg.ResetOnSpawn = false; sg.DisplayOrder = 100000

local function drag(obj)
    local dStart, sPos, dragging
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dStart, sPos = true, i.Position, obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dStart; obj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y) end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local btn = Instance.new("TextButton", sg)
btn.Size, btn.Position, btn.Text = UDim2.new(0, 60, 0, 60), UDim2.new(0, 20, 0, 20), "OPEN"
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 18; btn.ZIndex = 100
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0); drag(btn)

local frm = Instance.new("Frame", sg)
frm.Size, frm.Position, frm.Visible = UDim2.new(0, 200, 0, 280), UDim2.new(0, 20, 0, 90), false -- ขยายขนาด Frame รองรับปุ่มที่ 4
frm.BackgroundColor3 = Color3.fromRGB(35, 35, 35); frm.ZIndex = 90; Instance.new("UICorner", frm); drag(frm)

local function createBtn(name, pos, val)
    local b = Instance.new("TextButton", frm)
    b.Size, b.Position = UDim2.new(0.9, 0, 0, 45), UDim2.new(0.05, 0, 0, pos)
    b.Text = name..": "..(val and "ON" or "OFF")
    b.BackgroundColor3 = val and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    b.TextColor3, b.Font, b.TextSize, b.ZIndex = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16, 95
    Instance.new("UICorner", b); return b
end

local tB = createBtn("Auto Buy", 15, isBuy)
local tL = createBtn("Lucky", 75, isLucky)
local tH = createBtn("Auto Hop LB", 135, isHop)
local tS = createBtn("Send Item", 195, isSend) -- ปุ่มที่ 4

-- [[ LOGIC: SEND ITEM (Tumbleweed & Grand Piano) ]]
task.spawn(function()
    local targetItems = {"Tumbleweed", "Grand Piano"}
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LuckyLumberjackGiveTotem")
    
    while true do task.wait(0.35) -- ความเร็ว 0.3-0.4 วินาที
        if isSend then
            local backpack = player:FindFirstChild("Backpack")
            local char = player.Character
            local targetTotem = nil

            -- ค้นหาของและหยิบ
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                -- เช็คในมือ
                for _, item in pairs(char:GetChildren()) do
                    if item.Name == "Totem" and table.find(targetItems, item:GetAttribute("ItemName")) then
                        targetTotem = item; break
                    end
                end
                -- เช็คในเป้และหยิบ
                if not targetTotem and backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        if item.Name == "Totem" and table.find(targetItems, item:GetAttribute("ItemName")) then
                            hum:EquipTool(item)
                            task.wait(0.1)
                            targetTotem = item; break
                        end
                    end
                end
            end

            if targetTotem then
                -- ส่ง Remote
                task.spawn(function() pcall(function() remote:InvokeServer(targetTotem) end) end)
                task.wait(0.15)
                -- กด YES
                local yesBtn = player.PlayerGui:FindFirstChild("Yes", true) or player.PlayerGui:FindFirstChild("Confirm", true)
                if yesBtn and yesBtn.Visible then
                    pcall(function()
                        for _, con in pairs(getconnections(yesBtn.MouseButton1Click)) do con:Fire() end
                    end)
                end
            else
                -- ถ้าของหมด ปิดการทำงาน
                isSend = false
                tS.Text = "Send Item: OFF (Empty)"
                tS.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                saveC()
            end
        end
    end
end)

-- [[ ลูปนับถอยหลัง Hop ]]
task.spawn(function()
    while true do task.wait(1)
        if isHop then
            for i = 25, 1, -1 do
                if not isHop then break end
                tH.Text = "Hop in: "..i.."s"
                task.wait(1) 
            end
            if isHop then tH.Text = "Hopping..."; Hop() end
        else tH.Text = "Auto Hop LB: OFF" end
    end
end)

-- [[ LOGIC: AUTO BUY & CLICK ]]
task.spawn(function()
    while true do task.wait(1.5)
        if isBuy and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            task.wait(0.5)
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(1)
            local hasBought = false
            for _, v in pairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                    local p, s = v.AbsolutePosition, v.AbsoluteSize
                    VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2 + 58, 0, true, game, 0)
                    task.wait(0.1); VIM:SendMouseButtonEvent(p.X + s.X/2, p.Y + s.Y/2 + 58, 0, false, game, 0)
                    hasBought = true; break
                end
            end
            if hasBought then
                task.wait(1)
                local screenSize = sg.AbsoluteSize 
                for i = 1, 5 do
                    if not isBuy then break end
                    VIM:SendMouseButtonEvent(screenSize.X * 0.15, (screenSize.Y * 0.88) + 58, 0, true, game, 0)
                    task.wait(0.1); VIM:SendMouseButtonEvent(screenSize.X * 0.15, (screenSize.Y * 0.88) + 58, 0, false, game, 0)
                    task.wait(0.3)
                end
            end
            task.wait(2)
        end
    end
end)

-- [[ LOGIC: LUCKY FARM ]]
task.spawn(function()
    while true do task.wait(0.5)
        if isLucky and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            for _, o in pairs(workspace:GetDescendants()) do
                if not isLucky then break end
                if o.Name == "Main" and o.Parent and (o.Parent.Name == "Normal" or o.Parent.Name == "Rainbow") then
                    local p = o:FindFirstChildOfClass("ProximityPrompt")
                    if p then hrp.CFrame = o.CFrame * CFrame.new(0,3,0); p:InputHoldBegin(); task.wait(3.1); p:InputHoldEnd(); fireproximityprompt(p); break end
                end
            end
        end
    end
end)

btn.MouseButton1Click:Connect(function() frm.Visible = not frm.Visible end)
local function update(b, v, n) 
    b.Text = n..": "..(v and "ON" or "OFF"); b.BackgroundColor3 = v and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60); saveC() 
end
tB.MouseButton1Click:Connect(function() isBuy = not isBuy; update(tB, isBuy, "Auto Buy") end)
tL.MouseButton1Click:Connect(function() isLucky = not isLucky; update(tL, isLucky, "Lucky") end)
tH.MouseButton1Click:Connect(function() isHop = not isHop; update(tH, isHop, "Auto Hop LB") end)
tS.MouseButton1Click:Connect(function() isSend = not isSend; update(tS, isSend, "Send Item") end)
