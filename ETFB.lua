local function boot()
    if getgenv().ETFB_Loaded then
        pcall(getgenv().ETFB_Cleanup)
        task.wait(0.15)
    end
    getgenv().ETFB_Loaded = true

    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RS = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local TS = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local LP = Players.LocalPlayer

    local PARENT = LP:WaitForChild("PlayerGui", 10)
    if not PARENT then warn("[ETFB] no PlayerGui") return end
    for _, c in ipairs(PARENT:GetChildren()) do
        if c.Name:sub(1, 5) == "ETFB_" then pcall(function() c:Destroy() end) end
    end

    local C = {
        bg = Color3.fromRGB(10, 10, 12),
        bg_side = Color3.fromRGB(12, 12, 15),
        bg_content = Color3.fromRGB(14, 14, 17),
        bg_row = Color3.fromRGB(17, 17, 20),
        bg_row_hi = Color3.fromRGB(24, 24, 30),
        bg_elem = Color3.fromRGB(22, 22, 27),
        bg_elem_hi = Color3.fromRGB(30, 30, 37),
        bg_header = Color3.fromRGB(13, 13, 16),
        border = Color3.fromRGB(28, 28, 34),
        divider = Color3.fromRGB(22, 22, 26),
        text = Color3.fromRGB(230, 230, 235),
        text_bright = Color3.fromRGB(245, 245, 250),
        text_dim = Color3.fromRGB(130, 130, 142),
        text_dimmer = Color3.fromRGB(75, 75, 88),
        section = Color3.fromRGB(95, 95, 108),
        accent = Color3.fromRGB(77, 143, 240),
        accent_hi = Color3.fromRGB(120, 165, 255),
        accent_dk = Color3.fromRGB(45, 90, 170),
        green = Color3.fromRGB(80, 210, 130),
        red = Color3.fromRGB(230, 85, 110),
        yellow = Color3.fromRGB(250, 200, 80),
        orange = Color3.fromRGB(250, 150, 70),
        purple = Color3.fromRGB(170, 110, 250),
        cyan = Color3.fromRGB(80, 210, 240),
    }
    local F_REG = Enum.Font.Gotham
    local F_MED = Enum.Font.GothamMedium
    local F_BOLD = Enum.Font.GothamBold
    local F_BLK = Enum.Font.GothamBlack
    local F_CODE = Enum.Font.Code

    local function create(cls, props, parent)
        local o = Instance.new(cls)
        for k, v in pairs(props or {}) do
            if k ~= "Parent" then pcall(function() o[k] = v end) end
        end
        if parent then o.Parent = parent end
        return o
    end
    local function corner(p, r) return create("UICorner", {CornerRadius = UDim.new(0, r or 4)}, p) end
    local function stroke(p, col, th, tr)
        return create("UIStroke", {Color=col or C.border, Thickness=th or 1,
            Transparency=tr or 0.5, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p)
    end
    local function pad(p, t, b, l, r)
        return create("UIPadding", {
            PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
            PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
        }, p)
    end
    local function tween(o, prop, val, t, style, dir)
        local ti = TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
        local tr = TS:Create(o, ti, {[prop]=val})
        tr:Play(); return tr
    end
    local function grad(p, c1, c2, rot, trans)
        local g = create("UIGradient", {Rotation=rot or 90, Color=ColorSequence.new(c1,c2)}, p)
        if trans then g.Transparency = trans end
        return g
    end

    local blur = create("BlurEffect", {Name="ETFB_Blur", Size=0, Parent=game:GetService("Lighting")})
    local function blurOn() tween(blur, "Size", 12, 0.4) end
    local function blurOff() tween(blur, "Size", 0, 0.3) end

    local gui = create("ScreenGui", {
        Name="ETFB_Root", ResetOnSpawn=false, IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=999999,
    }, PARENT)
    getgenv().ETFB_Gui = gui

    local notifHolder = create("Frame", {
        Name="Notifs", Size=UDim2.fromOffset(300, 500),
        Position=UDim2.new(1, -316, 1, -16), BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0, 1),
    }, gui)
    create("UIListLayout", {
        Padding=UDim.new(0,8), VerticalAlignment=Enum.VerticalAlignment.Bottom,
        SortOrder=Enum.SortOrder.LayoutOrder,
    }, notifHolder)

    local function notify(title, content, color, dur)
        color = color or C.accent; dur = dur or 3
        local n = create("Frame", {
            Size=UDim2.fromOffset(300, 60), BackgroundColor3=C.bg,
            BackgroundTransparency=0.15, BorderSizePixel=0,
        }, notifHolder)
        corner(n, 8); stroke(n, C.border, 1, 0.75)
        local bar = create("Frame", {
            Size=UDim2.fromOffset(3, 30), Position=UDim2.new(0, 0, 0.5, -15),
            BackgroundColor3=color, BorderSizePixel=0,
        }, n)
        corner(bar, 2)
        create("TextLabel", {
            Size=UDim2.new(1,-30,0,16), Position=UDim2.fromOffset(18,12),
            BackgroundTransparency=1, Text=title, TextColor3=C.text,
            Font=F_BLK, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
        }, n)
        create("TextLabel", {
            Size=UDim2.new(1,-30,0,22), Position=UDim2.fromOffset(18,30),
            BackgroundTransparency=1, Text=content, TextColor3=C.text_dim,
            Font=F_MED, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true, TextTruncate=Enum.TextTruncate.AtEnd,
        }, n)
        n.Position = UDim2.new(1, 340, 0, 0)
        tween(n, "Position", UDim2.new(0,0,0,0), 0.4, Enum.EasingStyle.Back)
        task.delay(dur, function()
            tween(n, "Position", UDim2.new(1,340,0,0), 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.35)
            if n then pcall(function() n:Destroy() end) end
        end)
    end
    getgenv().ETFB_Notify = notify

    local wm = create("Frame", {
        Size=UDim2.fromOffset(260, 30), Position=UDim2.new(1, -276, 0, 14),
        BackgroundColor3=C.bg, BackgroundTransparency=0.15,
        BorderSizePixel=0, AnchorPoint=Vector2.new(0, 0),
    }, gui)
    corner(wm, 15); stroke(wm, C.border, 1, 0.5)
    create("Frame", {
        Size=UDim2.fromOffset(6,6), Position=UDim2.fromOffset(14,12),
        BackgroundColor3=C.cyan, BorderSizePixel=0,
    }, wm)
    local wmDot = wm:FindFirstChildOfClass("Frame")
    if wmDot then corner(wmDot, 3) end
    create("TextLabel", {
        Size=UDim2.fromOffset(180,30), Position=UDim2.fromOffset(28,0),
        BackgroundTransparency=1, Text="ALWAYSLOSE · ETFB",
        TextColor3=C.text, Font=F_BLK, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, wm)
    local wmFps = create("TextLabel", {
        Size=UDim2.fromOffset(70,30), Position=UDim2.new(1,-84,0,0),
        BackgroundTransparency=1, Text="60 fps",
        TextColor3=C.text_dim, Font=F_CODE, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, wm)

    local fpsSamples = {}
    RunService.RenderStepped:Connect(function(dt)
        table.insert(fpsSamples, dt)
        if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
    end)
    task.spawn(function()
        while getgenv().ETFB_Loaded do
            task.wait(0.5)
            local sum = 0
            for _, d in ipairs(fpsSamples) do sum = sum + d end
            local fps = (#fpsSamples > 0) and math.floor(#fpsSamples / math.max(0.001, sum)) or 0
            if wmFps and wmFps.Parent then wmFps.Text = fps .. " fps" end
        end
    end)

    local WIN_W, WIN_H = 880, 560
    local win = create("Frame", {
        Name="ETFB_Win", Size=UDim2.fromOffset(WIN_W, WIN_H),
        Position=UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3=C.bg, BackgroundTransparency=0.05,
        BorderSizePixel=0, Active=true,
    }, gui)
    corner(win, 8); stroke(win, C.border, 1.2, 0.35)

    local titlebar = create("Frame", {
        Size=UDim2.new(1,0,0,42),
        BackgroundColor3=C.bg_header, BorderSizePixel=0,
    }, win)
    corner(titlebar, 8)
    create("Frame", {
        Size=UDim2.new(0,8,0,8), Position=UDim2.new(1,-8,1,-8),
        BackgroundColor3=C.bg_header, BorderSizePixel=0,
    }, titlebar)

    local logoBox = create("Frame", {
        Size=UDim2.fromOffset(22,22), Position=UDim2.fromOffset(12,10),
        BackgroundColor3=C.cyan, BorderSizePixel=0,
    }, titlebar)
    corner(logoBox, 4)
    grad(logoBox, C.cyan, C.accent_dk, 45)
    create("TextLabel", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="NL",
        TextColor3=Color3.new(1,1,1), Font=F_BLK, TextSize=9,
    }, logoBox)

    create("TextLabel", {
        Size=UDim2.fromOffset(180,14), Position=UDim2.fromOffset(42,8),
        BackgroundTransparency=1, Text="ALWAYSLOSE",
        TextColor3=C.text, Font=F_BLK, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, titlebar)
    create("TextLabel", {
        Size=UDim2.fromOffset(180,12), Position=UDim2.fromOffset(42,22),
        BackgroundTransparency=1, Text="ESCAPE TSUNAMI",
        TextColor3=C.text_dimmer, Font=F_MED, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, titlebar)

    local cfgBtn = create("TextButton", {
        Size=UDim2.fromOffset(140,22), Position=UDim2.new(0.5,-70,0,10),
        BackgroundColor3=C.bg_row, BorderSizePixel=0,
        Text="", AutoButtonColor=false,
    }, titlebar)
    corner(cfgBtn, 4); stroke(cfgBtn, C.border, 1, 0.6)
    create("TextLabel", {
        Size=UDim2.fromOffset(18,22), Position=UDim2.fromOffset(4,0),
        BackgroundTransparency=1, Text="≡",
        TextColor3=C.text_dim, Font=F_BOLD, TextSize=12,
    }, cfgBtn)
    create("TextLabel", {
        Size=UDim2.fromOffset(80,22), Position=UDim2.fromOffset(24,0),
        BackgroundTransparency=1, Text="default.cfg",
        TextColor3=C.text, Font=F_MED, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cfgBtn)
    create("TextLabel", {
        Size=UDim2.fromOffset(16,22), Position=UDim2.new(1,-20,0,0),
        BackgroundTransparency=1, Text="▾",
        TextColor3=C.text_dim, Font=F_BOLD, TextSize=9,
    }, cfgBtn)

    create("TextLabel", {
        Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-100,0,11),
        BackgroundTransparency=1, Text="⌕",
        TextColor3=C.text_dim, Font=F_BOLD, TextSize=13,
    }, titlebar)

    local function tbBtn(text, xoff, hov, cb)
        local b = create("TextButton", {
            Size=UDim2.fromOffset(24,24), Position=UDim2.new(1,xoff,0,9),
            BackgroundColor3=C.bg_row, BorderSizePixel=0,
            Text=text, TextColor3=C.text_dim,
            Font=F_BOLD, TextSize=12, AutoButtonColor=false,
        }, titlebar)
        corner(b, 4)
        b.MouseEnter:Connect(function()
            tween(b, "BackgroundColor3", hov, 0.12)
            tween(b, "TextColor3", C.text_bright, 0.12)
        end)
        b.MouseLeave:Connect(function()
            tween(b, "BackgroundColor3", C.bg_row, 0.12)
            tween(b, "TextColor3", C.text_dim, 0.12)
        end)
        if cb then b.MouseButton1Click:Connect(cb) end
        return b
    end
    tbBtn("—", -62, C.bg_elem_hi, function() win.Visible = false; blurOff() end)
    tbBtn("✕", -32, C.red, function()
        getgenv().ETFB_Loaded = false
        getgenv().ETFB_Cleanup()
    end)

    local sidebar = create("Frame", {
        Size=UDim2.new(0, 175, 1, -114),
        Position=UDim2.fromOffset(0, 42),
        BackgroundColor3=C.bg_side, BorderSizePixel=0,
        ClipsDescendants=true,
    }, win)

    local sbScroll = create("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=C.bg_elem_hi,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, sidebar)
    pad(sbScroll, 8, 8, 8, 8)
    create("UIListLayout", {Padding=UDim.new(0,1), SortOrder=Enum.SortOrder.LayoutOrder}, sbScroll)

    local footer = create("Frame", {
        Size=UDim2.new(0,175,0,72),
        Position=UDim2.new(0, 0, 1, -72),
        BackgroundColor3=C.bg_side, BorderSizePixel=0,
    }, win)
    create("Frame", {
        Size=UDim2.new(1,-16,0,1), Position=UDim2.fromOffset(8,0),
        BackgroundColor3=C.border, BorderSizePixel=0, BackgroundTransparency=0.5,
    }, footer)

    local av = create("Frame", {
        Size=UDim2.fromOffset(30,30), Position=UDim2.fromOffset(12,12),
        BackgroundColor3=C.cyan, BorderSizePixel=0,
    }, footer)
    corner(av, 15)
    pcall(function()
        local img = create("ImageLabel", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Image="rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=100&h=100",
        }, av)
        corner(img, 15)
    end)
    create("TextLabel", {
        Size=UDim2.new(1,-54,0,14), Position=UDim2.fromOffset(50,14),
        BackgroundTransparency=1, Text=LP.Name,
        TextColor3=C.text_bright, Font=F_BOLD, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
    }, footer)
    create("TextLabel", {
        Size=UDim2.new(1,-54,0,12), Position=UDim2.fromOffset(50,30),
        BackgroundTransparency=1, Text="Lifetime · Premium",
        TextColor3=C.cyan, Font=F_MED, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, footer)
    create("TextLabel", {
        Size=UDim2.new(1,-24,0,12), Position=UDim2.fromOffset(12,50),
        BackgroundTransparency=1, Text="Neverlose Style · v1.0",
        TextColor3=C.text_dimmer, Font=F_MED, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, footer)

    local content = create("Frame", {
        Size=UDim2.new(1, -175, 1, -42),
        Position=UDim2.fromOffset(175, 42),
        BackgroundColor3=C.bg_content, BorderSizePixel=0,
        ClipsDescendants=true,
    }, win)

    local cHdr = create("Frame", {
        Size=UDim2.new(1,0,0,34),
        BackgroundColor3=C.bg_content, BorderSizePixel=0,
    }, content)
    create("Frame", {
        Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,1,-1),
        BackgroundColor3=C.border, BorderSizePixel=0, BackgroundTransparency=0.5,
    }, cHdr)
    local cTitle = create("TextLabel", {
        Size=UDim2.fromOffset(300,34), Position=UDim2.fromOffset(14,0),
        BackgroundTransparency=1, Text="Rage",
        TextColor3=C.text_bright, Font=F_BOLD, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cHdr)

    local Tabs = {}
    local TabOrder = {}
    local CurrentTab = nil
    local orderCounter = 0

    local function switchTab(name)
        if CurrentTab == name then return end
        CurrentTab = name
        for tn, t in pairs(Tabs) do
            local act = (tn == name)
            t.btn.BackgroundColor3 = act and C.bg_elem or C.bg_side
            t.btn.BackgroundTransparency = act and 0 or 1
            t.label.TextColor3 = act and C.text_bright or C.text_dim
            t.icon.TextColor3 = act and C.cyan or C.text_dimmer
            t.bar.BackgroundTransparency = act and 0 or 1
            t.panel.Visible = act
        end
        local t = Tabs[name]
        if t then cTitle.Text = t.title end
    end

    local function sideHeader(text)
        orderCounter = orderCounter + 1
        local wrap = create("Frame", {
            Size=UDim2.new(1,0,0,20), BackgroundTransparency=1,
            LayoutOrder=orderCounter,
        }, sbScroll)
        create("TextLabel", {
            Size=UDim2.new(1,0,0,12), Position=UDim2.fromOffset(10,6),
            BackgroundTransparency=1, Text=string.upper(text),
            TextColor3=C.text_dimmer, Font=F_BOLD, TextSize=8,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, wrap)
    end

    local function makeTab(name, displayName, icon)
        orderCounter = orderCounter + 1
        local btn = create("TextButton", {
            Size=UDim2.new(1,0,0,26),
            BackgroundColor3=C.bg_side, BackgroundTransparency=1,
            BorderSizePixel=0, Text="", AutoButtonColor=false,
            LayoutOrder=orderCounter,
        }, sbScroll)
        corner(btn, 4)
        local bar = create("Frame", {
            Size=UDim2.fromOffset(2,14), Position=UDim2.new(0,0,0.5,-7),
            BackgroundColor3=C.cyan, BackgroundTransparency=1, BorderSizePixel=0,
        }, btn)
        corner(bar, 1)
        local ic = create("TextLabel", {
            Size=UDim2.fromOffset(18,26), Position=UDim2.fromOffset(12,0),
            BackgroundTransparency=1, Text=icon or "◆",
            TextColor3=C.text_dimmer, Font=F_MED, TextSize=11,
        }, btn)
        local lbl = create("TextLabel", {
            Size=UDim2.new(1,-36,1,0), Position=UDim2.fromOffset(32,0),
            BackgroundTransparency=1, Text=displayName,
            TextColor3=C.text_dim, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, btn)
        local panel = create("ScrollingFrame", {
            Size=UDim2.new(1,-20,1,-44), Position=UDim2.fromOffset(10,44),
            BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3, ScrollBarImageColor3=C.bg_elem_hi,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false,
        }, content)
        create("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, panel)
        btn.MouseEnter:Connect(function()
            if CurrentTab ~= name then
                tween(btn, "BackgroundTransparency", 0.5, 0.1)
                lbl.TextColor3 = C.text
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= name then
                tween(btn, "BackgroundTransparency", 1, 0.1)
                lbl.TextColor3 = C.text_dim
            end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        Tabs[name] = {btn=btn, label=lbl, icon=ic, bar=bar, panel=panel, title=displayName}
        table.insert(TabOrder, name)
    end

    local colState = {}
    local function getCols(tabName)
        if colState[tabName] then return colState[tabName] end
        local p = Tabs[tabName].panel
        local lc = create("Frame", {
            Size=UDim2.new(0.5,-8,0,0), Position=UDim2.fromOffset(4,0),
            BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y,
        }, p)
        create("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, lc)
        local rc = create("Frame", {
            Size=UDim2.new(0.5,-8,0,0), Position=UDim2.new(0.5,4,0,0),
            BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y,
        }, p)
        create("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, rc)
        colState[tabName] = {left=lc, right=rc, lo=0, ro=0}
        return colState[tabName]
    end

    local function nextL(tab) local c = getCols(tab); c.lo = c.lo + 1; return c.left, c.lo end
    local function nextR(tab) local c = getCols(tab); c.ro = c.ro + 1; return c.right, c.ro end

    local function section(tabName, text, side)
        local parent, ord
        if side == "right" then parent, ord = nextR(tabName) else parent, ord = nextL(tabName) end
        local wrap = create("Frame", {
            Size=UDim2.new(1,-4,0,22), BackgroundTransparency=1, LayoutOrder=ord,
        }, parent)
        create("TextLabel", {
            Size=UDim2.new(1,0,0,12), Position=UDim2.fromOffset(4,8),
            BackgroundTransparency=1, Text=string.upper(text),
            TextColor3=C.section, Font=F_BOLD, TextSize=8,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, wrap)
    end

    local function row(tabName, height, side)
        local parent, ord
        if side == "right" then parent, ord = nextR(tabName) else parent, ord = nextL(tabName) end
        local r = create("Frame", {
            Size=UDim2.new(1,-4,0,height or 28),
            BackgroundColor3=C.bg_row, BorderSizePixel=0, LayoutOrder=ord,
        }, parent)
        corner(r, 4)
        return r
    end

    local function toggle(tabName, label, default, cb, side)
        local r = row(tabName, 28, side)
        create("TextLabel", {
            Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(12,0),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.text, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        local track = create("Frame", {
            Size=UDim2.fromOffset(30,15), Position=UDim2.new(1,-42,0.5,-7),
            BackgroundColor3=default and C.cyan or C.bg_elem_hi, BorderSizePixel=0,
        }, r)
        corner(track, 8)
        local knob = create("Frame", {
            Size=UDim2.fromOffset(11,11),
            Position=default and UDim2.new(1,-13,0.5,-5.5) or UDim2.new(0,2,0.5,-5.5),
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        }, track)
        corner(knob, 6)
        local state = default
        local btn = create("TextButton", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text="", AutoButtonColor=false,
        }, r)
        btn.MouseEnter:Connect(function() tween(r, "BackgroundColor3", C.bg_row_hi, 0.1) end)
        btn.MouseLeave:Connect(function() tween(r, "BackgroundColor3", C.bg_row, 0.1) end)
        btn.MouseButton1Click:Connect(function()
            state = not state
            tween(track, "BackgroundColor3", state and C.cyan or C.bg_elem_hi, 0.12)
            tween(knob, "Position", state and UDim2.new(1,-13,0.5,-5.5) or UDim2.new(0,2,0.5,-5.5), 0.15, Enum.EasingStyle.Back)
            if cb then pcall(cb, state) end
        end)
        return btn
    end

    local function slider(tabName, label, minV, maxV, default, step, suffix, cb, side)
        local r = row(tabName, 44, side)
        create("TextLabel", {
            Size=UDim2.new(1,-100,0,16), Position=UDim2.fromOffset(12,6),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.text, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        local valLbl = create("TextLabel", {
            Size=UDim2.fromOffset(80,16), Position=UDim2.new(1,-92,0,6),
            BackgroundTransparency=1, Text=tostring(default)..(suffix or ""),
            TextColor3=C.cyan, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, r)
        local track = create("Frame", {
            Size=UDim2.new(1,-24,0,2), Position=UDim2.fromOffset(12,32),
            BackgroundColor3=C.bg_elem_hi, BorderSizePixel=0,
        }, r)
        corner(track, 1)
        local pct = (default - minV) / math.max(0.001, maxV - minV)
        local fill = create("Frame", {
            Size=UDim2.new(pct,0,1,0), BackgroundColor3=C.cyan, BorderSizePixel=0,
        }, track)
        corner(fill, 1)
        local knob = create("Frame", {
            Size=UDim2.fromOffset(10,10), Position=UDim2.new(pct,-5,0.5,-5),
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        }, track)
        corner(knob, 5)
        local hit = create("TextButton", {
            Size=UDim2.new(1,0,0,20), Position=UDim2.fromOffset(0,26),
            BackgroundTransparency=1, Text="", AutoButtonColor=false,
        }, r)
        local dragging = false
        local function update(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
            local v = minV + (maxV - minV) * rel
            if step then v = math.floor(v / step + 0.5) * step end
            v = math.clamp(v, minV, maxV)
            local p2 = (v - minV) / math.max(0.001, maxV - minV)
            fill.Size = UDim2.new(p2,0,1,0)
            knob.Position = UDim2.new(p2,-5,0.5,-5)
            valLbl.Text = tostring(v)..(suffix or "")
            if cb then pcall(cb, v) end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; update(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                update(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    local function dropdown(tabName, label, options, default, cb, side)
        local r = row(tabName, 28, side)
        create("TextLabel", {
            Size=UDim2.new(0.5,-12,1,0), Position=UDim2.fromOffset(12,0),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.text, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        local dd = create("TextButton", {
            Size=UDim2.fromOffset(140,20), Position=UDim2.new(1,-152,0.5,-10),
            BackgroundTransparency=1, BorderSizePixel=0,
            Text="", AutoButtonColor=false,
        }, r)
        create("TextLabel", {
            Size=UDim2.fromOffset(20,20), BackgroundTransparency=1, Text="…",
            TextColor3=C.text_dimmer, Font=F_BOLD, TextSize=12,
        }, dd)
        local cur = create("TextLabel", {
            Size=UDim2.new(1,-46,1,0), Position=UDim2.fromOffset(22,0),
            BackgroundTransparency=1, Text=default or options[1] or "",
            TextColor3=C.text, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, dd)
        create("TextLabel", {
            Size=UDim2.fromOffset(16,20), Position=UDim2.new(1,-18,0,0),
            BackgroundTransparency=1, Text="▾",
            TextColor3=C.text_dim, Font=F_BOLD, TextSize=9,
        }, dd)
        local idx = 1
        for i, o in ipairs(options) do if o == default then idx = i break end end
        dd.MouseButton1Click:Connect(function()
            idx = idx + 1
            if idx > #options then idx = 1 end
            cur.Text = options[idx]
            if cb then pcall(cb, options[idx]) end
        end)
    end

    local function button(tabName, label, color, cb, side)
        local r = row(tabName, 28, side)
        local btn = create("TextButton", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text=label, TextColor3=color or C.text,
            Font=F_BOLD, TextSize=10, AutoButtonColor=false,
        }, r)
        btn.MouseEnter:Connect(function()
            tween(r, "BackgroundColor3", C.bg_row_hi, 0.1)
            tween(btn, "TextColor3", C.text_bright, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            tween(r, "BackgroundColor3", C.bg_row, 0.1)
            tween(btn, "TextColor3", color or C.text, 0.1)
        end)
        if cb then btn.MouseButton1Click:Connect(function() pcall(cb) end) end
    end

    local function navRow(tabName, label, value, cb, side)
        local r = row(tabName, 28, side)
        local btn = create("TextButton", {
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text="", AutoButtonColor=false,
        }, r)
        create("TextLabel", {
            Size=UDim2.new(1,-80,1,0), Position=UDim2.fromOffset(12,0),
            BackgroundTransparency=1, Text=label,
            TextColor3=C.text, Font=F_MED, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        if value then
            create("TextLabel", {
                Size=UDim2.fromOffset(60,28), Position=UDim2.new(1,-76,0,0),
                BackgroundTransparency=1, Text=value,
                TextColor3=C.text_dim, Font=F_MED, TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Right,
            }, r)
        end
        create("TextLabel", {
            Size=UDim2.fromOffset(16,28), Position=UDim2.new(1,-20,0,0),
            BackgroundTransparency=1, Text="›",
            TextColor3=C.text_dim, Font=F_BOLD, TextSize=11,
        }, r)
        btn.MouseEnter:Connect(function() tween(r, "BackgroundColor3", C.bg_row_hi, 0.1) end)
        btn.MouseLeave:Connect(function() tween(r, "BackgroundColor3", C.bg_row, 0.1) end)
        if cb then btn.MouseButton1Click:Connect(function() pcall(cb) end) end
    end

    local function divider(tabName, side)
        local parent, ord
        if side == "right" then parent, ord = nextR(tabName) else parent, ord = nextL(tabName) end
        create("Frame", {
            Size=UDim2.new(1,-8,0,1), BackgroundColor3=C.divider,
            BorderSizePixel=0, LayoutOrder=ord,
        }, parent)
    end

    local function textOutput(tabName, height, btnLabel, getText, side)
        local parent, ord
        if side == "right" then parent, ord = nextR(tabName) else parent, ord = nextL(tabName) end
        local wrap = create("Frame", {
            Size=UDim2.new(1,-4,0,(height or 200)+32),
            BackgroundTransparency=1, LayoutOrder=ord,
        }, parent)
        local hdr = create("Frame", {
            Size=UDim2.new(1,0,0,26), BackgroundColor3=C.bg_row, BorderSizePixel=0,
        }, wrap)
        corner(hdr, 4)
        create("TextLabel", {
            Size=UDim2.new(1,-90,1,0), Position=UDim2.fromOffset(12,0),
            BackgroundTransparency=1, Text=btnLabel or "output",
            TextColor3=C.text, Font=F_BOLD, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, hdr)
        local copyBtn = create("TextButton", {
            Size=UDim2.fromOffset(70,18), Position=UDim2.new(1,-78,0.5,-9),
            BackgroundColor3=C.bg_elem, BorderSizePixel=0, Text="Copy",
            TextColor3=C.text, Font=F_BOLD, TextSize=9, AutoButtonColor=false,
        }, hdr)
        corner(copyBtn, 3)
        local box = create("TextBox", {
            Size=UDim2.new(1,0,0,height or 200), Position=UDim2.fromOffset(0,30),
            BackgroundColor3=Color3.fromRGB(8,8,10), BorderSizePixel=0,
            Text="", TextColor3=C.text, Font=F_CODE, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
            TextWrapped=true, MultiLine=true, ClearTextOnFocus=false, TextEditable=false,
        }, wrap)
        corner(box, 4); stroke(box, C.border, 1, 0.5)
        pad(box, 8, 8, 10, 10)
        copyBtn.MouseButton1Click:Connect(function()
            local txt = getText and getText() or box.Text
            if setclipboard then
                pcall(setclipboard, txt)
                copyBtn.Text = "OK"
                copyBtn.TextColor3 = C.green
                task.delay(1.2, function()
                    copyBtn.Text = "Copy"
                    copyBtn.TextColor3 = C.text
                end)
            end
        end)
        copyBtn.MouseEnter:Connect(function() tween(copyBtn, "BackgroundColor3", C.bg_elem_hi, 0.1) end)
        copyBtn.MouseLeave:Connect(function() tween(copyBtn, "BackgroundColor3", C.bg_elem, 0.1) end)
        return box
    end

    local S = {
        flyBV = nil, flyBG = nil,
        origCollide = {},
        espHL = {},
        espBB = {},
        autoFarmLast = 0,
        autoCollectLast = 0,
        autoUpgradeLast = 0,
        autoRebirthLast = 0,
        autoPlaceLast = 0,
        autoSellLast = 0,
        autoDupLast = 0,
        autoTradeLast = 0,
        fakeTradeLast = 0,
        lastRemoteLog = {},
    }

    local function getChar() return LP.Character end
    local function getHRP() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
    local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
    local function isAlive(p)
        local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end

    local function findRemoteByKeyword(keyword)
        for _, d in ipairs(RS:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                if d.Name:lower():find(keyword:lower(), 1, true) then return d end
            end
        end
        return nil
    end

    local R = {
        Collect = findRemoteByKeyword("collect"),
        Upgrade = findRemoteByKeyword("upgrade"),
        Rebirth = findRemoteByKeyword("rebirth"),
        Place = findRemoteByKeyword("place"),
        Sell = findRemoteByKeyword("sell"),
        Trade = findRemoteByKeyword("trade"),
        Dup = findRemoteByKeyword("duplicate") or findRemoteByKeyword("dup"),
        Buy = findRemoteByKeyword("buy"),
        Pickup = findRemoteByKeyword("pickup") or findRemoteByKeyword("pick"),
        Speed = findRemoteByKeyword("speed"),
    }

    local function safeFire(rem, ...)
        if not rem then return false, "nil" end
        local a = table.pack(...)
        local ok, err = pcall(function() rem:FireServer(table.unpack(a, 1, a.n)) end)
        return ok, err
    end

    local function restoreCollide()
        for part in pairs(S.origCollide) do
            if part and part.Parent then pcall(function() part.CanCollide = true end) end
        end
        S.origCollide = {}
    end

    local function updateMovement()
        local hum = getHum()
        local hrp = getHRP()
        if hum then
            hum.WalkSpeed = Cfg.Misc.SpeedHack and Cfg.Misc.SpeedValue or 16
            hum.UseJumpPower = true
            hum.JumpPower = Cfg.Misc.JumpPower and Cfg.Misc.JumpValue or 50
        end
        if Cfg.Misc.Fly and hrp then
            if not S.flyBV or not S.flyBV.Parent then
                S.flyBV = create("BodyVelocity", {
                    Name = "ETFB_FlyBV", MaxForce = Vector3.new(9e9,9e9,9e9),
                    P = 1e4, Parent = hrp,
                })
                S.flyBG = create("BodyGyro", {
                    Name = "ETFB_FlyBG", MaxTorque = Vector3.new(9e9,9e9,9e9),
                    P = 1e4, D = 500, Parent = hrp,
                })
            end
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            S.flyBV.Velocity = move.Magnitude > 0 and move.Unit * Cfg.Misc.FlySpeed or Vector3.zero
            S.flyBG.CFrame = cam.CFrame
        else
            if S.flyBV and S.flyBV.Parent then S.flyBV:Destroy() S.flyBV = nil end
            if S.flyBG and S.flyBG.Parent then S.flyBG:Destroy() S.flyBG = nil end
        end
        if Cfg.Misc.Noclip then
            local c = getChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        S.origCollide[p] = true
                        p.CanCollide = false
                    end
                end
            end
        end
    end

    local function updateVisuals()
        if Cfg.Visuals.Fullbright then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(200,200,200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
            Lighting.ClockTime = Cfg.Visuals.TimeOfDay
        end
        if Cfg.Visuals.NoFog then Lighting.FogEnd = 9e9 end
        Lighting.GlobalShadows = not Cfg.Visuals.NoShadows
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= Cfg.Visuals.FOV then cam.FieldOfView = Cfg.Visuals.FOV end
    end

    local function espUpdate()
        if not Cfg.Players.ESP then
            for _, h in pairs(S.espHL) do if h and h.Parent then h:Destroy() end end
            for _, bb in pairs(S.espBB) do if bb and bb.Parent then bb:Destroy() end end
            S.espHL = {}
            S.espBB = {}
            return
        end
        local myHrp = getHRP()
        if not myHrp then return end
        local myPos = myHrp.Position
        local alive = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myPos).Magnitude
                    if d <= Cfg.Players.MaxDistance then
                        alive[p] = true
                        local col = C.accent
                        if not S.espHL[p] or not S.espHL[p].Parent then
                            local h = create("Highlight", {
                                Name = "ETFB_HL", FillColor = col, OutlineColor = col,
                                FillTransparency = 0.6, OutlineTransparency = 0.1,
                                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, Parent = char,
                            })
                            S.espHL[p] = h
                        else
                            S.espHL[p].FillColor = col
                            S.espHL[p].OutlineColor = col
                        end
                        if Cfg.Players.ESPNames or Cfg.Players.ESPHealth or Cfg.Players.ESPDistance then
                            local bb = char:FindFirstChild("ETFB_BB")
                            if not bb then
                                bb = create("BillboardGui", {
                                    Name = "ETFB_BB", Size = UDim2.fromOffset(220,44),
                                    AlwaysOnTop = true, StudsOffset = Vector3.new(0,4,0), Parent = char,
                                })
                                create("TextLabel", {
                                    Name = "Name", Size = UDim2.new(1,0,0,18),
                                    BackgroundTransparency = 1, Text = "",
                                    TextColor3 = C.text_bright, Font = F_BOLD, TextSize = 12,
                                    TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0,0,0),
                                }, bb)
                                create("TextLabel", {
                                    Name = "Info", Size = UDim2.new(1,0,0,14),
                                    Position = UDim2.fromOffset(0,18), BackgroundTransparency = 1,
                                    Text = "", TextColor3 = C.text, Font = F_MED, TextSize = 10,
                                    TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0,0,0),
                                }, bb)
                                S.espBB[p] = bb
                            end
                            local nameLbl = bb:FindFirstChild("Name")
                            local infoLbl = bb:FindFirstChild("Info")
                            if nameLbl then
                                nameLbl.Text = Cfg.Players.ESPNames and p.Name or ""
                                nameLbl.TextColor3 = col
                            end
                            if infoLbl then
                                local parts = {}
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if Cfg.Players.ESPHealth and hum then table.insert(parts, "HP:"..math.floor(hum.Health)) end
                                if Cfg.Players.ESPDistance then table.insert(parts, math.floor(d).."m") end
                                infoLbl.Text = table.concat(parts, "  ")
                            end
                        end
                    end
                end
            end
        end
        for p, h in pairs(S.espHL) do
            if not alive[p] then
                if h and h.Parent then h:Destroy() end
                S.espHL[p] = nil
                if S.espBB[p] and S.espBB[p].Parent then S.espBB[p]:Destroy() end
                S.espBB[p] = nil
            end
        end
    end

    local function doAutoFarm()
        if not Cfg.Farm.Enabled then return end
        if tick() - S.autoFarmLast < Cfg.Farm.Interval then return end
        S.autoFarmLast = tick()
        if R.Collect then safeFire(R.Collect) end
        if R.Pickup then safeFire(R.Pickup) end
        if Cfg.Farm.AutoPlace and R.Place then safeFire(R.Place) end
        if Cfg.Farm.AutoUpgrade and R.Upgrade then safeFire(R.Upgrade) end
        if Cfg.Farm.AutoRebirth and R.Rebirth then safeFire(R.Rebirth) end
    end

    local function doAutoCollect()
        if not Cfg.Farm.AutoCollect then return end
        if tick() - S.autoCollectLast < 1 then return end
        S.autoCollectLast = tick()
        if R.Collect then safeFire(R.Collect) end
    end

    local function doAutoUpgrade()
        if not Cfg.Farm.AutoUpgrade then return end
        if tick() - S.autoUpgradeLast < Cfg.Farm.UpgradeInterval then return end
        S.autoUpgradeLast = tick()
        if R.Upgrade then safeFire(R.Upgrade) end
    end

    local function doAutoRebirth()
        if not Cfg.Farm.AutoRebirth then return end
        if tick() - S.autoRebirthLast < Cfg.Farm.RebirthInterval then return end
        S.autoRebirthLast = tick()
        if R.Rebirth then safeFire(R.Rebirth) end
    end

    local function doAutoPlace()
        if not Cfg.Farm.AutoPlace then return end
        if tick() - S.autoPlaceLast < Cfg.Farm.PlaceInterval then return end
        S.autoPlaceLast = tick()
        if R.Place then safeFire(R.Place) end
    end

    local function doAutoSell()
        if not Cfg.Farm.AutoSell then return end
        if tick() - S.autoSellLast < Cfg.Farm.SellInterval then return end
        S.autoSellLast = tick()
        if R.Sell then safeFire(R.Sell) end
    end

    local function doAutoDup()
        if not Cfg.Dup.Enabled then return end
        if tick() - S.autoDupLast < Cfg.Dup.Interval then return end
        S.autoDupLast = tick()
        if R.Dup then safeFire(R.Dup) end
        if R.Trade then safeFire(R.Trade) end
    end

    local function doAutoTrade()
        if not Cfg.Trade.AutoTrade then return end
        if tick() - S.autoTradeLast < Cfg.Trade.Interval then return end
        S.autoTradeLast = tick()
        if R.Trade then safeFire(R.Trade) end
    end

    local function doFakeTrade()
        if not Cfg.Trade.FakeTrade then return end
        if tick() - S.fakeTradeLast < Cfg.Trade.FakeInterval then return end
        S.fakeTradeLast = tick()
        if R.Trade then safeFire(R.Trade, "fake") end
    end

    local function doFling(targetChar)
        if not targetChar then return end
        local root = targetChar:FindFirstChild("HumanoidRootPart")
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        for _, p in ipairs(targetChar:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CustomPhysicalProperties = PhysicalProperties.new(0.01,0.3,0,0,0) end)
            end
        end
        root.Velocity = Vector3.new(9e7,9e7,9e7)
        root.RotVelocity = Vector3.new(9e7,9e7,9e7)
    end

    local function doRagdoll(targetChar)
        if not targetChar then return end
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
            pcall(function() hum.PlatformStand = true end)
        end
    end

    local dragging, dragStart, startPos
    titlebar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                     startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local menuVisible = true
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            menuVisible = not menuVisible
            if menuVisible then
                win.Visible = true
                win.Size = UDim2.fromOffset(WIN_W, 0)
                win.BackgroundTransparency = 1
                tween(win, "Size", UDim2.fromOffset(WIN_W, WIN_H), 0.3, Enum.EasingStyle.Back)
                tween(win, "BackgroundTransparency", 0.05, 0.25)
                blurOn()
            else
                win.Visible = false
                blurOff()
            end
        end
    end)

    sideHeader("Farm")
    makeTab("farm", "Auto Farm", "⚡")
    makeTab("dup", "Dup", "◇")
    makeTab("trade", "Trade", "♟")

    sideHeader("Combat")
    makeTab("rage", "Rage", "◆")

    sideHeader("Visuals")
    makeTab("visuals", "Visuals", "◈")
    makeTab("players", "Players", "▤")

    sideHeader("Misc")
    makeTab("misc", "Misc", "⚙")

    section("farm", "Auto Farm")
    toggle("farm", "Enable Auto Farm", Cfg.Farm.Enabled, function(v) Cfg.Farm.Enabled = v saveCfg() end)
    slider("farm", "Farm Interval", 0.1, 5, Cfg.Farm.Interval, 0.1, "s", function(v) Cfg.Farm.Interval = v saveCfg() end)
    toggle("farm", "Auto Collect", Cfg.Farm.AutoCollect, function(v) Cfg.Farm.AutoCollect = v saveCfg() end)
    toggle("farm", "Auto Pickup", Cfg.Farm.AutoPickup, function(v) Cfg.Farm.AutoPickup = v saveCfg() end)
    toggle("farm", "Auto Place Best", Cfg.Farm.AutoPlace, function(v) Cfg.Farm.AutoPlace = v saveCfg() end)
    toggle("farm", "Auto Upgrade", Cfg.Farm.AutoUpgrade, function(v) Cfg.Farm.AutoUpgrade = v saveCfg() end)
    toggle("farm", "Auto Rebirth", Cfg.Farm.AutoRebirth, function(v) Cfg.Farm.AutoRebirth = v saveCfg() end)
    toggle("farm", "Auto Sell", Cfg.Farm.AutoSell, function(v) Cfg.Farm.AutoSell = v saveCfg() end)
    slider("farm", "Upgrade Interval", 0.5, 10, Cfg.Farm.UpgradeInterval, 0.5, "s", function(v) Cfg.Farm.UpgradeInterval = v saveCfg() end)
    slider("farm", "Rebirth Interval", 1, 60, Cfg.Farm.RebirthInterval, 1, "s", function(v) Cfg.Farm.RebirthInterval = v saveCfg() end)
    slider("farm", "Place Interval", 0.5, 10, Cfg.Farm.PlaceInterval, 0.5, "s", function(v) Cfg.Farm.PlaceInterval = v saveCfg() end)
    slider("farm", "Sell Interval", 1, 30, Cfg.Farm.SellInterval, 1, "s", function(v) Cfg.Farm.SellInterval = v saveCfg() end)

    section("dup", "Duplication")
    toggle("dup", "Enable Auto Dup", Cfg.Dup.Enabled, function(v) Cfg.Dup.Enabled = v saveCfg() end)
    slider("dup", "Dup Interval", 0.5, 30, Cfg.Dup.Interval, 0.5, "s", function(v) Cfg.Dup.Interval = v saveCfg() end)
    toggle("dup", "Only Divine+", Cfg.Dup.OnlyDivine, function(v) Cfg.Dup.OnlyDivine = v saveCfg() end)
    toggle("dup", "Auto Sell After Dup", Cfg.Dup.AutoSell, function(v) Cfg.Dup.AutoSell = v saveCfg() end)

    section("trade", "Auto Trade")
    toggle("trade", "Enable Auto Trade", Cfg.Trade.AutoTrade, function(v) Cfg.Trade.AutoTrade = v saveCfg() end)
    slider("trade", "Trade Interval", 1, 30, Cfg.Trade.Interval, 1, "s", function(v) Cfg.Trade.Interval = v saveCfg() end)
    toggle("trade", "Auto Accept All", Cfg.Trade.AutoAccept, function(v) Cfg.Trade.AutoAccept = v saveCfg() end)
    dropdown("trade", "Trade Priority", { "Highest Value", "Lowest Value", "Newest", "Random" }, Cfg.Trade.Priority, function(v) Cfg.Trade.Priority = v saveCfg() end)

    section("trade", "Fake Trade")
    toggle("trade", "Enable Fake Trade", Cfg.Trade.FakeTrade, function(v) Cfg.Trade.FakeTrade = v saveCfg() end)
    slider("trade", "Fake Trade Interval", 0.5, 30, Cfg.Trade.FakeInterval, 0.5, "s", function(v) Cfg.Trade.FakeInterval = v saveCfg() end)
    toggle("trade", "Show Fake Offer", Cfg.Trade.ShowFake, function(v) Cfg.Trade.ShowFake = v saveCfg() end)

    section("rage", "Combat")
    toggle("rage", "Kill Aura", Cfg.Rage.KillAura, function(v) Cfg.Rage.KillAura = v saveCfg() end)
    slider("rage", "Kill Aura Range", 5, 200, Cfg.Rage.KillAuraRange, 1, "", function(v) Cfg.Rage.KillAuraRange = v saveCfg() end)
    slider("rage", "Kill Aura Delay", 0.01, 1, Cfg.Rage.KillAuraDelay, 0.01, "s", function(v) Cfg.Rage.KillAuraDelay = v saveCfg() end)
    toggle("rage", "Fling All", Cfg.Rage.FlingAll, function(v) Cfg.Rage.FlingAll = v saveCfg() end)
    toggle("rage", "Ragdoll All", Cfg.Rage.RagdollAll, function(v) Cfg.Rage.RagdollAll = v saveCfg() end)
    button("rage", "▸ Fling Nearest", C.red, function()
        local myHrp = getHRP()
        if not myHrp then return end
        local myPos = myHrp.Position
        local best, minD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myPos).Magnitude
                    if d < minD then minD = d; best = p.Character end
                end
            end
        end
        if best then doFling(best) notify("Rage", "flinged nearest", C.red, 2) end
    end)
    button("rage", "▸ Ragdoll Nearest", C.red, function()
        local myHrp = getHRP()
        if not myHrp then return end
        local myPos = myHrp.Position
        local best, minD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and isAlive(p) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myPos).Magnitude
                    if d < minD then minD = d; best = p.Character end
                end
            end
        end
        if best then doRagdoll(best) notify("Rage", "ragdolled nearest", C.red, 2) end
    end)

    section("visuals", "View")
    slider("visuals", "Field of View", 40, 140, Cfg.Visuals.FOV, 1, "°", function(v) Cfg.Visuals.FOV = v saveCfg() end)
    toggle("visuals", "Fullbright", Cfg.Visuals.Fullbright, function(v) Cfg.Visuals.Fullbright = v saveCfg() end)
    toggle("visuals", "No Fog", Cfg.Visuals.NoFog, function(v) Cfg.Visuals.NoFog = v saveCfg() end)
    toggle("visuals", "Remove Shadows", Cfg.Visuals.NoShadows, function(v) Cfg.Visuals.NoShadows = v saveCfg() end)
    slider("visuals", "Time of Day", 0, 24, Cfg.Visuals.TimeOfDay, 1, ":00", function(v) Cfg.Visuals.TimeOfDay = v saveCfg() end)

    section("players", "ESP")
    toggle("players", "Enable ESP", Cfg.Players.ESP, function(v) Cfg.Players.ESP = v saveCfg() end)
    toggle("players", "Names", Cfg.Players.ESPNames, function(v) Cfg.Players.ESPNames = v saveCfg() end)
    toggle("players", "Health", Cfg.Players.ESPHealth, function(v) Cfg.Players.ESPHealth = v saveCfg() end)
    toggle("players", "Distance", Cfg.Players.ESPDistance, function(v) Cfg.Players.ESPDistance = v saveCfg() end)
    slider("players", "Max Distance", 100, 5000, Cfg.Players.MaxDistance, 50, "", function(v) Cfg.Players.MaxDistance = v saveCfg() end)

    section("misc", "Movement")
    toggle("misc", "Speed Hack", Cfg.Misc.SpeedHack, function(v) Cfg.Misc.SpeedHack = v saveCfg() end)
    slider("misc", "Speed Value", 16, 500, Cfg.Misc.SpeedValue, 1, "", function(v) Cfg.Misc.SpeedValue = v saveCfg() end)
    toggle("misc", "Jump Power", Cfg.Misc.JumpPower, function(v) Cfg.Misc.JumpPower = v saveCfg() end)
    slider("misc", "Jump Value", 50, 500, Cfg.Misc.JumpValue, 5, "", function(v) Cfg.Misc.JumpValue = v saveCfg() end)
    toggle("misc", "Fly", Cfg.Misc.Fly, function(v) Cfg.Misc.Fly = v saveCfg() end)
    slider("misc", "Fly Speed", 20, 500, Cfg.Misc.FlySpeed, 5, "", function(v) Cfg.Misc.FlySpeed = v saveCfg() end)
    toggle("misc", "Noclip", Cfg.Misc.Noclip, function(v)
        Cfg.Misc.Noclip = v
        if not v then restoreCollide() end
        saveCfg()
    end)

    section("misc", "Features")
    toggle("misc", "Anti-AFK", Cfg.Misc.AntiAFK, function(v) Cfg.Misc.AntiAFK = v saveCfg() end)
    button("misc", "▸ Save Config", C.green, function() saveCfg() notify("Config", "saved", C.green, 2) end)
    button("misc", "▸ Reset All", C.red, function()
        for sect, vals in pairs(Cfg) do
            if type(vals) == "table" then
                for k, v in pairs(vals) do
                    if type(v) == "boolean" then Cfg[sect][k] = false end
                end
            end
        end
        restoreCollide()
        saveCfg()
        notify("Config", "reset — reload script", C.red, 3)
    end)

    section("misc", "Debug")
    local remoteList = textOutput("misc", 180, "remotes", function()
        local L = {}
        for k, r in pairs(R) do
            table.insert(L, k .. " = " .. (r and r:GetFullName() or "NOT FOUND"))
        end
        return table.concat(L, "\n")
    end)
    task.spawn(function()
        local L = {}
        for k, r in pairs(R) do
            table.insert(L, k .. " = " .. (r and r:GetFullName() or "NOT FOUND"))
        end
        remoteList.Text = table.concat(L, "\n")
    end)
    button("misc", "↻ Refresh Remotes", C.accent, function()
        R.Collect = findRemoteByKeyword("collect")
        R.Upgrade = findRemoteByKeyword("upgrade")
        R.Rebirth = findRemoteByKeyword("rebirth")
        R.Place = findRemoteByKeyword("place")
        R.Sell = findRemoteByKeyword("sell")
        R.Trade = findRemoteByKeyword("trade")
        R.Dup = findRemoteByKeyword("duplicate") or findRemoteByKeyword("dup")
        R.Buy = findRemoteByKeyword("buy")
        R.Pickup = findRemoteByKeyword("pickup") or findRemoteByKeyword("pick")
        R.Speed = findRemoteByKeyword("speed")
        local L = {}
        for k, r in pairs(R) do
            table.insert(L, k .. " = " .. (r and r:GetFullName() or "NOT FOUND"))
        end
        remoteList.Text = table.concat(L, "\n")
        notify("Debug", "remotes refreshed", C.accent, 2)
    end)

    switchTab("farm")
    blurOn()

    task.delay(0.4, function()
        notify("ALWAYSLOSE · ETFB", "loaded · rightshift to toggle", C.cyan, 4)
    end)

    print("[ETFB] loaded.")

    getgenv().ETFB_Cleanup = function()
        getgenv().ETFB_Loaded = false
        restoreCollide()
        for _, h in pairs(S.espHL) do if h and h.Parent then pcall(function() h:Destroy() end) end end
        for _, bb in pairs(S.espBB) do if bb and bb.Parent then pcall(function() bb:Destroy() end) end end
        pcall(function()
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(70,70,70)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end)
        if S.flyBV and S.flyBV.Parent then pcall(function() S.flyBV:Destroy() end) end
        if S.flyBG and S.flyBG.Parent then pcall(function() S.flyBG:Destroy() end) end
        if blur then pcall(function() blur:Destroy() end) end
        if gui then pcall(function() gui:Destroy() end) end
    end
end

local ok, err = pcall(boot)
if not ok then
    warn("[ETFB] FATAL: " .. tostring(err))
    if setclipboard then pcall(setclipboard, "[ETFB] FATAL:\n" .. tostring(err)) end
end
