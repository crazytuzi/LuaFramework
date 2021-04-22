--
-- Kumo.Wang
-- zhangbichen主题曲活动——音乐活动界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetZhangbichenActivityYinyuehuodong = class("QUIWidgetZhangbichenActivityYinyuehuodong", QUIWidget)

local QUIViewController = import("..QUIViewController")

function QUIWidgetZhangbichenActivityYinyuehuodong:ctor(options)
	local ccbFile = "ccb/Widget_Activity_Zhangbichen_Yinyuehuodong.ccbi"
	local callBacks = {}
	QUIWidgetZhangbichenActivityYinyuehuodong.super.ctor(self, ccbFile, callBacks, options)
end

return QUIWidgetZhangbichenActivityYinyuehuodong