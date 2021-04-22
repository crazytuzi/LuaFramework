--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林巢穴Icon
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineIcon = class("QUIWidgetSilverMineIcon", QUIWidget)

QUIWidgetSilverMineIcon.EVENT_OK = "QUIWIDGETSILVERMINEICON_EVENT_OK"

function QUIWidgetSilverMineIcon:ctor(options)
	self._quality = options.quality
	-- local ccbFile = "ccb/Widget_SilverMine_MineIcon.ccbi"
	local ccbFile = "ccb/Widget_SilverMine_MineIcon_"..self._quality..".ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSilverMineIcon._onTriggerOK)},
	}
	QUIWidgetSilverMineIcon.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    -- self._quality = options.quality
    self._isNoEvent = options.isNoEvent
    
	-- self:_init()
end

function QUIWidgetSilverMineIcon:onEnter()

end

function QUIWidgetSilverMineIcon:onExit()

end

function QUIWidgetSilverMineIcon:_onTriggerOK()
	if self._isNoEvent then return end
	self:dispatchEvent( {name = QUIWidgetSilverMineIcon.EVENT_OK} )
end

function QUIWidgetSilverMineIcon:_init()
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

return QUIWidgetSilverMineIcon