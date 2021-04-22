--
-- Kumo.Wang
-- 西尔维斯大斗魂场组队界面元素

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaMyTeamCell = class("QUIWidgetSilvesArenaMyTeamCell", QUIWidget)

local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")

QUIWidgetSilvesArenaMyTeamCell.EVENT_ADD = "QUIWIDGETSILVESARENAMYTEAMCELL.EVENT_ADD"
QUIWidgetSilvesArenaMyTeamCell.EVENT_KICK_OFF = "QUIWIDGETSILVESARENAMYTEAMCELL.EVENT_KICK_OFF"

function QUIWidgetSilvesArenaMyTeamCell:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_MyTeam.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerAdd", callback = handler(self, self._onTriggerAdd)},
		{ccbCallbackName = "onTriggerKickOff", callback = handler(self, self._onTriggerKickOff)},
  	}
	QUIWidgetSilvesArenaMyTeamCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	
    q.setButtonEnableShadow(self._ccbOwner.btn_kick_off)

	self:_init()
end

function QUIWidgetSilvesArenaMyTeamCell:onEnter()
	QUIWidgetSilvesArenaMyTeamCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaMyTeamCell:onExit()
	QUIWidgetSilvesArenaMyTeamCell.super.onExit(self)
end

function QUIWidgetSilvesArenaMyTeamCell:update(fighter, isCaptain)
	self._info = fighter
	
	if q.isEmpty(fighter) then
		self._ccbOwner.node_empty:setVisible(true)
		self._ccbOwner.node_player:setVisible(false)
	else
		if q.isEmpty(self._info) then
			self._ccbOwner.node_empty:setVisible(true)
			self._ccbOwner.node_player:setVisible(false)
		else
			self._ccbOwner.node_empty:setVisible(false)
			self._ccbOwner.node_player:setVisible(true)

			self._ccbOwner.node_avatar:removeAllChildren()
			if self._info.defaultActorId then
				local avatar = QUIWidgetActorDisplay.new(self._info.defaultActorId, {heroInfo = {skinId = self._info.defaultSkinId}})
				self._ccbOwner.node_avatar:addChild(avatar)
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
				local fontInfo = db:getForceColorByForce(self._info.force, true)
			    if fontInfo ~= nil then
			        local color = string.split(fontInfo.force_color, ";")
			        self._ccbOwner.tf_player_force:setColor(ccc3(color[1], color[2], color[3]))
			    end
				self._ccbOwner.tf_player_force:setVisible(true)
			else
				self._ccbOwner.tf_player_force:setVisible(false)
			end

			

			if isCaptain then
				self._ccbOwner.sp_captain:setVisible(true)
				self._ccbOwner.node_btn_kick_off:setVisible(false)
			else
				self._ccbOwner.sp_captain:setVisible(false)
				if remote.silvesArena.myTeamInfo.leader and remote.silvesArena.myTeamInfo.leader.userId and remote.silvesArena.myTeamInfo.leader.userId == remote.user.userId then
					self._ccbOwner.node_btn_kick_off:setVisible(true)
				else
					self._ccbOwner.node_btn_kick_off:setVisible(false)
				end
			end
		end
	end
end

function QUIWidgetSilvesArenaMyTeamCell:_init()
	self._info = {}
end

function QUIWidgetSilvesArenaMyTeamCell:_onTriggerAdd(event)
	if q.buttonEventShadow(event, self._ccbOwner.sp_btn_add) == false then return end
	if event then
		app.sound:playSound("common_small")
	end
	self:dispatchEvent({name = QUIWidgetSilvesArenaMyTeamCell.EVENT_ADD})
end

function QUIWidgetSilvesArenaMyTeamCell:_onTriggerKickOff(event)
	if event then
		app.sound:playSound("common_small")
	end
	self:dispatchEvent({name = QUIWidgetSilvesArenaMyTeamCell.EVENT_KICK_OFF, userId = self._info.userId})
end

return QUIWidgetSilvesArenaMyTeamCell