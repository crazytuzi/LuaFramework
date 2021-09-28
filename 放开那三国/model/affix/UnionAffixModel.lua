-- Filename: UnionAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 武将羁绊属性

module("UnionAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	-- 武将连携属性 = 武将和武将之间连携属性 + 武将和羁绊之间的连携属性
	local affix = {}
	--武将连携
	local heroAffix = getHeroUnionAffix(p_hid)
	for id,value in pairs(heroAffix) do
		if affix[id] == nil then
			affix[id] = value
		else
			affix[id] = affix[id] + value
		end
	end
	--神兵连携
	local godAffix  = getGodUnionAffix(p_hid)
	for id,value in pairs(godAffix) do
		if affix[id] == nil then
			affix[id] = value
		else
			affix[id] = affix[id] + value
		end
	end
	return affix
end

--[[
	@des: 得到当前武将羁绊属性
	@parm: p_hid
	@ret:{
		affixId => affixValue
	}
--]]
function getHeroUnionAffix( p_hid )
	require "script/model/utils/UnionProfitUtil"
	local heroUnionInfo = UnionProfitUtil.getUnionProfitInfo()["onFormation"][tonumber(p_hid)]
	if heroUnionInfo == nil then
		heroUnionInfo = UnionProfitUtil.getUnionProfitInfo()["secondFriend"][tonumber(p_hid)]
	end
	local affix = getUnionAffixByIds(heroUnionInfo)
	return affix
end

--[[
	@des: 得到当前武将羁绊属性
	@parm: p_hid
	@ret:{
		affixId => affixValue
	}
--]]
function getGodUnionAffix( p_hid )
	local godUnionInfo = UnionProfitUtil.getGodUnionInfo()[p_hid]
	local affix = getUnionAffixByIds(godUnionInfo)
	return affix
end


--[[
	@des : 得到羁绊属性
	@parm: p_unionIdArray 羁绊id数组
	@ret:{
		affixId =>affixValue
		...
	}
--]]
function getUnionAffixByIds( p_unionIdArray )
	local unionIds = p_unionIdArray or {} 
	local affix = {}
	for k,v in pairs(unionIds) do
		local unionAffix = getUnionAffix(v)
		for id,value in pairs(unionAffix) do
			if affix[id] == nil then
				affix[id] = value
			else
				affix[id] = affix[id] + value
			end
		end
	end
	return affix
end

--[[
	@des : 得到羁绊属性
	@parm: p_unionId 羁绊id
	@ret:{
		affixId =>affixValue
		...
	}
--]]
function getUnionAffix( p_unionId )
	local dbInfo  = DB_Union_profit.getDataById(p_unionId)
	local affixIds = string.split(dbInfo.union_arribute_ids, ",")
	local affixValues = string.split(dbInfo.union_arribute_nums, ",")

	local affix = {}
	for i=1,#affixIds do
		local id = tonumber(affixIds[i])
		local value = tonumber(affixValues[i])
		if affix[id] == nil then
			affix[id] = value
		else
			affix[id] = affix[id] + value
		end
	end
	return affix
end
