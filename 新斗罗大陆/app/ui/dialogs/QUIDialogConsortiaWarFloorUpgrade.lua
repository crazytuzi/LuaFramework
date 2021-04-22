-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 11:08:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:07:13

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarFloorUpgrade = class("QUIDialogConsortiaWarFloorUpgrade", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogConsortiaWarFloorUpgrade:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_duanwei.ccbi"
	local callBack = {
	}
	QUIDialogConsortiaWarFloorUpgrade.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true
    app.sound:playSound("arena_refresh")

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	self._rewardInfo = options.rewardInfo
	self._callBack = options.callBack
end

function QUIDialogConsortiaWarFloorUpgrade:viewDidAppear()
	QUIDialogConsortiaWarFloorUpgrade.super.viewDidAppear(self)

	self:setFloorInfo()
end

function QUIDialogConsortiaWarFloorUpgrade:viewWillDisappear()
	QUIDialogConsortiaWarFloorUpgrade.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarFloorUpgrade:setFloorInfo()
	local awards = string.split(self._rewardInfo.floorReward, ";")
	for i = 1, 3 do
		if awards[i] and awards[i] ~= "" then
			local itemsInfo = string.split(awards[i], "^")
			self:createItemBox(self._ccbOwner["node_item_"..i], itemsInfo[1], itemsInfo[2])
		end	
	end

	-- set icon
	local oldIcon = QUIWidgetFloorIcon.new({isLarge = true})
	oldIcon:setInfo(self._rewardInfo.oldFloor, "consortiaWar")
	self._ccbOwner.node_old_floor:removeAllChildren()
	self._ccbOwner.node_old_floor:setScale(0.33)
	self._ccbOwner.node_old_floor:addChild(oldIcon)

	local newIcon = QUIWidgetFloorIcon.new({isLarge = true})
	newIcon:setInfo(self._rewardInfo.newFloor, "consortiaWar")
	self._ccbOwner.node_new_floor:removeAllChildren()
	self._ccbOwner.node_new_floor:setScale(0.33)
	self._ccbOwner.node_new_floor:addChild(newIcon)
end

function QUIDialogConsortiaWarFloorUpgrade:createItemBox(node, itemId, itemCount)
	local itemBox = QUIWidgetItemsBox.new()
	local itemType = ITEM_TYPE.ITEM
	if tonumber(itemId) == nil then
		itemType = remote.items:getItemType(itemId)
	end
	itemBox:setPromptIsOpen(true)
	node:addChild(itemBox)
	itemBox:setGoodsInfo(tonumber(itemId), itemType, tonumber(itemCount))
end

function QUIDialogConsortiaWarFloorUpgrade:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarFloorUpgrade:_onTriggerClose()
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarFloorUpgrade:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack then
		callBack()
	end
end

return QUIDialogConsortiaWarFloorUpgrade