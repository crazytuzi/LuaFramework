--
-- Author: Kumo.Wang
-- 大富翁奇遇获奖界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyLuckyAward = class("QUIDialogMonopolyLuckyAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogMonopolyLuckyAward:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_reward3.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogMonopolyLuckyAward.super.ctor(self, ccbFile, callBack, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	self._prizes = options.prizes

    self:resetAll()
end

function QUIDialogMonopolyLuckyAward:viewDidAppear()
	QUIDialogMonopolyLuckyAward.super.viewDidAppear(self)
end

function QUIDialogMonopolyLuckyAward:viewWillDisappear()
	QUIDialogMonopolyLuckyAward.super.viewWillDisappear(self)
end

function QUIDialogMonopolyLuckyAward:resetAll()
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(self._prizes[1].id, self._prizes[1].type, self._prizes[1].count)
	itemBox:setPromptIsOpen(true)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(itemBox)
	self._ccbOwner.node_icon:setVisible(true)
end

function QUIDialogMonopolyLuckyAward:_onTriggerOK()
    app.sound:playSound("common_small")
    self:_onTriggerClose()
end

function QUIDialogMonopolyLuckyAward:_onTriggerClose()
	self:popSelf()
end

return QUIDialogMonopolyLuckyAward