--
-- Kumo.Wang
-- 张碧晨主题曲活动预热——主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogZhangbichenPreheatMain = class("QUIDialogZhangbichenPreheatMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QUIWidgetZhangbichenPreheatReward = import("..widgets.QUIWidgetZhangbichenPreheatReward")

function QUIDialogZhangbichenPreheatMain:ctor(options)
	local ccbFile = "ccb/Dialog_Zhangbichen_Preheat.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogZhangbichenPreheatMain.super.ctor(self,ccbFile,callBacks,options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
	self.isAnimation = true

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.topBar then page.topBar:showWithMainPage() end

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	self:_init()
end

function QUIDialogZhangbichenPreheatMain:viewDidAppear()
	QUIDialogZhangbichenPreheatMain.super.viewDidAppear(self)
	self:addBackEvent()

	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.ZHANGBICHEN_PREHEAT_UPDATE, self:safeHandler(handler(self, self._update)))

    if not self._zhangbichenPreheatModel or q.serverTime() > self._zhangbichenPreheatModel.showEndAt then 
    	app.tip:floatTip("活动已结束")
    else
    	self:_update()	
    end
end

function QUIDialogZhangbichenPreheatMain:viewAnimationInHandler()
	if not self._zhangbichenPreheatModel or q.serverTime() > self._zhangbichenPreheatModel.showEndAt then 
        self:_onTriggerClose()
    end
end

function QUIDialogZhangbichenPreheatMain:viewWillDisappear()
  	QUIDialogZhangbichenPreheatMain.super.viewWillDisappear(self)
	self:removeBackEvent()

	self._activityRoundsEventProxy:removeAllEventListeners()
end

function QUIDialogZhangbichenPreheatMain:_resetAll()
	self._ccbOwner.node_rtf_expectation:removeAllChildren()
	self._ccbOwner.node_rtf_tips:removeAllChildren()
	self._ccbOwner.sp_ok_red_tips:setVisible(false)
	self._ccbOwner.node_bar_effect:removeAllChildren()
	self._ccbOwner.node_reward:removeAllChildren()
	self._ccbOwner.sp_zero_day:setVisible(false)
	self._ccbOwner.node_countdown:setVisible(false)
	self._ccbOwner.node_add_effect:removeAllChildren()
	self._ccbOwner.node_info:setPositionY(-63)
	self._ccbOwner.node_reward:setVisible(true)
end

function QUIDialogZhangbichenPreheatMain:_init()
    self:_resetAll()
	self._rewardBox = {}

	self._zhangbichenPreheatModel = remote.activityRounds:getZhangbichenPreheat()
    if self._zhangbichenPreheatModel and self._zhangbichenPreheatModel.isOpen then
    	self._zhangbichenPreheatModel:setActivityClickedToday()
        self._zhangbichenPreheatModel:zhangbichenPreheatMainInfoRequest()
    end

    if self._zhangbichenPreheatModel then 
        local startTimeTbl = q.date("*t", (self._zhangbichenPreheatModel.startAt or 0))
	    local endTimeTbl = q.date("*t", (self._zhangbichenPreheatModel.endAt or 0)) -- 參與期待的結束時間
	    -- local expectTimeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
	    --                                 startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
	    --                                 expectEndTimeTbl.month, expectEndTimeTbl.day, expectEndTimeTbl.hour, expectEndTimeTbl.min)
	    -- local endTimeTbl = q.date("*t", (self._zhangbichenPreheatModel.showEndAt or 0)) -- 整個活動結束時間
	    -- local finalRewardTimeStr = string.format("（%d月%d日瓜分大奖）", endTimeTbl.month, endTimeTbl.day)
	    local timeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
	                                    startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
	                                    endTimeTbl.month, endTimeTbl.day, endTimeTbl.hour, endTimeTbl.min)
	    local richText = QRichText.new({
	            {oType = "font", size = 17, color = COLORS.a, content = "活动时间："},
	            {oType = "font", size = 17, color = COLORS.b, content = timeStr},
	            {oType = "font", size = 17, color = COLORS.a, content = "（开服大于14天的服务器可参与）"},
	        })
	    richText:setAnchorPoint(ccp(0.5, 0.5))
	    self._ccbOwner.node_rtf_tips:addChild(richText)
	    
	    -- 初始化进度条
		if not self._percentBarClippingNode then
			self._totalStencilPosition = self._ccbOwner.sp_progress_bar:getPositionX() -- 这个坐标必须sp_progress_bar节点的锚点为(0, 0.5)
			self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress_bar)
			self._totalStencilWidth = self._ccbOwner.sp_progress_bar:getContentSize().width * self._ccbOwner.sp_progress_bar:getScaleX()
		end

	    local rewardDataList = self._zhangbichenPreheatModel:getRewardDataList()
	    self._maxExpectation = tonumber(rewardDataList[#rewardDataList].expectation)
		for index, data in ipairs(rewardDataList) do
			local box = QUIWidgetZhangbichenPreheatReward.new()
			box:setInfo(data)
			local posX = (self._totalStencilPosition + self._totalStencilWidth) * tonumber(data.expectation) / self._maxExpectation
			box:setPosition(ccp(posX, 0))
			box:addEventListener(QUIWidgetZhangbichenPreheatReward.EVENT_CLICK, self:safeHandler(handler(self, self._onBoxClicked)))
			self._ccbOwner.node_reward:addChild(box)
			self._rewardBox[tostring(data.id)] = box
		end

		
    end
end

function QUIDialogZhangbichenPreheatMain:_update()
    if self._zhangbichenPreheatModel and q.serverTime() <= self._zhangbichenPreheatModel.showEndAt then 
	    local countdownTime = self._zhangbichenPreheatModel:getCountdownTime()
	    local isNow = true
	    if countdownTime and countdownTime > 0 then
		    local countdownNumbers = QResPath("zhangbichenPreheatCountdownNumbers")
		    if countdownNumbers then
		    	local day = math.ceil(countdownTime/1000/DAY)
		    	print("countdown day = ", day)
		    	if day > 0 then
			    	local path = countdownNumbers[day]
			    	if path then
						QSetDisplayFrameByPath(self._ccbOwner.sp_day, path)
					else
						-- app.tip:floatTip("倒计时大于7天，美术资源不足，显示7天")
						QSetDisplayFrameByPath(self._ccbOwner.sp_day, countdownNumbers[#countdownNumbers])
					end
					isNow = false
					self._ccbOwner.node_countdown:setVisible(true)
				end
			end
		end
		if isNow then
			-- self._ccbOwner.sp_zero_day:setVisible(true)
			self._ccbOwner.node_countdown:setVisible(false)
		end

		self._serverInfo = self._zhangbichenPreheatModel:getServerInfo()

		self._ccbOwner.node_rtf_expectation:removeAllChildren()
		local richText = QRichText.new({
	            {oType = "font", size = 24, color = COLORS.b, content = "当前助力值："},
	            {oType = "font", size = 24, color = COLORS.b, content = self._serverInfo.currExpectation or 0},
	            {oType = "font", size = 16, color = COLORS.b, content = "（每整点刷新）"},
	        })
	    richText:setAnchorPoint(ccp(0, 0.5))
	    self._ccbOwner.node_rtf_expectation:addChild(richText)
	    
	    if not self._zhangbichenPreheatModel.isActivityNotEnd then 
	    	self._ccbOwner.node_info:setPositionY(-103)
	    	self._ccbOwner.node_reward:setVisible(false)
	    else
	    	self._ccbOwner.node_info:setPositionY(-63)
	    	self._ccbOwner.node_reward:setVisible(true)

	    	local tbl = {}
			for _, id in ipairs(self._serverInfo.rewardIds or {}) do
				tbl[tostring(id)] = true
			end
			for id, box in pairs(self._rewardBox) do
		    	box:isGet(tbl[tostring(id)])
		    	box:refreshInfo()
		    end
	    end
	    
	    local stencil = self._percentBarClippingNode:getStencil()
	    local curProportion = (tonumber(self._serverInfo.currExpectation) or 0) / self._maxExpectation
	    if curProportion > 1 then curProportion = 1 end
	    stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)

	    if not self._barEffect then
	    	self._barEffect = QUIWidgetFcaAnimation.new("fca/yingfu_jindutiao", "res")
			self._barEffect:playAnimation("animation", true)
			self._ccbOwner.node_bar_effect:addChild(self._barEffect)
	    end
	    local posX = (self._totalStencilPosition + self._totalStencilWidth) * curProportion
	    self._barEffect:setPositionX(posX)

		if self._serverInfo and self._serverInfo.alreadyExpected or not self._zhangbichenPreheatModel.isActivityNotEnd then
			makeNodeFromNormalToGray(self._ccbOwner.btn_ok)
		else
			makeNodeFromGrayToNormal(self._ccbOwner.btn_ok)
		end	
    end
end

function QUIDialogZhangbichenPreheatMain:_onBoxClicked(e)
	if not self._zhangbichenPreheatModel then return end

	self._serverInfo = self._zhangbichenPreheatModel:getServerInfo()
    local rewardIdDic = {}
	for _, id in ipairs(self._serverInfo.rewardIds or {}) do
		rewardIdDic[tostring(id)] = true
	end

	local info = e.info
	if not rewardIdDic[tostring(info.id)] then
		local awards = {}
		local tbl = string.split(info.rewards, "^")
		if tbl and #tbl > 0 then
			local itemId = tonumber(tbl[1])
			local itemCount = tonumber(tbl[2])
			local itemType = ITEM_TYPE.ITEM
			if not itemId then
				itemType = tbl[1]
			end
			table.insert(awards, {id = itemId, typeName = itemType, count = itemCount})
		end

		self._zhangbichenPreheatModel:zhangbichenPreheatGetRewardRequest(info.id, function(data)
				if data and data.prizes then
					awards = {}
					for _, value in ipairs(data.prizes) do 
						table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
					end
				end
		        app:alertAwards({awards = awards, title = "恭喜您获得助力奖励"})
			end)
	end
end

function QUIDialogZhangbichenPreheatMain:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "help_theme_preheat"}})
end

function QUIDialogZhangbichenPreheatMain:_onTriggerOK()
    app.sound:playSound("common_small")
	if not self._zhangbichenPreheatModel then return end

	if not self._zhangbichenPreheatModel.isActivityNotEnd then
		app.tip:floatTip("活动已结束")
		return
	end

	self._serverInfo = self._zhangbichenPreheatModel:getServerInfo()
	if self._serverInfo and self._serverInfo.alreadyExpected then
		app.tip:floatTip("今日已助力")
		return 
	end
	
	self._zhangbichenPreheatModel:zhangbichenPreheatExpectRequest(function()
			if self:safeCheck() then
				self:_showAddAnimation()
			end
		end)
end

function QUIDialogZhangbichenPreheatMain:_showAddAnimation(value)
	if self._effect ~= nil then 
		self._effect:disappear()
		self._effect:removeFromParent()
		self._effect = nil
	end
	local effectName = "effects/Tips_add.ccbi"
	self._ccbOwner.node_add_effect:removeAllChildren()
	self._effect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_add_effect:addChild(self._effect)
	self._effect:playAnimation(effectName, function(ccbOwner)
		ccbOwner.content:setString("+ 1")
	end, function()
    	self._effect:disappear()
    end)
end

function QUIDialogZhangbichenPreheatMain:_onTriggerClose()
	self:playEffectOut()
end

return QUIDialogZhangbichenPreheatMain