virtualKeyboard_key_mapping_DELETE = 11
virtualKeyboard_key_mapping_ENTER  = 12
virtualKeyboard_eventType_CLOSED   = -1

virtualKeyboard = {}
virtualKeyboard.UPSPRING_SPEED = 0.3 --键盘的弹起速度(单位：秒)
virtualKeyboard.TOUCH_PRIORITY = -99999 --键盘的触摸优先级(确保在游戏内拥有最高优先级权限)
virtualKeyboard.ZORDER		   = 99999 --键盘的渲染层级(确保在游戏内拥有最高渲染层级权限)

--[[@public
为保证虚拟键盘的全局唯一性(只能同时存在一个虚拟键盘)
所以将此类做成单例模式，请勿再使用new方法来创建
--]]
function virtualKeyboard:getInstance()
	if self.instance == nil then
		self.instance = self:new()
	end
	return self.instance
end

--[[@public
params[1] : 输入框的显示文本CCLabelTTF对象
params[2] : 可输入的最大长度
params[3] : 键盘事件的回调方法
--]]
function virtualKeyboard:show(...)
	if self.openFlag then
		return
	end
	self.openFlag = true
	self.params = {...}
	self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() self:close() end)
	self.bgLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
	self.bgLayer:setTouchPriority(self.TOUCH_PRIORITY)
	self.bgLayer:setOpacity(0)
	CCDirector:sharedDirector():getRunningScene():addChild(self.bgLayer, self.ZORDER)
	self:initKeyboardUI()
end

function virtualKeyboard:release()
	self.instance = nil
	self = nil
	spriteController:removePlist("public/virtualKeyboardImages.plist")
    spriteController:removeTexture("public/virtualKeyboardImages.png")
end


--========================================【以下为protected方法，请勿直接调用】========================================


function virtualKeyboard:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	G_addResource8888(function()
		spriteController:addPlist("public/virtualKeyboardImages.plist")
        spriteController:addTexture("public/virtualKeyboardImages.png")
	end)
	return nc
end

function virtualKeyboard:close(isEnter)
	if self then
		if self.originalScenePosY then
			CCDirector:sharedDirector():getRunningScene():setPositionY(self.originalScenePosY)
		end
		self.originalScenePosY = nil
		if self.schedulerID then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerID)
		end
		self.schedulerID = nil
		if tolua.cast(self.cursor, "CCLabelTTF") then
			self.cursor:removeFromParentAndCleanup(true)
		end
		self.cursor = nil
		if tolua.cast(self.bgLayer, "CCNode") then
			self.bgLayer:removeFromParentAndCleanup(true)
		end
		self.bgLayer = nil
		if (not isEnter) and self.params and type(self.params[3]) == "function" then
			self.params[3](virtualKeyboard_eventType_CLOSED)
		end
		self.params = nil
		self.openFlag = nil
	end
end

function virtualKeyboard:initKeyboardUI()
	-- self.keyboardNode = CCNode:create()
	self.keyboardNode = LuaCCScale9Sprite:createWithSpriteFrameName("vki_bg.png", CCRect(2, 2, 6, 4), function()end)
	self.bgLayer:addChild(self.keyboardNode)
	local keyboardWidth = G_VisibleSizeWidth
	local keyboardHeight = 0

	local tempNumTb = {}
	local function isEqual(value)
		for k, v in pairs(tempNumTb) do
			if v == value then
				return true
			end
		end
		return false
	end
	local rowCount = math.random(3, 4)
	local colCount = (rowCount == 3) and 4 or 3
	local menuArr = CCArray:create()
	for row = 1, rowCount do
		for col = 1, colCount do
			local numberPic, btnTag
			if row == 1 and col == 1 then
				btnTag = virtualKeyboard_key_mapping_DELETE
				numberPic = "vki_del.png"
			elseif row == 1 and col == colCount then
				btnTag = virtualKeyboard_key_mapping_ENTER
				numberPic = "vki_enter.png"
			else
				btnTag = math.random(0, 9)
				while isEqual(btnTag) do
					btnTag = math.random(0, 9)
				end
				numberPic = "vki_num" .. btnTag .. ".png"
				table.insert(tempNumTb, btnTag)
			end
			local numberBtn = GetButtonItem("vki_btn.png", "vki_btnDown.png", "vki_btn.png", function(...) self:onClickNumber(...) end, btnTag)
			menuArr:addObject(numberBtn)
			numberBtn:setAnchorPoint(ccp(0, 0))
			local numberBtnSize
			if colCount == 4 then
				numberBtn:setScaleX((keyboardWidth / colCount) / numberBtn:getContentSize().width)
				numberBtn:setScaleY(1)
				numberBtnSize = CCSizeMake(numberBtn:getContentSize().width * numberBtn:getScaleX(), numberBtn:getContentSize().height * numberBtn:getScaleY())
			else
				numberBtn:setScale((keyboardWidth / colCount) / numberBtn:getContentSize().width)
				numberBtnSize = CCSizeMake(numberBtn:getContentSize().width * numberBtn:getScale(), numberBtn:getContentSize().height * numberBtn:getScale())
			end
			numberBtn:setPosition(ccp((col - 1) * numberBtnSize.width, (row - 1) * numberBtnSize.height + 30))
			if keyboardHeight == 0 then
				keyboardHeight = numberBtnSize.height * rowCount + 30
			end

			local numberSp = CCSprite:createWithSpriteFrameName(numberPic)
			numberSp:setPosition(ccp(numberBtn:getPositionX() + numberBtnSize.width / 2, numberBtn:getPositionY() + numberBtnSize.height / 2))
			self.keyboardNode:addChild(numberSp, 1)
			if btnTag >= 0 and btnTag <= 9 then
				local lineSp = CCSprite:createWithSpriteFrameName("vki_line.png")
				lineSp:setAnchorPoint(ccp(0.5, 0.5))
				lineSp:setPositionX(numberSp:getPositionX())
				lineSp:setPositionY(numberSp:getPositionY() + math.random(-1 , 1) * (numberSp:getContentSize().height - 10) / 2)
				lineSp:setRotation(math.random(-40, 40))
				self.keyboardNode:addChild(lineSp, 1)
			end
		end
	end
	local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority(self.TOUCH_PRIORITY)
    btnMenu:setPosition(ccp(0, 0))
    self.keyboardNode:addChild(btnMenu)

    self.keyboardNode:setContentSize(CCSizeMake(keyboardWidth, keyboardHeight))
    self.keyboardNode:setAnchorPoint(ccp(0, 0))
    self.keyboardNode:setPosition(ccp(0, -keyboardHeight))

    if type(self.params[1]) == "userdata" then
	    local label = tolua.cast(self.params[1], "CCLabelTTF")
	    if label then
		    local anchorPoint = label:getAnchorPoint()
		    local position = ccp(label:getPosition())
		    self.cursor = GetTTFLabel("|", label:getFontSize() + 3, true)
		    self.cursor:setColor(ccc3(0, 0, 255))
		    self.cursor:setAnchorPoint(ccp(0, anchorPoint.y))
		    self.cursor:setPosition(ccp(position.x + (1 - anchorPoint.x) * label:getContentSize().width, position.y))
		    label:getParent():addChild(self.cursor)
		    self.cursor:runAction(CCRepeatForever:create(CCBlink:create(1, 1)))
		    local worldPosY = label:getParent():convertToWorldSpace(position).y
		    if worldPosY - anchorPoint.y * label:getContentSize().height < keyboardHeight then
		    	local scene = CCDirector:sharedDirector():getRunningScene()
		    	self.originalScenePosY = scene:getPositionY()
		    	scene:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(self.UPSPRING_SPEED, ccp(0, keyboardHeight)), CCCallFunc:create(function()end)))
		    end
		end
	end
	if self.originalScenePosY == nil then
		local seq = CCSequence:createWithTwoActions(CCMoveBy:create(self.UPSPRING_SPEED, ccp(0, keyboardHeight)), CCCallFunc:create(function()end))
	    self.keyboardNode:runAction(seq)
	end

	self.schedulerID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(...) self:update(...) end, 0, false)
end

function virtualKeyboard:onClickNumber(tag, obj)
	PlayEffect(audioCfg.mouseClick)
	if self.params == nil then
		return
	end
	if tag == virtualKeyboard_key_mapping_DELETE then
		if type(self.params[1]) == "userdata" then
			local label = tolua.cast(self.params[1], "CCLabelTTF")
			if label then
				local labelStr = label:getString()
				label:setString(string.sub(labelStr, 0, string.len(labelStr) - 1))
			end
		end
	elseif tag == virtualKeyboard_key_mapping_ENTER then
		if type(self.params[3]) == "function" then
			self.params[3](tag)
		end
		self:close(true)
	else
		if type(self.params[1]) == "userdata" then
			local label = tolua.cast(self.params[1], "CCLabelTTF")
			if label then
				if type(self.params[2]) == "number" and string.len(label:getString()) >= self.params[2] then
					return
				end
				label:setString(label:getString() .. tag)
			end
		end
	end
	if self.params and type(self.params[3]) == "function" then
		self.params[3](tag)
	end
end

function virtualKeyboard:update(dt)
	if self then
		if self.cursor and self.params and type(self.params[1]) == "userdata" then
		    local label = tolua.cast(self.params[1], "CCLabelTTF")
		    if label then
			    local anchorPoint = label:getAnchorPoint()
			    local position = ccp(label:getPosition())
			    self.cursor:setPositionX(position.x + (1 - anchorPoint.x) * label:getContentSize().width)
			end
		end
	end
end