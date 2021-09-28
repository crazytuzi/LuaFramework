-- Filename：	ChargeRaffleService.lua
-- Author：		lichenyang
-- Date：		2014-6-12
-- Purpose：		充值抽奖活动网络层


module ("ChargeRaffleService", package.seeall)

require "script/ui/rechargeActive/chargeRaffle/ChargeRaffleData"


---
--#function getInfo 
--#param  #function p_callbackFunc 完成回调
function getInfo( p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			ChargeRaffleData.setInfo(dictData.ret )
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "chargeraffle.getInfo", "chargeraffle.getInfo", nil, true)
end


---
--#function raffle 
--#param  #function p_callbackFunc 完成回调
--#param  #number   p_index 档次
function raffle( p_index,p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then 
			--修改剩余抽奖次数
			ChargeRaffleData.setCanRaffleNum(p_index, ChargeRaffleData.getCanRaffleNum(p_index) - 1)
			if(p_callbackFunc ~= nil) then
				local tid = niil
				if(dictData.ret["7"] ~= nil) then
					for k,v in pairs(dictData.ret["7"]) do
						tid = k
						break
					end
				elseif(dictData.ret["14"] ~= nil) then
					for k,v in pairs(dictData.ret["14"]) do
						tid = k
						break
					end
				end
				p_callbackFunc(tid)
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_index))
	Network.rpc(requestFunc, "chargeraffle.raffle", "chargeraffle.raffle", args, true)
end


---
--#function getReward 获取每日首冲奖励
--#param  #function p_callbackFunc 完成回调
function getReward( p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			ChargeRaffleData.setRewardStatus(2) -- 已领取
			ChargeRaffleData.addReward()		-- 修改缓存
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "chargeraffle.getReward", "chargeraffle.getReward", nil, true)
end