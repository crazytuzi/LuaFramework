-- 
-- zxs
-- 通关奖励
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDungeonPassAwardBox = class("QUIWidgetDungeonPassAwardBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")

QUIWidgetDungeonPassAwardBox.EVENT_PASS_AWARD_CLICK = "EVENT_PASS_AWARD_CLICK"

function QUIWidgetDungeonPassAwardBox:ctor(options)
	local ccbFile = "Widget_pass_award.ccbi"
	local callBacks = {
	}
	QUIWidgetDungeonPassAwardBox.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetDungeonPassAwardBox:setInfo(info, pos)
	self._ccbOwner.node_effect:setVisible(false)
	self._info = info
	self._pos = pos

	self._canGet = false
	if not info.isGet and info.isComplete then
		self._canGet = true
	end

	local awards = {}
	awards.itemID = info.awards.id
	awards.itemType = info.awards.typeName
	awards.count = info.awards.count

    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setInfo(awards)
	itemBox:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self._onTriggerClick))
    itemBox:setPromptIsOpen(not self._canGet)
    self._ccbOwner.node_box:addChild(itemBox)

	if info.isGet then
		self._ccbOwner.sp_get:setVisible(true)
	elseif info.isComplete then
		self._ccbOwner.node_effect:setVisible(true)
		self._ccbOwner.sp_get:setVisible(false)
	else
		self._ccbOwner.sp_get:setVisible(false)
	end

	if self._pos == 3 then
		self._ccbOwner.sp_gold:setVisible(true)
		self._ccbOwner.sp_sliver:setVisible(false)
	else
		self._ccbOwner.sp_gold:setVisible(false)
		self._ccbOwner.sp_sliver:setVisible(true)
	end
end

function QUIWidgetDungeonPassAwardBox:getContentSize()
	return self._ccbOwner.node_box:getContentSize()
end

function QUIWidgetDungeonPassAwardBox:_onTriggerClick()
	if not self._canGet then
		return
	end
	self:dispatchEvent({name = QUIWidgetDungeonPassAwardBox.EVENT_PASS_AWARD_CLICK, info = self._info})
end

return QUIWidgetDungeonPassAwardBox

