
-- FileName: GuildWarSupportService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarSupportService 跨服军团战助威接口模块

module("GuildWarSupportService", package.seeall)

require "script/ui/guildWar/support/GuildWarSupportData"

-- /**
-- * 获取所有助威的历史数据
-- *
-- * @return array							自己所有的助威信息
-- * [
-- * 		round=>array 						第几轮
-- * 		{
-- * 			guildId:						军团Id
-- * 			guildName:						军团名字
-- * 			serverId:						服务器Id
-- * 			serverName						服务器名称
-- *			guildState:						0还未比赛|1比赛中|2晋级|3淘汰|
-- *			rewardState:					0没发助威奖|1已发助威奖
-- * 		}
-- * ]
-- */
function getHistoryCheerInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if bRet == true then
			-- local dictData = {
			-- 	ret = {
			-- 		["4"] = {
			-- 			guildId     = "1",
			-- 			guildName   = "小村村",
			-- 			serverId    = "122",
			-- 			serverName  = "1",
			-- 			guildState  = "1",
			-- 			rewardState = "1",
			-- 		},
			-- 		["5"] = {
			-- 			guildId     = "1",
			-- 			guildName   = "小村村2",
			-- 			serverId    = "122",
			-- 			serverName  = "1",
			-- 			guildState  = "0",
			-- 			rewardState = "1",
			-- 		},
			-- 		["6"] = {
			-- 			guildId     = "1",
			-- 			guildName   = "小村村3",
			-- 			serverId    = "122",
			-- 			serverName  = "1",
			-- 			guildState  = "2",
			-- 			rewardState = "1",
			-- 		},		
			-- 	},
			-- 	err = "ok",
			-- }
			GuildWarSupportData.setMySupportList(dictData.ret)
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.getHistoryCheerInfo", "guildwar.getHistoryCheerInfo", nil, true)
end

-- /**
-- * 助威
-- *
-- * @param p_guildId							助威对象的Id
-- * @param p_serverId							助威对象的服务器Id
-- *
-- * @return 'ok'								助威成功
-- *         'directPromotion'					军团这一轮轮空，无需助威
-- */
function cheer(p_guildId, p_serverId, p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_guildId))
	args:addObject(CCInteger:create(p_serverId))
	Network.rpc(requestFunc, "guildwar.cheer", "guildwar.cheer", args, true)
end