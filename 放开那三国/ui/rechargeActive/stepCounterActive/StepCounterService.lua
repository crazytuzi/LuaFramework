-- Filename：	StepCounterService.lua
-- Author：		Zhang Zihang
-- Date：		2014-9-11
-- Purpose：		计步活动网络层

module ("StepCounterService", package.seeall)

require "script/network/Network"
require "script/ui/rechargeActive/stepCounterActive/StepCounterData"

--[[
	@des 	:拉取计步活动信息
	@param 	:UI层回调函数
	@return :
--]]
function checkStatus(p_UICallback)
	local checkStatusCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "stepcounter.checkStatus" then
			--在数据层设置是否已经领
			StepCounterData.setWetherReward(dictData.ret)
			--UI回调
			p_UICallback()
		end
	end

	Network.rpc(checkStatusCallBack, "stepcounter.checkStatus","stepcounter.checkStatus", nil, true)
end

--[[
	@des 	:领取奖励后端接口
	@param 	:
	@return :
--]]
function recReward(p_UICallback)
	local recRewardCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "stepcounter.recReward" then
			--增加数值物品，如金币，银币等等
			StepCounterData.addReward()
			--UI回调
			p_UICallback()
		end
	end

	Network.rpc(recRewardCallBack, "stepcounter.recReward","stepcounter.recReward", nil, true)
end