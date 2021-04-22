-- @Author: xurui
-- @Date:   2019-01-22 18:07:17
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-01 15:30:16
local QUIWidgetActivitySevenDisCountItem = import("..widgets.QUIWidgetActivitySevenDisCountItem")
local QUIWidgetActivityCarnivalDiscountItem = class("QUIWidgetActivityCarnivalDiscountItem", QUIWidgetActivitySevenDisCountItem)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActivityCarnivalItem = import("..widgets.QUIWidgetActivityCarnivalItem")

local itemBoxGap = 210

function QUIWidgetActivityCarnivalDiscountItem:ctor(options)
	if options == nil then
		options = {}
	end
	local ccbFile = "ccb/Dialog_Carnival_sell.ccbi"
	options.ccbFile = ccbFile
    QUIWidgetActivityCarnivalDiscountItem.super.ctor(self, options)

end

function QUIWidgetActivityCarnivalDiscountItem:setInfo(id, info, maxCount, activityInfo, curDay)
	local dayNum = string.split(activityInfo.params, ",")
	dayNum = tonumber(dayNum[1])
	self:setPreviewStated(dayNum > curDay)

	QUIWidgetActivityCarnivalDiscountItem.super.setInfo(self, id, info, maxCount)

	local count = #self.awards
	if count ~= nil then 
		self._ccbOwner.node_item:setPositionX( -itemBoxGap + (3 - count)/2 * itemBoxGap )
	end
end

function QUIWidgetActivityCarnivalDiscountItem:addItem(id, num, index)
	if id == nil or num == nil then
		return
	end

	if self._itemBox[index] == nil then
		self._itemBox[index] = QUIWidgetActivityCarnivalItem.new()
		self._ccbOwner.node_item:addChild(self._itemBox[index])
	end
    local itemType = remote.items:getItemType(id)
	id = tonumber(id)
	num = tonumber(num)
	self._itemBox[index]:setPositionX((index-1) * itemBoxGap)
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		self._itemBox[index]:setGoodsInfo(id, itemType, num)
    	table.insert(self.awards, {id = id, typeName = itemType, count = num})
	else
		self._itemBox[index]:setGoodsInfo(id, ITEM_TYPE.ITEM, num)
    	table.insert(self.awards, {id = id, typeName = ITEM_TYPE.ITEM, count = num})
	end
end

return QUIWidgetActivityCarnivalDiscountItem