-- FileName: GuildWarMainService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  GuildWarMainService 跨服军团战接口模块

module("GuildWarMainService", package.seeall)
require "script/ui/guildWar/GuildWarMainData"
-- /**
-- * 进入
-- * 
-- * @return 'ok':sting						进入成功
-- */
function enter(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.enter", "guildwar.enter", nil, true)
end

-- /**
-- * 退出
-- * @return 'ok':sting						退出成功
-- */
function leave(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.leave", "guildwar.leave", nil, true)
end

-- /**
-- * 报名
-- *
-- * @return 'ok':sting						报名成功
-- */
function signUp(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if dictData.ret == "already" then
				require "script/ui/tip/AnimationTip"
				AnimationTip.showTip(GetLocalizeStringBy("lcyx_174"))
				return
			end
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	Network.rpc(requestFunc, "guildwar.signUp", "guildwar.signUp", nil, true)
end

-- /**
-- * 获取用户的跨服军团战信息
-- *
-- * @return array							跨服军团战信息
-- *{
-- *		ret:	 							no表示本服务器不在分组内|ok表示在一个分组内
-- *		session: 							当前是第几届，如果当前没开启新的一届，返回上一届
-- *		sign_time：							本军团的报名时间，未报名为 0
-- *		round								大轮次
-- *		sub_round							晋级赛中的小轮次:0,1,2,3,4
-- *		status								当前轮次状态
-- * 		cheer_guild_id: 					助威对象军团Id
-- * 		cheer_guild_server_id:				助威对象所在服务器Id
-- * 		cheer_round：						助威轮次
-- * 		buy_max_win_num：					当前最大连胜次数
-- * 		buy_max_win_time：					购买连胜次数时刻
-- * 		worship_time：						膜拜时刻
-- * 		fight_force:						战斗力
-- * 		update_fmt_time：					更新战斗力时刻
-- * 		server_id:							自己所在服务的id
-- *		sign_up_count:						报名人数
-- *}
-- */
function getUserGuildWarInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		-- local dictData = {
		-- 	ret = {
		-- 			session               = "1",							
		-- 			sign_time             =	"1",					
		-- 			round                 =	"4",					
		-- 			sub_round             =	"1",	
		-- 			status                =	"100",
		-- 			sub_status			  = "100",				
		-- 			cheer_guild_id        = "1",				
		-- 			cheer_guild_server_id =	"1",		
		-- 			cheer_time            =	"1",					
		-- 			max_win_num           =	"1",				
		-- 			max_win_time          =	"1",				
		-- 			worship_time          =	"1",				
		-- 			fight_force           =	"1",				
		-- 			update_fmt_time       =	"1",
		-- 			server_id 			  = "20151"			
		-- 	},
		-- 	err = "ok"
		-- }
		if(dictData.err == "ok") then
			--设置跨服赛信息
			GuildWarMainData.setUserGuildWarInfo(dictData.ret)
			if dictData.ret.ret ~= "no" then
				--初始话数据
				GuildWarMainData.initate()
				--更新round
				GuildWarStageEvent.updateTime(true)
			end
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	-- requestFunc()
	Network.rpc(requestFunc, "guildwar.getUserGuildWarInfo", "guildwar.getUserGuildWarInfo", nil, true)
end

-- /**
-- * 拉取同组所有服
-- * 
-- * @return array
-- * [
-- * 		serverId => serverName				
-- * ]
-- */
function getMyTeamInfo(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		-- local dictData = {
		-- 	ret = {
		-- 		 ["20151"] = "小聪聪服务器",
		-- 		 ["15542"] = "小小葱服务器",
		-- 		 ["15522"] = "小大葱服务器",			
		-- 	},
		-- 	err = "ok"
		-- }
		if(dictData.err == "ok") then
			GuildWarMainData.setMyTeamInfo(dictData.ret)
			if(p_callback ~= nil) then
				p_callback()
			end
		end
	end
	-- requestFunc()
	Network.rpc(requestFunc, "guildwar.getMyTeamInfo", "guildwar.getMyTeamInfo", nil, true)
end

-- /**
-- * 注册跨服军团战状态推送接口
-- * push.guildwar.update
-- * array
-- * {
-- * 		round
-- * 		subRound
-- * 		status
-- * 		subStatus
-- * }
-- */
function registerStageChangePush( p_callback )
	local requestCallback = function ( callbackFlag, dictData, bSucceed )
		if(dictData.err == "ok") then
			local round     = tonumber(dictData.ret.round)
			local status    = tonumber(dictData.ret.status)
			local subRound  = tonumber(dictData.ret.sub_round)
			local subStatus = tonumber(dictData.ret.sub_status)
			if p_callback then
           		p_callback(round, status, subRound, subStatus)
           	end
		end
	end
	Network.re_rpc(requestCallback,"push.guildwar.update", "push.guildwar.update")
end

-- /**
-- * 移除跨服军团战状态推送接口
-- */
function removeStageChangePush( ... )
	Network.remove_re_rpc("push.guildwar.update")
end


