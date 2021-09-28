-- FileName: GuildWarPromotionService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarPromotionService 跨服军团战接口模块

module("GuildWarPromotionService", package.seeall)

require "script/ui/guildWar/promotion/GuildWarPromotionData"

-- /**
-- * 获取军团跨服战信息(和本服分在一组的所有军团列表)
-- *
-- * @return array							跨服战信息
-- * [
-- * 	    {
-- * 			index:							军团显示的位置顺序
-- * 			guild_id：						军团Id
-- * 			guild_name：						军团名
-- * 			guild_server_id：				军团所在的服务器Id
-- * 			guild_server_name：				军团所在的服务器名称
-- * 			sign_time：						报名时间
-- * 			final_rank:						最终名次
-- * 			fight_force:					战斗力
-- * 			guild_level:					军团等级
-- * 			guild_badge:					军团军旗
-- *     }
-- * ]
-- * </code>
-- */
function getGuildWarInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		GuildWarPromotionData.setGuildWarInfo(dictData.ret)
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildwar.getGuildWarInfo", "guildwar.getGuildWarInfo", nil, true)
	-- test
	-- local data = {}
	-- data.ret = {
	-- 	{
 --  			index 				= "1",						-- 军团显示的位置顺序
 --  			guild_id 			= "1232",					-- 军团Id
 --  			guild_name 			= "军团名称1",			-- 军团名
 --  			guild_server_id  	= "1",						-- 军团所在的服务器Id
 --  			guild_server_name 	= "服务器名称",			-- 军团所在的服务器名称
 --  			sign_time			= "1232",					-- 报名时间
 --  			final_rank			= "16",						-- 最终名次
 --  			fight_force			= "43433",					-- 战斗力
 --  			guild_level 		= "23",						-- 军团等级
 --  			guild_badge 		= "3",						-- 军团军旗			
 --    	},
 --    	{
 --  			index 				= "2",						-- 军团显示的位置顺序
 --  			guild_id 			= "1232",					-- 军团Id
 --  			guild_name 			= "军团名称1",			-- 军团名
 --  			guild_server_id  	= "1",						-- 军团所在的服务器Id
 --  			guild_server_name 	= "服务器名称",			-- 军团所在的服务器名称
 --  			sign_time			= "1232",					-- 报名时间
 --  			final_rank			= "16",						-- 最终名次
 --  			fight_force			= "43433",					-- 战斗力
 --  			guild_level 		= "23",						-- 军团等级
 --  			guild_badge 		= "3",						-- 军团军旗			
 --    	},
 --    	{
 --  			index 				= "8",						-- 军团显示的位置顺序
 --  			guild_id 			= tostring(GuildDataCache.getMineSigleGuildId()),					-- 军团Id
 --  			guild_name 			= "军团名称1",			-- 军团名
 --  			guild_server_id  	= tostring(GuildWarMainData.getMyServerId()),						-- 军团所在的服务器Id
 --  			guild_server_name 	= "服务器名称",			-- 军团所在的服务器名称
 --  			sign_time			= "1232",					-- 报名时间
 --  			final_rank			= "16",						-- 最终名次
 --  			fight_force			= "43433",					-- 战斗力
 --  			guild_level 		= "23",						-- 军团等级
 --  			guild_badge 		= "3",						-- 军团军旗			
 --    	}
	-- }
	-- requestFunc(nil, data, true)
end


-- /**
-- * 购买连胜次数，只能在晋级赛购买
-- *
-- * @return 'ok':string						购买成功
-- */
function buyMaxWinTimes(p_callback)
 	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildwar.buyMaxWinTimes", "guildwar.buyMaxWinTimes", nil, true)
	--requestFunc(nil, nil, true)
end