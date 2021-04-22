--
-- Kumo.Wang
-- 斗魂场功能模块
--

local QUIWidgetSubModluesChoose = import("..widgets.QUIWidgetSubModluesChoose")
local QUIWidgetArenaSubModluesChoose = class("QUIWidgetArenaSubModluesChoose", QUIWidgetSubModluesChoose)

function QUIWidgetArenaSubModluesChoose:ctor(options)
	QUIWidgetArenaSubModluesChoose.super.ctor(self,options)
end

function QUIWidgetArenaSubModluesChoose:onEnter()
	QUIWidgetArenaSubModluesChoose.super.onEnter(self)
end

function QUIWidgetArenaSubModluesChoose:onExit()
	QUIWidgetArenaSubModluesChoose.super.onExit(self)
end

return QUIWidgetArenaSubModluesChoose