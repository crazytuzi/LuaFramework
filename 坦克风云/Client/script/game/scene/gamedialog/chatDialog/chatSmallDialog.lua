chatSmallDialog = smallDialog:new()

function chatSmallDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function chatSmallDialog:showEmojiDialog(layerNum, titleStr, sendEventCallback)
	local sd = chatSmallDialog:new()
	sd:initEmojiDialog(layerNum, titleStr, sendEventCallback)
end

function chatSmallDialog:initEmojiDialog(layerNum, titleStr, sendEventCallback)
	self.layerNum = layerNum
    self.isUseAmi = true

    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    self.bgSize = CCSizeMake(575, 850)
    local function closeDialog()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    -- self.bgLayer:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)

    local previewBg = LuaCCScale9Sprite:createWithSpriteFrameName("chatEmoji_previewBg.png", CCRect(4, 3, 2, 2), function()end)
    previewBg:setContentSize(CCSizeMake(542, 234))
    previewBg:setAnchorPoint(ccp(0.5, 0))
    previewBg:setPosition(self.bgSize.width / 2, 20)
    previewBg:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.bgLayer:addChild(previewBg, 1)
    local previewTitleBg = CCSprite:createWithSpriteFrameName("chatEmoji_stateTitleBg.png")
    previewTitleBg:setAnchorPoint(ccp(0, 1))
    previewTitleBg:setPosition(0, previewBg:getContentSize().height)
    previewBg:addChild(previewTitleBg)
    local previewTitleLb = GetTTFLabel(getlocal("chatEmoji_previewText"), 22)
    previewTitleLb:setPosition(previewTitleBg:getContentSize().width / 2, previewTitleBg:getContentSize().height / 2)
    previewTitleLb:setColor(G_ColorGreen)
    previewTitleBg:addChild(previewTitleLb)
    local emojiBg = CCSprite:createWithSpriteFrameName("chatEmoji_bg.png")
    emojiBg:setScale(1.2)
    emojiBg:setAnchorPoint(ccp(0.5, 0))
    emojiBg:setPosition(55 + emojiBg:getContentSize().width * emojiBg:getScale() / 2, 20)
    emojiBg:setOpacity(40)
    previewBg:addChild(emojiBg)

    local buttonClickLogic
    local function onClickButton(obj, tag)
    	if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if buttonClickLogic then
        	buttonClickLogic()
        end
    end
    local button = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onClickButton, nil, "", 24/0.8, 101)
    button:setScale(0.8)
    button:setAnchorPoint(ccp(1, 0))
    local menu = CCMenu:createWithItem(button)
    menu:setPosition(0, 0)
    menu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    previewBg:addChild(menu)
    button:setPosition(previewBg:getContentSize().width - 80, emojiBg:getPositionY())

    local lbWidth = previewBg:getContentSize().width - emojiBg:getPositionX() - emojiBg:getContentSize().width * emojiBg:getScale() / 2 - 10
    local conditionDescLb = GetTTFLabelWrap("", 22, CCSizeMake(lbWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
    conditionDescLb:setAnchorPoint(ccp(1, 0))
    conditionDescLb:setPosition(previewBg:getContentSize().width - 5, button:getPositionY() + button:getContentSize().height * button:getScale() + 10)
    conditionDescLb:setColor(ccc3(91, 125, 118))
    previewBg:addChild(conditionDescLb)

    local tv, unlockEmojiData, lockEmojiData, unlockEmojiSize, lockEmojiSize, focus, cellHeight, staticEmojiData, staticEmojiSize
    local tvSize = CCSizeMake(self.bgSize.width - 30, self.bgSize.height - previewBg:getPositionY() - previewBg:getContentSize().height - 80)
    local function initTvData(isRefresh)
    	unlockEmojiData, lockEmojiData, staticEmojiData = chatVoApi:getChatEmojiData()
    	unlockEmojiSize, lockEmojiSize, staticEmojiSize = SizeOfTable(unlockEmojiData), SizeOfTable(lockEmojiData), SizeOfTable(staticEmojiData)
    	focus = CCSprite:createWithSpriteFrameName("chatEmoji_focus.png")
    	-- cellHeight = (math.ceil(unlockEmojiSize / 4) + math.ceil(lockEmojiSize / 4)) * (focus:getContentSize().height + 10) + (previewTitleBg:getContentSize().height + 10) * (lockEmojiSize == 0 and 1 or 2)
        cellHeight = math.ceil((unlockEmojiSize + lockEmojiSize) / 4) * (focus:getContentSize().height + 10) + (previewTitleBg:getContentSize().height + 10) * 2
        local tempSp = CCSprite:createWithSpriteFrameName("chatEmojiStatic_bg.png")
        tempSp:setScale(0.55)
        local focusH = focus:getContentSize().height * (tempSp:getContentSize().width * tempSp:getScale() / focus:getContentSize().width)
        cellHeight = cellHeight + math.ceil(staticEmojiSize / 5) * (focusH + 10)
    	if isRefresh == true and tv then
    		tv:reloadData()
    	end
    end

    local function setPreviewEmoji(emojiData, isLock, isStaticEmoji)
    	local emojiId = emojiData.id
		emojiBg:removeAllChildrenWithCleanup(true)
        if isStaticEmoji then
            emojiBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("chatEmojiStatic_bg.png"))
            emojiBg:setOpacity(255)
            emojiBg:setScale(1)
            emojiBg:setPositionX(55 + emojiBg:getContentSize().width * emojiBg:getScale() / 2)
            local emojiIcon = chatVoApi:getChatEmojiIcon(emojiId, nil)
            if emojiIcon then
                emojiIcon:setAnchorPoint(ccp(0.5, 0))
                emojiIcon:setPosition(emojiBg:getContentSize().width / 2, 0)
                emojiBg:addChild(emojiIcon)
            end
        else
            emojiBg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("chatEmoji_bg.png"))
            emojiBg:setOpacity(40)
            emojiBg:setScale(1.2)
            emojiBg:setPositionX(55 + emojiBg:getContentSize().width * emojiBg:getScale() / 2)
            local emojiAnimation = chatVoApi:getChatEmojiAnimation(emojiId)
            if emojiAnimation then
                emojiAnimation:setAnchorPoint(ccp(0.5, 0))
                emojiAnimation:setPosition(emojiBg:getContentSize().width / 2, 0)
                emojiBg:addChild(emojiAnimation)
            end
        end
		buttonClickLogic = nil
		local buttonLb = tolua.cast(button:getChildByTag(101), "CCLabelTTF")
		if isLock then
			local typeValue = emojiData.typeValue
			if type(typeValue) == "string" then
				typeValue = getlocal(typeValue)
			end
			conditionDescLb:setString(getlocal("chatEmoji_unlockConditionType" .. emojiData.faceType, {typeValue}))
			if emojiData.faceType == 7 then --购买表情
				button:setEnabled(true)
				buttonLb:setString(getlocal("buy"))
				buttonClickLogic = function()
					local gems = playerVoApi:getGems()
					local gemsCost = emojiData.typeValue
			        if gems < gemsCost then
			            GemsNotEnoughDialog(nil, nil, gemsCost - gems, self.layerNum + 1, gemsCost)
			            do return end
			        end
			        local function onSureLogic()
			        	chatVoApi:requestBuyChatEmoji(function()
			        		playerVoApi:setGems(gems - gemsCost)
			        		initTvData(true)
			        	end, emojiId)
			        end
			        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), onSureLogic, getlocal("dialog_title_prompt"), getlocal("chatEmoji_buySureText", {gemsCost}), nil, self.layerNum + 1)
				end
			else
				button:setEnabled(false)
				buttonLb:setString(getlocal("write_email_send"))
			end
		else
			conditionDescLb:setString("")
			button:setEnabled(true)
			buttonLb:setString(getlocal("write_email_send"))
			buttonClickLogic = function()
	        	if type(sendEventCallback) == "function" then
	        		sendEventCallback(self, emojiId)
		    	end
			end
		end
    end

    initTvData()
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(tvSize.width, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()

            focus:setAnchorPoint(ccp(0.5, 0))
            cell:addChild(focus, 5)
            local posY = cellHeight
            local spaceW = 25
            local firstPosX = (tvSize.width - (focus:getContentSize().width * 4 + (4 - 1) * spaceW)) / 2 + focus:getContentSize().width / 2
            local function addEmojiIcon(emojiData, i, isLock, isStaticEmoji)
            	local emojiIconBg
            	local emojiId = emojiData.id
            	local function onClickEmojiIcon()
                    if isStaticEmoji then
                        focus:setScale(emojiIconBg:getContentSize().width * emojiIconBg:getScale() / focus:getContentSize().width)
                    else
                        focus:setScale(1)
                    end
            		focus:setPosition(emojiIconBg:getPosition())
            		setPreviewEmoji(emojiData, isLock, isStaticEmoji)
            	end
            	emojiIconBg = LuaCCSprite:createWithSpriteFrameName(isStaticEmoji and "chatEmojiStatic_bg.png" or "chatEmoji_bg.png", onClickEmojiIcon)
                if isStaticEmoji then
                    emojiIconBg:setScale(0.55)
                else
            	   emojiIconBg:setScale(focus:getContentSize().width / emojiIconBg:getContentSize().width)
                end
            	emojiIconBg:setAnchorPoint(ccp(0.5, 0))
            	emojiIconBg:setPosition(firstPosX + ((i - 1) % 4) * (focus:getContentSize().width + spaceW), posY - focus:getContentSize().height)
            	local emojiIcon = chatVoApi:getChatEmojiIcon(emojiId, isLock)
            	emojiIcon:setAnchorPoint(ccp(0.5, 0))
            	emojiIcon:setPosition(emojiIconBg:getContentSize().width / 2, 0)
            	emojiIconBg:addChild(emojiIcon)
            	emojiIconBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
            	cell:addChild(emojiIconBg)
                if isStaticEmoji then
                    local focusScale = emojiIconBg:getContentSize().width * emojiIconBg:getScale() / focus:getContentSize().width
                    local focusWidth = focus:getContentSize().width * focusScale
                    local focusHeight = focus:getContentSize().height * focusScale
                    firstPosX = (tvSize.width - (focusWidth * 5 + (5 - 1) * spaceW)) / 2 + focusWidth / 2
                    emojiIconBg:setPosition(firstPosX + ((i - 1) % 5) * (focusWidth + spaceW), posY - focusHeight)
                    if (i % 5 == 0) or (i == staticEmojiSize) then
                        posY = emojiIconBg:getPositionY() - 10
                    end
                else
                    emojiIconBg:setOpacity(40)
                    -- if i % 4 == 0 or (i == (isLock and lockEmojiSize or unlockEmojiSize)) then
                    if (i % 4 == 0) or (i == lockEmojiSize + unlockEmojiSize) then
                		posY = emojiIconBg:getPositionY() - 10
                	end
                end
            	if focus:getPositionX() == 0 and focus:getPositionY() == 0 then
            		onClickEmojiIcon()
            	end
            end

            local unlockTitleBg = CCSprite:createWithSpriteFrameName("chatEmoji_stateTitleBg.png")
            unlockTitleBg:setAnchorPoint(ccp(0, 1))
            unlockTitleBg:setPosition(0, posY)
            cell:addChild(unlockTitleBg)
            local unlockTitleLb = GetTTFLabel(getlocal("chatEmoji_dynamicText"), 22)
            unlockTitleLb:setPosition(unlockTitleBg:getContentSize().width / 2, unlockTitleBg:getContentSize().height / 2)
            unlockTitleLb:setColor(G_ColorGreen)
            unlockTitleBg:addChild(unlockTitleLb)
            posY = unlockTitleBg:getPositionY() - unlockTitleBg:getContentSize().height - 10

            for k, v in pairs(unlockEmojiData) do
            	addEmojiIcon(v, k)
            end
            for k, v in pairs(lockEmojiData) do
                addEmojiIcon(v, unlockEmojiSize + k, true)
            end

            if staticEmojiSize > 0 then
	            local lockTitleBg = CCSprite:createWithSpriteFrameName("chatEmoji_stateTitleBg.png")
	            lockTitleBg:setAnchorPoint(ccp(0, 1))
	            lockTitleBg:setPosition(0, posY)
	            cell:addChild(lockTitleBg)
	            local lockTitleLb = GetTTFLabel(getlocal("chatEmoji_staticText"), 22)
	            lockTitleLb:setPosition(lockTitleBg:getContentSize().width / 2, lockTitleBg:getContentSize().height / 2)
	            lockTitleLb:setColor(G_ColorGreen)
	            lockTitleBg:addChild(lockTitleLb)
	            posY = lockTitleBg:getPositionY() - lockTitleBg:getContentSize().height - 10

	            for k, v in pairs(staticEmojiData) do
                    addEmojiIcon(v, k, nil, true)
	            end
	        end

            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setPosition((self.bgSize.width - tvSize.width) / 2, previewBg:getPositionY() + previewBg:getContentSize().height + 5)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 2)
    tv:setMaxDisToBottomOrTop(100)
    self.bgLayer:addChild(tv)

    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function chatSmallDialog:dispose()
	self = nil
end