-- FileName: WorldArenaMainService.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决 主要接口
--[[TODO List]]

module("WorldArenaMainService", package.seeall)

-- /**
-- * 拉取基础信息
-- * 
-- * @return array
-- * {
-- * 		ret								请求状态，取值范围： 'ok'
-- * 		stage							所处阶段，取值范围：'before_signup','signup','range_room','attack','reward'
-- * 		team_id							分组id，没分组则为0
-- * 		room_id							房间id，没分房则为0
-- * 		pid								返给前端自己的Pid
-- * 		signup_time						报名时间，没报名则为0
-- * 		period_bgn_time					周期开始时间
-- * 		period_end_time					周期结束时间
-- * 		signup_bgn_time					报名开始时间
-- * 		signup_end_time					报名结束时间
-- * 		attack_bgn_time					攻打开始时间
-- * 		attack_end_time					攻打结束时间
-- * 		extra							扩展信息，可以取如下值,处于不同阶段时候，这个字段的key不同
-- * 		{
-- * 			[stage为before_signup时候取如下值:]
-- * 			空
-- * 			
-- * 			[stage为signup时候取如下值:]
-- * 			update_fmt_time				更新战斗信息时间
-- * 
-- * 			[stage为range_room时候取如下值:]
-- * 			空
-- * 			
-- * 			[stage为attack时候取如下值:]
-- * 			atk_num						当前剩余的攻击次数 
-- * 			buy_atk_num					已经购买的攻击次数
-- * 			silver_reset_num			银币重置次数
-- * 			gold_reset_num				金币重置次数
-- * 			kill_num					玩家的击杀总数
-- * 			cur_conti_num				玩家当前的连杀数
-- * 			max_conti_num				玩家最大的连杀数
-- * 			last_attack_time    		上次主动挑战时间
-- * 			player						玩家列表，包括对手和自己，按照pos排序
-- * 			[	
-- * 				pos => array
-- * 				{
-- * 					server_id
-- * 					server_name
-- * 					pid
-- * 					uname
-- * 					htid
-- * 					level
-- * 					vip
-- * 					fight_force
-- * 					dress
-- * 					hp_percent			以10000作为基地
-- * 					protect_time
-- * 					self				如果是自己为1，别人为0
-- *				
-- * 				}
-- * 			]
-- * 
-- * 			[stage为reward时候取如下值:]
-- * 			空
-- * 		}
-- * }
-- */
function getWorldArenaInfo( p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--getWorldArenaInfo-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldarena.getWorldArenaInfo","worldarena.getWorldArenaInfo",nil,true)
end
	
-- /**
-- * 玩家报名
-- * 
-- * @return	int							返回玩家报名时间
-- */
function signUp( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--signUp-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldarena.signUp","worldarena.signUp",nil,true)
end
	
-- /**
-- * 更新战斗信息
-- * 
-- * @return	int							返回玩家更新战斗力的时间
-- */
function updateFmt( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--updateFmt-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldarena.updateFmt","worldarena.updateFmt",nil,true)
end
	
-- /**
-- * 攻击某个排名的玩家
-- * 
-- * @param int $serverId
-- * @param int $pid
-- * @param int $skip
-- * @return array
-- * {
-- * 		ret								请求状态，取值范围： 'ok'正常/'out_range'对手和自己的相对排名变化超出范围/'protect'对方在保护时间内
-- * 
-- * 		以下字段和getWorldArenaInfo中返回的相同
-- * 		atk_num							当前剩余的攻击次数 
-- * 		buy_atk_num						已经购买的攻击次数
-- * 		silver_reset_num				银币重置次数
-- * 		gold_reset_num					金币重置次数
-- * 		kill_num						玩家的击杀总数
-- * 		cur_conti_num					玩家当前的连杀数
-- * 		max_conti_num					玩家最大的连杀数
-- * 		player							玩家列表，包括对手和自己，按照pos排序
-- * 		[	
-- * 			pos => array
-- * 			{
-- * 				server_id
-- * 				server_name
-- * 				pid
-- * 				uname
-- * 				htid
-- * 				level
-- * 				vip
-- * 				fight_force
-- * 				dress
-- * 				hp_percent				以10000作为基地
-- * 				protect_time
-- * 				self					如果是自己为1，别人为0
-- * 			}
-- * 		]
-- * 		
-- * 		以下字段只有在ret为ok的时候才有的字段
-- * 		appraisal						战斗评价
-- * 		fightRet						战斗串，不是跳过战斗的情况下才有这个值
-- * 		reward							各种奖励
-- * 		{
-- * 			lose_reward					输了的时候的奖励
-- * 
-- * 			win_reward					打赢对手的奖励，普通奖励
-- * 			conti_reward				打赢对手的奖励，连杀的奖励
-- * 			terminal_conti_reward		打赢对手的奖励，终结连杀奖励
-- * 		}
-- * 		terminal_conti_num				如果胜利的话，而且终结了对方的连胜，这个值是终结的对方的连胜值						
-- * }
-- */
function attack( p_serverId, p_pid, p_skip, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--attack-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_serverId, p_pid, p_skip })
	Network.rpc(requestFunc,"worldarena.attack","worldarena.attack",args,true)
end
	
-- /**
-- * 购买攻击次数
-- * 
-- * @param int $num
-- * @return num
-- */
function buyAtkNum(p_num, p_callBack)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--buyAtkNum-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ tonumber(p_num) })
	Network.rpc(requestFunc,"worldarena.buyAtkNum","worldarena.buyAtkNum",args,true)
end
	
-- /**
-- * 重置，包含更新战斗信息，回满血
-- * 
-- * @param str $type 					取值如下：'silver'银币重置/'gold'金币重置 
-- * @return 'ok'
-- */
function reset( p_type, p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			-- print("--------后端返回数据--reset-----------")
			-- print_t(dictData)
			if(p_callBack ~= nil)then
				p_callBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ p_type })
	Network.rpc(requestFunc,"worldarena.reset","worldarena.reset",args,true)
end
