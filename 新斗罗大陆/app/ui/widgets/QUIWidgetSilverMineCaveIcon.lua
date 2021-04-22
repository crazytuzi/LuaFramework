--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineCaveIcon = class("QUIWidgetSilverMineCaveIcon", QUIWidget)

QUIWidgetSilverMineCaveIcon.EVENT_OK = "QUIWIDGETSILVERMINECAVEICON_EVENT_OK"

function QUIWidgetSilverMineCaveIcon:ctor(options)
	self._quality = options
	-- local ccbFile = "ccb/Widget_SilverMine_CaveIcon.ccbi"
	local ccbFile = "ccb/Widget_SilverMine_CaveIcon_"..self._quality..".ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSilverMineCaveIcon._onTriggerOK)},
	}
	QUIWidgetSilverMineCaveIcon.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
 --    self._quality = options
	-- self:_init()
end

function QUIWidgetSilverMineCaveIcon:onEnter()

end

function QUIWidgetSilverMineCaveIcon:onExit()

end

function QUIWidgetSilverMineCaveIcon:_onTriggerOK(event)
	if q.buttonEvent(event, self._ccbOwner.btn_quality) == false then return end
	self:dispatchEvent( {name = QUIWidgetSilverMineCaveIcon.EVENT_OK} )
end

function QUIWidgetSilverMineCaveIcon:_init()
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
end

return QUIWidgetSilverMineCaveIcon