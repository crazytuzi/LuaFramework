-- 
-- Kumo.Wang
-- Silves大斗魂场主界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaMain = class("QUIDialogSilvesArenaMain", QUIDialog)

local QUIWidgetChat = import("..widgets.QUIWidgetChat")
local QUIViewController = import("..QUIViewController")
local QChatData = import("...models.chatdata.QChatData")
local QSilvesDefenseArrangement = import("...arrangement.QSilvesDefenseArrangement")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local QUIWidgetSilvesArenaRestClient = import("..widgets.QUIWidgetSilvesArenaRestClient")
local QUIWidgetSilvesArenaTeamClient = import("..widgets.QUIWidgetSilvesArenaTeamClient")
local QUIWidgetSilvesArenaFightingClient = import("..widgets.QUIWidgetSilvesArenaFightingClient")
local QUIWidgetSilvesArenaAgainstClient = import("..widgets.QUIWidgetSilvesArenaAgainstClient")
local QUIWidgetSilvesArenaPeakGroupClient = import("..widgets.QUIWidgetSilvesArenaPeakGroupClient")
local QUIWidgetSilvesArenaPeakAgainstClient = import("..widgets.QUIWidgetSilvesArenaPeakAgainstClient")

function QUIDialogSilvesArenaMain:ctor(options)
	local ccbFile = "Dialog_SilvesArena_Main.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerShop", callback = handler(self, self._onTriggerShop)},
		{ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)}, 
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerHistoryPeak", callback = handler(self, self._onTriggerHistoryPeak)},
		{ccbCallbackName = "onTriggerStakeRecord", callback = handler(self, self._onTriggerStakeRecord)},
		{ccbCallbackName = "onTriggerPeakRecord", callback = handler(self, self._onTriggerPeakRecord)},
	}
	QUIDialogSilvesArenaMain.super.ctor(self,ccbFile,callBacks,options)

	if options then
		self._openCallback = options.openCallback
	end

    self._sacle = CalculateUIBgSize(self._ccbOwner.node_bg, 1024)
    if self._sacle <= 1.25 then
    	self._sacle = 1.25
    end
	self._ccbOwner.node_bg:setScale(self._sacle)

    self._ccbOwner.node_effect:setScale(self._sacle / 1.25) -- 这里放的特效是以1136为背景尺寸制作的。

    self._ccbOwner.node_effect_bg:setScale(self._sacle) -- 这里放的特效是以1024为背景尺寸制作的。
    self._ccbOwner.node_effect_fg:setScale(self._sacle) -- 这里放的特效是以1024为背景尺寸制作的。

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_rank)
    q.setButtonEnableShadow(self._ccbOwner.btn_record)
    q.setButtonEnableShadow(self._ccbOwner.btn_award)
    q.setButtonEnableShadow(self._ccbOwner.btn_shop)
    q.setButtonEnableShadow(self._ccbOwner.btn_historyPeak)
    q.setButtonEnableShadow(self._ccbOwner.btn_stake_record)
    q.setButtonEnableShadow(self._ccbOwner.btn_peak_record)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.setBackHomeBtnVisible then page:setBackHomeBtnVisible(false) end

    local isNotEnter = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SILVES_ARENA)
    if isNotEnter then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SILVES_ARENA)
    end
    
	self:_init()
end

function QUIDialogSilvesArenaMain:viewDidAppear()
	QUIDialogSilvesArenaMain.super.viewDidAppear(self)

	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.STATE_UPDATE, handler(self, self._updateStateHandler))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_FIGHT_END_ALL, handler(self, self._updateStateHandler))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_TEAM_AWARD, handler(self, self._updateRedTips))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_UPDATE, handler(self, self._updateStateHandler))
    self._silvesArenaProxy:addEventListener(remote.silvesArena.TEAM_UPDATE, handler(self, self._updateMyTeamInfo))

    -- 显示聊天信息
    self:setChatInfo()
	self:_updateState(true)
end

function QUIDialogSilvesArenaMain:viewWillDisappear()
	QUIDialogSilvesArenaMain.super.viewWillDisappear(self)
	self:removeBackEvent()
	
    self._silvesArenaProxy:removeAllEventListeners()

	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
    
    if self._timeHideChatScheduler ~= nil then
        scheduler.unscheduleGlobal(self._timeHideChatScheduler)
        self._timeHideChatScheduler = nil
    end

    if self._peakInfoScheduler ~= nil then
		scheduler.unscheduleGlobal(self._peakInfoScheduler)
		self._peakInfoScheduler = nil
	end
end

function QUIDialogSilvesArenaMain:_init()
	self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
	self._waitingDoorSize = self._ccbOwner.node_waiting_door_size:getContentSize()
	self._fightingScale = self._waitingDoorSize.height / self._ccbOwner.sp_bg_fighting:getContentSize().height
	self._waitingScaleX = display.width / self._waitingDoorSize.width

	self._restDoorSize = self._ccbOwner.node_rest_door_size:getContentSize()
	self._waitingScale = self._restDoorSize.height / self._ccbOwner.sp_bg_rest:getContentSize().height
	self._restScaleX = display.width / self._restDoorSize.width

	self._nodeSmallWaitingY = 120
	self._nodeSmallFightingY = 80
	
	self._peakInfoSchedulerCount = 0 -- 16强结果后端没有给的话，会每秒请求一次数据，连续10次

	self._ccbOwner.sp_peak_record_tips:setVisible(false)
	
	self._ccbOwner.node_btn_stake_record:setVisible(false)
	self._ccbOwner.node_btn_peak_record:setVisible(false)
	self._ccbOwner.node_btn_award:setVisible(true)
	self._ccbOwner.node_btn_record:setVisible(true)

	self:_updateCountdown()
	self:_updateRedTips()
	self:_updateMyDefenseTeam()
	self:_updateMyDefenseTeamReplayData()
	self:_updateMyTeamInfo()
end

function QUIDialogSilvesArenaMain:setChatInfo()
    if self._chat == nil then
        self._chat = QUIWidgetChat.new({state = QUIWidgetChat.STATE_TEAM, inChannelState = CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES})
        self._ccbOwner.node_chat:addChild(self._chat)
        self._chat:setChatAreaVisible(true)

        if self._timeHideChatScheduler ~= nil then
            scheduler.unscheduleGlobal(self._timeHideChatScheduler)
            self._timeHideChatScheduler = nil
        end
        self._timeHideChatScheduler = scheduler.performWithDelayGlobal(function()
            self._chat:setChatAreaVisible(false)
        end, 5)

    end
end

function QUIDialogSilvesArenaMain:_updateStateHandler()
	self:_updateState()
end

-- @isSkipGetInfo: 在进入功能的时候，不用再次拉取数据，因为在进来前已经拉过了，提高界面的流畅性
function QUIDialogSilvesArenaMain:_updateState(isSkipGetInfo)
	self:_updateRedTips()

	local state = remote.silvesArena:getCurState()
	print("[_updateState.state] ", state, isSkipGetInfo)
	if state == remote.silvesArena.STATE_PLAY then
		-- 海选赛
		local isEnterFighting = remote.silvesArena:isEnterFighting()
		if isEnterFighting then
			self:_playEnterFightingEffect()
		else
			self:_updateViewByState(state)
		end
	elseif state == remote.silvesArena.STATE_READY then
		-- 报名阶段
		self:_updateViewByState(state)
	elseif state == remote.silvesArena.STATE_PEAK then
		-- 巅峰赛
		if self._openCallback then
			self._openCallback()
			self._openCallback = nil
			self:getOptions().openCallback = nil
			return
		end
		local peakState = remote.silvesArena:getCurPeakState()
		local isEnterPeakFighting = remote.silvesArena:isEnterPeakFighting()
		print("[_updateState.peakState] ", peakState, isEnterPeakFighting)
		if isEnterPeakFighting then
			self:_showPlayStateView()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakTop16Poster",
				options = {callback = handler(self, self._playEnterPeakFightingEffect)}}, {isPopCurrentDialog = false})	
		else
			if not isSkipGetInfo and (peakState == remote.silvesArena.PEAK_8_IN_4 
				or peakState == remote.silvesArena.PEAK_READY_TO_4 
				or peakState == remote.silvesArena.PEAK_READY_TO_FINAL) then
				remote.silvesArena:silvesArenaGetMainInfoRequest(function()
					if self:safeCheck() then
						self:_updateViewByState(state, peakState)
					end
				end)
			else
				self:_updateViewByState(state, peakState)
			end
		end
	elseif state == remote.silvesArena.STATE_REST then
		-- 休赛期
		self:_updateViewByState(state)
	elseif state == remote.silvesArena.STATE_END then
		print("remote.silvesArena.isInBattle = ", remote.silvesArena.isInBattle)
		if not remote.silvesArena.isInBattle and q.isEmpty(remote.silvesArena.fightInfo) then
			local _, cdStr = remote.silvesArena:getCountdown()
			app.tip:floatTip("当前西尔维斯海选赛正在进行结算奖励，请 "..cdStr.." 后再进")
			self:onTriggerHomeHandler()
		else
			self:_updateViewByState(state)
		end
	else
		self:_updateViewByState(state)
	end
end

function QUIDialogSilvesArenaMain:_playEnterPeakFightingEffect()
	-- init view
	self._ccbOwner.node_effect:removeAllChildren()
	self._ccbOwner.node_effect_bg:removeAllChildren()
	self._ccbOwner.node_effect_fg:removeAllChildren()

	self._ccbOwner.node_view:setVisible(false)

	local offsetAPY = 0.25
	local offsetY = self._ccbOwner.sp_bg_fighting:getContentSize().height * offsetAPY
	self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, 0 + offsetY))
	self._ccbOwner.sp_bg_fighting:setAnchorPoint(ccp(0.5, 0.5 + offsetAPY))
	self._ccbOwner.sp_bg_fighting:setOpacity(255)
	self._ccbOwner.sp_bg_fighting:setScale(1)
	self._ccbOwner.sp_bg_fighting:stopAllActions()
	self._ccbOwner.sp_bg_fighting:setVisible(true)

	-- actions
	local fightingActiontime = 0.3
	local fightingScale = 6
	local fightingActions = CCArray:create()
	fightingActions:addObject(CCScaleTo:create(fightingActiontime, fightingScale))
	fightingActions:addObject(CCMoveTo:create(fightingActiontime, ccp(0, 0)))

	local actions = CCArray:create()
	actions:addObject(CCSpawn:create(fightingActions))
    actions:addObject(CCCallFunc:create(function() 
    	if self:safeCheck() then
			local fcaEffect = QUIWidgetFcaAnimation.new("fca/jinmen_shanbai_1", "res")
			fcaEffect:setScale(fightingScale)
			fcaEffect:setPosition(ccp(-10, -10))
			fcaEffect:playAnimation("animation", false)
			fcaEffect:setEndCallback(function()
				print("activateEffectFunc effect end")
				self._ccbOwner.sp_bg_fighting:setVisible(false)
				self._ccbOwner.sp_bg_peak:setVisible(true)
				fcaEffect:removeFromParent()
				self:_updateState(true)
			end)
			self._ccbOwner.node_waiting:addChild(fcaEffect)
    	end
    end))			
    self._ccbOwner.sp_bg_fighting:runAction(CCSequence:create(actions))
end

function QUIDialogSilvesArenaMain:_playEnterFightingEffect()
	-- init view
	self._ccbOwner.node_effect:removeAllChildren()
	self._ccbOwner.node_effect_bg:removeAllChildren()
	self._ccbOwner.node_effect_fg:removeAllChildren()
	self._ccbOwner.node_view:setVisible(false)
	self._ccbOwner.sp_waiting_door_words:setVisible(false)
	self._ccbOwner.sp_bg_against:setVisible(false)

	self._ccbOwner.node_waiting:setPosition(ccp(0, 0))
	self._ccbOwner.node_waiting:setOpacity(255)
	self._ccbOwner.node_waiting:setScale(1)
	self._ccbOwner.node_waiting:stopAllActions()
	self._ccbOwner.node_waiting:setVisible(true)

	self._ccbOwner.sp_bg_waiting:setPosition(ccp(0, 0))
	self._ccbOwner.sp_bg_waiting:setOpacity(255)
	self._ccbOwner.sp_bg_waiting:setScale(1)
	self._ccbOwner.sp_bg_waiting:stopAllActions()
	self._ccbOwner.sp_bg_waiting:setVisible(true)
	
	self._ccbOwner.ly_dark_mask_fighting:setPosition(ccp(0, 0))
	self._ccbOwner.ly_dark_mask_fighting:setOpacity(100)
	self._ccbOwner.ly_dark_mask_fighting:setScale(1)
	self._ccbOwner.ly_dark_mask_fighting:stopAllActions()
	self._ccbOwner.ly_dark_mask_fighting:setVisible(true)

	self._ccbOwner.sp_waiting_door:setPosition(ccp(0, 77))
	self._ccbOwner.sp_waiting_door:setOpacity(255)
	self._ccbOwner.sp_waiting_door:setScale(1)
	self._ccbOwner.sp_waiting_door:stopAllActions()
	self._ccbOwner.sp_waiting_door:setVisible(true)

	self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, self._nodeSmallFightingY))
	self._ccbOwner.sp_bg_fighting:setOpacity(255)
	self._ccbOwner.sp_bg_fighting:setScale(self._fightingScale)
	self._ccbOwner.sp_bg_fighting:stopAllActions()
	self._ccbOwner.sp_bg_fighting:setVisible(true)

	self._ccbOwner.sp_bg_rest:setVisible(false)

	-- actions
	local doorActions = CCArray:create()
	doorActions:addObject(CCMoveTo:create(1, ccp(0, 59 + self._waitingDoorSize.height)))
    doorActions:addObject(CCCallFunc:create(function() 
    	if self:safeCheck() then
    		self._ccbOwner.sp_waiting_door:setVisible(false)

    		local waitingActiontime = 0.5
			local fightingActiontime = 0.2

    		local waitingActions = CCArray:create()
		    waitingActions:addObject(CCScaleTo:create(waitingActiontime, self._waitingScaleX))
		    waitingActions:addObject(CCMoveTo:create(waitingActiontime, ccp(0, -self._nodeSmallFightingY *  self._waitingScaleX)))

		    local fightingActions = CCArray:create()
		    fightingActions:addObject(CCScaleTo:create(fightingActiontime, 1))
		    fightingActions:addObject(CCMoveTo:create(fightingActiontime, ccp(0, 0)))

		    local darkMaskActions = CCArray:create()
		    darkMaskActions:addObject(CCFadeOut:create(fightingActiontime))
		    darkMaskActions:addObject(CCDelayTime:create(waitingActiontime - fightingActiontime))
		    darkMaskActions:addObject(CCCallFunc:create(function() 
				if self:safeCheck() then
				   	self._ccbOwner.sp_bg_waiting:setVisible(false)
				   	self._ccbOwner.ly_dark_mask_fighting:setVisible(false)
					self:_updateState(true)
				end
			end))
		    print("[time]", waitingActiontime, fightingActiontime)
    		self._ccbOwner.sp_bg_waiting:runAction(CCSpawn:create(waitingActions))
    		self._ccbOwner.sp_bg_fighting:runAction(CCSpawn:create(fightingActions))
    		self._ccbOwner.ly_dark_mask_fighting:runAction(CCSequence:create(darkMaskActions))
    	end
    end))
    self._ccbOwner.sp_waiting_door:runAction(CCSequence:create(doorActions))
    q.shakeScreen(8, 0.3, 3)
end

-- function QUIDialogSilvesArenaMain:_playLeaveFightingEffect()
-- 	-- init view
-- 	self._ccbOwner.node_effect:removeAllChildren()
-- 	self._ccbOwner.node_view:setVisible(false)
-- 	self._ccbOwner.sp_waiting_door_words:setVisible(false)
-- 	self._ccbOwner.sp_bg_against:setVisible(false)

-- 	self._ccbOwner.node_waiting:setPosition(ccp(0, 0))
-- 	self._ccbOwner.node_waiting:setOpacity(255)
-- 	self._ccbOwner.node_waiting:setScale(1)
-- 	self._ccbOwner.node_waiting:stopAllActions()
-- 	self._ccbOwner.node_waiting:setVisible(true)

-- 	self._ccbOwner.sp_bg_waiting:setPosition(ccp(0, -self._nodeSmallFightingY * self._waitingScaleX))
-- 	self._ccbOwner.sp_bg_waiting:setOpacity(255)
-- 	self._ccbOwner.sp_bg_waiting:setScale(self._waitingScaleX)
-- 	self._ccbOwner.sp_bg_waiting:stopAllActions()
-- 	self._ccbOwner.sp_bg_waiting:setVisible(true)
	
-- 	self._ccbOwner.ly_dark_mask_fighting:setPosition(ccp(0, 0))
-- 	self._ccbOwner.ly_dark_mask_fighting:setOpacity(0)
-- 	self._ccbOwner.ly_dark_mask_fighting:setScale(1)
-- 	self._ccbOwner.ly_dark_mask_fighting:stopAllActions()
-- 	self._ccbOwner.ly_dark_mask_fighting:setVisible(true)

-- 	self._ccbOwner.sp_waiting_door:setPosition(ccp(0, 77 + self._waitingDoorSize.height))
-- 	self._ccbOwner.sp_waiting_door:setOpacity(255)
-- 	self._ccbOwner.sp_waiting_door:setScale(1)
-- 	self._ccbOwner.sp_waiting_door:stopAllActions()
-- 	self._ccbOwner.sp_waiting_door:setVisible(false)

-- 	self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, 0))
-- 	self._ccbOwner.sp_bg_fighting:setOpacity(255)
-- 	self._ccbOwner.sp_bg_fighting:setScale(1)
-- 	self._ccbOwner.sp_bg_fighting:stopAllActions()
-- 	self._ccbOwner.sp_bg_fighting:setVisible(true)

-- 	self._ccbOwner.sp_bg_rest:setVisible(false)

-- 	-- actions
-- 	local waitingActiontime = 0.5
-- 	local fightingDelaytime = 0.3
-- 	local fightingActiontime = 0.2

-- 	local waitingActions = CCArray:create()
--     waitingActions:addObject(CCScaleTo:create(waitingActiontime, 1))
--     waitingActions:addObject(CCMoveTo:create(waitingActiontime, ccp(0, 0)))

--     local fightingActions = CCArray:create()
--     fightingActions:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(fightingDelaytime), CCScaleTo:create(fightingActiontime, self._fightingScale)))
--     fightingActions:addObject(CCMoveTo:create(fightingActiontime, ccp(0, self._nodeSmallFightingY)))

--     local darkMaskActions = CCArray:create()
--     darkMaskActions:addObject(CCFadeTo:create(fightingActiontime, 100))
--     darkMaskActions:addObject(CCDelayTime:create(waitingActiontime - fightingActiontime))
--     darkMaskActions:addObject(CCCallFunc:create(function() 
-- 		if self:safeCheck() then
-- 		   	local doorActions = CCArray:create()
-- 			doorActions:addObject(CCMoveTo:create(1, ccp(0, 59)))
-- 		    doorActions:addObject(CCCallFunc:create(function() 
-- 		    	if self:safeCheck() then
-- 					self._ccbOwner.sp_bg_fighting:setVisible(false)
-- 		    		self:_updateState()
-- 		    	end
-- 		    end))
-- 		    self._ccbOwner.sp_waiting_door:setVisible(true)
-- 		    self._ccbOwner.sp_waiting_door:runAction(CCSequence:create(doorActions))
-- 		    q.shakeScreen(8, 0.3, 3)
--     	end
-- 	end))

--     print("[time]", waitingActiontime, fightingActiontime)
-- 	self._ccbOwner.sp_bg_waiting:runAction(CCSpawn:create(waitingActions))
-- 	self._ccbOwner.sp_bg_fighting:runAction(CCSpawn:create(fightingActions))
-- 	self._ccbOwner.ly_dark_mask_fighting:runAction(CCSequence:create(darkMaskActions))
-- end

function QUIDialogSilvesArenaMain:_updateViewByState(state, peakState)
	print("[QUIDialogSilvesArenaMain:_updateViewByState] ", state, peakState)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then page.topBar:showWithSilvesArena() end
	self:addBackEvent(false)

	if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_END then
		self:_showPlayStateView()
	elseif state == remote.silvesArena.STATE_PEAK then
		self._ccbOwner.node_waiting:setPosition(ccp(0, 0))
		self._ccbOwner.node_waiting:setOpacity(255)
		self._ccbOwner.node_waiting:setScale(1)
		self._ccbOwner.node_waiting:stopAllActions()
		self._ccbOwner.node_waiting:setVisible(true)

		self._ccbOwner.sp_bg_waiting:stopAllActions()
		self._ccbOwner.sp_bg_waiting:setVisible(false)
		self._ccbOwner.ly_dark_mask_fighting:setVisible(false)
		self._ccbOwner.sp_waiting_door:stopAllActions()
		self._ccbOwner.sp_waiting_door:setVisible(false)
		self._ccbOwner.sp_waiting_door_words:setVisible(false)

		self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, 0))
		self._ccbOwner.sp_bg_fighting:setOpacity(255)
		self._ccbOwner.sp_bg_fighting:setScale(1)
		self._ccbOwner.sp_bg_fighting:stopAllActions()
		self._ccbOwner.sp_bg_fighting:setVisible(false)

		self._ccbOwner.sp_bg_against:setVisible(false)

		self._ccbOwner.sp_bg_peak:setVisible(true)

		self._ccbOwner.sp_bg_rest:stopAllActions()
		self._ccbOwner.sp_bg_rest:setVisible(false)

		self._ccbOwner.node_effect:removeAllChildren()
		self._ccbOwner.node_effect_bg:removeAllChildren()
		self._ccbOwner.node_effect_fg:removeAllChildren()

		-- if peakState == remote.silvesArena.PEAK_READY_TO_16
		-- 		or peakState == remote.silvesArena.PEAK_WAIT_TO_16
		-- 		or peakState == remote.silvesArena.PEAK_16_IN_8
		-- 		or peakState == remote.silvesArena.PEAK_8_IN_4 then

			local fcaEffect = QUIWidgetFcaAnimation.new("fca/xews_bg_2", "res")
			self._ccbOwner.node_effect_fg:addChild(fcaEffect)
			fcaEffect:playAnimation("animation", true)
		-- end

		local fcaEffect = QUIWidgetFcaAnimation.new("fca/xews_bg_1", "res")
		self._ccbOwner.node_effect_bg:addChild(fcaEffect)
		fcaEffect:playAnimation("animation", true)
		fcaEffect:setPositionY(-20)
	elseif state == remote.silvesArena.STATE_READY then
		self._ccbOwner.node_waiting:setPosition(ccp(0, 0))
		self._ccbOwner.node_waiting:setOpacity(255)
		self._ccbOwner.node_waiting:setScale(1)
		self._ccbOwner.node_waiting:stopAllActions()
		self._ccbOwner.node_waiting:setVisible(true)
		self._ccbOwner.sp_waiting_door_words:setVisible(false)

		self._ccbOwner.sp_bg_waiting:setPosition(ccp(0, 0))
		self._ccbOwner.sp_bg_waiting:setOpacity(255)
		self._ccbOwner.sp_bg_waiting:setScale(1)
		self._ccbOwner.sp_bg_waiting:stopAllActions()
		self._ccbOwner.sp_bg_waiting:setVisible(true)
		self._ccbOwner.ly_dark_mask_fighting:setVisible(false)
		self._ccbOwner.sp_waiting_door:setPosition(ccp(0, 77))
		self._ccbOwner.sp_waiting_door:setOpacity(255)
		self._ccbOwner.sp_waiting_door:setScale(1)
		self._ccbOwner.sp_waiting_door:stopAllActions()
		self._ccbOwner.sp_waiting_door:setVisible(true)

		self._ccbOwner.sp_bg_fighting:stopAllActions()
		self._ccbOwner.sp_bg_fighting:setVisible(false)

		self._ccbOwner.sp_bg_against:setVisible(false)

		self._ccbOwner.sp_bg_rest:stopAllActions()
		self._ccbOwner.sp_bg_rest:setVisible(false)

		self._ccbOwner.sp_bg_peak:setVisible(false)

		self._ccbOwner.node_effect:removeAllChildren()
		self._ccbOwner.node_effect_bg:removeAllChildren()
		self._ccbOwner.node_effect_fg:removeAllChildren()

		local fcaEffect = QUIWidgetFcaAnimation.new("fca/xierweisi_2_fire", "res")
		self._ccbOwner.node_effect:addChild(fcaEffect)
		fcaEffect:playAnimation("animation", true)

		if not remote.silvesArena or not remote.silvesArena.myTeamInfo or remote.silvesArena.myTeamInfo.status ~= 1 then
			local fcaEffectDoor = QUIWidgetFcaAnimation.new("fca/xierweisi_2_door", "res")
			self._ccbOwner.node_effect:addChild(fcaEffectDoor)
			fcaEffectDoor:playAnimation("animation", true)
			self._ccbOwner.sp_waiting_door_words:setVisible(true)
		end
	else
		self._ccbOwner.node_waiting:stopAllActions()
		self._ccbOwner.node_waiting:setVisible(false)

		self._ccbOwner.sp_bg_waiting:stopAllActions()
		self._ccbOwner.sp_bg_waiting:setVisible(false)
		self._ccbOwner.ly_dark_mask_fighting:setVisible(false)
		self._ccbOwner.sp_waiting_door:stopAllActions()
		self._ccbOwner.sp_waiting_door:setVisible(false)
		self._ccbOwner.sp_waiting_door_words:setVisible(false)

		self._ccbOwner.sp_bg_fighting:stopAllActions()
		self._ccbOwner.sp_bg_fighting:setVisible(false)

		self._ccbOwner.sp_bg_against:setVisible(false)

		self._ccbOwner.sp_bg_rest:setPosition(ccp(0, 0))
		self._ccbOwner.sp_bg_rest:setOpacity(255)
		self._ccbOwner.sp_bg_rest:setScale(1)
		self._ccbOwner.sp_bg_rest:stopAllActions()
		self._ccbOwner.sp_bg_rest:setVisible(true)

		self._ccbOwner.sp_bg_peak:setVisible(false)

		self._ccbOwner.node_effect:removeAllChildren()
		self._ccbOwner.node_effect_bg:removeAllChildren()
		self._ccbOwner.node_effect_fg:removeAllChildren()

		local fcaEffect = QUIWidgetFcaAnimation.new("fca/xews_bg_1", "res")
		self._ccbOwner.node_effect_bg:addChild(fcaEffect)
		fcaEffect:playAnimation("animation", true)
		fcaEffect:setPositionY(100)
	end
		
	print(self._curState, self._curPeakState, self._isReadyFight, remote.silvesArena:isReadyFightState())
	if not peakState and self._curState == state and self._isReadyFight == remote.silvesArena:isReadyFightState() and self._client and self._client.update then
		print("[QUIDialogSilvesArenaMain:_updateViewByState] update 1")
		self._client:update()
	elseif peakState and self._curPeakState == peakState and self._client and self._client.update then
		print("[QUIDialogSilvesArenaMain:_updateViewByState] update 2")
		self._client:update()
	else
		print("[QUIDialogSilvesArenaMain:_updateViewByState] new")
		if self._chat then
			self._chat:setVisible(true)
		end
		self._ccbOwner.node_fighting_view:removeAllChildren()
		self._ccbOwner.node_waiting_view:removeAllChildren()
		self._ccbOwner.node_btn_stake_record:setVisible(false)
		self._ccbOwner.node_btn_peak_record:setVisible(false)
		self._ccbOwner.node_btn_award:setVisible(true)
		self._ccbOwner.node_btn_record:setVisible(true)
		self._client = nil
		self._isReadyFight = false
		if state == remote.silvesArena.STATE_PLAY then
			-- 海选赛阶段
			if remote.silvesArena:isReadyFightState() then
				self._client = QUIWidgetSilvesArenaAgainstClient.new({scale = self._sacle})
				self._ccbOwner.node_fighting_view:addChild(self._client)
				self._isReadyFight = true
				if self._chat then
					self._chat:setVisible(false)
				end
			else
				self._client = QUIWidgetSilvesArenaFightingClient.new()
				self._ccbOwner.node_fighting_view:addChild(self._client)
			end
		elseif state == remote.silvesArena.STATE_PEAK then
			-- 巅峰赛阶段
			if self._chat then
				self._chat:setVisible(false)
			end
			self._ccbOwner.node_btn_stake_record:setVisible(true)
			self._ccbOwner.node_btn_peak_record:setVisible(true)
			self._ccbOwner.node_btn_award:setVisible(false)
			self._ccbOwner.node_btn_record:setVisible(false)
			if peakState == remote.silvesArena.PEAK_READY_TO_16
				or peakState == remote.silvesArena.PEAK_WAIT_TO_16
				or peakState == remote.silvesArena.PEAK_16_IN_8
				or peakState == remote.silvesArena.PEAK_8_IN_4 then
				self._client = QUIWidgetSilvesArenaPeakGroupClient.new()
			else
				self._client = QUIWidgetSilvesArenaPeakAgainstClient.new({scale = self._sacle})
			end
			self._ccbOwner.node_fighting_view:addChild(self._client)
		elseif state == remote.silvesArena.STATE_READY then
			-- 报名阶段
			self._client = QUIWidgetSilvesArenaTeamClient.new()
			self._ccbOwner.node_waiting_view:addChild(self._client)
		else
			self._ccbOwner.node_btn_stake_record:setVisible(true)
			self._ccbOwner.node_btn_peak_record:setVisible(true)
			self._ccbOwner.node_btn_award:setVisible(false)
			self._ccbOwner.node_btn_record:setVisible(false)
			-- 结算阶段 or 休赛阶段
			self._client = QUIWidgetSilvesArenaRestClient.new()
			self._ccbOwner.node_waiting_view:addChild(self._client)
		end

		self._curState = state
		self._curPeakState = peakState

		if self._client and self._client.EVENT_CLIENT then
			self._client:addEventListener(self._client.EVENT_CLIENT, self:safeHandler(handler(self, self._onClientHandler)))
		end
	end

	self._ccbOwner.node_btn:setVisible(not self._isReadyFight)
	self._ccbOwner.node_countdown:setVisible(not self._isReadyFight)
	self._ccbOwner.node_view:setVisible(true)

	-- 判断战斗是否继续
	if not remote.silvesArena.isInBattle then
		remote.silvesArena:silvesAutoFightCommandSet()
	end

	if not remote.silvesArena.isInBattle and self._openCallback then
		self._openCallback()
		self._openCallback = nil
		self:getOptions().openCallback = nil
	end

	local isShowPeakChampion = remote.silvesArena:isShowPeakChampion()
	if isShowPeakChampion then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakChampionPoster",
			options = {}}, {isPopCurrentDialog = false})	
	end

	if state == remote.silvesArena.STATE_PEAK then
		self:_checkTutorial()
	end
end

function QUIDialogSilvesArenaMain:_checkTutorial()
    local haveTutorial = false

	if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        if app.tutorial:getStage().silvesArenaPeak == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Statge_SilvesArena_Peak)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end

    return haveTutorial
end

function QUIDialogSilvesArenaMain:onTriggerBackHandler()
	if self._client and self._client.getClassName and self._client:getClassName() == "QUIWidgetSilvesArenaAgainstClient" then
		if q.isEmpty(remote.silvesArena.fightInfo) then
			remote.silvesArena.againstTeamInfo = {}
			self:_updateState()
		else
			app.tip:floatTip("战斗中")
		end
	else
    	self:popSelf()
    end
end

function QUIDialogSilvesArenaMain:_onClientHandler(event)
	if event.name == QUIWidgetSilvesArenaRestClient.EVENT_CLIENT then
		self:_onTriggerRank()
	end
end

function QUIDialogSilvesArenaMain:_updateCountdown()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	local titleStr, timeStr = remote.silvesArena:getCountdown()
	self._ccbOwner.tf_countdown_title:setString(titleStr)
	self._ccbOwner.tf_countdown:setString(timeStr)
	self._countdownSchedule = scheduler.scheduleGlobal(function()
		if self:safeCheck() then
			self:_updateCountdown()
		end
	end, 1)
end

function QUIDialogSilvesArenaMain:_updateRedTips()
	self._ccbOwner.sp_record_tips:setVisible(remote.silvesArena:checkRecordRedTips())
	self._ccbOwner.sp_award_tips:setVisible(remote.silvesArena:checkTeamAwardRedTips())
	self._ccbOwner.sp_shop_tips:setVisible(remote.silvesArena:checkShopRedTips())
	-- self._ccbOwner.sp_team_tips:setVisible(remote.silvesArena:checkTeamRedTips())
end

--战队信息处理
function QUIDialogSilvesArenaMain:_updateMyDefenseTeam()
	--设置战队成员
	-- set local instance team to server, server will save at frist time
	-- if server response team not compare local , then save local to server
	local state = remote.silvesArena:getCurState()
    if state == remote.silvesArena.STATE_PLAY or state == remote.silvesArena.STATE_READY then
		remote.silvesArena:checkDefenseTeam()
	elseif state == remote.silvesArena.STATE_PEAK then
		local peakState = remote.silvesArena:getCurPeakState()
        if peakState == remote.silvesArena.PEAK_READY_TO_16
            or peakState == remote.silvesArena.PEAK_READY_TO_4
            or peakState == remote.silvesArena.PEAK_READY_TO_FINAL then

			remote.silvesArena:checkDefenseTeam()
        end
	end
end

--战队信息处理
function QUIDialogSilvesArenaMain:_updateMyDefenseTeamReplayData()
	if remote.silvesArena.myDefenseTeamBattleFormation and remote.silvesArena:checkCanChangeTeam() then
		remote.silvesArena:silvesArenaChangeReplayDataRequest()
	end
end

function QUIDialogSilvesArenaMain:_updateMyTeamInfo()
	local myTeamInfo = remote.silvesArena.myTeamInfo
	if q.isEmpty(myTeamInfo) then
		-- 个人
		self._ccbOwner.ccb_my_team:setVisible(true)
		self._ccbOwner.ccb_gang_team:setVisible(false)

		local force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SILVES_ARENA_TEAM, false)
		local fontInfo = db:getForceColorByForce(tonumber(force), true)
		local num, unit = q.convertLargerNumber(force)
		self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
		self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)

		self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
		self._ccbOwner.sp_team_tips:setVisible(not remote.teamManager:checkTeamStormIsFull(remote.teamManager.SILVES_ARENA_TEAM))
	else
		-- 团队
		self._ccbOwner.ccb_my_team:setVisible(false)
		self._ccbOwner.ccb_gang_team:setVisible(true)

		local averageForce = 0
		if not q.isEmpty(myTeamInfo) then
			local totalForce, totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(myTeamInfo, true)
			if totalForce and totalNumber then
				averageForce = totalForce / totalNumber
			end
		end

		local fontInfo = db:getForceColorByForce(tonumber(averageForce), true)
		local num, unit = q.convertLargerNumber(averageForce)
		self._ccbOwner.tf_team_average_force:setString(num..(unit or ""))
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_team_average_force:setColor(ccc3(color[1], color[2], color[3]))
	end
	
end

function QUIDialogSilvesArenaMain:_onTriggerRank(event)
	if event then
		app.sound:playSound("common_small")
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "silvesArena"}}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaMain:_onTriggerAward()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesTeamScore"})   
end

function QUIDialogSilvesArenaMain:_onTriggerShop()
    app.sound:playSound("common_small")
    
    remote.stores:openShopDialog(SHOP_ID.silvesShop)
end

function QUIDialogSilvesArenaMain:_onTriggerRecord()
    app.sound:playSound("common_small")
    
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaBattleRecord", 
		options = {reportType = REPORT_TYPE.SILVES_ARENA}}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaMain:_onTriggerHelp()
    app.sound:playSound("common_small")
    local myInfo = {}
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilvesArenaHelp",
    	options = {info = myInfo}})
end

function QUIDialogSilvesArenaMain:_setMyTeam()
	if self._client and self._client.getClassName and self._client:getClassName() == "QUIWidgetSilvesArenaAgainstClient" then
		if not q.isEmpty(remote.silvesArena.fightInfo) then
			app.tip:floatTip("战斗中")
			return
		end
    end

    local state = remote.silvesArena:getCurState()
   	local silvesDefenseArrangement = QSilvesDefenseArrangement.new({teamKey = remote.teamManager.SILVES_ARENA_TEAM})
    if state == remote.silvesArena.STATE_PEAK then
        local peakState = remote.silvesArena:getCurPeakState()
        if peakState == remote.silvesArena.PEAK_READY_TO_16
            or peakState == remote.silvesArena.PEAK_READY_TO_4
            or peakState == remote.silvesArena.PEAK_READY_TO_FINAL then

			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamArrangement",
				options = {arrangement = silvesDefenseArrangement}})
		else
			app.tip:floatTip("当前时段不能修改阵容")
        end
    else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTeamArrangement",
			options = {arrangement = silvesDefenseArrangement}})
    end
end

function QUIDialogSilvesArenaMain:_onTriggerTeam(event, target)
	if event ~= nil then
    	app.sound:playSound("common_small")
    end
	if target == self._ccbOwner.btn_team then
		if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
		self:_setMyTeam()
	elseif target == self._ccbOwner.btn_gang_team then
		if q.buttonEventShadow(event, self._ccbOwner.btn_gang_team) == false then return end
		self:_setGangTeam()
	end
end	

function QUIDialogSilvesArenaMain:_setGangTeam()
	if self._client and self._client.getClassName and self._client:getClassName() == "QUIWidgetSilvesArenaAgainstClient" then
		if not q.isEmpty(remote.silvesArena.fightInfo) then
			app.tip:floatTip("战斗中")
			return
		end
		self._client:_onTriggerSet()
		return
    end

	if q.isEmpty(remote.silvesArena.myTeamInfo) then 
		app.tip:floatTip("尚未组队")
		return 
	end

	if remote.silvesArena.myTeamInfo then
		local _module = remote.silvesArena.BATTLEFORMATION_MODULE_NORMAL
		if remote.silvesArena.myTeamInfo and remote.silvesArena.myTeamInfo.leader and remote.silvesArena.myTeamInfo.leader.userId and remote.silvesArena.myTeamInfo.leader.userId == remote.user.userId then
			_module = remote.silvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER
		end
		remote.silvesArena:silvesArenaQueryTeamFighterRequest(remote.silvesArena.myTeamInfo.teamId, nil, function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
				options = {module = _module}}, {isPopCurrentDialog = false})	
		end)
	end
end

function QUIDialogSilvesArenaMain:_onTriggerStakeRecord()
	app.sound:playSound("common_small")

	remote.silvesArena:silvesPeakGetMyBetInfoRequest(function(data)
	    local myBetList = {}
		if data.silvesArenaInfoResponse then
	    	myBetList = data.silvesArenaInfoResponse.silvesPeakUserBetInfo or {}
	    end
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaStakeRecord",
    		options = {betList = myBetList}}, {isPopCurrentDialog = false})
    end)
end

function QUIDialogSilvesArenaMain:_onTriggerPeakRecord()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakBattleRecord",
		options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogSilvesArenaMain:_onTriggerHistoryPeak()
	app.sound:playSound("common_small")

	if not remote.silvesArena.championTeamInfo then
		remote.silvesArena:silvesPeakGetChampionTeamInfoRequest(function()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakHistory",
				options = {}}, {isPopCurrentDialog = false})
		end)
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaPeakHistory",
			options = {}}, {isPopCurrentDialog = false})
	end
end

function QUIDialogSilvesArenaMain:_showPlayStateView()
	self._ccbOwner.node_waiting:setPosition(ccp(0, 0))
	self._ccbOwner.node_waiting:setOpacity(255)
	self._ccbOwner.node_waiting:setScale(1)
	self._ccbOwner.node_waiting:stopAllActions()
	self._ccbOwner.node_waiting:setVisible(true)

	self._ccbOwner.sp_bg_waiting:stopAllActions()
	self._ccbOwner.sp_bg_waiting:setVisible(false)
	self._ccbOwner.ly_dark_mask_fighting:setVisible(false)
	self._ccbOwner.sp_waiting_door:stopAllActions()
	self._ccbOwner.sp_waiting_door:setVisible(false)
	self._ccbOwner.sp_waiting_door_words:setVisible(false)

	if remote.silvesArena:isReadyFightState() then
		self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, 0))
		self._ccbOwner.sp_bg_fighting:setOpacity(255)
		self._ccbOwner.sp_bg_fighting:setScale(1)
		self._ccbOwner.sp_bg_fighting:stopAllActions()
		self._ccbOwner.sp_bg_fighting:setVisible(false)

		self._ccbOwner.sp_bg_against:setVisible(true)
	else
		self._ccbOwner.sp_bg_fighting:setPosition(ccp(0, 0))
		self._ccbOwner.sp_bg_fighting:setOpacity(255)
		self._ccbOwner.sp_bg_fighting:setScale(1)
		self._ccbOwner.sp_bg_fighting:stopAllActions()
		self._ccbOwner.sp_bg_fighting:setVisible(true)

		self._ccbOwner.sp_bg_against:setVisible(false)
	end

	self._ccbOwner.sp_bg_rest:stopAllActions()
	self._ccbOwner.sp_bg_rest:setVisible(false)

	self._ccbOwner.sp_bg_peak:setVisible(false)

	self._ccbOwner.node_effect:removeAllChildren()
	self._ccbOwner.node_effect_bg:removeAllChildren()
	self._ccbOwner.node_effect_fg:removeAllChildren()

	local fcaEffect = QUIWidgetFcaAnimation.new("fca/xierweisi_3", "res")
	self._ccbOwner.node_effect:addChild(fcaEffect)
	fcaEffect:playAnimation("animation", true)
end

return QUIDialogSilvesArenaMain
