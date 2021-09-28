require "script/utils/extern"
require "db/skill"
require "db/DB_Item_dress"
require "script/model/hero/HeroModel"

module("BT_Skill", package.seeall)

function getDataById( p_skillId, p_DressId, p_htid )
	-- print("p_skillId, p_DressId, p_htid",p_skillId, p_DressId, p_htid)
	local dressId = p_DressId or 1
	local skillId = p_skillId or 1
	local htid 	  = p_htid or 0
 	local skillData = skill.getDataById(skillId)

 	--判断是否需要时装改变特效
 	if skillData.suitChange ~= 1 then
 		return skillData
 	end
	local heroDataInfo = DB_Heroes.getDataById(htid)
	if p_DressId and p_DressId ~= 0 and tonumber(skillData.functionWay) ~= 2 and heroDataInfo then
		-- setmetatable(skillDateInfo, skillDate)
		-- print("开始替换数据")
		local sexId   = HeroModel.getSex(htid)
		local skillDataInfo = {}
		table.hcopy(skillData, skillDataInfo)

		local dreeInfo = DB_Item_dress.getDataById(dressId)
		if string.split(dreeInfo.mpostionType, ",")[sexId] ~= "nil" then
			skillDataInfo.mpostionType = tonumber(string.split(dreeInfo.mpostionType, ",")[sexId])
		else
			skillDataInfo.mpostionType =nil
		end
		if string.split(dreeInfo.distancePath, ",")[sexId] ~= "nil" then
			skillDataInfo.distancePath = (string.split(dreeInfo.distancePath, ",")[sexId])
		else
			skillDataInfo.distancePath = nil
		end
		if string.split(dreeInfo.actionid, ",")[sexId] ~= "nil" then
			skillDataInfo.actionid = (string.split(dreeInfo.actionid, ",")[sexId])
		else
			skillDataInfo.actionid = nil
		end
		if string.split(dreeInfo.skillEffect, ",")[sexId] ~= "nil" then
			skillDataInfo.skillEffect = (string.split(dreeInfo.skillEffect, ",")[sexId])
		else
			skillDataInfo.skillEffect = nil
		end
		if string.split(dreeInfo.fullScreen, ",")[sexId] ~= "nil" then
			skillDataInfo.fullScreen = tonumber(string.split(dreeInfo.fullScreen, ",")[sexId])
		else
			skillDataInfo.fullScreen = nil
		end
		if string.split(dreeInfo.attackEffct, ",")[sexId] ~= "nil" then
			skillDataInfo.attackEffct = (string.split(dreeInfo.attackEffct, ",")[sexId])
		else
			skillDataInfo.attackEffct = nil
		end
		if string.split(dreeInfo.spell_effect, ",")[sexId] ~= "nil" then
			skillDataInfo.spell_effect = (string.split(dreeInfo.spell_effect, ",")[sexId])
		else
			skillDataInfo.spell_effect = nil
		end
		if string.split(dreeInfo.hitEffct, ",")[sexId] ~= "nil" then
			skillDataInfo.hitEffct = (string.split(dreeInfo.hitEffct, ",")[sexId])
		else
			skillDataInfo.hitEffct = nil
		end
		if string.split(dreeInfo.hit_effect, ",")[sexId] ~= "nil" then
			skillDataInfo.hit_effect = (string.split(dreeInfo.hit_effect, ",")[sexId])
		else
			skillDataInfo.hit_effect = nil
		end
		if string.split(dreeInfo.attackEffctPosition, ",")[sexId] ~= "nil" then
			skillDataInfo.attackEffctPosition = (string.split(dreeInfo.attackEffctPosition, ",")[sexId])
		else
			skillDataInfo.attackEffctPosition = nil
		end
		-- print("替换数据完成")
		-- printTable("skillDataInfo", skillDataInfo)

		return skillDataInfo
	else
		-- local skillDataInfo = skill.getDataById(skillId)
		-- print("BT_Skill end")
		return skillData
	end
end

