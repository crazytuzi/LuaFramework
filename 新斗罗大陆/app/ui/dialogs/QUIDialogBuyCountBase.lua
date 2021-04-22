--
-- Author: Your Name
-- Date: 2014-07-24 10:58:34
--
local QUIDialog = import(".QUIDialog")
local QUIDialogBuyCountBase = class("QUIDialogBuyCountBase", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBuyVirtualLog = import("..widgets.QUIWidgetBuyVirtualLog")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogBuyCountBase:ctor(options)
	local ccbFile = "ccb/Dialog_BuyCount.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIDialogBuyCountBase._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBuyCountBase._onTriggerClose)},
		{ccbCallbackName = "onTriggerBuyAgain", callback = handler(self, QUIDialogBuyCountBase._onTriggerBuyAgain)},
		{ccbCallbackName = "onTriggerVIP", callback = handler(self, QUIDialogBuyCountBase._onTriggerVIP)},
	}
	QUIDialogBuyCountBase.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

    local cls = options.cls
    if cls == nil then
    	cls = "QBuyCountBase"
    end
	cls = import(app.packageRoot .. ".modules.buycount."..cls)
    self._controller = cls.new()

	self._callBack = options.buyCallback
	self._buyCount = 0

	self._ccbOwner.tf_1:setString("")
	self._ccbOwner.tf_2:setString("")
	self._ccbOwner.tf_buy:setString("")
	self._ccbOwner.tf_need_num:setString("")
	self._ccbOwner.tf_receive_num:setString("")
	self._ccbOwner.tf_tips:setString("")

	self._ccbOwner.btn_buy:setVisible(false)
	self._ccbOwner.btn_VIP_Info:setVisible(false)

	self._ccbOwner.frame_tf_title:setString("购 买")

	self:refreshInfo()
end

function QUIDialogBuyCountBase:viewWillDisappear()
    QUIDialogBuyCountBase.super.viewWillDisappear(self)
    if self._delayHandler ~= nil then
		scheduler.unscheduleGlobal(self._delayHandler)	
	end
	
	if self._callBack then 
		self._callBack(self._buyCount) 
	end
end

function QUIDialogBuyCountBase:refreshInfo()
	self._controller:refreshInfo()

	self._ccbOwner.tf_1:setString(self._controller:getTitle())
	self._ccbOwner.tf_2:setString(self._controller:getDesc())
	self._ccbOwner.tf_buy:setString(self._controller:getCountDesc())
	self._ccbOwner.tf_need_num:setString(self._controller:getConsumeNum())
	self._ccbOwner.tf_receive_num:setString(self._controller:getReciveNum())
	self._ccbOwner.tf_tips:setString(self._controller:getRefreshDesc())

	if self._controller:checkCanBuy() == false then
		self:enableTouchSwallowTop()
		self:getView():setVisible(false)
		if self._controller:checkVipCanGrade() == false then
			app.tip:floatTip("今日可购买次数已经用完")
			scheduler.performWithDelayGlobal(function ()
				self:popSelf()
			end, 0)
		else
			scheduler.performWithDelayGlobal(function ()
				local controller = self._controller
				self:popSelf()
				controller:alertVipBuy()
			end, 0)
		end
	else
		self._ccbOwner.btn_buy:setVisible(true)
	end
	if self._icon == nil then
		self._icon = self:setIconPath(self._controller:getIconPath())
	end
end

function QUIDialogBuyCountBase:setIconPath(path)
	if path == nil then return end
    local icon = CCSprite:create()
    icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
    self._ccbOwner.node_icon:addChild(icon)
    self._ccbOwner.node_icon:setScale(0.82)
    return icon
end

function QUIDialogBuyCountBase:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyCountBase:_onTriggerBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buy) == false then return end
  	app.sound:playSound("common_confirm")
  	self._controller:requestBuy(function ()
  		self:refreshInfo()
  		self._buyCount = self._buyCount + 1
  	end)
end

function QUIDialogBuyCountBase:_onTriggerVIP(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_vip) == false then return end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", options = {vipContentLevel = QVIPUtil:VIPLevel()}})
end

function QUIDialogBuyCountBase:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBuyCountBase:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogBuyCountBase