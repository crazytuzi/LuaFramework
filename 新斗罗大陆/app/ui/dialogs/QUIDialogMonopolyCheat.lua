--
-- Author: Kumo.Wang
-- 大富翁鬼影迷踪主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyCheat = class("QUIDialogMonopolyCheat", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogMonopolyCheat:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_touzi.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMonopolyCheat.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("遥控骰子")

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	self._itemId = options.itemId
	self._selectSpan = {}

	self:_calculateSelectSpan()
    self:_resetAll()
end

function QUIDialogMonopolyCheat:viewDidAppear()
	QUIDialogMonopolyCheat.super.viewDidAppear(self)
end

function QUIDialogMonopolyCheat:viewWillDisappear()
	QUIDialogMonopolyCheat.super.viewWillDisappear(self)
end

function QUIDialogMonopolyCheat:_resetAll()
	for i = 1, #remote.monopoly.formulaTbl, 1 do
		if i >= tonumber(self._selectSpan[1]) and i <= tonumber(self._selectSpan[2]) then
			self._ccbOwner["btn_select_"..i]:setVisible(true)
			self._ccbOwner["btn_select_"..i]:setEnabled(true)
			-- makeNodeFromGrayToNormal(self._ccbOwner["node_"..i])
			self._ccbOwner["sp_mask"..i]:setVisible(false)
		else
			self._ccbOwner["btn_select_"..i]:setVisible(false)
			self._ccbOwner["btn_select_"..i]:setEnabled(false)
			-- makeNodeFromNormalToGray(self._ccbOwner["node_"..i])
			self._ccbOwner["sp_mask"..i]:setVisible(true)
		end
		self._ccbOwner["node_select"..i]:setVisible(true)
		self._ccbOwner["node_select_an"..i]:setVisible(false)
	end
	-- makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	self._ccbOwner.tf_btnOK:disableOutline()
	self._ccbOwner.btn_ok:setEnabled(false)
	self._curSelectIndex = 0
end

function QUIDialogMonopolyCheat:_calculateSelectSpan()
	for _, value in ipairs(remote.monopoly.cheatItemInfo) do
		if value.itemId == self._itemId then
			local config = value.config
			self._selectSpan = string.split(config.target_number, ",")
		end
	end
end

function QUIDialogMonopolyCheat:_onTriggerSelect(event, target)
	app.sound:playSound("common_small")
	self:_resetAll()
	for i = 1, #remote.monopoly.formulaTbl, 1 do
		if target == self._ccbOwner["btn_select_"..i] then
			self._ccbOwner["node_select"..i]:setVisible(false)
			self._ccbOwner["node_select_an"..i]:setVisible(true)
			self._curSelectIndex = i
			-- makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
			self._ccbOwner.tf_btnOK:enableOutline()
			self._ccbOwner.btn_ok:setEnabled(true)
			self._ccbOwner["sp_mask"..i]:setVisible(false)
		end
	end
end

function QUIDialogMonopolyCheat:_onTriggerOK()
    app.sound:playSound("common_small")
    if self._curSelectIndex and self._curSelectIndex > 0 then
    	remote.monopoly:monopolyCheatRequest(self._itemId, self._curSelectIndex, self:safeHandler(function()
    			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    		end))
    end
end

function QUIDialogMonopolyCheat:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMonopolyCheat:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	self:playEffectOut()
end

function QUIDialogMonopolyCheat:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogMonopolyCheat