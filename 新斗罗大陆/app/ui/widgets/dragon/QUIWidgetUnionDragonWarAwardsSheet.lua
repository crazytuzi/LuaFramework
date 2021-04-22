local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarAwardsSheet = class("QUIWidgetUnionDragonWarAwardsSheet", QUIWidget)
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")

function QUIWidgetUnionDragonWarAwardsSheet:ctor(options)
	local ccbFile = "ccb/Widget_SunWall_xingji.ccbi"
	local callBack = {
	}
	QUIWidgetUnionDragonWarAwardsSheet.super.ctor(self, ccbFile, callBack, options)
	self._items = {}
end

function QUIWidgetUnionDragonWarAwardsSheet:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetUnionDragonWarAwardsSheet:setInfo(info)
	local myInfo = remote.unionDragonWar:getMyInfo()
	local num,unit = q.convertLargerNumber(info.config.condition)
	self._ccbOwner.tf_name:setString(string.format("对敌方武魂造成%s伤害", num..unit))
	self._ccbOwner.tf_weiwancheng:setVisible(info.isGet == false and info.isComplete == false)
	self._ccbOwner.node_done:setVisible(info.isGet == false and info.isComplete == true)
	self._ccbOwner.sp_yilingqu:setVisible(info.isGet == true)
	self._ccbOwner.normal_banner:setVisible(info.isGet == true or info.isComplete == false)
	local isDone = info.isGet == false and info.isComplete == true
	self._ccbOwner.done_banner:setVisible(isDone)
	self._ccbOwner.sp_title_normal:setVisible(not isDone)
	self._ccbOwner.sp_title_done:setVisible(isDone)	

	local num1,unit1 = q.convertLargerNumber(myInfo.todayHurt or 0)
	self._ccbOwner.tf_progress:setString(string.format("进度:%s/%s", num1..unit1, num..unit))

	self._ccbOwner.item1:removeAllChildren()
	self._items = {}
	local awardConfig = db:getLuckyDraw(info.config.reward_id)
	if awardConfig ~= nil then
		local index = 1
		while true do
			local typeName = awardConfig["type_"..index]
			local id = awardConfig["id_"..index]
			local count = awardConfig["num_"..index]
			if typeName ~= nil then
				local item = QUIWidgetItemsBox.new()
				item:setGoodsInfo(id, typeName, count)
				item:setPositionX((index-1) * 104)
				self._ccbOwner.item1:addChild(item)
				table.insert(self._items, item)
			else
				break
			end
			index = index + 1
		end
	end
end

function QUIWidgetUnionDragonWarAwardsSheet:registerItemBoxPrompt( index, list )
	-- body
	for k, v in ipairs(self._items) do
		list:registerItemBoxPrompt(index,k,v,nil)
	end
end

return QUIWidgetUnionDragonWarAwardsSheet