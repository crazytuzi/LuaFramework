--[[	
	文件名称：QUIWidgetActivityMonthFundItem.lua
	创建时间：2017-01-18 14:24:29
	作者：nieming
	描述：QUIWidgetActivityMonthFundItem
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityMonthFundItem = class("QUIWidgetActivityMonthFundItem", QUIWidget)
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIWidgetActivityMonthFundItem:ctor(options)
	local ccbFile = "Widget_yuejijin_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetActivityMonthFundItem._onTriggerClick)},
	}
	QUIWidgetActivityMonthFundItem.super.ctor(self,ccbFile,callBacks,options)
	if options ~= nil then
		self._activityId = options.activityId
	end
end

function QUIWidgetActivityMonthFundItem:setInfo(info, isPreview)
	if not info then
		return 
	end
	self._info = info

	self._ccbOwner.bg_1:setVisible(isPreview)
	self._ccbOwner.bg_2:setVisible(not isPreview)

	local loginDays = remote.activityMonthFund:getLoginDays()

	self._ccbOwner.dayLabel:setString(string.format("第%d天", info.awardIndex))
	if not self._itemBox then
		self._itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(self._itemBox)
		self._ccbOwner.node_item:setScale(0.8)
	end
	local isSpecial = false
	if info.glittering and info.glittering == 1 then
    	self._itemBox:showBoxEffect("effects/leiji_light.ccbi", true, 0, 1, 0.6)
		self._ccbOwner.bg_special:setVisible(true)
		self._ccbOwner.bg_1:setVisible(false)
		isSpecial = true
    else
    	self._itemBox:removeEffect()
		self._ccbOwner.bg_special:setVisible(false)
		self._ccbOwner.is_ready_special:setVisible(false)
	end
	self._itemBox:setGoodsInfoByID(info.award.id or info.award.type, info.award.count or 0)

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(info.award.id or info.award.type)


	if loginDays >= info.awardIndex and not isPreview and self._activityId ~= nil then 
		if remote.activityMonthFund:isTakenAward(self._activityId, info.awardIndex) then
			-- 已领奖
			self._ccbOwner.effectNode:setVisible(false)
			self._ccbOwner.choose:setVisible(true)
			self._ccbOwner.is_ready:setVisible(false)
			self._ccbOwner.alreadyTaken2:setVisible(true)
			self._ccbOwner.dayLabel:setColor(ccc3(135, 100, 81))
		else
			-- 可领奖
			self._ccbOwner.effectNode:setVisible(true)
			self._ccbOwner.choose:setVisible(false)
			if isSpecial then
				self._ccbOwner.is_ready_special:setVisible(true)
			else
				self._ccbOwner.is_ready:setVisible(true)
			end
			self._ccbOwner.alreadyTaken2:setVisible(false)
			self._ccbOwner.dayLabel:setColor(ccc3(58, 23, 0))
		end
	else
		-- 不可领奖
		self._ccbOwner.effectNode:setVisible(false)
		self._ccbOwner.choose:setVisible(false)
		self._ccbOwner.is_ready:setVisible(false)
		self._ccbOwner.alreadyTaken2:setVisible(false)
		self._ccbOwner.dayLabel:setColor(ccc3(58,23,0))
	end
end

function QUIWidgetActivityMonthFundItem:getContentSize()
	return self._ccbOwner.itemSize:getContentSize()
end

return QUIWidgetActivityMonthFundItem
