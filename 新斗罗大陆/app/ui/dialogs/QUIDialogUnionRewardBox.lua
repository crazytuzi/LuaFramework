--
-- Author: wkwang
-- Date: 2014-07-28 19:39:30
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionRewardBox = class("QUIDialogUnionRewardBox", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

QUIDialogUnionRewardBox.EVENT_GET_SUCC = "EVENT_GET_SUCC"

function QUIDialogUnionRewardBox:ctor(options)
	local ccbFile = "ccb/Dialog_Union_Reward.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogUnionRewardBox._onTriggerCancel)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogUnionRewardBox._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionRewardBox._onTriggerClose)},
    }
    QUIDialogUnionRewardBox.super.ctor(self, ccbFile, callBacks, options)

    self.isAnimation = true

    local boxNum = options.boxNum or 1
    local rewardType = options.type or 1
    local condition, basicAward
    if rewardType == 1 then
    	condition = db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].fete_schedule
    	basicAward = db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].basic_award
    else
    	condition = db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].fete_schedule
    	basicAward = db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].basic_award
    end
    self._ccbOwner.title_level:setVisible(rewardType == 1)
    self._ccbOwner.title_fete:setVisible(rewardType == 2)
    self._ccbOwner.level_condition:setString(condition)
    self._ccbOwner.fete_condition:setString(condition)
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.btn_cancel:setVisible(false)
	self._ccbOwner.btn_close:setVisible(true)

	self._items = {}
	self._awards = {}
	local strs = string.split(basicAward, ";")
	for _,str in ipairs(strs) do
		if str ~= nil and str ~= "" then
			local _awards = string.split(str, "^")
			local typeName = remote.items:getItemType(_awards[1])
			local id = nil
			local count = tonumber(_awards[2])
			if typeName == nil then
				typeName = ITEM_TYPE.ITEM
				id = tonumber(_awards[1])
			end
			table.insert(self._awards, {id = id, typeName = typeName, count = count})
		end
	end
	for index,award in ipairs(self._awards) do
		local item = QUIWidgetItemsBox.new()
		item:setGoodsInfo(award.id, award.typeName, award.count, true)
		item:setPositionX((index - 1) * 120)
		item:setPromptIsOpen(true)
		self._ccbOwner.node1:addChild(item)
	end
	self._ccbOwner.node1:setPositionX(-(#self._awards - 1) * 120/2)
end

function QUIDialogUnionRewardBox:_backClickHandler()
    self:_close()
end

function QUIDialogUnionRewardBox:_onTriggerCancel()
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogUnionRewardBox:_onTriggerClose()
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogUnionRewardBox:_close()
    self:playEffectOut()
end

function QUIDialogUnionRewardBox:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil, self)
end

function QUIDialogUnionRewardBox:_onTriggerConfirm()
	app.sound:playSound("common_confirm")
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil, self)
	if self:getOptions().confirmCallback then
		self:getOptions().confirmCallback()
	end
end

return QUIDialogUnionRewardBox