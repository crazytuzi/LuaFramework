-- FileName: GuildWarReportService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarReportService 跨服军团战战报接口模块信息

module("GuildWarReportService", package.seeall)

require "script/ui/guildWar/report/GuildWarReportData"

-- /**
-- * 查看战绩(获取自己军团跨服或者海选的所有战斗信息)
-- *
-- * @return array                        	战绩
-- * {
-- * 		self => array
-- * 		{
-- * 			guild_id						 军团Id
-- * 			guild_name						军团名称
-- * 			guild_server_id					服务器Id
-- * 			guild_server_name				服务器名称
-- * 		}
-- * 
-- * 		audition => array 					海选战报,以数据作为轮数
-- * 		[
-- * 			{
-- * 				replay_id
-- * 				result						战斗结果：1胜利，0失败
-- * 				attacker => array			攻方信息，如果是自己，则为空数组
-- * 				{
-- *					guild_id				军团Id
-- *					guild_name				军团名称
-- *					guild_server_id			服务器Id
-- *					guild_server_name		服务器名称
-- *				}
-- * 				defender => array			防方信息，如果为自己，则为空数组
-- * 				{
-- *					guild_id				军团Id
-- *					guild_name				军团名称
-- *					guild_server_id			服务器Id
-- *					guild_server_name		服务器名称
-- *				}
-- * 			}
-- * 		]								
-- *
-- * 		finals => array 					晋级赛战报
-- * 		[
-- * 			round => array					轮次做key    例如：8强赛(3)，4强赛(4)，半决赛(5)，决赛(6)
-- * 			{
-- *				result						战斗结果：1胜利，0失败
-- * 				attacker => array
-- * 				{
-- * 					guild_id
-- * 					guild_name
-- * 					guild_server_id
-- * 					guild_server_name
-- * 				}
-- * 				defender => array
-- * 				{
-- * 					guild_id
-- * 					guild_name
-- * 					guild_server_id
-- * 					guild_server_name
-- * 				}
-- * 				sub_round => array
-- * 				[
-- * 					{
-- * 						replay_id
-- * 					}
-- * 				]
-- * 			}
-- * 		]									
-- * }
-- */
function getHistoryFightInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			GuildWarReportData.setMainReportInfo(dictData.ret)

			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.getHistoryFightInfo", "guildwar.getHistoryFightInfo",nil, true)
end

-- /**
--  * 查看晋级赛之间任意战报
--  *
--  * @param $guildId01						军团01的Id
--  * @param $serverId01						军团01的服务器Id
--  * @param $guildId02						军团02的Id
--  * @param $serverId02						军团02的服务器Id
--  *
--  * @return array                        	战绩
--  * {	
--  * 		result								战斗结果：2胜利，0失败
--  *		attacker => array 					军团01的信息					
--  *		{
--  *			guild_id
--  *			guild_name
--  *			guild_server_id
--  *			guild_server_name
--  *			guild_badge						
--  *			member => array				
--  *			[
--  *				{
--  *					state					标记这个玩家是否能战斗,0无法战斗1可以战斗
--  *					htid
--  *					uname
--  *					fight_force
--  *				}
--  *			]
--  *		}									
--  *		defender:							同 attacker
--  *		sub_round => array
--  * 		[
--  * 			{
--  * 				replay_id
--  * 				arrProcess
--  * 			}
--  * 		]
--  * 		left_user => array
--  * 		[
--  * 			sub_round_index => array
--  * 			{
--  * 				[
--  * 					htid
--  * 					uname
--  * 					fight_force
--  * 				]
--  * 			}
--  * 		]			
--  * }
--  */
function getReplay(p_guildId01, p_serverId01, p_guildId02, p_serverId02, p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			-- 保存数据
			GuildWarReportData.setReportData(dictData.ret)

			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_guildId01))
	args:addObject(CCInteger:create(p_serverId01))
	args:addObject(CCInteger:create(p_guildId02))
	args:addObject(CCInteger:create(p_serverId02))
	Network.rpc(requestFunc, "guildwar.getReplay", "guildwar.getReplay", args, true)
end

-- /**
-- * 根据主战报获取子战报详细信息
-- * 
-- * @param array $arrReplayId
-- * @return array
-- * [
-- * 		replay_id => array
-- * 		{
-- * 			atk_server_id
-- * 			atk_guild_id
-- * 			def_server_id
-- * 			def_guild_id
-- * 			userList => array
-- * 			{
-- * 				uid => {uname, fight_force}
-- * 			}
-- * 			arrProcess => array
-- * 			[
-- * 				{
-- * 					result							战斗结果：1胜利，0失败
-- * 					brid							战报Id
-- * 					atk_uid							攻方玩家uid
-- * 					def_uid							防守玩家uid
-- * 					atk_max_win						攻方连胜次数，只有在此玩家下场时，才有这个字段
-- * 					def_max_win	 					守方连胜次数，只有在此玩家下场时，才有这个字段
-- * 				}
-- * 			]
-- * 		}
-- * ]
-- * 
-- */
function getReplayDetail(p_arrReplayIds, p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			GuildWarReportData.setAndSortDetailReportInfo(dictData.ret)
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	local goArgs = CCArray:create()
	local args = CCArray:create()
	for k,v in pairs(p_arrReplayIds) do
		args:addObject(CCString:create(v))
	end

	goArgs:addObject(args)
	Network.rpc(requestFunc, "guildwar.getReplayDetail", "guildwar.getReplayDetail", goArgs, true)
end