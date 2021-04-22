-- @Author: xurui
-- @Date:   2016-11-10 10:59:14
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-11-29 20:31:42
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogUnionActiveChest = class("QUIDialogUnionActiveChest", QUIDialogBaseUnion)

local QUIWidgetActiveChestClient = import("..widgets.QUIWidgetActiveChestClient")
local QUIWidgetActiveRecordeClient = import("..widgets.QUIWidgetActiveRecordeClient")
local QNavigationController = import("...controllers.QNavigationController")

QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB = "ACTIVE_CHEST_TAB"
QUIDialogUnionActiveChest.CHEST_RECORDE_TAB = "CHEST_RECORDE_TAB"

function QUIDialogUnionActiveChest:ctor(options)
	local ccbFile = "ccb/Dialog_society_gonghuihuoyue.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerActiveChest", callback = handler(self, self._onTriggerActiveChest)},
		{ccbCallbackName = "onTriggerActiveRecorde", callback = handler(self, self._onTriggerActiveRecorde)},
	}
	QUIDialogUnionActiveChest.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.state2:setVisible(true)
	self._ccbOwner.state1:setVisible(false)

	self._tab = QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB
	if options then
		self._tab = options.tab or self._tab
	end
end

function QUIDialogUnionActiveChest:viewDidAppear()
	QUIDialogUnionActiveChest.super.viewDidAppear(self)

	self:selectTab()

	self:addBackEvent(false)
end

function QUIDialogUnionActiveChest:viewWillDisappear()
	QUIDialogUnionActiveChest.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogUnionActiveChest:selectTab()
	self:getOptions().tab = self._tab

	self:setBtnState()

	if self._chestClient ~= nil then
		self._chestClient:setVisible(false)
	end

	if self._recordeClient ~= nil then
		self._recordeClient:setVisible(false)
	end

	if self._tab == QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB then
		if self._chestClient == nil then
			self._chestClient = QUIWidgetActiveChestClient.new()
			self._ccbOwner.node_client:addChild(self._chestClient)
			self._chestClient:addEventListener(QUIWidgetActiveChestClient.CHEST_IS_DONE, handler(self, self.onTriggerBackHandler))
		end
		self._chestClient:setVisible(true)
		self._chestClient:setInfo()
	elseif self._tab == QUIDialogUnionActiveChest.CHEST_RECORDE_TAB then
		if self._recordeClient == nil then
			self._recordeClient = QUIWidgetActiveRecordeClient.new()
			self._ccbOwner.node_client:addChild(self._recordeClient)
		end
		self._recordeClient:setVisible(true)
		self._recordeClient:setInfo()
	end
end

function QUIDialogUnionActiveChest:setBtnState()
	local activeChest = self._tab == QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB
	local activeRecorde = self._tab == QUIDialogUnionActiveChest.CHEST_RECORDE_TAB

	self._ccbOwner.btn_active_award:setEnabled(not activeChest)
	self._ccbOwner.btn_active_award:setHighlighted(activeChest)
	self._ccbOwner.btn_award_recorde:setEnabled(not activeRecorde)
	self._ccbOwner.btn_award_recorde:setHighlighted(activeRecorde)
end

function QUIDialogUnionActiveChest:_onTriggerActiveChest()
	if self._tab == QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB then return end
    app.sound:playSound("common_small")

    self._tab = QUIDialogUnionActiveChest.ACTIVE_CHEST_TAB
    self:selectTab()
end

function QUIDialogUnionActiveChest:_onTriggerActiveRecorde()
	if self._tab == QUIDialogUnionActiveChest.CHEST_RECORDE_TAB then return end
    app.sound:playSound("common_small")

    self._tab = QUIDialogUnionActiveChest.CHEST_RECORDE_TAB
    self:selectTab()
end

function QUIDialogUnionActiveChest:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogUnionActiveChest:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogUnionActiveChest