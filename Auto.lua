local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local isBuy, isLucky, isHop, targetPos = false, false, false, Vector3.new(9.3, 19.92, -37.65)

-- FileName สำหรับเซฟ
local fName = "MinMenuConfig.json"

-- ฟังก์ชันเซฟค่า
local function saveC()
    local data = {buy = isBuy, lucky = isLucky, hop = isHop}
    writefile(fName, Http:JSONEncode(data))
end

-- ฟังก์ชันโหลดค่า
local function loadC()
    if isfile(fName) then
        local data = Http:JSONDecode(readfile(fName))
        isBuy, isLucky, isHop = data.buy, data.lucky, data.hop
    end
end

loadC() -- โหลดค่าทันทีที่รันสคริปต์

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name, sg.ResetOnSpawn = "MinMenu", false

local function drag(obj)
    local dragStart, startPos, dragging
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local btn = Instance.new("TextButton", sg); btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,60,0,60), UDim2.new(0,10,0,10), "MENU", Color3.new(0.2,0.2,0.2); Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0); drag(btn)
local frm = Instance.new("Frame", sg); frm.Size, frm.Position, frm.Visible, frm.BackgroundColor3 = UDim2.new(0,180,0,200), UDim2.new(0,10,0,80), false, Color3.new(0.1,0.1,0.1); Instance.new("UICorner", frm); drag(frm)

local function createBtn(name, pos, val)
    local b = Instance.new("TextButton", frm); b.Size, b.Position = UDim2.new(0.8,0,0,40), UDim2.new(0.1,0,0,pos)
    b.Text = name..": "..(val and "ON" or "OFF")
    b.BackgroundColor3 = val and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2)
    Instance.new("UICorner", b); return b
end

local togBuy = createBtn("Auto Buy", 15, isBuy)
local togLucky = createBtn("Lucky", 60, isLucky)
local togHop = createBtn("Auto Hop LB", 105, isHop)

-- ระบบ Server Hop
local function ServerHop()
    local success, result = pcall(function()
        return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
    end)
    if success then
        for _, s in pairs(result) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TS:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                return
            end
        end
    end
    task.wait(2) if isHop then ServerHop() end
end

task.spawn(function()
    while true do task.wait(1)
        if isHop then
            for i = 30, 1, -1 do
                if not isHop then break end
                togHop.Text = "Hopping in: "..i.."s"
                task.wait(1)
            end
            if isHop then ServerHop() end
        end
        togHop.Text = "Auto Hop LB: OFF"
    end
end)

-- Logic อื่นๆ (เหมือนเดิม)
local function clickScreenFiveTimes()
    task.wait(0.5)
    local sz = workspace.CurrentCamera.ViewportSize
    local tx, ty = sz.X * 0.1, sz.Y * 0.8
    for i = 1, 5 do
        VIM:SendMouseButtonEvent(tx, ty, 0, true, game, 0); task.wait(0.05)
        VIM:SendMouseButtonEvent(tx, ty, 0, false, game, 0); task.wait(0.3)
    end
end

task.spawn(function()
    while true do task.wait(0.5)
        if isLucky then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not isLucky then break end
                    if obj.Name == "Main" and obj.Parent and (obj.Parent.Name == "Normal" or obj.Parent.Name == "Rainbow") then
                        local p = obj:FindFirstChildOfClass("ProximityPrompt")
                        if p then
                            hrp.CFrame = obj.CFrame * CFrame.new(0, 3, 0); hrp.Velocity = Vector3.new(0,0,0)
                            p:InputHoldBegin(); task.wait(3.1); p:InputHoldEnd(); fireproximityprompt(p)
                            task.wait(0.5); break 
                        end
                    end
                end
            end
        end
    end
end)

local function click(x, y) VIM:SendMouseButtonEvent(x, y, 0, true, game, 0); task.wait(0.4); VIM:SendMouseButtonEvent(x, y, 0, false, game, 0) end
task.spawn(function()
    while true do task.wait(2)
        if isBuy then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(targetPos); task.wait(0.5)
                VIM:SendKeyEvent(true, 101, false, game); task.wait(0.05); VIM:SendKeyEvent(false, 101, false, game); task.wait(1.2)
                for _, v in pairs(player.PlayerGui:GetDescendants()) do
                    if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                        click(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2 + 58)
                        task.spawn(clickScreenFiveTimes); task.wait(3)
                    end
                end
            end
        end
    end
end)

-- ปุ่มกดและอัปเดตสถานะ
local lastT = 0
btn.MouseButton1Down:Connect(function() lastT = tick() end)
btn.MouseButton1Up:Connect(function() if tick()-lastT < 0.2 then frm.Visible = not frm.Visible end end)

local function updateBtn(b, val, name)
    b.Text = name..": "..(val and "ON" or "OFF")
    b.BackgroundColor3 = val and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2)
    saveC() -- เซฟค่าทุกครั้งที่มีการกดปุ่ม
end

togBuy.MouseButton1Click:Connect(function() isBuy = not isBuy; updateBtn(togBuy, isBuy, "Auto Buy") end)
togLucky.MouseButton1Click:Connect(function() isLucky = not isLucky; updateBtn(togLucky, isLucky, "Lucky") end)
togHop.MouseButton1Click:Connect(function() isHop = not isHop; updateBtn(togHop, isHop, "Auto Hop LB") end)nd
