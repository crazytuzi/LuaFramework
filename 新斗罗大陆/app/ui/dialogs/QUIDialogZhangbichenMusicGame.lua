--
-- Kumo.Wang
-- zhangbichen主题曲活动——音游主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogZhangbichenMusicGame = class("QUIDialogZhangbichenMusicGame", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")

local QUIWidgetZhangbichenMusicGameIcon = import("..widgets.QUIWidgetZhangbichenMusicGameIcon")
local QUIWidgetZhangbichenReward = import("..widgets.QUIWidgetZhangbichenReward")

function QUIDialogZhangbichenMusicGame:ctor(options) 
 	local ccbFile = "ccb/Dialog_Music_Game_Zhangbichen.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerPause", callback = handler(self, self._onTriggerPause)},
	    {ccbCallbackName = "onTriggerAutoPlay", callback = handler(self, self._onTriggerAutoPlay)},
	    {ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
	    {ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
	    {ccbCallbackName = "onTriggerStatGame", callback = handler(self, self._onTriggerStatGame)},
	    {ccbCallbackName = "onTriggeShop", callback = handler(self, self._onTriggeShop)},
	    {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
	}
	QUIDialogZhangbichenMusicGame.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = false

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.setManyUIVisible then page:setManyUIVisible() end
	if page and page.setScalingVisible then page:setScalingVisible(false) end
	page.topBar:showMusicGamePage()

	-- CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

	-- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- if page then
	--     if page.setAllUIVisible then page:setAllUIVisible(false) end
	--     if page.setScalingVisible then page:setScalingVisible(false) end
	--     if page.topBar then page.topBar:hideAll() end
	-- 	if page.setBackBtnVisible then page:setBackBtnVisible(false) end
	-- 	if page.setHomeBtnVisible then page:setHomeBtnVisible(false) end
	-- end

    q.setButtonEnableShadow(self._ccbOwner.btn_pause)
    q.setButtonEnableShadow(self._ccbOwner.btn_goto)
    q.setButtonEnableShadow(self._ccbOwner.btn_shop)
    q.setButtonEnableShadow(self._ccbOwner.btn_rule)

    self._oldAvatarPosY = self._ccbOwner.node_avatar:getPositionY()

	self._isEnd = false
	self._zhangbichenModel = remote.activityRounds:getZhangbichen()
	if not self._zhangbichenModel then
		self._isEnd = true
		return
	end
    self._rewardBox = {}
    -- self._ccbOwner.tf_num:setString("0 （音浪值整点刷新）")

end

function QUIDialogZhangbichenMusicGame:viewAnimationInHandler()
    self:_initStaffView()
end

function QUIDialogZhangbichenMusicGame:viewDidAppear()
    QUIDialogZhangbichenMusicGame.super.viewDidAppear(self)
    self:addBackEvent(true)

    self._preAnimationInterval = CCDirector:sharedDirector():getAnimationInterval()
    -- CCDirector:sharedDirector():setAnimationInterval(1.0 / 60)
    self._musicVolume = audio.getMusicVolume()

    self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogZhangbichenMusicGame._onFrame))
    self._root:scheduleUpdate_()

    self._appProxy = cc.EventProxy.new(app)
    self._appProxy:addEventListener(app.APP_ENTER_BACKGROUND_EVENT, handler(self, self._onAppEvent))
    self._appProxy:addEventListener(app.APP_ENTER_FOREGROUND_EVENT, handler(self, self._onAppEvent))


	self:resetAll()
	self:_init()	

    self._zhangbichenModel:zhangbichenFormalMainInfoRequest(function()
    	if self:safeCheck() then
    		 self:refreshInfo()
    	end
    end)
    self._zhangbichenModel:setInthenGame(false)
end

function QUIDialogZhangbichenMusicGame:viewAnimationOutHandler()
	self:popSelf()
end

function QUIDialogZhangbichenMusicGame:viewWillDisappear()
    QUIDialogZhangbichenMusicGame.super.viewWillDisappear(self)

	self:removeBackEvent()
	if self._zhangbichenModel then
		self._zhangbichenModel:setInthenGame(false)
	end

    self._root:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self._root:unscheduleUpdate()
    app.sound:stopMusic()
	app.sound:playMusic("main_interface")
	if self._musicVolume then
		audio.setMusicVolume(self._musicVolume)
	end

    if self._appProxy then
    	self._appProxy:removeAllEventListeners()
    end
    if self._preAnimationInterval then
		CCDirector:sharedDirector():setAnimationInterval(self._preAnimationInterval)
	end
	if self._comboScheduler then
		scheduler.unscheduleGlobal(self._comboScheduler)
		self._comboScheduler = nil
	end
	if self._btnScheduler then
		scheduler.unscheduleGlobal(self._btnScheduler)
		self._btnScheduler = nil
	end
	if self._btnScheduler2 then
		scheduler.unscheduleGlobal(self._btnScheduler2)
		self._btnScheduler2 = nil
	end
	if self._appScheduler then
		scheduler.unscheduleGlobal(self._appScheduler)
		self._appScheduler = nil
	end

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end	

	if self._startGameScheduler then
		scheduler.unscheduleGlobal(self._startGameScheduler)
		self._startGameScheduler = nil
	end	

	if self._sayWordScheduler then
		scheduler.unscheduleGlobal(self._sayWordScheduler)
		self._sayWordScheduler = nil
	end		
end

function QUIDialogZhangbichenMusicGame:showNodeMoveAndOpacity(node,pos,time,opacityValue)
	if node and pos then
		local actionTime = time or 0.5
		local opValue = opacityValue or 255
	    local arr = CCArray:create()
	    arr:addObject(CCMoveBy:create(actionTime,pos))
	    arr:addObject(CCCallFunc:create(function()
	    	makeNodeFadeToByTimeAndOpacity(node ,actionTime, opValue)
	    end))
		node:runAction(CCSpawn:create(arr))			
	end
end

function QUIDialogZhangbichenMusicGame:showTopUI( isShow)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page ~= nil and page.setBackBtnVisible ~= nil then
        page:setBackBtnVisible(isShow)
        page:setHomeBtnVisible(isShow)
    end
	if isShow then
    	page.topBar:showMusicGamePage()
    else
    	if page.topBar then page.topBar:hideAll() end
    end

    self._ccbOwner.node_activityTime:setVisible(isShow)
    self._ccbOwner.node_btn_menu:setVisible(isShow)
    self._ccbOwner.node_desc:setVisible(isShow)

    if not isShow then
	    self:showNodeMoveAndOpacity(self._ccbOwner.node_btn_goInfo,ccp(0, -200),0.3,0)
	else
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_btn_goInfo ,0, 255)
	end

	if self._sayWordScheduler then
		scheduler.unscheduleGlobal(self._sayWordScheduler)
		self._sayWordScheduler = nil
	end		

	if isShow then
		self._sayWordScheduler = scheduler.scheduleGlobal(handler(self,self._playSayWordsAction), 15)
	end
end

function QUIDialogZhangbichenMusicGame:resetAll()
	self:showTopUI(true)
	self._ccbOwner.sp_bg:setScale(1)
	self._ccbOwner.node_fire_effect:setVisible(false)
	self._ccbOwner.node_game:setVisible(false)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_game ,0, 0)
	self._ccbOwner.btn_pause:setVisible(false)
	self._ccbOwner.node_btn_left:setVisible(false)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_btn_left ,0, 0)
	self._ccbOwner.node_btn_right:setVisible(false)
	makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_btn_right ,0, 0)
	self._ccbOwner.node_btn_auto_play:setVisible(false)

	self._ccbOwner.node_game:setPositionY(500)
	self._ccbOwner.btn_pause:setPositionY(500-36)
	self._ccbOwner.node_btn_left:setPositionX(-display.width/2-200)
	self._ccbOwner.node_btn_right:setPositionX(display.width/2+200)

	self._ccbOwner.node_title_child:setPosition(ccp(0,0))
	self._ccbOwner.node_btn_goInfo:setPosition(ccp(-17,-259))
	self._ccbOwner.node_progress_child:setPosition(ccp(80,-260))

	self._ccbOwner.node_avatar:setScale(1.2)
	self._ccbOwner.node_avatar:setPositionY(self._oldAvatarPosY + 50)

	self._ccbOwner.node_desc:setVisible(false)

	if self._zhangbichenModel then
		self._zhangbichenModel:setInthenGame(false)
	end
end

function QUIDialogZhangbichenMusicGame:_playSayWordsAction()
	self._sayWords = self._zhangbichenModel:getChatWords()
	self._ccbOwner.node_desc:setVisible(true)
	if self._richText == nil then
		self._richText = QRichText.new(nil, 260)
   		self._richText:setAnchorPoint(ccp(0, 1))
		self._ccbOwner.node_words:addChild(self._richText)
	end
	self._richText:setString({
		{oType = "font", content = self._sayWords ,size = 18,color = COLORS.k},
	})

	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function()
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_desc ,0.3, 255)
	end))
	array:addObject(CCDelayTime:create(3.3))
	array:addObject(CCCallFunc:create(function()
		makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_desc ,0.3, 0)
	end))
	array:addObject(CCDelayTime:create(0.3))
	array:addObject(CCCallFunc:create(function()
		if self:safeCheck() then
			self._ccbOwner.node_desc:setVisible(false)
		end		
	end))
	self._ccbOwner.node_desc:stopAllActions()
	self._ccbOwner.node_desc:runAction(CCSequence:create(array))

end

function QUIDialogZhangbichenMusicGame:showGameUI( )
	self._ccbOwner.node_fire_effect:setVisible(true)
	self._ccbOwner.node_game:setVisible(true)
	self._ccbOwner.btn_pause:setVisible(true)
	self._ccbOwner.btn_pause:setOpacity(0)
	self._ccbOwner.node_btn_left:setVisible(true)
	self._ccbOwner.node_btn_right:setVisible(true)

	self:showNodeMoveAndOpacity(self._ccbOwner.node_game,ccp(0,-500))
	self:showNodeMoveAndOpacity(self._ccbOwner.node_btn_left,ccp(display.width/2+200,0))
	self:showNodeMoveAndOpacity(self._ccbOwner.node_btn_right,ccp(-display.width/2-200,0))

    local arrPause = CCArray:create()
    arrPause:addObject(CCFadeIn:create(0.6))
    arrPause:addObject(CCMoveBy:create(0.6,ccp(0,-500)))

    local arrGame = CCArray:create()
    arrGame:addObject(CCSpawn:create(arrPause))
    arrGame:addObject(CCCallFunc:create(function( )
		if self._startGameScheduler then
			scheduler.unscheduleGlobal(self._startGameScheduler)
			self._startGameScheduler = nil
		end
		self._startGameScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self:statrGame()
			end
		end, 0.5)
    end))
	self._ccbOwner.btn_pause:runAction(CCSequence:create(arrGame))
end

function QUIDialogZhangbichenMusicGame:showGameBgAndAvatar()

    local arrSpbg = CCArray:create()
    arrSpbg:addObject(CCScaleTo:create(0.5,1.25))
    arrSpbg:addObject(CCCallFunc:create(function() 
    	if self:safeCheck() then
    		self:showGameUI()
    	end
    end))
    self._ccbOwner.sp_bg:runAction(CCSequence:create(arrSpbg))

    local arrAvatar = CCArray:create()
    arrAvatar:addObject(CCScaleTo:create(0.5,1.5))
    arrAvatar:addObject(CCMoveBy:create(0.5,ccp(0,-50)))
    self._ccbOwner.node_avatar:runAction(CCSpawn:create(arrAvatar))
end

function QUIDialogZhangbichenMusicGame:setTimeCountdown()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	local endTime = self._zhangbichenModel.endAt or 0

	local timeFunc = function ( )
		local lastTime = endTime - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = q.timeToDayHourMinute(lastTime)
				self._ccbOwner.tf_activityTime:setString(timeStr)
				if lastTime >= 30*60 then
		            color = GAME_COLOR_SHADOW.stress
		        else
		            color = GAME_COLOR_SHADOW.warning
		        end	
		        self._ccbOwner.tf_activityTime:setColor(color)			
			else 
				app.tip:floatTip("魂师大人，当前活动已结束")
				self:popSelf()
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogZhangbichenMusicGame:showReward(  )
	-- 初始化进度条
	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.sp_progress_bar:getPositionY() -- 这个坐标必须sp_progress_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress_bar)
		self._totalStencilWidth = self._ccbOwner.sp_progress_bar:getContentSize().width * self._ccbOwner.sp_progress_bar:getScaleX()
		self._percentBarClippingNode:setRotation(-90)
	end

	self._ccbOwner.node_reward:removeAllChildren()
    local rewardDataList = self._zhangbichenModel:getRewardDataList()
    self._maxExpectation = tonumber(rewardDataList[#rewardDataList].expectation)
	for index, data in pairs(rewardDataList) do
		local box = QUIWidgetZhangbichenReward.new()
		box:setInfo(data)
		-- local posY = self._totalStencilWidth * tonumber(data.expectation) / self._maxExpectation
		local posY = self._totalStencilWidth * index/#rewardDataList
		box:setPosition(ccp(0, posY))
		box:addEventListener(QUIWidgetZhangbichenReward.EVENT_CLICK, handler(self, self._onBoxClicked))
		self._ccbOwner.node_reward:addChild(box)
		self._rewardBox[tostring(data.id)] = box
	end
end

function QUIDialogZhangbichenMusicGame:refreshInfo()
	if self:safeCheck() then
		local serverInfo = self._zhangbichenModel:getServerInfo()
		if not serverInfo then return end

		self._ccbOwner.tf_num:setString((serverInfo.currNum or 0))
		self._ccbOwner.tf_play_count:setString((serverInfo.remainCount or 0).."次")

		local stencil = self._percentBarClippingNode:getStencil()
	    local rewardDataList = self._zhangbichenModel:getRewardDataList()
	    local progress = 0
	    for index, data in pairs(rewardDataList) do
	    	if tonumber(data.expectation) <= (tonumber(serverInfo.currNum) or 0) then
	    		progress = math.max(progress,index)
	    	end
	    end
		local averageProgress = self._maxExpectation / #rewardDataList * progress
		local maxProgress = math.max(averageProgress,(tonumber(serverInfo.currNum) or 0))
		if maxProgress > self._maxExpectation then
			maxProgress = self._maxExpectation
		end
		local posX = -self._totalStencilWidth + maxProgress/self._maxExpectation*self._totalStencilWidth
		stencil:setPositionX(posX)

	    local tbl = {}
		for _, id in ipairs(serverInfo.rewardIds or {}) do
			tbl[tostring(id)] = true
		end
	    for id, box in pairs(self._rewardBox) do
	    	box:isGet(tbl[tostring(id)])
	    	box:refreshInfo()
	    end
	end
end

function QUIDialogZhangbichenMusicGame:_init()
	self._lastTimeBarProportion = nil
	self._isPlaying = false
	self._curTime = 0
	self._curAddIndex = 1
	self._musicGameIconDataList = {}
	-- self._iconDic = {}
	self._iconList = {}
	self._addIconIndexDic = {}

	self._comboNumber = 0
	self._scoreNumber = 0 -- 獲得分數
	self._comboCoefficient = 0 -- combo系數
	self._curTotalScoreLevel = 0

	self._isFullCombo = true

	self._isTestModel = false -- 测试模式
	self._ccbOwner.node_test_left:setVisible(self._isTestModel)
	self._ccbOwner.node_test_right:setVisible(self._isTestModel)
	self._ccbOwner.tf_test_time:setVisible(self._isTestModel)
	self._ccbOwner.tf_test_time:setString("")
	self._ccbOwner.node_btn_auto_play:setVisible(self._isTestModel)
	self._isAutoPlay = false
	self._ccbOwner.sp_select_auto:setVisible(self._isAutoPlay)

	self._gameEndData = {} -- 传给结算界面的数据
	self._avatarActionList = {} -- avatar动作数据

    app.sound:stopMusic()


	self._zhangbichenModel:setActivityClickedToday(self._zhangbichenModel.yuyinniaoniaoActivityId)

	-- local serverInfo = self._zhangbichenModel:getServerInfo()
	-- if serverInfo and serverInfo.remainCount and serverInfo.remainCount <= 0 then
	-- 	app.tip:floatTip("已经没有领奖次数，游戏即将退出")
	-- 	self._isEnd = true
	-- 	return
	-- end
	

	self:_initScoreBar()
	self:_updateScoreBar()
	self:_initTimeBar()
	self:_updateTimeBar()
	self:_showScoreNumber()
	self:_showComboNumber()
	self:_initAvatar()
	
	self:setTimeCountdown()
	self:showReward()
	self:refreshInfo()
	
	if self._ccclippingNode and self._ccclippingNode.removeAllChildren then
		self._ccclippingNode:removeAllChildren()
	end

end



function QUIDialogZhangbichenMusicGame:_onAppEvent(e)
	if e.name == app.APP_ENTER_BACKGROUND_EVENT then
		if self:safeCheck() then
			if self._appScheduler then
				scheduler.unscheduleGlobal(self._appScheduler)
				self._appScheduler = nil
			end
			self:_onPause()
		end
	elseif e.name == app.APP_ENTER_FOREGROUND_EVENT then
		app.sound:pauseMusic()
		self._appScheduler = scheduler.performWithDelayGlobal(function()
			if self:safeCheck() then
				self._appScheduler = nil
				if self._pauseDialog and self._pauseDialog._onContinue then
					self._pauseDialog:_onContinue()
				else
					self:_onResume()
				end
			end
		end, 0)
	end
end

function QUIDialogZhangbichenMusicGame:_onFrame(dt)
	if not self._isPlaying then return end
	self._curTime = self._curTime + dt
	-- print("[Kumo] self._curTime = ", self._curTime)
	self._ccbOwner.tf_test_time:setString(math.floor(self._curTime))
	if self._isAutoPlay then
		self:_autoPlay()
	end
	self:_onAddIcon()
	self:_showScoreNumber()
	self:_showComboNumber()
	self:_updateScoreBar()
	self:_updateTimeBar()
	self:_updateAvatar()
end

function QUIDialogZhangbichenMusicGame:_initAvatar()
	local actionPreviewDic = {}
   	local gameConfig = self._zhangbichenModel:getGameConfig()
   	if gameConfig and gameConfig.music_action then
   		local tbl = string.split(gameConfig.music_action, ";")
   		if tbl and #tbl > 0 then
   			for _, str in pairs(tbl) do
   				local actionInfo = string.split(str, ":")
   				if actionInfo and #actionInfo > 0 then
   					if not self._avatarActionList then
   						self._avatarActionList = {}
   					end
   					local time = tonumber(actionInfo[1])
   					local actionName = actionInfo[2]
   					if time and actionName then
   						table.insert(self._avatarActionList, {time = time, actionName = actionName, isLoop = tonumber(actionInfo[3]) == 1})
   						if not actionPreviewDic[actionName] then
   							actionPreviewDic[actionName] = true
   						end
   					end
   				end
   			end

   		end
   	end

   	if self._avatarActionList and #self._avatarActionList > 0 then
   		table.sort(self._avatarActionList, function (a, b)
   			return a.time < b.time
   		end)
   	end

	if not self._avatar then
	    self._ccbOwner.node_avatar:removeAllChildren()
	    -- self._ccbOwner.node_avatar:setScale(1.5)
	    local skinId = 71
	    local skinConfig = db:getHeroSkinConfigByID(skinId)
	    self._avatar = QUIWidgetActorDisplay.new(skinConfig.character_id, {heroInfo = {skinId = skinId}})
	    -- self._avatar:setScale(1.5)
	    self._ccbOwner.node_avatar:addChild(self._avatar)
	    self._avatar:setAutoStand(true)


		local avatarPreview = QUIWidgetActorDisplay.new(skinConfig.character_id, {heroInfo = {skinId = skinId}})
	   	for actionName, _ in pairs(actionPreviewDic) do
	   		avatarPreview:displayWithBehavior(actionName)
	    end
	    avatarPreview:onCleanup()
	else
		self._avatar:getActor():playAnimation(ANIMATION.STAND, true)
	end
end

function QUIDialogZhangbichenMusicGame:_updateAvatar()
	if not self._avatar or not self._avatarActionList or #self._avatarActionList == 0 then return end

	local curTime = self._curTime * 1000
	local info = self._avatarActionList[1]
	if info.time <= curTime then
		-- QKumo(info)
		self:_avatarPlayAnimation(info.actionName, info.isLoop)
		table.remove(self._avatarActionList, 1)
		-- QKumo(self._avatarActionList)
	end
end

function QUIDialogZhangbichenMusicGame:_avatarPlayAnimation(actionName, isLoop, callback)
    if self._avatar ~= nil then
        self._avatar:displayWithBehavior(actionName)
        if isLoop then
        	self._avatar:setDisplayBehaviorCallback(function()
        		self:_avatarPlayAnimation(actionName, isLoop)
        	end)
        else
        	self._avatar:setDisplayBehaviorCallback(callback)
        end
    end
end

function QUIDialogZhangbichenMusicGame:_autoPlay()
	local iconList = self._iconList
	if not self._endPosX or not iconList or #iconList == 0 then return end

	local curTime = self._curTime * 1000
	table.sort(iconList, function(a, b)
		return a:getPositionX() > b:getPositionX()
	end)
	for _, icon in ipairs(iconList) do
		if icon.getInfo then
			local info = icon:getInfo()
			if not info.isEnd and icon:getPositionX() ~= self._endPosX then
				local lastTime = tonumber(info.start_time) + tonumber(info.perfect_time) + tonumber(info.perfect_offset)
				local firstTime = tonumber(info.start_time) + tonumber(info.perfect_time) - tonumber(info.perfect_offset)
				if curTime < lastTime then
					if curTime > firstTime then
						if tonumber(info.type) == 1 then
							self:_onTriggerClick1()
						else
							self:_onTriggerClick2()
						end
					end
					return
				end
			end

		end
	end
end

function QUIDialogZhangbichenMusicGame:_onAddIcon()
	if not self._musicGameIconDataList then return end
	if not self._ccclippingNode then return end

	if self._curAddIndex == 1 then
		self._ccclippingNode:removeAllChildren()
	end
	local curIconData = self._musicGameIconDataList[self._curAddIndex]
	if curIconData and not self._addIconIndexDic[curIconData.index] then
		if curIconData.start_time <= self._curTime * 1000 then
			-- print("[add icon] ", self._curAddIndex)
			local icon = QUIWidgetZhangbichenMusicGameIcon.new()
			-- if not self._iconDic[tostring(curIconData.type)] then
			-- 	self._iconDic[tostring(curIconData.type)] = {}
			-- end
			-- table.insert(self._iconDic[tostring(curIconData.type)], icon)
			table.insert(self._iconList, icon)
			icon:setInfo(curIconData)
			if not self._startPosX or not self._startPosY then
				self._startPosX = self._ccbOwner.node_staff_mask:getPositionX() - icon:getContentSize().width
				self._startPosY = self._ccbOwner.node_staff_mask:getPositionY()
			end
			if not self._endPosX or not self._endPosY then
				self._endPosX = self._ccbOwner.node_staff_mask:getPositionX() + self._ccbOwner.node_staff_mask:getContentSize().width
				self._endPosY = self._ccbOwner.node_staff_mask:getPositionY()
			end
			icon:setPosition(ccp(self._startPosX, self._startPosY))
			self._ccclippingNode:addChild(icon)
			self:_addAction(icon, curIconData)
			self._addIconIndexDic[curIconData.index] = true
			self._curAddIndex = self._curAddIndex + 1
		end
	end
end

function QUIDialogZhangbichenMusicGame:_addAction(icon, iconData)
	if not icon or not iconData then return end

	local endTime = 0
	if iconData.end_time then
		endTime = tonumber(iconData.end_time)
	else
		if not self._totalDistance or not self._perfectDistance then
			self._totalDistance = self._ccbOwner.node_staff_mask:getContentSize().width + icon:getContentSize().width
			self._perfectDistance = math.abs(self._ccbOwner.sp_perfect:getPositionX()) - icon:getContentSize().width/2 + math.abs(self._ccbOwner.node_staff_mask:getPositionX()) + icon:getContentSize().width
		end
		endTime = self._totalDistance * tonumber(iconData.perfect_time) / self._perfectDistance + tonumber(iconData.start_time)
	end
	local durationTime = (endTime - tonumber(iconData.start_time)) / 1000

	icon:stopAllActions()
	local actions = CCArray:create()
	actions:addObject(CCMoveTo:create(durationTime, ccp(self._endPosX, self._endPosY)))
    actions:addObject(CCCallFunc:create(function() 
    	if self:safeCheck() then
    		self._gameEndData["none"] = (self._gameEndData["none"] or 0) + 1

    		if icon.getInfo then
    			icon:getInfo().isEnd = true
    		end
    		-- icon:removeFromParentAndCleanup(false)
    		self._isFullCombo = false
			self._comboNumber = 0
			_, self._comboCoefficient = self._zhangbichenModel:getScore(0, 0, self._comboNumber)
    		icon:setVisible(false)
    	end
    end))
    icon:runAction(CCSequence:create(actions))
end

function QUIDialogZhangbichenMusicGame:_initScoreBar()
	local gameConfig = self._zhangbichenModel:getGameConfig()
	if not gameConfig then return end

	if not self._curScoreBarImg then
		self._curTotalScoreLevel = 0
		self._curScoreBarImg = self:_addTotalScoreBarImgByLevel(self._curTotalScoreLevel)
	end

	local maxScore = self._zhangbichenModel:getMaxScore()
	local totalScoreLevel = 1
	while true do
		local node = self._ccbOwner["sp_score_level_"..totalScoreLevel]
		local path = QResPath("zhangbichenMusicGameTotalScoreLevelImg")[totalScoreLevel]
		local scoreNumber = gameConfig["score_level_"..totalScoreLevel]
		if node and path and scoreNumber then
			scoreNumber = tonumber(scoreNumber)
			QSetDisplayFrameByPath(node, path)
			node:setPositionX(self._ccbOwner.node_cur_score_bar:getPositionX() + scoreNumber/maxScore*self._curScoreBarImg:getContentSize().width)
			totalScoreLevel = totalScoreLevel + 1
		else
			break
		end
	end

	-- if not self._barEffect then
 --    	self._barEffect = QUIWidgetFcaAnimation.new("fca/yingfu_jindutiao", "res")
	-- 	self._barEffect:playAnimation("animation", true)
	-- 	self._ccbOwner.node_bar_effect:addChild(self._barEffect)
 --    end
 --    local posX = 0
 --    self._barEffect:setPositionX(posX)
end

function QUIDialogZhangbichenMusicGame:_addTotalScoreBarImgByLevel(level)
	local size = CCSize(849, 18)

	if not self._scoreBarClippingNode then
		local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
		self._scoreBarClippingNode = CCClippingNode:create()
		lyImageMask:setAnchorPoint(ccp(0, 0))
		lyImageMask:setPosition(ccp(0, 0))
		lyImageMask:ignoreAnchorPointForPosition(false)
		self._scoreBarClippingNode:setStencil(lyImageMask)
		self._scoreBarClippingNode:setInverted(false)
		self._ccbOwner.node_cur_score_bar:removeAllChildren()
		self._ccbOwner.node_cur_score_bar:addChild(self._scoreBarClippingNode)
	end

	local level = tonumber(level) + 1
	local path = QResPath("zhangbichenMusicGameTotalScoreBarImg")[level]
	local spBar
	if path then
		spBar = CCScale9Sprite:create(path)
		spBar:setContentSize(size)
		spBar:setAnchorPoint(ccp(0, 0))
		spBar:setPosition(ccp(0, 0))
		self._scoreBarClippingNode:addChild(spBar, -level)
	end

	return spBar
end

function QUIDialogZhangbichenMusicGame:_initTimeBar()
	local gameConfig = self._zhangbichenModel:getGameConfig()
	if not gameConfig then return end

	self._musicName = gameConfig.sound_id
	local soundInfo = db:getSoundById(self._musicName)
	self._soundInfo = q.cloneShrinkedObject(soundInfo)

	if not self._timeBarClippingNode then
		self._timeBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.s9s_time_bar)
		self._timeStencilWidth = self._ccbOwner.s9s_time_bar:getContentSize().width * self._ccbOwner.s9s_time_bar:getScaleX()
	end
	self:_updateTimeBar()
end

function QUIDialogZhangbichenMusicGame:_showStartEffect()
	local tbl = {
		{node = self._ccbOwner.node_game_info_effect, fcaName = "yinyou_kaishi1", callback = function ()
			if self:safeCheck() then
				self._isPlaying = true
				app.sound:stopMusic()
				app.sound:playMusic(self._musicName, false)
				audio.setMusicVolume(global.music_volume)
			end
		end},
	}
	self:_showNodeEffect(tbl)
end

function QUIDialogZhangbichenMusicGame:_showGameOverEffect()
	local tbl = {}
	if self._isFullCombo then
		tbl = {
			{node = self._ccbOwner.node_game_info_effect, fcaName = "yinyou_fullcombo", callback = function ()
				if self:safeCheck() then
					self:_showEnd()
				end
			end},
		}
	else
		tbl = {
			{node = self._ccbOwner.node_game_info_effect, fcaName = "yinyou_clear1", callback = function ()
				if self:safeCheck() then
					self:_showEnd()
				end
			end},
		}
	end
	self:_showNodeEffect(tbl)
end

function QUIDialogZhangbichenMusicGame:_showEnd()
	-- 彈出結算界面
	self._gameEndData.callback = function(chooseType)
		if self:safeCheck() then

			if chooseType == 2 then
				-- 重新开始
				self:_init()
				self:statrGame()
			else
				self:resetAll()
				self:_init()
				-- self:_onPause()
				-- self:playEffectOut()
			end
		end
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenMusicGameEnd", 
		options = self._gameEndData})
end

function QUIDialogZhangbichenMusicGame:_showScoreNumber()
	if self._lastScoreNumber and self._lastScoreNumber == self._scoreNumber then return end

	local tbl = self:_getNumberList(self._scoreNumber, 6)
	for index, value in ipairs(tbl) do
		local num = tonumber(value)
		local node = self._ccbOwner["sp_score_bar_num_"..index]
		local path = QResPath("zhangbichenMusicGameScoreNumber")[num]
		if node and path then
			QSetDisplayFrameByPath(node, path)
		end
	end

	self._lastScoreNumber = self._scoreNumber
end

function QUIDialogZhangbichenMusicGame:_showComboNumber()
	if self._lastComboNumber and self._lastComboNumber == self._comboNumber then return end

	if self._comboNumber > 0 and self._ccbOwner.node_combo then
		if self._comboScheduler then
			scheduler.unscheduleGlobal(self._comboScheduler)
			self._comboScheduler = nil
		end
		self._ccbOwner.node_combo:setScale(1.2)
		self._comboScheduler = scheduler.performWithDelayGlobal(function()
				self._ccbOwner.node_combo:setScale(1)
		end, 0.2)
	end	
	local tbl = self:_getNumberList(self._comboNumber, 3)
	for index, value in ipairs(tbl) do
		local num = tonumber(value)
		local node = self._ccbOwner["sp_combo_num_"..index]
		local path = QResPath("zhangbichenMusicGameComboNumber")[num]
		if node and path then
			QSetDisplayFrameByPath(node, path)
		end
	end

	local gameConfig = self._zhangbichenModel:getGameConfig()
	if gameConfig and gameConfig.combo_condition then
		local condition = tonumber(gameConfig.combo_condition)
		if self._comboNumber > 0 and self._comboNumber % condition == 0 then
			local comboEffect = QUIWidgetAnimationPlayer.new()
	        self._ccbOwner.node_game_info_effect:addChild(comboEffect)
	        comboEffect:playAnimation("effects/music_game_combo_info.ccbi", function(owner)
	        	local _tbl = self:_getNumberList(self._comboNumber, 3, true)
	        	print("self._comboNumber = ", self._comboNumber)
	        	QKumo(_tbl)
	        	for index, value in ipairs(_tbl) do
					local num = tonumber(value)
					local node = owner["sp_combo_num_"..index]
					local path = QResPath("zhangbichenMusicGameComboNumber")[num]
					if node and path then
						QSetDisplayFrameByPath(node, path)
						node:setVisible(true)
					end
				end
				if #_tbl == 1 then
					owner.node_number:setPositionX(34)
				elseif #_tbl == 2 then
					owner.node_number:setPositionX(17)
				elseif #_tbl == 3 then
					owner.node_number:setPositionX(0)
				end
				local _index = #_tbl + 1
				while true do
					local node = owner["sp_combo_num_".._index]
					if node then
						node:setVisible(false)
						_index = _index + 1
					else
						break
					end
				end
	    	end,function ()
	            comboEffect:removeFromParent()
	            comboEffect = nil
	        end, true)
		end
	end

	self._ccbOwner.tf_combo_coefficient:setString("x"..self._comboCoefficient)

	self._lastComboNumber = self._comboNumber
end

function QUIDialogZhangbichenMusicGame:_showTimeBarNumber(curProportion)
	if self._lastTimeBarProportion == 1 then
		-- game Over
		self._isPlaying = false
		app.sound:stopMusic()
		QSetDisplayFrameByPath(self._ccbOwner.sp_time_bar_num_1, QResPath("zhangbichenMusicGameTimeBarNumber")[1])
		QSetDisplayFrameByPath(self._ccbOwner.sp_time_bar_num_2, QResPath("zhangbichenMusicGameTimeBarNumber")[10])
		QSetDisplayFrameByPath(self._ccbOwner.sp_time_bar_num_3, QResPath("zhangbichenMusicGameTimeBarNumber")[10])
		self:_showGameOverEffect()
	end
	if self._lastTimeBarProportion and self._lastTimeBarProportion == curProportion then return end

	local curP = math.floor(curProportion * 100)
	local tbl = self:_getNumberList(curP, 3)
	for index, value in ipairs(tbl) do
		local num = tonumber(value)
		local node = self._ccbOwner["sp_time_bar_num_"..index]
		local path = QResPath("zhangbichenMusicGameTimeBarNumber")[num]
		if node and path then
			QSetDisplayFrameByPath(node, path)
		end
	end

	self._lastTimeBarProportion = curProportion
end

-- @len 固定的顯示位數，實際數值小於時左邊用0（即 10）填滿，反之顯示len位的9；如果len為nil，則按照實際數值位數返回
-- @isNoZero 位数不足，前面不用0填充
-- 返回table，1為最高位
function QUIDialogZhangbichenMusicGame:_getNumberList(number, len, isNoZero)
	local numberStr = tostring(math.floor(number))
	local numberStrLen = string.len(numberStr)
	local tbl = {}
	for i = 1, numberStrLen, 1 do
		local s = string.sub(numberStr, i, i)
		if s == "0" then
			s = "10"
		end
		table.insert(tbl, s)
	end
	if len then
		if #tbl > len then
			tbl = {}
			for i = 1, len, 1 do
				table.insert(tbl, 9)
			end
		elseif #tbl < len and not isNoZero then
			for i = 1, len - #tbl, 1 do
				table.insert(tbl, 1, 10)
			end
		end
	end
	return tbl
end

function QUIDialogZhangbichenMusicGame:_updateScoreBar()
	local gameConfig = self._zhangbichenModel:getGameConfig()
	if not gameConfig then return end

	if not self._curScoreBarImg then
		self._curTotalScoreLevel = 0
		self._curScoreBarImg = self:_addTotalScoreBarImgByLevel(self._curTotalScoreLevel)
	end
	
	local nextTotalScoreLevel = self._curTotalScoreLevel + 1
	local nextScoreNumber = gameConfig["score_level_"..nextTotalScoreLevel]
	if nextScoreNumber and self._scoreNumber >= tonumber(nextScoreNumber) then
		self._curScoreBarImg:stopAllActions()
		self._curScoreBarImg:setOpacity(255)
		local preScoreBarImg = self._curScoreBarImg
		self._curTotalScoreLevel = tonumber(nextTotalScoreLevel)
		self._curScoreBarImg = self:_addTotalScoreBarImgByLevel(self._curTotalScoreLevel)
		self._curScoreBarImg:setOpacity(0)

		self._gameEndData["scoreLevel"] = self._curTotalScoreLevel

		local actionTime = 1
		local action1 = CCArray:create()
		action1:addObject(CCFadeOut:create(actionTime))
		action1:addObject(CCCallFunc:create(function()
			if self:safeCheck() then
				preScoreBarImg:removeFromParentAndCleanup(true)
			end
		end))
		preScoreBarImg:runAction(CCSequence:create(action1))

		local action2 = CCArray:create()
		action2:addObject(CCFadeIn:create(actionTime))
		-- action2:addObject(CCCallFunc:create(function()
		-- 	if self:safeCheck() then
		-- 	end
		-- end))
		self._curScoreBarImg:runAction(CCSequence:create(action2))
	end

	if self._scoreBarClippingNode then
		local stencil = self._scoreBarClippingNode:getStencil()
		local maxScore = self._zhangbichenModel:getMaxScore()
		local curProportion = self._scoreNumber / maxScore
		if curProportion > 1 then curProportion = 1 end
    	stencil:setPositionX(-self._curScoreBarImg:getContentSize().width + curProportion * self._curScoreBarImg:getContentSize().width)

  --   	if self._barEffect then
		-- 	self._barEffect:setPositionX(curProportion * self._curScoreBarImg:getContentSize().width)
		-- end
	end
end

function QUIDialogZhangbichenMusicGame:_updateTimeBar()
	if not self._timeBarClippingNode then return end

    local totalTime = self._soundInfo.duration
    local curProportion = self._curTime / totalTime
    if curProportion > 1 then curProportion = 1 end
    local stencil = self._timeBarClippingNode:getStencil()
    stencil:setPositionX(-self._timeStencilWidth + curProportion * self._timeStencilWidth)

    self:_showTimeBarNumber(curProportion)

    if self._ccbOwner.node_time_bar_info then
    	self._ccbOwner.node_time_bar_info:setPositionX(self._ccbOwner.node_cur_time_bar:getPositionX() + curProportion * self._timeStencilWidth )
    end
end

function QUIDialogZhangbichenMusicGame:_initStaffView()
	--切圖
	local size = self._ccbOwner.node_staff_mask:getContentSize()
	local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	self._ccclippingNode = CCClippingNode:create()
	lyImageMask:setPositionX(self._ccbOwner.node_staff_mask:getPositionX())
	lyImageMask:setPositionY(self._ccbOwner.node_staff_mask:getPositionY())
	lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_staff_mask:isIgnoreAnchorPointForPosition())
	lyImageMask:setAnchorPoint(self._ccbOwner.node_staff_mask:getAnchorPoint())
	self._ccclippingNode:setStencil(lyImageMask)
	self._ccclippingNode:setInverted(false)
	self._ccbOwner.node_staff_mask:getParent():addChild(self._ccclippingNode)
end

function QUIDialogZhangbichenMusicGame:_onTriggerPause() 
	if not self._isPlaying then return end
    app.sound:playSound("common_small")

	self:_onPause()
	self._pauseDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogZhangbichenMusicGamePause", options = {callback = function(chooseType)
		if self:safeCheck() then
			self._pauseDialog = nil
			if chooseType == 1 then
				-- 继续游戏
				self:_onResume()
			elseif chooseType == 2 then
				-- 放弃关卡
				-- self:playEffectOut()
				self:_onResume()
				self:resetAll()
				self:_init()
			elseif chooseType == 3 then
				-- 重新开始
				self:_init()
				self:statrGame()
			end
		end
	end}})
end

function QUIDialogZhangbichenMusicGame:_onPause()
	if not self._isPlaying then return end
	self._isPlaying = false
	app.sound:pauseMusic()
    self:_pauseNode(self._ccclippingNode, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_pauseNode(self._avatar, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
end

function QUIDialogZhangbichenMusicGame:_pauseNode(node, actionManager, scheduler)
    actionManager:pauseTarget(node)
    scheduler:pauseTarget(node)
    local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        self:_pauseNode(child, actionManager, scheduler)
    end
end

function QUIDialogZhangbichenMusicGame:_onResume()
	if self._isPlaying then return end
	self._isPlaying = true
	app.sound:resumeMusic()
    self:_resumeNode(self._ccclippingNode, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())
    self:_resumeNode(self._avatar, CCDirector:sharedDirector():getActionManager(), CCDirector:sharedDirector():getScheduler())

end

function QUIDialogZhangbichenMusicGame:_resumeNode(node, actionManager, scheduler)
    actionManager:resumeTarget(node)
    scheduler:resumeTarget(node)
    local children = node:getChildren()
    if children == nil then
        return
    end

    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        self:_resumeNode(child, actionManager, scheduler)
    end
end

function QUIDialogZhangbichenMusicGame:_showNodeEffect(tbl)
	for _, value in ipairs(tbl) do
		local node = value.node
		local fcaName = value.fcaName
		local callback = value.callback
		if node and fcaName then
			node:removeAllChildren()
			local fcaEffect = QUIWidgetFcaAnimation.new("fca/"..fcaName, "res")
			fcaEffect:playAnimation("animation", false)
			fcaEffect:setEndCallback(function()
				-- print("FCA End!!!")
				fcaEffect:removeFromParent()
				if callback then 
					callback()
				end
			end)
			node:addChild(fcaEffect)
		end
	end
end

function QUIDialogZhangbichenMusicGame:statrGame( )
	self._musicGameIconDataList = self._zhangbichenModel:getMusicIconDataList()
	if self._musicGameIconDataList then
		if self:safeCheck() then
			self:_showStartEffect()
		end
	end
	if self._zhangbichenModel then
		self._zhangbichenModel:setInthenGame(true)
	end	
end

function QUIDialogZhangbichenMusicGame:_onTriggerStatGame( )

	local hidNormalUI = function()
		self:showTopUI(false)

	    -- self._ccbOwner.node_activityTime:setVisible(false)
	    -- self._ccbOwner.node_btn_menu:setVisible(false)
	    -- self._ccbOwner.node_desc:setVisible(false)

	    -- self._ccbOwner.node_btn_goInfo:runAction(CCMoveBy:create(0.2, ccp(0, -300)))
	    self._ccbOwner.node_progress_child:runAction(CCMoveBy:create(0.2, ccp(-500, 0)))

	    local arrTitle = CCArray:create()
	    arrTitle:addObject(CCMoveBy:create(0.2, ccp(0, 200)))
	    arrTitle:addObject(CCCallFunc:create(function() 
	    	if self:safeCheck() then
	    		self:showGameBgAndAvatar()
	    	end
	    end))
	    self._ccbOwner.node_title_child:runAction(CCSequence:create(arrTitle))
	end

    local serverInfo = self._zhangbichenModel:getServerInfo()
    if not serverInfo then return end

    app.sound:playSound("common_small")

    if not self._zhangbichenModel.isActivityNotEnd then
    	app.tip:floatTip("活动已结束")
		return
    end

	if serverInfo.remainCount and serverInfo.remainCount <= 0 then
		app:alert({content = "没有剩余领奖次数，无法获得任何奖励，是否继续？",title = "系统提示", callback = function (state)
            if state == ALERT_TYPE.CONFIRM then
                hidNormalUI()
            end
        end})
		return
	else
		hidNormalUI()
	end
end

function QUIDialogZhangbichenMusicGame:_onTriggerClick1(e) 
	if self._isAutoPlay and e then
		app.tip:floatTip("自动游戏中，点击无效")
		return
	end
	if not self._isPlaying then return end

	if self._ccbOwner.sp_btn_left then
		if self._btnScheduler then
			scheduler.unscheduleGlobal(self._btnScheduler)
			self._btnScheduler = nil
		end
		self._ccbOwner.sp_btn_left:setScale(1.1)
		self._btnScheduler = scheduler.performWithDelayGlobal(function()
				self._ccbOwner.sp_btn_left:setScale(1)
		end, 0.1)
	end
	if not self._btnSoundId then
		local gameConfig = self._zhangbichenModel:getGameConfig()
		if gameConfig and gameConfig.button_sound_id then
			self._btnSoundId = gameConfig.button_sound_id
		end
	end

	local tbl = {
		{node = self._ccbOwner.node_left_btn_effect, fcaName = "yinyou_anniu1"},
		{node = self._ccbOwner.node_perfect_effect, fcaName = "yinyou_baodian1"},
	}
	self:_showNodeEffect(tbl)

	-- local iconList = self._iconDic["1"]
	local iconList = self._iconList
	if not self._endPosX or not iconList or #iconList == 0 then return end

	local curTime = self._curTime * 1000
	table.sort(iconList, function(a, b)
		return a:getPositionX() > b:getPositionX()
	end)
	for _, icon in ipairs(iconList) do
		if icon.getInfo then
			local info = icon:getInfo()
			if not info.isEnd and icon:getPositionX() ~= self._endPosX then
				local scoreLevel = self._zhangbichenModel:getLevel(info, curTime)
				if scoreLevel > self._zhangbichenModel.SCORE_LEVEL.none then
					-- 相應點擊
					if tonumber(info.type) ~= 1 then
						scoreLevel = self._zhangbichenModel.SCORE_LEVEL.miss
					end

					if scoreLevel > self._zhangbichenModel.SCORE_LEVEL.miss then
						self._comboNumber = self._comboNumber + 1
					else
						if self._btnSoundId then
							app.sound:playSound(self._btnSoundId)
						end
						self._isFullCombo = false
						self._comboNumber = 0
					end
					local addScore = 0
					local levelCoefficient = self._zhangbichenModel:getLevelCoefficientByLevel(scoreLevel)
					addScore, self._comboCoefficient = self._zhangbichenModel:getScore(info.base_score, levelCoefficient, self._comboNumber)
					self._scoreNumber = self._scoreNumber + addScore

					local scoreLevelStr = self._zhangbichenModel:levelToString(scoreLevel)
					-- print("[blue] scoreLevel = ", scoreLevel, "  scoreLevelStr = ", scoreLevelStr)
					if scoreLevelStr then
						tbl = {
							{node = self._ccbOwner.node_score_type_effect, fcaName = "yinyou_"..scoreLevelStr.."1"},
						}
						self:_showNodeEffect(tbl)
						self._gameEndData[scoreLevelStr] = (self._gameEndData[scoreLevelStr] or 0) + 1
					end
					if not self._gameEndData["combo"] or self._gameEndData["combo"] < self._comboNumber then
						self._gameEndData["combo"] = self._comboNumber
					end

					icon:stopAllActions()
	    			info.isEnd = true
		    		-- icon:removeFromParentAndCleanup(false)
		    		icon:setVisible(false)
					break
				end
			end
		end
	end

	while true do
		local icon = iconList[1]
		if icon and icon.getInfo then
			if icon:getPositionX() == self._endPosX then
				table.remove(iconList, 1)
			elseif icon.getInfo and icon:getInfo().isEnd then
				table.remove(iconList, 1)
			else
				break
			end
		else
			break
		end 
	end
end

function QUIDialogZhangbichenMusicGame:_onTriggerClick2(e)
	if self._isAutoPlay and e then
		app.tip:floatTip("自动游戏中，点击无效")
		return
	end
	if not self._isPlaying then return end

	if self._ccbOwner.sp_btn_right then
		if self._btnScheduler2 then
			scheduler.unscheduleGlobal(self._btnScheduler2)
			self._btnScheduler2 = nil
		end
		self._ccbOwner.sp_btn_right:setScale(1.1)
		self._btnScheduler2 = scheduler.performWithDelayGlobal(function()
				self._ccbOwner.sp_btn_right:setScale(1)
		end, 0.1)
	end
	if not self._btnSoundId then
		local gameConfig = self._zhangbichenModel:getGameConfig()
		if gameConfig and gameConfig.button_sound_id then
			self._btnSoundId = gameConfig.button_sound_id
		end
	end
	
	local tbl = {
		{node = self._ccbOwner.node_right_btn_effect, fcaName = "yinyou_anniu1"},
		{node = self._ccbOwner.node_perfect_effect, fcaName = "yinyou_baodian1"},
	}
	self:_showNodeEffect(tbl)

	-- local iconList = self._iconDic["2"]
	local iconList = self._iconList
	if not self._endPosX or not iconList or #iconList == 0 then return end

	local curTime = self._curTime * 1000
	table.sort(iconList, function(a, b)
		return a:getPositionX() > b:getPositionX()
	end)
	for _, icon in ipairs(iconList) do
		if icon.getInfo then
			local info = icon:getInfo()
			if not info.isEnd and icon:getPositionX() ~= self._endPosX then
				local scoreLevel = self._zhangbichenModel:getLevel(info, curTime)
				if scoreLevel > self._zhangbichenModel.SCORE_LEVEL.none then
					-- 相應點擊
					if tonumber(info.type) ~= 2 then
						scoreLevel = self._zhangbichenModel.SCORE_LEVEL.miss
					end

					if scoreLevel > self._zhangbichenModel.SCORE_LEVEL.miss then
						self._comboNumber = self._comboNumber + 1
					else
						if self._btnSoundId then
							app.sound:playSound(self._btnSoundId)
						end
						self._isFullCombo = false
						self._comboNumber = 0
					end
					local addScore = 0
					local levelCoefficient = self._zhangbichenModel:getLevelCoefficientByLevel(scoreLevel)
					addScore, self._comboCoefficient = self._zhangbichenModel:getScore(info.base_score, levelCoefficient, self._comboNumber)
					self._scoreNumber = self._scoreNumber + addScore

					local scoreLevelStr = self._zhangbichenModel:levelToString(scoreLevel)
					-- print("[purple] scoreLevel = ", scoreLevel, "  scoreLevelStr = ", scoreLevelStr)
					if scoreLevelStr then
						tbl = {
							{node = self._ccbOwner.node_score_type_effect, fcaName = "yinyou_"..scoreLevelStr.."1"},
						}
						self:_showNodeEffect(tbl)
						self._gameEndData[scoreLevelStr] = (self._gameEndData[scoreLevelStr] or 0) + 1
					end
					if not self._gameEndData["combo"] or self._gameEndData["combo"] < self._comboNumber then
						self._gameEndData["combo"] = self._comboNumber
					end

					icon:stopAllActions()
	    			info.isEnd = true
		    		-- icon:removeFromParentAndCleanup(false)
		    		icon:setVisible(false)
					break
				end
			end
		end
	end

	while true do
		local icon = iconList[1]
		if icon and icon.getInfo then
			if icon:getPositionX() == self._endPosX then
				table.remove(iconList, 1)
			elseif icon.getInfo and icon:getInfo().isEnd then
				table.remove(iconList, 1)
			else
				break
			end
		else
			break
		end 
	end
end

function QUIDialogZhangbichenMusicGame:_onTriggerAutoPlay()
	self._isAutoPlay = not self._isAutoPlay
	self._ccbOwner.sp_select_auto:setVisible(self._isAutoPlay)
end

function QUIDialogZhangbichenMusicGame:_onBoxClicked(e)
	if self:safeCheck() then
		if not self._zhangbichenModel then return end

		local serverInfo = self._zhangbichenModel:getServerInfo()
	    local rewardIdDic = {}
		for _, id in ipairs(serverInfo.rewardIds or {}) do
			rewardIdDic[tostring(id)] = true
		end

		local box = e.box
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

			self._zhangbichenModel:zhangbichenFormalScoreRewardRequest(info.id, function(data)
					if data and data.prizes then
						awards = {}
						for _, value in ipairs(data.prizes) do 
							table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
						end
					end
			        app:alertAwards({awards = awards, title = "恭喜您获得音符奖励"})
			        if self:safeCheck() then
			        	self:refreshInfo()
			        end
				end)
		end
	end
end

function QUIDialogZhangbichenMusicGame:_onTriggeShop(  )
	app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.musicShop)
end

function QUIDialogZhangbichenMusicGame:_onTriggerRule(  )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMusicGameRule"})
end
return QUIDialogZhangbichenMusicGame