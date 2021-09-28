local fashion = {}
local FashionEquipCfg = import("csv2cfg.FashionEquip")
local FashionEquip_UpLevelCfg = import("csv2cfg.FashionEquip_UpLevel")
local FashionEquip_UpLevel_ExpCfg = import("csv2cfg.FashionEquip_UpLevel_Exp")

for i, v in ipairs(FashionEquipCfg) do
	v.idx = i
end

table.merge(fashion, {
	weaponType = 2,
	clothType = 1
})

fashion.getFashion = function (type, sex)
	local result = {}

	if sex then
		for k, v in pairs(FashionEquipCfg) do
			if v.FEType == type and v.Gender == sex then
				result[#result + 1] = v
			end
		end
	else
		for k, v in pairs(FashionEquipCfg) do
			if v.FEType == type then
				result[#result + 1] = v
			end
		end
	end

	return result
end
fashion.setHaveFashion = function (list, islimit, otherList)
	local tempList = {}
	local FHaveList = otherList or g_data.player.fashionInfo.FHaveList
	local limitList = {}

	for k, v in pairs(list) do
		if type(v.TimeLimit) == "number" and islimit then
			limitList[#limitList + 1] = v
		end

		if type(v.TimeLimit) == "string" and not islimit then
			limitList[#limitList + 1] = v
		end
	end

	local showItem = nil

	for i = 1, #FHaveList, 1 do
		for k, v in pairs(limitList) do
			local temp = {}
			local have = FHaveList[i]

			if have.FID == v.idx then
				temp.FIsShow = have.FIsShow
				temp.FLevel = have.FLevel
				temp.have = true
				temp.FInvalidTime = have.FInvalidTime
				temp.FHaveStuff = have.FHaveStuff
				temp.FGetTime = have.FGetTime

				table.merge(temp, v)

				if have.FIsShow == 1 then
					showItem = temp

					break
				end

				tempList[#tempList + 1] = temp

				break
			end
		end
	end

	table.sort(tempList, function (a, b)
		if a.FGetTime < b.FGetTime then
			return true
		else
			return false
		end

		return 
	end)

	if showItem then
		table.insert(slot3, 1, showItem)
	end

	if islimit then
		return tempList
	end

	for k, v in pairs(limitList) do
		local isExist = false

		for i = 1, #tempList, 1 do
			if tempList[i].idx == v.idx then
				isExist = true

				break
			end
		end

		if not isExist then
			tempList[#tempList + 1] = v
		end
	end

	return tempList
end
fashion.getPropertyByLevel = function (idx, level)
	local data = {}

	for k, v in pairs(FashionEquip_UpLevel_ExpCfg) do
		if v.FEID == idx and v.FELevel == level then
			data = v

			break
		end
	end

	for k, v in pairs(FashionEquip_UpLevelCfg) do
		if data.UpNeedItem == v.ItemName then
			data.ItemGetExp = v.ItemGetExp

			break
		end
	end

	return data
end
fashion.isCanUpLevel = function (idx)
	local isCanUp = false

	for k, v in pairs(FashionEquip_UpLevel_ExpCfg) do
		if v.FEID == idx then
			isCanUp = true

			break
		end
	end

	return isCanUp
end
fashion.getFashionTypeByIdx = function (idx)
	local FEType = {}

	for k, v in pairs(FashionEquipCfg) do
		if v.idx == idx then
			FEType = v.FEType

			break
		end
	end

	return FEType
end
fashion.getAllLevelByIdx = function (idx)
	local result = {}

	for k, v in pairs(FashionEquip_UpLevel_ExpCfg) do
		if v.FEID == idx then
			result[#result + 1] = v
		end
	end

	table.sort(result, function (a, b)
		if b.FELevel < a.FELevel then
			return false
		else
			return true
		end

		return 
	end)

	return result
end
fashion.getFashionInfoByIdx = function (idx)
	local result = nil

	for k, v in pairs(FashionEquipCfg) do
		if v.idx == idx then
			result = v

			break
		end
	end

	return result
end
fashion.reorderFashion = function ()
	return 
end

return fashion
