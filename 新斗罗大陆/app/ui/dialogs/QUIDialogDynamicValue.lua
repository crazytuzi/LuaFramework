-- @Author: vicentboo
-- @Date:   2019-08-19 11:02:38
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-04 19:30:25
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDynamicValue = class("QUIDialogDynamicValue", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIDialogDynamicValue.HERO_HULIENA = "HERO_HULIENA"
QUIDialogDynamicValue.HERO_TANGSAN = "HERO_TANGSAN"

QUIDialogDynamicValue.HERO_XIAOWU = "HERO_XIAOWU"
QUIDialogDynamicValue.HERO_NINGRONGRONG = "HERO_NINGRONGRONG"
QUIDialogDynamicValue.HERO_SONGYI = "HERO_SONGYI"



function QUIDialogDynamicValue:ctor(options)
    if options then
    	self._callBack = options.callBack
    	self._heroName = options.heroName
    end
    local ccbFile = "ccb/Dialog_dynamicValue1.ccbi"
    local bg_res = ""
    if self._heroName == QUIDialogDynamicValue.HERO_HULIENA then
    	ccbFile = "ccb/Dialog_dynamicValue2.ccbi"
    elseif self._heroName == QUIDialogDynamicValue.HERO_HULIENA then
    	ccbFile = "ccb/Dialog_dynamicValue1.ccbi"
    elseif self._heroName == QUIDialogDynamicValue.HERO_XIAOWU then
        ccbFile = "ccb/Dialog_dynamicValue3.ccbi"
        bg_res = QResPath("value_sxiaowu_nextDay")
    elseif self._heroName == QUIDialogDynamicValue.HERO_NINGRONGRONG then
        ccbFile = "ccb/Dialog_dynamicValue3.ccbi"
        bg_res = QResPath("value_ningrongrong_nextDay")
    elseif self._heroName == QUIDialogDynamicValue.HERO_SONGYI then
        ccbFile = "ccb/Dialog_dynamicValue3.ccbi"
        bg_res = QResPath("value_songyi_nextDay")
    end
	
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogDynamicValue.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._isEnd = false

    if bg_res ~= "" and self._ccbOwner.sp_value_bg then
        QSetDisplayFrameByPath(self._ccbOwner.sp_value_bg, bg_res)
    end

end

function QUIDialogDynamicValue:viewDidAppear()
	QUIDialogDynamicValue.super.viewDidAppear(self)

    self._schedulerHandler = scheduler.performWithDelayGlobal(function()
        self._isEnd = true
    end, 1)
end

function QUIDialogDynamicValue:viewWillDisappear()
  	QUIDialogDynamicValue.super.viewWillDisappear(self)

    if self._schedulerHandler ~= nil then
        scheduler.unscheduleGlobal(self._schedulerHandler)
        self._schedulerHandler = nil
    end
end

function QUIDialogDynamicValue:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogDynamicValue:_onTriggerClose()
    if self._isEnd == false then return end

  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogDynamicValue:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogDynamicValue
