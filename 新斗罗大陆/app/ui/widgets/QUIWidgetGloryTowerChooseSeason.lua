-- @Author: xurui
-- @Date:   2016-08-19 17:52:03
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-26 18:23:56
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGloryTowerChooseSeason = class("QUIWidgetGloryTowerChooseSeason", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

QUIWidgetGloryTowerChooseSeason.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetGloryTowerChooseSeason:ctor(options)
	local ccbFile = "ccb/Widget_GloryTower_saijixuanze.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetGloryTowerChooseSeason.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetGloryTowerChooseSeason:onEnter()
end

function QUIWidgetGloryTowerChooseSeason:onExit()
end

function QUIWidgetGloryTowerChooseSeason:setInfo(seasonInfo, index)
	self._index = index
	
	if seasonInfo.seasonStartAt then
		local startAt = seasonInfo.seasonStartAt/1000
		local endAt = seasonInfo.seasonEndAt/1000
		local seasonStr = q.timeToYearMonthDay(startAt).."~"..q.timeToYearMonthDay(endAt)
		self._ccbOwner.tf_time:setString(seasonStr)
	else
		self._ccbOwner.tf_time:setString((seasonInfo.beginDateStr or "").."-"..(seasonInfo.endDateStr or ""))
	end

	local seasonNO = tostring(seasonInfo.seasonNO or 1)

	self._ccbOwner.tf_season:setString("第"..seasonNO.."赛季")

	self:setSelectState(false)
end

function QUIWidgetGloryTowerChooseSeason:setSelectState(state)
	self._ccbOwner.on:setVisible(state)
end 

function QUIWidgetGloryTowerChooseSeason:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetGloryTowerChooseSeason.EVENT_CLICK, index = self._index})
end

return QUIWidgetGloryTowerChooseSeason