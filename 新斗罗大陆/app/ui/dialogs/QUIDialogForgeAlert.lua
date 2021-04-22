-- @Author: xurui
-- @Date:   2019-04-17 10:13:52
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-04-19 12:17:10
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogForgeAlert = class("QUIDialogForgeAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogForgeAlert:ctor(options)
	local ccbFile = "ccb/Dialog_select.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerCharge", callback = handler(self, self._onTriggerCharge)},
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
    }
    QUIDialogForgeAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_change)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
    if options then
    	self._callBack = options.callBack
    end

	self._dRechargeNum = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_sum_recharge")
	self._dForgeProbability = QStaticDatabase:sharedDatabase():getConfigurationValue("forge_begin_probability")
	self._bSelect = false
	self._iBtnType = 1     --1，充值按钮；2，继续按钮
end

function QUIDialogForgeAlert:viewDidAppear()
	QUIDialogForgeAlert.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogForgeAlert:viewWillDisappear()
  	QUIDialogForgeAlert.super.viewWillDisappear(self)
end

function QUIDialogForgeAlert:setInfo()
	if self._richText == nil then
		self._richText = QRichText.new({
	            {oType = "font", content = "当前锻造成功率为", size = 22, color = COLORS.j},
	            {oType = "font", content = tostring(self._dForgeProbability*100), size = 22, color = COLORS.k},
	            {oType = "font", content = "%，充值", size = 22, color = COLORS.j},
	            {oType = "font", content = tostring(self._dRechargeNum or 0), size = 22, color = COLORS.k},
	            {oType = "font", content = "元可解锁名匠锤将成功率提升至", size = 22, color = COLORS.j},
	            {oType = "font", content = "100%", size = 22, color = COLORS.k},
	        },360)
		self._richText:setAnchorPoint(ccp(0.5, 1))
		self._richText:setPositionY(-20)
		self._ccbOwner.normalText:addChild(self._richText)
	end

	self:setSelectStatus()
end

function QUIDialogForgeAlert:setSelectStatus( ... )
	self._ccbOwner.sp_on:setVisible(self._bSelect)
end

function QUIDialogForgeAlert:_onTriggerSelect()
  	app.sound:playSound("common_small")

  	self._bSelect = not self._bSelect
  	self:setSelectStatus()
end

function QUIDialogForgeAlert:_onTriggerCharge()
  	app.sound:playSound("common_small")

  	self._iBtnType = 1
    self:_onTriggerClose()
end

function QUIDialogForgeAlert:_onTriggerContinue()
  	app.sound:playSound("common_small")

  	self._iBtnType = 2
    self:_onTriggerClose()
end

function QUIDialogForgeAlert:_backClickHandler()
	self._iBtnType = nil
    self:_onTriggerClose()
end

function QUIDialogForgeAlert:_onTriggerClose()
  	app.sound:playSound("common_close")

  	if self._bSelect then
  		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.FORGE_BEST_HAMMER)
  	end

	self:playEffectOut()
end

function QUIDialogForgeAlert:viewAnimationOutHandler()
	local callback = self._callBack
	local iBtnType = self._iBtnType

	self:popSelf()

	if callback then
		callback(iBtnType)
	end
end

return QUIDialogForgeAlert
