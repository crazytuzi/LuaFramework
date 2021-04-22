--
-- Kumo.Wang
-- 资源夺宝主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTreasures = class("QUIDialogTreasures", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QRichText = import("...utils.QRichText")
local QQuickWay = import("...utils.QQuickWay")

local QUIWidgetTreasuresBox = import("..widgets.QUIWidgetTreasuresBox")
local QUIWidgetTreasuresTheme = import("..widgets.QUIWidgetTreasuresTheme")

QUIDialogTreasures.BOX_SPACE_X = 92
QUIDialogTreasures.BOX_SPACE_Y = 90

QUIDialogTreasures.THUNDER_LENGTH = 385

-- QUIDialogTreasures.chained_horizontal_point_list = 2～8;14～20 (包含头尾)
-- QUIDialogTreasures.chained_vertical_point_list = 10～12;22～24 (包含头尾)

--[[
功能流程：
1、初始化
2、选择主题
3、显示三连格特效
4、play，隐藏主题，显示奖励区域
5、转盘滚动
6、停留中奖格子闪烁
7、奖励展示阶段
	{
		a，无雷电：展示奖励（可同时开始另一轮滚动）
		b，有雷电：开始雷电流程
	}
8、结束，隐藏奖励区域，显示主题

雷电流程：
1、源格子播放闪电发射特效
2、源到目标格子闪电链接
3、目标格子闪电受击特效
4、目标格子中奖闪烁
5、奖励展示阶段
	{
		a，无雷电：展示奖励（可同时继续功能流程）
		b，有雷电：开始新的雷电流程
	}
8、结束雷电流程，继续功能流程

三连格细节：
1、三连格中心点不会在雷电上（转角处）
2、每一轮同一个三连格只会触发一次
3、三连格失效，下一轮开始则不会显示（取决于后端radioGrid，给多少显示多少）
4、失效的三连格将会在当前轮结束后补充（前端拉一次MainInfo更新）

轮次：夺宝1次为1轮，夺宝10次为10轮。
]]
function QUIDialogTreasures:ctor(options) 
 	local ccbFile = "ccb/Dialog_Treasures.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerPlayOne", callback = handler(self, self._onTriggerPlayOne)},
	    {ccbCallbackName = "onTriggerPlayTen", callback = handler(self, self._onTriggerPlayTen)},
	    {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
	    {ccbCallbackName = "onTriggerRewards", callback = handler(self, self._onTriggerRewards)},
	}
	QUIDialogTreasures.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = false

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
	
	-- CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    q.setButtonEnableShadow(self._ccbOwner.btn_one)
    q.setButtonEnableShadow(self._ccbOwner.btn_ten)
    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_rewards)

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)
    if self._resourceTreasuresModule then
    	self._resourceTreasuresModule:setActivityClickedToday()
    end

    self._isTestModule = false

	self:_init()	
end

function QUIDialogTreasures:viewDidAppear()
    QUIDialogTreasures.super.viewDidAppear(self)
    self:addBackEvent(false)

    self._preAnimationInterval = CCDirector:sharedDirector():getAnimationInterval()
    -- CCDirector:sharedDirector():setAnimationInterval(1.0 / 60)

    self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogTreasures._onFrame))
    self._root:scheduleUpdate_()

    -- self._appProxy = cc.EventProxy.new(app)
    -- self._appProxy:addEventListener(app.APP_ENTER_BACKGROUND_EVENT, handler(self, self._onAppEvent))
    -- self._appProxy:addEventListener(app.APP_ENTER_FOREGROUND_EVENT, handler(self, self._onAppEvent))

    if self._resourceTreasuresModule then
    	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    	self._activityRoundsEventProxy:addEventListener(self._resourceTreasuresModule.RESOURCE_TREASURES_LOTTERY, handler(self, self._onLotteryHandler))
    	self._activityRoundsEventProxy:addEventListener(self._resourceTreasuresModule.RESOURCE_TREASURES_THEME_UPDATE, handler(self, self._updateThemeHandler))
    	self._activityRoundsEventProxy:addEventListener(self._resourceTreasuresModule.RESOURCE_TREASURES_NEW_DAY, handler(self, self._updateBtnView))

    	self._activityRoundsEventProxy:addEventListener(self._resourceTreasuresModule.RESOURCE_TREASURES_OFFLINE, self:safeHandler(handler(self, self.onTriggerHomeHandler)))
    end
end

function QUIDialogTreasures:viewAnimationOutHandler()
	self:popSelf()
end

function QUIDialogTreasures:viewWillDisappear()
    QUIDialogTreasures.super.viewWillDisappear(self)

	self:removeBackEvent()

    self._root:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self._root:unscheduleUpdate()

    if self._appProxy then
    	self._appProxy:removeAllEventListeners()
    end
    if self._activityRoundsEventProxy then
    	self._activityRoundsEventProxy:removeAllEventListeners()
    end
    if self._preAnimationInterval then
		CCDirector:sharedDirector():setAnimationInterval(self._preAnimationInterval)
	end

	if q.isEmpty(self._boxList) then
		for _, box in ipairs(self._boxList) do
			box:removeAllEventListeners()
		end
	end

	if q.isEmpty(self._themeMenuList) then
		for _, menu in ipairs(self._themeMenuList) do
			menu:removeAllEventListeners()
		end
	end

	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end

	if self._thunderSchedulerList then
		for _, s in ipairs(self._thunderSchedulerList) do
			if s then
				scheduler.unscheduleGlobal(s)
				s = nil
			end
		end
	end

	if self._endScheduler then
		scheduler.unscheduleGlobal(self._endScheduler)
		self._endScheduler = nil
	end
end

function QUIDialogTreasures:resetAll()
	self._allBoxCount = 0
	while true do
		self._allBoxCount = self._allBoxCount + 1
		local node = self._ccbOwner["node_box_"..self._allBoxCount]
		if node then
			node:removeAllChildren()
		else
			self._allBoxCount = self._allBoxCount - 1
			break
		end
	end

	self._ccbOwner.node_chained_effect:removeAllChildren()
	self._ccbOwner.node_chained_effect:setVisible(true)

	self._ccbOwner.node_thunder_effect:removeAllChildren()
	self._ccbOwner.node_thunder_effect:setVisible(true)

	self._ccbOwner.node_rewards_list:removeAllChildren()
	self._ccbOwner.node_rewards:setVisible(false)

	self._ccbOwner.node_theme_1:removeAllChildren()
	self._ccbOwner.node_theme_2:removeAllChildren()
	self._ccbOwner.node_theme:setVisible(true)

	self._ccbOwner.node_free:setVisible(false)
	self._ccbOwner.node_price_one:setVisible(false)
	self._ccbOwner.node_price_ten:setVisible(false)
	self._ccbOwner.node_btn_one:setVisible(true)
	self._ccbOwner.node_btn_ten:setVisible(true)

	self._ccbOwner.tf_countdown_title:setString("幸运秘宝倒计时：")
	self._ccbOwner.tf_countdown_title:setVisible(true)
	self._ccbOwner.tf_countdown:setString("--:--:--")
	self._ccbOwner.tf_countdown:setVisible(true)
	self._ccbOwner.tf_countdown_over:setVisible(false)

	self._ccbOwner.node_bg_effect:removeAllChildren()
	self._ccbOwner.node_bg_effect:setVisible(true)
end

function QUIDialogTreasures:_init()
	self._isInitGride = false
	self._isInitThemeMenu = false

	self._isPlaying = false
	self._isShowing = false

	self._curGrideTheme1 = nil
	self._preGrideTheme1 = nil
	self._curGrideTheme2 = nil
	self._preGrideTheme2 = nil
	self._curMenuTheme1 = nil
	self._curMenuTheme2 = nil

	self._boxList = {}
	self._themeMenuList = {}
	self._thunderSchedulerList = {}

	self:resetAll()
	self:disableTouchSwallowTop()
	if not self._resourceTreasuresModule then return end

	self:_updateCenterView()
	self:_updateGrideView()
	self:_updateChainedView()
	self:_updateBtnView()

	self:_updateCountdown()
	self:_updateHorseRaceLamp()
end

function QUIDialogTreasures:_updateHorseRaceLamp(state, isLoop)
	self._ccbOwner.node_bg_effect:removeAllChildren()
	local fcaEffect = nil
	local isLoop = isLoop == nil and true or isLoop
	if state then
		fcaEffect = QUIWidgetFcaAnimation.new("fca/paomadeng"..state, "res")
		fcaEffect:setEndCallback(function() 
			if self:safeCheck() then
				if self._isPlaying then
					self:_updateHorseRaceLamp(5)
				else
					self:_updateHorseRaceLamp()
				end
			end
		end)
	else
		fcaEffect = QUIWidgetFcaAnimation.new("fca/paomadeng4", "res")
		-- fcaEffect:setEndCallback(function() end)
	end

	if fcaEffect then
		fcaEffect:playAnimation("animation", isLoop)
		self._ccbOwner.node_bg_effect:addChild(fcaEffect)
	end
end

function QUIDialogTreasures:_updateThemeHandler()
	self._isInitGride = false
	self._isInitThemeMenu = false
	self._boxList = {}
	self._themeMenuList = {}

	local index = 1
	while true do
		local node = self._ccbOwner["node_box_"..index]
		if node then
			node:removeAllChildren()
			index = index + 1
		else
			break
		end
	end

	self._ccbOwner.node_chained_effect:removeAllChildren()
	self._ccbOwner.node_chained_effect:setVisible(true)

	self._ccbOwner.node_theme_1:removeAllChildren()
	self._ccbOwner.node_theme_2:removeAllChildren()
	self._ccbOwner.node_theme:setVisible(true)

	self:disableTouchSwallowTop()
	if not self._resourceTreasuresModule then return end

	self:_updateCenterView()
	self:_updateGrideView()
	self:_updateChainedView()

	self:_updateHorseRaceLamp()
end

function QUIDialogTreasures:_updateCountdown()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	local isInTime, timeStr = self._resourceTreasuresModule:getCountdown()
	if isInTime then
		self._ccbOwner.tf_countdown:setString(timeStr)
		self._ccbOwner.tf_countdown_title:setVisible(true)
		self._ccbOwner.tf_countdown:setVisible(true)
		self._ccbOwner.tf_countdown_over:setVisible(false)
	else
		self._ccbOwner.tf_countdown_title:setVisible(false)
		self._ccbOwner.tf_countdown:setVisible(false)
		self._ccbOwner.tf_countdown_over:setVisible(true)
		return
	end

	self._countdownSchedule = scheduler.scheduleGlobal(function()
		if self:safeCheck() then
			self:_updateCountdown()
		end
	end, 1)
end

function QUIDialogTreasures:_updateGrideView()
	print("[Kumo] QUIDialogTreasures:_updateGrideView() self._allBoxCount = ", self._allBoxCount, self._isInitGride)
	if not self._isInitGride then
		for i = 1, self._allBoxCount, 1 do
			local node = self._ccbOwner["node_box_"..i]
			self._boxList[i] = QUIWidgetTreasuresBox.new({index = i})
			self._boxList[i]:addEventListener(QUIWidgetTreasuresBox.EVENT_LIGHT_UP_END, handler(self, self._onLightUpEndHandler))
			self._boxList[i]:addEventListener(QUIWidgetTreasuresBox.EVENT_TWINKLE_END, handler(self, self._onTwinkleEndHandler))
			self._boxList[i]:addEventListener(QUIWidgetTreasuresBox.EVENT_BONUS_TWINKLE_END, handler(self, self._onBonusTwinkleEndHandler))
			self._boxList[i]:setPromptIsOpen(true)
			-- self._boxList[i]:initGLLayer()
			if node then
				if self._resourceTreasuresModule:isBonusGrideByGrideIndex(i) then
					print("闪电格: ", i)
					self._boxList[i]:setBonus()
				elseif self._resourceTreasuresModule:isTokenGrideByGrideIndex(i) then 
					print("钻石格: ", i)
					local _, mapId = self._resourceTreasuresModule:isTokenGrideByGrideIndex(i)
					local mapConfig = self._resourceTreasuresModule:getMapConfigByThemeId(mapId or 2)
					for _, config in pairs(mapConfig) do
						if config.index == i then
							self:_updateBox(config)
							break
						end
					end
				elseif self._resourceTreasuresModule:isSeniorGrideByGrideIndex(i) then 
					self._boxList[i]:setSeniorCard()
				elseif self._resourceTreasuresModule:isPrimaryGrideByGrideIndex(i) then
					self._boxList[i]:setPrimaryCard()
				end 

				node:addChild(self._boxList[i])
			end
		end
		self._isInitGride = true
	end

	print("[1]", self._curGrideTheme1, self._resourceTreasuresModule.theme1)
	if self._resourceTreasuresModule.theme1 and self._resourceTreasuresModule.theme1 ~= 0 then
		if self._curGrideTheme1 ~= self._resourceTreasuresModule.theme1 then
			print("change")
			self._preGrideTheme1 = self._curGrideTheme1
			self._curGrideTheme1 = self._resourceTreasuresModule.theme1
			local mapConfig = self._resourceTreasuresModule:getMapConfigByThemeId(self._curGrideTheme1)
			-- QKumo(mapConfig)
			if not q.isEmpty(mapConfig) then
				for _, config in pairs(mapConfig) do
					if not (self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) or self._resourceTreasuresModule:isTokenGrideByGrideIndex(config.index)) then 
						self:_changeGrideAction(config.index, self._preGrideTheme1 == nil, function()
							if self:safeCheck() then
								self:_updateBox(config)
							end
						end)
					end
				end
			end
		else
			print("normal")
			self._curGrideTheme1 = self._resourceTreasuresModule.theme1
			local mapConfig = self._resourceTreasuresModule:getMapConfigByThemeId(self._curGrideTheme1)
			if not q.isEmpty(mapConfig) then
				for _, config in pairs(mapConfig) do
					if not (self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) or self._resourceTreasuresModule:isTokenGrideByGrideIndex(config.index)) then 
						self:_updateBox(config)
					end
				end
			end
		end
	end

	print("[2]", self._curGrideTheme2, self._resourceTreasuresModule.theme2)
	if self._resourceTreasuresModule.theme2 and self._resourceTreasuresModule.theme2 ~= 0 then
		if self._curGrideTheme2 ~= self._resourceTreasuresModule.theme2 then
			print("change")
			self._preGrideTheme2 = self._curGrideTheme2 
			self._curGrideTheme2 = self._resourceTreasuresModule.theme2
			local mapConfig = self._resourceTreasuresModule:getMapConfigByThemeId(self._curGrideTheme2)
			if not q.isEmpty(mapConfig) then
				for _, config in pairs(mapConfig) do
					if not (self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) or self._resourceTreasuresModule:isTokenGrideByGrideIndex(config.index)) then 
						self:_changeGrideAction(config.index, self._preGrideTheme2 == nil, function()
							if self:safeCheck() then
								self:_updateBox(config)
							end
						end)
					end
				end
			end
		else
			print("normal")
			self._curGrideTheme2 = self._resourceTreasuresModule.theme2
			local mapConfig = self._resourceTreasuresModule:getMapConfigByThemeId(self._curGrideTheme2)
			if not q.isEmpty(mapConfig) then
				for _, config in pairs(mapConfig) do
					if not (self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) or self._resourceTreasuresModule:isTokenGrideByGrideIndex(config.index)) then 
						self:_updateBox(config)
					end
				end
			end
		end
	end
end

function QUIDialogTreasures:_changeGrideAction(index, isInit, callback)
	local node = self._ccbOwner["node_box_"..index]
	if node then
		local time = 0.3
		
		local turnActions1 = CCArray:create() -- 往右翻到垂直或往左翻到垂直
		turnActions1:addObject(CCSkewTo:create(time, -2, -2))
		turnActions1:addObject(CCScaleTo:create(time, 0, 1))

		local turnActions2 = CCArray:create() -- 往右垂直到平铺翻
		turnActions2:addObject(CCSkewTo:create(time, 0, 0))
		turnActions2:addObject(CCScaleTo:create(time, -1, 1))

		local turnActions3 = CCArray:create() -- 往左垂直到平铺翻
		turnActions3:addObject(CCSkewTo:create(time, 0, 0))
		turnActions3:addObject(CCScaleTo:create(time, 1, 1))


		local actions = CCArray:create()
		if not isInit then
			-- 正面翻到背面
			actions:addObject(CCSpawn:create(turnActions1))
			actions:addObject(CCCallFunc:create(function() 
		    		if self:safeCheck() then
	    				if self._boxList[index] then
			    			if self._resourceTreasuresModule:isSeniorGrideByGrideIndex(index) then 
								self._boxList[index]:setSeniorCard(-1)
							elseif self._resourceTreasuresModule:isPrimaryGrideByGrideIndex(index) then
								self._boxList[index]:setPrimaryCard(-1)
							end 
						end
		    		end
				end))
			actions:addObject(CCSpawn:create(turnActions2))
			-- actions:addObject(CCDelayTime:create(time * 2))
		end

		-- 背面翻到正面
		actions:addObject(CCSpawn:create(turnActions1))
		actions:addObject(CCCallFunc:create(function() 
	    		if self:safeCheck() then
	    			if callback then
    					callback()
    				end
	    		end
			end))
		actions:addObject(CCSpawn:create(turnActions3))
		
		node:runAction(CCSequence:create(actions))
	else
		if callback then
			callback()
		end
	end
end

function QUIDialogTreasures:_updateBox(config)
	if q.isEmpty(config) then return end
	if not self._boxList[tonumber(config.index)] then
		print("[Kumo ERROR:QUIDialogTreasures:_updateBox()] not box!")
		return 
	end
	if config.item_info then
		if self._isTestModule then
			if self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) then
				app.tip:floatTip("第"..config.index.."个格子应该是雷电格子，请检查treasure_map量表配置。")
			end
		end
		local tbl = string.split(config.item_info, "^")
		if self._isTestModule then
			if self._resourceTreasuresModule:isTokenGrideByGrideIndex(config.index) and tbl[1] ~= "token" then
				app.tip:floatTip("第"..config.index.."个格子应该是钻石格子，请检查treasure_map量表配置。")
			end
		end
		if tonumber(tbl[1]) then
			self._boxList[tonumber(config.index)]:setGoodsInfo(tbl[1], ITEM_TYPE.ITEM, tonumber(tbl[2]), false, config.color)
		else
			self._boxList[tonumber(config.index)]:setGoodsInfo(nil, tbl[1], tonumber(tbl[2]), false, config.color)
		end
	else
		if self._resourceTreasuresModule:isBonusGrideByGrideIndex(config.index) then
			-- 显示雷电格子
			self._boxList[tonumber(config.index)]:setBonus()
		else
			if self._isTestModule then
				app.tip:floatTip("第"..config.index.."个格子在treasure_map量表里缺少item_info字段。")
			end
			print("[Kumo] Not found 'item_info' in 'treasure_map' config.")
		end
	end
	-- self._boxList[tonumber(config.index)]:initGLLayer()
end

function QUIDialogTreasures:_updateCenterView()
	if self._isPlaying then
		-- 转盘滚动中，显示奖励栏
		self._ccbOwner.node_theme:setVisible(false)
		self._ccbOwner.node_rewards:setVisible(true)
	else
		-- 转盘禁止中，显示主题栏
		self._ccbOwner.node_theme:setVisible(true)
		self._ccbOwner.node_rewards:setVisible(false)
		if not self._isInitThemeMenu then
			for i = 1, 2, 1 do
				local node = self._ccbOwner["node_theme_"..i]
				self._themeMenuList[i] = QUIWidgetTreasuresTheme.new({themeType = i})
				self._themeMenuList[i]:addEventListener(QUIWidgetTreasuresTheme.EVENT_CLICK, handler(self, self._onChooseThemeHandler))
				if node then
					node:addChild(self._themeMenuList[i])
				end
			end
			self._isInitThemeMenu = true
		end

		if self._resourceTreasuresModule.theme1 and self._resourceTreasuresModule.theme1 ~= 0 then
			self._curMenuTheme1 = self._resourceTreasuresModule.theme1
			local themeConfigs = db:getStaticByName("treasure_theme")
			if not q.isEmpty(themeConfigs) and themeConfigs[tostring(self._curMenuTheme1)] then
				local config = themeConfigs[tostring(self._curMenuTheme1)]
				if config and config.icon then
					self._themeMenuList[1]:setItemIcon(config.icon)
					-- self._themeMenuList[1]:setThemeName(config.name)
				end
			end
		end

		if self._resourceTreasuresModule.theme2 and self._resourceTreasuresModule.theme2 ~= 0 then
			self._curMenuTheme2 = self._resourceTreasuresModule.theme2
			local themeConfigs = db:getStaticByName("treasure_theme")
			if not q.isEmpty(themeConfigs) and themeConfigs[tostring(self._curMenuTheme2)] then
				local config = themeConfigs[tostring(self._curMenuTheme2)]
				if config and config.icon then
					self._themeMenuList[2]:setItemIcon(config.icon)
					-- self._themeMenuList[2]:setThemeName(config.name)
				end
			end
		end
	end
end

-- QUIDialogTreasures.chained_horizontal_point_list = 2～8;14～20 (包含头尾)
-- QUIDialogTreasures.chained_vertical_point_list = 10～12;22～24 (包含头尾)
function QUIDialogTreasures:_updateChainedView()
	if not self._resourceTreasuresModule.theme1 or self._resourceTreasuresModule.theme1 == 0 or not self._resourceTreasuresModule.theme2 or self._resourceTreasuresModule.theme2 == 0 then
		self._ccbOwner.node_chained_effect:removeAllChildren()
	else
		if q.isEmpty(self._resourceTreasuresModule.radioGrid) then
			self._ccbOwner.node_chained_effect:removeAllChildren()
		else
			self._ccbOwner.node_chained_effect:removeAllChildren()
			for _, index in ipairs(self._resourceTreasuresModule.radioGrid) do
				if (index >= 2 and index <= 8) or (index >= 14 and index <= 20) then
					-- 横向
					-- print("横向", index)
					local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_zydb_nihongdeng_effect", "res")
					fcaEffect:setScale(1)
					fcaEffect:setRotation(0)
					local pos = ccp(self._ccbOwner["node_box_"..index]:getPosition())
					fcaEffect:setPosition(pos)
					print(index, pos.x, pos.y)
					fcaEffect:playAnimation("animation", true)
					self._ccbOwner.node_chained_effect:addChild(fcaEffect)
				elseif (index >= 10 and index <= 12) or (index >= 22 and index <= 24) then
					-- 纵向
					-- print("纵向", index)
					local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_zydb_nihongdeng_effect", "res")
					fcaEffect:setScaleX(0.95)
					fcaEffect:setScaleY(1)
					fcaEffect:setRotation(90)
					local pos = ccp(self._ccbOwner["node_box_"..index]:getPosition())
					fcaEffect:setPosition(pos)
					print(index, pos.x, pos.y)
					fcaEffect:playAnimation("animation", true)
					self._ccbOwner.node_chained_effect:addChild(fcaEffect)
				end
			end
		end
	end
end

function QUIDialogTreasures:_updateBtnView()
	if not self._priceItemId or not self._priceItemCount then
		local config = db:getConfigurationValue("treasure_cost")
		local tbl = string.split(config, ",")
	    if not q.isEmpty(tbl) then
	        self._priceItemId = tbl[1]
	        self._priceItemCount = tonumber(tbl[2])
	    end
   	end

   	local itemConfig = db:getItemByID(self._priceItemId)
   	local haveNum = remote.items:getItemsNumByID(self._priceItemId)
   	if not q.isEmpty(itemConfig) then
		if self._resourceTreasuresModule.free then
			self._ccbOwner.node_free:setVisible(true)
			self._ccbOwner.node_price_one:setVisible(false)
		else
			self._ccbOwner.node_free:setVisible(false)
			self._ccbOwner.node_price_one:setVisible(true)
			if not QSetDisplayFrameByPath(self._ccbOwner.sp_price_one, itemConfig.icon_1 or itemConfig.icon) then
				QSetDisplaySpriteByPath(self._ccbOwner.sp_price_one, itemConfig.icon_1 or itemConfig.icon)
			end
			self._ccbOwner.tf_price_one:setString(self._priceItemCount.." / "..haveNum)
		end

		if not QSetDisplayFrameByPath(self._ccbOwner.sp_price_ten, itemConfig.icon_1 or itemConfig.icon) then
			QSetDisplaySpriteByPath(self._ccbOwner.sp_price_ten, itemConfig.icon_1 or itemConfig.icon)
		end
		self._ccbOwner.tf_price_ten:setString((self._priceItemCount * 10).." / "..haveNum)
		self._ccbOwner.node_price_ten:setVisible(true)
	end
end

function QUIDialogTreasures:_onChooseThemeHandler(event)
	if self:safeCheck() then
		if not self._resourceTreasuresModule.isActivityNotEnd then
			app.tip:floatTip("活动已结束")
			return
		end

		if event.themeType then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasuresSelectTheme", 
				options = {themeType = event.themeType}})
		end
	end
end

function QUIDialogTreasures:_playEnding(event)
	if not event or event.name == "ended" then
		if event and (not self._lastSaveTime or q.serverTime() - self._lastSaveTime > 1) then
			self._lastSaveTime = q.serverTime()
			return
		end

		self._isPlaying = false
		self._isShowing = false
		self._lastSaveTime = nil
		local awards = self._resourceTreasuresModule.prizes or {}
		local playCount = #self._resourceTreasuresModule.lotteryInfo
		-- for _, info in ipairs(self._resourceTreasuresModule.prizes) do
		-- 	-- 获取所有奖励
		-- 	if info.type == "ITEM" then
		-- 		table.insert(awards, {id = info.id, type = ITEM_TYPE.ITEM, count = info.count})
		-- 	else
		-- 		table.insert(awards, {id = nil, type = info.type, count = info.count})
		-- 	end
		-- end

		self:_resetLotteryData()

		local callback = function(count)
			if self:safeCheck() then
				if count == 1 then
					self:_onTriggerPlayOne()
				elseif count == 10 then
					self:_onTriggerPlayTen()
				end
			end
		end

		if self._resourceTreasuresModule then
			if not self._resourceTreasuresModule.isActivityNotEnd then
				self:_updateThemeHandler()
				app.tip:floatTip("活动已结束")
			else
				self._resourceTreasuresModule:treasureMainInfoRequest(function()
					if self:safeCheck() then
						self:_updateThemeHandler()
					end
				end)	
			end
		end
		if not q.isEmpty(awards) then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasuresEnding", 
				options = {awards = awards, playCount = playCount, callback = callback}})
			self._resourceTreasuresModule.prizes = {}
		end
	end
end

function QUIDialogTreasures:_onTriggerPlayOne()
	app.sound:playSound("common_small")
	if self._isPlaying then
		self:_playEnding()
		return
	end
	if self._isPlaying or self._isShowing then return end

	if not self._resourceTreasuresModule.isActivityNotEnd then
		app.tip:floatTip("活动已结束")
		return
	end

	if not self._resourceTreasuresModule.theme1 or self._resourceTreasuresModule.theme1 == 0 or not self._resourceTreasuresModule.theme2 or self._resourceTreasuresModule.theme2 == 0 then
		app.tip:floatTip("尚未确定主题")
		return
	end

	local haveNum = remote.items:getItemsNumByID(self._priceItemId)
	if not self._resourceTreasuresModule.free and haveNum < self._priceItemCount then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._priceItemId)
		return
	end

	if self._resourceTreasuresModule then
		self._resourceTreasuresModule:treasureLotteryRequest(1)
	end
end

function QUIDialogTreasures:_onTriggerPlayTen()
	app.sound:playSound("common_small")
	if self._isPlaying then
		self:_playEnding()
		return
	end
	if self._isPlaying or self._isShowing then return end

	if not self._resourceTreasuresModule.isActivityNotEnd then
		app.tip:floatTip("活动已结束")
		return
	end

	if not self._resourceTreasuresModule.theme1 or self._resourceTreasuresModule.theme1 == 0 or not self._resourceTreasuresModule.theme2 or self._resourceTreasuresModule.theme2 == 0 then
		app.tip:floatTip("尚未确定主题")
		return
	end

	local haveNum = remote.items:getItemsNumByID(self._priceItemId)
	if haveNum < self._priceItemCount * 10 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._priceItemId)
		return
	end

	if self._resourceTreasuresModule then
		self._resourceTreasuresModule:treasureLotteryRequest(10)
	end
end

function QUIDialogTreasures:_onLotteryHandler(event)
	if self:safeCheck() then
		self:_updateBtnView()

		self._curRoundIndex = 1
		self._rewardBoxDic = {}
		self._rewardBoxIndex = 1
		self._stepInterval = self._resourceTreasuresModule.STEP_INTERVAL
		self._ccbOwner.node_rewards_list:removeAllChildren()
		-- 更新下一步的数据信息
		self:_updateStepInfo()
	end
end

function QUIDialogTreasures:_resetLotteryData()
	if self._thunderSchedulerList then
		for _, s in ipairs(self._thunderSchedulerList) do
			if s then
				scheduler.unscheduleGlobal(s)
				s = nil
			end
		end
	end
	self._thunderSchedulerList = {}
end

function QUIDialogTreasures:_updateStepInfo()
	local roundInfo = self._resourceTreasuresModule.lotteryInfo and self._resourceTreasuresModule.lotteryInfo[self._curRoundIndex]
	if roundInfo then
		local preRoundInfo = self._resourceTreasuresModule.lotteryInfo and self._resourceTreasuresModule.lotteryInfo[self._curRoundIndex - 1]
		self._startGrideIndex = preRoundInfo and preRoundInfo.grid or 1
		self._endGrideIndex = roundInfo.grid
		self._rewardStr = roundInfo.reward
		self._lotteryInfoList = roundInfo.lotteryInfoList
		self._resourceTreasuresModule.radioGrid = roundInfo.radioGrid
		self:_updateChainedView()

		self._curTime = 0
		self._step = 0 -- 每轮累计步数
		self._curGrideIndex = self._startGrideIndex

		print("[Kumo] start index : ", self._curRoundIndex, self._startGrideIndex, self._endGrideIndex)

		self._isShowing = false -- 每一轮展示更新中间奖励显示的阶段
		self:_lightUpGride()

		self._isPlaying = true -- 轮盘转动中
		self:enableTouchSwallowTop()
		self:_updateCenterView()

		-- self._ccbOwner.tf_info:setString("正在进行 "..self._curRoundIndex.."/"..#self._resourceTreasuresModule.lotteryInfo.." 次夺宝")
		self._ccbOwner.tf_info:setString(self._curRoundIndex.."/"..#self._resourceTreasuresModule.lotteryInfo)
	else
		if self._endScheduler then
			scheduler.unscheduleGlobal(self._endScheduler)
			self._endScheduler = nil
		end
		self._endScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				if self._endScheduler then
					scheduler.unscheduleGlobal(self._endScheduler)
					self._endScheduler = nil
				end
				self:_playEnding()
			end
		end, 0.5)
	end
end

-- 点亮当前的格子，之后格子自己衰减熄灭
function QUIDialogTreasures:_lightUpGride()
	self._curGrideIndex = self._curGrideIndex + 1
	if self._curGrideIndex > self._allBoxCount then
		self._curGrideIndex = 1
	end
	self._step = self._step + 1
	if (self._curTime > 1 or self._step > self._allBoxCount) and self._curGrideIndex == self._endGrideIndex then
		self._isShowing = true
	end
	if self._isShowing then
		self._curGrideIndex = self._endGrideIndex
	end
	self._boxList[self._curGrideIndex]:lightUp()
end

function QUIDialogTreasures:_onLightUpEndHandler(event)
	-- print("QUIDialogTreasures:_onLightUpEndHandler() ", self._resourceTreasuresModule.radioGrid, event.index, self._endGrideIndex, self._isShowing)
	if self:safeCheck() then
		if self._isShowing and event.index == self._endGrideIndex then
			self._isShowing = true
			if not q.isEmpty(self._resourceTreasuresModule.radioGrid) then
				for i, grideId in ipairs(self._resourceTreasuresModule.radioGrid) do
					local minId = grideId - 1
					local maxId = grideId + 1
					if grideId == self._allBoxCount then maxId = 1 end
					if self._endGrideIndex == minId or self._endGrideIndex == grideId or self._endGrideIndex == maxId then
						self._boxList[minId]:twinkle()
						self._boxList[grideId]:twinkle(false, true)
						self._boxList[maxId]:twinkle()
						self._curRadioGrideId = grideId
						table.remove(self._resourceTreasuresModule.radioGrid, i)
						return
					end
				end
			end
			-- if self._resourceTreasuresModule:isBonusGrideByGrideIndex(self._endGrideIndex) then
			-- 	self:_onTwinkleEndHandler({isEventBox = true, index = self._endGrideIndex})
			-- else
				self._boxList[self._endGrideIndex]:twinkle(false, true)
			-- end
		end
	end
end

function QUIDialogTreasures:_onTwinkleEndHandler(event)
	if self:safeCheck() then
		if self._isShowing and event.isEventBox then
			print("QUIDialogTreasures:_onTwinkleEndHandler()")
			if self._curRadioGrideId then
				local minId = self._curRadioGrideId - 1
				local maxId = self._curRadioGrideId + 1
				if self._curRadioGrideId == self._allBoxCount then maxId = 1 end
				if self._resourceTreasuresModule:isBonusGrideByGrideIndex(minId)
					or self._resourceTreasuresModule:isBonusGrideByGrideIndex(self._curRadioGrideId)
					or self._resourceTreasuresModule:isBonusGrideByGrideIndex(maxId) then
					self:_updateRewards()
					self:_onBonus()
					return
				end
			end
			print("event.index = ", event.index, self._resourceTreasuresModule:isBonusGrideByGrideIndex(event.index))
			if self._resourceTreasuresModule:isBonusGrideByGrideIndex(event.index) then
				self:_onBonus()
			else
				self:_updateRewards()
				self:_nextRound()
			end
		end
	end
end

function QUIDialogTreasures:_nextRound()
	print("QUIDialogTreasures:_nextRound() ", self._curRoundIndex)
	self._curRoundIndex = self._curRoundIndex + 1
	self:_updateStepInfo()
end

function QUIDialogTreasures:_updateRewards()
	print("QUIDialogTreasures:_updateRewards()")
	self._curRadioGrideId = nil

	self:_updateChainedView()
	
	local tbl = string.split(self._rewardStr, ";")
	if not q.isEmpty(tbl) then
		for _, itemStr in ipairs(tbl) do
			if itemStr ~= "nil" and itemStr ~= "" then
				local itemTbl = string.split(itemStr, "^")
				if not q.isEmpty(itemTbl) then
					local key = tostring(itemTbl[1])
					if not self._rewardBoxDic[key] then
						self._rewardBoxDic[key] = QUIWidgetTreasuresBox.new({index = self._rewardBoxIndex})
						if tonumber(itemTbl[1]) then
							self._rewardBoxDic[key]:setGoodsInfo(itemTbl[1], ITEM_TYPE.ITEM, tonumber(itemTbl[2]))
					    else
					    	self._rewardBoxDic[key]:setGoodsInfo(nil, itemTbl[1], tonumber(itemTbl[2]))
					    end
						self._ccbOwner.node_rewards_list:addChild(self._rewardBoxDic[key])
						self._rewardBoxIndex = self._rewardBoxIndex + 1
					    self:_updateRewardBoxView()
					else
						self._rewardBoxDic[key]:addGoodsNum(tonumber(itemTbl[2]))
					end
				end
			end
		end
	end
end

function QUIDialogTreasures:_updateRewardBoxView()
	if q.isEmpty(self._rewardBoxDic) then return end
	for _, box in pairs(self._rewardBoxDic) do
		local index = box:getIndex()
		local size = box:getContentSize()
		box:setPosition((size.width + 20) * (index - 1), 0)
	end
	self._ccbOwner.node_rewards_list:setPosition(-(self._rewardBoxIndex - 2) * 55, 0)
end

function QUIDialogTreasures:_onBonus()
	print("[Kumo] QUIDialogTreasures:_onBonus()")
	if q.isEmpty(self._lotteryInfoList) then 
		print("[Kumo] No lotteryInfoList in server data.")
		self._isPlaying = false
		self._isShowing = false
		if self._resourceTreasuresModule then
			self._resourceTreasuresModule:treasureMainInfoRequest(function()
				if self:safeCheck() then
					self:_init()
				end
			end)
		end
		return 
	end

	self._bonusData = {}
	table.insert(self._bonusData, {headGrideIndex = self._endGrideIndex, targetGrideList = self._lotteryInfoList})
	self._radioGrideIdList = {}
	self._curBonusRound = 1 -- 雷电可以嵌套，理论上最多有4轮
	self:_updateBonusInfo()
end

-- 开始雷电流程
function QUIDialogTreasures:_updateBonusInfo()
	local findRound = 1
	local findBonusDataByRound
	findBonusDataByRound = function(data, findRound)
		for i, value in pairs(data) do
			print("data : ", i, value.grid)
			local _thisRound = findRound
			if value.lotteryInfoList then
				_thisRound = _thisRound + 1
				print("_thisRound = ", _thisRound, self._curBonusRound)
				if _thisRound == self._curBonusRound then
					print("add")
					if self._resourceTreasuresModule:isBonusGrideByGrideIndex(value.grid) then
						table.insert(self._bonusData, {headGrideIndex = value.grid, targetGrideList = value.lotteryInfoList})
					else
						for _, ids in ipairs(self._radioGrideIdList) do
							local isBreak = false
							for _, id in ipairs(ids) do
								if id == value.grid then
									local _id = self._resourceTreasuresModule:getBonusGrideByIndexList(ids)
									table.insert(self._bonusData, {headGrideIndex = _id, targetGrideList = value.lotteryInfoList})
									isBreak = true
									break
								end
							end
							if isBreak then
								break
							end
						end
					end
				elseif _thisRound < self._curBonusRound then
					findBonusDataByRound(value.lotteryInfoList, _thisRound)
				end
			end
		end
	end
	
	if self._curBonusRound > 1 then
		self._bonusData = {}
		findBonusDataByRound(self._lotteryInfoList, findRound)
	end

	self._allEndBonusCount = 0 --最后打到几个点
	self._endBonusCount = 0
	self._radioGrideIdList = {}

	QKumo(self._bonusData)
	if q.isEmpty(self._bonusData) or q.isEmpty(self._bonusData[1].targetGrideList) then
		-- 雷电流程结束
		self:_nextRound()
	else
		if self._curBonusRound > 1 then
			self:_updateHorseRaceLamp(3, false)
		else
			self:_updateHorseRaceLamp(2, false)
		end
		self._rewardStr = ""
		for _, data in ipairs(self._bonusData) do
			for _, info in ipairs(data.targetGrideList) do
				if info.reward and info.reward ~= "" then
					self._rewardStr = self._rewardStr..info.reward
				end
			end
		end
		
		self:_onThunderEffect()
	end
end

function QUIDialogTreasures:_onThunderEffect()
	print("QUIDialogTreasures:_onThunderEffect()")
	for _, data in ipairs(self._bonusData) do
		local headIndex = data.headGrideIndex
		local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_zydb_shandiantop_effect", "res")
		fcaEffect:setScale(0.2)
		local headNode = self._ccbOwner["node_box_"..headIndex]
		if headNode then
			fcaEffect:playAnimation("animation", false)
			fcaEffect:setEndCallback(function()
				fcaEffect:removeFromParent()
				fcaEffect = nil
				if self:safeCheck() then
					self:_radiateThunderEffect(headNode, data)
				end
			end)
			headNode:addChild(fcaEffect)
		end
	end
end

function QUIDialogTreasures:_radiateThunderEffect(headNode, data)
	print("QUIDialogTreasures:_radiateThunderEffect()")

	self._allEndBonusCount = self._allEndBonusCount + #data.targetGrideList

	for _, info in ipairs(data.targetGrideList) do
		local targetNode = self._ccbOwner["node_box_"..info.grid]
		if targetNode then
			local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_zydb_shandian_effect", "res")
			-- 雷电动画默认朝右
			local headX, headY = headNode:getPosition()
			-- print("head ", headX, headY)
			local targetX, targetY = targetNode:getPosition()
			-- print("target ", targetX, targetY)
			local rotation = math.deg(math.atan((targetX - headX) / (targetY - headY)))
			-- print("[1]", rotation)
			if headY > targetY then
				rotation = rotation + 90
			else
				if headX <= targetX then
					rotation = rotation - 90
				else
					rotation = rotation - 90
				end
			end
			-- print("[2]", rotation)
			fcaEffect:setRotation(rotation)

			local a = targetX > headX and math.abs(targetX - headX) or math.abs(headX - targetX)
			local b = targetY > headY and math.abs(targetY - headY) or math.abs(headY - targetY)
			local length = math.sqrt(a * a + b * b)
			local scale = length / self.THUNDER_LENGTH
			-- print(scale)
			fcaEffect:setScaleX(scale)

			fcaEffect:playAnimation("animation", false)
			fcaEffect:setEndCallback(function()
				print("Thunder end index = ", info.grid)
				-- local node = fcaEffect:getParent()
				fcaEffect:removeFromParent()
				-- node:removeFromParent()
				fcaEffect = nil
				-- if self:safeCheck() then
				-- 	self:_thunderHitEffect(targetNode, info.grid)
				-- end
			end)

			local pos = ccp(headNode:getPosition())
			-- local thunderNode = CCNode:create()
			-- thunderNode:setPosition(pos)
			-- self._ccbOwner.node_thunder_effect:addChild(thunderNode)
			-- thunderNode:addChild(fcaEffect)
			fcaEffect:setPosition(pos)
			self._ccbOwner.node_thunder_effect:setPosition(0, 0)
			self._ccbOwner.node_thunder_effect:addChild(fcaEffect)

			local scheduler = scheduler.performWithDelayGlobal(function ()
				if self:safeCheck() then
					self:_thunderHitEffect(targetNode, info.grid)
				end
			end, 0)
			table.insert(self._thunderSchedulerList, scheduler)
		end
	end
end

function QUIDialogTreasures:_thunderHitEffect(targetNode, taretGrideId)
	print("QUIDialogTreasures:_thunderHitEffect()")
	local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_zydb_shandianhit_effect", "res")
	fcaEffect:setScale(1)
	fcaEffect:playAnimation("animation", false)
	fcaEffect:setEndCallback(function()
		fcaEffect:removeFromParent()
		fcaEffect = nil
		-- if self:safeCheck() then
		-- 	self:_twinkle(taretGrideId)
		-- end
	end)
	targetNode:addChild(fcaEffect)

	self:_twinkle(taretGrideId)
end

function QUIDialogTreasures:_twinkle(taretGrideId)
	print("QUIDialogTreasures:_twinkle()")
	if self._isShowing then
		self._endBonusCount = self._endBonusCount + 1
		local taretGrideId = tonumber(taretGrideId)
		if not q.isEmpty(self._resourceTreasuresModule.radioGrid) then
			for i, grideId in ipairs(self._resourceTreasuresModule.radioGrid) do
				local minId = grideId - 1
				local maxId = grideId + 1
				if grideId == self._allBoxCount then maxId = 1 end
				if taretGrideId == minId or taretGrideId == grideId or taretGrideId == maxId then
					self._boxList[minId]:twinkle(true)
					self._boxList[grideId]:twinkle(true, true, self._curBonusRound)
					self._boxList[maxId]:twinkle(true)
					-- self._curRadioGrideId = grideId
					table.insert(self._radioGrideIdList, {minId, grideId, maxId})
					table.remove(self._resourceTreasuresModule.radioGrid, i)

					if self._endBonusCount == self._allEndBonusCount then
						self:_updateRewards()
						self:_nextThunderRound()
					end
					return
				end
			end
		end

		-- if self._resourceTreasuresModule:isBonusGrideByGrideIndex(taretGrideId) then
		-- 	self:_onBonusTwinkleEndHandler({isEventBox = true, index = taretGrideId, bonusRound = self._curBonusRound})
		-- else
			self._boxList[taretGrideId]:twinkle(true, true, self._curBonusRound)
		-- end

		if self._endBonusCount == self._allEndBonusCount then
			self:_updateRewards()
			self:_nextThunderRound()
		end
	end
end

function QUIDialogTreasures:_onBonusTwinkleEndHandler(event)
	-- if self:safeCheck() then
	-- 	if self._isShowing then
	-- 		if event.isEventBox and event.bonusRound == self._curBonusRound then
	-- 			print("QUIDialogTreasures:_onBonusTwinkleEndHandler()", event.index)
	-- 			self:_updateRewards()
	-- 			self:_nextThunderRound()
	-- 		end
	-- 	end
	-- end
end

function QUIDialogTreasures:_nextThunderRound()
	print("QUIDialogTreasures:_nextThunderRound() ", self._curBonusRound)
	self._curBonusRound = self._curBonusRound + 1
	self:_updateBonusInfo()
end

function QUIDialogTreasures:_onFrame(dt)
	if not self._isPlaying or self._isShowing then return end

	self._curTime = self._curTime + dt

	if self._curTime > self._stepInterval * self._step then
		self:_lightUpGride()
	end
end

-- function QUIDialogTreasures:_onAppEvent(e)
	-- if e.name == app.APP_ENTER_BACKGROUND_EVENT then
	-- 	if self:safeCheck() then
	-- 		if self._appScheduler then
	-- 			scheduler.unscheduleGlobal(self._appScheduler)
	-- 			self._appScheduler = nil
	-- 		end
	-- 		self:_onPause()
	-- 	end
	-- elseif e.name == app.APP_ENTER_FOREGROUND_EVENT then
	-- 	app.sound:pauseMusic()
	-- 	self._appScheduler = scheduler.performWithDelayGlobal(function()
	-- 		if self:safeCheck() then
	-- 			self._appScheduler = nil
	-- 			if self._pauseDialog and self._pauseDialog._onContinue then
	-- 				self._pauseDialog:_onContinue()
	-- 			else
	-- 				self:_onResume()
	-- 			end
	-- 		end
	-- 	end, 0)
	-- end
-- end

function QUIDialogTreasures:_onTriggerHelp()
	if self._isPlaying then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "help_treasure"}})
end

function QUIDialogTreasures:_onTriggerRewards()
	if self._isPlaying then return end
    app.sound:playSound("common_small")
 --    if not self._resourceTreasuresModule.isActivityNotEnd then
	-- 	app.tip:floatTip("活动已结束")
	-- 	return
	-- end

    if self._resourceTreasuresModule then
		self._resourceTreasuresModule:treasureMainInfoRequest(function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTreasuresRewards"})
		end)
	end
end

function QUIDialogTreasures:onTriggerBackHandler()
	if self._isPlaying then return end
    self:popSelf()
end

--add touch layer at top layer stop touch event
function QUIDialogTreasures:enableTouchSwallowTop()
    if(self:getView() == nil) then return end

    if self._topTouchLayer == nil then
        self._enable = false
        self._topTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
        self._topTouchLayer:setPosition(-display.width/2, -display.height/2)
        self._topTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._topTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._playEnding))
        self._topTouchLayer:setTouchEnabled(true)
        self:getView():addChild(self._topTouchLayer,10000)
    end
end

--remove touch layer at top layer stop touch event
function QUIDialogTreasures:disableTouchSwallowTop()
    if self._topTouchLayer ~= nil then
        self._enable = true
        self._topTouchLayer:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
        self._topTouchLayer:setTouchEnabled(false)
        self._topTouchLayer:removeFromParent()
        self._topTouchLayer = nil
    end
end

return QUIDialogTreasures