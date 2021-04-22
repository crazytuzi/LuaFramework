--
-- Kumo.Wang
-- 西尔维斯大斗魂场报名期我队伍成员
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaEnemyTeam = class("QUIWidgetSilvesArenaEnemyTeam", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")

QUIWidgetSilvesArenaEnemyTeam.EVENT_CLIENT = "QUIWIDGETSILVESARENARESTCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaEnemyTeam:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_EnemyTeam.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
  		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
  	}
	QUIWidgetSilvesArenaEnemyTeam.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	q.setButtonEnableShadow(self._ccbOwner.btn_enemy_team_info)

  	if options then
  		self._info = options.info
  	end

	self:_init()
end

function QUIWidgetSilvesArenaEnemyTeam:onEnter()
	QUIWidgetSilvesArenaEnemyTeam.super.onEnter(self)
end

function QUIWidgetSilvesArenaEnemyTeam:onExit()
	QUIWidgetSilvesArenaEnemyTeam.super.onExit(self)
end

function QUIWidgetSilvesArenaEnemyTeam:_init()
	if q.isEmpty(self._info) then
		self._ccbOwner.node_enemy_team:setVisible(false)
	else
		self._ccbOwner.node_enemy_team:setVisible(true)

		self._ccbOwner.node_avatar_1:removeAllChildren()
		if self._info.leader and self._info.leader.defaultActorId then
			local avatar = QUIWidgetActorDisplay.new(self._info.leader.defaultActorId, {heroInfo = {skinId = self._info.leader.defaultSkinId}})
			self._ccbOwner.node_avatar_1:addChild(avatar)
		end

		self._ccbOwner.node_avatar_2:removeAllChildren()
		if self._info.member1 and self._info.member1.defaultActorId then
			local avatar = QUIWidgetActorDisplay.new(self._info.member1.defaultActorId, {heroInfo = {skinId = self._info.member1.defaultSkinId}})
			self._ccbOwner.node_avatar_2:addChild(avatar)
		end

		self._ccbOwner.node_avatar_3:removeAllChildren()
		if self._info.member2 and self._info.member2.defaultActorId then
			local avatar = QUIWidgetActorDisplay.new(self._info.member2.defaultActorId, {heroInfo = {skinId = self._info.member2.defaultSkinId}})
			self._ccbOwner.node_avatar_3:addChild(avatar)
		end

		if self._info.teamName then
			self._ccbOwner.tf_enemy_team_name:setString(self._info.teamName)
			self._ccbOwner.tf_enemy_team_name:setVisible(true)
		else
			self._ccbOwner.tf_enemy_team_name:setVisible(false)
		end

		if self._info.teamScore then
			self._ccbOwner.tf_enemy_team_score:setString(self._info.teamScore)
			self._ccbOwner.tf_enemy_team_score:setVisible(true)
		else
			self._ccbOwner.tf_enemy_team_score:setVisible(false)
		end

		local _totalForce, _totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(self._info)
		if _totalForce and _totalNumber then
			local num, unit = q.convertLargerNumber(_totalForce / _totalNumber)
			self._ccbOwner.tf_enemy_team_force:setString(num..(unit or ""))
		else
			self._ccbOwner.tf_enemy_team_force:setString(0)
		end
		self._ccbOwner.tf_enemy_team_force:setVisible(true)
	end
end

function QUIWidgetSilvesArenaEnemyTeam:_onTriggerOK( event )
	if event then
		app.sound:playSound("common_small")
	end

	local myInfo = remote.silvesArena.userInfo
	if myInfo and myInfo.todayFightAt then
		local cd = db:getConfigurationValue("silves_arena_user_fight_cd")
		if q.serverTime() * 1000 < tonumber(myInfo.todayFightAt) + tonumber(cd) * MIN * 1000 then
			app.tip:floatTip("挑战冷却中")
			return
		end
	end

	if self._info and self._info.teamId and remote.silvesArena.myTeamInfo and remote.silvesArena.myTeamInfo.teamId then
		remote.silvesArena.againstTeamInfo = self._info
		remote.silvesArena:dispatchEvent({name = remote.silvesArena.STATE_UPDATE})
		-- remote.silvesArena:silvesArenaQueryTeamFighterRequest(remote.silvesArena.myTeamInfo.teamId, nil, function()
		-- 	-- remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._info.teamId, nil, function()
		-- 		if self._ccbView then
		-- 			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
		-- 				options = {teamId = self._info.teamId, module = remote.silvesArena.BATTLEFORMATION_MODULE_PVP}}, {isPopCurrentDialog = false})
		-- 		end
		-- 	-- end)
		-- end)
	end
end

function QUIWidgetSilvesArenaEnemyTeam:_onTriggerInfo( event )
	if event then
		app.sound:playSound("common_small")
	end
	if self._info and self._info.teamId then
		remote.silvesArena:silvesArenaQueryTeamFighterRequest(self._info.teamId, nil, function()
			if self._ccbView then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesBattleFormation",
					options = {teamId = self._info.teamId, module = remote.silvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL}}, {isPopCurrentDialog = false})
			end
		end)
	end
end

return QUIWidgetSilvesArenaEnemyTeam