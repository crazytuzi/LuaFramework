-- @Author: xurui
-- @Date:   2016-08-18 15:04:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-08-18 15:43:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGloryTowerSeasonEnd = class("QUIDialogGloryTowerSeasonEnd", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogGloryTowerSeasonEnd:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_jiesuan.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
	}
	QUIDialogGloryTowerSeasonEnd.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	if options then
		self._lastFloor = options.lastFloor
	end

    local config = QStaticDatabase:sharedDatabase():getGloryTower(self._lastFloor or 0)
    local floorName = config.name or "青铜5层"
	self._ccbOwner.tf_floor_name:setString(floorName)
end

function QUIDialogGloryTowerSeasonEnd:viewWillAppear()
	QUIDialogGloryTowerSeasonEnd.super.viewWillAppear(self)
end

function QUIDialogGloryTowerSeasonEnd:viewDidAppear()
	QUIDialogGloryTowerSeasonEnd.super.viewDidAppear(self)
end

function QUIDialogGloryTowerSeasonEnd:_onTriggerConfirm()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:close()
end

function QUIDialogGloryTowerSeasonEnd:_backClickHandler()
	self:close()
end

function QUIDialogGloryTowerSeasonEnd:close()
	self:playEffectOut()
end

function QUIDialogGloryTowerSeasonEnd:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogGloryTowerSeasonEnd