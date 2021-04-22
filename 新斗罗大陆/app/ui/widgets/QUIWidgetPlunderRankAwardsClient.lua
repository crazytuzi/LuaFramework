-- @Author: xurui
-- @Date:   2016-12-16 19:24:28
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-12-23 10:31:00
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderRankAwardsClient = class("QUIWidgetPlunderRankAwardsClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetPlunderRankAwardsClient:ctor(options)
	local ccbFile = "ccb/Widget_plunder_rankachievement.ccbi"
	local callBack = {
	}
	QUIWidgetPlunderRankAwardsClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemBox = {}
end

function QUIWidgetPlunderRankAwardsClient:onEnter()
end

function QUIWidgetPlunderRankAwardsClient:onExit()
end

function QUIWidgetPlunderRankAwardsClient:setInfo(param)
	self._awardInfo = param.awardInfo or {}
	
	-- set awards item box
	local items = string.split(self._awardInfo.reward, ";")
	if items == nil then return end

	for i = 1, 4 do
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
	self:setConditionState(param.isDone, param.rankString, param.titleString)
end

function QUIWidgetPlunderRankAwardsClient:setConditionState(isDone, rankString, titleString)
	self._ccbOwner.tf_name:setString(titleString or "")
	self._ccbOwner.tf_progress:setString(rankString or "")

	self._ccbOwner.finish:setVisible(false)
	self._ccbOwner.notFinish:setVisible(false)
	if isDone then
		self._ccbOwner.finish:setVisible(true)
		self._state = QUIWidgetPlunderRankAwardsClient.AWARDS_IS_DONE
	else
		self._ccbOwner.notFinish:setVisible(true)
		self._state = QUIWidgetPlunderRankAwardsClient.AWARDS_IS_NONE
	end
end

function QUIWidgetPlunderRankAwardsClient:getContentSize()
	return self._ccbOwner.background:getContentSize()
end

return QUIWidgetPlunderRankAwardsClient