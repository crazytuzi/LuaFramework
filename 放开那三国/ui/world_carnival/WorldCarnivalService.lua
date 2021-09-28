-- Filename: WorldCarnivalService.lua
-- Author: bzx
-- Date: 2014-08-27
-- Purpose: 跨服嘉年华网络层

module("WorldCarnivalService", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalData"

-- /**
--  * 获得基本信息
--  * 
--  * @return array
--  * {
--  * 		ret								请求状态，取值范围： 'fighter'参数者/'watcher'围观者/'invalid'非法人群，***如果为'invalid'，则没有下面的字段***
--  * 		round							大轮次，取值范围：1 ：A组比赛  / 2 ：B组比赛  / 3 ： 决赛
--  * 		status							大轮次状态，取值范围：10 ：正在比赛  / 100 ： 比赛结束				
--  * 		sub_round						小轮次，取值范围：1-5
--  * 		sub_status						状态，取值范围：10 ：正在比赛/100 ：比赛结束
--	* 		next_fight_time					后端计算好的下次战斗的时间
--  *		normal_period 					正常小轮比赛间隔
--  *		final_period 					决赛前间隔
--  * 		fighters						参赛者基本信息
--  * 		{
--  * 			pos => array
--  * 				{
--  * 					rank
--  * 					server_id
--  * 					server_name
--  * 					pid
--  * 					uname
--  * 					htid
--  * 					level
--  * 					vip
--  * 					fight_force
--  * 					dress
--  * 				}
--  * 		}
--  * }
--  */
function getCarnivalInfo(p_callback)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		WorldCarnivalData.setCarnivalInfo(dictData.ret)
		if p_callback ~= nil then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(rpcCallback, "worldcarnival.getCarnivalInfo", "worldcarnival.getCarnivalInfo", nil, true)
	-- local data = {
	-- 	err = "ok",
	-- 	ret = {
	-- 		ret	= 'fighter',
	-- 		round = "1",
	-- 		status = "1",
	-- 		sub_round = "1",
	-- 		sub_status = "100",
	-- 		begin_time = TimeUtil.getSvrTimeByOffset() + 30,
	-- 		period = "300",
	-- 		fighters = {
	-- 			["1"] = {
	-- 				rank = "1",
	-- 				server_id = "12",
	-- 				server_name = "风云争霸",
	-- 				pid = "1213",
	-- 				uname = "大魔头",
	-- 				htid = "20001",
	-- 				level = "13",
	-- 				vip = "8",
	-- 				fight_force = "188888",
	-- 				dress = {["1"] = "80001",}
	-- 			},
	-- 			["2"] = {
	-- 				rank = "4",
	-- 				server_id = "12",
	-- 				server_name = "风云争霸",
	-- 				pid = "1213",
	-- 				uname = "大魔头",
	-- 				htid = "20001",
	-- 				level = "13",
	-- 				vip = "8",
	-- 				fight_force = "188888",
	-- 				dress = {["1"] = "80001",}
	-- 			},
	-- 			["3"] = {
	-- 				rank = "4",
	-- 				server_id = "12",
	-- 				server_name = "风云争霸",
	-- 				pid = "1213",
	-- 				uname = "大魔头",
	-- 				htid = "20001",
	-- 				level = "13",
	-- 				vip = "8",
	-- 				fight_force = "188888",
	-- 				dress = {["1"] = "80001",}
	-- 			},
	-- 			["4"] = {
	-- 				rank = "2",
	-- 				server_id = "12",
	-- 				server_name = "风云争霸",
	-- 				pid = "1213",
	-- 				uname = "大魔头",
	-- 				htid = "20001",
	-- 				level = "13",
	-- 				vip = "8",
	-- 				fight_force = "188888",
	-- 				dress = {["1"] = "80001",}
	-- 			}
	-- 		},
	-- 	}
	-- }
	-- rpcCallback(nil, data, true)
end

-- /**
--  * 更新战斗信息
--  * 
--  * @return 'ok'更新成功/'invalid'非参赛者
--  */
function updateFmt(p_callback)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if p_callback ~= nil then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(rpcCallback, "worldcarnival.updateFmt", "worldcarnival.updateFmt", nil, true)
	-- local data = {
	-- 	err = "ok",
	-- 	ret = "ok",
	-- }
	-- rpcCallback(nil, data, true)
end

-- /**
--  * 
--  * @param int $round				大轮次，取值范围：1 A组比赛/2 B组比赛/3 决赛
--  * @return array
--  * [
--  * 		{
--  * 			attacker_pos			攻方位置
--  * 			defender_pos			守方位置
--  * 			result					结果：1 攻方胜利，0攻方失败
-- 	* 			brid 					战报id
--  * 		}
--  * ]
--  */
function getRecord(p_callback, p_round)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		WorldCarnivalData.initReportInfo(dictData.ret, p_round)
		if p_callback ~= nil then
			p_callback(dictData.ret)
		end
	end
	local param = Network.argsHandler(p_round)
	Network.rpc(rpcCallback, "worldcarnival.getRecord", "worldcarnival.getRecord", param, true)
	-- local data = {
	-- 	err = "ok",
	-- 	ret = {
	-- 		{
	-- 			attacker_pos = "1",
	-- 			defender_pos = "2",
	-- 			result = "1",
	-- 		},
	-- 		{
	-- 			attacker_pos = "1",
	-- 			defender_pos = "2",
	-- 			result = "1",
	-- 		},
	-- 		{
	-- 			attacker_pos = "1",
	-- 			defender_pos = "2",
	-- 			result = "0",
	-- 		}
	-- 	}
	-- }
	-- rpcCallback(nil, data, true)
end

-- /**
--  * 获得参赛者的阵容信息
--  * 
--  * @param int $aServerId
--  * @param int $aPid
--  */
function getFighterDetail(p_callback, aServerId, aPid)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if p_callback ~= nil then
			p_callback(cbFlag, dictData, bRet)
		end
	end
	local param = Network.argsHandler(aServerId, aPid)
	Network.rpc(rpcCallback, "worldcarnival.getFighterDetail", "worldcarnival.getFighterDetail", param, true)
end

-- array
-- {
-- 	round
-- 	status
-- 	sub_round
-- 	sub_status
-- 	win_pos
-- }
function re_worldcarnival_update()
	btimport "script/ui/world_carnival/WorldCarnivalEventDispatcher"
	local rpcCallback = function(cbFlag, dictData, bRet)
		if not bRet then
			return
		end
		local round = tonumber(dictData.ret.round)
		local status = tonumber(dictData.ret.status)
		local subRound = tonumber(dictData.ret.sub_round)
		local subStatus = tonumber(dictData.ret.sub_status)
		if status == WorldCarnivalConstant.STATUS_DONE then
			WorldCarnivalData.heroPromotion(dictData.ret.win_pos)
		end
		if subStatus == WorldCarnivalConstant.STATUS_DONE then 
			WorldCarnivalData.setNextSubRoundStartTime(dictData.ret.next_fight_time)
		end
		WorldCarnivalEventDispatcher.statusChange(round, status, subRound, subStatus)
	end
	Network.re_rpc(rpcCallback, "push.worldcarnival.update", "push.worldcarnival.update")
end