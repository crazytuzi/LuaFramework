-- @Author: liaoxianbo
-- @Date:   2020-05-07 16:51:13
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-07 16:51:17
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySevenRushBuyCell = class("QUIWidgetActivitySevenRushBuyCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetActivitySevenRushBuyCell:ctor(options)
	local ccbFile = "ccb/"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetActivitySevenRushBuyCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetActivitySevenRushBuyCell:onEnter()
end

function QUIWidgetActivitySevenRushBuyCell:onExit()
end

function QUIWidgetActivitySevenRushBuyCell:getContentSize()
end

return QUIWidgetActivitySevenRushBuyCell
