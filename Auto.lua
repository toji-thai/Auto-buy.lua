-- [[ CONFIG ]]
local TargetID = 9228045253
local targetGiftPlayer = "tunthihakyi2" 

local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")

local isBuy, isLucky, isHop, isSend, isWater, isGift, isAccept = false, false, false, false, false, false, false
local targetPos = Vector3.new(9.3, 19.92, -37.65)
local fName = "MinMenuConfig.json"

-- [[ SYSTEM FUNCTIONS ]]
local function saveC()
    if not writefile then return end
    local data = {buy = isBuy, lucky = isLucky, hop = isHop, send = isSend, water = isWater, gift = isGift, accept = isAccept}
    pcall(function() writefile(fName, Http:JSONEncode(data)) end)
end

local function loadC()
    if isfile and isfile(fName) then
        local s, data = pcall(function() return Http:JSONDecode(readfile(fName)) end)
        if s then 
            isBuy, isLucky, isHop, isSend, isWater, isGift, isAccept = 
            data.buy, data.lucky, data.hop, data.send, data.water, data.gift, data.accept
        end
    end
end
loadC()

-- [[ UI SYSTEM ]]
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "MinMenu_Final_v11"; sg.ResetOnSpawn = false

local frm = Instance.new("Frame", sg)
frm.Size, frm.Position, frm.Visible = UDim2.new(0, 220, 0, 320), UDim2.new(0, 50, 0, 90), false
frm.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", frm)

local scroll = Instance.new("ScrollingFrame", frm)
scroll.Size, scroll.CanvasSize = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 450)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 4

local function createBtn(name, pos, varName)
    local b = Instance.new("TextButton", scroll)
    b.Size, b.Position = UDim2.new(0.9, 0, 0, 45), UDim2.new(0.05, 0, 0, pos)
    
    local function updateView()
        local val = _G[varName]
        b.Text = name..": "..(val and "ON" or "OFF")
        b.BackgroundColor3 = val and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    end
    
    b.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        -- Sync Local Variable for Saving
        if varName == "isAccept" then isAccept = _G[varName] end
        if varName == "isWater" then isWater = _G[varName] end
        if varName == "isBuy" then isBuy = _G[varName] end
        if varName == "isLucky" then isLucky = _G[varName] end
        if varName == "isHop" then isHop = _G[varName] end
        if varName == "isGift" then isGift = _G[varName] end
        updateView()
        saveC()
    end)
    
    -- Set Initial Global Value
    if varName == "isAccept" then _G[varName] = isAccept
    elseif varName == "isWater" then _G[varName] = isWater
    elseif varName == "isBuy" then _G[varName] = isBuy
    elseif varName == "isLucky" then _G[varName] = isLucky
    elseif varName == "isHop" then _G[varName] = isHop
    elseif varName == "isGift" then _G[varName] = isGift
    else _G[varName] = false end
    
    updateView()
    Instance.new("UICorner", b)
    return b
end

local tB = createBtn("Auto Buy", 10, "isBuy")
local tL = createBtn("Lucky", 70, "isLucky")
local tH = createBtn("Auto Hop (25s)", 130, "isHop")
local tW = createBtn("Water (0.5s)", 190, "isWater")
local tG = createBtn("Auto Gift", 250, "isGift")
local tA = createBtn("Auto Accept", 310, "isAccept")

local openBtn = Instance.new("TextButton", sg)
openBtn.Size, openBtn.Position, openBtn.Text = UDim2.new(0, 70, 0, 30), UDim2.new(0, 50, 0, 50), "OPEN"
openBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); openBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", openBtn)
openBtn.MouseButton1Click:Connect(function() frm.Visible = not frm.Visible end)

-- [[ LOGIC: AUTO ACCEPT (ล็อคสถานะค้างไว้) ]]
task.spawn(function()
    while true do task.wait(0.5)
        if _G.isAccept == true then
            pcall(function()
                for _, v in pairs(player.PlayerGui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible and v.Text:lower():find("accept") then
                        for _, con in pairs(getconnections(v.MouseButton1Click)) do con:Fire() end
                    end
                end
            end)
        end
    end
end)

-- [[ LOGIC: AUTO WATER (0.5s + บังคับถือถัง XP) ]]
task.spawn(function()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TreeClick")
    while true do task.wait(0.5)
        if _G.isWater == true then
            pcall(function()
                local char = player.Character
                local tree = workspace.Plots.Plot.PlotContents.Tree
                local tank = nil
                
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item.Name:upper():find("XP") then tank = item; break end
                end
                if not tank and char then
                    for _, item in pairs(char:GetChildren()) do
                        if item:IsA("Tool") and item.Name:upper():find("XP") then tank = item; break end
                    end
                end

                if tank and char then
                    if tank.Parent == player.Backpack then char.Humanoid:EquipTool(tank) end
                    remote:InvokeServer(tree)
                end
            end)
        end
    end
end)

-- [[ LOGIC: AUTO HOP (เปลี่ยนเซิร์ฟทุก 25 วินาที) ]]
task.spawn(function()
    while true do 
        task.wait(25) -- ตั้งเป็น 25 วินาทีแล้วครับ
        if _G.isHop == true then
            pcall(function()
                local url = "https://games.roblox.com/v1/games/"..TargetID.."/servers/Public?sortOrder=Asc&limit=100"
                local x = Http:JSONDecode(game:HttpGet(url))
                for _, s in pairs(x.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TS:TeleportToPlaceInstance(TargetID, s.id, player)
                        break
                    end
                end
            end)
        end
    end
end)

-- [[ LOGIC: BUY & LUCKY ]]
task.spawn(function()
    while true do task.wait(1)
        if _G.isBuy == true and player.Character then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
        if _G.isLucky == true and player.Character then
            for _, o in pairs(workspace:GetDescendants()) do
                if o.Name == "Main" and (o.Parent.Name == "Normal" or o.Parent.Name == "Rainbow") then
                    local p = o:FindFirstChildOfClass("ProximityPrompt")
                    if p then player.Character.HumanoidRootPart.CFrame = o.CFrame * CFrame.new(0,3,0); fireproximityprompt(p); break end
                end
            end
        end
    end
end)

print("V11: Hop 25s, Water 0.5s, Accept Locked ON.")
