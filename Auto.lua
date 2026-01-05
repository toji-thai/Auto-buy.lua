local player = game.Players.LocalPlayer
local UIS, VIM = game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local isBot, targetPos = false, Vector3.new(9.3, 19.92, -37.65)

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name, sg.ResetOnSpawn = "MinMenu", false

-- ฟังก์ชันทำให้ลากได้ (แบบสั้น)
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
local btn = Instance.new("TextButton", sg)
btn.Size, btn.Position, btn.Text, btn.BackgroundColor3 = UDim2.new(0,60,0,60), UDim2.new(0,10,0.5,0), "MENU", Color3.new(0.2,0.2,0.2)
Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
drag(btn)

local frm = Instance.new("Frame", sg)
frm.Size, frm.Position, frm.Visible, frm.BackgroundColor3 = UDim2.new(0,180,0,100), UDim2.new(0.5,-90,0.5,-50), false, Color3.new(0.1,0.1,0.1)
Instance.new("UICorner", frm)
drag(frm)

local tog = Instance.new("TextButton", frm)
tog.Size, tog.Position, tog.Text, tog.BackgroundColor3 = UDim2.new(0.8,0,0,40), UDim2.new(0.1,0,0.3,0), "Auto: OFF", Color3.new(0.7,0.2,0.2)
Instance.new("UICorner", tog)

-- Logic
local function click(x, y)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0); task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function run()
    while isBot do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(targetPos); task.wait(0.5)
            VIM:SendKeyEvent(true, 101, false, game); task.wait(0.05); VIM:SendKeyEvent(false, 101, false, game); task.wait(1.2)
            
            for _, v in pairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                    click(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2 + 58)
                    break
                end
            end
            
            local vSize = workspace.CurrentCamera.ViewportSize
            for i=1,5 do if not isBot then break end click(50, vSize.Y-50); task.wait(0.4) end
        end
        task.wait(2)
    end
end

local lastT = 0
btn.MouseButton1Down:Connect(function() lastT = tick() end)
btn.MouseButton1Up:Connect(function() if tick()-lastT < 0.2 then frm.Visible = not frm.Visible end end)

tog.MouseButton1Click:Connect(function()
    isBot = not isBot
    tog.Text = isBot and "Auto: ON" or "Auto: OFF"
    tog.BackgroundColor3 = isBot and Color3.new(0.2,0.7,0.2) or Color3.new(0.7,0.2,0.2)
    if isBot then task.spawn(run) end
end)
