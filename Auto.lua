local TargetID = 9228045253
if game.GameId ~= TargetID and game.PlaceId ~= TargetID then return end

local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local isBuy, isLucky, isHop, targetPos = false, false, false, Vector3.new(9.3, 19.92, -37.65)

local fName = "MinMenuConfig.json"
local globalFile = "UsedServers.json" -- ไฟล์กลางสำหรับแชร์ข้อมูลระหว่างไอดี

-- ฟังก์ชันจัดการข้อมูลเซิร์ฟเวอร์ที่ถูกใช้แล้ว
local function getUsedServers()
    if isfile(globalFile) then
        return Http:JSONDecode(readfile(globalFile)) or {}
    end
    return {}
end

local function markServerUsed()
    local used = getUsedServers()
    used[game.JobId] = os.time()
    -- ล้างข้อมูลเก่า (เกิน 10 นาที) เพื่อไม่ให้ไฟล์ใหญ่เกินไป
    for id, t in pairs(used) do
        if os.time() - t > 600 then used[id] = nil end
    end
    writefile(globalFile, Http:JSONEncode(used))
end

-- บันทึกว่าไอดีนี้จองเซิร์ฟนี้แล้ว
markServerUsed()

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

-- [[ UI SYSTEM - เหมือนเดิมแต่ปรับ ZIndex ให้ชัวร์ ]]
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
frm.Size, frm.Position, frm.Visible = UDim2.new(0, 200, 0, 220), UDim2.new(0, 20, 0, 90), false
frm.BackgroundColor3 = Color3.fromRGB(35, 35, 35); frm.ZIndex = 90; Instance.new("UICorner", frm); drag(frm)

local function createBtn(name, pos, val)
    local b = Instance.new("TextButton", frm)
    b.Size, b.Position = UDim2.new(0.9, 0, 0, 50), UDim2.new(0.05, 0, 0, pos)
    b.Text = name..": "..(val and "ON" or "OFF")
    b.BackgroundColor3 = val and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    b.TextColor3, b.Font, b.TextSize, b.ZIndex = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 18, 95
    Instance.new("UICorner", b); return b
end

local tB = createBtn("Auto Buy", 15, isBuy)
local tL = createBtn("Lucky", 80, isLucky)
local tH = createBtn("Auto Hop LB", 145, isHop)

-- [[ ระบบ Hop แบบป้องกันไอดีซ้ำเซิร์ฟ ]]
local function Hop()
    if not isHop then return end
    local used = getUsedServers()
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local s, r = pcall(function() return Http:JSONDecode(game:HttpGet(url)) end)
    
    if s and r.data then
        for _, v in pairs(r.data) do
            -- เช็คว่าเซิร์ฟเวอร์นี้มีไอดีอื่นใช้อยู่หรือไม่
            if v.playing < v.maxPlayers and v.id ~= game.JobId and not used[v.id] then
                TS:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                return
            end
        end
    end
    task.wait(2) if isHop then Hop() end
end

task.spawn(function()
    while true do task.wait(1)
        if isHop then
            for i = 15, 1, -1 do 
                if not isHop then break end
                tH.Text = "Hop in: "..i.."s"; task.wait(1) 
            end
            if isHop then Hop() end
        else tH.Text = "Auto Hop LB: OFF" end
    end
end)

-- [[ LOGIC FARM ]]
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

btn.MouseButton1Click:Connect(function() frm.Visible = not frm.Visible end)
local function update(b, v, n) 
    b.Text = n..": "..(v and "ON" or "OFF")
    b.BackgroundColor3 = v and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    saveC() 
end
tB.MouseButton1Click:Connect(function() isBuy = not isBuy; update(tB, isBuy, "Auto Buy") end)
tL.MouseButton1Click:Connect(function() isLucky = not isLucky; update(tL, isLucky, "Lucky") end)
tH.MouseButton1Click:Connect(function() isHop = not isHop; update(tH, isHop, "Auto Hop LB") end)
