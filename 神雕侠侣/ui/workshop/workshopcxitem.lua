WorkshopCxItem = {
	m_ItemCell,
	m_ItemName,
	m_ItemInfo
}
setmetatable(WorkshopCxItem, WorkshopCxItem)
WorkshopCxItem.__index = WorkshopCxItem

function WorkshopCxItem.new()
	local newItem = {}
	setmetatable(newItem, WorkshopCxItem)
	newItem.__index = newItem
	return newItem
end
