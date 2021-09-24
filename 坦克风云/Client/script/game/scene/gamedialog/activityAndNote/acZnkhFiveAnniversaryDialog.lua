acZnkhFiveAnniversaryDialog = commonDialog:new()

function acZnkhFiveAnniversaryDialog:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    
    G_addResource8888(function()
            spriteController:addPlist("public/acZnkh2018.plist")
            spriteController:addTexture("public/acZnkh2018.png")
            spriteController:addPlist("public/limitChallenge.plist")
            spriteController:addTexture("public/limitChallenge.png")
    end)
    spriteController:addPlist("public/newTopBgImage1.plist")
    spriteController:addTexture("public/newTopBgImage1.png")
    for i = 1, 3 do
        spriteController:addPlist("public/acZnkh2018Effect" .. i .. ".plist")
        spriteController:addTexture("public/acZnkh2018Effect" .. i .. ".png")
    end
    self.tabObj = { acZnkhFiveAnniversaryTabOne, acZnkhFiveAnniversaryTabTwo, acZnkhFiveAnniversaryTabThree }
    self.tabNum = SizeOfTable(self.tabObj)
    return nc
end

function acZnkhFiveAnniversaryDialog:resetTab()
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

function acZnkhFiveAnniversaryDialog:getBgOfTabPosY(tabIndex)
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

function acZnkhFiveAnniversaryDialog:initTableView()
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
            local fontSp = CCSprite:createWithSpriteFrameName("acZnkh2018_font.png")
            fontSp:setPosition(webImage:getContentSize().width / 2, webImage:getContentSize().height - 480)
            webImage:addChild(fontSp, 2)
            self.acBg = webImage
            self:runAction(fontSp)
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    LuaCCWebImage:createWithURL(G_downloadUrl("active/acZnkh2018_bg.jpg"), onLoadWebImage)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self:tabClick(0)
    acZnkhFiveAnniversaryVoApi:requestRankData()
end

function acZnkhFiveAnniversaryDialog:runAction(fontSp)
	local fontActionSp = CCSprite:createWithSpriteFrameName("acZnkh2018_effect2_font1.png")
	G_setBlendFunc(fontActionSp, GL_ONE, GL_ONE)
	local frameArray = CCArray:create()
    for i = 1, 11 do
        local frameName = "acZnkh2018_effect2_font" .. i .. ".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
        if frame then
        	frameArray:addObject(frame)
        end
    end
    local animation = CCAnimation:createWithSpriteFrames(frameArray, 0.07)
    local animate = CCAnimate:create(animation)
    fontActionSp:setPosition(fontSp:getContentSize().width / 2, fontSp:getContentSize().height / 2)
    fontSp:addChild(fontActionSp, 1)
    fontActionSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(animate, CCDelayTime:create(1.3))))

    local fontEffectSp = CCSprite:createWithSpriteFrameName("acZnkh2018_effect2_fe1.png")
    G_setBlendFunc(fontEffectSp, GL_ONE, GL_ONE)
	fontEffectSp:setPosition(fontSp:getContentSize().width / 2, fontSp:getContentSize().height / 2)
	fontEffectSp:setOpacity(0)
	fontSp:addChild(fontEffectSp)
	local fontArr = CCArray:create()
	fontArr:addObject(CCFadeTo:create(0.66, 255))
	fontArr:addObject(CCFadeTo:create(1.35, 0))
	fontArr:addObject(CCDelayTime:create(1.3))
	fontEffectSp:runAction(CCRepeatForever:create(CCSequence:create(fontArr)))

	local fontLineSp = CCSprite:createWithSpriteFrameName("acZnkh2018_effect2_fe2.png")
	G_setBlendFunc(fontLineSp, GL_ONE, GL_ONE)
	fontLineSp:setPosition(self.acBg:getContentSize().width / 2, self.acBg:getContentSize().height - 510)
	self.acBg:addChild(fontLineSp)
	local arr1 = CCArray:create()
	arr1:addObject(CCScaleTo:create(0.87, 0.15, 2))
	arr1:addObject(CCScaleTo:create(0.87, 1.80, 2))
	arr1:addObject(CCScaleTo:create(0.87, 0.15, 2))
	local arr2 = CCArray:create()
	arr2:addObject(CCSequence:create(arr1))
	arr2:addObject(CCSequence:createWithTwoActions(CCFadeTo:create(1.3, 255 * 0.5), CCFadeTo:create(1.3, 255)))
	fontLineSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCSpawn:create(arr2), CCDelayTime:create(1.3))))

	--从内到外的三个三角形
	local triangleData = {
		{
			scale = 1.0, pos = ccp(self.acBg:getContentSize().width / 2 - 5, self.acBg:getContentSize().height - 475),
		  	line = {
			  	{ rotate =   0, scale = 0.60, pos = ccp(self.acBg:getContentSize().width / 2,      self.acBg:getContentSize().height - 548) }, --底边
			  	{ rotate = -56, scale = 0.52, pos = ccp(self.acBg:getContentSize().width / 2 - 57, self.acBg:getContentSize().height - 472) }, --斜边(左)
			  	{ rotate =  56, scale = 0.52, pos = ccp(self.acBg:getContentSize().width / 2 + 46, self.acBg:getContentSize().height - 472) }, --斜边(右)
			}
		},
		{
			scale = 1.5, pos = ccp(self.acBg:getContentSize().width / 2 - 7, self.acBg:getContentSize().height - 465),
		  	line = {
			  	{ rotate =   0, scale = 0.90, pos = ccp(self.acBg:getContentSize().width / 2,      self.acBg:getContentSize().height - 575) }, --底边
			  	{ rotate = -56, scale = 0.75, pos = ccp(self.acBg:getContentSize().width / 2 - 84, self.acBg:getContentSize().height - 460) }, --斜边(左)
			  	{ rotate =  56, scale = 0.75, pos = ccp(self.acBg:getContentSize().width / 2 + 73, self.acBg:getContentSize().height - 460) }, --斜边(右)
			}
		},
		{
			scale = 2.0, pos = ccp(self.acBg:getContentSize().width / 2 - 7, self.acBg:getContentSize().height - 455),
		  	line = {
			  	{ rotate =   0, scale = 1.11, pos = ccp(self.acBg:getContentSize().width / 2,       self.acBg:getContentSize().height - 603) }, --底边
			  	{ rotate = -56, scale = 1.00, pos = ccp(self.acBg:getContentSize().width / 2 - 112, self.acBg:getContentSize().height - 455) }, --斜边(左)
			  	{ rotate =  56, scale = 1.00, pos = ccp(self.acBg:getContentSize().width / 2 + 102, self.acBg:getContentSize().height - 455) }, --斜边(右)
			}
		}
	}

	local function createLineAction()
		local lineEffectSp = CCSprite:createWithSpriteFrameName("acZnkh2018_effect3_line1.png")
		G_setBlendFunc(lineEffectSp, GL_ONE, GL_ONE)
		local lineFrameArr = CCArray:create()
		for i = 1, 21 do
			local frameName = "acZnkh2018_effect3_line" .. i .. ".png"
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(frameName)
			if frame then
				lineFrameArr:addObject(frame)
			end
		end
		local lineAnimation = CCAnimation:createWithSpriteFrames(lineFrameArr, 0.07)
		local lineAnimate = CCAnimate:create(lineAnimation)
		return lineEffectSp, lineAnimate
	end

	local function runTriangleEffect(index)
		local v = triangleData[index]
		if v then
			local triangleSp = CCSprite:createWithSpriteFrameName("acZnkh2018_effect3_triangle.png")
			G_setBlendFunc(triangleSp, GL_ONE, GL_ONE)
			triangleSp:setScale(v.scale)
			triangleSp:setPosition(v.pos)
			triangleSp:setOpacity(0)
			self.acBg:addChild(triangleSp)
			for m, n in pairs(v.line) do
				local lineSp, lineAnim = createLineAction()
				lineSp:setRotation(n.rotate)
				lineSp:setScale(n.scale)
				lineSp:setPosition(n.pos)
				self.acBg:addChild(lineSp)
				lineSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(lineAnim, CCDelayTime:create(1.3))))
			end
			local arr = CCArray:create()
			arr:addObject(CCDelayTime:create(5 * 0.07))
			arr:addObject(CCFadeTo:create(0.3, 255 * 0.6))
			arr:addObject(CCFadeTo:create(1, 0))
			arr:addObject(CCDelayTime:create(1.3))
			triangleSp:runAction(CCRepeatForever:create(CCSequence:create(arr)))
			self.acBg:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function() runTriangleEffect(index + 1) end)))
		end
	end
	runTriangleEffect(1)
end

function acZnkhFiveAnniversaryDialog:tabClick(idx)
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
        else
            v:setEnabled(true)
        end
    end
    self:switchTab(idx + 1)
end

function acZnkhFiveAnniversaryDialog:switchTab(tabIndex)
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

function acZnkhFiveAnniversaryDialog:tick()
    if self then
        local vo = acZnkhFiveAnniversaryVoApi:getAcVo()
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

function acZnkhFiveAnniversaryDialog:dispose()
    for i = 1, self.tabNum do
        if self["tab" .. i] and self["tab" .. i].dispose then
            self["tab" .. i]:dispose()
        end
        self["layerTab" .. i] = nil
    end
    self.acBg = nil
    self = nil
    spriteController:removePlist("public/acZnkh2018.plist")
    spriteController:removeTexture("public/acZnkh2018.png")
    spriteController:removePlist("public/limitChallenge.plist")
    spriteController:removeTexture("public/limitChallenge.png")
    spriteController:removePlist("public/newTopBgImage1.plist")
    spriteController:removeTexture("public/newTopBgImage1.png")
    for i = 1, 3 do
        spriteController:removePlist("public/acZnkh2018Effect" .. i .. ".plist")
        spriteController:removeTexture("public/acZnkh2018Effect" .. i .. ".png")
    end
end