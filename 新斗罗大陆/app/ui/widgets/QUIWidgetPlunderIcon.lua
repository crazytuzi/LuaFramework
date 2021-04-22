--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderIcon = class("QUIWidgetPlunderIcon", QUIWidget)

QUIWidgetPlunderIcon.EVENT_OK = "QUIWIDGETPLUNDERICON_EVENT_OK"

function QUIWidgetPlunderIcon:ctor(options)
	self._quality = options.quality
	local ccbFile = ""
	if self._quality == 1 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_1.ccbi"
	elseif self._quality == 2 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_2.ccbi"
	elseif self._quality == 3 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_3.ccbi"
	elseif self._quality == 4 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_4.ccbi"
	elseif self._quality == 5 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_5.ccbi"
	elseif self._quality == 6 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_6.ccbi"
	elseif self._quality == 7 then
		ccbFile = "ccb/Widget_SilverMine_MineIcon_7.ccbi"
	else
		ccbFile = "ccb/Widget_SilverMine_MineIcon_1.ccbi"
	end
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetPlunderIcon._onTriggerOK)},
	}
	QUIWidgetPlunderIcon.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    -- self._quality = options.quality
    self._isNoEvent = options.isNoEvent
    
	-- self:_init()
end

function QUIWidgetPlunderIcon:onEnter()

end

function QUIWidgetPlunderIcon:onExit()

end

function QUIWidgetPlunderIcon:_onTriggerOK()
	if self._isNoEvent then return end
	self:dispatchEvent( {name = QUIWidgetPlunderIcon.EVENT_OK} )
end

function QUIWidgetPlunderIcon:_init()
	local index = 1
	while true do
		local node = self._ccbOwner["node_quality_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end

	local node = self._ccbOwner["node_quality_"..self._quality]
	if node then
		node:setVisible(true)
	end
	if self._isNoEvent then
		self._ccbOwner["btn_quality_"..self._quality]:setEnabled(false)
	end
end

return QUIWidgetPlunderIcon