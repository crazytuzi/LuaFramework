local equipSuite = {}
local EquipSuiteCfg = import("csv2cfg.EquipSuiteCfg")
local ESEquipLv = import("csv2cfg.ESEquipLv")
equipSuite.getSuiteTypes = function ()
	local types = {}

	for k, v in ipairs(EquipSuiteCfg) do
		local notPutIn = true

		for _k, _v in ipairs(types) do
			if _v == v.ESTypeName then
				notPutIn = false
			end
		end

		if notPutIn then
			types[#types + 1] = v.ESTypeName
		end
	end

	return types
end
equipSuite.getSuiteByTypeAndLevel = function (eType, eLevel)
	for k, v in ipairs(EquipSuiteCfg) do
		if type(eType) == "number" then
			if v.ESType == eType and v.ESLv == eLevel then
				return v
			end
		elseif type(eType) == "string" and v.ESTypeName == eType and v.ESLv == eLevel then
			return v
		end
	end

	return nil
end
equipSuite.dumpPropertyStr = function (str, job)
	local propTable = {}
	local Props = nil

	if not job then
		Props = def.property.dumpPropertyStr(str):clearZero():toStdProp()
	else
		Props = def.property.dumpPropertyStr(str):clearZero():toStdProp():grepJob(job)
	end

	for i, v in ipairs(Props.props) do
		local p = Props.formatPropString(Props, v[1], "%s:+%s", "%s:%s-%s")
		propTable[#propTable + 1] = p
	end

	return propTable
end
equipSuite.getSuiteLevelNum = function ()
	local levels = {}

	for k, v in ipairs(EquipSuiteCfg) do
		local hasPut = false

		for _k, _v in ipairs(levels) do
			if v.ESLv == _v then
				hasPut = true
			end
		end

		if not hasPut then
			levels[#levels + 1] = v.ESLv
		end
	end

	return #levels
end
equipSuite.getSuiteLevelByName = function (name)
	for k, v in ipairs(ESEquipLv) do
		if v.Name == name then
			return v.Level
		end
	end

	return 0
end
equipSuite.getHaveEquipNum = function (equipItems, needLevel)
	local haveEquipNum = 0

	for _k, item in pairs(equipItems) do
		local name = item.getVar(item, "name")
		local level = def.equipSuite.getSuiteLevelByName(name)

		if needLevel <= level then
			haveEquipNum = haveEquipNum + 1
		end
	end

	return haveEquipNum
end
equipSuite.getShowList = function (equipItems, actList)
	local showList = {}

	if #actList == 0 then
		return showList
	end

	local usedList = def.equipSuite.getUsedList(equipItems, actList)

	for i = 1, def.equipSuite.getSuiteLevelNum(), 1 do
		local level = i
		local type = (usedList[level] and usedList[level].FESType) or 1
		local infoCfg = def.equipSuite.getSuiteByTypeAndLevel(type, level)
		local haveEquipNum = def.equipSuite.getHaveEquipNum(equipItems, infoCfg.EquipLv)
		local suiteInfo = {
			FESType = type,
			FESLv = level,
			FHaveEquipNum = haveEquipNum,
			FBoEffect = infoCfg.EquipNum <= haveEquipNum,
			FBoShowSpecShape = (usedList[level] and usedList[level].FBoShowSpecShape) or false,
			FBoAct = (usedList[level] and true) or false
		}
		showList[#showList + 1] = suiteInfo
	end

	return showList
end
equipSuite.getUsedList = function (equipItems, actList)
	local usedList = {}

	table.sort(actList, function (a, b)
		if a.FESLv == b.FESLv then
			return a.FESType < b.FESType
		else
			return a.FESLv < b.FESLv
		end

		return 
	end)

	for k, v in ipairs(slot1) do
		local infoCfg = def.equipSuite.getSuiteByTypeAndLevel(v.FESType, v.FESLv)
		local haveEquipNum = def.equipSuite.getHaveEquipNum(equipItems, infoCfg.EquipLv)

		if not usedList[v.FESLv] or (usedList[v.FESLv].FESType < v.FESType and infoCfg.EquipNum <= haveEquipNum) then
			usedList[v.FESLv] = v
		end
	end

	return usedList
end

return equipSuite
