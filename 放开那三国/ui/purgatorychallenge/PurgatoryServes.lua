-- FileName: PurgatoryService.lua
-- Author: LLP
-- Date: 15-5-21
-- Purpose: 炼狱副本网络命令接口


module("PurgatoryServes", package.seeall)

require "script/ui/purgatorychallenge/PurgatoryData"
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopData"
require "script/ui/login/ServerList"
--获取炼狱副本信息
function getCopyInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.ret.ret == "ok")then
			PurgatoryData.setCopyInfo(dictData.ret)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		else
			local curTime = BTUtil:getSvrTimeInterval()
			local keepDay = TimeUtil.getCurDayZeroTime(tonumber(dictData.ret.open_time))-TimeUtil.getCurDayZeroTime(curTime)
			local dayNum = math.ceil(keepDay/(24*60*60))
			-- 网络错误 返回活动列表
			AnimationTip.showTip(GetLocalizeStringBy("llp_214",dayNum))

		end
	end
	Network.rpc(requestFunc, "worldpass.getWorldPassInfo", "worldpass.getWorldPassInfo", nil, true)
end

--战斗信息
function attack( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.ret.ret == "ok")then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.attack", "worldpass.attack", pArgs, true)
end

--重置
function resetCopy( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.ret.ret == "ok")then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.reset", "worldpass.reset", nil, true)
end

--购买次数
function buyTimeCommond( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.ret == "ok")then
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.addAtkNum", "worldpass.addAtkNum",pArgs, true)
end

-- /**
-- 	 * 拉取排行榜信息
-- 	 *
-- 	 * @return array
-- 	 * [
-- 	 * 		inner => array
-- 	 * 		[
-- 	 * 			uid
-- 	 * 			uname
-- 	 * 			htid
-- 	 * 			level
-- 	 * 			vip
-- 	 * 			fight_force
-- 	 * 			dress
-- 	 * 			max_point
-- 	 * 			rank
-- 	 * 		]
-- 	 * 		cross => array
-- 	 * 		[
-- 	 * 			server_id
-- 	 * 			server_name
-- 	 * 			uid
-- 	 * 			uname
-- 	 * 			htid
-- 	 * 			level
-- 	 * 			vip
-- 	 * 			fight_force
-- 	 * 			dress
-- 	 * 			max_point
-- 	 * 			rank
-- 	 * 		]
--	 * 		my_inner_rank => int
-- 	 * 		my_cross_rank => int
-- 	 * ]
-- 	 */
--排行榜信息
function getRankList( callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			PurgatoryData.setRankInfo(dictData.ret)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.getRankList", "worldpass.getRankList", nil, true)
end

--刷新英雄信息
function refreshHeros( callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.refreshHeros", "worldpass.refreshHeros", nil, true)
end

--商店信息
function getShopInfo( callbackFunc,pArgs )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			PurgatoryShopData.setShopServerInfo(dictData.ret)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.getShopInfo", "worldpass.getShopInfo", nil, true)
end

--兑换
function buyGoods( p_param,callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			if(dictData.ret.ret == "ok")then
				----扣消耗
				GodShopData.updateCost(p_param)
				----加次数
				----扣数量
				GodShopData.changeGoodList(p_param,-1)
				local goods = GodShopData.getRewardInDb(p_param)
				ItemUtil.addRewardByTable(goods) ---发奖
				require "script/ui/shopall/godShop/GodShopAlertCost"
	            ReceiveReward.showRewardWindow(goods,callbackFunc,GodShopAlertCost.getZorder()+10,-650)  --奖励弹窗
        	end
		end
	end
	local arg = CCArray:create()
	arg:addObject(CCInteger:create(p_param))
	Network.rpc(requestFunc, "worldpass.buyGoods", "worldpass.buyGoods", arg, true)
end
--刷新
function refreshShopInfo( callbackFunc )
	-- body
	local function requestFunc( cbFlag, dictData, bRet )
		if(bRet == true)then
			GodShopData.setShopInfo(dictData.ret)
			-- 回调
			if(callbackFunc)then
				callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.refreshGoodsList", "worldpass.refreshGoodsList", nil, true)
end