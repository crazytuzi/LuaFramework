accessoryBatchSmallDialog = smallDialog:new()

function accessoryBatchSmallDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function accessoryBatchSmallDialog:init(layerNum, titleStr, batchData)
	self.layerNum = layerNum
	self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    local function closeDialog()
        -- base:removeFromNeedRefresh(self)
        self:close()
    end
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), closeDialog)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)

    local height = 150
    local btnCount = SizeOfTable(batchData)
    local btnSpaceH, btnHeight = 35, 0
    local btnArry = CCArray:create()
    for k, v in pairs(batchData) do
    	local btnScale = 1
	    local button = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", function() closeDialog() if type(v[2]) == "function" then v[2]() end end, nil, v[1], 24 / btnScale)
	    button:setScale(btnScale)
	    btnArry:addObject(button)
	    btnHeight = button:getContentSize().height * btnScale
	    height = height + btnHeight
	    if k < btnCount then
	    	height = height + btnSpaceH
	    end
    end
    self.bgSize = CCSizeMake(500, height)
    self.bgLayer = G_getNewDialogBg2(self.bgSize, self.layerNum, function()end)
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    -- self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    -- 标题
    local titleTb = {titleStr, 26, G_ColorYellowPro}
    local titleLbSize = CCSizeMake(300,0)
    local titleBg, titleL, subHeight = G_createNewTitle(titleTb, titleLbSize, nil, true)
    titleBg:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 50))
    self.bgLayer:addChild(titleBg)
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function()end)
    contentBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 70))
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 50)
    self.bgLayer:addChild(contentBg)

    local btnPosY = contentBg:getContentSize().height - (contentBg:getContentSize().height - btnHeight * btnCount - btnSpaceH * (btnCount - 1)) / 2
    local btnAryCount = btnArry:count()
    for i = 0, btnAryCount - 1 do
        local button = tolua.cast(btnArry:objectAtIndex(i), "CCMenuItem")
        if button then
            button:setAnchorPoint(ccp(0.5, 1))
	    	button:setPosition(ccp(contentBg:getContentSize().width / 2, btnPosY - i * (btnHeight + btnSpaceH)))
        end
    end

    local btnMenu = CCMenu:createWithArray(btnArry)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    contentBg:addChild(btnMenu)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function accessoryBatchSmallDialog:dispose()
	self = nil
end