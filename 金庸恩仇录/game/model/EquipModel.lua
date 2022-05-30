local data_item_item = require("data.data_item_item")

local EquipModel = {}

function EquipModel.sort(list,isReverse)
	
	if isReverse == true then
		table.sort(list, function(a, b)
			return (EquipModel.getCellValue(a) < EquipModel.getCellValue(b))
		end)
	else
		table.sort(list, function(a, b)
			return (EquipModel.getCellValue(a) > EquipModel.getCellValue(b))
		end)
	end
	
end

function EquipModel.getCellValue(cellData)
	local resId = cellData.resId
	local equipStaticData = data_item_item[resId]
	local pinjiValue = equipStaticData["equip_level"]
	local cellValue = 0
	
	--已装备在侠客身上排名第一
	if cellData.pos ~= nil and cellData.pos ~= 0 then
		
		cellValue = cellValue + 100000000
	end
	
	--品级第二
	cellValue = cellValue + pinjiValue/10 * 1000000
	
	--强化等级第三
	if cellData.level ~= nil then
		cellValue = cellValue + cellData.level/100 * 10000
	end
	
	--resId
	cellValue = cellValue + resId/10000
	return cellValue
end

function EquipModel.getChoseCellValue(cellData)
	return EquipModel.getCellValue(cellData.data)
end

function EquipModel.sortChoseList(list,isReverse)
	if isReverse == true then
		table.sort(list, function(a, b)
			return (EquipModel.getChoseCellValue(a) < EquipModel.getChoseCellValue(b))
		end)
	else
		table.sort(list, function(a, b)
			return (EquipModel.getChoseCellValue(a) > EquipModel.getChoseCellValue(b))
		end)
	end
end

return EquipModel