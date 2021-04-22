-- @Author: xurui
-- @Date:   2018-11-12 14:43:12
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-18 15:28:31
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStormArena = class("QUIDialogStormArena", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStormArena = import("..widgets.QUIWidgetStormArena")
local QShop = import("...utils.QShop")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialDirector = import("...tutorial.QTutorialDirector")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIWidgetTopStatusShow = import("..widgets.QUIWidgetTopStatusShow")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QUIWidgetStormArenaList = import("..widgets.QUIWidgetStormArenaList")

local QStormArenaDefenseArrangement = import("...arrangement.QStormArenaDefenseArrangement")
local QStormArenaArrangement = import("...arrangement.QStormArenaArrangement")
local QStormArenaAutoArrangement = import("...arrangement.QStormArenaAutoArrangement")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QRichText = import("...utils.QRichText")


function QUIDialogStormArena:ctor(options)
 	local ccbFile = "ccb/Dialog_StormArena.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerIntroduce", callback = handler(self, QUIDialogStormArena._onTriggerIntroduce)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, QUIDialogStormArena._onTriggerRank)},
        {ccbCallbackName = "onTriggerShop", callback = handler(self, QUIDialogStormArena._onTriggerShop)},
        {ccbCallbackName = "onTriggerRecord", callback = handler(self, QUIDialogStormArena._onTriggerRecord)},
        {ccbCallbackName = "onTriggerScorePanel", callback = handler(self, QUIDialogStormArena._onTriggerScorePanel)},
        {ccbCallbackName = "onTriggerTeam", callback = handler(self, QUIDialogStormArena._onTriggerTeam)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, QUIDialogStormArena._onTriggerRefresh)},
        {ccbCallbackName = "onPlus", callback = handler(self, QUIDialogStormArena._onTriggerBuyCount)},
		{ccbCallbackName = "onTriggerHistoryGlory", callback = handler(self, QUIDialogStormArena._onTriggerHistoryGlory)},
        {ccbCallbackName = "onTriggerClickPVP", callback = handler(self, self._onTriggerClickPVP)}, 
    }
    QUIDialogStormArena.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
	if page.setScalingVisible then page:setScalingVisible(false) end
	if page.topBar then page.topBar:showWithStormArena() end

    self._ccbOwner.touch_layer:setContentSize(CCSize(display.width, display.height))
    CalculateBattleUIPosition(self._ccbOwner.touch_node , true)
    -- CalculateBattleUIPosition(self._ccbOwner.node_team , true)
    -- CalculateBattleUIPosition(self._ccbOwner.node_competitor , true)

	self._totalCount = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_FREE_FIGHT_COUNT")
	self._cdTime = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_CD") or 0
	self._removeCDToken = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_CD_REMOVE") or 0
	self._refreshFreeCount = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_FREE_REFRESH_TIME") or 0
	self._refreshToken = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_TIME_COST") or 0

	if options then
		self._selectRivalPos = options.selectRivalPos
	end
	if self._selectRivalPos == nil then
		self._selectRivalPos = 8        --总共展示9个对手，策划为了把第二个对手显示在中间
	end

	self.isManualRefresh = false

    self:startCountdownSchedule()

    self:checkRankChangeInfo()

    self._pvpNodePosX = self._ccbOwner.node_pvp:getPositionX()
end


function QUIDialogStormArena:viewDidAppear()
   QUIDialogStormArena.super.viewDidAppear(self)
	self:addBackEvent(false)
	--代码
	self.stormArenaEventProxy = cc.EventProxy.new(remote.stormArena)
    self.stormArenaEventProxy:addEventListener(remote.stormArena.STORM_ARENA_REFRESH, handler(self, self._onRefresh))	
    self.stormArenaEventProxy:addEventListener(remote.stormArena.STORM_ARENA_RECORD_REFRESH, handler(self, self.updateRedTips))

    self:render()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)

end

function QUIDialogStormArena:viewWillDisappear()
	QUIDialogStormArena.super.viewWillDisappear(self)

	self:removeBackEvent()
	self:removeTimeCount()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.exitFromBattleHandler, self)
	
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end

	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end

	self.stormArenaEventProxy:removeAllEventListeners()
	self.stormArenaEventProxy = nil
end

function QUIDialogStormArena:_onRefresh( event )
	-- body
	if not event then
		event = {isNotRefreshAvatar = true}
	end

	self.isManualRefresh = not event.isNotRefreshAvatar
	self:render(event.isNotRefreshAvatar)
end

function QUIDialogStormArena:render(isNotRefreshAvatar)
	-- body
	self._refreshCount = remote.stormArena:getStormArenaRefreshTime()

	self:setRivalsInfo()
	if not isNotRefreshAvatar then
		self:initRivalsListView()
	end

	self:setMyInfo()

	self:timeCount()
	self:setFightCount()
	self:updateRedTips()
end

function QUIDialogStormArena:setMyInfo()
	if self._selfAvatar == nil then
		self._selfAvatar = QUIWidgetStormArena.new()
		self._ccbOwner.node_avtar:addChild(self._selfAvatar)
    	self._selfAvatar:addEventListener(QUIWidgetStormArena.EVENT_BATTLE, handler(self, self._clickEvent))
    	self._selfAvatar:addEventListener(QUIWidgetStormArena.EVENT_VISIT, handler(self, self._clickEvent))
	end
	local selfInfo = clone(remote.stormArena:getStormArenaInfo())
	self._selfAvatar:setInfo(selfInfo)

	local force = selfInfo.force or 0
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(force, true)
	local num, unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..(unit or ""))
	if fontInfo then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	end

	self._ccbOwner.node_pvp:setVisible(ENABLE_PVP_FORCE)
	self._ccbOwner.node_pvp:setPositionX( self._pvpNodePosX + self._ccbOwner.tf_defens_force:getContentSize().width)
end

function QUIDialogStormArena:setRivalsInfo()
	self._myInfo = clone(remote.stormArena:getStormArenaInfo())
	self._worshipList = clone(remote.stormArena:getStormArenaWorshipInfo().fighter or {})
	self._rivalsList = clone(remote.stormArena:getStormArenaRivalsInfo())
	self._buyCount = self._myInfo.fightBuyCount or 0
	
	self._avatarList = {}

    local index = 1
	for i, value in ipairs(self._worshipList) do
		if i > 5 then break end
		value.isWorship = true
		value.isFans = remote.stormArena:stormArenaTodayWorshipByPos(i)

		if self._avatarList[index] and #self._avatarList[index] == 3 then
			index = index + 1
		end
		if self._avatarList[index] == nil then
			self._avatarList[index] = {}
		end
		table.insert(self._avatarList[index], value)
	end
	for _, value in ipairs(self._rivalsList) do
		if self._avatarList[index] and #self._avatarList[index] == 3 then
			index = index + 1
		end
		if self._avatarList[index] == nil then
			self._avatarList[index] = {}
		end
		table.insert(self._avatarList[index], value)
	end
end

function QUIDialogStormArena:initRivalsListView()
	local totalNumber = #self._avatarList
	local headIndex = totalNumber
	local headIndexPosOffset = 0
	if self._selectRivalPos then
		local index = math.ceil(self._selectRivalPos / 3)
		headIndex = index

		local offsetIndex = self._selectRivalPos % 3
		if offsetIndex == 0 then offsetIndex = 3 end
		headIndexPosOffset = -(offsetIndex - 1) * 120
	end
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.renderFunHandler),
	        ignoreCanDrag = false,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        topShadow = self._ccbOwner.sp_top,
	        bottomShadow = self._ccbOwner.sp_bottom,
	        headIndex = headIndex,
	        headIndexPosOffset = headIndexPosOffset,
	        contentOffsetX = display.ui_width/2,
	        endRate = 0,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.touch_layer, cfg)
	else
		self._contentListView:reload({totalNumber = totalNumber, headIndex = headIndex, headIndexPosOffset = headIndexPosOffset})
	end

	self.isManualRefresh = false
end

function QUIDialogStormArena:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._avatarList[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetStormArenaList.new()
    	item:addEventListener(QUIWidgetStormArena.EVENT_BATTLE, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetStormArena.EVENT_VISIT, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetStormArena.EVENT_WORSHIP, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetStormArena.EVENT_QUICK_BATTLE, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetStormArena.EVENT_FAST_BATTLE, handler(self, self._clickEvent))


        isCacheNode = false
    end
    info.item = item
	item:setInfo(data, index, self.isManualRefresh)
    info.size = item:getContentSize()
	item:registerBtnHandler(list, index)

	return isCacheNode, -index
end

function QUIDialogStormArena:startCountdownSchedule()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	self:updateCountdown()
	self._countdownSchedule = scheduler.scheduleGlobal(function (  )
		if self:safeCheck() then
			self:updateCountdown()
		end
	end, 1)
end

function QUIDialogStormArena:updateCountdown()
	local isInSeason, timeStr, color = remote.stormArena:updateTime()

	if not isInSeason then
		self._ccbOwner.tf_season_time:setString("赛季结束")
		self._ccbOwner.node_competitor:setVisible(false)
	else
		self._ccbOwner.node_competitor:setVisible(true)
		self._ccbOwner.tf_season_time:setString(timeStr)
		self._ccbOwner.tf_season_time:setColor(color)
	end
end

function QUIDialogStormArena:updateRedTips(  )
	-- body
	if remote.stormArena:checkStormArenaScoreAwardRedtips() then
		self._ccbOwner.score_tips:setVisible(true)
	else
		self._ccbOwner.score_tips:setVisible(false)
	end
	
	if remote.stormArena:checkStormArenaShopRedTips() then
		self._ccbOwner.shop_tips:setVisible(true)
	else
		self._ccbOwner.shop_tips:setVisible(false)
	end

	self._ccbOwner.record_tips:setVisible(false)
	if remote.stormArena:getStormArenaRecordTip() then
		self._ccbOwner.record_tips:setVisible(true)
	end

	self._ccbOwner.sp_team_tips:setVisible(false)
	if remote.stormArena:checkTeamIsFull() == false then
		self._ccbOwner.sp_team_tips:setVisible(true)
	end
end

function QUIDialogStormArena:exitFromBattleHandler(evt)
	-- print("QUIDialogStormArena:exitFromBattleHandler(evt)")
	local fighterResult, rivalId = remote.stormArena:getTopRankUpdate()
	-- QPrintTable(fighterResult)
	-- print(rivalId)
	self:setRivalsInfo()
	if fighterResult and rivalId then
		self.fighterResult = fighterResult
		self.rivalId = rivalId	
		local isIn = false
		for i, avatars in ipairs(self._avatarList) do
			for j, value in ipairs(avatars) do
				if value.userId == self.rivalId then
					self._rival = value
					self._selectRivalPos = (i - 1) * 3 + j
					isIn = true
					break
				end
			end
		end	
		if not isIn then
			self.fighterResult = nil
			self.rivalId = nil
		end 

		if self.fighterResult then
			if self.fighterResult.stormResponse.mySelf.rank >= self.fighterResult.stormResponse.mySelf.lastRank  then
				self.fighterResult = nil
				self.rivalId = nil
				remote.stormArena:requestStormArenaInfo()
			end
		end
	end
	self:initRivalsListView()

	self:setMyInfo()
	
	if self.fighterResult then
		if self.fighterResult.stormResponse.mySelf.rank < self.fighterResult.stormResponse.mySelf.lastRank  then
			self:enableTouchSwallowTop()

			local winFun = function()
				if self._contentListView then
					local listIndex = math.ceil(self._selectRivalPos / 3)
					local offsetIndex = self._selectRivalPos % 3
					if offsetIndex == 0 then offsetIndex = 3 end
					local deadAvatar = self._contentListView:getItemByIndex(listIndex)
					deadAvatar:showDeadEffect(offsetIndex, function()
							self.rivalId = nil
							remote.stormArena:requestStormArenaInfo()
							self:disableTouchSwallowTop()
						end)
				end
			end

			if self.fighterResult.stormResponse.mySelf.lastRank > self.fighterResult.stormResponse.mySelf.topRank and self.fighterResult.stormFightEndResponse and self.fighterResult.stormFightEndResponse.topRankPrize then
				local maritimeMoney = string.split((self.fighterResult.stormFightEndResponse.topRankPrize or ""), "^")
				maritimeMoney = tonumber(maritimeMoney[2]) or 0
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArenaRankTop",
			    	options = {myInfo = self.fighterResult.stormResponse.mySelf, isStorm = true, token = maritimeMoney, callBack = function()
						remote.stormArena:setTopRankUpdate(nil, nil)
						self.fighterResult = nil
						self.rivalId = nil
			    		winFun()
			    	end}})
			else
				winFun()
			end
		end
	end

	self:setFightCount()
end

function QUIDialogStormArena:setFightCount(  )
	-- body
	local buyCount = self._myInfo.fightBuyCount or 0
	local fightCount = self._myInfo.fightCount or 0
	local count = (self._totalCount + buyCount) - fightCount
	self._ccbOwner.tf_count:setString(count)

	local totalVIPNum = QVIPUtil:getCountByWordField("storm_arena_times", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("storm_arena_times")
	self._ccbOwner.node_btn_plus:setVisible(totalVIPNum > totalNum or totalNum > buyCount)
end

function QUIDialogStormArena:timeCount()
	self:removeTimeCount()
	local timeFun = function()
			local passTime = q.serverTime() - (self._myInfo.lastFrozenTime or 0)/1000
			if passTime <= self._cdTime and (not app.unlock:checkLock("UNLOCK_STORM_UNFREEZE")) then
				local needTime = self._cdTime - passTime 
				self._ccbOwner.node_time:setVisible(true)
				self._ccbOwner.tf_time:setString(string.format("%02d:%02d后", math.floor(needTime/60), math.floor(needTime%60)))
				self:resetTimeHandler(false)
			else
				self._ccbOwner.node_time:setVisible(false)
				self:removeTimeCount()
				self:resetTimeHandler(true)
			end
		end
	self._timeHandler = scheduler.scheduleGlobal(timeFun, 1)
	timeFun()
end

--显示斗魂场的重置CD
function QUIDialogStormArena:resetTimeHandler(b)
	self._resetCount = b
	if b == true then
		self._ccbOwner.tf_refresh:setString("换一批")
		if self._refreshCount >= self._refreshFreeCount then
			self._ccbOwner.tf_token:setString(self._refreshToken)
		else
			self._ccbOwner.tf_token:setString("免费")
		end
	else
		self._ccbOwner.tf_refresh:setString("重置")
		self._ccbOwner.tf_token:setString(self._removeCDToken)
	end
end

function QUIDialogStormArena:removeTimeCount()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
	end
end

function QUIDialogStormArena:_clickEvent(event)
	if event == nil then return end

	local info = event.info or {}
	if event.name == QUIWidgetStormArena.EVENT_BATTLE then
		self:getOptions().selectRivalPos = event.index
		if info.userId == remote.user.userId and not info.isWorship then
			self:changeDefanceTeamHandler(event)
		else
			self:startBattleHandler(event)
		end
	elseif event.name == QUIWidgetStormArena.EVENT_VISIT then
		if info.userId == remote.user.userId and not info.isWorship then
			self:changeDefanceTeamHandler(event)
		else
			self:clickCellHandler(event)
		end
	elseif event.name == QUIWidgetStormArena.EVENT_WORSHIP then
		self:worshipHandler(event)
	elseif event.name == QUIWidgetStormArena.EVENT_QUICK_BATTLE then
		self:quickBattleHandler(event)
	elseif event.name == QUIWidgetStormArena.EVENT_FAST_BATTLE then
		self:startBattleHandler(event, true)
	end
end

function QUIDialogStormArena:changeDefanceTeamHandler(event)
	if self.rivalId ~= nil then return end
	local arenaArrangement1 = QStormArenaDefenseArrangement.new({teamKey = remote.teamManager.STORM_ARENA_DEFEND_TEAM1})
	local arenaArrangement2 = QStormArenaDefenseArrangement.new({teamKey = remote.teamManager.STORM_ARENA_DEFEND_TEAM2})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
end

function QUIDialogStormArena:startBattleHandler(event, isFastFight)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	
	local isInSeason = remote.stormArena:updateTime()
	if isInSeason then
		if isFastFight then
			self:checkCanBattle(event, handler(self, self.startFastBattle))
		else
			self:checkCanBattle(event, handler(self, self.startBattle))
		end
	else
		app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
            options = {content ="亲爱的魂师大人！新赛季即将到来～准备参加新赛季吧～", comfirmCallback = function ()
               app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end}})
	end
end

function QUIDialogStormArena:startBattle(info, index)
	local rivalInfo = info
	local rivalsPos = index - 5

	if rivalInfo == nil then
		return 
	end

	local battleFunc = function ()
		remote.stormArena:stormArenaQueryDefenseHerosRequest(rivalInfo.userId, function(data)
			local rivalsFight = (data.towerFightersDetail or {})[1]
			remote.teamManager:sortTeam(rivalsFight.heros, true)
			remote.teamManager:sortTeam(rivalsFight.subheros, true)
			remote.teamManager:sortTeam(rivalsFight.sub2heros, true)
			remote.teamManager:sortTeam(rivalsFight.main1Heros, true)
			remote.teamManager:sortTeam(rivalsFight.sub1heros, true)
			
			local arenaArrangement1 = QStormArenaArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM1})
			local arenaArrangement2 = QStormArenaArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM2})
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
				options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", 
				fighterInfo = rivalsFight}})
		end)
	end

	remote.stormArena:stormFightStartCheckRequest(self._myInfo.userId, self._myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
			if self:safeCheck() then
				if data.gfStartCheckResponse and data.gfStartCheckResponse.stormFightStartCheckResponse and (data.gfStartCheckResponse.stormFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.stormFightStartCheckResponse.isSelfPosChanged) then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							remote.stormArena:requestStormArenaInfo()
						end
					end})
				else
					if battleFunc then
						battleFunc()
					end
				end
			end
		end, function()
			if battleFunc then
				battleFunc()
			end
		end)
end


function QUIDialogStormArena:startFastBattle(info, index)
	local rivalInfo = info
	local rivalsPos = index - 5

	if rivalInfo == nil then
		return 
	end

	local battleFunc = function ()
		remote.stormArena:stormArenaQueryDefenseHerosRequest(rivalInfo.userId, function(data)
			local rivalsFight = (data.towerFightersDetail or {})[1]
			remote.teamManager:sortTeam(rivalsFight.heros, true)
			remote.teamManager:sortTeam(rivalsFight.subheros, true)
			remote.teamManager:sortTeam(rivalsFight.sub2heros, true)
			remote.teamManager:sortTeam(rivalsFight.main1Heros, true)
			remote.teamManager:sortTeam(rivalsFight.sub1heros, true)
			
			local autoArrangement1 = QStormArenaAutoArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM1})
			local autoArrangement2 = QStormArenaAutoArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM2})
			local heroIdList1 = autoArrangement1:getHeroIdList()
			local heroIdList2 = autoArrangement2:getHeroIdList()

			local callback = function()
				local arenaArrangement1 = QStormArenaArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM1})
				local arenaArrangement2 = QStormArenaArrangement.new({myInfo = self._myInfo, rivalInfo = rivalsFight, rivalsPos = rivalsPos, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM2})
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
					options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", 
					fighterInfo = rivalsFight}})
			end
			if not autoArrangement1:teamValidity(heroIdList1[1].actorIds, 1, callback) then 
				return
			end
			if not autoArrangement2:teamValidity(heroIdList2[1].actorIds, 2, callback) then 
				return
			end

			local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_ATTACK_TEAM1, false)
			local soulMaxNum = teamVO:getSpiritsMaxCountByIndex(1)
			local numSpiritInOne = heroIdList1[1].spiritIds == nil and 0 or #heroIdList1[1].spiritIds
			local numSpiritInTwo = heroIdList2[1].spiritIds == nil and 0 or #heroIdList2[1].spiritIds
		    if soulMaxNum > 0 
		    	and ((heroIdList1[1].spiritIds ~= nil and #heroIdList1[1].spiritIds < soulMaxNum) or (heroIdList2[1].spiritIds ~= nil and #heroIdList2[1].spiritIds < soulMaxNum)) 
		    	and (#remote.soulSpirit:getMySoulSpiritInfoList() - numSpiritInOne - numSpiritInTwo) > 0 then
		        app:alert({content="有主力魂灵未上阵，确定开始战斗吗？",title="系统提示", callback = function (state)
		            if state == ALERT_TYPE.CONFIRM then
		                autoArrangement1:startBattle(heroIdList1, heroIdList2, function ()
								self:exitFromBattleHandler()
							end)
		            end
		        end})
		    else
		    	autoArrangement1:startBattle(heroIdList1, heroIdList2, function ()
						self:exitFromBattleHandler()
					end)
		    end
		end)
	end

	remote.stormArena:stormFightStartCheckRequest(self._myInfo.userId, self._myInfo.rank, rivalInfo.userId, rivalInfo.rank, function(data)
			if self:safeCheck() then
				if data.gfStartCheckResponse and data.gfStartCheckResponse.stormFightStartCheckResponse and (data.gfStartCheckResponse.stormFightStartCheckResponse.isRivalPosChanged or data.gfStartCheckResponse.stormFightStartCheckResponse.isSelfPosChanged) then
					app:alert({content = "排名发生了变化，确认刷新后重新开始挑战", callback = function (state)
						if state == ALERT_TYPE.CONFIRM then
							remote.stormArena:requestStormArenaInfo()
						end
					end})
				else
					if battleFunc then
						battleFunc()
					end
				end
			end
		end, function()
			if battleFunc then
				battleFunc()
			end
		end)
end


function QUIDialogStormArena:quickBattle(info, index)
	local rivalsPos = index - 5
	local rivalInfo = info

	if rivalInfo == nil then
		return 
	end

	local oldStormMoney = remote.user.maritimeMoney or 0
	local oldScore = self._myInfo.arenaRewardIntegral
	self:enableTouchSwallowTop()
	remote.stormArena:requestStormArenaQuickFight(rivalInfo.userId, rivalsPos, function (data)

		app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_TASK_EVENT, 1)
		remote.user:addPropNumForKey("todayStormFightCount")
		remote.stormArena:setTopRankUpdate(data, userId)

		if self:safeCheck() then
			self.rivalId = nil
			local batchAwards = {}
			local awards = {}
	
			--节日掉落
			if type(data.extraExpItem) == "table" then
				for k, v in pairs(data.extraExpItem)do
					table.insert(awards, v)
				end
			end
			table.insert(batchAwards, {awards = awards})
			table.insert(awards, {type = ITEM_TYPE.MARITIME_MONEY ,count = ((remote.user.maritimeMoney or 0) - oldStormMoney)})
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
				options = {fast_type = FAST_FIGHT_TYPE.RANK_FAST,awards = batchAwards, yield = data.stormFightEndResponse.yield or 1, activityYield =  1, score = data.stormResponse.mySelf.arenaRewardIntegral - oldScore, name = "索托扫荡",
				userComeBackRatio = data.userComeBackRatio, callback = function ()
					self:disableTouchSwallowTop()
		    		if self:safeCheck() then
						remote.stormArena:requestStormArenaInfo()
					end
				end}},{isPopCurrentDialog = false})
		end
	end,function ()
		self.rivalId = nil
		self:disableTouchSwallowTop()
	end)
end

function QUIDialogStormArena:_teamIsNil()
  	app:alert({content="还未设置战队，无法参加战斗！现在就设置战队？",title="系统提示", callback=function(state)
		if state == ALERT_TYPE.CONFIRM then
			self:changeDefenceTeamHandler()
		end
  	end})
end

function QUIDialogStormArena:quickBattleHandler(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_confirm")
	if app.unlock:checkLock("UNLOCK_ARENA_QUICK_FIGHT") == false then
		app.unlock:tipsLock("UNLOCK_ARENA_QUICK_FIGHT", "斗魂场扫荡", true)
		return
	end

	local isInSeason = remote.stormArena:updateTime()
	if isInSeason then
		self:checkCanBattle(event, handler(self, self.quickBattle))
	else
		app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
            options = {content ="亲爱的魂师大人！新赛季即将到来～准备参加新赛季吧～", comfirmCallback = function ()
               app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end}})
	end
end

function QUIDialogStormArena:checkCanBattle(event, startHandler)
    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		app.tip:floatTip("魂师大人，21：00～21：15是每日结算时间，无法挑战，稍后再来吧～")
		return
	end

	if event.info.userId == remote.user.userId then
		app.tip:floatTip("不能挑战自己！")
		return
	end
	if event.isWorship == true and self._myInfo.rank > 20 then
		app.tip:floatTip("太不自量力了，先冲到前20名再来挑战我吧！")
        return 
	end

	if ((self._totalCount + self._buyCount) - self._myInfo.fightCount) <= 0 then
    	self:_onTriggerBuyCount()
		return 
	end

	local passTime = q.serverTime() - (self._myInfo.lastFrozenTime or 0)/1000
	if passTime <= self._cdTime and self._myInfo.fightCount > 0 then
  		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "索托斗魂场CD重置")
			return
		else
			app:alert({content=string.format("挑战时间在冷却中，消除冷却时间需花费%d钻石\n是否消除CD直接挑战对方？", self._removeCDToken),title="系统提示", callback=function(state)
					if state == ALERT_TYPE.CONFIRM then
						if self._removeCDToken > remote.user.token then
							QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
						else
							remote.stormArena:requestStormArenaCleanFightCD(function (data)
								remote.stormArena:stormArenaRefresh(data)
								if self:safeCheck() then
									startHandler(event.info, event.index)
								end
							end)
						end
					end
				end})
			return 
		end
	else
		startHandler(event.info, event.index)
	end
end

function QUIDialogStormArena:clickCellHandler(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")

	remote.stormArena:stormArenaQueryDefenseHerosRequest(event.info.userId, function(data)
		local fighterInfo = (data.towerFightersDetail or {})[1] or {}
		self:changeRivalsInfo(fighterInfo)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
    		options = {fighterInfo = fighterInfo, isPVP = true}}, {isPopCurrentDialog = false})
	end)
  
end

function QUIDialogStormArena:changeRivalsInfo(fighterInfo)
	if q.isEmpty(fighterInfo) then return end

	local isUpdate = false
	for i, avatars in ipairs(self._avatarList) do
		for j, value in ipairs(avatars) do
			if value.userId == fighterInfo.userId then
				value.force = fighterInfo.force or 0
				isUpdate = true
			end
		end
	end	

	if isUpdate and self._contentListView then
		self._contentListView:refreshData()
	end
end

function QUIDialogStormArena:worshipHandler(event)
    app.sound:playSound("common_small")

	local isInSeason = remote.stormArena:updateTime()
	if not isInSeason then
		app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogNpcPrompt", 
            options = {content ="亲爱的魂师大人！新赛季即将到来～准备参加新赛季吧～", comfirmCallback = function ()
               app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end}})
		return 
	end

    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
	if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
		app.tip:floatTip("魂师大人，21：00～21：15是每日结算时间，无法膜拜，稍后再来吧～")
		return
	end

	if remote.stormArena:stormArenaTodayWorshipByPos(event.index) == true then
        app.tip:floatTip("今日已经膜拜过了") 
    else
    	local widget = event.widget
    	local oldStormMoney = remote.user.maritimeMoney or 0
		remote.stormArena:requestStormArenaWorship(event.info.userId, event.index-1, function (data)
			local money = (data.wallet.maritimeMoney or 0) - oldStormMoney
            app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_WORSHIP_EVENT, 1, false, true)

			if self:safeCheck() then
				remote.stormArena:setStormArenaTodayWorshipInfo(data.stormWorshipResponse.todayWorshipPos)
        		remote.stormArena:setStormArenaWorshipInfoFighter(data.stormWorshipResponse.fighter)
				widget:showFans()
				self:setRivalsInfo()
				if self._worshipAnimationPlayer ~= nil then
					self._worshipAnimationPlayer:disappear()
					self:getView():removeChild(self._worshipAnimationPlayer)
					self._worshipAnimationPlayer = nil
				end
				self._worshipAnimationPlayer = QUIWidgetAnimationPlayer.new()
				if data.stormWorshipResponse.yield > 1 then
					self._worshipAnimationPlayer:playAnimation("ccb/effects/Baoji_mobai.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(money)
						ccbOwner.tf_2:setPositionX(ccbOwner.tf_money:getPositionX() + ccbOwner.tf_money:getContentSize().width/2 + 10)
						if data.stormWorshipResponse.yield > 2 then
							ccbOwner.sp_title1:setVisible(false)
						else
							ccbOwner.sp_title2:setVisible(false)
						end
					end)
				else
					self._worshipAnimationPlayer:playAnimation("ccb/effects/team_arena.ccbi", function (ccbOwner)
						ccbOwner.tf_money:setString(money)
					end)
				end
				self:getView():addChild(self._worshipAnimationPlayer)
			end
		end)
	end
end

function QUIDialogStormArena:showFunctionDescription()
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaDescription"})
end

function QUIDialogStormArena:checkRankChangeInfo()
	remote.userDynamic:openDynamicDialog(2, function(isConfirm)
			if self:safeCheck() then
				if isConfirm == false then
					remote.stormArena:setStormArenaRecordTip(true, true)
				else
					self:_onTriggerRecord()
				end
			end
		end)
end

function QUIDialogStormArena:_onTriggerTeam(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_team) == false then return end
	if self.rivalId ~= nil then return end

	local selfInfo = clone(remote.stormArena:getStormArenaInfo())
	self:changeDefanceTeamHandler({info = selfInfo})
end

function QUIDialogStormArena:_onTriggerIntroduce()
	--代码
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaHelp"})
end

function QUIDialogStormArena:_onTriggerRecord(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")

	remote.stormArena:setStormArenaRecordTip(false, true)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAgainstRecord", options = {reportType = REPORT_TYPE.STORM_ARENA}}, 
		{isPopCurrentDialog = false})
end

function QUIDialogStormArena:_onTriggerRank(event)
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "stormArena"}}, 
		{isPopCurrentDialog = false})
end

function QUIDialogStormArena:_onTriggerShop(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")

    remote.stores:openShopDialog(SHOP_ID.artifactShop)
end

function QUIDialogStormArena:_onTriggerBuyCount(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	if self.rivalId ~= nil then return end
	if event ~= nil then
    	app.sound:playSound("common_small")
    end

    local buyCount = self._myInfo.fightBuyCount or 0
	if buyCount >= QVIPUtil:getStormArenaResetCount() then
		self:_showVipAlert(3)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
			options = {cls = "QBuyCountStormArena"}})
	end
end

function QUIDialogStormArena:_onTriggerRefresh(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	if self._resetCount == false then
		if app.unlock:checkLock("ARENA_RESET") == false then
			app.unlock:tipsLock("ARENA_RESET", "索托斗魂场CD重置")
			return
		else
			if self._removeCDToken > remote.user.token then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				remote.stormArena:requestStormArenaCleanFightCD(function (data)
					if self:safeCheck() then
						remote.stormArena:stormArenaRefresh(data)
					end
				end)
			end
		end
	else
		-- print("---------------------",self._refreshCount, QVIPUtil:getStormArenaRefreshCount())
		local nowTime = q.serverTime() 
	    local nowDateTable = q.date("*t", nowTime)
		if ( nowDateTable.hour == 21 and nowDateTable.min < 16 ) then
			app.tip:floatTip("魂师大人，21：00～21：15是每日结算时间，无法换一批，稍后再来吧～")
			return
		end
		if self._refreshCount >= QVIPUtil:getStormArenaRefreshCount() then
			self:_showVipAlert(1)
			return
		else
			if self._contentListView then
				self._contentListView:startScrollToIndex(#self._avatarList, true, 200, function()
						remote.stormArena:requestStormArenaInfo(true)
					end, -92)
			end
		end
	end
end

function QUIDialogStormArena:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogStormArena:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogStormArena:_showVipAlert( model )
	if model == 1 then
		-- 刷新
		app:vipAlert({title = "刷新次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.STORM_ARENA_REFRESH_COUNT}, false)
	elseif model == 3 then
		-- 挑战
		app:vipAlert({title = "挑战次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.STORM_ARENA_RESET_COUNT}, false)
	end
end

function QUIDialogStormArena:_onTriggerScorePanel()
	if self.rivalId ~= nil then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaScoreAwards"})
end

function QUIDialogStormArena:_onTriggerHistoryGlory()
    app.sound:playSound("common_small")
    remote.stormArena:stormGetSeasonInfoRequest(function(data)
    	    if data and data.stormGetSeasonInfoResponse then
    			remote.stormArena:setSeasonInfo( data.stormGetSeasonInfoResponse.stormArenaSeasonInfo or {} )
    		end
    	end)
    local data = {}
    remote.stormArena:stormGetGloryWallInfoRequest(remote.stormArena.seasonNO, remote.stormArena.isAllServersHistory, function(data)
    		if self:safeCheck() then
	            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStormArenaHistoryGlory", 
	            	options = { data = data.stormGetGloryWallInfoResponse }})
	        end
    	end)

end

function QUIDialogStormArena:_onTriggerClickPVP(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_pvp) == false then return end
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPVPPropTip", 
        options = {teamKey = remote.teamManager.STORM_ARENA_DEFEND_TEAM1, teamKey2 = remote.teamManager.STORM_ARENA_DEFEND_TEAM2, showTeam = true}}, {isPopCurrentDialog = false})
end

return QUIDialogStormArena