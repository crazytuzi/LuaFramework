-- 通用协议调试界面
DebugValue = DebugValue or class("DebugValue")

DebugValueHeight = 400
DebugValueWidth = DebugValueHeight / 2

-- 创建
DebugValue.create = function()
    DebugValue.__index = DebugValue
    local layer = cc.Layer:create()
    local t = tolua.getpeer(layer)
    if not t then
        t = {}
        tolua.setpeer(layer, t)
    end           
    setmetatable(t, DebugValue)
    layer:init_view()
    return layer
end

-- 添加一个监听变量 在打开面板前添加
-- 对象是全局，或者是数组里面的变量
-- 例如  DebugValue:add("auto_id", _G)    就是监听全局变量
--       DebugValue:add("status", Battle) 就是监听Battle的status
-- value_name   字段名，也是显示出来的名字
-- base_arr     基础数组，可以是_G全局变量
-- base_getfun  获取函数，改变数值的函数，默认是 function() return base_arr[value_name] or "" end
-- base_setfun  设置函数，改变数值的函数，默认是 function(value) base_arr[value_name] = value end  可以在里面处理一些别的东西，例如setPosition
-- min_value, max_value     支持手动调整数值上下限，并且每次改变都会触发base_setfun
function DebugValue:add(value_name, base_arr, base_getfun, base_setfun, min_max_list)
    local get_fun = base_getfun or function() return base_arr[value_name] or "" end
    local set_fun = base_setfun or function(value) base_arr[value_name] = value end
    self.value_list = self.value_list or {}
    table.insert(self.value_list, {name=value_name, get_fun=get_fun, set_fun=set_fun, min_max_list = min_max_list})
end

-- 初始化基础界面
function DebugValue:init_view()
    local cv = createScrollView(SCREEN_WIDTH,DebugValueHeight,0,150,self,ccui.ScrollViewDir.horizontal)
    cv:setInnerContainerSize(cc.size(SCREEN_WIDTH*2.5,DebugValueHeight))
    self.scroll_view = cv
    -- showLayoutRect(cv)
    self.scroll_view_touchenable = true
    self.scroll_view_show = true
    local f1 = function()
        self.scroll_view_touchenable = not self.scroll_view_touchenable 
        for _, v in pairs(self.scroll_view:getChildren()) do 
            if not v.forever_show then
                for _, v2 in pairs(v:getChildren()) do 
                    if v2.setTouchEnabled then
                        v2:setTouchEnabled(self.scroll_view_touchenable)
                    end
                end
                v:setOpacity(self.scroll_view_touchenable and 255 or 128)
            end
            v:setTouchEnabled(self.scroll_view_touchenable)
        end
        self.scroll_view:setTouchEnabled(self.scroll_view_touchenable)
    end
    local f2 = function()
        self.scroll_view_show = not self.scroll_view_show
        for _, v in pairs(self.scroll_view:getChildren()) do 
            if not v.forever_show then
                v:setVisible(self.scroll_view_show)
            else
                v:setTouchEnabled(self.scroll_view_show)
            end
        end
        self.scroll_view:setTouchEnabled(self.scroll_view_show)
    end
    local f3 = function()
        -- self:clearAll()
        GlobalTimeTicket:getInstance():remove("DebugValue")
        self:removeFromParent()
    end
    local f4 = function(sender)
    end
    local button_list = {{"-点击穿透-", f1}, {"=显隐面板=", f2}, {"x整个关掉x", f3}, {"", f4, "editbox", "全局变量"}}
    local cv = createScrollView(DebugValueWidth-20,DebugValueHeight,10, 0,self.scroll_view)
    cv:setInnerContainerSize(cc.size(DebugValueWidth-20,math.max(80*(#button_list+1), DebugValueHeight)))
    showLayoutRect(cv)
    cv.is_forever = true
    for i, one in pairs(button_list) do 
        local name, fun = one[1], one[2]
        local editbox
        if one[3] == "editbox" then
            editbox = createEditBox(cv, DebugValueWidth/2-10, (0.5-i) * 80 + DebugValueHeight, DebugValueWidth-100, 50, 30, one[4], function(sender)
                -- DebugProtocalCtrl:getInstance():addCmd(self, tonumber(sender:getText()))
                -- self:addValue(sender:getText())
            end)
            editbox:setAnchorPoint(0.5, 0.5)
        else
            local button = self:addButton(cv, name, DebugValueWidth/2-10, (0.5-i) * 80 + DebugValueHeight, fun, editbox)
        end
    end
    cv.forever_show = true
    GlobalTimeTicket:getInstance():add(function() self:update() end, 0.1, 0, "DebugValue") 
    self:init_value()
end

function DebugValue:create_tips_view(i, one)
    local t_width = DebugValueWidth * (i + 0.5)
    local cv = createScrollView(DebugValueWidth-20,DebugValueHeight,t_width-DebugValueWidth/2 + 10, 0,self.scroll_view)
    cv:setInnerContainerSize(cc.size(DebugValueWidth-20,DebugValueHeight))

    local label = createRichLabel(20, 10, cc.p(0,1), cc.p(0, DebugValueHeight), 5, 0, DebugValueWidth-20)
    local str = tipsFormat("%s:%s\n", one.name, one.get_fun())
    showLayoutRect(cv)
    cv:addChild(label)
    label:setString(str)
    xzy(one)
    if one.min_max_list then 
        cv.val = {}
        for index, min_max in pairs(one.min_max_list) do
            self:addSlider(cv, DebugValueWidth/2-10, DebugValueHeight-100, one, index, min_max)
        end
    end
    return label
end

-- 添加按钮
function DebugValue:addButton(parent, name, x, y, func, editbox)
    button = ccui.Button:create()
    button:loadTextures(PathTool.getBtnRes("btn1"), "", "")
    button:setTitleText(name)
    button:setTitleFontSize(25)
    button:setPosition(x, y)
    button:setScale(0.8)
    button:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            func(editbox)
        end
    end)
    parent:addChild(button)
    return button
end

function DebugValue:addSlider(parent, x, y, one, i, min_max)
    local min_value = min_max[1] or 0
    local max_value = min_max[2] or 100
    local default = min_max[3] or 0
    min_value = math.min(min_value, max_value)
    local slider = ccui.Slider:create()
    slider:setTouchEnabled(true)
    slider:loadBarTexture(PathTool.getResFrame("common", "common_1047"), LOADTEXT_TYPE_PLIST)
    slider:loadSlidBallTextures(PathTool.getResFrame("common", "common_1014"), nil, nil, LOADTEXT_TYPE_PLIST)
    slider:loadProgressBarTexture(PathTool.getResFrame("common", "common_1047"), LOADTEXT_TYPE_PLIST)
    parent:addChild(slider, -1)
    slider.num = createWithSystemFont(0, DEFAULT_FONT, 26)
    slider.num:setPosition(slider:getContentSize().width/2, slider:getContentSize().height/2)
    slider.num:setString(min_value)
    slider:setPosition(x, y - (i-1) * 100)
    slider:setScale(2)
    slider:addChild(slider.num)
    parent.val[i] = default
    local now_percent = default/(max_value - min_value)*100
    slider:setPercent(now_percent)
    slider.num:setString(default)
    slider:addEventListener(function(sender,eventType)
        parent.val[i] = sender:getPercent() / 100 * (max_value - min_value) + min_value
        slider.num:setString(parent.val[i])
        one.set_fun(parent.val)
    end)
end

function DebugValue:init_value()
    local i = 0
    if self.value_list == nil then
        self.value_list = {}
    end
    xzy(self.value_list)
    -- table.sort(self.value_list)
    self.scroll_view:setInnerContainerSize(cc.size((#self.value_list+1) * DebugValueWidth,DebugValueHeight))
    for _, one in pairs(self.value_list) do 
        i = i + 1
        local tips_view = self:create_tips_view(i, one)
        one.update_fun = function()
            tips_view:setString(tipsFormat("%s:%s\n", one.name, one.get_fun()))
        end
    end
end

function DebugValue:clearValue(value_name)
    for index, one in pairs(self.value_list) do 
        if one.name == value_name then 
            table.remove(self.value_list, index)
            self:init_value(layer)
        end
    end
end

function DebugValue:update()
    self.value_list = self.value_list or {}
    for _, v in pairs(self.value_list) do 
        if v.update_fun then
            v.update_fun()
        end
    end
end