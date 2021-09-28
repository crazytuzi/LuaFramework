local horseSoul = {}
local MonSoulUpCfg = import("csv2cfg.MonSoulUpCfg")
local MonSoulStoneCfg = import("csv2cfg.MonSoulStoneCfg")
local MonSoulStonePosCfg = import("csv2cfg.MonSoulStonePosCfg")
horseSoul.getMonSoulUpCfg = function ()
	return MonSoulUpCfg or {}
end
horseSoul.getMonSoulStoneCfg = function ()
	return MonSoulStoneCfg or {}
end
horseSoul.getMonSoulStonePosCfg = function ()
	return MonSoulStonePosCfg or {}
end
horseSoul.getCanInlayDataByPos = function (pos)
	for k, v in ipairs(MonSoulStonePosCfg) do
		if v.Pos == pos then
			return v
		end
	end

	return nil
end
horseSoul.setSelComSoulStone = function (type, level)
	horseSoul.CurSelStoneType = type or ""
	horseSoul.CurSelStoneLevel = level or 0

	return 
end
horseSoul.getSelComSoulStone = function (type, level)
	return horseSoul.CurSelStoneType or "", horseSoul.CurSelStoneLevel or 0
end
horseSoul.getComSoulStoneByIndex = function (idx)
	for k, v in ipairs(MonSoulStoneCfg) do
		if v.StoneIndex == idx then
			return v
		end
	end

	return nil
end
horseSoul.getAllMonSoulStoneType = function ()
	local types = {}

	for k, v in ipairs(MonSoulStoneCfg) do
		local hasInset = false

		for _k, _v in ipairs(types) do
			if _v == v.StoneName then
				hasInset = true
			end
		end

		if not hasInset then
			types[#types + 1] = v.StoneName
		end
	end

	return types
end
horseSoul.getComStoneLevelByType = function (type)
	local levels = {}

	for k, v in ipairs(MonSoulStoneCfg) do
		if v.StoneName == type and v.CanComp == 1 then
			levels[#levels + 1] = v.StoneLv
		end
	end

	return levels
end
horseSoul.getUsedHorseSoulStoneItems = function (equipItems)
	local items = {}

	for k, v in pairs(equipItems) do
		if k == U_MINGZHONG or k == U_WUSHAN or k == U_MOSHAN or k == U_SHENFANG or k == U_SHENSHANG then
			items[k] = v
		end
	end

	return items
end
horseSoul.getUsedSoulStoneProps = function (equipItems)
	local items = def.horseSoul.getUsedHorseSoulStoneItems(equipItems)
	local allProps = {}

	local function addProp(name, value)
		local notFind = true

		for k, v in ipairs(allProps) do
			if v[1] == name then
				v[2] = v[2] + tonumber(value)
				notFind = false
			end
		end

		if notFind then
			allProps[#allProps + 1] = {
				name,
				tonumber(value)
			}
		end

		return 
	end

	for k, v in pairs(slot1) do
		local props = def.horseSoul.getHorseSoulStoneProps(v)
		local strs = string.split(props, ";")

		for _k, _v in ipairs(strs) do
			local propStr = string.split(_v, "=")

			if #propStr == 2 then
				local propName = propStr[1]
				local propValue = propStr[2]

				addProp(propName, propValue)
			end
		end
	end

	local atrStr = ""

	for k, v in ipairs(allProps) do
		atrStr = atrStr .. v[1] .. "=" .. v[2] .. ";"
	end

	if 2 < string.len(atrStr) then
		local endStr = string.sub(atrStr, -1, -1)

		if endStr == ";" then
			atrStr = string.sub(atrStr, 1, -2)
		end
	end

	return atrStr
end
horseSoul.getHorseSoulStoneProps = function (data)
	local atrStr = ""
	local atrTable = {}

	if not data then
		return atrStr
	end

	local function addStr(name, value)
		atrStr = atrStr .. name .. "=" .. value .. ";"

		return 
	end

	local function addAtrTable(name, value)
		atrTable[#atrTable + 1] = {
			name,
			value
		}

		return 
	end

	for k, v in pairs(data._item) do
		if k == "AC" then
			slot4("防御下限", v)
		elseif k == "maxAC" then
			addAtrTable("防御上限", v)
		elseif k == "MAC" then
			addAtrTable("魔御下限", v)
		elseif k == "maxMAC" then
			addAtrTable("魔御上限", v)
		elseif k == "DC" then
			addAtrTable("攻击下限", v)
		elseif k == "maxDC" then
			addAtrTable("攻击上限", v)
		elseif k == "MC" then
			addAtrTable("魔法下限", v)
		elseif k == "maxMC" then
			addAtrTable("魔法上限", v)
		elseif k == "SC" then
			addAtrTable("道术下限", v)
		elseif k == "maxSC" then
			addAtrTable("道术上限", v)
		end
	end

	for i = 25, 39, 1 do
		local notExc = true

		if i == 36 then
			notExc = false
		end

		if notExc then
			local value = data.getVar(data, def.items.valueType2Key[i])

			if value and value ~= 0 then
				local atrName = def.items.key2ValueName[i]

				if atrName then
					for k, v in ipairs(atrTable) do
						if v[1] == atrName .. "上限" then
							v[2] = v[2] + value
						end
					end
				else
					atrName = "未知属性"

					addAtrTable(atrName, value)
				end
			end
		end
	end

	if data._item.itemExtAbil and data._item.itemExtAbil ~= "" then
		local strs = string.split(data._item.itemExtAbil, "|")

		for k, v in ipairs(strs) do
			local pStrs = string.split(v, ":")

			if #pStrs == 2 then
				addAtrTable(pStrs[1], pStrs[2])
			end
		end
	end

	for k, v in ipairs(atrTable) do
		addStr(v[1], v[2])
	end

	if 2 < string.len(atrStr) then
		local endStr = string.sub(atrStr, -1, -1)

		if endStr == ";" then
			atrStr = string.sub(atrStr, 1, -2)
		end
	end

	return atrStr
end
horseSoul.getHorseSoulByLevel = function (level)
	for k, v in ipairs(MonSoulUpCfg) do
		if v.Level == level then
			return v
		end
	end

	return nil
end
horseSoul.level2str = function (level)
	if level <= 0 then
		return "一阶"
	end

	local n2s = {
		[0] = "零",
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十"
	}
	local l = math.floor(level/10)
	local r = level%10

	if 0 < r then
		l = l + 1
	elseif r == 0 then
		r = 10
	end

	return n2s[l] .. "阶" .. n2s[r] .. "星"
end

return horseSoul
