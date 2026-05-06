if game.CoreGui:FindFirstChild("gradient_lib") then
    game.CoreGui.gradient_lib:Destroy()
end

local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local library = {windows = 0, theme = {bg = Color3.fromRGB(35,35,35), accent = Color3.fromRGB(0,170,255)}}
local ScreenGui = Instance.new("ScreenGui")

function library:SetTheme(t)
    for i,v in pairs(t) do
        library.theme[i] = v
    end
end

function library:SaveConfig(name, flags)
    if writefile then
        writefile(name..".json", HttpService:JSONEncode(flags))
    end
end

function library:LoadConfig(name)
    if readfile and isfile and isfile(name..".json") then
        return HttpService:JSONDecode(readfile(name..".json"))
    end
end

function library:Window(name, keybind)
    local window = {toggled = true, flags = {}}
    local Frame = Instance.new("Frame")
    local Container = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")

    library.windows += 1
    ScreenGui.Name = "gradient_lib"
    ScreenGui.Parent = game.CoreGui

    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0,200,0,250)
    Frame.Position = UDim2.new(0,20 + ((210 * library.windows) - 210),0,20)
    Frame.BackgroundColor3 = library.theme.bg
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1,0,0,30)
    Title.BackgroundTransparency = 1
    Title.Text = " "..name
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Container.Parent = Frame
    Container.Position = UDim2.new(0,0,0,30)
    Container.Size = UDim2.new(1,0,1,-30)
    Container.BackgroundTransparency = 1

    UIListLayout.Parent = Container

    if keybind then
        UIS.InputBegan:Connect(function(input,gp)
            if not gp and input.KeyCode == keybind then
                window.toggled = not window.toggled
                Frame.Visible = window.toggled
            end
        end)
    end

    local function resize()
        local y = 5
        for _,v in pairs(Container:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextButton") then
                y += v.AbsoluteSize.Y
            end
        end
        Frame.Size = UDim2.new(0,200,0,y+30)
    end

    function window:Button(name, callback)
        local b = Instance.new("TextButton")
        b.Parent = Container
        b.Size = UDim2.new(1,0,0,28)
        b.BackgroundTransparency = 1
        b.Text = " "..name
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.MouseButton1Click:Connect(callback)
        resize()
    end

    function window:Toggle(name, callback)
        local state = false
        local b = Instance.new("TextButton")
        b.Parent = Container
        b.Size = UDim2.new(1,0,0,28)
        b.BackgroundTransparency = 1
        b.Text = " "..name.." [OFF]"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.Gotham
        b.TextXAlignment = Enum.TextXAlignment.Left

        b.MouseButton1Click:Connect(function()
            state = not state
            window.flags[name] = state
            b.Text = " "..name.." ["..(state and "ON" or "OFF").."]"
            if callback then callback(state) end
        end)
        resize()
    end

    function window:Box(name, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = Container
        frame.Size = UDim2.new(1,0,0,30)
        frame.BackgroundTransparency = 1

        local box = Instance.new("TextBox")
        box.Parent = frame
        box.Size = UDim2.new(1,-10,1,0)
        box.Position = UDim2.new(0,5,0,0)
        box.BackgroundColor3 = library.theme.bg
        box.TextColor3 = Color3.new(1,1,1)
        box.PlaceholderText = default or "value"
        box.Text = ""

        box.FocusLost:Connect(function()
            local text = tostring(box.Text)
            window.flags[name] = text
            if callback then callback(text) end
        end)
        resize()
    end

    function window:Dropdown(name, list, callback)
        local frame = Instance.new("Frame")
        frame.Parent = Container
        frame.Size = UDim2.new(1,0,0,30)
        frame.BackgroundTransparency = 1

        local title = Instance.new("TextButton")
        title.Parent = frame
        title.Size = UDim2.new(1,0,0,30)
        title.BackgroundTransparency = 1
        title.Text = " "..name
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.Gotham
        title.TextXAlignment = Enum.TextXAlignment.Left

        local open = false
        local listFrame = Instance.new("Frame")
        listFrame.Parent = frame
        listFrame.Position = UDim2.new(0,0,0,30)
        listFrame.Size = UDim2.new(1,0,0,0)
        listFrame.ClipsDescendants = true
        listFrame.BackgroundColor3 = library.theme.bg

        local layout = Instance.new("UIListLayout", listFrame)

        title.MouseButton1Click:Connect(function()
            open = not open
            listFrame:TweenSize(
                open and UDim2.new(1,0,0,#list*28) or UDim2.new(1,0,0,0),
                "Out","Sine",0.25,true
            )
        end)

        for _,v in pairs(list) do
            local opt = Instance.new("TextButton")
            opt.Parent = listFrame
            opt.Size = UDim2.new(1,0,0,28)
            opt.BackgroundTransparency = 1
            opt.Text = "   "..v
            opt.TextColor3 = Color3.new(1,1,1)
            opt.Font = Enum.Font.Gotham
            opt.TextXAlignment = Enum.TextXAlignment.Left

            opt.MouseButton1Click:Connect(function()
                title.Text = " "..name.." : "..v
                window.flags[name] = v
                if callback then callback(v) end
            end)
        end

        resize()
    end

    return window
end

return library