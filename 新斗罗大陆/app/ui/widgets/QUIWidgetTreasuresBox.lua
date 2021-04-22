--
-- Kumo.Wang
-- 资源夺宝格子
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetTreasuresBox = class("QUIWidgetTreasuresBox", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import(".actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")

QUIWidgetTreasuresBox.EVENT_LIGHT_UP_END = "QUIWIDGETTREASURESBOX.EVENT_LIGHT_UP_END"
QUIWidgetTreasuresBox.EVENT_TWINKLE_END = "QUIWIDGETTREASURESBOX.EVENT_TWINKLE_END"
QUIWidgetTreasuresBox.EVENT_BONUS_TWINKLE_END = "QUIWIDGETTREASURESBOX.EVENT_BONUS_TWINKLE_END"

function QUIWidgetTreasuresBox:ctor(options)
	local ccbFile = "ccb/Widget_Treasures_Box.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerMinus", callback = handler(self, self._onTriggerMinus)},
    }
	QUIWidgetTreasuresBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    	
    if options then
    	self._index = options.index
    end

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)

    self._isPlaying = false
    self:resetAll()
    self.promptTipIsOpen = false
    self._isBonusIcon = false
end

function QUIWidgetTreasuresBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	if self._spBg then
		self._glLayerIndex = q.nodeAddGLLayer(self._spBg, self._glLayerIndex)
	end
	if self._spLightUp then
		self._glLayerIndex = q.nodeAddGLLayer(self._spLightUp, self._glLayerIndex)
	end
	if self.icon then
		self._glLayerIndex = q.nodeAddGLLayer(self.icon, self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_goods_num, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetTreasuresBox:setPromptIsOpen(value)
  self.promptTipIsOpen = value
end

function QUIWidgetTreasuresBox:getIndex()
	return self._index
end

function QUIWidgetTreasuresBox:resetAll()
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg:setVisible(true)

	self._ccbOwner.node_effect:removeAllChildren()
	local path = QResPath("resource_treasures_gride_xuanzhong")
	self._spLightUp = CCSprite:create(path)
	self._ccbOwner.node_effect:addChild(self._spLightUp)
	self._ccbOwner.node_effect:setVisible(false)

	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.tf_goods_num:setVisible(false)

	self._ccbOwner.node_box:setScale(1)
end

function QUIWidgetTreasuresBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetTreasuresBox:onEnter()
	self._ccbOwner.node_size:setTouchEnabled(true)
	self._ccbOwner.node_size:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	self._ccbOwner.node_size:setTouchSwallowEnabled(true)
	self._ccbOwner.node_size:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))
end

function QUIWidgetTreasuresBox:onExit()
	self._ccbOwner.node_size:setTouchEnabled(false)
	self._ccbOwner.node_size:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

	if self._twinkleScheduler then
		scheduler.unscheduleGlobal(self._twinkleScheduler)
		self._twinkleScheduler = nil
	end
end

-- 点亮
function QUIWidgetTreasuresBox:lightUp()
	-- print("[Kumo] QUIWidgetTreasuresBox:lightUp() ", self._index)
	if self._isPlaying then return end
	self._isPlaying = true
	self._spLightUp:setOpacity(255)

    local actions = CCArray:create()
	actions:addObject(CCDelayTime:create(self._resourceTreasuresModule.STEP_INTERVAL))
	actions:addObject(CCFadeOut:create(self._resourceTreasuresModule.STEP_INTERVAL * 6))

	local actions2 = CCArray:create()
	actions2:addObject(CCDelayTime:create(self._resourceTreasuresModule.STEP_INTERVAL))
	actions2:addObject(CCScaleTo:create(self._resourceTreasuresModule.STEP_INTERVAL * 6, 1))
	actions2:addObject(CCCallFunc:create(function() 
    		if self._ccbView then
    			self._isPlaying = false
				self._ccbOwner.node_box:setScale(1)
    			self._ccbOwner.node_effect:setVisible(false)
				self:dispatchEvent({name = self.EVENT_LIGHT_UP_END, index = self._index})
    		end
		end))

	self._ccbOwner.node_box:setScale(1.1)
	self._ccbOwner.node_effect:setVisible(true)

    self._spLightUp:runAction(CCSequence:create(actions))
	self._ccbOwner.node_box:runAction(CCSequence:create(actions2))
end

-- 闪烁
-- isEventBox 接受事件的box，防止多个同时触发，多次重复监听
function QUIWidgetTreasuresBox:twinkle( isBonus, isEventBox, bonusRound )
	print("QUIWidgetTreasuresBox:twinkle()", self._index, isBonus, isEventBox, bonusRound)
	self._isPlaying = true
	self._spLightUp:setOpacity(255)
	self._twinkleCount = 0

	if self._twinkleScheduler then
		scheduler.unscheduleGlobal(self._twinkleScheduler)
		self._twinkleScheduler = nil
	end

	self._ccbOwner.node_box:setScale(1)
	self._ccbOwner.node_effect:setVisible(true)
	self._twinkleScheduler = scheduler.scheduleGlobal(function()
		if self._ccbView then
			self._twinkleCount = self._twinkleCount + 1
			self._ccbOwner.node_effect:setVisible(not self._ccbOwner.node_effect:isVisible())
			if self._twinkleCount >= 3 then
				if self._twinkleScheduler then
					scheduler.unscheduleGlobal(self._twinkleScheduler)
					self._twinkleScheduler = nil
				end
				self._isPlaying = false
				self._ccbOwner.node_box:setScale(1)
				self._ccbOwner.node_effect:setVisible(false)
				if isBonus then
					self:dispatchEvent({name = self.EVENT_BONUS_TWINKLE_END, index = self._index, isEventBox = isEventBox, bonusRound = bonusRound})
				else
					self:dispatchEvent({name = self.EVENT_TWINKLE_END, index = self._index, isEventBox = isEventBox})
				end
			end
		end
	end, 0.1)
end

function QUIWidgetTreasuresBox:addGoodsNum(addNum)
	local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_baoguang_effect", "res")
	fcaEffect:playAnimation("animation", false)
	fcaEffect:setEndCallback(function()
				fcaEffect:removeFromParent()
				fcaEffect = nil
				if self._ccbView then
					local num = tonumber(self._ccbOwner.tf_goods_num:getString())
					self:_setItemCount(num + addNum)
				end
			end)
	self._ccbOwner.node_add_effect:addChild(fcaEffect)
end

function QUIWidgetTreasuresBox:setGoodsInfo(itemID, itemType, goodsNum, froceShow, color)
	self._itemID = itemID
	self._itemType = remote.items:getItemType(itemType)
	self:resetAll()
	if self._itemType == ITEM_TYPE.ITEM then 
  		self:_showAsItem(itemID, goodsNum, froceShow, color)
	else
		self:_showAsResouce(goodsNum, froceShow, color)
	end
end

function QUIWidgetTreasuresBox:setBonus()
	local path = QResPath("resource_treasures_bonus_icon")
	if path then
		self._isBonusIcon = true
		self:_setItemIconAndCount(path, 0, false, 1)
	end
end

function QUIWidgetTreasuresBox:setSeniorCard(sacleX)
	local sacleX = sacleX or 1
	local path = QResPath("resource_treasures_gride_card")[self._resourceTreasuresModule.SENIOR_THEME]
	self._spBg = CCSprite:create(path)
	self._spBg:setScaleX(sacleX)
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg:addChild(self._spBg)
	self._ccbOwner.node_bg:setVisible(true)
	self._ccbOwner.node_icon:setVisible(false)
end

function QUIWidgetTreasuresBox:setPrimaryCard(sacleX)
	local sacleX = sacleX or 1
	local path = QResPath("resource_treasures_gride_card")[self._resourceTreasuresModule.PRIMARY_THEME]
	self._spBg = CCSprite:create(path)
	self._spBg:setScaleX(sacleX)
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg:addChild(self._spBg)
	self._ccbOwner.node_bg:setVisible(true)
	self._ccbOwner.node_icon:setVisible(false)
end

--当作item来显示
function QUIWidgetTreasuresBox:_showAsItem(itemID, goodsNum, froceShow, color)
	local itemInfo = db:getItemByID(itemID)
	local path = itemInfo and (itemInfo.icon_treasure or itemInfo.icon)
	if path then
		self:_setItemIconAndCount(path, goodsNum, froceShow, color)
	end
end

--当作Resouce来显示
function QUIWidgetTreasuresBox:_showAsResouce(goodsNum, froceShow, color)
	local icon, name = remote.items:getURLForItem(self._itemType, "alphaIcon")
	if icon then
		self:_setItemIconAndCount(icon, goodsNum, froceShow, color)
	end
end

--设置item基本信息
function QUIWidgetTreasuresBox:_setItemIconAndCount(respath, goodsNum, froceShow, color)
	if goodsNum == nil then goodsNum = 0 end
	if color then
		self._ccbOwner.node_bg:removeAllChildren()
		local path = QResPath("resource_treasures_gride_bg")[tonumber(color)]
		if path then
			local sp = CCSprite:create(path)
			self._ccbOwner.node_bg:addChild(sp)
			self._ccbOwner.node_bg:setVisible(true)
		end
	else
		self._ccbOwner.node_bg:removeAllChildren()
		local path = QResPath("resource_treasures_theme_none")
		if path then
			local sp = CCSprite:create(path)
			self._ccbOwner.node_bg:addChild(sp)
			self._ccbOwner.node_bg:setVisible(true)
		end
	end
  	if respath then
  		self:_setItemIcon(respath)
  	end
  	if froceShow == nil then froceShow = false end
  	if froceShow == true or goodsNum > 0 then
  		self:_setItemCount(goodsNum)
	else
		self._ccbOwner.tf_goods_num:setVisible(false)
  	end
end

--设置icon
function QUIWidgetTreasuresBox:_setItemIcon(respath)
	if respath then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end

		self.icon:setVisible(true)
		self.icon:setScale(1)
		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		
		setNodeShaderProgram(self.icon, qShader.CC_ProgramPositionTextureColor)
		self.icon:setOpacity(1 * 255)
		
		local size = self.icon:getContentSize()
		local targetSize = self._ccbOwner.node_icon_size:getContentSize()
		local targetScaleX = self._ccbOwner.node_icon_size:getScaleX()
		local targetScaleY = self._ccbOwner.node_icon_size:getScaleY()
		if size.width ~= targetSize.width then
			self.icon:setScaleX(targetSize.width * targetScaleX/size.width)
		end
		if size.height ~= targetSize.height then
			self.icon:setScaleY(targetSize.height * targetScaleY/size.height)
		end

		self._ccbOwner.node_icon:setVisible(true)
	end
end

function QUIWidgetTreasuresBox:_setItemCount(str)
	self._ccbOwner.tf_goods_num:setString(str)
	local size = self._ccbOwner.tf_goods_num:getContentSize()
	local targetSize = self._ccbOwner.node_icon_size:getContentSize()
	local scale = (targetSize.width - 20)/size.width
	if scale < 1 then
		self._ccbOwner.tf_goods_num:setScale(scale)
	else
		self._ccbOwner.tf_goods_num:setScale(1)
	end
	self._ccbOwner.tf_goods_num:setVisible(true)
end

function QUIWidgetTreasuresBox:_onTouch(event)
	if event.name == "began" then 
		self._startPosX = event.x
		self._startPosY = event.y
		self._isPatch = true
		return true
	elseif event.name == "moved" then	
		if self._isPatch == true then
			if self._startPosX ~= nil and math.abs(event.x - self._startPosX) > 10 then
				self._isPatch = false
			elseif self._startPosY ~= nil and math.abs(event.y - self._startPosY) > 10 then
				self._isPatch = false
			end
		end
	elseif event.name == "ended" or event.name == "cancelled" then 
		if self.promptTipIsOpen and self._isPatch then
			app.sound:playSound("common_small")
			if self._itemID or self._itemType then
				app.tip:itemTip(self._itemType, self._itemID)
			elseif self._isBonusIcon then
				app.tip:floatTip("这是雷电")
			else
				app.tip:floatTip("选择主题后才能预览")
			end
		end
		self._startPosX = nil
		self._startPosY = nil
		self._isPatch = nil
	end
end

return QUIWidgetTreasuresBox