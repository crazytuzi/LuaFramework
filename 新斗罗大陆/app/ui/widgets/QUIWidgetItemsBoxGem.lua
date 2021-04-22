--
-- Author: Your Name
-- Date: 2014-07-10 18:54:20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetItemsBoxGem = class("QUIWidgetItemsBoxGem", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItmePrompt = import(".QUIWidgetItmePrompt") 
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetItemsBoxGem.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetItemsBoxGem.EVENT_CLICK_END = "EVENT_CLICK_END"
QUIWidgetItemsBoxGem.EVENT_BEGAIN = "ITEM_EVENT_BEGAIN"
QUIWidgetItemsBoxGem.EVENT_END = "ITEM_EVENT_END"
QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK = "EVENT_MINUS_CLICK"
QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK_END = "EVENT_MINUS_CLICK_END"

function QUIWidgetItemsBoxGem:ctor(touchCallbackDisabled)
	local ccbFile = "ccb/Widget_ItemBox_Enchant.ccbi"
	local callBacks = {
    }
	QUIWidgetItemsBoxGem.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self:setNodeVisible(self._ccbOwner.node_goods,true)
    self:setTFText(self._ccbOwner.tf_goods_num,"")
    self:setNodeVisible(self._ccbOwner.node_mask,false)
    self:resetAll()

    self.promptTipIsOpen = false
    self.touchCallbackDisabled = touchCallbackDisabled
    self.interval = 0.2

    self._isNeedshadow = true
end

function QUIWidgetItemsBoxGem:setNeedshadow( boo )
	self._isNeedshadow = boo
	TFSetDisableOutline(self._ccbOwner.item_name, not boo)
end

function QUIWidgetItemsBoxGem:setPromptIsOpen(value)
  self.promptTipIsOpen = value
end

function QUIWidgetItemsBoxGem:getName()
	return "QUIWidgetItemsBoxGem"
end

function QUIWidgetItemsBoxGem:hideAllColor()
 	self:setNodeVisible(self._ccbOwner.node_bar,false)
    self:setNodeVisible(self._ccbOwner.node_green,false)
    self:setNodeVisible(self._ccbOwner.node_blue,false)
    self:setNodeVisible(self._ccbOwner.node_orange,false)
    self:setNodeVisible(self._ccbOwner.node_purple,false)
    self:setNodeVisible(self._ccbOwner.node_white,false)
    self:setNodeVisible(self._ccbOwner.node_gold,false)

    self._ccbOwner.node_scrap_green:setVisible(false)
    self._ccbOwner.node_scrap_blue:setVisible(false)
    self._ccbOwner.node_scrap_purple:setVisible(false)
    self._ccbOwner.node_scrap_orange:setVisible(false)
    self._ccbOwner.node_scrap_red:setVisible(false)
    self._ccbOwner.node_scrap_yellow:setVisible(false)
	self._ccbOwner.sp_break:setVisible(false)

    q.setAptitudeShow(self._ccbOwner)

    self:setNodeVisible(self._ccbOwner.node_mask_scrap,false)
end

function QUIWidgetItemsBoxGem:resetAll()
	self:hideAllColor()
    self:setNodeVisible(self._ccbOwner.icon,false)
    self:setTFText(self._ccbOwner.tf_goods_num,"")
    self._ccbOwner.node_scrap:setVisible(false)
    self._ccbOwner.node_soul:setVisible(false)
    self._ccbOwner.node_scrap_green:setVisible(false)
    self._ccbOwner.node_scrap_blue:setVisible(false)
    self._ccbOwner.node_scrap_purple:setVisible(false)
end

function QUIWidgetItemsBoxGem:getContentSize()
	return self._ccbOwner.sprite_back:getContentSize()
end

function QUIWidgetItemsBoxGem:onEnter()
	if not self.touchCallbackDisabled then
		self._ccbOwner.sprite_back:setTouchEnabled(true)
		self._ccbOwner.sprite_back:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._ccbOwner.sprite_back:setTouchSwallowEnabled(false)
		self._ccbOwner.sprite_back:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetItemsBoxGem._onTouch))

		self._ccbOwner.minus:setTouchEnabled(true)
		self._ccbOwner.minus:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		self._ccbOwner.minus:setTouchSwallowEnabled(true)
		self._ccbOwner.minus:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetItemsBoxGem._onTriggerMinus))
	end
end

function QUIWidgetItemsBoxGem:onExit()
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

function QUIWidgetItemsBoxGem:setBoxScale(scale)
  	if scale == nil then return end
  	self._ccbOwner.node_box:setScale(scale)
end

function QUIWidgetItemsBoxGem:setColor(breakLevel)
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

function QUIWidgetItemsBoxGem:setGoodsInfo(itemID, itemType, goodsNum, froceShow)
	self._itemID = itemID
	self._itemType = remote.items:getItemType(itemType)
	self:resetAll()
	self._name = ""
	if self._itemType == ITEM_TYPE.GEMSTONE_PIECE then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
		if itemInfo == nil then return end
		self._name = itemInfo.name

		self:showSabc(itemInfo.gemstone_quality or 10)
		self:_setItemInfo(self._itemID, itemInfo.icon, goodsNum, froceShow)
	end
end

function QUIWidgetItemsBoxGem:_setItemInfo(itemId, respath, goodsNum, froceShow)
	if goodsNum == nil then goodsNum = 0 end
	print("respath1 = "..respath)
  	if respath ~= nil then
  		self:setItemIcon(respath)
  	end
  	if froceShow == nil then froceShow = false end

  	local stoneInfo = remote.gemstone:getStoneCraftInfoByPieceId(itemId) or {}

  	local needNum = stoneInfo.component_num_1 or 0

	self:setTFText(self._ccbOwner.tf_goods_num, goodsNum)
	-- Scale the number if its size exceeds the box size @qinyuanji
	local numSize = self._ccbOwner.tf_goods_num:getContentSize()
	local boxSize = self._ccbOwner.node_scrap_normal:getContentSize()
	local scale = (boxSize.width - 20)/numSize.width
	if scale < 1 then
		self._ccbOwner.tf_goods_num:setScale(scale)
	end

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo == nil then return end
	if itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		self._ccbOwner.node_scrap:setVisible(true)
		self._ccbOwner.node_scrap_normal:setVisible(false)
		self._ccbOwner.node_scrap_green:setVisible(false)
		self._ccbOwner.node_scrap_blue:setVisible(false)
		self._ccbOwner.node_scrap_purple:setVisible(false)
		self._ccbOwner.node_scrap_orange:setVisible(false)
		if self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[itemInfo.colour]] ~= nil then
			self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[itemInfo.colour]]:setVisible(true)
		end
	end
	self._ccbOwner.item_name:setString(itemInfo.name)

	local fontColor = EQUIPMENT_COLOR[itemInfo.colour]
	self._ccbOwner.item_name:setColor(fontColor)
	if self._isNeedshadow then
		self._ccbOwner.item_name = setShadowByFontColor(self._ccbOwner.item_name, fontColor)
	else
		TFSetDisableOutline(self._ccbOwner.item_name, true)
	end
end

function QUIWidgetItemsBoxGem:showSabc(aptitude)
	if aptitude == nil then return end

    local aptitudeInfo = {}
    for _,value in ipairs(HERO_SABC) do
        if value.aptitude == aptitude then
            aptitudeInfo = value
        end
    end
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
	
    self._ccbOwner.node_pingzhi:setVisible(true)

	self._ccbOwner.node_scrap:setVisible(true)
	if self._ccbOwner["node_scrap_"..aptitudeInfo.color] then
    	self._ccbOwner["node_scrap_"..aptitudeInfo.color]:setVisible(true)	
	end
end

function QUIWidgetItemsBoxGem:_showIsItem(itemID, goodsNum, froceShow)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemID)
	if itemInfo == nil then return end
	if itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		self._ccbOwner.node_scrap:setVisible(true)
		self._ccbOwner.node_scrap_normal:setVisible(false)
		self._ccbOwner.node_scrap_green:setVisible(false)
		self._ccbOwner.node_scrap_blue:setVisible(false)
		self._ccbOwner.node_scrap_purple:setVisible(false)
		self._ccbOwner.node_scrap_orange:setVisible(false)
		if self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[itemInfo.colour]] ~= nil then
			self._ccbOwner["node_scrap_"..EQUIPMENT_QUALITY[itemInfo.colour]]:setVisible(true)
		end
	end
	self:_setItemInfo(self._itemID, itemInfo.icon, goodsNum, froceShow)
	if itemInfo.type ~= ITEM_CONFIG_TYPE.SOUL then
		if itemInfo.break_through then
			self:setColor(itemInfo.break_through)
		elseif itemInfo.colour then
			self:setColourColor(EQUIPMENT_QUALITY[itemInfo.colour])
		end
	else
		self:hideAllColor()
	end
end

function QUIWidgetItemsBoxGem:setColourColor( name )
	-- body
	self:hideAllColor()
	self:setNodeVisible(self._ccbOwner.node_bar,true)
	if name ~= nil then
    	self:setNodeVisible(self._ccbOwner["node_"..name],true)
    else
    	self:setNodeVisible(self._ccbOwner["node_normal"],true)
    end
end

function QUIWidgetItemsBoxGem:setQualityIcon()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

	if characher == nil or characher.func == nil then return end

	local aptitudeInfo = db:getActorSABC(actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetItemsBoxGem:setNameVisibility(visibility)
	self._ccbOwner.item_name:setVisible(visibility)
end

function QUIWidgetItemsBoxGem:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end

		self.icon:setVisible(true)
		self.icon:setScale(1)
		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		self._respath = respath

		if self._ccbOwner.node_scrap:isVisible() then
			self.icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorHead)
			self.icon:setOpacity(0.86 * 255)
			self._ccbOwner.node_bj:setVisible(false)
			self._ccbOwner.node_scrap_bj:setVisible(true)
		else
			self.icon:retain()
			self.icon:removeFromParent()
			self._ccbOwner.node_icon:addChild(self.icon)
			self.icon:release()
			self._ccbOwner.node_bj:setVisible(true)
			self._ccbOwner.node_scrap_bj:setVisible(false)
		end

		local size = self.icon:getContentSize()
		local size2 = self._ccbOwner.node_mask:getContentSize()
		local scaleX = self._ccbOwner.node_mask:getScaleX()
		local scaleY = self._ccbOwner.node_mask:getScaleY()

		if size.width > size2.width then
			self.icon:setScaleX(size2.width * scaleX/size.width)
		end
		if size.height > size2.height then
			self.icon:setScaleY(size2.height * scaleY/size.height)
		end
	end
end

function QUIWidgetItemsBoxGem:setNodeVisible(node,b)
	if node ~= nil then
		node:setVisible(b)
	end
end

function QUIWidgetItemsBoxGem:setTFText(node,str)
	if node ~= nil then
		node:setString(str)
	end
end

function QUIWidgetItemsBoxGem:showMinusButton(visible)
	self._ccbOwner.minus:setVisible(visible)
end

function QUIWidgetItemsBoxGem:_onTouch(event)
	if event.name == "began" then 
		self:onDownHandler()
		self._startPosX = event.x
		self._startPosY = event.y
		self._isPatch = true
	elseif event.name == "moved" then	
		if self._isPatch == true then
			if self._startPosX ~= nil and math.abs(event.x - self._startPosX) > 10 then
				self._isPatch = false
			elseif self._startPosY ~= nil and math.abs(event.y - self._startPosY) > 10 then
				self._isPatch = false
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:_onTriggerClick()
		if self.promptTipIsOpen and self._itemID and self._itemType then
			if self._isPatch then
				app.sound:playSound("common_small")
				app.tip:itemTip(self._itemType, self._itemID)
			end
		end
		self:onUpHandler()
		self:dispatchEvent({name = QUIWidgetItemsBoxGem.EVENT_CLICK_END , itemID = self._itemID, source = self})
		self._startPosX = nil
		self._startPosY = nil
		self._isPatch = nil
  	end
end

function QUIWidgetItemsBoxGem:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetItemsBoxGem.EVENT_CLICK , itemID = self._itemID, source = self})
end

function QUIWidgetItemsBoxGem:onDownHandler()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), 1)
end

function QUIWidgetItemsBoxGem:onUpHandler( ... )
	self.interval = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetItemsBoxGem:consecutivePush( ... )
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

    self:_onTriggerClick()
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

function QUIWidgetItemsBoxGem:_onTriggerMinus(event)
	if event.name == "began" then 
		self:onMinusDownHandler()
	elseif event.name == "ended" or event.name == "cancelled" then 
		self:onMinusUpHandler()
    	self:_onTriggerMinusClick()
		self:onUpHandler()
		self:dispatchEvent({name = QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK_END , itemID = self._itemID, source = self})
  	end
end

function QUIWidgetItemsBoxGem:getResPath()
	return self._respath
end

function QUIWidgetItemsBoxGem:_onTriggerMinusClick()
	self:dispatchEvent({name = QUIWidgetItemsBoxGem.EVENT_MINUS_CLICK , itemID = self._itemID, source = self})
end

function QUIWidgetItemsBoxGem:onMinusDownHandler()
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), 1)
end

function QUIWidgetItemsBoxGem:onMinusUpHandler( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
	self.interval = 0.2
end

function QUIWidgetItemsBoxGem:setInfo(config)
	self._config = config
	self:setGoodsInfo(config.id, ITEM_TYPE.GEMSTONE_PIECE, config.selectedCount .. "/" .. config.count, true)
	self:showMinusButton(config.selectedCount > 0)
end

function QUIWidgetItemsBoxGem:refresh()
	self:setInfo(self._config)
end

function QUIWidgetItemsBoxGem:getContentSize()
	return self._ccbOwner.node_bj:getContentSize()
end

function QUIWidgetItemsBoxGem:consecutiveMinusPush( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

    self:_onTriggerMinusClick()
	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

return QUIWidgetItemsBoxGem