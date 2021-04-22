

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCityEntrance = class("QUIDialogMetalCityEntrance", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetIconAniTips = import("..widgets.QUIWidgetIconAniTips")

function QUIDialogMetalCityEntrance:ctor(options)
	local ccbFile = "ccb/Dialog_MetalCity_Entrance.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
	}
    QUIDialogMetalCityEntrance.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = false 
    
    CalculateUIBgSize(self._ccbOwner.sp_bg)
	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._rightGray = false

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
end



function QUIDialogMetalCityEntrance:viewDidAppear()
	QUIDialogMetalCityEntrance.super.viewDidAppear(self)
	self:setInfo()
	self:addBackEvent(false)

	--makeNodeFromNormalToGray(self._ccbOwner.node_right) 
end

function QUIDialogMetalCityEntrance:viewWillDisappear()
  	QUIDialogMetalCityEntrance.super.viewWillDisappear(self)
    if self._seasonScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._seasonScheduler)
    	self._seasonScheduler = nil
    end
	self:removeBackEvent()
end

function QUIDialogMetalCityEntrance:setInfo()
	self._ccbOwner.shop_is_lock:setVisible(false)
	if not remote.metalAbyss:checkMetalAbyssIsUnLock(false) then
		local config_ = app.unlock:getConfigByKey("UNLOCK_ABYSS") or {}
  		local unlockLevel = config_.team_level or 99
		if unlockLevel - 5 > remote.user.level then
			self._ccbOwner.shop_is_lock:setVisible(true)
			self._rightGray = true
			makeNodeFromNormalToGray(self._ccbOwner.node_right) 
		else
			makeNodeFromNormalToGray(self._ccbOwner.node_right_title) 
		end
	end

end


function QUIDialogMetalCityEntrance:_onTriggerLeft(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_left) == false then return end
    app.sound:playSound("common_small")

	remote.metalCity:openDialog()
end

function QUIDialogMetalCityEntrance:_onTriggerRight(event)
	if q.buttonEvent(event, self._ccbOwner.sp_icon_right) == false then 
		return 
	end
    app.sound:playSound("common_small")
	if self._rightGray then
		makeNodeFromNormalToGray(self._ccbOwner.node_right) 
	end
    remote.metalAbyss:openDialog()
end

function QUIDialogMetalCityEntrance:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalCityEntrance:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end


return QUIDialogMetalCityEntrance