-- FileName: HappySignService.lua 
-- Author: shengyixian
-- Date: 15-9-25
-- Purpose: 欢乐签到网络层

module("HappySignService",package.seeall)

--[[
	@des 	:获取已经签到的数据
	@param 	:
	@return : array(
--         			'uid'             => int,
--         			'had_sign'        => array( 1,3,4... ),欢乐签到已经领取了的奖励id
--         			),
--]]
function getSignInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"happysign.getSignInfo","happysign.getSignInfo",nil,true)
end
--[[
	@des 	:签到
	@param 	:id : 当前签到的天数
	@return : 
--]]
function gainSignReward(id,selectID,pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({id,selectID})
	Network.rpc(requestFunc,"happysign.gainSignReward","happysign.gainSignReward",args,true)
end