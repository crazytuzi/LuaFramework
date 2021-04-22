-- @Author: xurui
-- @Date:   2018-11-21 16:46:50
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-25 19:18:11
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStormArenaDescription = class("QUIDialogStormArenaDescription", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogStormArenaDescription:ctor(options)
	local ccbFile = "ccb/Dialog_StormArena_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogStormArenaDescription.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    self._pageIndex = 1
end

function QUIDialogStormArenaDescription:viewDidAppear()
	QUIDialogStormArenaDescription.super.viewDidAppear(self)
end

function QUIDialogStormArenaDescription:viewWillDisappear()
  	QUIDialogStormArenaDescription.super.viewWillDisappear(self)
end

function QUIDialogStormArenaDescription:changePage()
	self._ccbOwner.node_page_1:setVisible(false)
	self._ccbOwner.node_page_2:setVisible(true)

	self._pageIndex = 2
end

function QUIDialogStormArenaDescription:_backClickHandler()
	if self._pageIndex == 1 then
		self:changePage()
	else
    	self:_onTriggerClose()
	end
end

function QUIDialogStormArenaDescription:_onTriggerClose()
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogStormArenaDescription:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogStormArenaDescription
