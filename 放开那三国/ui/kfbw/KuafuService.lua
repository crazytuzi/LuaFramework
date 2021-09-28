-- FileName: KuafuService.lua 
-- Author: yangrui
-- Date: 15-09-29
-- Purpose: function description of module 

module("KuafuService", package.seeall)

require "script/network/Network"
require "script/ui/kfbw/KuafuData"

-- /**
--  * 获得基本信息
--  * @return array
--  * { 
--  * 		ret										'ok'/'no' 为no时代表这个服不在任何分组内,没有以下字段
--  * 		atk_num									挑战完成次数
--  * 		suc_num									挑战胜利次数
--  * 		buy_atk_num								挑战购买次数
--  * 		refresh_num								对手刷新次数
--  * 		worship_num								膜拜完成次数
--  * 	  	max_honor 								本次比武的最大荣誉
--  * 		cross_honor								累积比武的总荣誉
--  * 		begin_time								本次活动开始时间
--  * 		end_time								本次活动结束时间
--  * 		reward_end_time							发奖结束时间
--  * 		period_end_time							整个活动的结束时间
--  * 		rival									3个对手的信息
--  * 		{
--  * 			index => array
--  * 			{
--  * 				server_id
--  * 				server_name
--  * 				pid
--  * 				uname
--  * 				htid
--  * 				level
--  * 				vip
--  * 				fight_force
--  * 				dress
--  * 				status							status为0是失败,1是成功
--  * 			}
--  * 		}
--  * 		prize									已领取的奖励
--  * 		{
--  * 			index => sucNum						index从0开始,sucNum是胜利次数	
--  * 		}
--  * }
--  */
--  function getWorldCompeteInfo();
function getWorldCompeteInfo( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			-- 设置跨服比武信息
			KuafuData.setWorldCompeteInfo(pData.ret)
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	Network.rpc(callBack, "worldcompete.getWorldCompeteInfo", "worldcompete.getWorldCompeteInfo", nil, true)
end

-- /**
--  * 挑战
--  * 
--  * @param int $serverId
--  * @param int $pid
--  * @param int $crazy							是否狂怒模式，1是0否，默认1
--  * @param int $skip								是否跳过战斗，1是0否，默认1
--  * @return array
--  * {
--  * 		ret										'ok'
--  * 		appraisal								战斗评价
--  * 		fightRet								战斗串，不是跳过战斗的情况下才有这个值
--  * 		rival									3个对手的信息,3个对手都胜利的情况下返回
--  * 		{
--  * 			index => array
--  * 			{
--  * 				server_id
--  * 				server_name
--  * 				pid
--  * 				uname
--  * 				htid
--  * 				level
--  * 				vip
--  * 				fight_force
--  * 				dress
--  * 				status							status为0是失败,1是成功
--  * 			}
--  * 		}
--  * }
--  */
-- function attack($serverId, $pid, $crazy = 1, $skip = 1);
function attack( pServerId, pId, pCrazy, pSkip, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pServerId,pId,pCrazy,pSkip})
	Network.rpc(callBack, "worldcompete.attack", "worldcompete.attack", args, true)
end

-- /**
--  * 购买挑战次数
--  *
--  * @param int $num
--  * @return string 'ok'
--  */
-- function buyAtkNum($num);
function buyAtkNum( pNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		elseif pData.err == "not in activity" then
			AnimationTip.showTip(GetLocalizeStringBy("yr_2029"))
			return
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(callBack, "worldcompete.buyAtkNum", "worldcompete.buyAtkNum", args, true)
end

-- /**
--  * 刷新对手们
--  * 
--  * @return array
--  * {
--  * 		index => array
--  * 		{
--  * 			server_id
--  * 			server_name
--  * 			pid
--  * 			uname
--  * 			htid
--  * 			level
--  * 			vip
--  * 			fight_force
--  * 			dress
--  * 			status							status为0是失败,1是成功
--  * 		}		
--  * }
--  */
-- 	function refreshRival();
function refreshRival( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	Network.rpc(callBack, "worldcompete.refreshRival", "worldcompete.refreshRival", nil, true)
end

-- /**
--  * 领取胜场奖励
--  *
--  * @param int $num 胜利次数
--  * @return string 'ok'
--  */
-- function getPrize($num);
function getPrize( pNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		elseif pData.err == "not in activity" then
			AnimationTip.showTip(GetLocalizeStringBy("yr_2027"))
			return
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(callBack, "worldcompete.getPrize", "worldcompete.getPrize", args, true)
end

-- /**
--  * 膜拜
--  * 
--  * @return string 'ok'
--  */
-- function worship();
function worship( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		elseif pData.err == "not in reward" then
			AnimationTip.showTip(GetLocalizeStringBy("yr_2028"))
			return
		end
	end
	Network.rpc(callBack, "worldcompete.worship", "worldcompete.worship", nil, true)
end

-- /**
--  * 拉取排行榜信息
--  *
--  * @return array
--  * {
--  * 		inner => array
--  * 		{
--  * 			uid
--  * 			uname
--  * 			htid
--  * 			level
--  * 			vip
--  * 			fight_force
--  * 			dress
--  * 			max_honor
--  * 			rank
--  * 		}
--  * 		cross => array
--  * 		{
--  * 			server_id
--  * 			server_name
--  * 			uid
--  * 			uname
--  * 			htid
--  * 			level
--  * 			vip
--  * 			fight_force
--  * 			dress
--  * 			max_honor
--  * 			rank
--  * 		}
--  * 		my_inner_rank => int
--  * 		my_cross_rank => int
--  * }
-- */
-- function getRankList();
function getRankList( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	Network.rpc(callBack, "worldcompete.getRankList", "worldcompete.getRankList", nil, true)
end


-- /**
--  * 获得对手的阵容信息
--  * 
--  * @param int  $aServerId
--  * @param int  $aPid
--  * @return @see User.getBattleDataOfUers
--  */
-- function getFighterDetail($aServerId,$aPid);
function getFighterDetail( pServerId, pPid, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pFlag,pData,pBool)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pServerId,pPid})
	Network.rpc(callBack, "worldcompete.getFighterDetail", "worldcompete.getFighterDetail", args, true)
end

-- /**
-- 	 * 拉取冠军信息
-- 	 *
-- 	 * @return array
-- 	 * {
-- 	 * 		cross => array
-- 	 * 		{
-- 	 * 			server_id
-- 	 * 			server_name
-- 	 * 			uid
-- 	 * 			uname
-- 	 * 			htid
-- 	 * 			level
-- 	 * 			vip
-- 	 * 			fight_force
-- 	 * 			dress
-- 	 * 			max_honor
-- 	 * 			rank
-- 	 * 		}
-- 	 * }
-- 	 */
-- 	function getChampion();
function getChampion( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			KuafuData.setChampionData(pData.ret)
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	Network.rpc(callBack, "worldcompete.getChampion", "worldcompete.getChampion", nil, true)
end
