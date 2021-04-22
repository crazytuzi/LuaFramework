--
-- Author: Kumo
--QArchaeologyUtils

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QActorProp = import("..models.QActorProp")

function getArchaeologyBuffTableByFragmentID( fragmentID )
	if fragmentID == nil or fragmentID == 0 then return {} end
	-- 1：全队出战生命固定值加成
	-- 2：全队出战攻击固定值加成
	-- 3：全队出战魔防固定值加成
	-- 4：全队出战物防固定值加成
	-- 5：全队出战生命百分比加成
	-- 6：全队出战攻击百分比加成
	-- 7：全队出战魔防百分比加成
	-- 8：全队出战物防百分比加成
	local returnTable = {0, 0, 0, 0, 0, 0, 0, 0}
	if fragmentID == 0 then return returnTable end
	local archaeologyConfig = getArcharologyConfig()
	for _, value in pairs(archaeologyConfig) do
		if value.id <= fragmentID then
			if value.value == nil then value.value = 0 end
			returnTable[value.type] = returnTable[value.type] + value.value
		end
	end
	-- printInfo("[Kumo] getArchaeologyBuffTableByFragmentID : ")
	-- printTable(returnTable)

	return returnTable
end

function getArchaeologyPropByFragmentID( fragmentID )
	if fragmentID == nil or fragmentID == 0 then return {} end
	local propTbl = {}
	local archaeologyConfig = getArcharologyConfig()
	for _,config in pairs(archaeologyConfig) do
		if config.id <= fragmentID then
			config = q.cloneShrinkedObject(config)
			for name,filed in pairs(QActorProp._field) do
				if config[name] ~= nil then
					if propTbl[name] == nil then
						propTbl[name] = config[name]
					else
						propTbl[name] = config[name] + propTbl[name]
					end
				end
			end
		end
	end
	return propTbl
end

function getArcharologyConfig()
	return QStaticDatabase:sharedDatabase():getArcharologyConfig()
end