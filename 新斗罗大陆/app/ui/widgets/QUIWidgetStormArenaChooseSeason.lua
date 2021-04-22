
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormArenaChooseSeason = class("QUIWidgetStormArenaChooseSeason", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

QUIWidgetStormArenaChooseSeason.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetStormArenaChooseSeason:ctor(options)
	local ccbFile = "ccb/Widget_GloryTower_saijixuanze.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetStormArenaChooseSeason.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetStormArenaChooseSeason:onEnter()
end

function QUIWidgetStormArenaChooseSeason:onExit()
end

function QUIWidgetStormArenaChooseSeason:setInfo(seasonInfo, index)
	self._index = index
	
	if seasonInfo.seasonStartAt then
		local startAt = seasonInfo.seasonStartAt/1000
		local endAt = seasonInfo.seasonEndAt/1000
		local seasonStr = q.timeToYearMonthDay(startAt).."~"..q.timeToYearMonthDay(endAt)
		self._ccbOwner.tf_time:setString(seasonStr)
	else
		self._ccbOwner.tf_time:setString((seasonInfo.beginDateStr or "").."-"..(seasonInfo.endDateStr or ""))
	end

	local seasonNO = tostring(seasonInfo.seasonNo or 1)

	self._ccbOwner.tf_season:setString("第"..seasonNO.."赛季")

	self:setSelectState(false)
end

function QUIWidgetStormArenaChooseSeason:setSelectState(state)
	self._ccbOwner.on:setVisible(state)
end 

function QUIWidgetStormArenaChooseSeason:_onTriggerClick()
    app.sound:playSound("common_switch")
	self:dispatchEvent({name = QUIWidgetStormArenaChooseSeason.EVENT_CLICK, index = self._index})
end

return QUIWidgetStormArenaChooseSeason