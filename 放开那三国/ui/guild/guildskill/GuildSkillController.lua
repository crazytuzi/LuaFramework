-- Filename: GuildSkillController.lua
-- Author: lgx
-- Date: 2016-03-02
-- Purpose: 军团科技逻辑控制层

module("GuildSkillController", package.seeall)

require "script/ui/guild/guildskill/GuildSkillService"
require "script/ui/guild/guildskill/GuildSkillData"
require "script/ui/guild/GuildDataCache"
require "script/ui/tip/AnimationTip"

-- 后端接口类型,1成员学习 2管理提升
local kPromoteMember 	= 1
local kPromoteGroup 	= 2

-- 需要消耗的科技图纸
local _needBook 	= nil
-- 需要消耗的军团建设度
local _needDonate 	= nil

--[[
	@desc:	成员学习/升级军团科技 逻辑判断 请求发送
--]]
function promoteByMember( pSkillId , pCallback )
	-- 条件判断 军团成员升级科技
	local curLevel = GuildDataCache.getGuildMemberSkillLv(pSkillId)
	
	-- 1.判断科技等级上限
	local maxLevel = GuildSkillData.getMaxCfgMemberSkillLevel(pSkillId)
	if (curLevel >= maxLevel) then
		-- 该科技已升满
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1006"))
		return
	end

	local groupLevel = GuildSkillData.getMaxMemberSkillLevel(pSkillId)
	if (curLevel >= groupLevel) then
		-- 达到军团技能上限
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1007"))
		return
	end

	-- 2.判断科技图纸是否足够
	local costTab = string.split(GuildSkillData.getUpgradeCostMemberItem(pSkillId,curLevel+1), "|")
	_needBook = tonumber(costTab[#costTab])
	local curBook = UserModel.getBookNum()
	if (_needBook > curBook) then
		-- 科技图纸不足
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1008"))
		return
	end
	
	local requestCallback = function ( ... )
		-- 提示文字
		local curLevel = GuildDataCache.getGuildMemberSkillLv(pSkillId)
		if (curLevel >= 1) then
			-- 升级成功
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1003"))
		else
			-- 学习成功
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1002"))
		end
		-- 1.更新军团成员科技等级
		GuildDataCache.setGuildMemberSkillLv(pSkillId,curLevel+1)
		-- 2.更新科技图纸数量
		UserModel.addBookNum(-_needBook)
		-- 3.刷新UI
		require "script/ui/guild/guildskill/GuildSkillLayer"
		GuildSkillLayer.updateUI()
		-- 4.计算科技属性加成
		GuildSkillData.getGuildSkillAttrInfo(true)

		if pCallback then
			pCallback()
		end
	end
	-- 向后端发送请求
	GuildSkillService.promote(pSkillId,kPromoteMember,requestCallback)
end

--[[
	@desc: 	军团长或副军团长提升军团科技等级上限
--]]
function promoteByAdmin( pSkillId , pCallback )
	-- 进行条件判断 军团管理提升科技
	local curLevel = GuildDataCache.getGuildGroupSkillLv(pSkillId)

	-- 1.判断科技等级上限
	local maxLevel = GuildSkillData.getMaxGuildSkillLevel(pSkillId)
	if (curLevel >= maxLevel) then
		-- 当前科技已升满
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1001"))
		return
	end

	-- 2.判断当前建设度是否足够
	local costTab = string.split(GuildSkillData.getUpgradeCostGuildExp(pSkillId,curLevel+1), "|")
	_needDonate = tonumber(costTab[#costTab])
	local curDonate = GuildDataCache.getGuildDonate()
	if (_needDonate > curDonate) then
		-- 建设度不足
		AnimationTip.showTip(GetLocalizeStringBy("lic_1360"))
		return
	end

	local requestCallback = function ( ... )
		-- 提示文字
		local curLevel = GuildDataCache.getGuildGroupSkillLv(pSkillId)
		if (curLevel >= 1) then
			-- 提升成功
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1005"))
		else
			-- 研发成功
			AnimationTip.showTip(GetLocalizeStringBy("lgx_1004"))
		end
		-- 1.更新军团科技等级
		GuildDataCache.setGuildGroupSkillLv(pSkillId,curLevel+1)
		-- 2.特殊约定 军团人数上限 type 2
		local skillInfo = GuildSkillData.getSkillInfoBySkillId(pSkillId)
		if (tonumber(skillInfo.type) == 2) then
			-- 更新军团人数上限
			GuildDataCache.addGuildMemberLimit(tonumber(skillInfo.grow_up))
		end
		-- 3.更新军团建设度
		GuildDataCache.addGuildDonate(-_needDonate)
		-- 4.刷新UI
		GuildMainLayer.refreshGuildAttr()
		require "script/ui/guild/guildskill/GuildSkillAdminLayer"
		GuildSkillAdminLayer.updateUI()
		-- 刷新军团成员科技列表
		require "script/ui/guild/guildskill/GuildSkillLayer"
		GuildSkillLayer.updateSkillTableView()

		if pCallback then
			pCallback()
		end
	end
	-- 向后端发送请求
	GuildSkillService.promote(pSkillId,kPromoteGroup,requestCallback)
end