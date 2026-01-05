local player = game.Players.LocalPlayer
local virtualInput = game:GetService("VirtualInputManager")
local isRunning, targetPos = false, Vector3.new(9.3, 19.92, -37.65)

-- UI Setup
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name, sg.ResetOnSpawn = "BotGui", false
local btn = Instance.new("TextButton", sg)
btn.Size, btn.Position = UDim2.new(0, 70, 0, 70), UDim2.new(0.85, -35, 0.2, 0)
btn.BackgroundColor3, btn.Text, btn.Font, btn.TextSize = Color3.fromRGB(200, 50, 50), "OFF", 4, 18
Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

-- ฟังก์ชันจิ้มแล้วปล่อยทันที
local function clickAt(x, y)
    virtualInput:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    virtualInput:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function runBot()
    while isRunning do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            -- [1] วาร์ป
            root.CFrame = CFrame.new(targetPos)
            task.wait(0.5)
            
            -- [2] กด E (เปิดเมนู)
            virtualInput:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            virtualInput:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(1.2) -- รอเมนูโหลด
            
            -- [3] ค้นหาปุ่มและจิ้มที่พิกัดปุ่ม
            local buyBtn = nil
            for _, v in ipairs(player.PlayerGui:GetDescendants()) do
                if v:IsA("GuiButton") and v.Visible and v.Name:lower():find("buy") and v.Name:find("3") then
                    buyBtn = v; break
                end
            end
            
            if buyBtn and isRunning then
                -- คำนวณจุดกึ่งกลางของปุ่มบนหน้าจอ
                local pos = buyBtn.AbsolutePosition
                local size = buyBtn.AbsoluteSize
                local centerX = pos.X + (size.X / 2)
                local centerY = pos.Y + (size.Y / 2) + 58 -- +58 สำหรับระยะขอบบนของ Roblox App
                
                clickAt(centerX, centerY)
                print("Clicked Buy 3 at coordinate")
                task.wait(0.5)
            end
            
            -- [4] กดมุมซ้ายล่าง 7 ที
            local view = workspace.CurrentCamera.ViewportSize
            for i = 1, 5 do
                if not isRunning then break end
                clickAt(50, view.Y - 50)
                task.wait(0.4)
            end
        end
        task.wait(2)
    end
end

btn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    btn.Text = isRunning and "ON" or "OFF"
    btn.BackgroundColor3 = isRunning and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    if isRunning then task.spawn(runBot) end
end)
