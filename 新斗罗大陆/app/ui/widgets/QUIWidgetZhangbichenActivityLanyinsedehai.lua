--
-- Kumo.Wang
-- zhangbichen主题曲活动——蓝银色的海界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenActivityLanyinsedehai = class("QUIWidgetZhangbichenActivityLanyinsedehai", QUIWidget)

local QUIViewController = import("..QUIViewController")

function QUIWidgetZhangbichenActivityLanyinsedehai:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Zhangbichen_lanyinsedehai.ccbi"
	local callBacks = {}
	QUIWidgetZhangbichenActivityLanyinsedehai.super.ctor(self, ccbFile, callBacks, options)
end

return QUIWidgetZhangbichenActivityLanyinsedehai