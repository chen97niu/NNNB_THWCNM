--[[
    创世神VN 飞行菜单 v2.1
    修复：多次注入不重复生成菜单
    修复：摇杆控制前后左右，视角控制上下，开启飞行后静止不动
--]]

-- ========== 防止重复加载 ==========
if _G.NNNBV2_Loaded then
    print("[创世神VN] 脚本已运行，无需重复加载")
    return
end
_G.NNNBV2_Loaded = true

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

-- ========== 检查是否已有UI ==========
local existingGui = player.PlayerGui:FindFirstChild("ChuangShiShenVN")
if existingGui then
    existingGui:Destroy()
end

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
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 255)
}
local colorIndex = 1
task.spawn(function()
    while screenGui and screenGui.Parent do
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
menuFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
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
        
        for j, b in pairs(speedBtns) do
            b.BackgroundColor3 = (j == currentSpeedLevel) and Color3.fromRGB(255, 100, 0) or Color3.fromRGB(60, 60, 60)
        end
        
        if flying then
            print("[飞行] 速度已切换至 " .. flySpeed)
        end
    end)
end
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

-- ========== 移动方向计算 ==========
-- 摇杆：控制前后左右
-- 视角：控制上下（向上看就上升，向下看就下降）
local function getMoveDirection()
    local camera = workspace.CurrentCamera
    local moveDir = Vector3.new(0, 0, 0)
    
    -- 1. 手机摇杆移动方向（控制前后左右）
    local stickMove = humanoid.MoveDirection
    if stickMove.Magnitude > 0.1 then
        -- 将摇杆方向转换到相机平面
        local camForward = camera.CFrame.LookVector
        local camRight = camera.CFrame.RightVector
        camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
        camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
        
        moveDir = (camForward * stickMove.Z + camRight * stickMove.X) * flySpeed
    end
    
    -- 2. 视角控制上下飞行（看天上升，看地下降）
    local cameraLook = camera.CFrame.LookVector
    local verticalInput = -cameraLook.Y  -- 向上看为正，向下看为负
    
    -- 死区：只有视角倾斜超过0.3时才触发上下飞
    if math.abs(verticalInput) > 0.3 then
        local verticalSpeed = verticalInput * flySpeed
        moveDir = moveDir + Vector3.new(0, verticalSpeed, 0)
    end
    
    return moveDir
end

-- ========== 菜单开关 ==========
local menuOpen = false
mainButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menuFrame.Visible = menuOpen
end)

-- ========== 可拖动主按钮 ==========
local dragging = false
local dragStart, buttonStart

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        buttonStart = mainButton.Position
    end
end)

mainButton.InputEnded:Connect(function(input)
    dragging = false
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(buttonStart.X.Scale, buttonStart.X.Offset + delta.X, buttonStart.Y.Scale, buttonStart.Y.Offset + delta.Y)
    end
end)

-- ========== 飞行循环 ==========
rs.RenderStepped:Connect(function()
    if flying and humanoid and rootPart and bodyVelocity then
        bodyVelocity.Velocity = getMoveDirection()
    end
end)

-- ========== 辅助功能 ==========
-- 防摔
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
-- 无限跳跃
uis.JumpRequest:Connect(function()
    if humanoid and not flying then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("[创世神VN] 加载完成！点击红色按钮打开菜单")
print("[操作说明] 摇杆=前后左右 | 视角向上看=上升 | 视角向下看=下降")