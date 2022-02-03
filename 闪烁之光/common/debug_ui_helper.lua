----------------------------------------------------
---- UI 帮助工具
---- @author whjing2011@gmail.com
------------------------------------------------------
DebugUIHelper = DebugUIHelper or BaseClass()

function DebugUIHelper:__init(obj)
    GM_UI_DEBUG = true
    DebugUIHelper.Instance = self
    self.obj = obj
    self:initUI()
    self:registerEvents()
    self:updateInfo()
end

function DebugUIHelper:getInstance(obj)
    if DebugUIHelper.Instance == nil then
        DebugUIHelper.New(obj)
    end
    return DebugUIHelper.Instance
end

function DebugUIHelper:initUI()
    self.root = ccui.Layout:create()
    ViewManager:addToLayerByTag(self.root, ViewMgrTag.DEBUG_TAG, 100)
    self.root:setContentSize(cc.size(SCREEN_WIDTH + 200, SCREEN_HEIGHT + 200))
    local size = cc.size(320, 460)
    self.container = ccui.Layout:create()
    self.root:addChild(self.container, 20)
    self.container:setBackGroundColor(cc.c3b(255,255,255))
    self.container:setBackGroundColorOpacity(255)
    self.container:setBackGroundColorType(1)
    self.container:setContentSize(size)
    self.container:setAnchorPoint(0.5, 0.5)
    self.container:setPosition(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)

    self.close_btn = CustomButton.New(self.container, PathTool.getResFrame("common", "common_1028"),nil, nil, LOADTEXT_TYPE_PLIST)
    self.close_btn:setAnchorPoint(cc.p(1,1))
    self.close_btn:setPosition(size.width - 2, size.height - 2)

    local y = size.height - 30
    local x = 100
    local dy = 30
    local fontsize = 22
    self.showVo = ccui.Button:create()
    self.container:addChild(self.showVo)
    self.showVo:setTitleColor(cc.c3b(0,0,0))
    self.showVo:setContentSize(cc.size(30, 25))
    self.showVo:setAnchorPoint(0, 0)
    self.showVo:setPosition(x, y)
    self.showVo:setTitleFontSize(fontsize)
    self.showVo:setTitleText("VO")
    self.showVo:setVisible(false)
    self.parent = ccui.Button:create()
    self.container:addChild(self.parent)
    self.parent:setTitleColor(cc.c3b(0,0,0))
    self.parent:setContentSize(cc.size(30, 25))
    self.parent:setAnchorPoint(0, 0)
    self.parent:setPosition(x + 50, y)
    self.parent:setTitleFontSize(fontsize)
    self.parent:setTitleText("父层")
    self.back = ccui.Button:create()
    self.container:addChild(self.back)
    self.back:setTitleColor(cc.c3b(0,0,0))
    self.back:setContentSize(cc.size(30, 25))
    self.back:setAnchorPoint(0, 0)
    self.back:setPosition(x + 100, y)
    self.back:setTitleFontSize(fontsize)
    self.back:setTitleText("返回")
    self.showHide = ccui.Button:create()
    self.container:addChild(self.showHide)
    self.showHide:setTitleColor(cc.c3b(0,0,0))
    self.showHide:setContentSize(cc.size(30, 25))
    self.showHide:setAnchorPoint(0, 0)
    self.showHide:setPosition(x + 150, y)
    self.showHide:setTitleFontSize(fontsize)
    self.showHide:setTitleText("隐")

    y = y - dy
    local label = cc.Label:createWithTTF("TAG:", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    label = cc.Label:createWithTTF("", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,255,255))
    label:setAnchorPoint(0, 0)
    self.container:addChild(label)
    label:setPosition(x+2, y)
    self.tag = label

    y = y - dy
    label = cc.Label:createWithTTF("Name:", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    label = cc.Label:createWithTTF("", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,255,255))
    label:setAnchorPoint(0, 0)
    self.container:addChild(label)
    label:setPosition(x+2, y)
    self.name = label

    self.showSub = ccui.Button:create()
    self.container:addChild(self.showSub)
    self.showSub:setTitleColor(cc.c3b(0,0,0))
    self.showSub:setContentSize(cc.size(30, 25))
    self.showSub:setAnchorPoint(0, 0)
    self.showSub:setPosition(size.width - 20, y)
    self.showSub:setTitleText("子")
    self.showSub:setTitleFontSize(fontsize)
    self.showSub.type = 1

    y = y - dy
    label = cc.Label:createWithTTF("Type:", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    label = cc.Label:createWithTTF("", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,255,255))
    label:setAnchorPoint(0, 0)
    self.container:addChild(label)
    label:setPosition(x+2, y)
    self.type = label

    y = y - dy
    label = cc.Label:createWithTTF("宽(W):", DEFAULT_FONT, fontsize)
    label:setAnchorPoint(1, 0)
    label:setTextColor(cc.c4b(0,0,0,255))
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.width = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.width:setAnchorPoint(0, 0)
    self.container:addChild(self.width)
    self.width:setPosition(x + 5, y-5)
    self.width:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("高(H):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.height = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.height:setAnchorPoint(0, 0)
    self.container:addChild(self.height)
    self.height:setPosition(x + 5, y-5)
    self.height:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("缩放(X):", DEFAULT_FONT, fontsize)
    label:setAnchorPoint(1, 0)
    label:setTextColor(cc.c4b(0,0,0,255))
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.scaleX = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.scaleX:setAnchorPoint(0, 0)
    self.container:addChild(self.scaleX)
    self.scaleX:setPosition(x + 5, y-5)
    self.scaleX:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("缩放(Y):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.scaleY = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.scaleY:setAnchorPoint(0, 0)
    self.container:addChild(self.scaleY)
    self.scaleY:setPosition(x + 5, y-5)
    self.scaleY:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("锚点(X):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.ui_ax = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.ui_ax:setAnchorPoint(0, 0)
    self.container:addChild(self.ui_ax)
    self.ui_ax:setPosition(x + 5, y-5)
    self.ui_ax:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("锚点(Y):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.ui_ay = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.ui_ay:setAnchorPoint(0, 0)
    self.container:addChild(self.ui_ay)
    self.ui_ay:setPosition(x + 5, y-5)
    self.ui_ay:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("世界坐标(X):", DEFAULT_FONT, fontsize)
    label:setAnchorPoint(1, 0)
    label:setTextColor(cc.c4b(0,0,0,255))
    self.container:addChild(label)
    label:setPosition(x-2, y)
    label = cc.Label:createWithTTF("", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,255,255))
    label:setAnchorPoint(0, 0)
    self.container:addChild(label)
    label:setPosition(x+2, y)
    self.world_x = label

    y = y - dy
    label = cc.Label:createWithTTF("世界坐标(Y):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    label = cc.Label:createWithTTF("", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,255,255))
    label:setAnchorPoint(0, 0)
    self.container:addChild(label)
    label:setPosition(x+2, y)
    self.world_y = label

    y = y - dy
    label = cc.Label:createWithTTF("UI坐标(X):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.ui_x = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.ui_x:setAnchorPoint(0, 0)
    self.container:addChild(self.ui_x)
    self.ui_x:setPosition(x + 5, y-5)
    self.ui_x:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("UI坐标(Y):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.ui_y = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.ui_y:setAnchorPoint(0, 0)
    self.container:addChild(self.ui_y)
    self.ui_y:setPosition(x + 5, y-5)
    self.ui_y:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("字体颜色:", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.color_r = ccui.EditBox:create(cc.size(50, 30), ccui.Scale9Sprite:create())
    self.color_r:setAnchorPoint(0, 0)
    self.color_r:setFontSize(15)
    self.container:addChild(self.color_r)
    self.color_r:setPosition(x + 5, y-5)
    self.color_r:setFontColor(cc.c3b(0,0,255))
    self.color_g = ccui.EditBox:create(cc.size(50, 30), ccui.Scale9Sprite:create())
    self.color_g:setAnchorPoint(0, 0)
    self.container:addChild(self.color_g)
    self.color_g:setPosition(x + 55, y-5)
    self.color_g:setFontSize(15)
    self.color_g:setFontColor(cc.c3b(0,0,255))
    self.color_b = ccui.EditBox:create(cc.size(50, 30), ccui.Scale9Sprite:create())
    self.color_b:setAnchorPoint(0, 0)
    self.container:addChild(self.color_b)
    self.color_b:setPosition(x + 105, y-5)
    self.color_b:setFontSize(15)
    self.color_b:setFontColor(cc.c3b(0,0,255))
    self.color_a = ccui.EditBox:create(cc.size(50, 30), ccui.Scale9Sprite:create())
    self.color_a:setAnchorPoint(0, 0)
    self.container:addChild(self.color_a)
    self.color_a:setPosition(x + 155, y-5)
    self.color_a:setFontSize(15)
    self.color_a:setFontColor(cc.c3b(0,0,255))

    y = y - dy
    label = cc.Label:createWithTTF("字体大小(Y):", DEFAULT_FONT, fontsize)
    label:setTextColor(cc.c4b(0,0,0,255))
    label:setAnchorPoint(1, 0)
    self.container:addChild(label)
    label:setPosition(x-2, y)
    self.fontsize = ccui.EditBox:create(cc.size(150, 30), ccui.Scale9Sprite:create())
    self.fontsize:setAnchorPoint(0, 0)
    self.container:addChild(self.fontsize)
    self.fontsize:setPosition(x + 5, y-5)
    self.fontsize:setFontColor(cc.c3b(0,0,255))

    self.layer = ccui.ScrollView:create()
    self.container:addChild(self.layer)
    self.layer:setContentSize(145,300)
    self.layer:setInnerContainerSize(self.layer:getContentSize())
    self.layer:setAnchorPoint(0,0)
    self.layer:setPosition(size.width - 148, 65)
    -- self.layer:setTouchEnabled(true)
    self.layer:setSwallowTouches(true)
    self.layer:setBounceEnabled(true)
    self.layer:setClippingEnabled(true)
    self.layer:setScrollBarEnabled(false)
    -- showLayoutRect(self.layer)
end

function DebugUIHelper:registerEvents()
    handleTouchEnded(self.close_btn, function()
        self:close()
    end)
    handleTouchEnded(self.showVo, function()
        require("common/debug_ui_var")
        DebugUIVar:getInstance():open(self.obj.vo)
    end)
    handleTouchEnded(self.parent, function()
        self:setNewObj(self.obj:getParent())
    end)
    handleTouchEnded(self.back, function()
        self:setNewObj(self.obj_bak)
    end)
    handleTouchEnded(self.showHide, function()
        if self.obj:isVisible() then
            self.obj:setVisible(false)
            self.showHide:setTitleText("显")
        else
            self.obj:setVisible(true)
            self.showHide:setTitleText("隐")
        end
    end)
    handleTouchEnded(self.showSub, function()
        if self.showSub.type == 1 then
            self.showSub.type = 0
            self.showSub:setTitleText("父")
        else
            self.showSub.type = 1
            self.showSub:setTitleText("子")
        end
        self:updateObjChild()
    end)
    self.container:setTouchEnabled(true)
    self.container:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            pos = sender:getParent():convertToNodeSpaceAR(pos)
            sender:setPosition(pos)
        end
    end)
    local editBoxChange = function(eventType, sender)
        if eventType == "began" then
            sender._text_ = sender:getText()
            return false
        elseif eventType == "return" and sender._text_ ~= sender:getText() then
            return true
        end
    end
    self.width:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setContentSize(cc.size(tonumber(sender:getText()), self.obj:getContentSize().height))
            self:updateObjBorder()
        end
    end)
    self.height:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setContentSize(cc.size(self.obj:getContentSize().width, tonumber(sender:getText())))
            self:updateObjBorder()
        end
    end)
    self.ui_ax:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setAnchorPoint(cc.p(tonumber(sender:getText()), self.obj:getAnchorPoint().y))
            self:updateObjBorder()
        end
    end)
    self.ui_ay:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setAnchorPoint(cc.p(self.obj:getAnchorPoint().x, tonumber(sender:getText())))
            self:updateObjBorder()
        end
    end)
    self.ui_x:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setPositionX(tonumber(sender:getText()))
            self:updateObjBorder()
        end
    end)
    self.ui_y:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setPositionY(tonumber(sender:getText()))
            self:updateObjBorder()
        end
    end)
    self.scaleX:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setScaleX(tonumber(sender:getText()))
            self:updateObjBorder()
        end
    end)
    self.scaleY:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            self.obj:setScaleY(tonumber(sender:getText()))
            self:updateObjBorder()
        end
    end)
    local function updateColor(r, g, b, a)
        local c = self:getObjColor()
        if c and c.a then
            self.obj[c.set](self.obj, cc.c4b(r or c.r, g or c.g, b or c.b, a or c.a))
        elseif c then
            self.obj[c.set](self.obj, cc.c3b(r or c.r, g or c.g, b or c.b))
        end
    end
    self.color_r:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            updateColor(tonumber(sender:getText()))
        end
    end)
    self.color_g:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            updateColor(nil, tonumber(sender:getText()))
        end
    end)
    self.color_b:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            updateColor(nil, nil, tonumber(sender:getText()))
        end
    end)
    self.color_a:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            updateColor(nil, nil, nil, tonumber(sender:getText()))
        end
    end)
    local function updateFontSize(fontsize)
        local font = self:getObjFont()
        if font then
            self.obj[font.set](self.obj, fontsize)
        end
    end
    self.fontsize:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            updateFontSize(tonumber(sender:getText()))
            self:updateObjBorder()
        end
    end)

	local function onTouchBegan( touch, event )
        local pos = touch:getLocation()
        self:selectObj(pos)
        return true 
    end
	local function onTouchEnded( touch, event )
    end
	self.touch_listener = cc.EventListenerTouchOneByOne:create()
    self.touch_listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.touch_listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.touch_listener:setSwallowTouches(true)
    -- self.touch_listener:setTouchPriority(-200)
    -- self.root:setSwallowTouches(true)
    self.root:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.touch_listener, self.root)
    -- self.root:getEventDispatcher():addEventListenerWithFixedPriority(self.touch_listener, -200)

    self.keyevt = GlobalKeybordEvent:getInstance()
    self.keyevt:add(function() self:updatePos(-1, 0, 124) end, nil, 124, 0)
    self.keyevt:add(function() self:updatePos(1, 0, 127) end, nil, 127, 0)
    self.keyevt:add(function() self:updatePos(0, 1, 146) end, nil, 146, 0)
    self.keyevt:add(function() self:updatePos(0, -1, 142) end, nil, 142, 0)
end

function DebugUIHelper:updateObjBorder()
    if self.obj.draw_border == nil then
        self.obj.draw_border = cc.DrawNode:create()
        self.obj:getParent():addChild(self.obj.draw_border, 100000)
    end
    self.obj.draw_border:clear()
    self.obj.draw_border:setContentSize(self.obj:getBoundingBox())
    self.obj.draw_border:setAnchorPoint(self.obj:getAnchorPoint())
    self.obj.draw_border:setPosition(self.obj:getPosition())
    self.obj.draw_border:drawRect(cc.p(0, 0), cc.p(self.obj:getBoundingBox().width, self.obj:getBoundingBox().height), cc.c4f(0,1,0, 1))
end

function DebugUIHelper:setNewObj(newobj)
    if not newobj then return end
    if tolua.type(newobj) == "cc.Scene" then return end
    if self.obj.draw_border then
        doRemoveFromParent(self.obj.draw_border)
        self.obj.draw_border = nil
    end
    self.obj_bak = self.obj
    self.obj = newobj
    self:updateInfo()
    self.showVo:setVisible(type(newobj.vo) == 'table')
    -- print("=======", tolua.type(self.obj), tolua.type(newobj))
end

function DebugUIHelper:selectObj(pos)
    if not self.root:isVisible() then return end
    local newobj = self:matchObj(cc.Director:getInstance():getRunningScene(), 0, pos, nil)
    self:setNewObj(newobj)
end

function DebugUIHelper:matchObj(node, n, pos, obj)
    if n > 50 then return obj end
    local subNode = node:getChildren()
    for _, sub in pairs(subNode) do
        if sub:isVisible() then
            if n >= 2 and self:hitObj(sub, pos) then
                obj = self:compObj(sub, obj)
            end
            obj = self:matchObj(sub, n + 1, pos, obj)
        end
    end
    return obj
end

function DebugUIHelper:hitObj(node, pos)
    local p = node:getParent():convertToNodeSpace(pos)
    local rect = node:getBoundingBox()
    return cc.rectContainsPoint(rect, p)
end

function DebugUIHelper:compObj(obj, obj1)
    if obj:getBoundingBox().width < 1 or obj:getBoundingBox().height < 1 
        or obj:getBoundingBox().width >= SCREEN_WIDTH or obj:getBoundingBox().height >= SCREEN_HEIGHT then 
        return obj1
    elseif obj1 == nil then
        return obj
    elseif obj:getGlobalZOrder() > obj1:getGlobalZOrder() then
        return obj
    elseif obj:getBoundingBox().width < obj1:getBoundingBox().width then
        return obj
    elseif obj:getBoundingBox().height < obj1:getBoundingBox().height then
        return obj
    end
    return obj1
end

function DebugUIHelper:updateInfo()
    self.type:setString(tolua.type(self.obj))
    self.width:setText(self.obj:getBoundingBox().width)
    self.height:setText(self.obj:getBoundingBox().height)
    self.scaleX:setText(self.obj:getScaleX())
    self.scaleY:setText(self.obj:getScaleY())
    self.ui_ax:setText(self.obj:getAnchorPoint().x)
    self.ui_ay:setText(self.obj:getAnchorPoint().y)
    local pos = self.obj:convertToWorldSpace(cc.p(0,0))
    self.world_x:setString(math.ceil(pos.x))
    self.world_y:setString(math.ceil(pos.y))
    self.ui_x:setText(math.ceil(self.obj:getPositionX()))
    self.ui_y:setText(math.ceil(self.obj:getPositionY()))
    self.color_r:setText("")
    self.color_g:setText("")
    self.color_b:setText("")
    self.color_a:setText("")
    self.fontsize:setText("")
    local color = self:getObjColor()
    if color then
        self.color_r:setText(color.r)
        self.color_g:setText(color.g)
        self.color_b:setText(color.b)
        self.color_a:setText(color.a or 255)
    end
    local font = self:getObjFont()
    if font then
        self.fontsize:setText(font.size)
    end
    self:updateObjBorder()
    self:updateObjChild()
    local name = self.obj:getName() or ""
    if type(name) ~= "string" and type(name) ~= "number" then 
        name = ""
    end 
    self.name:setString(name)
    self.tag:setString(self.obj:getTag())
end

function DebugUIHelper:getObjFont()
    local obj = self.obj
    local font = nil
    local getlist = {"getTitleFontSize", "getFontSize", "getSystemFontSize", "getBMFontSize"}
    local setlist = {"setTitleFontSize", "setFontSize", "setSystemFontSize", "setBMFontSize"}
    for i, f in ipairs(getlist) do
        if obj[f] then
            if font == nil or font.size == 12 then
                font = {size = obj[f](obj), get = f, set = setlist[i]}
            end
        end
    end
    return font
end

function DebugUIHelper:getObjColor()
    local obj = self.obj
    local c = nil
    local getlist = {"getTextColor", "getTitleColor", "getFontColor", "getColor"}
    local setlist = {"setTextColor", "setTitleColor", "setFontColor", "setColor"}
    for i, f in ipairs(getlist) do
        if obj[f] then
            if c == nil or (c.r == 255 and c.g == 255 and c.b == 255) then
                c = obj[f](obj)
                c.get = f
                c.set = setlist[i]
            end
        end
    end
    return c
end

function DebugUIHelper:updatePos(dx, dy, keyCode, n)
    if not self.obj then return end
    if n and not self.keyevt:inKeyCode(keyCode) then return end
    n = n or 0
    self.obj:setPositionX(self.obj:getPositionX() + dx)
    self.obj:setPositionY(self.obj:getPositionY() + dy)
    self:updateInfo()
    local time = math.max(0.01, 0.2-n*0.02)
    delayRun(self.root, time, function() self:updatePos(dx, dy, keyCode, n + 1) end)
end

function DebugUIHelper:updateObjChild()
    self.layer:removeAllChildren()
    self.layer:setInnerContainerSize(self.layer:getContentSize())
    local items = self.obj:getChildren()
    if self.showSub.type == 0 then
        items = self.obj:getParent():getChildren()
    end
    local width, height = 145, 20
    local y = height * #items
    self.layer:setInnerContainerSize(cc.size(self.layer:getContentSize().width, math.max(y, self.layer:getContentSize().height)))
    for _, v in pairs(items) do
        y = y - height
        local item = ccui.Button:create()
        item:setContentSize(width - 25, height)
        item:setAnchorPoint(0, 0)
        item:setPosition(0, y)
        item:setTitleColor(cc.c3b(0,0,0))
        item:setTitleText(tolua.type(v))
        self.layer:addChild(item)
        handleTouchEnded(item, function()
            self:setNewObj(v)
        end)
    end
end

function DebugUIHelper:open()
    self.root:setVisible(true)
    self.touch_listener:setSwallowTouches(true)
end

function DebugUIHelper:close()
    self.root:setVisible(false)
    self.touch_listener:setSwallowTouches(false)
    if self.obj.draw_border then
        doRemoveFromParent(self.obj.draw_border)
        self.obj.draw_border = nil
    end
end
