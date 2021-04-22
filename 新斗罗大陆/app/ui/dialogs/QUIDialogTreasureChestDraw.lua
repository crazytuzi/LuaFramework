--
-- Author: wkwang
-- Date: 2014-10-25 10:29:58
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTreasureChestDraw = class("QUIDialogTreasureChestDraw", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QFlag = import("...utils.QFlag")
local QUIViewController = import("..QUIViewController")
local QUIWidgetChestSilver = import("..widgets.QUIWidgetChestSilver")
local QUIWidgetChestGold = import("..widgets.QUIWidgetChestGold")

function QUIDialogTreasureChestDraw:ctor(options)
	local ccbFile = "ccb/Dialog_TreasureChestDraw_new.ccbi"
    local callBacks = {
    }
    QUIDialogTreasureChestDraw.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setScalingVisible then page:setScalingVisible(true) end
    if page.setManyUIVisible then page:setManyUIVisible() end
    
    -- CalculateUIBgSize(self._ccbOwner.node_gold_bg, 1280)
    CalculateUIBgSize(self._ccbOwner.node_sliver_bg, 1280)

    self._doAni = options.doAni or true
end

function QUIDialogTreasureChestDraw:viewDidAppear()
	QUIDialogTreasureChestDraw.super.viewDidAppear(self)

	self:setClientInfo()

	self:addBackEvent(true)
	remote.blackrock:setInviteEnable(false)
end

function QUIDialogTreasureChestDraw:viewWillDisappear()
  	QUIDialogTreasureChestDraw.super.viewWillDisappear(self)

	self:removeBackEvent()
	remote.blackrock:setInviteEnable(true)

	if self._sliverListener then
		self._sliverPanel:removeEventListener(self._sliverListener)
	end
	if self._goldListener then
		self._goldPanel:removeEventListener(self._goldListener)
	end
end

function QUIDialogTreasureChestDraw:setClientInfo()
	self._sliverPanel = QUIWidgetChestSilver.new()
	self._ccbOwner.sliver_contain:addChild(self._sliverPanel)
	self._sliverListener = self._sliverPanel:addEventListener(QUIWidgetChestSilver.EVENT_CLICK, self:safeHandler(function()
			if self._sliverListener then
				self._sliverPanel:removeEventListener(self._sliverListener)
			end
			if self._doAni then
				local sPosX, sPosY = self._ccbOwner.sliver_contain:getPosition()
				local sArr = CCArray:create()
				sArr:addObject(CCEaseOut:create(CCMoveTo:create(0.15, ccp(sPosX - display.width/2, sPosY)), 0.15))
				sArr:addObject(CCCallFunc:create(function()
						app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHero", 
							options = {tavernType = TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE}})
					end))
				self._ccbOwner.sliver_contain:runAction(CCSequence:create(sArr))

				local gPosX, gPosY = self._ccbOwner.gold_contain:getPosition()
				local gArr = CCArray:create()
				gArr:addObject(CCEaseOut:create(CCMoveTo:create(0.15, ccp(gPosX + display.width/2, gPosY)), 0.15))
				self._ccbOwner.gold_contain:runAction(CCSequence:create(gArr))
			end
		end))	
	self._goldPanel = QUIWidgetChestGold.new()
	self._ccbOwner.gold_contain:addChild(self._goldPanel)
	self._goldListener = self._goldPanel:addEventListener(QUIWidgetChestGold.EVENT_CLICK, self:safeHandler(function()
			if self._goldListener then
				self._goldPanel:removeEventListener(self._goldListener)
			end
			if self._doAni then
				local sPosX, sPosY = self._ccbOwner.sliver_contain:getPosition()
				local sArr = CCArray:create()
				sArr:addObject(CCEaseOut:create(CCMoveTo:create(0.15, ccp(sPosX - display.width/2, sPosY)), 0.15))
				self._ccbOwner.sliver_contain:runAction(CCSequence:create(sArr))
				
				local gPosX, gPosY = self._ccbOwner.gold_contain:getPosition()
				local gArr = CCArray:create()
				gArr:addObject(CCEaseOut:create(CCMoveTo:create(0.15, ccp(gPosX + display.width/2, gPosY)), 0.15))
				gArr:addObject(CCCallFunc:create(function()
						app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHero", 
							options = {tavernType = TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE}})
					end))
				self._ccbOwner.gold_contain:runAction(CCSequence:create(gArr))
			end
		end))
	if self._doAni then
		local sPosX, sPosY = self._ccbOwner.sliver_contain:getPosition()
		local gPosX, gPosY = self._ccbOwner.gold_contain:getPosition()
		self._ccbOwner.sliver_contain:setPositionX(sPosX - display.width/2)
		self._ccbOwner.gold_contain:setPositionX(gPosX + display.width/2)

		local easeIn1 = CCEaseIn:create(CCMoveTo:create(0.15, ccp(sPosX, sPosY)), 0.15)
		self._ccbOwner.sliver_contain:runAction(easeIn1)
		local easeIn2 = CCEaseIn:create(CCMoveTo:create(0.15, ccp(gPosX, gPosY)), 0.15)
		self._ccbOwner.gold_contain:runAction(easeIn2)
	end
end

function QUIDialogTreasureChestDraw:_backClickHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogTreasureChestDraw:onTriggerBackHandler(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 返回主界面
function QUIDialogTreasureChestDraw:onTriggerHomeHandler(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogTreasureChestDraw