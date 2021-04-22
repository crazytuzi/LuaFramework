--
-- Kumo.Wang
-- 西尔维斯大斗魂场休赛期界面冠军人物
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaRestWinner = class("QUIWidgetSilvesArenaRestWinner", QUIWidget)

local QUIWidgetActorDisplay = import(".QUIWidgetActorDisplay")

QUIWidgetSilvesArenaRestWinner.EVENT_CLIENT = "QUIWIDGETSILVESARENARESTCLIENT.EVENT_CLIENT"

function QUIWidgetSilvesArenaRestWinner:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Winner.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaRestWinner.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	if options then
  		self._info = options.info
  		self._index = options.index
  	end

	self:_init()
end

function QUIWidgetSilvesArenaRestWinner:onEnter()
	QUIWidgetSilvesArenaRestWinner.super.onEnter(self)
end

function QUIWidgetSilvesArenaRestWinner:onExit()
	QUIWidgetSilvesArenaRestWinner.super.onExit(self)
end

function QUIWidgetSilvesArenaRestWinner:_init()
	if q.isEmpty(self._info) then
		return
	end

	local i = 1
	while true do
		local isFind = false
		local nodeBottom = self._ccbOwner["sp_bottom_"..i]
		if nodeBottom then
			nodeBottom:setVisible(i == self._index)
			isFind = true
		end

		local nodeNumber = self._ccbOwner["sp_number_"..i]
		if nodeNumber then
			nodeNumber:setVisible(i == self._index)
			isFind = true
		end

		local nodeEffect = self._ccbOwner["fca_bottom_"..i]
		if nodeEffect then
			nodeEffect:setVisible(i == self._index)
			isFind = true
		end

		local node = self._ccbOwner["node_bottom_"..i]
		if node then
			node:setVisible(i == self._index)
			isFind = true
		end

		if isFind then
			i = i + 1
		else
			break
		end
	end

	self._ccbOwner.node_avatar_1:removeAllChildren()
	if not q.isEmpty(self._info.leader) then
		local avatar = QUIWidgetActorDisplay.new(self._info.leader.defaultActorId, {heroInfo = {skinId = self._info.leader.defaultSkinId}})
		self._ccbOwner.node_avatar_1:addChild(avatar)
	end

	self._ccbOwner.node_avatar_2:removeAllChildren()
	if not q.isEmpty(self._info.member1) then
		local avatar = QUIWidgetActorDisplay.new(self._info.member1.defaultActorId, {heroInfo = {skinId = self._info.member1.defaultSkinId}})
		self._ccbOwner.node_avatar_2:addChild(avatar)
	end

	self._ccbOwner.node_avatar_3:removeAllChildren()
	if not q.isEmpty(self._info.member2) then
		local avatar = QUIWidgetActorDisplay.new(self._info.member2.defaultActorId, {heroInfo = {skinId = self._info.member2.defaultSkinId}})
		self._ccbOwner.node_avatar_3:addChild(avatar)
	end

	if self._info.teamName then
		self._ccbOwner.tf_team_name:setString(self._info.teamName)
		self._ccbOwner.tf_team_name:setVisible(true)
	else
		self._ccbOwner.tf_team_name:setVisible(false)
	end

	local isMe = remote.silvesArena.myTeamInfo and self._info.teamId == remote.silvesArena.myTeamInfo.teamId
	local _totalForce, _totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(self._info, isMe)
	if _totalForce and _totalNumber then
		local num, unit = q.convertLargerNumber(_totalForce / _totalNumber)
		self._ccbOwner.tf_team_force:setString(num..(unit or ""))
	else
		self._ccbOwner.tf_team_force:setString(0)
	end
end

return QUIWidgetSilvesArenaRestWinner