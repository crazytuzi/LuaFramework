-- @Author: xurui
-- @Date:   2019-02-18 14:49:14
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-21 20:26:01
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarBuffTip = class("QUIDialogUnionDragonWarBuffTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogUnionDragonWarBuffTip:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_zhufu.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogUnionDragonWarBuffTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._endAt = options.endAt or 0
    end
end

function QUIDialogUnionDragonWarBuffTip:viewDidAppear()
	QUIDialogUnionDragonWarBuffTip.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogUnionDragonWarBuffTip:viewWillDisappear()
  	QUIDialogUnionDragonWarBuffTip.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonWarBuffTip:setInfo()
    local configuration = db:getConfiguration()
    local data = configuration["sociaty_dragon_holy_bonous"].value or 0
    self._ccbOwner.tf_text:setString("魂师大人，您的宗主已经为您开启\n了武魂祝福！您将在祝福持续时间\n"..q.timeToHourMinuteSecond(self._endAt).."分内，对敌方武魂造成\n"..(data*100).."%的伤害")
	
end

function QUIDialogUnionDragonWarBuffTip:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDragonWarBuffTip:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogUnionDragonWarBuffTip
