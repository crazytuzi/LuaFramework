local data_tujian_tujian = require("data.data_tujian_tujian")
local data_item_item = require("data.data_item_item")

local CARD_TYPE = 1
local EQUIP_TYPE = 2
local GONG_TYPE = 3
local CHEATS_TYPE = 4
local PET_TYPE = 5
local HandBookModel = {}

function HandBookModel.init(data)
	HandBookModel.totalTable = {
	{},
	{},
	{},
	{},
	{}
	}
	local rawData = data
	HandBookModel.exCard = rawData.card or {}
	HandBookModel.exEquip = rawData.equip or {}
	HandBookModel.exGong = rawData.gong or {}
	HandBookModel.exFashion =  {}
	HandBookModel.exCheats = rawData.cheats or {}
	HandBookModel.exPet = rawData.pet or {}	
	
	for _, v in ipairs(HandBookModel.exEquip) do
		if data_item_item[v].type == 2 then
			table.insert(HandBookModel.exFashion, v)
		end
	end
	
	for i = 1, #data_tujian_tujian do
		local serverData
		local tujianData = data_tujian_tujian[i]
		if data_tujian_tujian[i].mainTab == CARD_TYPE then
			serverData = HandBookModel.exCard
		elseif data_tujian_tujian[i].mainTab == EQUIP_TYPE then
			if data_tujian_tujian[i].subTab == 5 then
				serverData = HandBookModel.exFashion
				--tujianData = clone(data_tujian_tujian[i])
				--local gender = game.player.getGender()
				--for k, v in pairs(tujianData.arr_id) do
				--	tujianData.arr_id[k] = v + gender
				--end
			else
				serverData = HandBookModel.exEquip
			end
		elseif data_tujian_tujian[i].mainTab == GONG_TYPE then
			serverData = HandBookModel.exGong
		elseif data_tujian_tujian[i].mainTab == CHEATS_TYPE then
			serverData = HandBookModel.exCheats
		elseif data_tujian_tujian[i].mainTab == PET_TYPE then
			serverData = HandBookModel.exPet
		end
		HandBookModel.addData(tujianData, serverData)
	end
end

HandBookModel.viewBg = nil
HandBookModel.totalTable = {
{},
{},
{},
{},
{}
}

function HandBookModel.addData(data, serverData)
	local mainTab = data.mainTab
	local subTab = data.subTab
	if HandBookModel.totalTable[mainTab][subTab] == nil then
		HandBookModel.totalTable[mainTab][subTab] = {}
	end
	local curTable = {}
	curTable.isExist = {}
	curTable.data = data
	curTable.exNum = 0
	local dataIds = data.arr_id
	for i = 1, #dataIds do
		local curId = dataIds[i]
		curTable.isExist[i] = 0
		for j = 1, #serverData do
			if curId == serverData[j] then
				table.remove(serverData, j)
				curTable.isExist[i] = 1
				curTable.exNum = curTable.exNum + 1
				break
			end
		end
	end
	HandBookModel.totalTable[mainTab][subTab][#HandBookModel.totalTable[mainTab][subTab] + 1] = curTable
end

function HandBookModel.getSubData(mainTab, subTab)
	return HandBookModel.totalTable[mainTab][subTab]
end

function HandBookModel.getMainTabNum(mainTab)
	local mainTabTable = HandBookModel.totalTable[mainTab]
	local mainExNum = 0
	local mainMaxNum = 0
	for i = 1, #mainTabTable do
		local curData = mainTabTable[i]
		for j = 1, #curData do
			mainMaxNum = mainMaxNum + #curData[j].data.arr_id
			mainExNum = mainExNum + curData[j].exNum
		end
	end
	return mainExNum, mainMaxNum
end

function HandBookModel.getSubTabNum(mainTab, subTab)
	local curData = HandBookModel.getSubData(mainTab, subTab)
	local exNum = 0
	local maxNum = 0
	for i = 1, #curData do
		exNum = exNum + curData[i].exNum
		maxNum = maxNum + #curData[i].data.arr_id
	end
	return exNum, maxNum
end

return HandBookModel