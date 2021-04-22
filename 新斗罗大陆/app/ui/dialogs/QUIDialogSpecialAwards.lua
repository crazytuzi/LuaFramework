-- @Author: liaoxianbo
-- @Date:   2020-05-06 14:39:47
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-08 18:03:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSpecialAwards = class("QUIDialogSpecialAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSpecialAwards = import("..widgets.QUIWidgetSpecialAwards")
local QPayUtil = import("...utils.QPayUtil")

function QUIDialogSpecialAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Special_Awards.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
    }
    QUIDialogSpecialAwards.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_buy)
	self._ccbOwner.frame_tf_title:setString(options.bigTitle or "特权购买")

	self._curActivityType = options.curActivityType or 1
	self._callBack = options.closeCallback or nil
	self._allSpecialItems = options.allSpecialItems or {} --界面上方奖励
	self._availableItems = options.availableItems or {} --界面下方奖励
	self._title1 = options.title1 or ""
	self._title2 = options.title2 or ""
	self._subTitle1 = options.subTitle1 or nil
	self._subTitle2 = options.subTitle2 or nil

	self:initAwardsView()
end

function QUIDialogSpecialAwards:viewDidAppear()
	QUIDialogSpecialAwards.super.viewDidAppear(self)

end

function QUIDialogSpecialAwards:viewWillDisappear()
  	QUIDialogSpecialAwards.super.viewWillDisappear(self)

end

function QUIDialogSpecialAwards:initAwardsView()

	local isShowLock = remote.user.calnivalPrizeIsActive or false
	if self._curActivityType == 2 then
		isShowLock = remote.user.celebrationPrizeIsActive or false
	end

	self._ccbOwner.sp_ishave:setVisible(isShowLock)
	self._ccbOwner.node_btn_buy:setVisible(not isShowLock)

	self._ccbOwner.node_all_award:removeAllChildren()
	self._ccbOwner.node_available_award:removeAllChildren()

	local allAwardsWidget = QUIWidgetSpecialAwards.new({title = self._title1,subtitle=self._subTitle1,awards = self._allSpecialItems})
	self._ccbOwner.node_all_award:addChild(allAwardsWidget)


	local availableAwardsWidget = QUIWidgetSpecialAwards.new({title = self._title2,subtitle=self._subTitle2,awards = self._availableItems})
	self._ccbOwner.node_available_award:addChild(availableAwardsWidget)

end

function QUIDialogSpecialAwards:fastBuy(price,rechargeBuyProductid)
	if price == nil or price == 0 then return end
	app.sound:playSound("common_small")

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(price, 7,rechargeBuyProductid)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(price, 7, rechargeBuyProductid)
		else
			QPayUtil:pay(price, 7, rechargeBuyProductid)
		end
	end
end

function QUIDialogSpecialAwards:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSpecialAwards:_onTriggerBuy( )
	app.sound:playSound("common_small")
	-- 128特权充值应策划要求直接写死 
	self:fastBuy(128,"128_"..self._curActivityType)
end

function QUIDialogSpecialAwards:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end


function QUIDialogSpecialAwards:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSpecialAwards
