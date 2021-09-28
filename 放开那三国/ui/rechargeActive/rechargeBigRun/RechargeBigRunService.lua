-- Filename：	RechargeBigRunService.lua
-- Author：		Zhang Zihang
-- Date：		2014-7-7
-- Purpose：		充值大放送后端接口

module("RechargeBigRunService", package.seeall)

require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunData"
require "script/network/Network"

--[[
	@des 	:拉取充值大放送后端信息
	@param 	:UI回调
	@return :
--]]
function topupRewardGetInfo(UICallBack)
	--dictData.ret结构
	-- [ 
	-- 	'data' => array [
	-- 		=> array[0, 0], （第一个参数：是否能够领奖0否1是， 第二个参数：是否已经领取0否1是）
	-- 		=> array[0, 1], （第一个参数：是否能够领奖0否1是， 第二个参数：是否已经领取0否1是）
	-- 		... ], 
	-- 	'day' => int 活动第几天（从0开始） 
	-- ]
	getInfoCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "topupreward.getInfo" then
			--设置活动数据
			RechargeBigRunData.setBigRunInfo(dictData.ret)

			--UI回调
			UICallBack()
		end
	end

	Network.rpc(getInfoCallBack, "topupreward.getInfo","topupreward.getInfo", nil, true)
end

--[[
	@des 	:领奖返回
	@param 	:要领第几天的奖励（从0开始）
	@return :
--]]
function topupRewardRec(getRewardCallBack)
	recCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		require "script/ui/rechargeActive/rechargeBigRun/RechargeBigRunLayer"
		if cbFlag == "topupreward.rec" then
			--如果领取成功
			if dictData.ret == "true" or dictData.ret == true then
				--增加奖励
				RechargeBigRunData.addReward()
				--刷新UI，弹出奖励结算面板
				getRewardCallBack()
			else
				--弹出领取失败
				RechargeBigRunLayer.getFailed()
			end
		end
	end

	local arg = CCArray:create()
	--原来UI没改前，所有天的奖励都可以领，现在UI改成只有当天的可以领
	--可是后端怕策划变卦，所以保留了参数
	--参数是要领哪一天的，因为RechargeBigRunData.getToday()返回的天数从1开始，而参数从0开始
	--所以减1
	arg:addObject(CCInteger:create(RechargeBigRunData.getToday() - 1))
	Network.rpc(recCallBack,"topupreward.rec","topupreward.rec",arg, true)
end