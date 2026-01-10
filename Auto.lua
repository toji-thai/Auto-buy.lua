-- [[ CONFIG ]]
local TargetID = 9228045253
local targetGiftPlayer = "tunthihakyi2" 

if game.PlaceId ~= TargetID and game.GameId ~= TargetID then
    warn("Current ID: " .. game.PlaceId .. " does not match TargetID: " .. TargetID)
end

local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local TS, Http = game:GetService("TeleportService"), game:GetService("HttpService")
local isBuy, isLucky, isHop, isSend, isWater, isGift, isAccept = false, false, false, false, false, false, false

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
            data.buy, data.lucky, data.hop, (data.send or false), (data.water or false), (data.gift or false), (data.accept or false) 
        end
    end
end
loadC()

-- [[ UI SYSTEM ]]
local sg = Instance.new("ScreenGui")
sg.Name = "MinMenuSystem_Scroll"; sg.ResetOnSpawn = false; sg.DisplayOrder = 100000
pcall(function() sg.Parent = player:WaitForChild("PlayerGui") end)

local function drag(obj)
    local dStart, sPos, dragging
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dStart, sPos = true, i.Position, obj.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dStart; obj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y) end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local btn = Instance.new("TextButton", sg)
btn.Size, btn.Position, btn.Text = UDim2.new(0, 70, 0, 30), UDim2.new(0, 50, 0, 50), "OPEN"
btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 14; btn.ZIndex = 100
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8); drag(btn)

-- หน้าต่างหลัก (Background)
local frm = Instance.new("Frame", sg)
frm.Size, frm.Position, frm.Visible = UDim2.new(0, 220, 0, 300), UDim2.new(0, 50, 0, 90), false -- ล็อกความสูงไว้ที่ 300
frm.BackgroundColor3 = Color3.fromRGB(35, 35, 35); frm.ZIndex = 90; Instance.new("UICorner", frm); drag(frm)

-- ส่วนที่เลื่อนได้ (Scrolling Frame)
local scroll = Instance.new("ScrollingFrame", frm)
scroll.Size = UDim2.new(1, -10, 1, -20)
scroll.Position = UDim2.new(0, 5, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 450) -- ปรับพื้นที่ข้างในให้ยาวเพื่อเลื่อนได้
scroll.ZIndex = 91

local function createBtn(name, pos, val)
    local b = Instance.new("TextButton", scroll) -- เปลี่ยน Parent ไปที่ scroll
    b.Size, b.Position = UDim2.new(0.9, 0, 0, 45), UDim2.new(0.05, 0, 0, pos)
    b.Text = name..": "..(val and "ON" or "OFF")
    b.BackgroundColor3 = val and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    b.TextColor3, b.Font, b.TextSize, b.ZIndex = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16, 95
    Instance.new("UICorner", b); return b
end

-- ลำดับปุ่ม
local tB = createBtn("Auto Buy", 10, isBuy)
local tL = createBtn("Lucky", 70, isLucky)
local tH = createBtn("Auto Hop LB", 130, isHop)
local tS = createBtn("Send Item", 190, isSend)
local tW = createBtn("Auto Watering can", 250, isWater)
local tG = createBtn("Auto Gift", 310, isGift)
local tA = createBtn("Auto Accept", 370, isAccept)

-- [[ LOGIC: ปุ่มต่างๆ (เหมือนเดิมทุกอย่าง) ]]
-- (ตัด Logic เดิมมาใส่เพื่อให้โค้ดสมบูรณ์)

local function update(b, v, n) 
    b.Text = n..": "..(v and "ON" or "OFF"); b.BackgroundColor3 = v and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60); saveC() 
end

btn.MouseButton1Click:Connect(function() frm.Visible = not frm.Visible end)
tB.MouseButton1Click:Connect(function() isBuy = not isBuy; update(tB, isBuy, "Auto Buy") end)
tL.MouseButton1Click:Connect(function() isLucky = not isLucky; update(tL, isLucky, "Lucky") end)
tH.MouseButton1Click:Connect(function() isHop = not isHop; update(tH, isHop, "Auto Hop LB") end)
tS.MouseButton1Click:Connect(function() isSend = not isSend; update(tS, isSend, "Send Item") end)
tW.MouseButton1Click:Connect(function() isWater = not isWater; update(tW, isWater, "Auto Watering can") end)
tG.MouseButton1Click:Connect(function() isGift = not isGift; update(tG, isGift, "Auto Gift") end)
tA.MouseButton1Click:Connect(function() isAccept = not isAccept; update(tA, isAccept, "Auto Accept") end)

-- ใส่ Logic การทำงาน (task.spawn) จากโค้ดอันเก่าของคุณต่อท้ายได้เลยครับ

print("Scrollable Menu Loaded!")
