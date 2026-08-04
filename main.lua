-- ===================================================
-- Project: ypx Multi-Game Master Hub
-- Version: v1.15.2 (Production Stable Fix)
-- Developer: ypx
-- ===================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local set_clipboard = setclipboard or set_copy or (syn and syn.write_clipboard) or function() end
local open_url = openurl or opentarget or (syn and syn.open_url) or function(url) end
local write_file = writefile or (syn and syn.writefile)
local read_file = readfile or (syn and syn.readfile)
local is_file = isfile or (syn and syn.isfile)

local Config = {
    HubVersion = "1.15.2",
    KeySystemEnabled = true,
    UserKey = "ypx-vip-2026",
    ValidDurationHours = 24,
    KeyLink = "https://lootdest.org/s?kjLRWzSa",
    DiscordLink = "https://discord.gg/szQ573FFQ",
    SaveFileName = "YPX_Hub_KeyData.json"
}

if _G.YpxHubActiveInstance then
    pcall(function()
        _G.YpxHubActiveInstance:Destroy()
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YPX_LuxuryMasterHub"
ScreenGui.ResetOnSpawn = false
_G.YpxHubActiveInstance = ScreenGui

local uiParentSuccess, _ = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not uiParentSuccess then
    ScreenGui.Parent = PlayerGui
end

local function EnableSmoothDrag(guiObject)
    local dragging, dragInput, dragStart, startPos
    
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            RunService.Heartbeat:Wait()
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function CheckIsKeyValid()
    if not Config.KeySystemEnabled then return true end
    local success, isValid = pcall(function()
        if is_file and read_file and is_file(Config.SaveFileName) then
            local data = HttpService:JSONDecode(read_file(Config.SaveFileName))
            if data and data.Key == Config.UserKey and data.ExpireTime then
                if os.time() < data.ExpireTime then
                    return true 
                end
            end
        end
        return false
    end)
    if success then return isValid end
    return false 
end

local function SaveKeyData()
    if write_file then
        pcall(function()
            local expireTime = os.time() + (Config.ValidDurationHours * 3600)
            local data = { Key = Config.UserKey, ExpireTime = expireTime }
            write_file(Config.SaveFileName, HttpService:JSONEncode(data))
        end)
    end
end

local StartCoreEngine
local ShowKeyVerificationWindow
local FloatBall, MainFrame

local function ShowSplashLoadingScreen()
    local SplashFrame = Instance.new("Frame")
    SplashFrame.Name = "YpxSplashLoading"
    SplashFrame.Size = UDim2.new(0, 320, 0, 160)
    SplashFrame.Position = UDim2.new(0.5, -160, 0.4, -80)
    SplashFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    SplashFrame.BorderSizePixel = 0
    SplashFrame.Parent = ScreenGui

    local SplashCorner = Instance.new("UICorner")
    SplashCorner.CornerRadius = UDim.new(0, 16)
    SplashCorner.Parent = SplashFrame

    local SplashStroke = Instance.new("UIStroke")
    SplashStroke.Color = Color3.fromRGB(0, 240, 255)
    SplashStroke.Thickness = 2
    SplashStroke.Parent = SplashFrame

    EnableSmoothDrag(SplashFrame)

    local SplashTitle = Instance.new("TextLabel")
    SplashTitle.Size = UDim2.new(1, 0, 0, 35)
    SplashTitle.Position = UDim2.new(0, 0, 0, 20)
    SplashTitle.Text = "⚡ YPX LUXURY HUB"
    SplashTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    SplashTitle.TextSize = 14
    SplashTitle.Font = Enum.Font.GothamBold
    SplashTitle.BackgroundTransparency = 1
    SplashTitle.Parent = SplashFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -30, 0, 25)
    StatusLabel.Position = UDim2.new(0, 15, 0, 65)
    StatusLabel.Text = "正在初始化多端引擎与安全验证"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Parent = SplashFrame

    local CountdownLabel = Instance.new("TextLabel")
    CountdownLabel.Size = UDim2.new(1, 0, 0, 30)
    CountdownLabel.Position = UDim2.new(0, 0, 0, 105)
    CountdownLabel.Text = "3 秒后启动卡密验证界面..."
    CountdownLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
    CountdownLabel.TextSize = 10
    CountdownLabel.Font = Enum.Font.GothamBold
    CountdownLabel.BackgroundTransparency = 1
    CountdownLabel.Parent = SplashFrame

    task.spawn(function()
        pcall(function()
            for i = 3, 1, -1 do
                CountdownLabel.Text = i .. " 秒后启动卡密验证界面..."
                task.wait(1)
            end
        end)
        
        pcall(function()
            SplashFrame:Destroy()
        end)

        local isValid = CheckIsKeyValid()
        if isValid then
            StartCoreEngine()
        else
            ShowKeyVerificationWindow()
        end
    end)
end

ShowKeyVerificationWindow = function()
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "LuxuryLoginFrame"
    KeyFrame.Size = UDim2.new(0, 350, 0, 310)
    KeyFrame.Position = UDim2.new(0.5, -175, 0.3, 0)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = ScreenGui

    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 16)
    KeyCorner.Parent = KeyFrame

    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Color3.fromRGB(0, 240, 255)
    KeyStroke.Thickness = 2
    KeyStroke.Parent = KeyFrame

    EnableSmoothDrag(KeyFrame)

    local HeaderGlow = Instance.new("Frame")
    HeaderGlow.Size = UDim2.new(1, 0, 0, 48)
    HeaderGlow.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
    HeaderGlow.Parent = KeyFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = HeaderGlow

    local KeyTitleText = Instance.new("TextLabel")
    KeyTitleText.Size = UDim2.new(1, -20, 1, 0)
    KeyTitleText.Position = UDim2.new(0, 12, 0, 0)
    KeyTitleText.Text = "⚡ YPX LUXURY HUB v" .. Config.HubVersion .. " ( 高级登录系统 )"
    KeyTitleText.TextColor3 = Color3.fromRGB(0, 240, 255)
    KeyTitleText.TextSize = 12
    KeyTitleText.Font = Enum.Font.GothamBold
    KeyTitleText.BackgroundTransparency = 1
    KeyTitleText.TextXAlignment = Enum.TextXAlignment.Left
    KeyTitleText.Parent = HeaderGlow

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(1, -24, 0, 40)
    GetKeyBtn.Position = UDim2.new(0, 12, 0, 62)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    GetKeyBtn.Text = "🔑 获取卡密 ( 访问广告链接 )"
    GetKeyBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Parent = KeyFrame

    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn

    GetKeyBtn.MouseButton1Click:Connect(function()
        set_clipboard(Config.KeyLink)
        open_url(Config.KeyLink)
        GetKeyBtn.Text = "✓ 链接已复制到剪贴板！"
        task.wait(2)
        GetKeyBtn.Text = "🔑 获取卡密 ( 访问广告链接 )"
    end)

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -24, 0, 40)
    KeyInput.Position = UDim2.new(0, 12, 0, 112)
    KeyInput.BackgroundColor3 = Color3.fromRGB(20, 23, 33)
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "在此粘贴获取到的卡密..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 130, 150)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 11
    KeyInput.Font = Enum.Font.GothamMedium
    KeyInput.Parent = KeyFrame

    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 8)
    KeyInputCorner.Parent = KeyInput

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(1, -24, 0, 40)
    VerifyBtn.Position = UDim2.new(0, 12, 0, 162)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 120)
    VerifyBtn.Text = "🚀 验证并启动"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.TextSize = 12
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.Parent = KeyFrame

    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 8)
    VerifyCorner.Parent = VerifyBtn

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -24, 0, 25)
    StatusText.Position = UDim2.new(0, 12, 0, 210)
    StatusText.Text = "提示：验证成功后 24 小时内免验证"
    StatusText.TextColor3 = Color3.fromRGB(150, 160, 180)
    StatusText.TextSize = 10
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.BackgroundTransparency = 1
    StatusText.Parent = KeyFrame

    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Size = UDim2.new(1, -24, 0, 32)
    DiscordBtn.Position = UDim2.new(0, 12, 0, 246)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    DiscordBtn.Text = "💬 加入交流社区"
    DiscordBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
    DiscordBtn.TextSize = 10
    DiscordBtn.Font = Enum.Font.GothamMedium
    DiscordBtn.Parent = KeyFrame

    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 6)
    DiscordCorner.Parent = DiscordBtn

    DiscordBtn.MouseButton1Click:Connect(function()
        set_clipboard(Config.DiscordLink)
        open_url(Config.DiscordLink)
    end)

    VerifyBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == Config.UserKey then
            StatusText.Text = "✓ 验证成功！正在进入..."
            StatusText.TextColor3 = Color3.fromRGB(0, 240, 255)
            SaveKeyData()
            task.wait(0.5)
            KeyFrame:Destroy()
            StartCoreEngine()
        else
            StatusText.Text = "❌ 卡密错误，请重新获取"
            StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
end

local function BuildMainHubUI()
    FloatBall = Instance.new("TextButton")
    FloatBall.Name = "LuxuryFloatBall"
    FloatBall.Size = UDim2.new(0, 56, 0, 56)
    FloatBall.Position = UDim2.new(0.04, 0, 0.22, 0)
    FloatBall.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
    FloatBall.Text = "ypx⚡"
    FloatBall.TextSize = 16
    FloatBall.Font = Enum.Font.GothamBold
    FloatBall.TextColor3 = Color3.fromRGB(255, 255, 255)
    FloatBall.Active = true
    FloatBall.Parent = ScreenGui

    local BallCorner = Instance.new("UICorner")
    BallCorner.CornerRadius = UDim.new(1, 0)
    BallCorner.Parent = FloatBall

    local BallStroke = Instance.new("UIStroke")
    BallStroke.Color = Color3.fromRGB(0, 240, 255)
    BallStroke.Thickness = 2.5
    BallStroke.Parent = FloatBall

    EnableSmoothDrag(FloatBall)

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "LuxuryMainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 470)
    MainFrame.Position = UDim2.new(0.5, -175, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(0, 240, 255)
    MainStroke.Thickness = 1.8
    MainStroke.Parent = MainFrame

    EnableSmoothDrag(MainFrame)

    FloatBall.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
end

local TitleText
local CreateStandardTab, AddToggle, AddSlider, AddButton

local function InitUIFactory()
    BuildMainHubUI()

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 16)
    TitleCorner.Parent = TitleBar

    TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0.58, 0, 1, 0)
    TitleText.Position = UDim2.new(0.04, 0, 0, 0)
    TitleText.Text = "YPX HUB v" .. Config.HubVersion .. " ( 主面板 )"
    TitleText.TextColor3 = Color3.fromRGB(0, 240, 255)
    TitleText.TextSize = 12
    TitleText.Font = Enum.Font.GothamBold
    TitleText.BackgroundTransparency = 1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local AuthorText = Instance.new("TextLabel")
    AuthorText.Size = UDim2.new(0.38, 0, 1, 0)
    AuthorText.Position = UDim2.new(0.58, 0, 0, 0)
    AuthorText.Text = "Dev by ypx"
    AuthorText.TextColor3 = Color3.fromRGB(180, 100, 255)
    AuthorText.TextSize = 10
    AuthorText.Font = Enum.Font.GothamMedium
    AuthorText.BackgroundTransparency = 1
    AuthorText.TextXAlignment = Enum.TextXAlignment.Right
    AuthorText.Parent = TitleBar

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -16, 0, 34)
    TabBar.Position = UDim2.new(0, 8, 0, 50)
    TabBar.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
    TabBar.Parent = MainFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabBar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabBar

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -16, 1, -94)
    PagesContainer.Position = UDim2.new(0, 8, 0, 88)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainFrame

    local tabs = {}
    CreateStandardTab = function(name)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
        page.Visible = false
        page.Parent = PagesContainer

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.Parent = page

        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
        end)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 46, 0.82, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(140, 150, 170)
        tabBtn.TextSize = 9
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = TabBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
                t.Button.TextColor3 = Color3.fromRGB(140, 150, 170)
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
            tabBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
        end)

        table.insert(tabs, {Page = page, Button = tabBtn})
        if #tabs == 1 then
            page.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
            tabBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
        end
        return page
    end

    AddToggle = function(parent, text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.72, 0, 1, 0)
        label.Position = UDim2.new(0.04, 0, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 235, 245)
        label.TextSize = 10
        label.Font = Enum.Font.GothamMedium
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 20)
        btn.Position = UDim2.new(1, -46, 0.5, -10)
        btn.Text = ""
        btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        btn.Parent = frame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = btn

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0, 3, 0.5, -7)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Parent = btn

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(35, 40, 55)
            dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            task.spawn(function()
                pcall(callback, state)
            end)
        end)
    end

    AddSlider = function(parent, text, minVal, maxVal, defaultVal, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 48)
        frame.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -12, 0, 18)
        label.Position = UDim2.new(0, 6, 0, 4)
        label.Text = text .. " : " .. tostring(defaultVal)
        label.TextColor3 = Color3.fromRGB(230, 235, 245)
        label.TextSize = 10
        label.Font = Enum.Font.GothamMedium
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(1, -12, 0, 8)
        bar.Position = UDim2.new(0, 6, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
        bar.Text = ""
        bar.AutoButtonColor = false
        bar.Parent = frame

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        fill.Parent = bar

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local sliding = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(minVal + (maxVal - minVal) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. " : " .. tostring(val)
            task.spawn(function()
                pcall(callback, val)
            end)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                Update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end)
    end

    AddButton = function(parent, text, bgColor, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 36)
        btn.BackgroundColor3 = bgColor or Color3.fromRGB(30, 35, 50)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            task.spawn(function()
                pcall(callback)
            end)
        end)
        return btn
    end
end

local function LoadUniversalInterface()
    TitleText.Text = "UNIVERSAL MODS ( 通用修改 )"
    
    local PagePlayer = CreateStandardTab("👤 角色 ( Player )")
    local PageMovement = CreateStandardTab("🏃 移动 ( Move )")
    local PageVisual = CreateStandardTab("👁️ 视觉 ( Visual )")

    AddSlider(PagePlayer, "WalkSpeed ( 玩家移动速度 )", 16, 300, 16, function(val)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end)

    AddSlider(PagePlayer, "JumpPower ( 跳跃高度 )", 50, 300, 50, function(val)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
            char.Humanoid.UseJumpPower = true
        end
    end)

    AddToggle(PagePlayer, "Infinite Jump ( 无限连跳 )", function(val)
        _G.InfJumpYpx = val
        if not _G.InfJumpConn then
            _G.InfJumpConn = UserInputService.JumpRequest:Connect(function()
                if _G.InfJumpYpx then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end)

    AddToggle(PagePlayer, "Anti-AFK ( 防挂机踢出 )", function(val)
        _G.AntiAfkYpx = val
        task.spawn(function()
            while _G.AntiAfkYpx do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(30)
            end
        end)
    end)

    AddToggle(PageMovement, "Noclip ( 角色穿墙 )", function(val)
        _G.NoclipYpx = val
        task.spawn(function()
            while _G.NoclipYpx do
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)

    AddToggle(PageMovement, "Touch Fly ( 手机端触控飞行 )", function(val)
        _G.FlyingYpx = val
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if _G.FlyingYpx then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "YpxFlyBV"
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            task.spawn(function()
                while _G.FlyingYpx and hrp:FindFirstChild("YpxFlyBV") do
                    local cam = Workspace.CurrentCamera
                    hrp.YpxFlyBV.Velocity = cam.CFrame.LookVector * 50
                    task.wait(0.02)
                end
                if hrp:FindFirstChild("YpxFlyBV") then hrp.YpxFlyBV:Destroy() end
            end)
        else
            if hrp:FindFirstChild("YpxFlyBV") then hrp.YpxFlyBV:Destroy() end
        end
    end)

    AddSlider(PageVisual, "Field of View ( 广角视野 )", 70, 120, 70, function(val)
        Workspace.CurrentCamera.FieldOfView = val
    end)
end

local function LoadAnimeIncrementalInterface()
    TitleText.Text = "ANIME INCREMENTAL ( 动漫增量 )"

    local function GetDynamicRemote(sName, isFunc)
        local success, res = pcall(function()
            if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") then
                for _, child in pairs(ReplicatedStorage.Packages._Index:GetChildren()) do
                    if string.find(child.Name, "networker") then
                        local remotes = child:FindFirstChild("networker") and child.networker:FindFirstChild("_remotes")
                        if remotes then
                            local s = remotes:FindFirstChild(sName)
                            if s then
                                return isFunc and s:FindFirstChild("RemoteFunction") or s:FindFirstChild("RemoteEvent")
                            end
                        end
                    end
                end
            end
        end)
        return success and res or nil
    end

    local PageMain = CreateStandardTab("⚡ 挂机 ( Auto )")
    local PagePotions = CreateStandardTab("🧪 药水 ( Potion )")
    local PageUpgrades = CreateStandardTab("📈 属性 ( Max Up )")
    local PageCards = CreateStandardTab("🎴 卡包 ( Cards )")
    local PageNinja = CreateStandardTab("👁️ 血统 ( Blood )")
    local PageTeleport = CreateStandardTab("📍 传送 ( Teleport )")

    AddToggle(PageMain, "ClickerService ( 自动点击器 )", function(val)
        local r = GetDynamicRemote("ClickerService", false)
        if r then r:FireServer("SetAutoClickEnabled", val) end
    end)

    AddToggle(PageMain, "ConvertMax ( 自动最大化转换能量 )", function(val)
        _G.AutoConvertMaxypx = val
        task.spawn(function()
            local r = GetDynamicRemote("CondensedEnergyService", false)
            while _G.AutoConvertMaxypx do
                if r then pcall(function() r:FireServer("ConvertMax") end) end
                task.wait(0.1)
            end
        end)
    end)

    AddToggle(PageMain, "PickupAura & Orb ( 自动收集光环 )", function(val)
        _G.AutoOrbAuraypx = val
        task.spawn(function()
            local orb = GetDynamicRemote("OrbService", false)
            local aura = GetDynamicRemote("PickupAuraService", false)
            while _G.AutoOrbAuraypx do
                if orb then pcall(function() orb:FireServer() end) end
                if aura then pcall(function() aura:FireServer() end) end
                task.wait(0.05)
            end
        end)
    end)

    AddToggle(PageMain, "AntiAfkService ( 防挂机踢出 )", function(val)
        _G.AntiAfkypx = val
        task.spawn(function()
            local r = GetDynamicRemote("AntiAfkService", false)
            while _G.AntiAfkypx do
                if r then pcall(function() r:FireServer() end) end
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(30)
            end
        end)
    end)

    local inventoryFunc = GetDynamicRemote("InventoryService", true)
    local potionList = {
        {"CardLuckPotion", "🍀 Card Luck Potion ( 抽卡幸运药水 )"},
        {"CardBulkPotion", "📦 Card Bulk Potion ( 抽卡数量药水 )"},
        {"CardSpeedPotion", "⚡ Card Speed Potion ( 抽卡速度药水 )"},
        {"WalkspeedPotion", "🏃 Walkspeed Potion ( 移速药水 )"}
    }

    AddToggle(PagePotions, "🔥 Use All Potions ( 全药水无限自动连用 )", function(val)
        _G.AutoUseAllPotionsypx = val
        task.spawn(function()
            while _G.AutoUseAllPotionsypx do
                if inventoryFunc then
                    for _, p in ipairs(potionList) do pcall(function() inventoryFunc:InvokeServer("UseItem", p[1], 1) end) end
                end
                task.wait(1)
            end
        end)
    end)

    for _, p in ipairs(potionList) do
        local id, name = p[1], p[2]
        AddToggle(PagePotions, "Auto Potion : " .. name, function(val)
            _G["AutoPot_" .. id] = val
            task.spawn(function()
                while _G["AutoPot_" .. id] do
                    if inventoryFunc then pcall(function() inventoryFunc:InvokeServer("UseItem", id, 1) end) end
                    task.wait(1)
                end
            end)
        end)
    end

    local upgradeRemote = GetDynamicRemote("UpgradeService", true)
    local levelRemote = GetDynamicRemote("LevelService", true) or GetDynamicRemote("LevelService", false)
    local upgradeList = {
        {"NatureMultiplier", "Nature Multiplier ( 自然能量倍率 )"},
        {"NatureChakraMultiplier", "Chakra Multiplier ( 自然查克拉倍率 )"},
        {"NatureExperienceMultiplier", "Nature Exp Multiplier ( 自然经验倍率 )"},
        {"ClickerMultiplier", "Clicker Multiplier ( 基础点击倍率 )"},
        {"DailyClickerMultiplier", "Daily Clicker Multiplier ( 每日点击倍率 )"},
        {"DailyMeditationMultiplier", "Daily Meditation Multiplier ( 每日冥想倍率 )"},
        {"CondensedExperienceMultiplier", "Condensed Exp Multiplier ( 凝聚经验倍率 )"},
        {"CondensedNatureMultiplier", "Condensed Nature Multiplier ( 凝聚自然倍率 )"},
        {"MeditationGain", "Meditation Gain ( 冥想收益增幅 )"},
        {"MeditationExperienceInsight", "Meditation Exp Insight ( 冥想经验洞察 )"},
        {"MeditationAdventureDamage", "Meditation Adventure Damage ( 冥想冒险伤害 )"},
        {"LevelAdventureDamage", "Level Adventure Damage ( 等级冒险伤害 )"},
        {"AdventureDamage", "Adventure Damage ( 基础冒险伤害 )"},
        {"SkillMeditationFocus", "Skill Meditation Focus ( 技能冥想专注 )"},
        {"LevelClickerPower", "Level Clicker Power ( 等级点击力量 )"},
        {"LevelEyeSpeed", "Level Eye Speed ( 等级瞳术速度 )"},
        {"LevelEyeLuck", "Level Eye Luck ( 等级瞳术幸运 )"}
    }

    AddToggle(PageUpgrades, "🔥 Max All Upgrades ( 一键极速属性拉满 )", function(val)
        _G.AutoUpgradeAllypx = val
        task.spawn(function()
            while _G.AutoUpgradeAllypx do
                if upgradeRemote then
                    for _, item in ipairs(upgradeList) do
                        pcall(function()
                            upgradeRemote:InvokeServer("AttemptUpgrade", item[1], 4)
                        end)
                    end
                end
                task.wait(0.02)
            end
        end)
    end)

    AddToggle(PageUpgrades, "LevelUp Service ( 自动提升角色等级 )", function(val)
        _G.AutoLevelUpypx = val
        task.spawn(function()
            while _G.AutoLevelUpypx do
                if levelRemote then
                    pcall(function()
                        if levelRemote:IsA("RemoteFunction") then levelRemote:InvokeServer("LevelUp")
                        else levelRemote:FireServer("LevelUp") end
                    end)
                end
                task.wait(0.1)
            end
        end)
    end)

    AddButton(PageUpgrades, "⚠️ Reset Hourglass Upgrades ( 重置沙漏升级 )", Color3.fromRGB(180, 50, 50), function()
        if upgradeRemote then upgradeRemote:InvokeServer("ResetHourglassUpgrades") end
    end)

    for _, item in ipairs(upgradeList) do
        local key, name = item[1], item[2]
        AddToggle(PageUpgrades, "Auto Upgrade : " .. name, function(val)
            _G["AutoUp_" .. key] = val
            task.spawn(function()
                while _G["AutoUp_" .. key] do
                    if upgradeRemote then pcall(function() upgradeRemote:InvokeServer("AttemptUpgrade", key, 4) end) end
                    task.wait(0.02)
                end
            end)
        end)
    end)

    AddToggle(PageCards, "CardPackService ( 全卡包后台自动抽卡 )", function(val)
        _G.AutoCardPackypx = val
        task.spawn(function()
            local cardRemote = GetDynamicRemote("CardPackService", false)
            local cardFunc = GetDynamicRemote("CardPackService", true)
            local packNames = {"Shinobi Starter Pack", "Rogue Shadows Pack", "Starter", "Basic", "Advanced", "World2"}
            while _G.AutoCardPackypx do
                pcall(function()
                    for _, p in ipairs(packNames) do
                        if cardRemote then cardRemote:FireServer("Buy", p, 18); cardRemote:FireServer("Open", p, 18) end
                        if cardFunc then cardFunc:InvokeServer("Buy", p, 18) end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end)

    AddToggle(PageNinja, "BloodlineService ( 自动重抽血统 )", function(val)
        _G.AutoBloodlineypx = val
        task.spawn(function()
            local r = GetDynamicRemote("BloodlineService", true) or GetDynamicRemote("BloodlineService", false)
            while _G.AutoBloodlineypx do
                if r then pcall(function() if r:IsA("RemoteFunction") then r:InvokeServer("RequestRerollBloodline") else r:FireServer("RequestRerollBloodline") end end) end
                task.wait(0.1)
            end
        end)
    end)

    AddToggle(PageNinja, "EyeService ( 自动重抽瞳术 )", function(val)
        _G.AutoEyeypx = val
        task.spawn(function()
            local r = GetDynamicRemote("EyeService", true) or GetDynamicRemote("EyeService", false)
            while _G.AutoEyeypx do
                if r then pcall(function() if r:IsA("RemoteFunction") then r:InvokeServer("RequestRerollEye") else r:FireServer("RequestRerollEye") end end) end
                task.wait(0.1)
            end
        end)
    end)

    AddButton(PageTeleport, "🔄 Scan Map & Stations ( 智能扫描地图站台与刷怪点 )", Color3.fromRGB(0, 150, 200), function()
        for _, child in pairs(PageTeleport:GetChildren()) do 
            if child:IsA("Frame") and child.Name == "PackItem" then 
                child:Destroy() 
            end 
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (string.find(obj.Name, "Pack") or string.find(obj.Name, "Platform") or string.find(obj.Name, "Starter") or string.find(obj.Name, "Stage") or string.find(obj.Name, "Adventure")) then
                local packFrame = Instance.new("Frame")
                packFrame.Name = "PackItem"
                packFrame.Size = UDim2.new(1, -6, 0, 38)
                packFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                packFrame.Parent = PageTeleport
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = packFrame
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.60, 0, 1, 0)
                label.Position = UDim2.new(0.04, 0, 0, 0)
                label.Text = "📍 " .. obj.Name
                label.TextColor3 = Color3.fromRGB(230, 235, 245)
                label.TextSize = 10
                label.Font = Enum.Font.GothamMedium
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.Parent = packFrame
                
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0.32, 0, 0.75, 0)
                tpBtn.Position = UDim2.new(0.64, 0, 0.125, 0)
                tpBtn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
                tpBtn.Text = "Teleport ( 立即传送 )"
                tpBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
                tpBtn.TextSize = 9
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.Parent = packFrame
                
                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 6)
                bCorner.Parent = tpBtn
                
                tpBtn.MouseButton1Click:Connect(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    end
                end)
            end
        end
    end)
end

StartCoreEngine = function()
    InitUIFactory()

    local SupportedGames = {
        [79708985160875] = LoadAnimeIncrementalInterface,
    }

    local currentGameId = game.PlaceId
    local loadedGameAdapter = false

    for placeId, adapterFunc in pairs(SupportedGames) do
        if currentGameId == placeId then
            adapterFunc()
            loadedGameAdapter = true
            break
        end
    end

    if not loadedGameAdapter then
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("_Index") then
            local index = ReplicatedStorage.Packages._Index
            for _, child in pairs(index:GetChildren()) do
                if string.find(child.Name, "networker") then
                    LoadAnimeIncrementalInterface()
                    loadedGameAdapter = true
                    break
                end
            end
        end
    end

    if not loadedGameAdapter then
        LoadUniversalInterface()
    end
end

ShowSplashLoadingScreen()
