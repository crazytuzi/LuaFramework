-- @Author: xurui
-- @Date:   2016-11-08 17:35:13
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-02-10 10:55:45
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogUnionActiveHall = class("QUIDialogUnionActiveHall", QUIDialogBaseUnion)

local QUIWidgetPersonalActiveClient = import("..widgets.QUIWidgetPersonalActiveClient")
local QUIWidgetUnionActiveClient = import("..widgets.QUIWidgetUnionActiveClient")
local QUIWidgetActiveRankClient = import("..widgets.QUIWidgetActiveRankClient")
local QNavigationController = import("...controllers.QNavigationController")

QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB = "PERSONAL_ACTIVE_TAB"
QUIDialogUnionActiveHall.UNION_ACTIVE_TAB = "UNION_ACTIVE_TAB"
QUIDialogUnionActiveHall.ACTIVE_RANK_TAB = "ACTIVE_RANK_TAB"

function QUIDialogUnionActiveHall:ctor(options)
	local ccbFile = "ccb/Dialog_society_gonghuihuoyue.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerPersonalActive", callback = handler(self, self._onTriggerPersonalActive)},
		{ccbCallbackName = "onTriggerUnionActive", callback = handler(self, self._onTriggerUnionActive)},
		{ccbCallbackName = "onTriggerActiveRank", callback = handler(self, self._onTriggerActiveRank)},
	}
	QUIDialogUnionActiveHall.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.state1:setVisible(true)
	self._ccbOwner.state2:setVisible(false)

	self._tab = QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB
	if options then
		self._tab = options.tab or self._tab
	end
end

function QUIDialogUnionActiveHall:viewDidAppear()
	QUIDialogUnionActiveHall.super.viewDidAppear(self)

	self:selectTab()

	self:addBackEvent(false)
end

function QUIDialogUnionActiveHall:viewWillDisappear()
	QUIDialogUnionActiveHall.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogUnionActiveHall:selectTab()
	self:getOptions().tab = self._tab

	self:setBtnState()

	if self._personalClient ~= nil then
		self._personalClient:setVisible(false)
	end

	if self._unionClient ~= nil then
		self._unionClient:setVisible(false)
	end

	if self._rankClient ~= nil then
		self._rankClient:setVisible(false)
	end

	if self._tab == QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB then
		if self._personalClient == nil then
			self._personalClient = QUIWidgetPersonalActiveClient.new()
			self._ccbOwner.node_client:addChild(self._personalClient)
		end
		self._personalClient:setVisible(true)
	elseif self._tab == QUIDialogUnionActiveHall.UNION_ACTIVE_TAB then
		if self._unionClient == nil then
			self._unionClient = QUIWidgetUnionActiveClient.new()
			self._ccbOwner.node_client:addChild(self._unionClient)
		end
		self._unionClient:setVisible(true)
		self._unionClient:setInfo()
	elseif self._tab == QUIDialogUnionActiveHall.ACTIVE_RANK_TAB then
		if self._rankClient == nil then
			self._rankClient = QUIWidgetActiveRankClient.new()
			self._ccbOwner.node_client:addChild(self._rankClient)
		end
		self._rankClient:setVisible(true)
		self._rankClient:setInfo()
	end
end

function QUIDialogUnionActiveHall:setBtnState()
	local personalActive = self._tab == QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB
	local unionActive = self._tab == QUIDialogUnionActiveHall.UNION_ACTIVE_TAB
	local activeRank = self._tab == QUIDialogUnionActiveHall.ACTIVE_RANK_TAB

	self._ccbOwner.btn_personal_active:setEnabled(not personalActive)
	self._ccbOwner.btn_personal_active:setHighlighted(personalActive)
	self._ccbOwner.btn_union_active:setEnabled(not unionActive)
	self._ccbOwner.btn_union_active:setHighlighted(unionActive)
	self._ccbOwner.btn_active_rank:setEnabled(not activeRank)
	self._ccbOwner.btn_active_rank:setHighlighted(activeRank)
end

function QUIDialogUnionActiveHall:_onTriggerPersonalActive()
	if self._tab == QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB then return end
    app.sound:playSound("common_small")

    self._tab = QUIDialogUnionActiveHall.PERSONAL_ACTIVE_TAB
    self:selectTab()
end

function QUIDialogUnionActiveHall:_onTriggerUnionActive()
	if self._tab == QUIDialogUnionActiveHall.UNION_ACTIVE_TAB then return end
    app.sound:playSound("common_small")

    self._tab = QUIDialogUnionActiveHall.UNION_ACTIVE_TAB
    self:selectTab()
end

function QUIDialogUnionActiveHall:_onTriggerActiveRank()
	if self._tab == QUIDialogUnionActiveHall.ACTIVE_RANK_TAB then return end
    app.sound:playSound("common_small")

    self._tab = QUIDialogUnionActiveHall.ACTIVE_RANK_TAB
    self:selectTab()
end

function QUIDialogUnionActiveHall:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogUnionActiveHall:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogUnionActiveHall