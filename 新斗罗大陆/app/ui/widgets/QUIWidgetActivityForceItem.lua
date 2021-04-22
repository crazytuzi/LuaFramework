local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityForceItem = class("QUIWidgetActivityForceItem", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIWidgetActivityForceItem:ctor(options)
	local ccbFile = "ccb/Widget_Activity_client2.ccbi"
  	local callBacks = {
  	}
	QUIWidgetActivityForceItem.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityForceItem:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetActivityForceItem:setInfo(info, activityType)
	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)

	self._ccbOwner.tf_name:setString(info.description or "")
	self._ccbOwner.tf_num:setString("我的排名:"..(info.myRank or ""))

	if info.myRank then
		if info.myRank >= info.rank_1 and info.myRank <= info.rank_2 then
			self._ccbOwner.alreadyTouch:setVisible(true)
			self._ccbOwner.notTouch:setVisible(false)
		else
			self._ccbOwner.alreadyTouch:setVisible(false)
			self._ccbOwner.notTouch:setVisible(true)
		end
	else
		self._ccbOwner.alreadyTouch:setVisible(false)
		self._ccbOwner.notTouch:setVisible(false)
	end

	self._ccbOwner.node_item:removeAllChildren()
	self._itemBoxs = {}
	local awards = {}
	if info.awards ~= nil then
		local _awards = string.split(info.awards, ";")
		for _,value in ipairs(_awards) do
			local awards2 = string.split(value, "^")
			if #awards2 > 1 then
				table.insert(awards, {id = tonumber(awards2[1]), itemType = (remote.items:getItemType(awards2[1]) or ITEM_TYPE.ITEM), count = tonumber(awards2[2])})
			end
		end
	end

	local effectNum = 0
	if activityType and activityType == remote.activity.TYPE_ACTIVITY_FOR_FORCE then
		if info.rank_2 <= 3 then
			effectNum = 2
		elseif info.rank_2 <= 20 then
			effectNum = 1
		end
	end
	for index, award in ipairs(awards) do
		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setScale(0.8)
		itemBox:setGoodsInfo(award.id, award.itemType, award.count)
		itemBox:setPositionX((index-1) * 80)
		if index <= effectNum then
            itemBox:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
		end
		self._ccbOwner.node_item:addChild(itemBox)
		table.insert(self._itemBoxs, itemBox)
	end
end

function QUIWidgetActivityForceItem:registerItemBoxPrompt( index, list )
	-- body
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v)
	end
end

return QUIWidgetActivityForceItem