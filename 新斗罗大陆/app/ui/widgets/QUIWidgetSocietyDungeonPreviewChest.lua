--
-- Author: Kumo.Wang
-- Date: Thu Jun  2 14:48:54 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyDungeonPreviewChest = class("QUIWidgetSocietyDungeonPreviewChest", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
												
QUIWidgetSocietyDungeonPreviewChest.EVENT_CLICK = "QUIWIDGETSOCIETYDUNGEONPREVIEWCHEST_EVENT_CLICK"

function QUIWidgetSocietyDungeonPreviewChest:ctor(options)
	local ccbFile = "ccb/Widget_Society_ChestPreview.ccbi"
	local callBacks = {}
	QUIWidgetSocietyDungeonPreviewChest.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemId = options.itemId
	self._itemType = options.itemType
	self._itemCount = options.itemCount
	self._maxCount = options.maxCount
	self._isEffect = options.isEffect
	-- print("[Kumo] QUIWidgetSocietyDungeonPreviewChest:ctor() ", options.itemId, options.itemType, options.itemCount, options.maxCount)
	self:_init()
end

function QUIWidgetSocietyDungeonPreviewChest:onEnter()

end

function QUIWidgetSocietyDungeonPreviewChest:onExit()

end

function QUIWidgetSocietyDungeonPreviewChest:getHeight()
	return self._ccbOwner.node_size:getContentSize().height * self._ccbOwner.node_size:getScaleY()
end

function QUIWidgetSocietyDungeonPreviewChest:getWidth()
	return self._ccbOwner.node_size:getContentSize().width * self._ccbOwner.node_size:getScaleX()
end

function QUIWidgetSocietyDungeonPreviewChest:getKey()
	if self._itemId then
		return self._itemId.."^"..self._itemCount
	else
		return self._itemType.."^"..self._itemCount
	end
end

function QUIWidgetSocietyDungeonPreviewChest:update( receivedCount )
	local num = receivedCount or 0
	self._ccbOwner.tf_count:setString("数量:"..(self._maxCount - num).."/"..self._maxCount)
end

function QUIWidgetSocietyDungeonPreviewChest:_init()
	local item = QUIWidgetItemsBox.new()
	item:setPromptIsOpen(true)
	self._ccbOwner.node_icon:addChild(item)
	item:setGoodsInfo(self._itemId, self._itemType, self._itemCount)

	if self._isEffect then
		local ccbFile = "ccb/effects/heji_kuang_2.ccbi"
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_icon:addChild(aniPlayer)
	    aniPlayer:playAnimation(ccbFile, nil, nil, false)
	end

	self._ccbOwner.tf_count:setString("数量:"..self._maxCount.."/"..self._maxCount)

	self:update()
end

return QUIWidgetSocietyDungeonPreviewChest