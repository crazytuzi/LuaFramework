local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderKingMysteriousMany = class("QUIDialogThunderKingMysteriousMany", QUIDialog)
local QQuickWay = import("...utils.QQuickWay")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetThunderKingMysteriousMany = import("..widgets.QUIWidgetThunderKingMysteriousMany")
local QScrollContain = import("..QScrollContain")

function QUIDialogThunderKingMysteriousMany:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_haoyunbaoxiang.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOne", callback = handler(self, QUIDialogThunderKingMysteriousMany._onTriggerOne)},
		{ccbCallbackName = "onTriggerTwo", callback = handler(self, QUIDialogThunderKingMysteriousMany._onTriggerTwo)},
		{ccbCallbackName = "onTriggerLeave", callback = handler(self, QUIDialogThunderKingMysteriousMany._onTriggerLeave)},
	}
   	QUIDialogThunderKingMysteriousMany.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = true --是否动画显示

	self._emptyFrames = {}

	if options then
		self._callBackFunc = options.callBack
	end

	self.preciousTimes = remote.thunder:getPreciousTimes()

    self.tf_tips = QRichText.new()
    self.tf_tips:setAnchorPoint(0.5,0.5)
    self.tf_tips:setPositionX(self._ccbOwner.tf_tips:getPositionX())
    self.tf_tips:setPositionY(self._ccbOwner.tf_tips:getPositionY())
    self._ccbOwner.tf_tips:getParent():addChild(self.tf_tips)
    self._ccbOwner.tf_tips:setVisible(false)
    self.tf_tips:setString({
        {oType = "font", content = "您的战队实力雄厚，弹指一瞬间闯过了", size = 22,color = GAME_COLOR_LIGHT.normal},
        {oType = "font", content = #self.preciousTimes, size = 22,color = GAME_COLOR_LIGHT.stress},
        {oType = "font", content = "层，一共获得了", size = 22,color = GAME_COLOR_LIGHT.normal},
        {oType = "font", content = #self.preciousTimes, size = 22,color = GAME_COLOR_LIGHT.stress},
        {oType = "font", content = "个好运宝箱", size = 22,color = GAME_COLOR_LIGHT.normal},
    })

    self._ccbOwner.frame_tf_title:setString("开启好运宝箱")

	self.chestContain = QScrollContain.new({sheet = self._ccbOwner.content_sheet, slideRate = 0.2, sheet_layout = self._ccbOwner.content_sheet_layout, 
		direction = QScrollContain.directionX, renderFun = handler(self, self._onFrameHandler)})
	self.chestContain:setIsCheckAtMove(true)

	self._ccbOwner.btn_close:setVisible(false)

	self._isAllOpen = false
end

function QUIDialogThunderKingMysteriousMany:viewDidAppear()
	QUIDialogThunderKingMysteriousMany.super.viewDidAppear(self)
    self:showInfo()
    self:showChest()
end

function QUIDialogThunderKingMysteriousMany:viewWillDisappear()
    QUIDialogThunderKingMysteriousMany.super.viewWillDisappear(self)
	self:clearVirtualFrames()
	if self._emptyFrames ~= nil then
		for _,icon in ipairs(self._emptyFrames) do
			icon:removeAllEventListeners()
		end
	end
    if self.chestContain ~= nil then
    	self.chestContain:disappear()
    	self.chestContain = nil
    end
end

function QUIDialogThunderKingMysteriousMany:showInfo()
	self._oneToken = 0
	self._twoToken = 0
	local isFound1 = true
	local isFound2 = true
	local database = QStaticDatabase:sharedDatabase()
	for _,value in ipairs(self.preciousTimes) do
		local config1,found1 = database:getTokenConsume("fulminous_price", value.count)
		local config2,found2 = database:getTokenConsume("fulminous_price", value.count+1)
		self._oneToken = self._oneToken + config1.money_num
		self._twoToken = self._twoToken + config1.money_num + config2.money_num
		
		isFound1 = found1
		isFound2 = found2
	end
	if self._oneToken == 0 then
		self._ccbOwner.tf_free:setVisible(true)
		self._ccbOwner.node_token1:setVisible(false)
	else
		self._ccbOwner.tf_free:setVisible(false)
		self._ccbOwner.node_token1:setVisible(true)
		self._ccbOwner.tf_token1:setString(self._oneToken)
	end
	self._ccbOwner.node_token2:setVisible(true)
	self._ccbOwner.tf_token2:setString(self._twoToken)

	if self:checkChestIsHaveFreeOpen() == true then
		makeNodeFromNormalToGray(self._ccbOwner.btn_leave)
		-- self._ccbOwner.tf_leave:disableOutline()
	else
		makeNodeFromGrayToNormal(self._ccbOwner.btn_leave)
		-- self._ccbOwner.tf_leave:enableOutline()
	end

	-- 找不到次数对应配置
	if not isFound1 then
		self._ccbOwner.btn_open1:setTouchEnabled(false)
		self._ccbOwner.node_token1:setVisible(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_open1)
	end
	if not isFound2 then
		self._ccbOwner.btn_open2:setTouchEnabled(false)
		self._ccbOwner.node_token2:setVisible(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_open2)
	end
	self._isAllOpen = not (isFound1 or isFound2)
end

function QUIDialogThunderKingMysteriousMany:showChest()
	self:clearVirtualFrames()
	self._virtualFrames = {}
	self._cellW = 210
	local offset = 6
	local gap = 21
	for index,value in ipairs(self.preciousTimes) do
		local posX = (index - 1) * (self._cellW + gap) + self._cellW/2 + offset
		table.insert(self._virtualFrames,{layer = value.layer, count = value.count, posX = posX, posY = -135, isShow = false})
	end
	local size = self.chestContain:getContentSize()
	size.width = (self._cellW + gap) * #self.preciousTimes
    self.chestContain:setContentSize(size.width, size.height)
	self:_onFrameHandler()
end

--开箱子动画
function QUIDialogThunderKingMysteriousMany:openBoxEffect(awards, layer, oldHeros)
	self:enableTouchSwallowTop() --屏蔽上层
	self.chestContain.touchLayer:disable()
	for _, value in pairs(self._virtualFrames) do
		if value.icon ~= nil and (layer == nil or value.layer == layer) then
			value.icon:setChestState(true)
		end
	end

	local count = #self.preciousTimes
	if layer ~= nil then count = 1 end
	self._waitForShowitem = scheduler.performWithDelayGlobal(function ()
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards, oldHeros = oldHeros, callBack = function ()
            	self:disableTouchSwallowTop()
				self.chestContain.touchLayer:enable()
				for _, value in pairs(self._virtualFrames) do
					if value.icon ~= nil then
						value.icon:setChestState(false)
					end
				end
				self.preciousTimes = remote.thunder:getPreciousTimes()
			    self:showInfo()
			    self:showChest()
            end}}, {isPopCurrentDialog = false} )
        dialog:setTitle("")
	end, 1.5)
end

function QUIDialogThunderKingMysteriousMany:_onFrameHandler()
	local contentX = self.chestContain.content:getPositionX()
	local minValue = - self._cellW
	local maxValue = (self.chestContain.size.width + self._cellW)
	local offsetX = 0
	for _, value in pairs(self._virtualFrames) do
		offsetX = value.posX + contentX
		if offsetX >= maxValue or offsetX <= minValue then  
			self:_show(value, false)
		end
	end
	for _, value in pairs(self._virtualFrames) do
		offsetX = value.posX + contentX
		if offsetX >= maxValue or offsetX <= minValue then  
		else
			self:_show(value, true)
		end
	end
end

function QUIDialogThunderKingMysteriousMany:_show(frame, isShow)
	if frame.isShow == isShow then 
		return 
	end
	frame.isShow = isShow
	if isShow == false then
		if frame.icon ~= nil then
			self._emptyFrames[#self._emptyFrames+1] = frame.icon
			frame.icon:setVisible(false)
			frame.icon = nil
		end
	else
		frame.icon = self:_getEmptyFrames()
		frame.icon:setVisible(true)
		frame.icon:setChestState(false)
		frame.icon:setPosition(ccp(frame.posX , frame.posY))
		frame.icon:setInfo(frame.layer, frame.count)
	end
end

function QUIDialogThunderKingMysteriousMany:clearVirtualFrames()
	if self._virtualFrames ~= nil then
		for _, frame in pairs(self._virtualFrames) do
			if frame.icon ~= nil then
				self._emptyFrames[#self._emptyFrames+1] = frame.icon
				frame.icon:setVisible(false)
				frame.icon = nil
			end
		end
	end
end

function QUIDialogThunderKingMysteriousMany:_getEmptyFrames()
	if self._emptyFrames ~= nil and #self._emptyFrames > 0 then
		return table.remove(self._emptyFrames)
	else
		local icon = QUIWidgetThunderKingMysteriousMany.new()
		icon:addEventListener(icon.EVENT_CLICK, handler(self, self.clickHandler))
		icon:setVisible(false)
		self.chestContain:addChild(icon)
		return icon
	end
end

--检查是否有免费开启的宝箱
function QUIDialogThunderKingMysteriousMany:checkChestIsHaveFreeOpen()
	for index,value in ipairs(self.preciousTimes) do
		if value.count == 1 then
			return true
		end
	end
	return false
end

function QUIDialogThunderKingMysteriousMany:clickHandler(e)
	if self.chestContain:getMoveState() == true then 
    	app.sound:playSound("common_confirm")
		return
	end
	local layer = e.layer
	local times = 0
	for _,value in ipairs(self.preciousTimes) do
		if value.layer == layer then
			times = value.count
		end
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderKingMysteriousBaoxiang", 
		options = {times = times, layer = layer, callBack = function ()
			self.preciousTimes = remote.thunder:getPreciousTimes()
		    self:showInfo()
		    self:showChest()
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogThunderKingMysteriousMany:_onTriggerOne(e)
	if q.buttonEventShadow(e,self._ccbOwner.btn_open1) == false then return end
    app.sound:playSound("common_confirm")
	if remote.user.token < self._oneToken then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, function ()
			-- self:popSelf()
		end)
		return
	end

	local callback = function()
		local oldHeros = clone(remote.herosUtil:getHaveHero())
		remote.thunder:thunderBuyAllPreciousRequest(true, 1, false, function(data)
			self:openBoxEffect(data.apiThunderBuyPreciousResponse.luckyDraw.prizes, nil, oldHeros)
		end)
	end

	if self._oneToken > 0 then
		local content = string.format("##n好运宝箱全开一次需要消耗共##e%d##n钻石，确定开启吗？", self._oneToken)
		app:alert({content = content,title = "系统提示", callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
					callback()
				end
			end, colorful = true}, false)
	else
		callback()
	end
end

function QUIDialogThunderKingMysteriousMany:_onTriggerTwo(e)
	if q.buttonEventShadow(e,self._ccbOwner.btn_open2) == false then return end
    app.sound:playSound("common_confirm")
	if remote.user.token < self._twoToken then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY)
		return
	end

	local callback = function()
		local oldHeros = clone(remote.herosUtil:getHaveHero())
		remote.thunder:thunderBuyAllPreciousRequest(true, 2, false, function(data)
			self:openBoxEffect(data.apiThunderBuyPreciousResponse.luckyDraw.prizes, nil, oldHeros)
		end)
	end
	local content = string.format("##n好运宝箱全开两次需要消耗共##e%d##n钻石，确定开启吗？", self._twoToken)
	app:alert({content = content,title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				callback()
			end
		end, colorful = true}, false)
end

function QUIDialogThunderKingMysteriousMany:_onTriggerLeave(e)
	if q.buttonEventShadow(e,self._ccbOwner.button_leave) == false then return end
    app.sound:playSound("common_confirm")
    self:closeHandler()
end

function QUIDialogThunderKingMysteriousMany:closeHandler()
    if self:checkChestIsHaveFreeOpen() == true then
    	app.tip:floatTip("魂师大人，您还有未开启的免费宝箱哟~")
    	return
    elseif self._isAllOpen then
		self:enableTouchSwallowTop()
		remote.thunder:thunderBuyAllPreciousRequest(false, nil, false, function(data)
    		self:viewAnimationOutHandler()
		end)
    else
    	app:alert({content = "还有未开启宝箱，是否跳过此步骤？", title = "系统提示", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self:enableTouchSwallowTop()
	    		remote.thunder:thunderBuyAllPreciousRequest(false, nil, false, function(data)
		    		self:viewAnimationOutHandler()
	    		end)
			end
		end}, true, true)
    end
end

function QUIDialogThunderKingMysteriousMany:viewAnimationOutHandler()
	local callback = self._callBackFunc

    self:popSelf()

    if callback then
    	callback()
    end
end

return QUIDialogThunderKingMysteriousMany