local data_cheats_cheats = require("data.data_miji_miji")
local data_mijiatt_mijiatt = require("data.data_mijiatt_mijiatt")
local data_mijicost_mijicost = require("data.data_mijicost_mijicost")
local CheatsModel = {}

function CheatsModel.init()
	local costMap = {}
	for i, v in ipairs(data_mijicost_mijicost) do
		if costMap[tostring(v.attarr)] == nil then
			costMap[tostring(v.attarr)] = {}
		end
		costMap[tostring(v.attarr)][tostring(v.lv)] = v
	end
	CheatsModel.costMap = costMap
	local propsMap = {}
	for i, v in ipairs(data_mijiatt_mijiatt) do
		if propsMap[tostring(v.attarr)] == nil then
			propsMap[tostring(v.attarr)] = {}
		end
		propsMap[tostring(v.attarr)][tostring(v.lv)] = v
	end
	CheatsModel.propsMap = propsMap
end

--[[ÃØ¼®ÁÐ±í]]
function CheatsModel.getCheatsListInfo(param)
	local msg = {
	m = "packet",
	a = "list",
	t = BAG_TYPE.cheats
	}
	local function callback(data)
		CheatsModel.setCheatsTable(data["1"])
		if param.callback ~= nil then
			param.callback(data)
		end
	end
	RequestHelper.request(msg, callback, param.errback)
end

--[[ÃØ¼®½ø½×ÐÅÏ¢]]
function CheatsModel.getCheatsJinJieInfo(param)
	local msg = {
	m = "cheats",
	a = "study",
	id = param.id,
	op = param.op
	}
	local function callback(data)
		CheatsModel.setCheatsTableData({
		id = param.id,
		props = data.props,
		floor = data.floor,
		level = data.level
		})
		if param.callback ~= nil then
			param.callback(data)
		end
	end
	RequestHelper.request(msg, callback, param.errback)
end

function CheatsModel.setCheatsTableData(param)
	for i = 1, #CheatsModel.totalTable do
		if param.id == CheatsModel.totalTable[i].id then
			local data = CheatsModel.totalTable[i]
			data.props = param.props
			data.floor = param.floor
			data.level = param.level
		end
	end
end

function CheatsModel.removeList(removeIdList)
	for i = 1, #removeIdList do
		for k = 1, #CheatsModel.totalTable do
			if CheatsModel.totalTable[k].id == removeIdList[i] then
				table.remove(CheatsModel.totalTable, k)
				break
			end
		end
	end
end
function CheatsModel.setCheatsNum(num)
	if num <= 0 then
		num = 0
	end
	CheatsModel.m_CheatsNum = num
end

function CheatsModel.getCheatsNum()
	if CheatsModel.m_CheatsNum == nil then
		return 0
	else
		return CheatsModel.m_CheatsNum
	end
end

function CheatsModel.isUpFloor(resId, level, floor)
	local mod = tonumber(level) % tonumber(data_cheats_cheats[resId].number)
	if mod == 0 then
		local value = level / data_cheats_cheats[resId].number
		if value + 1 ~= floor then
			return true, data_cheats_cheats[resId].number, floor == data_cheats_cheats[resId].height
		end
	end
	return false, mod, false
end

function CheatsModel.getCheatsByObjId(id)
	for i = 1, #CheatsModel.totalTable do
		if id == CheatsModel.totalTable[i].id then
			local data = CheatsModel.totalTable[i]
			local cheatsData = {}
			cheatsData.floor = data.floor
			cheatsData.skills = clone(data_cheats_cheats[data.resId].skills)
			cheatsData.resId = data.resId
			cheatsData.star = data_cheats_cheats[data.resId].quality
			cheatsData.type = data_cheats_cheats[data.resId].type
			local isup, level = CheatsModel.isUpFloor(data.resId, data.level, data.floor)
			cheatsData.isUp = isup
			cheatsData.level = data.level
			cheatsData.props = CheatsModel.getCheatsProps(data.resId, data.floor,data.level )
			--[[
			if data.props ~= nil and #data.props then
				for i, v in ipairs(data.props) do
					table.insert(cheatsData.props, {
					idx = v.idx,
					val = v.val
					})
				end
				table.sort(cheatsData.props, function (a, b)
					return a.idx < b.idx
				end)
			end
			]]
			cheatsData.data = data
			return cheatsData
			
		end
	end
	return nil
end

function CheatsModel.getInitCheatsDataById(resId)
	if not data_cheats_cheats[resId] then
		return {}
	end
	local cheatsData = {}
	cheatsData.floor = data_cheats_cheats[resId].height
	cheatsData.skills = clone(data_cheats_cheats[resId].skills)
	cheatsData.resId = resId
	cheatsData.star = data_cheats_cheats[resId].quality
	cheatsData.type = data_cheats_cheats[resId].type
	cheatsData.level = data_cheats_cheats[resId].number
	cheatsData.props = {}
	local props = {}
	for i, v in ipairs(data_mijiatt_mijiatt) do
		if v.attarr == resId then
			if type(v.type) == "table" then
				for n, t in ipairs(v.type) do
					if props[t] then
						props[t] = props[t] + v.number
					else
						props[t] = v.number
					end
				end
			else
				if props[v.type] then
					props[v.type] = props[v.type] + v.number
				else
					props[v.type] = v.number
				end
			end
		end
	end
	
	if props ~= nil then
		for k, v in pairs(props) do
			table.insert(cheatsData.props, {
			idx = k,
			val = v
			})
		end
		table.sort(cheatsData.props, function (a, b)
			return a.idx < b.idx
		end)
	end
	return cheatsData
end

function CheatsModel.getCheatsProps(resId, floor, level)
	local data = data_cheats_cheats[resId]
	if not data then
		return {}
	end
	local step = (floor - 1) * data.number + level
	if step == 0 then
		return {}
	end
	cheatsProps = {}
	local props = {}
	for i, v in ipairs(data_mijiatt_mijiatt) do
		if v.attarr == resId and v.lv <= step then
			if type(v.type) == "table" then
				dump(v.type)
				for n, t in ipairs(v.type) do
					if props[t] then
						props[t] = props[t] + v.number
					else
						props[t] = v.number
					end
				end
			else
				if props[v.type] then
					props[v.type] = props[v.type] + v.number
				else
					props[v.type] = v.number
				end
			end
		end
	end
	
	if props ~= nil then
		for k, v in pairs(props) do
			table.insert(cheatsProps, {
			idx = k,
			val = v
			})
		end
		table.sort(cheatsProps, function (a, b)
			return a.idx < b.idx
		end)
	end
	return cheatsProps
end

function CheatsModel.getCheatsDebrisList(param)
	local function _callback(data)
		dump(data)
		CheatsModel.setCheatsDebrisTable(data["1"])
		if param.callback ~= nil then
			param.callback(data)
		end
	end
	local _param = {
	type = BAG_TYPE.cheats_suipian,
	callback = _callback,
	errback = param.errback
	}
	RequestHelper.getDebrisList(_param)
end

function CheatsModel.setCheatsTable(cellTable)
	dump("---------------------CheatsList----------------------")
	dump(cellTable)
	CheatsModel.totalTable = cellTable
	CheatsModel.sort(CheatsModel.totalTable)
end

function CheatsModel.setCheatsDebrisTable(data)
	CheatsModel.debrisList = data
end

function CheatsModel.getCellValue(cellData, showRelation)
	local _showRelation = showRelation
	local maxNum = 40000000
	local cellValue = 0
	if cellData.pos ~= nil and 0 < cellData.pos then
		cellValue = cellValue + maxNum
	end
	if _showRelation ~= 0 and cellData.relation ~= nil and 0 < #cellData.relation then
		cellValue = cellValue + maxNum / 10
	end
	local cheatsData = ResMgr.getCheatsData(cellData.resId)
	cellValue = cellValue + maxNum / 1500 * cheatsData.quality
	cellValue = cellValue + maxNum / 1000 * cellData.level
	cellValue = cellValue + cellData.resId
	return cellValue
end

function CheatsModel.sort(cellTable, reverse)
	table.sort(cellTable, function (a, b)
		if reverse == true then
			return CheatsModel.getCellValue(a) < CheatsModel.getCellValue(b)
		else
			return CheatsModel.getCellValue(a) > CheatsModel.getCellValue(b)
		end
	end)
end

--[[ÃØ¼®ÑÐÏ°ÏûºÄ]]
function CheatsModel.getCheatsCostInfo(attarr, lv)
	if CheatsModel.costMap ~= nil then
		return CheatsModel.costMap[tostring(attarr)][tostring(lv)] or nil
	end
	return nil
end

--[[ÃØ¼®½×¶ÎÊôÐÔ]]
function CheatsModel.getCheatsPropsInfo(resId, level)
	if CheatsModel.propsMap ~= nil and CheatsModel.propsMap[tostring(resId)] ~= nil then
		return CheatsModel.propsMap[tostring(resId)][tostring(level)] or nil
	end
	return nil
end

return CheatsModel