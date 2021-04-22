-- @Author: xurui
-- @Date:   2019-01-30 10:24:39
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-20 11:00:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityCarnivalItem = class("QUIWidgetActivityCarnivalItem", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetActivityCarnivalItem:ctor(options)
	local ccbFile = "ccb/Widget_Carnival_item.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetActivityCarnivalItem.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetActivityCarnivalItem:onEnter()
end

function QUIWidgetActivityCarnivalItem:onExit()
end

function QUIWidgetActivityCarnivalItem:setGoodsInfo(id, itemType, num)
	if self._itemBox == nil then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox)
   	 	self._itemBox:setPromptIsOpen(true)
		self._itemBox:showBoxEffect("effects/Auto_Skill_light.ccbi", true, 0, 0, 1.2)
	end
	local icon, itemName = nil, ""
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		icon, itemName = remote.items:getURLForId(itemType)
		self._itemBox:setGoodsInfo(id, itemType, num)
	else
		icon, itemName = remote.items:getURLForId(id)
		self._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
	end
	self._ccbOwner.tf_name:setString(itemName or "")

	local nameLen = q.wordLen(itemName, 18, 10)
	self._ccbOwner.sp_name_frame:setPreferredSize(CCSize(nameLen + 40, 42))
end

function QUIWidgetActivityCarnivalItem:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetActivityCarnivalItem
