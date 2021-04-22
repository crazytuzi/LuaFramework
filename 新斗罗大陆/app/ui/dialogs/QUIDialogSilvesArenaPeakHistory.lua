-- 
-- Kumo.Wang
-- silves巅峰赛上赛季前三名
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSilvesArenaPeakHistory = class("QUIDialogSilvesArenaPeakHistory", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local QUIWidgetSilvesArenaHistoryClient = import("..widgets.QUIWidgetSilvesArenaHistoryClient")

function QUIDialogSilvesArenaPeakHistory:ctor(options)
	local ccbFile = "Dialog_SilvesArena_Peak_History.ccbi"
	local callBacks = {}
	QUIDialogSilvesArenaPeakHistory.super.ctor(self,ccbFile,callBacks,options)

    self._sacle = CalculateUIBgSize(self._ccbOwner.node_bg, 1024)
    if self._sacle <= 1.25 then
    	self._sacle = 1.25
    end
	self._ccbOwner.node_bg:setScale(self._sacle)

    self._ccbOwner.node_effect_bg:setScale(self._sacle) -- 这里放的特效是以1024为背景尺寸制作的。

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then page.topBar:showWithSilvesArena() end
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

	self:_init()
end

function QUIDialogSilvesArenaPeakHistory:viewDidAppear()
	QUIDialogSilvesArenaPeakHistory.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogSilvesArenaPeakHistory:viewWillDisappear()
	QUIDialogSilvesArenaPeakHistory.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSilvesArenaPeakHistory:_init()
	self._ccbOwner.sp_bg_rest:setPosition(ccp(0, 0))
	self._ccbOwner.sp_bg_rest:setOpacity(255)
	self._ccbOwner.sp_bg_rest:setScale(1)
	self._ccbOwner.sp_bg_rest:stopAllActions()
	self._ccbOwner.sp_bg_rest:setVisible(true)

	self._ccbOwner.node_effect_bg:removeAllChildren()

	local fcaEffect = QUIWidgetFcaAnimation.new("fca/xews_bg_1", "res")
	self._ccbOwner.node_effect_bg:addChild(fcaEffect)
	fcaEffect:playAnimation("animation", true)
	fcaEffect:setPositionY(100)

	self._ccbOwner.node_waiting_view:removeAllChildren()
	self._client = QUIWidgetSilvesArenaHistoryClient.new()
	self._ccbOwner.node_waiting_view:addChild(self._client)

	self._ccbOwner.node_view:setVisible(true)
end

function QUIDialogSilvesArenaPeakHistory:onTriggerBackHandler()
	self:popSelf()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.topBar then page.topBar:showWithSilvesArena() end
end

return QUIDialogSilvesArenaPeakHistory
