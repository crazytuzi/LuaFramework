local godring = {}
local GodRingBaseConfig = import("csv2cfg.GodRingBaseConfig")
local GodRingStepConfig = import("csv2cfg.GodRingStepConfig")
local GodRingOpenConfig = import("csv2cfg.GodRingOpenConfig")
godring.imgCfg = {
	"hs",
	"fy",
	"bs",
	"ls"
}
godring.nameCfg = {
	"护身戒指",
	"防御戒指",
	"冰霜戒指",
	"龙神戒指"
}
godring.checkOpen = function (id)
	for k, v in ipairs(GodRingOpenConfig) do
		if v.ID == id and v.BoOpen == 1 and v.NeedSeverStep <= g_data.client.serverState and v.NeedOpenDay <= g_data.client.openDay then
			return true
		end
	end

	return false
end
godring.getOpenNeed = function (id)
	for k, v in ipairs(GodRingOpenConfig) do
		if v.ID == id then
			return v
		end
	end

	return nil
end
godring.getAllGodingRingNum = function ()
	return #GodRingOpenConfig
end
godring.setGodRingData = function (localGodRingList, serverGodRingList)
	localGodRingList = {}

	for i = 1, def.godring.getAllGodingRingNum(), 1 do
		if def.godring.checkOpen(i) then
			local t = {
				FHaveStuffForLevel = 0,
				FStep = 0,
				FHaveStuffForStep = 0,
				FLevel = 0,
				FID = i
			}
			localGodRingList[#localGodRingList + 1] = t
		end
	end

	for k, v in ipairs(serverGodRingList) do
		for _k, _v in ipairs(localGodRingList) do
			if v.FID == _v.FID then
				localGodRingList[_k] = v
			end
		end
	end

	return localGodRingList
end
godring.getGodRingLevelById = function (id)
	local t = {}

	for k, v in ipairs(GodRingBaseConfig) do
		if id == v.ID then
			t[#t + 1] = v
		end
	end

	return t
end
godring.getGodRingStepById = function (id)
	local t = {}

	for k, v in ipairs(GodRingStepConfig) do
		if id == v.ID then
			t[#t + 1] = v
		end
	end

	return t
end
godring.getGodRingByIdAndLevel = function (id, level)
	for k, v in ipairs(GodRingBaseConfig) do
		if id == v.ID and level == v.Level then
			return v
		end
	end

	return nil
end
godring.getGodRingByIdAndStep = function (id, step)
	for k, v in ipairs(GodRingStepConfig) do
		if id == v.ID and step == v.Step then
			return v
		end
	end

	return nil
end
godring.getPropByIdAndLevel = function (id, level, job)
	local data = def.godring.getGodRingByIdAndLevel(id, level)

	if not data then
		return {}
	end

	return def.godring.transPropertyStr(data.MainProperty, data.SpecialProperty, job)
end
godring.getPropByIdAndStep = function (id, step, job)
	local data = def.godring.getGodRingByIdAndStep(id, step)

	if not data then
		return {}
	end

	return def.godring.transPropertyStr(data.GodRingProperty, data.SpecialProperty, job)
end
godring.transPropertyStr = function (propStr, spStr, job)
	local propTable = {}

	if propStr and propStr ~= "" then
		local props = def.godring.dumpPropertyStr(propStr, job)

		for k, v in ipairs(props) do
			propTable[#propTable + 1] = v
		end
	end

	local spStrs = string.split(spStr, ";")

	for k, v in ipairs(spStrs) do
		local strT = string.split(v, "=")

		if #strT == 2 and 1 < tonumber(strT[2]) then
			if strT[1] == "护身减免伤害比例" then
				strT[2] = "+" .. tonumber(strT[2])/100 .. "%"
			elseif strT[1] == "防御效果持续时间" then
				strT[2] = "+" .. tonumber(strT[2])/1000 .. "秒"
			elseif strT[1] == "防御神戒冷却时间" then
				strT[2] = "-" .. tonumber(strT[2])/1000 .. "秒"
			elseif strT[1] == "冰霜神戒冷却时间" then
				strT[2] = "-" .. tonumber(strT[2])/1000 .. "秒"
			elseif strT[1] == "龙神效果持续时间" then
				strT[2] = "+" .. tonumber(strT[2])/1000 .. "秒"
			elseif strT[1] == "龙神神戒冷却时间" then
				strT[2] = "-" .. tonumber(strT[2])/1000 .. "秒"
			elseif strT[1] == "安全区回血百分比" then
				strT[2] = "+" .. tonumber(strT[2])/100 .. "%"
			end

			propTable[#propTable + 1] = strT[1] .. ":" .. strT[2]
		end
	end

	return propTable
end
godring.dumpPropertyStr = function (str, job)
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
godring.getPlayerGodRing = function (id)
	for k, v in ipairs(g_data.player.godRingList) do
		if v.FID == id then
			return v
		end
	end

	return nil
end

return godring
