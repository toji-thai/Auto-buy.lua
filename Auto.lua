local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local isBuy, isLucky, targetPos = false, false, Vector3.new(9.3, 19.92, -37.65)

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name, sg.ResetOnSpawn = "MinMenu", false

-- ฟังก์ชันลาก (Drag)
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

-- สร้าง UI
local btn = Instance.new("TextButton", sg); btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,60,0,60), UDim2.new(0,10,0,10), "MENU", Color3.new(0.2,0.2,0.2); Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0); drag(btn)
local frm = Instance.new("Frame", sg); frm.Size, frm.Position, frm.Visible, frm.BackgroundColor3 = UDim2.new(0,180,0,150), UDim2.new(0,10,0,80), false, Color3.new(0.1,0.1,0.1); Instance.new("UICorner", frm); drag(frm)

local function createBtn(name, pos)
    local b = Instance.new("TextButton", frm); b.Size, b.Position, b.Text, b.BackgroundColor3 = UDim2.new(0.8,0,0,40), UDim2.new(0.1,0,0,pos), name..": OFF", Color3.new(0.7,0.2,0.2); Instance.new("UICorner", b); return b
end

local togBuy = createBtn("Auto Buy", 15)
local togLucky = createBtn("Lucky", 65)

-- Logic Lucky (วาร์ปหา Main ใน Normal และ Rainbow)
task.spawn(function()
    while true do task.wait(0.5)
        if isLucky then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if not isLucky then break end
                
                -- เช็คเงื่อนไข: ชื่อ Main และ Parent ต้องเป็น Normal หรือ Rainbow
                if obj.Name == "Main" and obj.Parent and (obj.Parent.Name == "Normal" or obj.Parent.Name == "Rainbow") then
                    local p = obj:FindFirstChildOfClass("ProximityPrompt")
                    if p then
                        hrp.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                        hrp.Velocity = Vector3.new(0,0,0)
                        
                        p:InputHoldBegin()
                        task.wait(3.1) -- กดค้างตามเงื่อนไข 3 วินาที
                        p:InputHoldEnd()
                        
                        fireproximityprompt(p)
                        task.wait(0.5)
                        break 
                    end
                end
            end
        end
    end
end)

-- Logic Auto Buy (คงเดิม)
local function click(x, y) VIM:SendMouseButtonEvent(x, y, 0, true, game, 0); task.wait(0.05); VIM:SendMouseButtonEvent(x, y, 0, false, game, 0) end
task.spawn(function()
    while true do task.wait(2)
        if isBuy then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(targetPos); task.wait(0.5)
                VIM:SendKeyEvent(true, 101, false, game); task.wait(0.05); VIM:SendKeyEvent(false, 101, false, game); task.wait(1.2)
                for _, v in pairs(player.PlayerGui:GetDescendants()) do
                    if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                        click(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2 + 58); break
                    end
                end
            end
        end
    end
end)

-- Menu Toggle & Interaction
local lastT = 0
btn.MouseButton1Down:Connect(function() lastT = tick() end)
btn.MouseButton1Up:Connect(function() if tick()-lastT < 0.2 then frm.Visible = not frm.Visible end end)

togBuy.MouseButton1Click:Connect(function()
    isBuy = not isBuy
    togBuy.Text = "Auto Buy: "..(isBuy and "ON" or "OFF")
    togBuy.BackgroundColor3 = isBuy and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2)
end)

togLucky.MouseButton1Click:Connect(function()
    isLucky = not isLucky
    togLucky.Text = "Lucky: "..(isLucky and "ON" or "OFF")
    togLucky.BackgroundColor3 = isLucky and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2)
end)
