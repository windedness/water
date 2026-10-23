-- watermark_lib.lua — Dark Minimal Watermark Library v1.0
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C = {
    bg=Color3.fromRGB(15,15,18), panel=Color3.fromRGB(22,22,27),
    elem=Color3.fromRGB(30,30,37), elemHover=Color3.fromRGB(40,40,48),
    stroke=Color3.fromRGB(45,45,50), text=Color3.fromRGB(200,200,205),
    textDim=Color3.fromRGB(120,120,130), accent=Color3.fromRGB(120,100,255),
    knob=Color3.fromRGB(160,140,255),
}

local Lib = {}

local function corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p return c end
local function stroke(p,col,th) local s=Instance.new("UIStroke") s.Color=col or C.stroke s.Thickness=th or 1 s.Parent=p return s end

function Lib.new()
    local self = {}
    self.C = C
    self.pages = {}
    self.tabs = {}
    self.activeTab = nil

    -- GUI
    local gui = Instance.new("ScreenGui")
    gui.Name="DarkWatermark" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true
    gui.DisplayOrder=999 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=playerGui
    self.gui = gui

    -- Bar
    local bar = Instance.new("Frame")
    bar.Size=UDim2.new(0,170,0,28) bar.Position=UDim2.new(0,20,0,20)
    bar.BackgroundColor3=C.bg bar.BackgroundTransparency=0.1
    bar.BorderSizePixel=0 bar.Active=true bar.Parent=gui
    corner(bar,6) stroke(bar)
    self.bar = bar

    local avFrame=Instance.new("Frame")
    avFrame.Size=UDim2.new(0,20,0,20) avFrame.Position=UDim2.new(0,4,0.5,-10)
    avFrame.BackgroundColor3=C.elem avFrame.BorderSizePixel=0 avFrame.ZIndex=2 avFrame.Parent=bar
    corner(avFrame,999)

    local av=Instance.new("ImageLabel")
    av.Size=UDim2.new(1,-4,1,-4) av.Position=UDim2.new(0,2,0,2)
    av.BackgroundTransparency=1
    av.Image="rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=48&h=48"
    av.ZIndex=3 av.Parent=avFrame corner(av,999)

    local barLabel=Instance.new("TextLabel")
    barLabel.Size=UDim2.new(1,-34,1,0) barLabel.Position=UDim2.new(0,30,0,0)
    barLabel.BackgroundTransparency=1
    barLabel.Text="df1nd  |  "..player.DisplayName
    barLabel.TextColor3=C.text barLabel.TextSize=12 barLabel.Font=Enum.Font.GothamMedium
    barLabel.TextXAlignment=Enum.TextXAlignment.Left
    barLabel.TextTruncate=Enum.TextTruncate.AtEnd barLabel.Parent=bar

    -- Menu
    local menu=Instance.new("Frame")
    menu.Size=UDim2.new(0,300,0,300) menu.Position=UDim2.new(0,20,0,56)
    menu.BackgroundColor3=C.bg menu.BackgroundTransparency=0.05
    menu.BorderSizePixel=0 menu.Visible=false menu.ClipsDescendants=true menu.Parent=gui
    corner(menu,8) stroke(menu,C.stroke,1)
    self.menu = menu

    local header=Instance.new("Frame")
    header.Size=UDim2.new(1,0,0,32) header.BackgroundColor3=C.panel
    header.BorderSizePixel=0 header.Active=true header.Parent=menu
    corner(header,8) self.header = header

    local headerMask=Instance.new("Frame")
    headerMask.Size=UDim2.new(1,0,0,10) headerMask.Position=UDim2.new(0,0,1,-10)
    headerMask.BackgroundColor3=C.panel headerMask.BorderSizePixel=0 headerMask.Parent=header

    local headerTitle=Instance.new("TextLabel")
    headerTitle.Size=UDim2.new(1,-40,1,0) headerTitle.Position=UDim2.new(0,12,0,0)
    headerTitle.BackgroundTransparency=1 headerTitle.Text="df1nd  •  Menu"
    headerTitle.TextColor3=C.text headerTitle.TextSize=12 headerTitle.Font=Enum.Font.GothamBold
    headerTitle.TextXAlignment=Enum.TextXAlignment.Left headerTitle.Parent=header

    local closeBtn=Instance.new("TextButton")
    closeBtn.Size=UDim2.new(0,20,0,20) closeBtn.Position=UDim2.new(1,-26,0.5,-10)
    closeBtn.BackgroundColor3=C.elem closeBtn.Text="×" closeBtn.TextColor3=C.text
    closeBtn.TextSize=14 closeBtn.Font=Enum.Font.GothamBold closeBtn.AutoButtonColor=false
    closeBtn.BorderSizePixel=0 closeBtn.ZIndex=5 closeBtn.Parent=header
    corner(closeBtn,4) self.closeBtn = closeBtn

    local tabsBar=Instance.new("Frame")
    tabsBar.Size=UDim2.new(1,-16,0,24) tabsBar.Position=UDim2.new(0,8,0,38)
    tabsBar.BackgroundColor3=C.panel tabsBar.BorderSizePixel=0 tabsBar.Parent=menu
    corner(tabsBar,4)

    local tabsHolder=Instance.new("Frame")
    tabsHolder.Size=UDim2.new(1,0,1,0) tabsHolder.BackgroundTransparency=1 tabsHolder.Parent=tabsBar
    self.tabsHolder = tabsHolder

    local tabsList=Instance.new("UIListLayout")
    tabsList.FillDirection=Enum.FillDirection.Horizontal
    tabsList.Padding=UDim.new(0,2) tabsList.VerticalAlignment=Enum.VerticalAlignment.Center
    tabsList.Parent=tabsHolder

    local tabsPad=Instance.new("UIPadding")
    tabsPad.PaddingLeft=UDim.new(0,2) tabsPad.Parent=tabsHolder

    local content=Instance.new("ScrollingFrame")
    content.Size=UDim2.new(1,-16,1,-70) content.Position=UDim2.new(0,8,0,66)
    content.BackgroundTransparency=1 content.BorderSizePixel=0
    content.ScrollBarThickness=3 content.ScrollBarImageColor3=C.accent
    content.CanvasSize=UDim2.new(0,0,0,0) content.Parent=menu
    self.content = content

    local cPad=Instance.new("UIPadding")
    cPad.PaddingTop=UDim.new(0,2) cPad.PaddingBottom=UDim.new(0,6) cPad.Parent=content

    local list=Instance.new("UIListLayout")
    list.Padding=UDim.new(0,5) list.SortOrder=Enum.SortOrder.LayoutOrder list.Parent=content

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
    end)

    -- ============ Фабрики ============
    self.section = function(text)
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,16)
        f.BackgroundTransparency=1 f.Parent=content
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0)
        l.BackgroundTransparency=1 l.Text=text l.TextColor3=C.textDim l.TextSize=10
        l.Font=Enum.Font.GothamBold l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        return f
    end

    self.button = function(text, cb)
        local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,26)
        b.BackgroundColor3=C.elem b.Text="" b.AutoButtonColor=false
        b.BorderSizePixel=0 b.Parent=content corner(b,5)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-12,1,0)
        l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=text
        l.TextColor3=C.text l.TextSize=11 l.Font=Enum.Font.GothamMedium
        l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=b
        b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=C.elemHover}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=C.elem}):Play() end)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        return b
    end

    self.checkbox = function(text, default, cb)
        local state = default or false
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,26)
        f.BackgroundColor3=C.elem f.BorderSizePixel=0 f.Parent=content corner(f,5)
        local box=Instance.new("Frame") box.Size=UDim2.new(0,14,0,14)
        box.Position=UDim2.new(0,8,0.5,-7)
        box.BackgroundColor3=state and C.accent or C.elemHover
        box.BorderSizePixel=0 box.Parent=f corner(box,3) stroke(box)
        local check=Instance.new("TextLabel") check.Size=UDim2.new(1,0,1,0)
        check.BackgroundTransparency=1 check.Text="✓" check.TextColor3=Color3.new(1,1,1)
        check.TextSize=11 check.Font=Enum.Font.GothamBold check.Visible=state check.Parent=box
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-36,1,0)
        l.Position=UDim2.new(0,28,0,0) l.BackgroundTransparency=1 l.Text=text
        l.TextColor3=C.text l.TextSize=11 l.Font=Enum.Font.GothamMedium
        l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,0,1,0)
        btn.BackgroundTransparency=1 btn.Text="" btn.Parent=f
        local function set(v)
            state=v check.Visible=v
            TweenService:Create(box,TweenInfo.new(0.12),{BackgroundColor3=v and C.accent or C.elemHover}):Play()
            if cb then cb(v) end
        end
        btn.MouseButton1Click:Connect(function() set(not state) end)
        return f
    end

    self.slider = function(text, min, max, default, cb)
        local val = default or min
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,38)
        f.BackgroundColor3=C.elem f.BorderSizePixel=0 f.Parent=content corner(f,5)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-60,0,18)
        l.Position=UDim2.new(0,10,0,2) l.BackgroundTransparency=1 l.Text=text
        l.TextColor3=C.text l.TextSize=11 l.Font=Enum.Font.GothamMedium
        l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=f
        local valLabel=Instance.new("TextLabel") valLabel.Size=UDim2.new(0,50,0,18)
        valLabel.Position=UDim2.new(1,-55,0,2) valLabel.BackgroundTransparency=1
        valLabel.Text=tostring(val) valLabel.TextColor3=C.accent valLabel.TextSize=11
        valLabel.Font=Enum.Font.GothamBold valLabel.TextXAlignment=Enum.TextXAlignment.Right valLabel.Parent=f
        local barBg=Instance.new("Frame") barBg.Size=UDim2.new(1,-20,0,4)
        barBg.Position=UDim2.new(0,10,0,24) barBg.BackgroundColor3=C.elemHover
        barBg.BorderSizePixel=0 barBg.Parent=f corner(barBg,2)
        local fill=Instance.new("Frame") fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
        fill.BackgroundColor3=C.accent fill.BorderSizePixel=0 fill.Parent=barBg corner(fill,2)
        local knob=Instance.new("Frame") knob.Size=UDim2.new(0,10,0,10)
        knob.AnchorPoint=Vector2.new(0.5,0.5) knob.Position=UDim2.new(fill.Size.X.Scale,0,0.5,0)
        knob.BackgroundColor3=C.knob knob.BorderSizePixel=0 knob.ZIndex=3 knob.Parent=barBg
        corner(knob,999) stroke(knob,C.accent,1)
        local hit=Instance.new("TextButton") hit.Size=UDim2.new(1,0,0,20)
        hit.Position=UDim2.new(0,0,0,18) hit.BackgroundTransparency=1 hit.Text="" hit.Parent=f
        local dragging=false
        local function update(absX)
            local rel=math.clamp((absX-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
            val=math.floor(min+(max-min)*rel+0.5)
            valLabel.Text=tostring(val) fill.Size=UDim2.new(rel,0,1,0)
            knob.Position=UDim2.new(rel,0,0.5,0)
            if cb then cb(val) end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true update(i.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                update(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=false
            end
        end)
        return f
    end

    self.dropdown = function(text, options, defaultIndex, cb)
        local selected=options[defaultIndex or 1]
        local opened=false
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,26)
        f.BackgroundColor3=C.elem f.BorderSizePixel=0 f.ClipsDescendants=true
        f.Parent=content corner(f,5)
        local h=Instance.new("TextButton") h.Size=UDim2.new(1,0,0,26)
        h.BackgroundTransparency=1 h.Text="" h.Parent=f
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-40,1,0)
        l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1
        l.Text=text..":  "..selected l.TextColor3=C.text l.TextSize=11
        l.Font=Enum.Font.GothamMedium l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=h
        local arrow=Instance.new("TextLabel") arrow.Size=UDim2.new(0,20,1,0)
        arrow.Position=UDim2.new(1,-24,0,0) arrow.BackgroundTransparency=1
        arrow.Text="▼" arrow.TextColor3=C.textDim arrow.TextSize=8
        arrow.Font=Enum.Font.GothamBold arrow.Parent=h
        local holder=Instance.new("Frame") holder.Size=UDim2.new(1,0,0,0)
        holder.Position=UDim2.new(0,0,0,26) holder.BackgroundTransparency=1 holder.Parent=f
        for i,opt in ipairs(options) do
            local ob=Instance.new("TextButton") ob.Size=UDim2.new(1,-8,0,22)
            ob.Position=UDim2.new(0,4,0,(i-1)*24) ob.BackgroundColor3=C.elemHover
            ob.Text="" ob.AutoButtonColor=false ob.BorderSizePixel=0 ob.Parent=holder
            corner(ob,4)
            local ol=Instance.new("TextLabel") ol.Size=UDim2.new(1,-8,1,0)
            ol.Position=UDim2.new(0,6,0,0) ol.BackgroundTransparency=1 ol.Text=opt
            ol.TextColor3=C.text ol.TextSize=11 ol.Font=Enum.Font.GothamMedium
            ol.TextXAlignment=Enum.TextXAlignment.Left ol.Parent=ob
            ob.MouseButton1Click:Connect(function()
                selected=opt l.Text=text..":  "..selected opened=false
                arrow.Text="▼"
                TweenService:Create(f,TweenInfo.new(0.18),{Size=UDim2.new(1,0,0,26)}):Play()
                if cb then cb(opt) end
            end)
        end
        h.MouseButton1Click:Connect(function()
            opened=not opened arrow.Text=opened and "▲" or "▼"
            local target=opened and UDim2.new(1,0,0,28+#options*24) or UDim2.new(1,0,0,26)
            TweenService:Create(f,TweenInfo.new(0.18,Enum.EasingStyle.Quart),{Size=target}):Play()
        end)
        return f
    end

    self.separator = function()
        local s=Instance.new("Frame") s.Size=UDim2.new(1,0,0,1)
        s.BackgroundColor3=C.stroke s.BorderSizePixel=0 s.Parent=content return s
    end

    self.paragraph = function(text)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,32)
        l.BackgroundColor3=C.panel l.Text="  "..text l.TextColor3=C.textDim
        l.TextSize=10 l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
        l.TextYAlignment=Enum.TextYAlignment.Center l.TextWrapped=true l.Parent=content
        corner(l,5) return l
    end

    -- ============ Вкладки ============
    function self.tab(name, build)
        local btn=Instance.new("TextButton") btn.Size=UDim2.new(0,60,1,-4)
        btn.BackgroundColor3=C.elem btn.Text="" btn.AutoButtonColor=false
        btn.BorderSizePixel=0 btn.Parent=tabsHolder corner(btn,4)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0)
        l.BackgroundTransparency=1 l.Text=name l.TextColor3=C.textDim
        l.TextSize=10 l.Font=Enum.Font.GothamMedium l.Parent=btn
        self.pages[name]=build
        self.tabs[name]={btn=btn,label=l}
        btn.MouseButton1Click:Connect(function()
            self:selectTab(name)
        end)
        return btn
    end

    function self:clearContent()
        for _,v in ipairs(content:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") then
                v:Destroy()
            end
        end
    end

    function self:selectTab(name)
        self.activeTab=name
        for n,data in pairs(self.tabs) do
            TweenService:Create(data.btn,TweenInfo.new(0.12),{
                BackgroundColor3 = n==name and C.accent or C.elem
            }):Play()
            data.label.TextColor3 = n==name and Color3.new(1,1,1) or C.textDim
        end
        self:clearContent()
        if self.pages[name] then self.pages[name]() end
    end

    -- ============ Open/Close ============
    self.menuOpen=false

    function self:open()
        self.menuOpen=true
        menu.Visible=true
        local vp=workspace.CurrentCamera.ViewportSize
        local bx=bar.Position.X.Offset
        local by=bar.Position.Y.Offset+34
        local mx=math.clamp(bx,0,math.max(0,vp.X-300))
        local my=by
        if my+300>vp.Y then my=bar.Position.Y.Offset-300-4 end
        if my<0 then my=0 end
        menu.Position=UDim2.new(0,mx,0,my)
        menu.Size=UDim2.new(0,300,0,0)
        TweenService:Create(menu,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,300,0,300)
        }):Play()
        if not self.activeTab and self.tabs["Main"] then
            self:selectTab("Main")
        end
    end

    function self:close()
        self.menuOpen=false
        TweenService:Create(menu,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
            Size=UDim2.new(0,300,0,0)
        }):Play()
        task.delay(0.2,function() menu.Visible=false end)
    end

    closeBtn.MouseButton1Click:Connect(function() self:close() end)

    -- ============ Drag bar ============
    local barDragging,barDragStart,barStartPos,barMoved=false,nil,nil,false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            barDragging=true barMoved=false
            barDragStart=i.Position barStartPos=bar.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not barDragging then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        local d=i.Position-barDragStart
        if d.Magnitude>4 then barMoved=true end
        if barMoved then
            local vp=workspace.CurrentCamera.ViewportSize
            local abs=bar.AbsoluteSize
            local x=math.clamp(barStartPos.X.Offset+d.X,0,vp.X-abs.X)
            local y=math.clamp(barStartPos.Y.Offset+d.Y,0,vp.Y-abs.Y)
            bar.Position=UDim2.new(0,x,0,y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if barDragging then
                barDragging=false
                if not barMoved then
                    if self.menuOpen then self:close() else self:open() end
                end
            end
        end
    end)

    -- ============ Drag menu за шапку ============
    local mDrag,mStart,mPos=false,nil,nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            mDrag=true mStart=i.Position mPos=menu.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not mDrag then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
        local d=i.Position-mStart
        local vp=workspace.CurrentCamera.ViewportSize
        local abs=menu.AbsoluteSize
        local x=math.clamp(mPos.X.Offset+d.X,0,vp.X-abs.X)
        local y=math.clamp(mPos.Y.Offset+d.Y,0,vp.Y-abs.Y)
        menu.Position=UDim2.new(0,x,0,y)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            mDrag=false
        end
    end)

    return self
end

return Lib
