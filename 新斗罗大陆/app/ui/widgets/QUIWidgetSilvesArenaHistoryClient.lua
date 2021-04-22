--
-- Kumo.Wang
-- 西尔维斯巅峰赛上赛季前三名
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaHistoryClient = class("QUIWidgetSilvesArenaHistoryClient", QUIWidget)

local QListView = import("...views.QListView")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

local QUIWidgetSilvesArenaRestRankCell = import(".QUIWidgetSilvesArenaRestRankCell")
local QUIWidgetSilvesArenaRestWinner = import(".QUIWidgetSilvesArenaRestWinner")

QUIWidgetSilvesArenaHistoryClient.EVENT_CLIENT = "QUIWidgetSilvesArenaHistoryClient.EVENT_CLIENT"

QUIWidgetSilvesArenaHistoryClient.VIEW_ON = 1
QUIWidgetSilvesArenaHistoryClient.VIEW_OFF = -1

function QUIWidgetSilvesArenaHistoryClient:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Rest.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaHistoryClient.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:_init()
end

function QUIWidgetSilvesArenaHistoryClient:onEnter()
	QUIWidgetSilvesArenaHistoryClient.super.onEnter(self)

	self:update()
end

function QUIWidgetSilvesArenaHistoryClient:onExit()
	QUIWidgetSilvesArenaHistoryClient.super.onExit(self)
end

function QUIWidgetSilvesArenaHistoryClient:update()
	if q.isEmpty(remote.silvesArena.championTeamInfo) then
		self._ccbOwner.node_winner:setVisible(false)
		self._ccbOwner.node_no_winner:setVisible(true)
		self._ccbOwner.node_no_rank:setVisible(true)
		self._ccbOwner.node_rank:setVisible(false)
		self._ccbOwner.node_npc_fld:removeAllChildren()
		local avatar = QUIWidgetActorDisplay.new(1013)
		avatar:setScaleX(-1)
		self._ccbOwner.node_npc_fld:addChild(avatar)
	else
		self._ccbOwner.node_winner:setVisible(true)
		self._ccbOwner.node_no_winner:setVisible(false)
		self._ccbOwner.node_no_rank:setVisible(false)
		self._ccbOwner.node_rank:setVisible(true)
		self._ccbOwner.node_npc_fld:removeAllChildren()
		self:_updateView()
	end
end

function QUIWidgetSilvesArenaHistoryClient:_init()
	self._firstTeamInfo = {}
	self._secondTeamInfo = {}
	self._thirdTeamInfo = {}
	self._teamInfoList = {}

	self._isInfoON = self.VIEW_ON
	self._nodeInfoY = 190
	self._ccbOwner.node_info:setPosition(360, self._nodeInfoY)

	self._ccbOwner.node_winner:setVisible(false)
	self._ccbOwner.node_no_winner:setVisible(false)
end

function QUIWidgetSilvesArenaHistoryClient:_updateView()
	self:_updateWinnerView()
end

function QUIWidgetSilvesArenaHistoryClient:_updateWinnerView()
	if (q.isEmpty(self._firstTeamInfo) or q.isEmpty(self._secondTeamInfo) or q.isEmpty(self._thirdTeamInfo)) and not q.isEmpty(remote.silvesArena.championTeamInfo) then
		for _, teamInfo in ipairs(remote.silvesArena.championTeamInfo) do
			if teamInfo.currRound == 5 then
				self._firstTeamInfo = teamInfo
			elseif teamInfo.currRound == 4 then
				self._secondTeamInfo = teamInfo
			elseif teamInfo.isThirdRound then
				self._thirdTeamInfo = teamInfo
			end
		end
	end

	self._ccbOwner.node_winner_1:removeAllChildren()
	if not q.isEmpty(self._firstTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._firstTeamInfo, index = 1})
		self._ccbOwner.node_winner_1:addChild(winner)
	end

	self._ccbOwner.node_winner_2:removeAllChildren()
	if not q.isEmpty(self._secondTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._secondTeamInfo, index = 2})
		self._ccbOwner.node_winner_2:addChild(winner)
	end

	self._ccbOwner.node_winner_3:removeAllChildren()
	if not q.isEmpty(self._thirdTeamInfo) then
		local winner = QUIWidgetSilvesArenaRestWinner.new({info = self._thirdTeamInfo, index = 3})
		self._ccbOwner.node_winner_3:addChild(winner)
	end
end


return QUIWidgetSilvesArenaHistoryClient