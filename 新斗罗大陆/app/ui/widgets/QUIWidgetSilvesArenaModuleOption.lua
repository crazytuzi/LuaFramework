--
-- Kumo.Wang
-- 西尔维斯大斗魂场模块选项
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaModuleOption = class("QUIWidgetSilvesArenaModuleOption", QUIWidget)

local QUIWidgetFcaAnimation = import(".actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetSilvesArenaModuleOption:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Module.ccbi"
  	local callBacks = {}
	QUIWidgetSilvesArenaModuleOption.super.ctor(self,ccbFile,callBacks,options)

	self._isPeak = nil
	self:_updateState()
end

function QUIWidgetSilvesArenaModuleOption:onEnter()
	QUIWidgetSilvesArenaModuleOption.super.onEnter(self)
	self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.STATE_UPDATE, handler(self, self._updateState))
end

function QUIWidgetSilvesArenaModuleOption:onExit()
	QUIWidgetSilvesArenaModuleOption.super.onExit(self)
	self._silvesArenaProxy:removeAllEventListeners()
end

function QUIWidgetSilvesArenaModuleOption:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaModuleOption:getBtnImg()
	return self._ccbOwner.sp_icon
end

function QUIWidgetSilvesArenaModuleOption:getRedTipsImg()
	return self._ccbOwner.red_tips
end

-- 做一些特殊的处理
function QUIWidgetSilvesArenaModuleOption:_updateState()
	local curState = remote.silvesArena:getCurState(true)
	if curState == remote.silvesArena.STATE_PEAK then
		if self._isPeak == true then return end
		self._isPeak = true
		self._ccbOwner.node_effect:removeAllChildren()
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/tx_jianzhu_xewsrukou_effect", "res")
		fcaAnimation:playAnimation("animation", true)
		self._ccbOwner.node_effect:addChild(fcaAnimation)

		local fcaTitleAnimation = QUIWidgetFcaAnimation.new("fca/tx_ziti_effect", "res")
		fcaTitleAnimation:playAnimation("animation", true)
		fcaTitleAnimation:setPositionY(120)
		self._ccbOwner.node_effect:addChild(fcaTitleAnimation)
		self._ccbOwner.node_effect_bg:setVisible(true)
	else
		if self._isPeak == false then return end
		self._isPeak = false
		self._ccbOwner.node_effect:removeAllChildren()
		local fcaAnimation = QUIWidgetFcaAnimation.new("fca/xierweisi_4", "res")
		fcaAnimation:playAnimation("animation", true)
		self._ccbOwner.node_effect:addChild(fcaAnimation)
		self._ccbOwner.node_effect_bg:setVisible(false)
	end
end

return QUIWidgetSilvesArenaModuleOption