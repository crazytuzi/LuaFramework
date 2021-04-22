--
-- Author: Kumo
-- Date: 2017-12-12 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunWarNewAlert = class("QUIDialogSunWarNewAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogSunWarNewAlert:ctor(options) 
 	local ccbFile = "ccb/Dialog_SunWar_haishenzhiguang.ccbi"
	local callBacks = {
	    -- {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSunWarNewAlert._onTriggerClose)},
	}
	QUIDialogSunWarNewAlert.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = options.isAnimation == nil and true or false

    -- self._isNewDay = options.isNewDay
    -- self._ccbOwner.node_newMap:setVisible(not self._isNewDay)
    -- self._ccbOwner.node_newDay:setVisible(self._isNewDay)
    -- if self._isNewDay then
    --     app:getUserOperateRecord():recordLastOpenSunWarTime( q.serverTime() ) 
    -- end
end

function QUIDialogSunWarNewAlert:viewDidAppear()
    QUIDialogSunWarNewAlert.super.viewDidAppear(self)
end

function QUIDialogSunWarNewAlert:viewWillDisAppear()
    QUIDialogSunWarNewAlert.super.viewWillDisAppear(self)
end

function QUIDialogSunWarNewAlert:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSunWarNewAlert:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogSunWarNewAlert