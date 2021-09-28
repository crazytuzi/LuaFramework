-- Filename: GuildSkillData.lua
-- Author: lgx
-- Date: 2016-03-02
-- Purpose: 军团科技数据层

module("GuildSkillData", package.seeall)
require "db/DB_GruopTech_skill"
require "script/ui/guild/GuildDataCache"

-- 数据类型
kTypeGroup 		= 0
kTypeMember 	= 1

-- 成员科技属性加成信息
local _guildSkillAttrInfo 	= nil

--[[
	@desc:	获取军团科技信息
	@param:	number pShow 数据类型 0军团 1成员 
--]]
function getGuildSkillInfo( pShow )
	local skillInfo = {}
    for k,v in pairs(DB_GruopTech_skill.GruopTech_skill) do
        local tab = DB_GruopTech_skill.getDataById(v[1])
	    -- 根据show判断是否显示在成员个人科技中
	    if (pShow == kTypeGroup or tab.show == pShow) then
	        table.insert(skillInfo,tab)
        end
    end
    -- 按rank排序
    table.sort(skillInfo,function (v1,v2)
    	return v1.rank > v2.rank
	end)
	return skillInfo
end

--[[
	@desc:		获取升级科技需要的军团消耗(军团建设度)
	@param:		number pSkillId 军团科技Id
	@param:		number pLevel 	军团科技等级
	@return: 	string 军团消耗信息
--]]
function getUpgradeCostGuildExp( pSkillId , pLevel )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	local costInfo = string.split(tab.corps_cost, ",")
	local guildCost = costInfo[pLevel]
	return guildCost
end

--[[
	@desc:		获取升级科技需要的个人消耗(科技图纸)
	@param:		number pSkillId 科技Id
	@param:		number pLevel 	科技等级
	@return: 	string 个人消耗信息
--]]
function getUpgradeCostMemberItem( pSkillId , pLevel )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	local costInfo = string.split(tab.personal_cost, ",")
	local memberCost = costInfo[pLevel]
	return memberCost
end

--[[
	@desc:		获取军团科技表中配置的等级上限
	@param:		number pSkillId 科技Id
	@return:	number 等级上限
--]]
function getMaxGuildSkillLevel( pSkillId )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	local costInfo = string.split(tab.corps_cost, ",")
	return #costInfo
end

--[[
	@desc:		获取军团成员科技表中配置的等级上限
	@param:		number pSkillId 科技Id
	@return:	number 等级上限
--]]
function getMaxCfgMemberSkillLevel( pSkillId )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	local costInfo = string.split(tab.personal_cost, ",")
	return #costInfo
end

--[[
	@desc:		获取军团成员科技实际的等级上限
	@param:		number pSkillId 科技Id
	@return:	number 等级上限
--]]
function getMaxMemberSkillLevel( pSkillId )
	local guildMaxLv = getMaxCfgMemberSkillLevel(pSkillId)
	local curGroupLv = GuildDataCache.getGuildGroupSkillLv(pSkillId)
	if (guildMaxLv > curGroupLv) then
		return curGroupLv
	else
		return guildMaxLv
	end
end

--[[
	@desc: 		获取是否显示军团科技管理按钮
	@return:	bool 是否是军团长或者副军团长
--]]
function getIsGuildAdmin()
	-- 0为平民，1为会长，2为副会长
	local isAdmin = false
	local memberType = GuildDataCache.getMineMemberType()
	if (memberType ~= 0) then
		isAdmin = true
	end
	return isAdmin
end

--[[
	@desc:		获取属性加成信息
	@param:		pSkillId 科技Id
	@param:		pLevel 科技等级
	@return:	displayNum 加成显示数
--]]
function getAttrNumBySkillId( pSkillId, pLevel )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	if (tonumber(tab.type) == 1) then
		local growInfo = string.split(tab.grow_up,"|")
		local affixId = tonumber(growInfo[1])
		local affixNum = tonumber(growInfo[2])*pLevel
		local affixDesc,displayNum,realNum = ItemUtil.getAtrrNameAndNum(affixId,affixNum)
		return displayNum
	else
		-- 增加军团人数上限
		local displayNum = tonumber(tab.grow_up)*pLevel
		return displayNum
	end
end

--[[
	@desc:		获取科技的信息
	@param:		pSkillId 科技Id
	@return:	tab 科技信息
--]]
function getSkillInfoBySkillId( pSkillId )
	local tab = DB_GruopTech_skill.getDataById(pSkillId)
	return tab
end

--[[
	@desc:		计算军团科技属性加成信息
	@return: 	tab {id = value} 属性加成信息
--]]
function calculateGuildSkillAttrInfo()
	local retData = {}
	local skills = GuildDataCache.getGuildMemberSkillInfo()
	if (not table.isEmpty(skills)) then
		for k,v in pairs(skills) do
			local skillId = tonumber(k)
			local skillLv = tonumber(v)
			local skillTab = DB_GruopTech_skill.getDataById(skillId)
			if (tonumber(skillTab.type) == 1) then
				local growInfo = string.split(skillTab.grow_up,"|")
				local affixId = tonumber(growInfo[1])
				local affixNum = tonumber(growInfo[2])*skillLv
				if( retData[affixId] == nil  )then
					retData[affixId] = affixNum
				else
					retData[affixId] = retData[affixId] + affixNum
				end
			end
		end
	end
	return retData
end

--[[
	@desc:	获取军团成员科技属性加成信息
	@param: pIsForce 强制重新计算
--]]
function getGuildSkillAttrInfo( pIsForce )
	if (pIsForce or _guildSkillAttrInfo == nil) then
		_guildSkillAttrInfo = calculateGuildSkillAttrInfo()
	end
	return _guildSkillAttrInfo
end