--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderCaveIcon = class("QUIWidgetPlunderCaveIcon", QUIWidget)

QUIWidgetPlunderCaveIcon.EVENT_OK = "QUIWIDGETPLUNDERCAVEICON_EVENT_OK"

function QUIWidgetPlunderCaveIcon:ctor(options)
	self._quality = options
	-- local ccbFile = "ccb/Widget_plunder_caveIcon.ccbi"
	local ccbFile = "ccb/Widget_Plunder_CaveIcon_"..self._quality..".ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetPlunderCaveIcon._onTriggerOK)},
	}
	QUIWidgetPlunderCaveIcon.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
 --    self._quality = options
	-- self:_init()
end

function QUIWidgetPlunderCaveIcon:onEnter()

end

function QUIWidgetPlunderCaveIcon:onExit()

end

function QUIWidgetPlunderCaveIcon:_onTriggerOK()
	self:dispatchEvent( {name = QUIWidgetPlunderCaveIcon.EVENT_OK} )
end

function QUIWidgetPlunderCaveIcon:_init()
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

return QUIWidgetPlunderCaveIcon