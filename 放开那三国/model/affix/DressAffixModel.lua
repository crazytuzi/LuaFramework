-- Filename: DressAffixModel.lua.
-- Author: licheyang
-- Date: 2015-03-05
-- Purpose: 时装属性


require "script/model/hero/HeroModel"
module("DressAffixModel", package.seeall)

local _affixCache = {}
local _unlockAffix = nil

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid ,p_isForce)
	--先从缓存取
	if _affixCache[tonumber(p_hid)] and p_isForce ~= true then
		return _affixCache[tonumber(p_hid)]
	end
	local heroInfo 	  = HeroModel.getHeroByHid(tostring(p_hid))
	local heroDBInfo  = DB_Heroes.getDataById(heroInfo.htid)
	local affix = {}
	-- 时装系统战斗力加成
	local dress = heroInfo.equip.dress

	for k, v in pairs(dress) do
		if tonumber(v) ~= 0 then
			local dressAffix = getDressAffixByDreeInfo(v)
			for k,v in pairs(dressAffix) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
		end
	end
	_affixCache[tonumber(p_hid)] = affix
	return affix
end

--[[
	desc: 获取时装天赋已解锁的属性，给阵容上所有人增加
	param:
	return:
--]]
function getUnLockAffix(p_isForce)
	--先从缓存取
	if _unlockAffix and p_isForce ~= true then
		return _unlockAffix
	end
	local heroInfo  = HeroModel.getNecessaryHero()
	local affix = {}
	-- 时装系统战斗力加成
	local dress = heroInfo.equip.dress
	for k, v in pairs(dress) do
		if tonumber(v) ~= 0 then
			local dressAffix = getUnlockedTalent(v)
			for k,v in pairs(dressAffix) do
				if affix[k] == nil then
					affix[k] = v
				else
					affix[k] = affix[k] + v
				end
			end
		end
	end
	_unlockAffix = affix
	return affix
end


--[[
	desc: 计算解锁的属性
	param:
	return:
--]]
function getUnlockedTalent( p_dressInfo )
	local itemTid = p_dressInfo.item_template_id
	local level   = tonumber(p_dressInfo.va_item_text.dressLevel) or 0
	local tid = tonumber(itemTid)
	require "db/DB_Item_dress"
	local desc = DB_Item_dress.getDataById(tid)
	local tbRet = {}
	local tbAllTalent = lua_string_split(desc.extra_attr, ",")
	for i, sTalent in ipairs(tbAllTalent) do
		--"等级｜属性id｜属性值"
		local tbTalent = lua_string_split(sTalent, "|")
		local needLevel = tonumber(tbTalent[1])
		local affixId = tonumber(tbTalent[2])
		local affixValue = tonumber(tbTalent[3])
		if level >= needLevel then  --判断是否解锁
			if(tbRet[affixId] == nil) then
				tbRet[affixId]=affixValue
			else
				tbRet[affixId]=tbRet[affixId]+affixValue
			end
		end
	end
	return tbRet
end



--[[
	@des: 根据武平信息得到物品属性
	@parm: dressinfo {
		--后端时装信息结构
	}
	@ret: {
		affixId => affixValue,
		...
	}
--]]
function getDressAffixByDreeInfo( p_dressInfo )
	local itemTid = p_dressInfo.item_template_id
	local level   = p_dressInfo.va_item_text.dressLevel or 0
	--基础属性
	local affix   = getDressBaseAffixByTid(itemTid)
	--成长属性
	local dbInfo = DB_Item_dress.getDataById(itemTid)
	local growAffixes = string.split(dbInfo.growAffix, ",")
	for i=1, #growAffixes do
		local item       = string.split(growAffixes[i], "|")
		local affixId    = tonumber(item[1])
		local affixValue = tonumber(item[2])
		if affix[affixId] == nil then
			affix[affixId] = affixValue * level
		else
			affix[affixId] = affix[affixId] + affixValue * level
		end
	end
	return affix
end


--[[
	@des: 得到时装基础信息
	@param: p_itemTid 时装模板id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getDressBaseAffixByTid( p_itemTid )
	local dbInfo = DB_Item_dress.getDataById(p_itemTid)
	local affix = {}
	local baseAffixes = string.split(dbInfo.baseAffix, ",")
	for i=1, #baseAffixes do
		local item = string.split(baseAffixes[i], "|")
		local affixId = tonumber(item[1])
		local affixValue = tonumber(item[2])
		if affix[affixId] == nil then
			affix[affixId] = affixValue
		else
			affix[affixId] = affix[affixId] + affixValue
		end
	end
	return affix
end




