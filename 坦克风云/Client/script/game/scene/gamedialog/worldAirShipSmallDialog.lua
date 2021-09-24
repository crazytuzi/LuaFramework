worldAirShipSmallDialog = smallDialog:new()

function worldAirShipSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function worldAirShipSmallDialog:showAttackReward(layerNum, titleStr, rewardTb)
	local sd = worldAirShipSmallDialog:new()
    sd:initAttackReward(layerNum, titleStr, rewardTb)
end

function worldAirShipSmallDialog:initAttackReward(layerNum, titleStr, rewardTb)
	self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority( - (layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    local function closeDialog()
    	self:close()
    end
    self.bgSize = CCSizeMake(560, 300)
    local function onClickClose()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, G_isAsia() == false and 28 or 32, nil, self.layerNum, true, onClickClose, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)

    if rewardTb then
        local tipsLb = GetTTFLabelWrap(getlocal("airShip_worldBossAttackRewardTips"), 22, CCSizeMake(self.bgSize.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        tipsLb:setAnchorPoint(ccp(0.5, 1))
        tipsLb:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 86))
        tipsLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(tipsLb)
    	local iconSize = 100
    	local rowNum = 4
    	local iconSpaceX = 20
    	local iconSpaceY = 20
    	local firstPosX = (self.bgSize.width - (iconSize * rowNum + (rowNum - 1) * iconSpaceX)) / 2
    	local firstPosY = self.bgSize.height - 130
    	for k, v in pairs(rewardTb) do
    		local function showNewPropDialog()
		        if v.type == "at" and v.eType == "a" then --AI部队
		            local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(v.key, true)
		            AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
		        else
		            G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, nil, nil, nil, nil, true)
		        end
		    end
			local icon, scale = G_getItemIcon(v, 100, false, self.layerNum, showNewPropDialog)
			icon:setAnchorPoint(ccp(0, 1))
            icon:setScale(iconSize / icon:getContentSize().height)
            scale = icon:getScale()
            icon:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
            icon:setPosition(firstPosX + ((k - 1) % rowNum) * (iconSize + iconSpaceX), firstPosY - math.floor(((k - 1) / rowNum)) * (iconSize + iconSpaceY))
            self.bgLayer:addChild(icon)
        	local numLb = GetTTFLabel("x" .. FormatNumber(v.num), 20)
            local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
            numBg:setAnchorPoint(ccp(0, 1))
            numBg:setRotation(180)
            numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
            numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
            numBg:setPosition(icon:getPositionX() + iconSize - 5, icon:getPositionY() - iconSize + 5)
            self.bgLayer:addChild(numBg)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(numBg:getPosition())
            self.bgLayer:addChild(numLb)
    	end
    end
end

function worldAirShipSmallDialog:dispose()
    self = nil
end