--
-- Kumo.Wang
-- 斗魂场模块选项
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetNormalArenaModuleOption = class("QUIWidgetNormalArenaModuleOption", QUIWidget)

function QUIWidgetNormalArenaModuleOption:ctor(options)
	local ccbFile = "ccb/Widget_NormalArena_Module.ccbi"
  	local callBacks = {}
	QUIWidgetNormalArenaModuleOption.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetNormalArenaModuleOption:onEnter()
	QUIWidgetNormalArenaModuleOption.super.onEnter(self)
end

function QUIWidgetNormalArenaModuleOption:onExit()
	QUIWidgetNormalArenaModuleOption.super.onExit(self)
end

function QUIWidgetNormalArenaModuleOption:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetNormalArenaModuleOption:getBtnImg()
	return self._ccbOwner.sp_icon
end

function QUIWidgetNormalArenaModuleOption:getRedTipsImg()
	return self._ccbOwner.red_tips
end

return QUIWidgetNormalArenaModuleOption