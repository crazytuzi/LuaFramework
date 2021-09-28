--SmelterReader.lua
--/*-----------------------------------------------------------------
 --* Module:  SmelterReader.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月23日
 --* Purpose: Implementation of the SmelterReader
 -------------------------------------------------------------------*/
 
--（1白色，6红色，2绿色，3蓝色，4紫色，5橙色）
EQUIPMENT_TYPE = 1	
--SmeltValue = {}				--熔炼值
--SmeltGetMoney = {}			--熔炼获得的装备
EquipStreng = {}                --强化表

function loadPropData()
	--self._ItemCompandAndSmelter
	--EquipStrengthDB
	local prop = require "data.EquipStrengthDB"
	for _, record in pairs(prop or {}) do
		local propType = tonumber(record.q_type or 0)
		if not EquipStreng[propType] then
			EquipStreng[propType] = {}
		end

		local strengthLvl = tonumber(record.q_level or 1)
		if not EquipStreng[propType][strengthLvl] then
			EquipStreng[propType][strengthLvl] = {}
		end

		--EquipStreng[propType][strengthLvl].
		--local Temp = {}
		--Temp.type=tonumber(record.q_type or 1)
		--Temp.Strenglvl = tonumber(record.q_level or 1)
		EquipStreng[propType][strengthLvl].backID1 = tonumber(record.q_smelterID1 or 0)
		EquipStreng[propType][strengthLvl].backNum1 = tonumber(record.q_smelterNum1 or 0)
		EquipStreng[propType][strengthLvl].backID2 = tonumber(record.q_smelterID2 or 0)
		EquipStreng[propType][strengthLvl].backNum2 = tonumber(record.q_smelterNum2 or 0)
		EquipStreng[propType][strengthLvl].backID3 = tonumber(record.q_smelterID3 or 0)
		EquipStreng[propType][strengthLvl].backNum3 = tonumber(record.q_smelterNum3 or 0)
		EquipStreng[propType][strengthLvl].backID4 = tonumber(record.q_smelterID4 or 0)
		EquipStreng[propType][strengthLvl].backNum4 = tonumber(record.q_smelterNum4 or 0)
		--table.insert(EquipStreng[propType],Temp)
	end
	--print("loadPropData 01",toString(SmeltValue),toString(SmeltGetMoney),toString(VioletEquip))
end