
-- User: cloud
-- Date: 2017.3.15

-- [[文件功能：改良版tips]]

CommonTips = CommonTips or BaseClass()

function CommonTips:__init(delay)
    self.delay = delay or 30
    self:createRootWnd()
end

function CommonTips:createRootWnd()
    self:LoadLayoutFinish()
    self:registerCallBack()
end


function CommonTips:closeCallBack()

end


function CommonTips:LoadLayoutFinish()
    self.screen_bg = ccui.Layout:create()
    self.screen_bg:setAnchorPoint(cc.p(0.5, 0.5))
    self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH, display.height))
    self.screen_bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self.screen_bg:setTouchEnabled(true)
    self.screen_bg:setSwallowTouches(false)

    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(cc.p(0, 0))
    self.screen_bg:addChild(self.root_wnd)
    
    self.background = ccui.ImageView:create(PathTool.getResFrame("common","common_1034"), LOADTEXT_TYPE_PLIST)
    self.background:setScale9Enabled(true)
    -- self.background:setCapInsets(cc.rect(100,60,1,1))
    self.background:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:addChild(self.background)
end


function CommonTips:registerCallBack()
    self.screen_bg:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            TipsManager:getInstance():hideTips()
        end
    end)
end


function CommonTips:setPosition(x, y)
    self.root_wnd:setAnchorPoint(cc.p(0, 1))
    self.root_wnd:setPosition(cc.p(x, y))
end

function CommonTips:addToParent(parent, zOrder)
    self.parent_wnd = parent
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:removeFromParent()
        if not tolua.isnull(parent) then
            self.parent_wnd:addChild(self.root_wnd,zOrder)
        end
    end
end

function CommonTips:setPos(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function CommonTips:getContentSize()
    return self.root_wnd:getContentSize()
end


function CommonTips:getScreenBg()
    return self.screen_bg
end

function CommonTips:showTips(str, width, font_size)
    local font_size = font_size or 6
    self.tips_label = self:recoutTextFieldSize(str, width, font_size)
    local size = self.tips_label:getSize()
    local size_width = math.max(80 + size.width, self.background:getContentSize().width)
    local size_height = math.max(70 + size.height, self.background:getContentSize().height)
    self.root_wnd:setContentSize(cc.size(size_width, size_height))
    self.background:setContentSize(cc.size(size_width, size_height))

    self.tips_label:setPosition(cc.p(37, size_height - 35))
    self.root_wnd:addChild(self.tips_label)
end

-- 从新计算文本的大小
function CommonTips:recoutTextFieldSize(str_label, width, font_size)
    local label = createRichLabel(font_size, Config.ColorData.data_new_color4[6], cc.p(0, 1), nil, 6, 0, width)
    label:setString(str_label)
    return label
end

function CommonTips:setAnchorPoint(pos)
    self.screen_bg:setAnchorPoint(pos)
end
function CommonTips:open()
    local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
    parent:addChild(self.screen_bg)
	doStopAllActions(self.screen_bg)
    delayRun(self.screen_bg, self.delay, function()
        TipsManager:getInstance():hideTips()
    end)
end


function CommonTips:close()
    if self.screen_bg then
	  doStopAllActions(self.screen_bg)
      self.screen_bg:removeFromParent()
      self.screen_bg = nil
    end
end
