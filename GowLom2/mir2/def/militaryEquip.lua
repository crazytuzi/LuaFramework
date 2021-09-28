local militaryEquip = {}
local RankEquipBaseCfg = import("csv2cfg.RankEquipBaseCfg")
militaryEquip.getEquipPropertyByLevel = function (type, level)
	if level == 0 then
		level = 1
	end

	for k, v in ipairs(RankEquipBaseCfg) do
		if v.REID == type and v.RELevel == level then
			return v
		end
	end

	return {}
end
militaryEquip.getPreviewList = function (type)
	local result = {}

	for k, v in ipairs(RankEquipBaseCfg) do
		if v.REID == type and v.IsPreview == 1 then
			result[#result + 1] = v
		end
	end

	return result
end
militaryEquip.isCanLevelUp = function (type, level)
	local num = 0

	for k, v in ipairs(RankEquipBaseCfg) do
		if v.REID == type then
			num = num + 1
		end
	end

	if num < level then
		return false
	else
		return true
	end

	return 
end
militaryEquip.dumpPropStr = function (propertyStr, job)
	local props = def.property.dumpPropertyStr("")
	local tmpProps = def.property.dumpPropertyStr(propertyStr)

	props.mergeProp(props, tmpProps)
	props.clearZero(props):toStdProp():grepJob(job)

	return props.props
end
militaryEquip.getEquipIcon = function (property)
	return res.get2("pic/panels/militaryEquip/" .. property.REID .. "/" .. property.Icon .. ".png")
end
militaryEquip.getFlagImg = function (level, cor)
	local index = 1

	if 20 <= level and level <= 49 then
		index = 1
	elseif 50 <= level and level <= 69 then
		index = 2
	elseif 70 <= level and level <= 89 then
		index = 3
	elseif 90 <= level and level <= 100 then
		index = 4
	end

	return res.get2("pic/panels/militaryEquip/" .. cor .. "_" .. index .. ".png")
end

return militaryEquip
