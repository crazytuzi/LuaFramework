acKfczDialog = commonDialog:new()

function acKfczDialog:new(layerNum)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	G_addResource8888(function()
		spriteController:addPlist("public/acKfcz_Image.plist")
        spriteController:addTexture("public/acKfcz_Image.png")
		spriteController:addPlist("public/acZnkh2018.plist")
        spriteController:addTexture("public/acZnkh2018.png")
		spriteController:addPlist("public/acznjl_images.plist")
        spriteController:addTexture("public/acznjl_images.png")
        spriteController:addPlist("public/limitChallenge.plist")
        spriteController:addTexture("public/limitChallenge.png")
	end)
	spriteController:addPlist("public/newTopBgImage1.plist")
    spriteController:addTexture("public/newTopBgImage1.png")
	spriteController:addPlist("public/acZnkh2018Effect1.plist")
    spriteController:addTexture("public/acZnkh2018Effect1.png")
	self.tabObj = { acKfczTabOne, acKfczTabTwo, acKfczTabThree }
    self.tabNum = SizeOfTable(self.tabObj)
	return nc
end

function acKfczDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    
    local index = 0
    local tabBtnItemSpaceX = 3
    for k, tabBtnItem in pairs(self.allTabs) do
        local btnItemFirstPosX = (G_VisibleSizeWidth - (tabBtnItem:getContentSize().width * self.tabNum + tabBtnItemSpaceX * (self.tabNum - 1))) / 2 + (tabBtnItem:getContentSize().width / 2)
        local btnItemPosY = G_VisibleSizeHeight - tabBtnItem:getContentSize().height / 2 - 80
        tabBtnItem:setPosition(btnItemFirstPosX + index * (tabBtnItem:getContentSize().width + tabBtnItemSpaceX), btnItemPosY)
        if index == self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index = index + 1
    end
    self.selectedTabIndex = 0
end

function acKfczDialog:getBgOfTabPosY(tabIndex)
    local offset = 0
    if tabIndex == 0 then
    	if G_getIphoneType() == G_iphone5 then
    		offset = - 140
    	elseif G_getIphoneType() == G_iphoneX then
    		offset = - 200
    	else --默认是 G_iphone4
    		offset = - 40
    	end
    elseif tabIndex == 1 then
    	offset = 170
    elseif tabIndex == 2 then
    	offset = 230
    end
    return G_VisibleSizeHeight + offset
end

function acKfczDialog:getInfoMenuPos(tabIndex)
	if self.infoBtn == nil then
		return
	end
	local pos = ccp(0, 0)
	if tabIndex == 0 then
		pos = ccp(G_VisibleSizeWidth - 8 - self.infoBtn:getContentSize().width / 2, G_VisibleSizeHeight - 200)
	elseif tabIndex == 1 then
		pos = ccp(G_VisibleSizeWidth - 10 - self.infoBtn:getContentSize().width / 2, G_VisibleSizeHeight - 300)
	elseif tabIndex == 2 then
		pos = ccp(G_VisibleSizeWidth - 10 - self.infoBtn:getContentSize().width / 2, G_VisibleSizeHeight - 250)
	end
	return pos
end

function acKfczDialog:initTableView()
	local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 160))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 160)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)

    local function onLoadWebImage(fn, webImage)
        if self and clipper and tolua.cast(clipper, "CCNode") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(G_VisibleSizeWidth / 2, self:getBgOfTabPosY(self.selectedTabIndex))
            clipper:addChild(webImage)
            self.acBg = webImage
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    LuaCCWebImage:createWithURL(G_downloadUrl("active/acKfcz_bg.jpg"), onLoadWebImage)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self:tabClick(0)

	local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {
            getlocal("activity_kfcz_tipsDesc1", {acKfczVoApi:getRankNum()}), 
            getlocal("activity_kfcz_tipsDesc2", {acKfczVoApi:getRankRecharge()}), 
            getlocal("activity_kfcz_tipsDesc3", nil, {acKfczVoApi:getLuckyNum()}), 
            getlocal("activity_kfcz_tipsDesc4"), 
            getlocal("activity_kfcz_tipsDesc5"), 
            getlocal("activity_kfcz_tipsDesc6"), 
            getlocal("activity_kfcz_tipsDesc7"), 
        }
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    self.infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    local infoMenu = CCMenu:createWithItem(self.infoBtn)
    infoMenu:setPosition(self:getInfoMenuPos(self.selectedTabIndex))
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:addChild(infoMenu, 2)
    self.infoMenu = infoMenu

    acKfczVoApi:requestRankData()
end

function acKfczDialog:tabClick(idx)
    for k, v in pairs(self.allTabs) do
        if v:getTag() == idx then
            v:setEnabled(false)
            self.selectedTabIndex = idx
            if self.acBg then
                self.acBg:setPositionY(self:getBgOfTabPosY(self.selectedTabIndex))
                local blackBg = self.acBg:getChildByTag(999)
                if blackBg == nil then
                	blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                	blackBg:setContentSize(CCSizeMake(self.acBg:getContentSize().width, 500))
                	blackBg:setPosition(self.acBg:getContentSize().width / 2, self.acBg:getContentSize().height - 480)
                	blackBg:setOpacity(100)
                	blackBg:setTag(999)
                	self.acBg:addChild(blackBg, 3)
                else
                	blackBg = tolua.cast(blackBg, "CCSprite")
                end
                if self.selectedTabIndex == 0 then
                	blackBg:setVisible(false)
                else
                	blackBg:setVisible(true)
                end
            end
            if self.infoMenu then
            	self.infoMenu:setPosition(self:getInfoMenuPos(self.selectedTabIndex))
            end
        else
            v:setEnabled(true)
        end
    end
    self:switchTab(idx + 1)
end

function acKfczDialog:switchTab(tabIndex)
    if tabIndex == nil then
        tabIndex = 1
    end
    if self["tab" .. tabIndex] == nil then
        local tab = self.tabObj[tabIndex]:new(self.layerNum)
        self["tab" .. tabIndex] = tab
        self["layerTab" .. tabIndex] = tab:init()
        self.bgLayer:addChild(self["layerTab" .. tabIndex], 1)
    end
    for i = 1, self.tabNum do
        local _pos = ccp(999333, 0)
        local _visible = false
        if(i == tabIndex)then
            _pos = ccp(0, 0)
            _visible = true
        end
        if self["layerTab" .. i] ~= nil then
            self["layerTab" .. i]:setPosition(_pos)
            self["layerTab" .. i]:setVisible(_visible)
        end
    end
end

function acKfczDialog:tick()
    if self then
        local vo = acKfczVoApi:getAcVo()
        if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        else
            for i = 1, self.tabNum do
                if self["tab" .. i] and self["tab" .. i].tick then
                    self["tab" .. i]:tick()
                end
            end
        end
    end
end

function acKfczDialog:dispose()
	for i = 1, self.tabNum do
        if self["tab" .. i] and self["tab" .. i].dispose then
            self["tab" .. i]:dispose()
        end
        self["layerTab" .. i] = nil
    end
	self = nil
	spriteController:removePlist("public/acKfcz_Image.plist")
    spriteController:removeTexture("public/acKfcz_Image.png")
	spriteController:removePlist("public/acZnkh2018.plist")
    spriteController:removeTexture("public/acZnkh2018.png")
	spriteController:removePlist("public/acznjl_images.plist")
    spriteController:removeTexture("public/acznjl_images.png")
    spriteController:removePlist("public/limitChallenge.plist")
    spriteController:removeTexture("public/limitChallenge.png")
    spriteController:removePlist("public/newTopBgImage1.plist")
    spriteController:removeTexture("public/newTopBgImage1.png")
    spriteController:removePlist("public/acZnkh2018Effect1.plist")
    spriteController:removeTexture("public/acZnkh2018Effect1.png")
end