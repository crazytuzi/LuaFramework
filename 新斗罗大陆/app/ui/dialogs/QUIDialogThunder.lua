local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunder = class("QUIDialogThunder", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetThunder = import("..widgets.QUIWidgetThunder")
local QUIWidgetThunderFail = import("..widgets.QUIWidgetThunderFail")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogThunder:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing.ccbi"
	local callBacks = {
	}
	QUIDialogThunder.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setManyUIVisible then page:setManyUIVisible() end
	if page.setScalingVisible then page:setScalingVisible(false) end
	if page.topBar then page.topBar:showWithThunder() end

    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

    self:checkTutorial()
end

function QUIDialogThunder:checkTutorial()
	if app.tutorial and app.tutorial:isTutorialFinished() == false then
		local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
		if page and page.class.__cname == "QUIPageMainMenu" then
			page:buildLayer()
			local haveTutorial = false
			if app.tutorial:getStage().thunder == app.tutorial.Guide_Start and app.unlock:getUnlockThunder() then
				local thunderHistoryEveryWaveStar = remote.thunder.thunderInfo.thunderHistoryEveryWaveStar or {}
				local advanceIndex = #thunderHistoryEveryWaveStar
				if advanceIndex > 0 then
					app.tutorial:getStage().thunder = 1
				else
					haveTutorial = app.tutorial:startTutorial(app.tutorial.Stage_Thunder)
				end
			end
			if haveTutorial == false then
				page:cleanBuildLayer()
			end
		end
	end
end

function QUIDialogThunder:viewDidAppear()
	QUIDialogThunder.super.viewDidAppear(self)
	self:addBackEvent(false)
	if FinalSDK.isHXShenhe() then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setBackBtnVisible(false)
    end
	self._eventPorxy = cc.EventProxy.new(remote.thunder)
	self._eventPorxy:addEventListener(remote.thunder.EVENT_UPDATE_INFO, handler(self, self.checkInfo))
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.checkInfo, self)

	self:checkInfo()
end

function QUIDialogThunder:viewWillDisappear()
    QUIDialogThunder.super.viewWillDisappear(self)
	self:removeBackEvent()
	if self._eventPorxy ~= nil then
	  	self._eventPorxy:removeAllEventListeners()
	end
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self.checkInfo, self)
end

function QUIDialogThunder:checkInfo()
  	self._ccbOwner.client:removeAllChildren()
	self.thunderFighter, self._layerConfig, self._lastIndex, self._buyPreciousTimes, self.isArrivalMaxLayer = remote.thunder:getThunderFighter()
	-- self._preciousAward = clone(remote.thunder:getThunderPreciousAward())
	self._buff = remote.thunder:getBuffByLayer(self._layerConfig.thunder_floor)

	if self.thunderFighter and self.thunderFighter.thunderLastChallengeIsFail == true then
		if self.isArrivalMaxLayer then
			self._ccbOwner.client:removeAllChildren()
			self._ccbOwner.client:addChild(QUIWidgetThunderFail.new({arrivalMaxLayer = true}))
		else
  			self._ccbOwner.client:addChild(QUIWidgetThunderFail.new())
  		end
		return
	end

	local checkLastFloor = function ( ... )
		if self.isArrivalMaxLayer then 
			remote.thunder:setIsBattle(true, false)
			remote.thunder:thunderQuickEnd()
			return true
		end
		return false
	end
	if remote.thunder:getIsBattle() ~= true and remote.thunder:getIsFast() ~= true then
		if self._buff == nil and self._lastIndex == 3 then
			self._mysteriousBaoxiangDialog = nil
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderBuff", 
				options = {callBack = function ()
					remote.thunder:setIsBattle(false)
				end}})
		elseif self._buyPreciousTimes > 0 --[[and self._lastIndex == 0]] then
			local layerPreciousTimes = remote.thunder:getPreciousTimes()
			if layerPreciousTimes ~= nil and #layerPreciousTimes > 0 then
				if self:getOptions().openDialog == nil then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderKingMysteriousMany",
						options = {callBack = function()
							checkLastFloor()
						end}})
					self:getOptions().openDialog = 1
				end
			else
				if self._mysteriousBaoxiangDialog == nil then
					self._mysteriousBaoxiangDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderKingMysteriousBaoxiang", 
						options = {times = self._buyPreciousTimes ,callBack = function()
							checkLastFloor()
						end}})
				end
			end
		else
			if checkLastFloor() then
				return
			end
		end
	else
		self:getOptions().openDialog = nil
		local layerPreciousTimes = remote.thunder:getPreciousTimes()
		if remote.thunder:getIsFast() == true and self._buyPreciousTimes > 0 and layerPreciousTimes ~= nil and #layerPreciousTimes > 0 then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderFastBattle", options = {isAllStar = true}})
		end
	end
	
	self._ccbOwner.client:addChild(QUIWidgetThunder.new())
end

function QUIDialogThunder:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogThunder:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end

function QUIDialogThunder:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogThunder:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogThunder