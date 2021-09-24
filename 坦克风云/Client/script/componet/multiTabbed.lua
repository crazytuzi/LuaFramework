--创建多页签
multiTabbed = {}

function multiTabbed:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--tabNameTb ：页签标题，tabPic 页签资源，tabSelectPic 页签按下资源，fontSize 字体大小，lspace页签行间距
function multiTabbed:createTabs(tabcfg, callback, tabPic, tabDownPic, lspace, fontSize)
    self.allTabs = {}
    self.callback = callback
    local fts = fontSize or 25
    local space = lspace or 3
    local tabMenu = CCMenu:create()
    if tabcfg ~= nil then
        for k, v in pairs(tabcfg) do
            tabItem = CCMenuItemImage:create(v.tabPic or tabPic, v.tabdPic or tabDownPic, v.tabdPic or tabDownPic)
            tabItem:setAnchorPoint(CCPointMake(0.5, 0.5))
            
            local function tabClick(idx)
                if self.selectIdex == idx then
                    do return end
                end
                if G_checkClickEnable() == false then
                    do return end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                self.oldSelectIdex = self.selectIdex
                self:tabClick(idx)
            end
            tabItem:registerScriptTapHandler(tabClick)
            tabItem:setPosition(tabItem:getContentSize().width / 2 + (k - 1) * (tabItem:getContentSize().width + space), tabItem:getContentSize().height / 2)
            
            if v.tabText then
                local lb = GetTTFLabelWrap(v.tabText, fts, CCSizeMake((tabItem:getContentSize().width - 10), 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
                lb:setPosition(CCPointMake(tabItem:getContentSize().width / 2, tabItem:getContentSize().height / 2))
                tabItem:addChild(lb, 1)
                lb:setTag(31)
                if k ~= 1 then
                    lb:setColor(G_TabLBColorGreen)
                end
            end
            
            self.allTabs[k] = tabItem
            tabMenu:addChild(tabItem)
            tabItem:setTag(k)
        end
    end
    self.tabMenu = tabMenu
    return self.tabMenu
end

--设置页签的触摸优先级
function multiTabbed:setTabTouchPriority(priority)
    if self.tabMenu then
        self.tabMenu:setTouchPriority(priority)
    end
end

function multiTabbed:setTabPosition(x, y)
    if self.tabMenu then
        self.tabMenu:setPosition(x, y)
    end
end

function multiTabbed:getTabPosition()
    if self.tabMenu then
        return ccp(self.tabMenu:getPosition())
    end
    return ccp(0, 0)
end

function multiTabbed:setParent(parent, zorder)
    if parent and self.tabMenu then
        parent:addChild(self.tabMenu, zorder or 0)
    end
end

function multiTabbed:setClickCallBack(callback)
    self.callback = callback
end

--按下页签后更换页签状态
function multiTabbed:tabClick(idx)
    for k, v in pairs(self.allTabs) do
        local lb = v:getChildByTag(31)
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectIdex = idx
            if lb and tolua.cast(lb, "CCLabelTTF") then
                lb:setColor(G_ColorWhite)
            end
        else
            v:setEnabled(true)
            if lb and tolua.cast(lb, "CCLabelTTF") then
                lb:setColor(G_ColorWhite)
            end
        end
    end
    if self.callback then
        self.callback(idx)
    end
end

function multiTabbed:getOldSelectIdex()
    return self.oldSelectIdex
end

--回收
function multiTabbed:dispose()
    if self.tabMenu and tolua.cast(self.tabMenu, "CCMenu") then
        self.tabMenu:removeFromParentAndCleanup(true)
    end
    self.tabMenu = nil
    self.allTabs = nil
    self.selectIdex, self.oldSelectIdex = nil, nil
    self = nil
end

