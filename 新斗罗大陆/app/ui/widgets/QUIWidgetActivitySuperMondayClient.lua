-- @Author: xurui
-- @Date:   2019-03-21 14:26:33
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-05 15:27:02
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivitySuperMondayClient = class("QUIWidgetActivitySuperMondayClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

QUIWidgetActivitySuperMondayClient.EVENT_RECIVE = "EVENT_RECIVE"

function QUIWidgetActivitySuperMondayClient:ctor(options)
	local ccbFile = "ccb/Widget_Mondayclient.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
    }
    QUIWidgetActivitySuperMondayClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemBox = {}
end

function QUIWidgetActivitySuperMondayClient:onEnter()
end

function QUIWidgetActivitySuperMondayClient:onExit()
end

function QUIWidgetActivitySuperMondayClient:setInfo(targetInfo, isAwardTime, index)
	self._targetInfo = targetInfo or {}
	self._index = index
	self._targetConfig = remote.activity:getActivityTargetConfigByTargetId(self._targetInfo.activityTargetId)
	self._targetRecord = remote.activity:getActivityTargetProgressDataById(self._targetInfo.activityId, self._targetInfo.activityTargetId)

	local description = self._targetConfig.description or ""
	if isAwardTime ~= true and self._targetInfo.completeNum ~= 3 then
		if self._targetInfo.type == 705 then
			local currentMin = math.floor(self._targetRecord.progress/60)
			local totlaMin = math.floor(self._targetConfig.value/60)
			currentMin = currentMin > totlaMin and totlaMin or currentMin
			description = string.format("%s(%s/%s)", description, currentMin, totlaMin)
		elseif self._targetInfo.type == 708 then
			local currenNum = self._targetRecord.progress
			local totlaNum = self._targetConfig.value
			currenNum = currenNum > totlaNum and totlaNum or currenNum
			description = string.format("%s(%s/%s)", description, currenNum, totlaNum)
		end
	end
    self._ccbOwner.tf_condition:setString(description)

	self._ccbOwner.node_no:setVisible(self._targetInfo.completeNum == 1)
	self._ccbOwner.node_btn_recive:setVisible(self._targetInfo.completeNum == 2)
	self._ccbOwner.node_ok:setVisible(self._targetInfo.completeNum == 3)

	if self._targetInfo.awards ~= nil then
		self._awards = {}
		remote.items:analysisServerItem(self._targetInfo.awards, self._awards)
		local awardNum = #self._awards
		local totalWidth = 0
		for index, value in ipairs(self._awards) do
			if self._itemBox[index] == nil then
				self._itemBox[index] = QUIWidgetItemsBox.new()
				self._ccbOwner.node_item:addChild(self._itemBox[index])
				self._itemBox[index]:setScale(0.8)
				self._itemBox[index]:setPromptIsOpen(true)
			end
			self._itemBox[index]:setGoodsInfo(value.id, value.typeName, value.count)
			local contentSize = self._itemBox[index]:getContentSize()
			self._itemBox[index]:setPositionX(totalWidth)
			if index ~= awardNum then
				totalWidth = totalWidth + contentSize.width
			end
		end

		if awardNum > 1 then
			self._ccbOwner.node_item:setPositionX(-totalWidth / 2)
		end
	end
end

function QUIWidgetActivitySuperMondayClient:_onTriggerRecive(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recive) == false then return end
	self:dispatchEvent({name = QUIWidgetActivitySuperMondayClient.EVENT_RECIVE, info = self._targetInfo, awards = self._awards, index = self._index})
end

function QUIWidgetActivitySuperMondayClient:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetActivitySuperMondayClient
