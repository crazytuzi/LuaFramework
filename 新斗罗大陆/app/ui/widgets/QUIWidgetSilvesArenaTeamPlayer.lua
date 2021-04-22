--
-- Kumo.Wang
-- 西尔维斯大斗魂场报名期我队伍成员

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaTeamPlayer = class("QUIWidgetSilvesArenaTeamPlayer", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")

QUIWidgetSilvesArenaTeamPlayer.EVENT_CLIENT = "QUIWIDGETSILVESARENARESTCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaTeamPlayer:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_MyTeam_Player.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerPlayerInfo", callback = handler(self, self._onTriggerPlayerInfo)},
  	}
	QUIWidgetSilvesArenaTeamPlayer.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_player_info)

  	if options then
  		self._info = options.info
  		self._isLeader = options.isLeader
  	end

	self:_init()
end

function QUIWidgetSilvesArenaTeamPlayer:onEnter()
	QUIWidgetSilvesArenaTeamPlayer.super.onEnter(self)
end

function QUIWidgetSilvesArenaTeamPlayer:onExit()
	QUIWidgetSilvesArenaTeamPlayer.super.onExit(self)
end

function QUIWidgetSilvesArenaTeamPlayer:_init()
	if q.isEmpty(self._info) then
		self._ccbOwner.node_player:setVisible(false)
	else
		self._ccbOwner.node_player:setVisible(true)

		self._ccbOwner.node_avatar:removeAllChildren()
		if self._info.defaultActorId then
			local avatar = QUIWidgetActorDisplay.new(self._info.defaultActorId, {heroInfo = {skinId = self._info.defaultSkinId}})
			self._ccbOwner.node_avatar:addChild(avatar)
		end

		if self._info.userId and self._info.userId == remote.user.userId then
			self._ccbOwner.s9s_myInfo_bg:setVisible(true)
			self._ccbOwner.s9s_playerInfo_bg:setVisible(false)
		else
			self._ccbOwner.s9s_myInfo_bg:setVisible(false)
			self._ccbOwner.s9s_playerInfo_bg:setVisible(true)
		end

		if self._info.name then
			self._ccbOwner.tf_player_name:setString(self._info.name)
			self._ccbOwner.tf_player_name:setVisible(true)
		else
			self._ccbOwner.tf_player_name:setVisible(false)
		end

		if self._info.game_area_name then
			self._ccbOwner.tf_player_area_name:setString(self._info.game_area_name)
			self._ccbOwner.tf_player_area_name:setVisible(true)
		else
			self._ccbOwner.tf_player_area_name:setVisible(false)
		end

		if self._info.force then
			local num, unit = q.convertLargerNumber(self._info.force)
			self._ccbOwner.tf_player_force:setString(num..(unit or ""))
			self._ccbOwner.tf_player_force:setVisible(true)
		else
			self._ccbOwner.tf_player_force:setVisible(false)
		end

		-- self._ccbOwner.sp_captain:setVisible(self._isLeader)
		self._ccbOwner.sp_captain:setVisible(false)
	end
end

function QUIWidgetSilvesArenaTeamPlayer:_onTriggerPlayerInfo(event)
	remote.silvesArena:silvesArenaQueryUserDataRequest(self._info.userId, function(data)
		if self._ccbView then
			if data and data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.fighter and not q.isEmpty(data.silvesArenaInfoResponse.fighter) then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
					options = {fighter = data.silvesArenaInfoResponse.fighter, forceTitle = "战力：", specialTitle1 = "服务器名：", specialValue1 = data.silvesArenaInfoResponse.fighter.game_area_name, isPVP = true}}, {isPopCurrentDialog = false})
			end
		end
	end)
end

return QUIWidgetSilvesArenaTeamPlayer