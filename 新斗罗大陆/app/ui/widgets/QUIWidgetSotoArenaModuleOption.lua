--
-- Kumo.Wang
-- 云顶之战模块选项
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSotoArenaModuleOption = class("QUIWidgetSotoArenaModuleOption", QUIWidget)

function QUIWidgetSotoArenaModuleOption:ctor(options)
	local ccbFile = "ccb/Widget_SotoArena_Module.ccbi"
  	local callBacks = {}
	QUIWidgetSotoArenaModuleOption.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSotoArenaModuleOption:onEnter()
	QUIWidgetSotoArenaModuleOption.super.onEnter(self)
end

function QUIWidgetSotoArenaModuleOption:onExit()
	QUIWidgetSotoArenaModuleOption.super.onExit(self)
end

function QUIWidgetSotoArenaModuleOption:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSotoArenaModuleOption:getBtnImg()
	return self._ccbOwner.sp_icon
end

function QUIWidgetSotoArenaModuleOption:getRedTipsImg()
	return self._ccbOwner.red_tips
end

return QUIWidgetSotoArenaModuleOption