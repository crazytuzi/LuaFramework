-- 
-- zxs
-- 武魂战段位升级
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarFloorUpgrade = class("QUIDialogUnionDragonWarFloorUpgrade", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogUnionDragonWarFloorUpgrade:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_duanwei.ccbi"
	local callBack = {
	}
	QUIDialogUnionDragonWarFloorUpgrade.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	if options then
		self._rewardInfo = options.rewardInfo
		self._callBack = options.callBack
	end
    app.sound:playSound("arena_refresh")
end

function QUIDialogUnionDragonWarFloorUpgrade:viewDidAppear()
	QUIDialogUnionDragonWarFloorUpgrade.super.viewDidAppear(self)

	self:setFloorInfo()
end

function QUIDialogUnionDragonWarFloorUpgrade:viewWillDisappear()
	QUIDialogUnionDragonWarFloorUpgrade.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonWarFloorUpgrade:setFloorInfo()
	local awards = string.split(self._rewardInfo.floorReward, ";")
	for i = 1, 3 do
		if awards[i] and awards[i] ~= "" then
			local itemsInfo = string.split(awards[i], "^")
			self:createItemBox(self._ccbOwner["node_item_"..i], itemsInfo[1], itemsInfo[2])
		end	
	end

	-- set icon
	local oldIcon = QUIWidgetFloorIcon.new({isLarge = true})
	oldIcon:setInfo(self._rewardInfo.oldFloor, "unionDragonWar")
	self._ccbOwner.node_old_floor:removeAllChildren()
	self._ccbOwner.node_old_floor:addChild(oldIcon)

	local newIcon = QUIWidgetFloorIcon.new({isLarge = true})
	newIcon:setInfo(self._rewardInfo.newFloor, "unionDragonWar")
	self._ccbOwner.node_new_floor:removeAllChildren()
	self._ccbOwner.node_new_floor:addChild(newIcon)
end

function QUIDialogUnionDragonWarFloorUpgrade:createItemBox(node, itemId, itemCount)
	local itemBox = QUIWidgetItemsBox.new()
	local itemType = ITEM_TYPE.ITEM
	if tonumber(itemId) == nil then
		itemType = remote.items:getItemType(itemId)
	end
	itemBox:setPromptIsOpen(true)
	node:addChild(itemBox)
	itemBox:setGoodsInfo(tonumber(itemId), itemType, tonumber(itemCount))
end

function QUIDialogUnionDragonWarFloorUpgrade:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonWarFloorUpgrade:_onTriggerClose()
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionDragonWarFloorUpgrade:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack then
		callBack()
	end
end

return QUIDialogUnionDragonWarFloorUpgrade