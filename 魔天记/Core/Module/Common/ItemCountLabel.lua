local ItemCountLabel = class("ItemCountLabel")
local green = ColorDataManager.Get_green()
local red = ColorDataManager.Get_red()
function ItemCountLabel:New()
	self = {};
	setmetatable(self, {__index = ItemCountLabel});
	return self
end

function ItemCountLabel:Init(label)
	self._txtCount = label
end

function ItemCountLabel:UpdateItemById(id, needCount)
	self:UpdateItemByData(BackpackDataManager.GetProductTotalNumBySpid(id), needCount)
end

function ItemCountLabel:UpdateItemByData(allCount, needCount)
	self._txtCount.text = allCount .. "/" .. needCount
	self._txtCount.color = allCount >= needCount and green or red
end

function ItemCountLabel:Dispose()
	self._txtCount = nil
end
return ItemCountLabel 