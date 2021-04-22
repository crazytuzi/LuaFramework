local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarUnionAward = class("QUIWidgetUnionDragonWarUnionAward", QUIWidget)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")

function QUIWidgetUnionDragonWarUnionAward:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_paihang.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonWarUnionAward.super.ctor(self, ccbFile, callBack, options)

	self._items = {}
	self._ccbOwner.node_ready:setVisible(false)
end

function QUIWidgetUnionDragonWarUnionAward:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetUnionDragonWarUnionAward:setInfo(data, currentInfo)
	self._items = {}
	self._ccbOwner.tf_award_title:setString(string.format("宗门保持【%s】本周奖励", data.name))
	self._ccbOwner.tf_progress:setString("当前："..currentInfo.name)
	self._ccbOwner.tf_none:setVisible(data.dan > currentInfo.dan)
	self._ccbOwner.sp_done:setVisible(data.dan <= currentInfo.dan)
	local awardConfig = db:getLuckyDraw(data.week_reward)
	if awardConfig ~= nil then
		local index = 1
		while true do
			local typeName = awardConfig["type_"..index]
			local id = awardConfig["id_"..index]
			local count = awardConfig["num_"..index]
			if typeName ~= nil then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setGoodsInfo(id, typeName, count)
				itemBox:setPositionX((index - 1) * 102)
				self._ccbOwner.item:addChild(itemBox)
				self._items[#self._items+1] = itemBox
			else
				break
			end
			index = index + 1
		end
	end
end

function QUIWidgetUnionDragonWarUnionAward:registerItemBoxPrompt(index, list)
	for k, v in ipairs(self._items) do
		list:registerItemBoxPrompt(index,k,v,nil)
	end
end

return QUIWidgetUnionDragonWarUnionAward