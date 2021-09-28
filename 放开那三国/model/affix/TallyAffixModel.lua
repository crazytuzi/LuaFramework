-- FileName: TallyAffixModel.lua 
-- Author: licong 
-- Date: 16/1/12 
-- Purpose: 兵符属性


module("TallyAffixModel", package.seeall)

--[[
	@parm: p_hid 武将id
	@ret:{
		affixId => affixValue,
		...
	}
--]]
function getAffixByHid( p_hid )
	local heroInfo 	  = HeroModel.getHeroByHid(tostring(p_hid))
	local heroDBInfo  = DB_Heroes.getDataById(heroInfo.htid)
	local affix = {}
	local tallyInfo = heroInfo.equip.tally or {}
	for k_index, v_itemInfo in pairs(tallyInfo) do
		if tonumber(v_itemInfo) ~= 0 then
			-- 所有属性
			local allAffixInfo  = getAllAffixByItemInfo(v_itemInfo)
			for k_id,v_value in pairs(allAffixInfo) do
				if affix[k_id] == nil then
					affix[k_id] = v_value
				else
					affix[k_id] = affix[k_id] + v_value
				end
			end
		end
	end
	require "script/ui/tally/TallyMainData"
	local affixTable = TallyMainData.getQualityByHid(p_hid)
	for k,v in pairs(affixTable) do
		local haveSame = false
		for key,value in pairs(affix)do
			if(k==key)then
				affix[k] = v+value
				haveSame = true
				break
			end
		end
		if(not haveSame)then
			affix[k] = v
		end
	end
	return affix
end
--[[
	@des 	: 得到基础属性
	@param 	: p_itemInfo
	@return : {id = value,}
--]]
function getAllAffixByItemInfo( p_itemInfo )
	local retData = {}
	-- 基础属性
	local baseAffixInfo  = getBaseAffixByItemInfo(p_itemInfo)
	for k_id,v_value in pairs(baseAffixInfo) do
		if retData[k_id] == nil then
			retData[k_id] = v_value
		else
			retData[k_id] = retData[k_id] + v_value
		end
	end
	-- 进阶属性
	local developAffixInfo = getDevelopAffixByItemInfo(p_itemInfo)
	for k_id,v_value in pairs(developAffixInfo) do
		if retData[k_id] == nil then
			retData[k_id] = v_value
		else
			retData[k_id] = retData[k_id] + v_value
		end
	end
	-- 精炼属性
	local evolveAffixInfo = getEvolveAffixByItemInfo( p_itemInfo )
	for k_id,v_value in pairs(evolveAffixInfo) do
		if retData[k_id] == nil then
			retData[k_id] = v_value
		else
			retData[k_id] = retData[k_id] + v_value
		end
	end
	return retData
end

--[[
	@des 	: 得到基础属性
	@param 	: p_tid
	@return : {id = value,}
--]]
function getBaseAffixByTid( p_tid )
	local retData = {}
	local dbData = ItemUtil.getItemById( p_tid )
	local atrrStab = string.split(dbData.baseAtt,",")
	for i=1,#atrrStab do
		local temp = string.split(atrrStab[i],"|")
		retData[tonumber(temp[1])] = tonumber(temp[2])
	end
	return retData
end

--[[
	@des 	: 得到每级成长属性
	@param 	: p_tid
	@return : {id = value,}
--]]
function getGrowAffixByTid( p_tid )
	local retData = {}
	local dbData = ItemUtil.getItemById( p_tid )
	local atrrStab = string.split(dbData.growAtt,",")
	for i=1,#atrrStab do
		local temp = string.split(atrrStab[i],"|")
		retData[tonumber(temp[1])] = tonumber(temp[2])
	end
	return retData
end

--[[
	@des 	: 得到基础属性
	@param 	: p_itemInfo
	@return : {id = value,...}
--]]
function getBaseAffixByItemInfo( p_itemInfo )
	local retData = {}
	local baseTab = getBaseAffixByTid( p_itemInfo.item_template_id )
	local growTab = getGrowAffixByTid( p_itemInfo.item_template_id )
	local curLv = 0
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.tallyLevel )then
		curLv = tonumber(p_itemInfo.va_item_text.tallyLevel)
	end
	for k_id,v_value in pairs(baseTab) do
		retData[k_id] = v_value + curLv * growTab[k_id]
	end
	return retData
end

--[[
	@des 	: 得到基础属性
	@param 	: p_itemId
	@return : {id = value,...}
--]]
function getBaseAffixByItemId( p_itemId )
	local itemInfo = ItemUtil.getItemByItemId( p_itemId )
	local retData = getBaseAffixByItemInfo( itemInfo )
	return retData
end

--[[
	@des 	: 得到进阶属性
	@param 	: p_tid
	@return : {51|100,109|10,...}
--]]
function getDevelopAffixByTid( p_tid )
	local dbData = ItemUtil.getItemById( p_tid )
	local retData = string.split(dbData.Advance_Att,";")
	return retData
end


--[[
	@des 	: 得到进阶属性
	@param 	: p_itemInfo
	@return : {id = value,...}
--]]
function getDevelopAffixByItemInfo( p_itemInfo )
	local retData = {}
	local atrrStrtab = getDevelopAffixByTid( p_itemInfo.item_template_id )
	local curDevelopLv = 0
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.tallyDevelop )then
		curDevelopLv = tonumber(p_itemInfo.va_item_text.tallyDevelop)
	end
	-- 从0阶的属性累加到当前阶数
	for i=1,curDevelopLv+1 do
		local atrrTab = string.split(atrrStrtab[i],",")
		for i=1,#atrrTab do
			local temp = string.split(atrrTab[i],"|")
			if(retData[tonumber(temp[1])] == nil)then
				retData[tonumber(temp[1])] = tonumber(temp[2])
			else
				retData[tonumber(temp[1])] = retData[tonumber(temp[1])] + tonumber(temp[2])
			end
		end
	end
	
	return retData
end

--[[
	@des 	: 得到进阶属性
	@param 	: p_itemId
	@return : {id = value,...}
--]]
function getDevelopAffixByItemId( p_itemId )
	local itemInfo = ItemUtil.getItemByItemId( p_itemId )
	local retData = getDevelopAffixByItemInfo( itemInfo )
	return retData
end

--[[
	@des 	: 得到精炼提供的天赋id
	@param 	: p_tid，p_evolve精炼等级
	@return : id
--]]
function getEvolveEffectIdByTid( p_tid, p_evolve )
	local dbData = ItemUtil.getItemById( p_tid )
	local effectStrTab = string.split(dbData.upgrade_effect,",")
	local curEvolve = tonumber(p_evolve) or 0
	local retData = nil
	for i=1,#effectStrTab do
		local temp = string.split(effectStrTab[i],"|")
		if( tonumber(temp[1]) == curEvolve )then
			retData = tonumber(temp[2])
			break
		end
	end
	return retData
end

--[[
	@des 	: 得到精炼提供的天赋描述
	@param 	: p_tid，p_evolve精炼等级
	@return : 精炼效果信息
--]]
function getEvolveEffectDesByTid( p_tid, p_evolve )
	local effectId = getEvolveEffectIdByTid( p_tid, p_evolve )
	require "db/DB_Awake_ability"
	local dbData = DB_Awake_ability.getDataById(effectId)
	local retData = dbData
	return retData
end

--[[
	@des 	: 得到精炼属性
	@param 	: p_tid，p_evolve精炼等级
	@return : {id = value,...}
--]]
function getEvolveAffixByTid( p_tid, p_evolve )
	local curEffectId = getEvolveEffectIdByTid( p_tid, p_evolve )
	require "script/model/affix/HeroAffixModel"
	local retData = HeroAffixModel.getAffixByTelentId(curEffectId)
	return retData
end

--[[
	@des 	: 得到精炼属性
	@param 	: p_itemInfo
	@return : {id = value,...}
--]]
function getEvolveAffixByItemInfo( p_itemInfo )
	local curEvolve = 0
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.tallyEvolve )then
		curEvolve = tonumber(p_itemInfo.va_item_text.tallyEvolve)
	end
	local retData = getEvolveAffixByTid( p_itemInfo.item_template_id, curEvolve )
	return retData
end

--[[
	@des 	: 得到精炼属性
	@param 	: p_itemId
	@return : {id = value,...}
--]]
function getEvolveAffixByItemId( p_itemId )
	local itemInfo = ItemUtil.getItemByItemId( p_itemId )
	local retData = getEvolveAffixByItemInfo(itemInfo)
	return retData
end





