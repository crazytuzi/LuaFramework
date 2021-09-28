-- Filename: GuildWarWorshipData.lua
-- Author: lichenyang
-- Date: 2015-01-20
-- Purpose: 个人跨服赛数据层

module("GuildWarWorshipData", package.seeall)


local _templeInfo = nil

function setTempleInfo( p_info )
	_templeInfo = p_info
end

function getTempleInfo( p_info )

	-- local tempInfo = {}

	-- tempInfo.guild_id              = "001"						--	军团Id
	-- tempInfo.guild_name            = "13222"					--	军团名称
	-- tempInfo.server_id             = "game001"					--	服务器Id
	-- tempInfo.server_name           = "剑问鱼肠"					--	服务器名称
	-- tempInfo.president_uname       = "冠军军团长"					--	军团长名称
	-- tempInfo.president_htid        = 20109						--	军团长主角形象
	-- tempInfo.president_level       = "99"						-- 	军团长等级
	-- tempInfo.president_vip_level   = "13"						--	军团长vip等级
	-- tempInfo.President_fight_force = "999999" 					--	军团长战斗力
	-- tempInfo.president_dress 	   = {["1"] = 80001}				--	时装信息
	-- return tempInfo
	return _templeInfo
end
-- --返回膜拜对应的tag的酒需要的消耗
-- --返回值 1：类型 2：数量   类型：1 银币  2 金币 3 金币
-- function getCostByTag( p_tag )
-- 	p_tag = tonumber(p_tag)
-- 	local dbDataCacheCpy = DB_Kuafu_personchallenge.getDataById(1)
-- 	local dbDataArryCpy = string.split(dbDataCacheCpy.wishCost,",")
-- 	local partDbDataArryCpy = string.split(dbDataArryCpy[p_tag],"|")
-- 	print("costtype，costnum",partDbDataArryCpy[1],partDbDataArryCpy[3])
-- 	return tonumber(partDbDataArryCpy[1]),tonumber(partDbDataArryCpy[3])
-- end
-- --判断膜拜需要的消耗是否足够
-- --返回值：1.需要的消耗是否足够 2.消耗的类型
-- function isCostEnough(p_tag )
-- 	local costType,num = getCostByTag(p_tag)
-- 	local isEnough = false
-- 	if(costType == 2 or costType == 3)then
-- 		if (UserModel.getGoldNumber() >= num)then
-- 			isEnough = true
-- 		else
-- 			isEnough = false
-- 		end
-- 	elseif(costType == 1)then
-- 		if(UserModel.getSilverNumber() >= num)then
-- 			isEnough = true
-- 		else
-- 			isEnough = false
-- 		end
-- 	end
-- 	return isEnough,costType
-- end
--根据tag获取本次膜拜需要的银币
function getSilverCostByTag(p_tag)
	p_tag = tonumber(p_tag)
	local numResult = 0
	local dbDataCacheCpy = DB_Kuafu_personchallenge.getDataById(1)
	local dbDataArryCpy = string.split(dbDataCacheCpy.wishCost,",")
	local partDbDataArryCpy = string.split(dbDataArryCpy[p_tag],"|")
	--print("costtype，costnum",partDbDataArryCpy[1],partDbDataArryCpy[3])
	if(tonumber(partDbDataArryCpy[1]) == 1)then
		numResult = tonumber(partDbDataArryCpy[3])
	end
	return numResult
end
--根据tag获取本次膜拜需要的金币
function getGoldCostByTag(p_tag)
	p_tag = tonumber(p_tag)
	local numResult = 0
	local dbDataCacheCpy = DB_Kuafu_personchallenge.getDataById(1)
	local dbDataArryCpy = string.split(dbDataCacheCpy.wishCost,",")
	local partDbDataArryCpy = string.split(dbDataArryCpy[p_tag],"|")
	--print("costtype，costnum",partDbDataArryCpy[1],partDbDataArryCpy[3])
	if(tonumber(partDbDataArryCpy[1]) == 2 or tonumber(partDbDataArryCpy[1]) == 3)then
		numResult = tonumber(partDbDataArryCpy[3])
	end
	return numResult
end



