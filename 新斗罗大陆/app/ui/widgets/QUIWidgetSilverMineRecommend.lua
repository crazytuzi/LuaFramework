--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林引导
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilverMineRecommend = class("QUIWidgetSilverMineRecommend", QUIWidget)

QUIWidgetSilverMineRecommend.EVENT_OK = "QUIWIDGETSILVERMINERECOMMEND.EVENT_OK"

function QUIWidgetSilverMineRecommend:ctor(options)
	local ccbFile = "ccb/Widget_SilverMine_Recommend.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetSilverMineRecommend._onTriggerOK)},
	}
	QUIWidgetSilverMineRecommend.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSilverMineRecommend:onEnter()

end

function QUIWidgetSilverMineRecommend:onExit()

end

function QUIWidgetSilverMineRecommend:update( mineId )
	self._mineId = mineId
end

function QUIWidgetSilverMineRecommend:_onTriggerOK()
	if not self._mineId then return end
	self:dispatchEvent( {name = QUIWidgetSilverMineRecommend.EVENT_OK, mineId = self._mineId} )
end

return QUIWidgetSilverMineRecommend