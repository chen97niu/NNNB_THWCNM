--[[
    创世神VN 飞行菜单 v2.0
    手机完全适配：摇杆移动 + 视角上下飞
--]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- ========== 配置 ==========
local flying = false
local currentSpeedLevel = 1
local flySpeeds = {39, 50, 100, 500, 2000}
local flySpeed = flySpeeds[currentSpeedLevel]

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000

-- ========== 创建主菜单UI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChuangShiShenVN"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- 主按钮（小长方形 + 彩色光圈）
local mainButton = Instance.new("ImageButton")
mainButton.Size = UDim2.new(0, 120, 0, 50)
mainButton.Position = UDim2.new(0.5, -60, 0.85, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainButton.BackgroundTransparency = 0
mainButton.BorderSizePixel = 0
mainButton.Parent = screenGui

-- 圆角
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = mainButton

-- 彩色光圈（边框）
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255, 0, 0)
border.Thickness = 3
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = mainButton

-- 颜色变换动画
local colors = {
    Color3.fromRGB(255, 0, 0),     -- 红
    Color3.fromRGB(255, 165, 0),   -- 橙
    Color3.fromRGB(255, 255, 0),   -- 黄
    Color3.fromRGB(0, 255, 0),     -- 绿
    Color3.fromRGB(0, 255, 255),   -- 青
    Color3.fromRGB(0, 0, 255),     -- 蓝
    Color3.fromRGB(255, 0, 255)    -- 紫
}
local colorIndex = 1
task.spawn(function()
    while true do
        colorIndex = colorIndex % #colors + 1
        border.Color = colors[colorIndex]
        task.wait(0.15)
    end
end)

-- 按钮文字
local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 1, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "创世神VN"
btnText.TextColor3 = Color3.fromRGB(255, 0, 0)
btnText.TextSize = 20
btnText.Font = Enum.Font.GothamBold
btnText.TextScaled = true
btnText.Parent = mainButton

-- ========== 菜单Frame ==========
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 300, 0, 400)
menuFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 0.05
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 15)
menuCorner.Parent = menuFrame

-- 菜单标题
local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, 0, 0, 50)
menuTitle.BackgroundTransparency = 1
menuTitle.Text = "飞行菜单"
menuTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
menuTitle.TextSize = 24
menuTitle.Font = Enum.Font.GothamBold
menuTitle.Parent = menuFrame

-- 飞行开关按钮
local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(0.8, 0, 0, 50)
flyToggle.Position = UDim2.new(0.1, 0, 0, 60)
flyToggle.Text = "飞行 (关闭)"
flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
flyToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
flyToggle.BorderSizePixel = 0
flyToggle.Parent = menuFrame

local flyToggleCorner = Instance.new("UICorner")
flyToggleCorner.CornerRadius = UDim.new(0, 8)
flyToggleCorner.Parent = flyToggle

-- 速度档位标题
local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(0.8, 0, 0, 30)
speedTitle.Position = UDim2.new(0.1, 0, 0, 120)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "飞行速度"
speedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
speedTitle.TextSize = 18
speedTitle.Font = Enum.Font.GothamBold
speedTitle.Parent = menuFrame

-- 当前速度显示
local speedDisplay = Instance.new("TextLabel")
speedDisplay.Size = UDim2.new(0.8, 0, 0, 30)
speedDisplay.Position = UDim2.new(0.1, 0, 0, 150)
speedDisplay.BackgroundTransparency = 1
speedDisplay.Text = "档位 1/5 | 速度 39"
speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 0)
speedDisplay.TextSize = 16
speedDisplay.Font = Enum.Font.Gotham
speedDisplay.Parent = menuFrame

-- 速度档位按钮容器
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(0.9, 0, 0, 60)
speedContainer.Position = UDim2.new(0.05, 0, 0, 185)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = menuFrame

-- 创建5个档位按钮
local speedBtns = {}
for i = 1, 5 do
    local btn = Instance.new("TextButton")
    local xPos = (i - 1) * 0.2
    btn.Size = UDim2.new(0.18, 0, 0, 50)
    btn.Position = UDim2.new(xPos, 0, 0, 0)
    btn.Text = i .. "档\n" .. flySpeeds[i]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextSize = 12
    btn.Parent = speedContainer
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 6)
    btnCorner2.Parent = btn
    
    speedBtns[i] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentSpeedLevel = i
        flySpeed = flySpeeds[currentSpeedLevel]
        speedDisplay.Text = "档位 " .. currentSpeedLevel .. "/5 | 速度 " .. flySpeed
        
        -- 高亮当前档位
        for j, b in pairs(speedBtns) do
            if j == currentSpeedLevel then
                b.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            else
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
        
        if flying then
            print("[飞行] 速度已切换至 " .. flySpeed)
        end
    end)
end

-- 高亮默认档位
speedBtns[1].BackgroundColor3 = Color3.fromRGB(255, 100, 0)

-- ========== 飞行开关逻辑 ==========
flyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    
    if flying then
        humanoid.PlatformStand = true
        bodyVelocity.Parent = rootPart
        flyToggle.Text = "飞行 (开启)"
        flyToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        print("[飞行] 已开启，当前速度：" .. flySpeed)
    else
        humanoid.PlatformStand = false
        bodyVelocity.Parent = nil
        flyToggle.Text = "飞行 (关闭)"
        flyToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        print("[飞行] 已关闭")
    end
end)

-- ========== 移动方向计算（手机摇杆 + 视角上下） ==========
local function getMoveDirection()
    local camera = workspace.CurrentCamera
    local moveDir = Vector3.new(0, 0, 0)
    
    -- 手机摇杆移动方向（MoveDirection 自动适配摇杆）
    local stickMove = humanoid.MoveDirection
    if stickMove.Magnitude > 0.1 then
        -- 将摇杆方向转换到相机空间
        local camForward = camera.CFrame.LookVector
        local camRight = camera.CFrame.RightVector
        camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
        camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
        
        moveDir = camForward * stickMove.Z + camRight * stickMove.X
    end
    
    -- 上下飞行：根据相机视角的上下方向
    -- 手机上：看天就向上飞，看地就向下飞
    local cameraLook = camera.CFrame.LookVector
    local verticalMove = cameraLook.Y
    if math.abs(verticalMove) > 0.3 then
        moveDir = moveDir + Vector3.new(0, verticalMove, 0)
    end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * flySpeed
    end
    return moveDir
end

-- ========== 菜单开关 ==========
local menuOpen = false
mainButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
end)

-- ========== 可拖动主按钮（手机触摸） ==========
local dragging = false
local dragStart
local buttonStart

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        buttonStart = mainButton.Position
    end
end)

mainButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        local newX = buttonStart.X.Offset + delta.X
        local newY = buttonStart.Y.Offset + delta.Y
        mainButton.Position = UDim2.new(buttonStart.X.Scale, newX, buttonStart.Y.Scale, newY)
    end
end)

-- ========== 飞行循环 ==========
rs.RenderStepped:Connect(function()
    if flying then
        bodyVelocity.Velocity = getMoveDirection()
    end
end)

-- ========== 防摔和无限跳跃（可选小功能） ==========
-- 防摔
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
-- 无限跳跃
uis.JumpRequest:Connect(function()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("[创世神VN] 加载完成！点击红色按钮打开菜单")