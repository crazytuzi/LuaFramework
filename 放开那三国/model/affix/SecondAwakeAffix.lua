-- Filename: AllStarAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 名将属性

require "script/model/hero/HeroModel"
require "script/model/affix/HeroAffixModel"
module("SecondAwakeAffix", package.seeall)

local _affixInfo = {}

function getOpenSecondAwakeId()
	local openAwakeIds = {}
	local formation = DataCache.getFormationInfo()
	for k,v in pairs(formation) do
		if tonumber(v) > 0 then
			openAwakeIds[v] = getOpendIds(v, 1)
	   	end
	end
	--第二套小伙伴
	local secondFriendInfo = SecondFriendData.getSecondFriendInfo()
	for k,v in pairs(secondFriendInfo) do
		if tonumber(v) > 0 then
		    openAwakeIds[v] = getOpendIds(v, 2)
	    end
	end
	return openAwakeIds
end

function getOpendIds( pHeroId, pHeroType)
	local heroInfo 	= HeroModel.getHeroByHid(tostring(pHeroId))
	local dbInfo = DB_Heroes.getDataById(heroInfo.htid)
    local baseAwakeIds = string.split(dbInfo.awake_id, ",")
    local openGrowAwakeIds = HeroAffixModel.getOpenTalentAffixIds(heroInfo)
    local openIds = {}
    for k,v in pairs(baseAwakeIds) do
    	table.insert(openIds, v)
    end
    for k,v in pairs(openGrowAwakeIds) do
    	table.insert(openIds, v)
    end
    -- print(dbInfo.name)
    -- printTable("baseAwakeIds",baseAwakeIds)
    -- printTable("openGrowAwakeIds",openGrowAwakeIds)
    -- printTable("openIds",openIds)
    local retIds = {}
    for k,v in pairs(openIds) do
    	require "db/DB_Awake_ability"
		local awakeInfo = DB_Awake_ability.getDataById(v)
		if awakeInfo.second_awake then
			local secAffixInfo = string.split(awakeInfo.second_awake, "|")
			local needSelfType = tonumber(secAffixInfo[1])
			if needSelfType == pHeroType then
				table.insert(retIds, v)
			end
			if needSelfType == 0 then
				table.insert(retIds, v)
			end
		end
    end
    return retIds
end

function getAffixByHid( pHid )

	local heroInfo = HeroModel.getHeroByHid(pHid)
	local tarDbInfo = DB_Heroes.getDataById(heroInfo.htid)
	local tarCountry = tonumber(tarDbInfo.country)
	local tarGender = tonumber(tarDbInfo.gender)
	local openAwakeIds = getOpenSecondAwakeId()
	printTable("SecondAwakeAffix", openAwakeIds)
	local affix = {}
	for k,v in pairs(openAwakeIds) do
		for k1,v1 in pairs(v) do
			require "db/DB_Awake_ability"
			local awakeInfo = DB_Awake_ability.getDataById(v1)
			if awakeInfo.second_awake then
				local sceAwks = string.split(awakeInfo.second_awake, ",")
				for k,v in pairs(sceAwks) do
					local secAffixInfo = string.split(v, "|")
					local needSelfType = tonumber(secAffixInfo[1])
					local needTarCountry = tonumber(secAffixInfo[2])
					local needTarGender = tonumber(secAffixInfo[3])
					local affixId = tonumber(secAffixInfo[4])
					local affixValude = tonumber(secAffixInfo[5])
					if (needTarCountry == tarCountry or needTarCountry == 0)  and (needTarGender == tarGender or needTarGender == 0) then
						if affix[affixId] == nil then
							affix[affixId] = affixValude
						else
							affix[affixId] = affix[affixId] + affixValude
						end
					end
				end
			end
		end
	end
	return affix
end