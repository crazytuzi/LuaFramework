-- @Author: xurui
-- @Date:   2016-12-16 15:57:04
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-12-20 18:28:48
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderAwardClient = class("QUIWidgetPlunderAwardClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetPlunderAwardClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetPlunderAwardClient:ctor(options)
	local ccbFile = "ccb/Widget_plunder_mubiao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetPlunderAwardClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemBox = {}
	self._isReady = false
end

function QUIWidgetPlunderAwardClient:onEnter()
end

function QUIWidgetPlunderAwardClient:onExit()
end

function QUIWidgetPlunderAwardClient:setInfo(param)
	self._index = param.index
	self._awardInfo = param.awardInfo or {}
	self._buyAwards = param.buyAwards
	
	-- set awards item box
	local items = string.split(self._awardInfo.reward, ";")
	if items == nil then return end

	for i = 1, 3 do
		if items[i] then
			items[i] = string.split(items[i], "^")
			if self._itemBox[i] == nil then
				self._itemBox[i] = QUIWidgetItemsBox.new()
				 self._ccbOwner["item"..i]:addChild(self._itemBox[i])
			end
			local itemType = ITEM_TYPE.ITEM
			if tonumber(items[i][1]) == nil then
				itemType = items[i][1]
			end
			self._itemBox[i]:setGoodsInfo(tonumber(items[i][1]), itemType, tonumber(items[i][2]))
			self._itemBox[i]:setPromptIsOpen(true)
			self._itemBox[i]:setVisible(true)
		else
			if self._itemBox[i] ~= nil then
				self._itemBox[i]:setVisible(false)
			end
		end
	end

	--set condition
	self:setConditionState(param.condition, param.rankString, param.titleString)
end

function QUIWidgetPlunderAwardClient:setConditionState(condition, rankString, titleString)
	self._isReady = false
	self._ccbOwner.tf_name:setString(titleString or "")
	self._ccbOwner.tf_progress:setString(rankString or "")
	self._ccbOwner.tf_num:setString("")

	self._ccbOwner.node_ready:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.sp_none:setVisible(false)
	self._ccbOwner.done_banner:setVisible(false)

	if self._awardInfo.target_score <= condition then
		self._ccbOwner.node_ready:setVisible(true)
		self._ccbOwner.done_banner:setVisible(true)
		self._isReady = true
	elseif self._awardInfo.target_score > condition then
		self._ccbOwner.sp_none:setVisible(true)
	end
	for _, value in pairs(self._buyAwards) do
		if value == self._awardInfo.id then
			self._ccbOwner.sp_done:setVisible(true)
			self._ccbOwner.sp_none:setVisible(false)
			self._ccbOwner.node_ready:setVisible(false)
			self._ccbOwner.done_banner:setVisible(false)
			self._isReady = false
			break
		end 
	end
end

function QUIWidgetPlunderAwardClient:_onTriggerClick(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ready) == false then return end
	if self._isReady == false then return end
	self:dispatchEvent({name = QUIWidgetPlunderAwardClient.EVENT_CLICK, awardInfo = self._awardInfo})
end

function QUIWidgetPlunderAwardClient:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

return QUIWidgetPlunderAwardClient