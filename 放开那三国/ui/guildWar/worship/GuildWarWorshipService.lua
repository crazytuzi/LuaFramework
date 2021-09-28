-- FileName: GuildWarWorshipService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarWorshipService 跨服军团战接口模块

module("GuildWarWorshipService", package.seeall)

require "script/ui/guildWar/worship/GuildWarWorshipData"

-- /**
--  * 获取膜拜神殿信息
--  *
--  * @return array
--  * {
--  * 		session:							届数
--  * 		guild_id							军团Id
--  * 		guild_name							军团名称
--  * 		guild_server_id						服务器Id
--  * 		guild_server_name					服务器名称
--  * 		guild_badge							军团徽章Id
--  * 		president_uname						军团长名称
--  * 		president_htid						军团长主角形象
--  *      president_level						军团长等级
--  *      president_vip_level					军团长vip等级
--  *      president_fight_force				军团长战斗力
--  *      president_dress						军团长时装信息
--  * }
--  */
function getTempleInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			GuildWarWorshipData.setTempleInfo(dictData.ret)
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.getTempleInfo", "guildwar.getTempleInfo", nil, true)
end	

-- /**
--  * 膜拜
--  *
--  * @param $type      						膜拜种类 取值1,2,3
--  *
--  * @return ok								膜拜成功
--  */
function worship(p_type, p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_type))
	Network.rpc(requestFunc, "guildwar.worship", "guildwar.worship", args, true)
end

