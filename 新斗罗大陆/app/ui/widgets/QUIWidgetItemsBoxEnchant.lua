--
-- Author: Your Name
-- Date: 2014-07-10 18:54:20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetItemsBoxEnchant = class("QUIWidgetItemsBoxEnchant", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItmePrompt = import(".QUIWidgetItmePrompt") 
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetItemsBoxEnchant.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetItemsBoxEnchant.EVENT_CLICK_END = "EVENT_CLICK_END"
QUIWidgetItemsBoxEnchant.EVENT_BEGAIN = "ITEM_EVENT_BEGAIN"
QUIWidgetItemsBoxEnchant.EVENT_END = "ITEM_EVENT_END"
QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK = "EVENT_MINUS_CLICK"
QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK_END = "EVENT_MINUS_CLICK_END"

function QUIWidgetItemsBoxEnchant:ctor(touchCallbackDisabled)
	local ccbFile = "ccb/Widget_ItemBox_Enchant.ccbi"
	local callBacks = {
    }
	QUIWidgetItemsBoxEnchant.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeVisible(self._ccbOwner.node_goods,true)
    self:setTFText(self._ccbOwner.tf_goods_num,"")
    self:setNodeVisible(self._ccbOwner.node_mask,false)
	self.icon = CCSprite:create()
	self._ccbOwner.node_icon:addChild(self.icon)
    self:resetAll()

    self.promptTipIsOpen = false
    self.touchCallbackDisabled = touchCallbackDisabled
    self.interval = 0.2
    self._isNeedshadow = true
	self._startPosX = 0
	self._startPosY = 0

    self._minusPosX, self._minusPosY = self._ccbOwner.minus:getPosition()
end

function QUIWidgetItemsBoxEnchant:setPromptIsOpen(value)
  self.promptTipIsOpen = value
end

function QUIWidgetItemsBoxEnchant:setNeedshadow( boo )
	self._isNeedshadow = boo
	TFSetDisableOutline(self._ccbOwner.item_name, not boo)
end

function QUIWidgetItemsBoxEnchant:getName()
	return "QUIWidgetItemsBoxEnchant"
end

function QUIWidgetItemsBoxEnchant:hideAllColor()
	self:setNodeVisible(self._ccbOwner.node_bar,false)
	self:setNodeVisible(self._ccbOwner.node_normal,false)
	for _, color in pairs(EQUIPMENT_QUALITY) do
		if self._ccbOwner["node_"..color] then
			self._ccbOwner["node_"..color]:setVisible(false)
		end
	end
    for _, color in pairs(EQUIPMENT_QUALITY) do
		if self._ccbOwner["node_scrap_"..color] then
			self._ccbOwner["node_scrap_"..color]:setVisible(false)
		end
	end
	self._ccbOwner.sp_break:setVisible(false)

    q.setAptitudeShow(self._ccbOwner)

    self:setNodeVisible(self._ccbOwner.node_mask,false)
end

function QUIWidgetItemsBoxEnchant:resetAll()
	self:hideAllColor()
    self:setNodeVisible(self._ccbOwner.icon,false)
    self:setTFText(self._ccbOwner.tf_goods_num,"")
    self._ccbOwner.node_scrap:setVisible(false)
    self._ccbOwner.node_soul:setVisible(false)
end

function QUIWidgetItemsBoxEnchant:getContentSize()
	return self._ccbOwner.sprite_back:getContentSize()
end

function QUIWidgetItemsBoxEnchant:onEnter()
	if not self.touchCallbackDisabled then
		self._ccbOwner.sprite_back:setTouchEnabled(true)
		self._ccbOwner.sprite_back:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._ccbOwner.sprite_back:setTouchSwallowEnabled(false)
		self._ccbOwner.sprite_back:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetItemsBoxEnchant._onTouch))

		self._ccbOwner.minus:setTouchEnabled(true)
		self._ccbOwner.minus:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._ccbOwner.minus:setTouchSwallowEnabled(true)
		self._ccbOwner.minus:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetItemsBoxEnchant._onTriggerMinus))
	end
end

function QUIWidgetItemsBoxEnchant:onExit()
    self._ccbOwner.sprite_back:setTouchEnabled(false)
  	self._ccbOwner.sprite_back:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
  	if self._light ~= nil then
  		self._light:removeFromParentAndCleanup(true)
  		self._light = nil
  	end
    if self._signInLight ~= nil then
      self._signInLight:removeFromParentAndCleanup(true)
      self._signInLight = nil
    end
    
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
end

function QUIWidgetItemsBoxEnchant:setBoxScale(scale)
  if scale == nil then return end
  self._ccbOwner.node_box:setScale(scale)
end

function QUIWidgetItemsBoxEnchant:setColor(breakLevel)
	self:hideAllColor()
	local iconPath
	if breakLevel then
		iconPath = QResPath("rect_frame")[breakLevel+1]
	end
	if not iconPath then
		iconPath = QResPath("rect_frame")[1]
	end
	local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
	if texture then
		self._ccbOwner.sp_break:setVisible(true)
		self._ccbOwner.sp_break:setTexture(texture)
	else
		self._ccbOwner.sp_break:setVisible(false)
	end
end

function QUIWidgetItemsBoxEnchant:setGoodsInfo(itemID, itemType, goodsNum, froceShow)
	self:resetAll()
	self._itemID = itemID
	self._itemType = remote.items:getItemType(itemType)
	if self._itemType == ITEM_TYPE.ITEM then --物品
  		self:_showIsItem(itemID, goodsNum, froceShow)
	elseif self._itemType == ITEM_TYPE.HERO then --魂师
	    local heroDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(itemID)
	    if nil ~= heroDisplay then 
			self:_setItemInfo(heroDisplay.icon, goodsNum, froceShow)
			self:setQualityIcon()
	    end
	else
		local icon = remote.items:getURLForItem(self._itemType)
		if icon ~= nil then
  			self:_setItemInfo(icon, goodsNum, froceShow)
  		end
	end
end

function QUIWidgetItemsBoxEnchant:_showIsItem(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	if itemInfo == nil then return end
	self:hideAllColor()
	if itemInfo.type == ITEM_CONFIG_TYPE.SOUL then
		self:showColorWithScrap(itemInfo.colour)
		self:setQualityIcon()
	elseif itemInfo.type == ITEM_CONFIG_TYPE.ARTIFACT_PIECE then
		self:showColorWithScrap(itemInfo.colour)
		local targetItems = remote.items:getItemsByMaterialId(itemID)
		if targetItems ~= nil and #targetItems == 1 then
			local itemId = targetItems[1].item_id
			local actorId = remote.artifact:getActorIdByArtifactId(itemId)
			if actorId ~= nil then
				local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
				self:showSabc(aptitudeInfo.lower)
			end
		end
	else
		if itemInfo.type == ITEM_CONFIG_TYPE.ARTIFACT then
			local actorId = remote.artifact:getActorIdByArtifactId(itemID)
			if actorId ~= nil then
				local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
				self:showSabc(aptitudeInfo.lower)
			end
		end
		if itemInfo.break_through then
			self:setColor(itemInfo.break_through)
		elseif itemInfo.colour then
			self:setColourColor(EQUIPMENT_QUALITY[itemInfo.colour])
		end
	end
	self:_setItemInfo(itemInfo.icon, goodsNum, froceShow)

	local itemName = itemInfo.name or ""
	self._ccbOwner.item_name:setString(itemName)

	local fontColor = EQUIPMENT_COLOR[itemInfo.colour]
	self._ccbOwner.item_name:setColor(fontColor)
	if self._isNeedshadow then
		self._ccbOwner.item_name = setShadowByFontColor(self._ccbOwner.item_name, fontColor)
	else
		TFSetDisableOutline(self._ccbOwner.item_name, true)
	end
end

function QUIWidgetItemsBoxEnchant:setNameVisibility(visibility)
	self._ccbOwner.item_name:setVisible(visibility)
end

function QUIWidgetItemsBoxEnchant:setNumVisibility(visibility)
	self._ccbOwner.tf_goods_num:setVisible(visibility)
end

function QUIWidgetItemsBoxEnchant:setName(itemName)
	if itemName then
		self._ccbOwner.item_name:setString(itemName)
	end
end

function QUIWidgetItemsBoxEnchant:setColourColor( name )
	-- body
	self:hideAllColor()
	self:setNodeVisible(self._ccbOwner.node_bar,true)
	if name ~= nil then
    	self:setNodeVisible(self._ccbOwner["node_"..name],true)
    else
    	self:setNodeVisible(self._ccbOwner["node_normal"],true)
    end
end

function QUIWidgetItemsBoxEnchant:setQualityIcon()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

	if characher == nil or characher.func == nil then return end

	local aptitudeInfo = db:getActorSABC(actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetItemsBoxEnchant:showColorWithScrap(colour)
	self._ccbOwner.node_scrap:setVisible(true)
	self._ccbOwner.node_scrap_normal:setVisible(false)
	for _, color in pairs(EQUIPMENT_QUALITY) do
		if self._ccbOwner["node_scrap_"..color] then
			self._ccbOwner["node_scrap_"..color]:setVisible(false)
		end
	end
	if self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[colour]] then
		self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[colour]]:setVisible(true)
	end
end

function QUIWidgetItemsBoxEnchant:showSabc( quality )
	if quality == nil then return end
	self._ccbOwner["pingzhi_"..quality]:setVisible(true)	
end

function QUIWidgetItemsBoxEnchant:_setItemInfo(respath, goodsNum, froceShow)
  	if respath ~= nil then
  		self:setItemIcon(respath)
  	end
  	if froceShow == nil then froceShow = false end
  	if froceShow == true or goodsNum > 0 then
    	self:setTFText(self._ccbOwner.tf_goods_num,goodsNum)
    	-- Scale the number if its size exceeds the box size @qinyuanji
    	local numSize = self._ccbOwner.tf_goods_num:getContentSize()
    	local boxSize = self._ccbOwner.node_scrap_normal:getContentSize()
    	local scale = (boxSize.width - 20)/numSize.width
    	if scale > 1 then
    		scale = 1
    	end
    	self._ccbOwner.tf_goods_num:setScale(scale)
    else
    	self:setTFText(self._ccbOwner.tf_goods_num,"")
  	end
end

function QUIWidgetItemsBoxEnchant:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end

		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		if self._ccbOwner.node_scrap:isVisible() then
			self.icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorHead)
			self.icon:setOpacity(0.8 * 255)
			self._ccbOwner.node_bj:setVisible(false)
			self._ccbOwner.node_scrap_bj:setVisible(true)
		else
			self.icon:setShaderProgram(qShader.CC_ProgramPositionTextureColor)
			self.icon:setOpacity(1 * 255)
			self._ccbOwner.node_bj:setVisible(true)
			self._ccbOwner.node_scrap_bj:setVisible(false)
		end

		self.icon:setVisible(true)
		self.icon:setScale(1)

		local size = self.icon:getContentSize()
		local size2 = self._ccbOwner.node_mask:getContentSize()
		local scaleX = self._ccbOwner.node_mask:getScaleX()
		local scaleY = self._ccbOwner.node_mask:getScaleY()

		if size.width ~= size2.width then
			self.icon:setScaleX(size2.width * scaleX/size.width)
		end
		if size.height ~= size2.height then
			self.icon:setScaleY(size2.height * scaleY/size.height)
		end
	end
end

function QUIWidgetItemsBoxEnchant:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetItemsBoxEnchant:setTFText(node,str)
	if node ~= nil then
		node:setString(str)
	end
end

function QUIWidgetItemsBoxEnchant:checkNeedItem()
	local isNeed = remote.stores:checkItemIsNeed(self._itemID, 1)
	self:showGreenTips(isNeed)
end

function QUIWidgetItemsBoxEnchant:showGreenTips(b)
	if self._animationGreenTips == nil then
		self._animationGreenTips = QUIWidget.new("ccb/effects/shoujizhong.ccbi")
		self._ccbOwner.node_sign_light:addChild(self._animationGreenTips)
	end
	self._animationGreenTips:setVisible(b)
end

function QUIWidgetItemsBoxEnchant:showMinusButton(visible)
	self._ccbOwner.minus:setVisible(visible)
end

function QUIWidgetItemsBoxEnchant:onTouchListView(event)
	if not event then
		return
	end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
	local pos = self._ccbOwner.minus:convertToWorldSpaceAR(ccp(0,0))
	local size = self._ccbOwner.minus:getContentSize()
	if self._ccbOwner.minus:isVisible() and event.x >= pos.x - size.width/2 and event.x <= pos.x + size.width/2 and
		event.y >= pos.y - size.height/2 and event.y <= pos.y + size.height/2  then
		self:_onTriggerMinus(event)
		return
	end

	local posBack = self._ccbOwner.sprite_back:convertToWorldSpaceAR(ccp(0,0))
	local sizeBack = self._ccbOwner.sprite_back:getContentSize()
	if event.x >= posBack.x - sizeBack.width/2 and event.x <= posBack.x + sizeBack.width/2 and
		event.y >= posBack.y - sizeBack.height/2 and event.y <= posBack.y + sizeBack.height/2  then
		self:_onTouch(event)
		return
	end
end

function QUIWidgetItemsBoxEnchant:_onTouch(event)
	if event.name == "began" then
		self._isClick = true
		self._startPosX = event.x
		self._startPosY = event.y
		self:onDownHandler()
	elseif event.name == "moved" then
		if math.abs(event.x - self._startPosX) > 10 or math.abs(event.y - self._startPosY) > 10 then
			self._isClick = false
		end
	elseif event.name == "ended" then
		if self._isClick then 
	    	self:_onTriggerClick()
	    end
		self._isClick = false
		self:onUpHandler()
		self:dispatchEvent({name = QUIWidgetItemsBoxEnchant.EVENT_CLICK_END , itemID = self._itemID, source = self})
  	end
end

function QUIWidgetItemsBoxEnchant:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetItemsBoxEnchant.EVENT_CLICK , itemID = self._itemID, source = self})
end

function QUIWidgetItemsBoxEnchant:onDownHandler()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), 1)
end

function QUIWidgetItemsBoxEnchant:onUpHandler( ... )
	self.interval = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetItemsBoxEnchant:consecutivePush( ... )
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

    self:_onTriggerClick()
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

function QUIWidgetItemsBoxEnchant:_onTriggerMinus(event)
	if event.name == "began" then 
		self._isTouchBeganMinus = true
		self:onMinusDownHandler()
	elseif event.name == "ended" and self._isTouchBeganMinus then 
		self._isTouchBeganMinus = false
		self:onMinusUpHandler()
    	self:_onTriggerMinusClick()
		self:onUpHandler()
		self:dispatchEvent({name = QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK_END , itemID = self._itemID, source = self})
  	end
end

function QUIWidgetItemsBoxEnchant:getResPath()
	return self._respath
end

function QUIWidgetItemsBoxEnchant:_onTriggerMinusClick()
	self:dispatchEvent({name = QUIWidgetItemsBoxEnchant.EVENT_MINUS_CLICK , itemID = self._itemID, source = self})
end

function QUIWidgetItemsBoxEnchant:onMinusDownHandler()
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), 1)
end

function QUIWidgetItemsBoxEnchant:onMinusUpHandler( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
	self.interval = 0.2
end

function QUIWidgetItemsBoxEnchant:setInfo(config)
	self._config = config
	self:setGoodsInfo(config.id, ITEM_TYPE.ITEM, config.selectedCount .. "/" .. config.count, true)
	self:showMinusButton(config.selectedCount > 0)
end

function QUIWidgetItemsBoxEnchant:refresh()
	self:setInfo(self._config)
end

function QUIWidgetItemsBoxEnchant:getContentSize()
	return self._ccbOwner.node_bj:getContentSize()
end

function QUIWidgetItemsBoxEnchant:consecutiveMinusPush( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

    self:_onTriggerMinusClick()
	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

return QUIWidgetItemsBoxEnchant