-- Filename：	AccumulateService.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-19
-- Purpose：		合服登录累积 & 合服充值回馈 网络层

module("AccumulateService", package.seeall)

require "script/network/Network"
require "script/ui/mergeServer/accumulate/AccumulateData"

--[[
	@des 	:
	*	'login' => array
	*      	'ret' => 'ok'       领取ok
	*                'over'     活动结束
	*       'res' => array      奖励信息
	* 		[
	* 			'login' => num	       已经累积登录的天数，没有返回0
	*           'got' => array         已经领取的天数
	* 			'can' => array         可以领取的天数
	* 		]
	*	'recharge' => array
	*      	'ret' => 'ok'       领取ok
	*                'over'     活动结束
	*       'res' => array      奖励信息
	* 		[
	* 			'recharge' => num	   累计充值的金币，没有返回0
	*           'got' => array         已经领取的档位   
	*           'can' => array         可以领取的档位
	* 		]
	@param 	:$ p_type 			:活动类型
						 	 	 1 累积登录 	 2 充值回馈
	@param 	:$ p_UICallback 	:UI界面回调		
	@return :
--]]
function getRewardInfo(p_type,p_UICallback)
	local getRewardInfoCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "mergeserver.getRewardInfo" then
			print("后端返回信息")
			print_t(dictData)
			--设置活动数据
			--累积登录
			if p_type == 1 then
				AccumulateData.setAccumulateInfo(dictData.ret.login)
			else
				AccumulateData.setRechargeInfo(dictData.ret.recharge)
			end

			--UI回调
			p_UICallback()
		end
	end

	Network.rpc(getRewardInfoCallBack, "mergeserver.getRewardInfo","mergeserver.getRewardInfo", nil, true)
end

--[[
	@des 	:累积登录领奖后端接口
	@param 	:$ p_index 			:领奖下标
	@param 	:$ p_callback 		:回调		
	@return :
--]]
function getLoginReward(p_index,p_callback)
	local getLoginRewardCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "mergeserver.receiveLoginReward" then
			p_callback()
		end
	end

	local arg = CCArray:create()
	arg:addObject(CCInteger:create(p_index))

	Network.rpc(getLoginRewardCallBack,"mergeserver.receiveLoginReward","mergeserver.receiveLoginReward",arg,true)
end

--[[
	@des 	:充值回馈领奖后端接口
	@param 	:$ p_index 			:领奖下标
	@param 	:$ p_callback 		:回调		
	@return :
--]]
function getRechargeReward(p_index,p_callback)
	local getRechargeRewardCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "mergeserver.receiveRechargeReward" then
			p_callback()
		end
	end

	local arg = CCArray:create()
	arg:addObject(CCInteger:create(p_index))

	Network.rpc(getRechargeRewardCallBack, "mergeserver.receiveRechargeReward","mergeserver.receiveRechargeReward", arg, true)
end