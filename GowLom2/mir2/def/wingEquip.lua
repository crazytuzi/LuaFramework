local wingEquip = {}
local WingEquipBaseCfg = import("csv2cfg.WingEquipBaseCfg")
local WELossWSWeightCfg = import("csv2cfg.WELossWSWeightCfg")
wingEquip.getWingEquip = function (typeName, level)
	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEName == typeName and v.WELevel == level then
			return v
		end
	end

	return nil
end
wingEquip.getWingEquipTypes = function ()
	local types = {}

	for k, v in ipairs(WingEquipBaseCfg) do
		local noPut = true

		for _k, _v in ipairs(types) do
			if v.WEName == _v then
				noPut = false
			end
		end

		if noPut then
			types[#types + 1] = v.WEName
		end
	end

	return types
end
wingEquip.getWingEquipID = function (typeName)
	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEName == typeName then
			return v.WEID
		end
	end

	return 0
end
wingEquip.getWingEquipTypeName = function (id)
	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEID == id then
			return v.WEName
		end
	end

	return ""
end
wingEquip.getWingEquipProps = function (typeName, level, job)
	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEName == typeName and v.WELevel == level then
			return def.wingEquip.dumpPropertyStr(v.PropertyStr, job)
		end
	end

	return {}
end
wingEquip.dumpPropertyStr = function (str, job)
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
wingEquip.getBaoLv = function (typeName)
	local baolv = {}
	local bRedName = 200 <= g_data.player.ability.FPkValue

	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEName == typeName then
			local dropChance = (200 < g_data.player.ability.FPkValue and v.RedDropChance) or v.NoRedDropChance

			for _k, _v in ipairs(WELossWSWeightCfg) do
				if _v.WEName == typeName and _v.WELevel == v.WELevel then
					baolv[#baolv + 1] = {
						level = v.WELevel,
						percent = _v.Weight/10000*dropChance/10000*100,
						value = _v.LossValue
					}
				end
			end
		end
	end

	return baolv
end
wingEquip.getIsOpen = function (typeName)
	for k, v in ipairs(WingEquipBaseCfg) do
		if v.WEName == typeName and v.WELevel == 0 and v.UpNeedServerStep <= g_data.client.serverState and v.UpNeedOpenDays <= g_data.client.openDay then
			return true
		end
	end

	return false
end
wingEquip.getWingEquipState = function (wingEquipInfoList, typeName)
	local bopen = false
	local data = nil
	local wingEquipId = def.wingEquip.getWingEquipID(typeName)

	for k, v in ipairs(wingEquipInfoList) do
		if v.FID == wingEquipId then
			bopen = true
			data = v
		end
	end

	return bopen, data
end

return wingEquip
