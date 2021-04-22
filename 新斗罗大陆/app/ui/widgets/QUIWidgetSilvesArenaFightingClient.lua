--
-- Kumo.Wang
-- 西尔维斯大斗魂场战斗期主界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaFightingClient = class("QUIWidgetSilvesArenaFightingClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

local QUIWidgetSilvesArenaEnemyTeam = import(".QUIWidgetSilvesArenaEnemyTeam")

QUIWidgetSilvesArenaFightingClient.EVENT_CLIENT = "QUIWIDGETSILVESARENAFIGHTINGCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaFightingClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Fighting.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
  	}
	QUIWidgetSilvesArenaFightingClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_refresh)
    q.setButtonEnableShadow(self._ccbOwner.btn_detail)

	self:_init()
end

function QUIWidgetSilvesArenaFightingClient:onEnter()
	QUIWidgetSilvesArenaFightingClient.super.onEnter(self)
	
	if q.isEmpty(remote.silvesArena.teamInfo) then
		remote.silvesArena:silvesArenaGetMainInfoRequest(function()
			if self._ccbView then
				self:_checkTutorial()
				self:update()
			end
		end)
	else
		self:_checkTutorial()
		self:update()
	end
end

function QUIWidgetSilvesArenaFightingClient:_checkTutorial()
    local haveTutorial = false

	if app.tutorial and app.tutorial:isTutorialFinished() == false then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        if page.buildLayer then
            page:buildLayer()
        end
        if app.tutorial:getStage().silvesArenaFighting == app.tutorial.Guide_Start then
            haveTutorial = app.tutorial:startTutorial(app.tutorial.Statge_SilvesArena_Fighting)
        end
        if haveTutorial == false and page.cleanBuildLayer then
            page:cleanBuildLayer()
        end
    end

    return haveTutorial
end


function QUIWidgetSilvesArenaFightingClient:onExit()
	QUIWidgetSilvesArenaFightingClient.super.onExit(self)

	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
end

function QUIWidgetSilvesArenaFightingClient:getClassName()
	return "QUIWidgetSilvesArenaFightingClient"
end

function QUIWidgetSilvesArenaFightingClient:_reset()
	self._ccbOwner.tf_team_count:setVisible(false)
	self._ccbOwner.btn_detail:setVisible(false)
	self._ccbOwner.tf_my_count:setVisible(false)
	self._ccbOwner.tf_my_cd:setVisible(false)
	self._ccbOwner.tf_my_team_score:setVisible(false)
	self._ccbOwner.tf_my_team_rank:setVisible(false)
	self._ccbOwner.node_team_1:removeAllChildren()
	self._ccbOwner.node_team_2:removeAllChildren()
	self._ccbOwner.node_team_3:removeAllChildren()
end

function QUIWidgetSilvesArenaFightingClient:update()
	if q.isEmpty(remote.silvesArena.teamInfo) then
		self:_reset()
		return
	else
		self:_updateView()
	end
end

function QUIWidgetSilvesArenaFightingClient:_init()
	self:_reset()
end

function QUIWidgetSilvesArenaFightingClient:_updateView()
	self:_updateEnemyTeamView()
	self:_updateMyTeamInfo()
	self:_updateMyInfo()
end

function QUIWidgetSilvesArenaFightingClient:_updateEnemyTeamView()
	local enemyTeamInfo = remote.silvesArena.teamInfo

	for i = 1, 3, 1 do
		local node = self._ccbOwner["node_team_"..i]
		if node then
			node:removeAllChildren()
			if enemyTeamInfo and enemyTeamInfo[i] then
				local avatar = QUIWidgetSilvesArenaEnemyTeam.new({info = enemyTeamInfo[i]})
				node:addChild(avatar)
			end
		else
			break
		end
	end
end

function QUIWidgetSilvesArenaFightingClient:_updateMyTeamInfo()
	local myTeamInfo = remote.silvesArena.myTeamInfo

	if myTeamInfo and myTeamInfo.teamScore then
		self._ccbOwner.tf_my_team_score:setString(myTeamInfo.teamScore)
		self._ccbOwner.tf_my_team_score:setVisible(true)
	else
		self._ccbOwner.tf_my_team_score:setVisible(false)
	end

	if remote.silvesArena and remote.silvesArena.myTeamRank and remote.silvesArena.myTeamRank > 0 then
		self._ccbOwner.tf_my_team_rank:setString(remote.silvesArena.myTeamRank)
		self._ccbOwner.tf_my_team_rank:setVisible(true)
	else
		self._ccbOwner.tf_my_team_rank:setString("无")
		self._ccbOwner.tf_my_team_rank:setVisible(true)
	end

	if myTeamInfo and myTeamInfo.todayFightCount then
		local fightCnt = db:getConfigurationValue("silves_arena_day_fight_count")
		local totalFightCnt = remote.silvesArena.MAX_TEAM_MEMBER_COUNT * tonumber(fightCnt)
		local count = totalFightCnt - tonumber(myTeamInfo.todayFightCount)
		if count < 0 then count = 0 end
		self._ccbOwner.tf_team_count:setString(count.."次")
		self._ccbOwner.tf_team_count:setVisible(true)
	else	
		self._ccbOwner.tf_team_count:setVisible(false)
	end

	self._ccbOwner.btn_detail:setVisible(true)
end

function QUIWidgetSilvesArenaFightingClient:_updateMyInfo()
	local myInfo = remote.silvesArena.userInfo

	if myInfo and myInfo.todayFightCount then
		local fightCnt = db:getConfigurationValue("silves_arena_day_fight_count")
		local count = tonumber(fightCnt) - tonumber(myInfo.todayFightCount)
		if count < 0 then count = 0 end
		self._ccbOwner.tf_my_count:setString(count.."次")
		self._ccbOwner.tf_my_count:setVisible(true)
	else	
		self._ccbOwner.tf_my_count:setVisible(false)
	end

	if myInfo and myInfo.todayFightAt then
		local cd = db:getConfigurationValue("silves_arena_user_fight_cd")
		if q.serverTime() * 1000 >= tonumber(myInfo.todayFightAt) + tonumber(cd) * MIN * 1000 then
			self._ccbOwner.tf_my_cd:setVisible(false)
		else
			self:_updateCountdown()
		end
	else	
		self._ccbOwner.tf_my_cd:setVisible(false)
	end

	if myInfo and myInfo.refreshCount then
		local refreshCount = db:getConfigurationValue("silves_arena_user_day_refresh_max_count")
		self._ccbOwner.tf_refresh_count:setString( "免费："..( tonumber(refreshCount) - myInfo.refreshCount ).."次" )
	end
end

function QUIWidgetSilvesArenaFightingClient:_updateCountdown()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
	local timeStr, isCDing = self:_getMyCDCountdown()
	if isCDing then
		self._ccbOwner.tf_my_cd:setString(timeStr)
		self._ccbOwner.tf_my_cd:setVisible(true)
		self._countdownSchedule = scheduler.scheduleGlobal(function()
			if self._ccbView then
				self:_updateCountdown()
			end
		end, 1)
	else
		self._ccbOwner.tf_my_cd:setVisible(false)
	end
end

function QUIWidgetSilvesArenaFightingClient:_getMyCDCountdown()
	local myInfo = remote.silvesArena.userInfo
	local timeStr = ""
	local isCDing = false
	if myInfo and myInfo.todayFightAt then
		local cd = db:getConfigurationValue("silves_arena_user_fight_cd")
		self._cdSecTime = math.floor( (tonumber(myInfo.todayFightAt) + tonumber(cd) * MIN * 1000 - q.serverTime() * 1000) / 1000 )
		if self._cdSecTime > 0 then
			isCDing = true
			timeStr = self:_formatSecTime(self._cdSecTime)
		else
			isCDing = false
		end
		
		return timeStr, isCDing
	end

	return timeStr, isCDing
end

function QUIWidgetSilvesArenaFightingClient:_formatSecTime( sec )
    local m = math.floor(sec/MIN)
    local s = math.floor(sec%MIN)
    return string.format("（挑战冷却 %02d:%02d）", m, s)
end

function QUIWidgetSilvesArenaFightingClient:_onTriggerDetail(event)
	if event then
		app.sound:playSound("common_small")
	end

	remote.silvesArena:silvesArenaTodayTeamBattleInfoRequest(function()
		if self._ccbView then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesMyTeamReport"}, {isPopCurrentDialog = false})	
		end
	end)
end

function QUIWidgetSilvesArenaFightingClient:_onTriggerRefresh(event)
	if event then
		app.sound:playSound("common_small")
	end

	local myInfo = remote.silvesArena.userInfo
	if myInfo and myInfo.refreshCount then
		local refreshCount = db:getConfigurationValue("silves_arena_user_day_refresh_max_count")
		if tonumber(refreshCount) <= tonumber(myInfo.refreshCount) then
			app.tip:floatTip("刷新次数不足")
			return
		end
	end

	remote.silvesArena:silvesArenaRefreshRequest(function()
		if self._ccbView then
			self:update()
		end
	end)
end

return QUIWidgetSilvesArenaFightingClient