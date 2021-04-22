--
-- Kumo.Wang
-- 西尔维斯大斗魂场休赛期界面排行榜
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaRestRankCell = class("QUIWidgetSilvesArenaRestRankCell", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetSilvesArenaRestRankCell:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Rank.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaRestRankCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilvesArenaRestRankCell:onEnter()
	QUIWidgetSilvesArenaRestRankCell.super.onEnter(self)
end

function QUIWidgetSilvesArenaRestRankCell:onExit()
	QUIWidgetSilvesArenaRestRankCell.super.onExit(self)
end

function QUIWidgetSilvesArenaRestRankCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaRestRankCell:setInfo(info, index)
	if q.isEmpty(info) then
		return
	end

	self._ccbOwner.tf_team_name:setString(index..". "..info.teamName)
end

return QUIWidgetSilvesArenaRestRankCell