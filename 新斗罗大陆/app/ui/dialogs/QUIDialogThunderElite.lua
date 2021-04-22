--
-- Author: xurui
-- Date: 2015-08-11 15:54:06
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderElite = class("QUIDialogThunderElite", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetThunderMonsterHead = import("..widgets.QUIWidgetThunderMonsterHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QThunderArrangement = import("...arrangement.QThunderArrangement")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogThunderElite:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_Elite.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},  
		{ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFightOne)}   
	}
	QUIDialogThunderElite.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	page:setScalingVisible(false)
    page.topBar:showWithThunder()
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)

	self.isMoving = false

	self._openElite = 0
	self._hisLevel = 0
	self._minNum = 8
	self._maxNum = 0

	self:getMonsterConfig()

    self:setOpenEliteInfo()
	self:setMonsterHead()
	self:setChallengeNum()

	q.setButtonEnableShadow(self._ccbOwner.btn_one_fast)
end

function QUIDialogThunderElite:viewDidAppear()
	QUIDialogThunderElite.super.viewDidAppear(self)
	self._checkItemScheduler = scheduler.performWithDelayGlobal(handler(self, self.checkFirstWin), 0)

	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)

    self._thunderProxy = cc.EventProxy.new(remote.thunder)
    self._thunderProxy:addEventListener(remote.thunder.EVENT_UPDATE_ELITE_BUY_COUNT, handler(self, self.setChallengeNum))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self:addBackEvent(false)
end 

function QUIDialogThunderElite:viewWillDisappear()
	QUIDialogThunderElite.super.viewWillDisappear(self)
 	self.prompt:removeItemEventListener()

	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

    self._thunderProxy:removeAllEventListeners()
    self._thunderProxy = nil

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self:removeBackEvent()
end

function QUIDialogThunderElite:_exitFromBattle()
    self:setOpenEliteInfo()
	self:setMonsterHead()
	self:setChallengeNum()
	self:checkFirstWin()
end

function QUIDialogThunderElite:_fastSuccessed()
	self:setChallengeNum()
end

function QUIDialogThunderElite:setChallengeNum()
	local thunderInfo = remote.thunder:getThunderFighter()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local num = tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) +  tonumber(thunderInfo.thunderEliteChallengeBuyCount) - tonumber(thunderInfo.thunderEliteChallengeTimes)
	self._ccbOwner.challenge_num:setString(num or 0)


    local buyCount = tonumber(thunderInfo.thunderEliteChallengeBuyCount) or 0
	local totalNum = tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) or 0
	self._ccbOwner.node_btn_plus:setVisible(totalNum > buyCount)
end

function QUIDialogThunderElite:setOpenEliteInfo()
	local thunderInfo = remote.thunder:getThunderFighter()
	if not thunderInfo then
		return
	end
	local winNpcs = string.split(thunderInfo.thunderEliteAlreadyWinNpc, ";")
	self._hisLevel = 0
	for _, value in ipairs(winNpcs) do
		local num = tonumber(value) or 0
		if self._hisLevel == 0 or num > self._hisLevel then
			self._hisLevel = num
		end
	end
	self._floor = tonumber(thunderInfo.thunderHistoryMaxFloor)

	if self._floor == 0 then
		self._openElite = 0
		return  
	end
	local rewardIndexs = QStaticDatabase:sharedDatabase():getThunderConfigByLayer(self._floor)
	if rewardIndexs == nil then return end
	local index = 1
	while index < 10000 do 
		if "thunder_elite_"..index == rewardIndexs.elite then
			self._openElite = index 
			break
		end
		index = index + 1
	end

end 

function QUIDialogThunderElite:setMonsterHead() 
	self._currentLevel = self._hisLevel
	if self._currentLevel < self._openElite then self._currentLevel = self._currentLevel + 1 end
	if self._currentLevel == 0 then self._currentLevel = 1 end

	self:initListView()

	self:setCurrentEliteInfo()
end 


function QUIDialogThunderElite:initListView()
	local totalNumber = self._openElite
	totalNumber = (totalNumber + 2)
	if totalNumber < self._minNum then
	 	totalNumber = self._minNum 
	end
	if totalNumber > self._maxNum then
	 	totalNumber = self._maxNum 
	end
	local headIndex = self._currentLevel

    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = false,
	        isVertical = false,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        tailIndex = headIndex,
	        headIndexPosOffset = 100,
	        curOffset = 10,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end

 	self._ccbOwner.node_arrow_left:setVisible(totalNumber > 10)
 	self._ccbOwner.node_arrow_right:setVisible(totalNumber > 10)
end

function QUIDialogThunderElite:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._monsterInfoDict[tostring(index)]
    local config = self._monsterConfigDict[data.monster_id]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetThunderMonsterHead.new()
		item:addEventListener(QUIWidgetThunderMonsterHead.CLICK_MONSTER_HEAD, handler(self, self._clickMonsterHead))

        isCacheNode = false
    end

    info.item = item
	item:setInfo({config = config, index = index, hisLevel = self._hisLevel, openElite = self._openElite})
    info.size = item:getContentSize()


    item:setSelected(index == self._currentLevel)

    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

	return isCacheNode
end

function QUIDialogThunderElite:getMonsterConfig(index)
	if q.isEmpty(self._monsterConfigInfo) then
		self._monsterInfoDict = {}
		self._monsterConfigDict = {}
		local index = 1
		local monsetrInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID("thunder_elite_"..index)
		while monsetrInfo do
			self._monsterInfoDict[tostring(index)] = monsetrInfo
			local monsterConfig = QStaticDatabase:sharedDatabase():getMonstersById(monsetrInfo.monster_id)
			if monsterConfig ~= nil and #monsterConfig > 0 then
				self._monsterConfigDict[monsetrInfo.monster_id] = monsterConfig[1]
			end
			self._maxNum = index
			index = index + 1
			monsetrInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID("thunder_elite_"..index)
		end
	end
end

function QUIDialogThunderElite:setCurrentEliteInfo(isLock)
	local monsetrInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID("thunder_elite_"..self._currentLevel)
	if monsetrInfo == nil then return end

	self._ccbOwner.title_name:setString(monsetrInfo.name)
	self._ccbOwner.first_reward:setString(monsetrInfo.thunder_fd)

	local rewards = string.split(monsetrInfo.thunder_drop, "^")
	if self._itemBox == nil then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.item_node:addChild(self._itemBox)
		self._itemBox:setPromptIsOpen(true)
	end
	self._itemBox:setGoodsInfo(rewards[1], "item", tonumber(rewards[2]))

	local firstIsDone = self._currentLevel <= self._hisLevel
	self._ccbOwner.is_have:setVisible(firstIsDone)
	self._ccbOwner.btn_one:setVisible(firstIsDone)

	self._ccbOwner.node_btn_battle:setVisible(not isLock)
	self._ccbOwner.node_challenge:setVisible(not isLock)

	local num,unit = q.convertLargerNumber(monsetrInfo.thunder_force or 0)
	self._ccbOwner.tf_battle_force:setString(num..unit)

	self:setAvatar(monsetrInfo)
end

function QUIDialogThunderElite:setAvatar(config)
	local monsterConfigs = QStaticDatabase:sharedDatabase():getMonstersById(config.monster_id)
	local monsterConfig = {}
	if monsterConfigs ~= nil and #monsterConfigs > 0 then
		for i,value in pairs(monsterConfigs) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			if value.is_boss then
				monsterConfig = value
			end
		end
	end
	if next(monsterConfig) == nil then
		monsterConfig = monsterConfigs[1]
	end
	if self._avatar == nil then 
		self._avatar = QUIWidgetHeroInformation.new()
		self._ccbOwner.avatar:addChild(self._avatar)
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		-- self._avatar:setProVisible(false)
	end
	self._avatar:setAvatarByHeroInfo(nil, monsterConfig.npc_id, 1)

	-- self:chat(config.description)
end

function QUIDialogThunderElite:chat(str)
	if self._speak == nil then 
		self._speak = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.chat_tips:addChild(self._speak)
	end
	self._speak:playAnimation("effects/chat_tips.ccbi", function (ccbOwner)
		ccbOwner.tf_chat:setString(str)
	end,nil,false)
end

function QUIDialogThunderElite:checkFirstWin()
	local level, info = remote.thunder:getEliteBattleInfo()
	if level == nil then return end

	local num = string.split(info, ";")
	for _, value in pairs(num) do
		if value == tostring(level) then
			return
		end
	end
	local monsetrInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID("thunder_elite_"..level)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderEliteFirstWin" , 
		options = {itemInfo = monsetrInfo}})	
	remote.thunder:setEliteBattleInfo()
end

function QUIDialogThunderElite:_onScrollViewMoving(event)
	if event.name == QScrollView.GESTURE_MOVING then
		self.isMoving = true
	elseif event.name == QScrollView.GESTURE_BEGAN then
		self.isMoving = false
	end
end

function QUIDialogThunderElite:_clickMonsterHead(data)
	if data == nil or self.isMoving then return end
	self._avatar:removeAvatar()

	self._currentLevel = data.index
	self:initListView()
	self:setCurrentEliteInfo(data.isLock)
end

function QUIDialogThunderElite:getRefreshToken(refreshCount)
	local tokeNum = 0

	local refreshInfo = QStaticDatabase:sharedDatabase():getTokenConsumeByType("thunder_elite")
	if refreshInfo ~= nil then
		for _, value in pairs(refreshInfo) do
			if value.consume_times == refreshCount + 1 then
				return value.money_num, value.money_type
			end
		end
	end
	return refreshInfo[#refreshInfo].money_num, refreshInfo[#refreshInfo].money_type
end

function QUIDialogThunderElite:_checkCanBuy()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local thunderInfo = remote.thunder:getThunderFighter()
	local N = thunderInfo.thunderEliteChallengeBuyCount or 0
	local refreshToken = self:getRefreshToken(N)
	local M = configuration["THUNDER_ELITE_BUY"].value
	return N >= M
end

function QUIDialogThunderElite:_onBuyHandler(callBack)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountThunderElite"}})
end

function QUIDialogThunderElite:_onTriggerPlus(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_plus) == false then return end
    app.sound:playSound("common_small")
	if self:_checkCanBuy() then 
		app.tip:floatTip("今日购买次数已达上限")
		return 
	end
	self:_onBuyHandler()
end

function QUIDialogThunderElite:_onTriggerFight(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_battle) == false then return end
    app.sound:playSound("common_small")
	if self._openElite == 0 then
		app.tip:floatTip("关卡尚未解锁")
		return 
	end

	if self._checkCanFight() == false then 
		if self:_checkCanBuy() == false then
			self:_onBuyHandler(function ()
				self:_onFightHandler()
			end)
		else
			app.tip:floatTip("今日挑战次数已达上限")
		end
		return 
	end 
	self:_onFightHandler()
end 

function QUIDialogThunderElite:_onFightHandler()
	local options = {}
	options.waveType = remote.thunder.ELITE_WAVE
	options.wave = tonumber(self._index)
	options.dungeonId = "thunder_elite_"..self._currentLevel
	options.rivalUserId = self._currentLevel 
	options.eliteWave = self._currentLevel 
	local dungeonArrangement = QThunderArrangement.new(options)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement", 
     	options = {arrangement = dungeonArrangement}})
end

function QUIDialogThunderElite:_checkCanFight()
	local thunderInfo = remote.thunder:getThunderFighter()
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	local num = tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) +  tonumber(thunderInfo.thunderEliteChallengeBuyCount) - tonumber(thunderInfo.thunderEliteChallengeTimes)
	if num == 0 then 
		return false
	end
	return true
end

function QUIDialogThunderElite:_onTriggerQuickFightOne(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_one_fast) == false then return end
    app.sound:playSound("common_small")
	if self._checkCanFight() == false then 
		if self:_checkCanBuy() == false then
			self:_onBuyHandler(function ()
				self:_onQuickFightHandler()
			end)
		else
			app.tip:floatTip("今日挑战次数已达上限")
		end
		return 
	end 
	self:_onQuickFightHandler()
end

function QUIDialogThunderElite:_onQuickFightHandler()
	local battleType = BattleTypeEnum.THUNDER_ELITE
	remote.thunder:thunderEliteQuickFight(battleType, self._currentLevel, remote.thunder.ELITE_WAVE, true, nil, nil, self._currentLevel, true, false,
		self:safeHandler(function(data)
			local allAwards = {}
			local prizes = {}
			prizes.awards = {}
			for _,awardInfo in pairs(data.apiThunderFightEndResponse.luckyDraw.prizes) do
				table.insert(prizes.awards,awardInfo)
			end
			table.insert(allAwards,prizes)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
				options = {awards  = allAwards, name = string.format("第%s关", self._currentLevel), isOnlyClose = true,isCanFast = true,callback = handler(self, self._onTriggerQuickFightOne)}})
				self:_fastSuccessed()
    end))
end

function QUIDialogThunderElite:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogThunderElite:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end 

return QUIDialogThunderElite