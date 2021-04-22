--
-- Kumo.Wang
-- 西尔维斯大斗魂场报名期主界面
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaTeamClient = class("QUIWidgetSilvesArenaTeamClient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

local QUIWidgetSilvesArenaTeamPlayer = import(".QUIWidgetSilvesArenaTeamPlayer")

QUIWidgetSilvesArenaTeamClient.EVENT_CLIENT = "QUIWIDGETSILVESARENATEAMCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaTeamClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Team.ccbi"
  	local callBacks = {
		{ccbCallbackName = "onTriggerOpenRoom", callback = handler(self, self._onTriggerOpenRoom)},
  	}
	QUIWidgetSilvesArenaTeamClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:_init()
end

function QUIWidgetSilvesArenaTeamClient:onEnter()
	QUIWidgetSilvesArenaTeamClient.super.onEnter(self)

	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.TEAM_UPDATE, handler(self, self.update))

	self:update()
end

function QUIWidgetSilvesArenaTeamClient:onExit()
	QUIWidgetSilvesArenaTeamClient.super.onExit(self)

	self._silvesArenaProxy:removeAllEventListeners()
end

function QUIWidgetSilvesArenaTeamClient:getClassName()
	return "QUIWidgetSilvesArenaTeamClient"
end

function QUIWidgetSilvesArenaTeamClient:update()
	if self._ccbView then
		if q.isEmpty(remote.silvesArena.myTeamInfo) or remote.silvesArena.myTeamInfo.status == 0 then
			self._ccbOwner.node_no_team:setVisible(true)
			self._ccbOwner.node_my_team:setVisible(false)
			self._ccbOwner.node_npc_fld:removeAllChildren()
			local avatar = QUIWidgetActorDisplay.new(1013)
			avatar:setScaleX(-1)
			self._ccbOwner.node_npc_fld:addChild(avatar)

			if self._isAutoOpenMyTeam and not ( remote.silvesArena.myTeamInfo and remote.silvesArena.myTeamInfo.status == 1 ) then
				self:_onTriggerOpenRoom()
			end
		else
			self._ccbOwner.node_no_team:setVisible(false)
			self._ccbOwner.node_my_team:setVisible(true)
			self._ccbOwner.node_npc_fld:removeAllChildren()
			self:_updateView()
		end

		if remote.silvesArena.haveApply then
			self._ccbOwner.tf_fld_bubble:setString("有人申请入队，快去看看吧～")
		else
			self._ccbOwner.tf_fld_bubble:setString("点击斗魂场大门进行组队～")
		end
	end
end

function QUIWidgetSilvesArenaTeamClient:_init()
	self._isAutoOpenMyTeam = false
	self._myTeamInfo = {}
end

function QUIWidgetSilvesArenaTeamClient:_updateView()
	self:_updateMyTeamView()
	self:_updateMyTeamInfo()
end

function QUIWidgetSilvesArenaTeamClient:_updateMyTeamView()
	self._myTeamInfo = remote.silvesArena.myTeamInfo

	self._ccbOwner.node_member_1:removeAllChildren()
	if not q.isEmpty(self._myTeamInfo.leader) then
		local avatar = QUIWidgetSilvesArenaTeamPlayer.new({info = self._myTeamInfo.leader, isLeader = true})
		self._ccbOwner.node_member_1:addChild(avatar)
	end

	self._ccbOwner.node_member_2:removeAllChildren()
	if not q.isEmpty(self._myTeamInfo.member1) then
		local avatar = QUIWidgetSilvesArenaTeamPlayer.new({info = self._myTeamInfo.member1})
		self._ccbOwner.node_member_2:addChild(avatar)
	end

	self._ccbOwner.node_member_3:removeAllChildren()
	if not q.isEmpty(self._myTeamInfo.member2) then
		local avatar = QUIWidgetSilvesArenaTeamPlayer.new({info = self._myTeamInfo.member2})
		self._ccbOwner.node_member_3:addChild(avatar)
	end
end

function QUIWidgetSilvesArenaTeamClient:_updateMyTeamInfo()
	if self._myTeamInfo and self._myTeamInfo.teamScore then
		self._ccbOwner.tf_my_team_score:setString(self._myTeamInfo.teamScore)
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
end

function QUIWidgetSilvesArenaTeamClient:_onTriggerOpenRoom()
	if q.isEmpty(remote.silvesArena.myTeamInfo) then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaRoomList", 
			options = {callback = function()
				if self._ccbView then
					if not q.isEmpty(remote.silvesArena.myTeamInfo) and remote.silvesArena.myTeamInfo.status == 0 then
						self._isAutoOpenMyTeam = true
						self:update()
					end
				end
			end}}, {isPopCurrentDialog = false})
	else
		self._isAutoOpenMyTeam = false
		-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaMyTeam",
		-- 	options = {callback = handler(self, self.update)}}, {isPopCurrentDialog = false})	
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaMyTeam"}, {isPopCurrentDialog = false})	
	end
end

return QUIWidgetSilvesArenaTeamClient