-- @Author: xurui
-- @Date:   2020-01-02 20:30:42
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-02 20:54:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTotemChallengeFloorAward = class("QUIDialogTotemChallengeFloorAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogTotemChallengeFloorAward:ctor(options)
	local ccbFile = "ccb/Dialog_totemChallenge_award.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogTotemChallengeFloorAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    	self._awardInfo = options.awardInfo
    	self._config = options.config
    end

    self._itemsBox = {}
end

function QUIDialogTotemChallengeFloorAward:viewDidAppear()
	QUIDialogTotemChallengeFloorAward.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogTotemChallengeFloorAward:viewWillDisappear()
  	QUIDialogTotemChallengeFloorAward.super.viewWillDisappear(self)
end

function QUIDialogTotemChallengeFloorAward:setInfo()
	local awards = {}
	remote.items:analysisServerItem(self._awardInfo.reward or "", awards)

	self._ccbOwner.tf_title:setString(string.format("恭喜您已经通关所有%s，请收下您的奖励", (self._config.name or "")))

	local itemCount = 0
	for index,value in ipairs(awards) do
    	self._itemsBox[index] = QUIWidgetItemsBox.new()
    	self._itemsBox[index]:setPromptIsOpen(true)
		self._ccbOwner.node_item:addChild(self._itemsBox[index])
		self._itemsBox[index]:setPositionX((index-1) * 100)
		self._itemsBox[index]:setGoodsInfo(value.id, value.type or value.typeName, value.count)
	end

	local awardsNum = #awards
	if awardsNum > 0 then
		local x = 120+(-(awardsNum - 1) * 50)
		if x < -50 then
			x = -50
		end
		self._ccbOwner.node_item:setPositionX(x)
	end
end

function QUIDialogTotemChallengeFloorAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTotemChallengeFloorAward:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogTotemChallengeFloorAward:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogTotemChallengeFloorAward
