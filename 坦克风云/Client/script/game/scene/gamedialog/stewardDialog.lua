stewardDialog = smallDialog:new()

function stewardDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.allTabData = {
        -- title, object, tabBtn, layer
        {title = getlocal("steward_title_tabOne"), object = require("luascript/script/game/scene/gamedialog/stewardTabOne")}, 
        {title = getlocal("steward_title_tabTwo"), object = require("luascript/script/game/scene/gamedialog/stewardTabTwo")}, 
        {title = getlocal("steward_title_tabThree"), object = require("luascript/script/game/scene/gamedialog/stewardTabThree")}, 
    }
    
    self.selectedTabIndex = 1
    
    return nc
end

function stewardDialog:showStewardDialog(layerNum, titleStr)
    local sd = stewardDialog:new()
    sd:initStewardDialog(layerNum, titleStr)
    return sd
end

function stewardDialog:closeDialog()
    base:removeFromNeedRefresh(self)
    self:close()
end

function stewardDialog:initStewardDialog(layerNum, titleStr)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(560, 680)
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png", CCRect(30, 30, 1, 1), function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority( - (layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 - 55))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("steward_titleBg.png", CCRect(215, 30, 1, 1), function()end)
    titleBg:setContentSize(CCSizeMake(self.bgSize.width + 40, titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0.5, 0))
    titleBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 20)
    self.bgLayer:addChild(titleBg)
    local function closeBtnHandler()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:closeDialog()
    end
    local closeBtn = GetButtonItem("steward_closeBtn.png", "steward_closeBtn_down.png", "steward_closeBtn.png", closeBtnHandler)
    closeBtn:setAnchorPoint(ccp(1, 0))
    local menu = CCMenu:createWithItem(closeBtn)
    menu:setTouchPriority( - (layerNum - 1) * 20 - 4)
    menu:setPosition(titleBg:getContentSize().width - 20, 66)
    titleBg:addChild(menu)
    local titleLb = GetTTFLabel(titleStr, 32, true)
    titleLb:setPosition((titleBg:getContentSize().width + 200) / 2, 34)
    titleBg:addChild(titleLb)

    local function tabClick(idx)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:tabClick(idx)
    end
    local tabBtn = CCMenu:create()
    for i, v in pairs(self.allTabData) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", "yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0, 1))
        tabBtnItem:setPosition(20 + (i - 1) * (tabBtnItem:getContentSize().width + 4), self.bgSize.height - 35)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)

        local strSize = 24
        if G_isAsia() == false then
            if G_isIOS() == true then
                strSize = 20
            else
                strSize = 17
            end 
        end
        local lb = GetTTFLabelWrap(v.title, strSize, CCSizeMake(tabBtnItem:getContentSize().width, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width / 2, tabBtnItem:getContentSize().height / 2))
        tabBtnItem:addChild(lb, 1)

        if i < 3 then --第三个页签暂不显示红点
            local tipIcon = CCSprite:createWithSpriteFrameName("IconTip.png")
            tipIcon:setPosition(tabBtnItem:getContentSize().width-10,tabBtnItem:getContentSize().height-5)
            tipIcon:setScale(0.8)
            tipIcon:setTag(10)
            tipIcon:setVisible(false)
            tabBtnItem:addChild(tipIcon)
        end
        
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabData[i].tabBtn = tabBtnItem
        if i == 1 then
            tabBtnItem:setEnabled(false)
        end
    end
    tabBtn:setPosition(0, 0)
    tabBtn:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(tabBtn, 1)

    self:tabClick(self.selectedTabIndex)
    self:checkRedPoint()

    base:addNeedRefresh(self)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function stewardDialog:tabClick(idx)
    for k, v in pairs(self.allTabData) do
        local _pos, _visible = ccp(99999, 0), false
        if v.tabBtn:getTag() == idx then
            v.tabBtn:setEnabled(false)
            self.selectedTabIndex = idx
            if v.layer == nil then
                v.layer = v.object:init(self.layerNum, self)
                self.bgLayer:addChild(v.layer)
            end
            _pos = ccp(0, 0)
            _visible = true
        else
            v.tabBtn:setEnabled(true)
        end
        if v.layer ~= nil then
            v.layer:setPosition(_pos)
            v.layer:setVisible(_visible)
        end
    end
end

function stewardDialog:checkRedPoint(tabIndex)
    for k, v in pairs(self.allTabData) do
        if tabIndex==nil or tabIndex==k then
            local tipIcon = v.tabBtn:getChildByTag(10)
            if tipIcon then
                tipIcon = tolua.cast(tipIcon, "CCSprite")
                if stewardVoApi:isShowRedPoint(k)==true then
                    tipIcon:setVisible(true)
                else
                    tipIcon:setVisible(false)
                end
            end
            if tabIndex==k then
                break
            end
        end
    end
end

function stewardDialog:tick()
    for k, v in pairs(self.allTabData) do
        if v.layer and v.object and v.object.tick then
            v.object:tick()
        end
    end
end

function stewardDialog:dispose()
    for k, v in pairs(self.allTabData) do
        if v.object and v.object.dispose then
            v.object:dispose()
            v.object = nil
        end
    end
    self.allTabData = nil
    self = nil
end