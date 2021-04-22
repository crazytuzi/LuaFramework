-- @Author: xurui
-- @Date:   2017-03-31 16:17:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-01 12:04:30
local QUIWidgetGemstonesBaseBox = import("...widgets.QUIWidgetGemstonesBaseBox")
local QUIWidgetSparBox = class("QUIWidgetSparBox", QUIWidgetGemstonesBaseBox)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetHeroHeadStar = import("...widgets.QUIWidgetHeroHeadStar")

QUIWidgetSparBox.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetSparBox.EVENT_MINUS_CLICK = "EVENT_MINUS_CLICK"



function QUIWidgetSparBox:ctor(options)
	local ccbFile = "ccb/Widget_spar_box.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerTouch", callback = handler(self, self._onTriggerTouch)},
		{ccbCallbackName = "onTriggerMinusTouch", callback = handler(self, self._onTriggerMinusTouch)},
	}
	QUIWidgetSparBox.super.ctor(self, ccbFile, callBack, options)
	self._longTouch = false
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSparBox:onEnter()
end

function QUIWidgetSparBox:onExit()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
end

function QUIWidgetSparBox:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg_1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg_2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._icon, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_spar_frame, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_strengthen_level, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_wear2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_lock, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_quality, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_state, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_star, self._glLayerIndex)
	-- 
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_inherit, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit, self._glLayerIndex)
	--pingzhi
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_b, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_c, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["pingzhi_a+"], self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s4, self._glLayerIndex)

	if self._star then
		self._glLayerIndex = self._star:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_mask, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_spar_name, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_tips, self._glLayerIndex)


	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_minus, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.minus, self._glLayerIndex)


	return self._glLayerIndex
end

function QUIWidgetSparBox:resetAll()
	self._ccbOwner.node_tips:setVisible(false)
	self._ccbOwner.node_state:setVisible(false)
	self._ccbOwner.node_normal:setVisible(true)
	self._ccbOwner.node_strengthen:setVisible(false)
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.node_wear:setVisible(false)
	self._ccbOwner.node_icon:setVisible(false)
	self._ccbOwner.node_gray:setVisible(false)
	self._ccbOwner.node_pingzhi:setVisible(false)
	self._ccbOwner.node_inherit:setVisible(false)
	self._ccbOwner.node_minus:setVisible(false)
end
	
-- index: 1,代表榴石；2，代表曜石
function QUIWidgetSparBox:setGemstoneInfo(sparInfo, sparPos)
	self:setInfo({sparInfo = sparInfo, sparPos = sparPos})
end

function QUIWidgetSparBox:setInfo(param)
	self:resetAll()

	self._sparInfo = param.sparInfo or {}
	self._itemId = self._sparInfo.type or self._sparInfo.itemId
	self._sparPos = param.sparPos or 1
	self._index = param.index

	local name = ""
	if self._itemId ~= nil then
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
		self:setIcon(itemInfo.icon)

		self:setStar((self._sparInfo.grade or 0) + 1)
		self:setInherit(self._sparInfo.inheritLv or 0)
		self:showSabc()

		if self._sparInfo.level ~= nil then
			self._ccbOwner.tf_strengthen_level:setString(self._sparInfo.level or 1)
			self._ccbOwner.node_strengthen:setVisible(true)
		end

		name = param.content or itemInfo.name
	end
	self:setName(name)
	if param.addLine ~= nil then
		self:setBackPackLine(param.addLine)
	end

	if param.redTips ~= nil then
		self:setTips(param.redTips)
	end

	if param.userState ~= nil then
		self:setWearState(param.userState)
	end

	if self._selectPosition and self._index == self._selectPosition then
		self:selected(true)
	end

	self:setBgIcon()
end

function QUIWidgetSparBox:setStar(star)
	local starNum = star or 5

	if self._star == nil then
    	self._star = QUIWidgetHeroHeadStar.new({})
    	self._ccbOwner.node_star:addChild(self._star:getView())
    end

    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
    -- handle empty star
	if itemInfo and itemInfo.gemstone_quality and itemInfo.gemstone_quality >= APTITUDE.SS then
		if starNum <= 5 then -- 0~5 都是空星
    		self._star:setEmptyStar()
    	else
    		local grade = math.floor((starNum - 1) / 5) -- SS 's spar 5 grade equal 1 star 
    		self._star:setStar((grade or 1) , false)
    	end
    else
    	self._star:setStar((starNum or 0), false)
	end

	self._ccbOwner.node_star:setVisible(starNum>0)
end

function QUIWidgetSparBox:setIcon(iconPath)
	if self._icon == nil then
		self._icon = CCSprite:create()
		self._ccbOwner.node_icon:addChild(self._icon)
		self._ccbOwner.node_icon:setScale(1)
	end
	self._icon:setOpacity(1 * 255)
	self._icon:setTexture(CCTextureCache:sharedTextureCache():addImage(iconPath))
	self._icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)

	self._ccbOwner.node_icon:setVisible(true)
end

function QUIWidgetSparBox:setBgIcon()
	for i = 1, 2 do
		self._ccbOwner["sp_bg_"..i]:setVisible(i == self._sparPos)
	end
end

function QUIWidgetSparBox:setState(state, index)
	self:resetAll()
	if state == nil then return end

	self._sparPos = index

	self._state = state
	if state == remote.spar.SPAR_LOCK then
		self:setWearState(false)
		self:setLockState(true)
		self:setStar(0)
	elseif state == remote.spar.SPAR_CAN_WEAR then
		self:setWearState(false)
		self:setStar(0)
		self._ccbOwner.node_wear:setVisible(true)
	elseif state == remote.spar.SPAR_NONE then
		self:setWearState(false)
		self:setStar(0)
		self._ccbOwner.node_wear:setVisible(false)	
		self._ccbOwner.node_break:setVisible(false)	
	end
	local name = "八蛛矛前螯"
	if self._sparPos == 2 then
		name = "八蛛矛后爪"
	end
	self:setName(name)
	self:setBgIcon()
end

function QUIWidgetSparBox:getState()
	return self._state
end

function QUIWidgetSparBox:showMinusButton(visible)
	self._ccbOwner.node_minus:setVisible(visible)
	if not visible then
		self:onMinusUpHandler()
	end
end

function QUIWidgetSparBox:setLongTouch(isLongTouch)
	self._longTouch = isLongTouch
end

function QUIWidgetSparBox:setWearState(state)
	if state == nil then state = false end
	self._ccbOwner.node_state:setVisible(state)
end

function QUIWidgetSparBox:setSelectPosition(pos)
	self._selectPosition = pos
end

--设置位置
function QUIWidgetSparBox:setPos(pos)
end

function QUIWidgetSparBox:getIndex()
	return self._index
end

function QUIWidgetSparBox:getSparPos()
	return self._sparPos
end

function QUIWidgetSparBox:setName(name, scale)
	self._ccbOwner.tf_spar_name:setString(name or "")
	if scale then
		self._ccbOwner.tf_spar_name:setScale(scale)
	end
end

function QUIWidgetSparBox:setNameColor(color)
	if color == nil then return end
	self._ccbOwner.tf_spar_name:setColor(color)
end

function QUIWidgetSparBox:setNameVisible(state)
	if state == nil then return end
	self._ccbOwner.tf_spar_name:setVisible(state)
end

--替换掉本身的name
function QUIWidgetSparBox:setNameNode(tf_name)
	local nameVisible = self._ccbOwner.tf_spar_name:isVisible()
	local nameValue = self._ccbOwner.tf_spar_name:getString() or ""
	self:setNameVisible(false)
	self._ccbOwner.tf_spar_name = tf_name
	self:setNameVisible(nameVisible)
	self._ccbOwner.tf_spar_name:setString(nameValue)
end

function QUIWidgetSparBox:setNamePositionOffset(offsetX, offsetY)
	self._ccbOwner.tf_spar_name:setPositionX(offsetX)
	self._ccbOwner.tf_spar_name:setPositionY(-72 + offsetY)
end

function QUIWidgetSparBox:selected(b)
	self._ccbOwner.node_select:setVisible(b)
end

function QUIWidgetSparBox:setLockState(state)
	self._ccbOwner.node_lock:setVisible(state)
	if state then
		local unlockLevel = remote.spar:getUnlockHeroLevelByIndex(self._sparPos)
		if unlockLevel == nil then return end
		self._ccbOwner.tf_lock:setString(unlockLevel.."级\n开启")
	end
end

-- 添加背包中的线
function QUIWidgetSparBox:setBackPackLine(state)
	if state == false and self._line ~= nil then
		self._line:removeFromParent()
		self._line = nil
	elseif state and self._line == nil then
	    self._line = CCBuilderReaderLoad("ccb/Widget_Baoshi_Packsack_xian.ccbi", CCBProxy:create(), {})
	    local contentSize = self:getContentSize()
	    self._line:setPosition(ccp(contentSize.width*2 - 50, -contentSize.height+20))
		self:getView():addChild(self._line)
	end
end

function QUIWidgetSparBox:setStrengthVisible(state)
	if self._state == remote.spar.SPAR_LOCK or self._state == remote.spar.SPAR_CAN_WEAR then
		state = false
	end
	self._ccbOwner.node_strengthen:setVisible(state)
end


--设置突破小红点显示
function QUIWidgetSparBox:setGradeTips(b)
	self._gradeTips = b
end

--设置突破小红点显示
function QUIWidgetSparBox:setStrengthTips(b)
	self._strengthTips = b
end

--设置突破小红点显示
function QUIWidgetSparBox:setDetailTips(b)
	self._detailTips = b
end

--设置小红点显示
function QUIWidgetSparBox:setTips(b)
	self._tips = b
	self:showTipsByState()
end

--设置吸收小红点显示
function QUIWidgetSparBox:setInheritTips(b)
	self._inheritTips = b
end

--设置小红点显示
function QUIWidgetSparBox:showTipsByState(state)
	if state == nil then
		self._ccbOwner.node_tips:setVisible(self._tips)
		return 
	end
	if state == "grade" then
		self._ccbOwner.node_tips:setVisible(self._gradeTips)
		return 
	end
	if state == "strength" then
		self._ccbOwner.node_tips:setVisible(self._strengthTips)
		return 
	end
	if state == "detail" then
		self._ccbOwner.node_tips:setVisible(self._detailTips)
		return 
	end

	if state == "inherit" then
		self._ccbOwner.node_tips:setVisible(self._inheritTips)
		return 
	end

end


function QUIWidgetSparBox:setInherit(inherit)
	if inherit <= 0 then
		self._ccbOwner.node_inherit:setVisible(false)
		return
	end
    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	if itemInfo and itemInfo.gemstone_quality and itemInfo.gemstone_quality >= APTITUDE.SS then
		self._ccbOwner.node_inherit:setVisible(true)
	    local frame =QSpriteFrameByPath(QResPath("spar_absorb_sp")[tonumber(inherit)])
	    if frame then
	    	self._ccbOwner.sp_inherit:setVisible(true)
	        self._ccbOwner.sp_inherit:setDisplayFrame(frame)
	    end
	else
		self._ccbOwner.node_inherit:setVisible(false)
	end
end

function QUIWidgetSparBox:showSabc()
	if not self._itemId then 
		self:hideSabc()
		return 
	end

    local itemInfo = db:getItemByID(self._itemId)
	local aptitudeInfo = db:getSABCByQuality(itemInfo.gemstone_quality )
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

	-- if aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
	-- 	self._ccbOwner["star_a"]:setVisible(true)
	-- elseif aptitudeInfo.lower == "s" then
	-- 	self._ccbOwner["star_s"]:setVisible(true)
	-- end

	self._ccbOwner.node_pingzhi:setVisible(true)
end

function QUIWidgetSparBox:hideSabc()
	self._ccbOwner.node_pingzhi:setVisible(false)
end


function QUIWidgetSparBox:setGrayState(state)
	self._ccbOwner.node_gray:setVisible(state)
end

function QUIWidgetSparBox:setPromptIsOpen(state)
	self._promptIsOpen = state
end

function QUIWidgetSparBox:_onTriggerTouch(eventType)

	if self._longTouch then
		if tonumber(eventType) == CCControlEventTouchDown then 	
			self._isClick = true
			self:onDownHandler()
		elseif tonumber(eventType) == CCControlEventTouchUpInside then
			if self._isClick then
	    		self:_onTriggerClick()
	    	end
			self._isClick = false
			self:onUpHandler()
		end
	else
		if self._promptIsOpen == true and tonumber(eventType) == CCControlEventTouchDown then 	
			app.tip:sparTip(ITEM_TYPE.SPAR, self._itemId, self._sparInfo)
		elseif tonumber(eventType) == CCControlEventTouchUpInside then
			self:dispatchEvent({name = QUIWidgetSparBox.EVENT_CLICK, itemID = self._itemId, sparPos = self._sparPos, boxType = 1, index = self._index})
		end
	end

end

function QUIWidgetSparBox:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSparBox.EVENT_CLICK, itemID = self._itemId, sparPos = self._sparPos, boxType = 1, index = self._index})
end


function QUIWidgetSparBox:_onTriggerMinusTouch(eventType)

	if tonumber(eventType) == CCControlEventTouchDown then 	
		self._isTouchBeganMinus = true
		self:onMinusDownHandler()
	elseif tonumber(eventType) == CCControlEventTouchUpInside and self._isTouchBeganMinus then
		if self._isTouchBeganMinus then
    		self:_onTriggerMinusClick()
		end
		self._isTouchBeganMinus = false
		self:onMinusUpHandler()
		-- self:onUpHandler()
	end
	
end

function QUIWidgetSparBox:_onTriggerMinusClick()
	self:dispatchEvent({name = QUIWidgetSparBox.EVENT_MINUS_CLICK, itemID = self._itemId, sparPos = self._sparPos, boxType = 1, index = self._index})
end



function QUIWidgetSparBox:onDownHandler()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), 0.6)
end

function QUIWidgetSparBox:onUpHandler( ... )
	self.interval = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetSparBox:consecutivePush( ... )
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

    self:_onTriggerClick()
	self._timeHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutivePush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end




function QUIWidgetSparBox:onUpHandler( ... )
	self.interval = 0.2
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetSparBox:onMinusDownHandler()
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), 0.6)
end

function QUIWidgetSparBox:onMinusUpHandler( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end
	self.interval = 0.2
end

function QUIWidgetSparBox:consecutiveMinusPush( ... )
	if self._timeMinusHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeMinusHandler)
		self._timeMinusHandler = nil
	end

    self:_onTriggerMinusClick()
	self._timeMinusHandler = scheduler.performWithDelayGlobal(handler(self, self.consecutiveMinusPush), self.interval)
	self.interval = self.interval - 0.02
	if self.interval < 0.05 then self.interval = 0.05 end
end

function QUIWidgetSparBox:getContentSize()
	return self._ccbOwner.sp_spar_frame:getContentSize()
end

return QUIWidgetSparBox