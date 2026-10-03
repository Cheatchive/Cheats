local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local UILibrary = {}

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------

local Theme = {
    Background = Color3.fromRGB(20, 20, 23),
    Sidebar = Color3.fromRGB(25, 25, 29),
    Surface = Color3.fromRGB(30, 30, 34),
    SurfaceHover = Color3.fromRGB(38, 38, 43),

    Text = Color3.fromRGB(245, 245, 247),
    SubText = Color3.fromRGB(160, 160, 168),

    Accent = Color3.fromRGB(0, 120, 215),
    AccentHover = Color3.fromRGB(30, 140, 230),

    Border = Color3.fromRGB(55, 55, 62),
    Divider = Color3.fromRGB(45, 45, 51),

    Success = Color3.fromRGB(76, 175, 80),
    Danger = Color3.fromRGB(220, 70, 70),

    Corner = 8,
}

local function Tween(instance, properties, duration)
    local info = TweenInfo.new(
        duration or 0.15,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    return TweenService:Create(instance, info, properties)
end

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Theme.Corner)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0
    stroke.Parent = parent
    return stroke
end

local function Padding(parent, amount)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, amount)
    padding.PaddingBottom = UDim.new(0, amount)
    padding.PaddingLeft = UDim.new(0, amount)
    padding.PaddingRight = UDim.new(0, amount)
    padding.Parent = parent
    return padding
end

local function NewText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")

    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = color or Theme.Text
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent

    return label
end

----------------------------------------------------------------
-- SCREEN GUI
----------------------------------------------------------------

function UILibrary:CreateWindow(title, options)
    options = options or {}

    local size = options.Size or {
        X = 600,
        Y = 400
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WinUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)

    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    ------------------------------------------------------------
    -- MAIN WINDOW
    ------------------------------------------------------------

    local Main = Instance.new("Frame")
    Main.Name = "Window"
    Main.Size = UDim2.fromOffset(size.X, size.Y)
    Main.Position = UDim2.new(
        0.5,
        -size.X / 2,
        0.5,
        -size.Y / 2
    )
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Corner(Main, 12)
    Stroke(Main, Theme.Border, 1)

    ------------------------------------------------------------
    -- TITLE BAR
    ------------------------------------------------------------

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main

    local Title = NewText(
        TitleBar,
        title or "WinUI",
        14,
        Theme.Text,
        Enum.Font.GothamMedium
    )

    Title.Position = UDim2.fromOffset(18, 0)
    Title.Size = UDim2.new(1, -130, 1, 0)

    ------------------------------------------------------------
    -- WINDOW CONTROLS
    ------------------------------------------------------------

    local Minimize = Instance.new("TextButton")
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.fromOffset(38, 30)
    Minimize.Position = UDim2.new(1, -82, 0, 6)
    Minimize.BackgroundTransparency = 1
    Minimize.Text = "—"
    Minimize.TextSize = 17
    Minimize.TextColor3 = Theme.SubText
    Minimize.Font = Enum.Font.Gotham
    Minimize.AutoButtonColor = false
    Minimize.Parent = TitleBar

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Size = UDim2.fromOffset(38, 30)
    Close.Position = UDim2.new(1, -42, 0, 6)
    Close.BackgroundTransparency = 1
    Close.Text = "×"
    Close.TextSize = 19
    Close.TextColor3 = Theme.SubText
    Close.Font = Enum.Font.Gotham
    Close.AutoButtonColor = false
    Close.Parent = TitleBar

    Close.MouseEnter:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Theme.Danger,
            TextColor3 = Color3.new(1, 1, 1)
        }):Play()

        Corner(Close, 6)
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundTransparency = 1,
            TextColor3 = Theme.SubText
        }):Play()
    end)

    ------------------------------------------------------------
    -- DRAGGING
    ------------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    ------------------------------------------------------------
    -- CONTENT AREA
    ------------------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.fromOffset(0, 42)
    Content.Size = UDim2.new(1, 0, 1, -42)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    ------------------------------------------------------------
    -- SIDEBAR
    ------------------------------------------------------------

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.fromOffset(155, 1)
    Sidebar.Size = UDim2.new(0, 155, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Content

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Theme.Divider
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    ------------------------------------------------------------
    -- TAB HOLDER
    ------------------------------------------------------------

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "Tabs"
    TabHolder.Position = UDim2.fromOffset(8, 12)
    TabHolder.Size = UDim2.new(1, -16, 1, -24)
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.ScrollBarThickness = 0
    TabHolder.CanvasSize = UDim2.new()
    TabHolder.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabHolder

    ------------------------------------------------------------
    -- PAGE AREA
    ------------------------------------------------------------

    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Position = UDim2.fromOffset(155, 0)
    Pages.Size = UDim2.new(1, -155, 1, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Content

    ------------------------------------------------------------
    -- WINDOW OBJECT
    ------------------------------------------------------------

    local Window = {}

    Window.Gui = ScreenGui
    Window.Frame = Main
    Window.Pages = Pages
    Window.TabHolder = TabHolder
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false

    ------------------------------------------------------------
    -- CLOSE
    ------------------------------------------------------------

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    ------------------------------------------------------------
    -- MINIMIZE
    ------------------------------------------------------------

    Minimize.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized

        if Window.Minimized then
            Content.Visible = false

            Tween(Main, {
                Size = UDim2.fromOffset(size.X, 42)
            }):Play()
        else
            Content.Visible = true

            Tween(Main, {
                Size = UDim2.fromOffset(size.X, size.Y)
            }):Play()
        end
    end)

    ------------------------------------------------------------
    -- CREATE TAB
    ------------------------------------------------------------

    function Window:CreateTab(tabName, icon)
        local Tab = {}

        --------------------------------------------------------
        -- SIDEBAR BUTTON
        --------------------------------------------------------

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Theme.Sidebar
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabHolder

        Corner(TabButton, 7)

        local Icon = NewText(
            TabButton,
            icon or "●",
            15,
            Theme.SubText,
            Enum.Font.Gotham
        )

        Icon.Size = UDim2.fromOffset(32, 36)
        Icon.Position = UDim2.fromOffset(4, 0)
        Icon.TextXAlignment = Enum.TextXAlignment.Center

        local TabLabel = NewText(
            TabButton,
            tabName,
            13,
            Theme.SubText,
            Enum.Font.GothamMedium
        )

        TabLabel.Position = UDim2.fromOffset(38, 0)
        TabLabel.Size = UDim2.new(1, -42, 1, 0)

        --------------------------------------------------------
        -- PAGE
        --------------------------------------------------------

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Border
        Page.CanvasSize = UDim2.new()
        Page.Visible = false
        Page.Parent = Pages

        Padding(Page, 18)

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 9)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.fromOffset(
                0,
                Layout.AbsoluteContentSize.Y + 30
            )
        end)

        Tab.Page = Page
        Tab.Button = TabButton

        --------------------------------------------------------
        -- SELECT TAB
        --------------------------------------------------------

        function Tab:Select()
            for _, other in pairs(Window.Tabs) do
                other.Page.Visible = false

                Tween(other.Button, {
                    BackgroundTransparency = 1
                }):Play()

                Tween(other.Button:FindFirstChildOfClass("TextLabel"), {
                    TextColor3 = Theme.SubText
                }):Play()

                local labels = other.Button:GetChildren()

                for _, child in ipairs(labels) do
                    if child:IsA("TextLabel") then
                        Tween(child, {
                            TextColor3 = Theme.SubText
                        }):Play()
                    end
                end
            end

            Page.Visible = true

            Tween(TabButton, {
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.82
            }):Play()

            for _, child in ipairs(TabButton:GetChildren()) do
                if child:IsA("TextLabel") then
                    Tween(child, {
                        TextColor3 = Theme.Text
                    }):Play()
                end
            end

            Window.CurrentTab = Tab
        end

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {
                    BackgroundColor3 = Theme.SurfaceHover,
                    BackgroundTransparency = 0
                }):Play()
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {
                    BackgroundTransparency = 1
                }):Play()
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        --------------------------------------------------------
        -- LABEL
        --------------------------------------------------------

        function Tab:AddLabel(text)
            local Label = NewText(
                Page,
                text,
                13,
                Theme.SubText,
                Enum.Font.Gotham
            )

            Label.Size = UDim2.new(1, 0, 0, 28)

            return Label
        end

        --------------------------------------------------------
        -- SECTION
        --------------------------------------------------------

        function Tab:AddSection(text)
            local Section = NewText(
                Page,
                text,
                12,
                Theme.SubText,
                Enum.Font.GothamMedium
            )

            Section.Size = UDim2.new(1, 0, 0, 25)
            Section.Text = string.upper(text)

            return Section
        end

        --------------------------------------------------------
        -- BUTTON
        --------------------------------------------------------

        function Tab:AddButton(data)
            data = data or {}

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 42)
            Button.BackgroundColor3 = Theme.Surface
            Button.BorderSizePixel = 0
            Button.Text = data.Text or "Button"
            Button.TextColor3 = Theme.Text
            Button.TextSize = 13
            Button.Font = Enum.Font.GothamMedium
            Button.AutoButtonColor = false
            Button.Parent = Page

            Corner(Button, Theme.Corner)
            Stroke(Button, Theme.Border)

            Button.MouseEnter:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.SurfaceHover
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, {
                    BackgroundColor3 = Theme.Surface
                }):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                if data.Callback then
                    task.spawn(data.Callback)
                end
            end)

            return Button
        end

        --------------------------------------------------------
        -- TOGGLE
        --------------------------------------------------------

        function Tab:AddToggle(data)
            data = data or {}

            local enabled = data.Default == true

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, 48)
            Holder.BackgroundColor3 = Theme.Surface
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, Theme.Corner)
            Stroke(Holder, Theme.Border)

            local Label = NewText(
                Holder,
                data.Text or "Toggle",
                13,
                Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(14, 0)
            Label.Size = UDim2.new(1, -75, 1, 0)

            ----------------------------------------------------
            -- SWITCH
            ----------------------------------------------------

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.fromOffset(42, 22)
            Switch.Position = UDim2.new(1, -56, 0.5, -11)
            Switch.BackgroundColor3 = enabled
                and Theme.Accent
                or Color3.fromRGB(70, 70, 77)

            Switch.Text = ""
            Switch.AutoButtonColor = false
            Switch.Parent = Holder

            Corner(Switch, 11)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.fromOffset(16, 16)
            Knob.Position = enabled
                and UDim2.new(1, -19, 0.5, -8)
                or UDim2.fromOffset(3, 3)

            Knob.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            Knob.BorderSizePixel = 0
            Knob.Parent = Switch

            Corner(Knob, 8)

            local function UpdateToggle()
                Tween(Switch, {
                    BackgroundColor3 = enabled
                        and Theme.Accent
                        or Color3.fromRGB(70, 70, 77)
                }):Play()

                Tween(Knob, {
                    Position = enabled
                        and UDim2.new(1, -19, 0.5, -8)
                        or UDim2.fromOffset(3, 3)
                }):Play()

                if data.Callback then
                    task.spawn(data.Callback, enabled)
                end
            end

            Switch.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateToggle()
            end)

            function Tab:UpdateToggle(value)
                enabled = value == true
                UpdateToggle()
            end

            return Holder
        end

        --------------------------------------------------------
        -- SLIDER
        --------------------------------------------------------

        function Tab:AddSlider(data)
            data = data or {}

            local min = data.Min or 0
            local max = data.Max or 100
            local value = data.Default or min

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, 65)
            Holder.BackgroundColor3 = Theme.Surface
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, Theme.Corner)
            Stroke(Holder, Theme.Border)

            local Label = NewText(
                Holder,
                data.Text or "Slider",
                13,
                Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(14, 5)
            Label.Size = UDim2.new(1, -80, 0, 25)

            local ValueLabel = NewText(
                Holder,
                tostring(value),
                12,
                Theme.SubText,
                Enum.Font.Gotham
            )

            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.Size = UDim2.fromOffset(45, 25)
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(1, -28, 0, 5)
            Bar.Position = UDim2.fromOffset(14, 45)
            Bar.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
            Bar.BorderSizePixel = 0
            Bar.Parent = Holder

            Corner(Bar, 3)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(
                math.clamp((value - min) / (max - min), 0, 1),
                0,
                1,
                0
            )
            Fill.BackgroundColor3 = Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar

            Corner(Fill, 3)

            local draggingSlider = false

            local function SetValueFromMouse()
                local mouse = UserInputService:GetMouseLocation()
                local relative = mouse.X - Bar.AbsolutePosition.X

                local percent = math.clamp(
                    relative / Bar.AbsoluteSize.X,
                    0,
                    1
                )

                value = min + ((max - min) * percent)

                if data.Rounding then
                    local rounding = data.Rounding
                    value = math.floor(
                        value / rounding + 0.5
                    ) * rounding
                else
                    value = math.floor(value + 0.5)
                end

                ValueLabel.Text = tostring(value)

                Tween(Fill, {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()

                if data.Callback then
                    task.spawn(data.Callback, value)
                end
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    SetValueFromMouse()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and
                    input.UserInputType == Enum.UserInputType.MouseMovement then

                    SetValueFromMouse()
                end
            end)

            return Holder
        end

        --------------------------------------------------------
        -- DROPDOWN
        --------------------------------------------------------

        function Tab:AddDropdown(data)
            data = data or {}

            local options = data.Options or {}
            local selected = data.Default or options[1]

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, 48)
            Holder.BackgroundColor3 = Theme.Surface
            Holder.BorderSizePixel = 0
            Holder.ClipsDescendants = true
            Holder.Parent = Page

            Corner(Holder, Theme.Corner)
            Stroke(Holder, Theme.Border)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 48)
            Button.BackgroundTransparency = 1
            Button.Text = ""
            Button.Parent = Holder

            local Label = NewText(
                Button,
                data.Text or "Dropdown",
                13,
                Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(14, 0)
            Label.Size = UDim2.new(0.55, 0, 1, 0)

            local Current = NewText(
                Button,
                tostring(selected or "Select"),
                12,
                Theme.SubText,
                Enum.Font.Gotham
            )

            Current.Position = UDim2.new(0.55, 0, 0, 0)
            Current.Size = UDim2.new(0.38, -5, 1, 0)
            Current.TextXAlignment = Enum.TextXAlignment.Right

            local Arrow = NewText(
                Button,
                "⌄",
                16,
                Theme.SubText,
                Enum.Font.Gotham
            )

            Arrow.Position = UDim2.new(1, -28, 0, 0)
            Arrow.Size = UDim2.fromOffset(20, 48)
            Arrow.TextXAlignment = Enum.TextXAlignment.Center

            local List = Instance.new("Frame")
            List.Position = UDim2.fromOffset(10, 48)
            List.Size = UDim2.new(1, -20, 0, 0)
            List.BackgroundColor3 = Theme.Background
            List.BorderSizePixel = 0
            List.Visible = true
            List.Parent = Holder

            Corner(List, 6)
            Stroke(List, Theme.Border)

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = List

            for _, option in ipairs(options) do
                local Option = Instance.new("TextButton")
                Option.Size = UDim2.new(1, 0, 0, 32)
                Option.BackgroundColor3 = Theme.Background
                Option.BackgroundTransparency = 1
                Option.Text = tostring(option)
                Option.TextColor3 = Theme.SubText
                Option.TextSize = 12
                Option.Font = Enum.Font.Gotham
                Option.AutoButtonColor = false
                Option.Parent = List

                Option.MouseEnter:Connect(function()
                    Tween(Option, {
                        BackgroundColor3 = Theme.SurfaceHover,
                        BackgroundTransparency = 0
                    }):Play()
                end)

                Option.MouseLeave:Connect(function()
                    Tween(Option, {
                        BackgroundTransparency = 1
                    }):Play()
                end)

                Option.MouseButton1Click:Connect(function()
                    selected = option
                    Current.Text = tostring(option)

                    local closedHeight = 48

                    Tween(Holder, {
                        Size = UDim2.new(1, 0, 0, closedHeight)
                    }):Play()

                    if data.Callback then
                        task.spawn(data.Callback, option)
                    end
                end)
            end

            local opened = false

            Button.MouseButton1Click:Connect(function()
                opened = not opened

                if opened then
                    local height = 48 + (#options * 34) + 10

                    Tween(Holder, {
                        Size = UDim2.new(1, 0, 0, height)
                    }):Play()

                    Tween(Arrow, {
                        Rotation = 180
                    }):Play()
                else
                    Tween(Holder, {
                        Size = UDim2.new(1, 0, 0, 48)
                    }):Play()

                    Tween(Arrow, {
                        Rotation = 0
                    }):Play()
                end
            end)

            return Holder
        end

        --------------------------------------------------------
        -- TEXTBOX
        --------------------------------------------------------

        function Tab:AddTextbox(data)
            data = data or {}

            local Holder = Instance.new("Frame")
            Holder.Size = UDim2.new(1, 0, 0, 48)
            Holder.BackgroundColor3 = Theme.Surface
            Holder.BorderSizePixel = 0
            Holder.Parent = Page

            Corner(Holder, Theme.Corner)
            Stroke(Holder, Theme.Border)

            local Label = NewText(
                Holder,
                data.Text or "Textbox",
                13,
                Theme.Text,
                Enum.Font.GothamMedium
            )

            Label.Position = UDim2.fromOffset(14, 0)
            Label.Size = UDim2.new(0.4, 0, 1, 0)

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(0.5, 0, 0, 32)
            Box.Position = UDim2.new(0.47, 0, 0.5, -16)
            Box.BackgroundColor3 = Theme.Background
            Box.BorderSizePixel = 0
            Box.Text = data.Default or ""
            Box.PlaceholderText = data.Placeholder or "Enter text..."
            Box.PlaceholderColor3 = Theme.SubText
            Box.TextColor3 = Theme.Text
            Box.TextSize = 12
            Box.Font = Enum.Font.Gotham
            Box.ClearTextOnFocus = false
            Box.Parent = Holder

            Corner(Box, 6)
            Stroke(Box, Theme.Border)

            local boxPadding = Instance.new("UIPadding")
            boxPadding.PaddingLeft = UDim.new(0, 9)
            boxPadding.PaddingRight = UDim.new(0, 9)
            boxPadding.Parent = Box

            Box.FocusLost:Connect(function()
                if data.Callback then
                    task.spawn(data.Callback, Box.Text)
                end
            end)

            return Holder
        end

        --------------------------------------------------------
        -- DIVIDER
        --------------------------------------------------------

        function Tab:AddDivider()
            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, 0, 0, 1)
            Divider.BackgroundColor3 = Theme.Divider
            Divider.BorderSizePixel = 0
            Divider.Parent = Page

            return Divider
        end

        table.insert(Window.Tabs, Tab)

        -- Automatically select the first tab.
        if #Window.Tabs == 1 then
            Tab:Select()
        end

        return Tab
    end

    return Window
end

return UILibrary
