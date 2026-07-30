-- إنشاء الواجهة الرسومية (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ElementsContainer = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الشاشة الأساسية
ScreenGui.Name = "DeltaCustomGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- إعدادات الإطار الرئيسي
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 350, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل ميزة سحب الواجهة بإصبعك

-- عنوان الواجهة
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "DELTA CUSTOM MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- حاوية العناصر (قائمة قابلة للتمرير)
ElementsContainer.Name = "ElementsContainer"
ElementsContainer.Parent = MainFrame
ElementsContainer.BackgroundTransparency = 1
ElementsContainer.Position = UDim2.new(0, 10, 0, 50)
ElementsContainer.Size = UDim2.new(1, -20, 1, -60)
ElementsContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
ElementsContainer.ScrollBarThickness = 4

UIListLayout.Parent = ElementsContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- دالة مساعدة لإنشاء الأزرار بسهولة
local function createButton(name, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = ElementsContainer
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 16
    
    -- إضافة تأثير بسيط عند الضغط
    button.MouseButton1Click:Connect(callback)
    return button
end

-- دالة مساعدة لإنشاء حقول الإدخال (السرعة والقفز)
local function createTextBox(name, placeholder, callback)
    local textBox = Instance.new("TextBox")
    textBox.Name = name
    textBox.Parent = ElementsContainer
    textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    textBox.Size = UDim2.new(1, 0, 0, 40)
    textBox.Font = Enum.Font.SourceSans
    textBox.PlaceholderText = placeholder
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextSize = 16
    
    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)
    return textBox
end

-- 1. حقل تعديل السرعة (Speed)
createTextBox("SpeedInput", "أدخل السرعة المخصصة واضغط Enter", function(value)
    local num = tonumber(value)
    if num then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num
    end
end)

-- 2. حقل تعديل قوة القفز (Jump Power)
createTextBox("JumpInput", "أدخل قوة القفز واضغط Enter", function(value)
    local num = tonumber(value)
    if num then
        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        humanoid.UseJumpPower = true
        humanoid.JumpPower = num
    end
end)

-- 3. زر اختراق الجدران (Noclip)
local noclipActive = false
createButton("NoclipBtn", "اختراق الجدران: معطل", function(btn)
    noclipActive = not noclipActive
    local button = ElementsContainer:FindFirstChild("NoclipBtn")
    if noclipActive then
        button.Text = "اختراق الجدران: مفعّل"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        button.Text = "اختراق الجدران: معطل"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 4. زر الدوران المستمر (Spin Bot)
local spinActive = false
local spinVelocity
createButton("SpinBtn", "دوران شخصية: معطل", function()
    spinActive = not spinActive
    local button = ElementsContainer:FindFirstChild("SpinBtn")
    local character = game.Players.LocalPlayer.Character
    
    if spinActive and character and character:FindFirstChild("HumanoidRootPart") then
        button.Text = "دوران شخصية: مفعّل"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        spinVelocity = Instance.new("BodyAngularVelocity")
        spinVelocity.Name = "Spinning"
        spinVelocity.Parent = character.HumanoidRootPart
        spinVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        spinVelocity.AngularVelocity = Vector3.new(0, 50, 0) -- سرعة الدوران
    else
        button.Text = "دوران شخصية: معطل"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        if character and character.HumanoidRootPart:FindFirstChild("Spinning") then
            character.HumanoidRootPart.Spinning:Destroy()
        end
    end
end)

-- 5. زر القفز اللانهائي (Infinite Jump)
local infJumpActive = false
createButton("InfJumpBtn", "قفز لانهائي: معطل", function()
    infJumpActive = not infJumpActive
    local button = ElementsContainer:FindFirstChild("InfJumpBtn")
    if infJumpActive then
        button.Text = "قفز لانهائي: مفعّل"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        button.Text = "قفز لانهائي: معطل"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpActive and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

-- 6. زر منظور الرؤية (FOV 120)
local fovActive = false
createButton("FovBtn", "منظور POV 120: عادي", function()
    fovActive = not fovActive
    local button = ElementsContainer:FindFirstChild("FovBtn")
    if fovActive then
        button.Text = "منظور POV 120: مفعّل"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        game.Workspace.CurrentCamera.FieldOfView = 120
    else
        button.Text = "منظور POV 120: عادي"
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        game.Workspace.CurrentCamera.FieldOfView = 70 -- إرجاع المنظور الافتراضي
    end
end)
