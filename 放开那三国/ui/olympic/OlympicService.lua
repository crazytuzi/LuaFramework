-- Filename: OlympicService.lua
-- Author: lichenyang
-- Date: 2014-07-14
-- Purpose: 擂台争霸网络层

require "script/ui/olympic/OlympicData"
require "script/model/user/UserModel"

module("OlympicService",package.seeall)




-- /**
--  * 进入擂台争霸界面
--  */
function enterOlympic(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "olympic.enterOlympic", "olympic.enterOlympic", nil, true)
end

-- /**
-- * 离开擂台争霸界面
-- */
function leave(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "olympic.leave", "olympic.leave", nil, true)
end

-- /**
-- * 不同阶段返回不同的信息，每个阶段都返回的信息：当前进行到哪个阶段、此阶段的结束时间
-- * 三个不同的阶段返回的信息
-- * 1.比赛前阶段：奖池信息、上一届冠军
-- * 2.预选赛阶段：奖池信息、报名的32名玩家的信息、预选赛的战报信息
-- * 3.进16强赛-进4强赛阶段：奖池信息、报名的32名玩家的信息、进16强赛到进4强赛的战报数据
-- * 4.助威阶段到半决赛到决赛阶段到比赛后阶段：奖池信息、报名的32名玩家的信息、半决赛到决赛阶段的战报数据
-- *
-- * @return array
-- * <code>
-- * [
-- *     stage:int                当前的阶段
-- *     status:int               0是准备 1是开始了  2是超时  3是出现错误  4是结束了
-- *     stage_end_time:int        当前阶段的结束时间
-- *     silver_pool:int            奖池总的银币数量
-- *     last_champion:array        上一届冠军信息
-- *     challenge_cd:array        上一届冠军信息
-- *     [
-- *         uid:int
-- *         uname:int
-- *         dress:array
-- *         htid:int
-- *     ]
-- *     rank_list:array       报名的32个玩家的信息
-- *     [
-- *         uid=>array
-- *         [
-- *             sign_up_index:int    报名位置
-- *             olympic_index:int    比赛位置
-- *             final_rank:int        排名
-- *             uid:int
-- *             uname:int
-- *             dress:array
-- *             htid:int
-- *         ]
-- *     ]
-- *     fight_info:array        战斗数据
-- *     [
-- *         log_type=>array        log_type的取值 1.预选赛战报  2.16强战报  3.8强战报 4.4强战报  5.2强战报  6.冠军赛战报
-- *         [
-- *             array
-- *             [
-- *                 attacker:int
-- *                 defender:int
-- *                 brid:int
-- *                 result:string
-- *             ]
-- *         ]
-- *     ]
-- * ]
-- * </code>
-- */
function getInfo( p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			OlympicData.setInfo(dictData.ret )
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "olympic.getInfo", "olympic.getInfo", nil, true)
end

-- /**
-- * 获得整体战报
-- * 返回决赛的所有战报
-- * @return array
-- * <code>
-- * [
-- *     rank_list:array       报名的32个玩家的信息
-- *     [
-- *         uid=>array
-- *         [
-- *             sign_up_index:int    报名位置
-- *             olympic_index:int    比赛位置
-- *             final_rank:int        排名
-- *             uid:int
-- *             uname:int
-- *             dress:array
-- *             htid:int
-- *         ]
-- *     ]
-- *     fight_info:array        战斗数据
-- *     [
-- *         log_type=>array        log_type的取值 1.预选赛战报  2.16强战报  3.8强战报 4.4强战报  5.2强战报  6.冠军赛战报
-- *         [
-- *             array
-- *             [
-- *                 attacker:int
-- *                 defender:int
-- *                 brid:int
-- *                 result:string
-- *             ]
-- *         ]
-- *     ]
-- * ]
-- * </code>
-- */
function getFightInfo(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			OlympicData.setBattleReportInfo(dictData.ret )
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "olympic.getFightInfo", "olympic.getFightInfo", nil, true)
end

-- /**
--  * 报名
--  */
function signUp(p_index, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			--扣除报名费用
			UserModel.addSilverNumber(-OlympicData.getJoinCostSilver())
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_index))
	Network.rpc(requestFunc, "olympic.signUp", "olympic.signUp", args, true)
end

-- /**
-- * 挑战:决赛名额不满32时，能不能挑战
-- * @param
-- * @return array
-- * [
-- *     res:string 战斗结果
-- *     fight_ret:string 战报
-- *     userInfo:array 用户的信息     
-- * ]
-- */
function challenge( p_signIndex, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			--扣除挑战金币
			UserModel.addSilverNumber(-OlympicData.getChallengeCostSilver())
			if(string.upper(dictData.ret.res) ~= "F" and string.upper(dictData.ret.res) ~= "E") then
				for k,v in pairs(dictData.ret.userInfo) do
					v.sign_up_index = p_signIndex
					OlympicData.updateUserInfo(v)
				end
			end
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret.fight_ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_signIndex))
	Network.rpc(requestFunc, "olympic.challenge", "olympic.challenge", args, true)
end

-- /**
-- * 清除挑战Cd
-- * @return array
-- * <code>
-- * [
-- *  'gold' => int 扣除金币
-- * ]
-- * </code>
-- */
function clearChallengeCd(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			local spendGold = tonumber(dictData.ret.gold)
			UserModel.addGoldNumber(-spendGold)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(spendGold)
			end
		end
	end
	local args = CCArray:create()
	Network.rpc(requestFunc, "olympic.clearChallengeCd", "olympic.clearChallengeCd", nil, true)
end

-- /**
-- * 所有成功进入决赛的玩家不可点击助威. 失败了也不行吗？     进入32强的玩家无法助威
-- * 每个玩家只允许助威1个玩家,助威后不可撤销
-- * @parm  : p_cheerUid
-- * @return string 'ok'
-- */
function cheer(p_cheerUid)

end

----------------------------------------------[[ 推送接口 ]]---------------------------------
--[[
	@des 	:报名推送，如果有玩家报名则推送此接口
	@param 	:pos 玩家报名的位置
	@return :
        user_info:
        [
            sign_up_index:int    报名位置
            olympic_index:int    比赛位置
            final_rank:int        排名
            uid:int
            uname:int
            dress:array
            htid:int
        ]
    ]
]]
function registerSignupPush( p_callback )
	local requestCallback = function ( callbackFlag, dictReciveData, bSucceed )
		OlympicData.updateUserInfo(dictReciveData.ret)
		if(p_callback ~= nil) then
			p_callback( tonumber(dictReciveData.ret.sign_up_index) )
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.signup", "push.olympic.signup")
end

--[[
	@des 	:擂台争霸战报推送
	@return :
	{
		attacker:int
	    defender:int
	    brid:int
	    result:string
	    stage:int
	}
	@callbac parma  array olympicPos 晋级的玩家的比赛位置数组
	@callbac parma  array battleReports 所有的战报列表
 --]]
function registerBattleRecordPush( p_callback )
	local requestCallback = function ( callbackFlag, dictReciveData, bSucceed )
		OlympicData.addBattleInfo(dictReciveData.ret) -- 添加战报信息
		local olympicIndexs = {}
		for k,v in ipairs(dictReciveData.ret) do
			if(OlympicData.getStage() > OlympicData.kGroupStage) then
				OlympicData.updateUserInfoByBattleInfo(v)
				local userInfo = OlympicData.getUserInfoByBattleInfo(v)
				table.insert(olympicIndexs, tonumber(userInfo.olympic_index))
			end
		end
		if(p_callback ~= nil) then
			p_callback(olympicIndexs, dictReciveData.ret)
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.battlerecord", "push.olympic.battlerecord")
end

--[[
	@des 	:推送的阶段id是
	@return :
	{
		stage:int
	}
 --]]
function regisgerStagechangePush( p_callback )
	local requestCallback = function ( callbackFlag, dictReciveData, bSucceed )
		OlympicData.setStage(tonumber(dictReciveData.ret.stage))
		OlympicData.updateUserInfoByOlympicStage(tonumber(dictReciveData.ret.stage))	
		if(p_callback ~= nil) then
			p_callback( tonumber(dictReciveData.ret.stage) )
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.stagechange", "push.olympic.stagechange")
end

-------------------------刷新助威 ----------------------------

function re_olympic_refreshCheerUp( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			if(MainScene.getOnRunningLayerSign() == "Olympic4Layer")then
				--加数据
				print("收到推送————————————————————————————————————————————————————————————————")
				OlympicData.addPlayerCheerNum(dictData.ret.cheer_uid)
				p_callback(tonumber(dictData.ret.cheer_uid))
			end
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.cheer", "push.olympic.cheer")
end


function registerChallengeBattlePush( p_callback )
	local requestCallback = function ( callbackFlag, dictReciveData, bSucceed )
		OlympicData.updateChallengeBattleInfo(dictReciveData.ret)
		if(p_callback) then
			p_callback({}, dictReciveData.ret)
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.challenge", "push.olympic.challenge")
end

-------------------------刷新奖池 ----------------------------
function re_olympic_refreshSilverPool( p_callback )
	local requestCallback = function ( cbFlag, dictData, bRet )
		if (dictData.err == "ok") then
			--加数据
			print("收到奖池推送————")
			print_t(dictData)
			--如果阶段8，推新的奖池金额
			if OlympicData.getStage() == OlympicData.kAfterStage then
				print("奖池阶段8推送")
				OlympicData.setSilverPoolNum(dictData.ret.totalSilverPool)
			--普通阶段推奖池增量
			else
				print("普通推送")
				OlympicData.addSilverPoolNum(dictData.ret.addSilverPool)
			end
			p_callback()
		end
	end
	Network.re_rpc(requestCallback, "push.olympic.silverpool", "push.olympic.silverpool")
end