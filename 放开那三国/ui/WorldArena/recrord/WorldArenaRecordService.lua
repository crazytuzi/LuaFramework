-- FileName: WorldArenaRecordService.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 战报 网络接口
--[[TODO List]]

module("WorldArenaRecordService", package.seeall)

-- /**
-- * 获得战报列表
-- * 
-- * @return array
-- * {
-- * 		my => array
-- * 		[
-- * 			{
-- * 				attacker_server_id		攻方服务器id
-- * 				attacker_server_name	攻方服名字
-- * 				attacker_pid			攻方pid
-- * 				attacker_uname			攻方名字
-- * 				attacker_htid			攻方htid
-- * 				attacker_rank			攻方名次
-- * 				attacker_conti          攻方连胜次数
-- * 				attacker_terminal_conti 攻方终结对方连胜次数
-- * 				defender_server_id		守方服务器id
-- * 				defender_server_name	守方服名字
-- * 				defender_pid			守方pid
-- * 				defender_uname			守方名字
-- * 				defender_htid			守方htid
-- * 				defender_rank			守方名次
-- * 				defender_conti          守方连胜次数
-- * 				defender_terminal_conti 守方终结对方连胜次数
-- * 				attack_time				攻击时间
-- * 				result					结果，1代表攻方胜，0代表守方胜
-- * 				brid					战报id
-- * 			}
-- * 		]
-- * 		conti => array
-- * 		[
-- * 			{
-- * 				结构同上
-- * 			}
-- * 		]
-- * }
-- */
function getRecordList( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getRecordList-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldarena.getRecordList","worldarena.getRecordList",nil,true)
end
	
-- /**
-- * 获得跨服竞技场战报数据
-- */
function getRecord(p_brid, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getRecord-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_brid })
	Network.rpc(requestFunc,"battle.getRecord","battle.getRecord",args,true)
end