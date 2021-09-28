-- Filename: HeroDestineyCopyService.lua
-- Author: zhangqiang
-- Date: 2016-05-30
-- Purpose: 英雄天命副本网络接口

module("HeroDestineyCopyService", package.seeall)


-- /**
--  * 购买主角经验副本攻击次数
--  * @param int $num
--  * @return string 'ok'
--  */
function buyDestinyAtkNum(p_num, p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet, tbParams )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(dictData.ret, tbParams)
			end
		end
	end

	local tbArgs = {}
	tbArgs[#tbArgs + 1] = tonumber(p_num)

	local args = Network.argsHandlerOfTable(tbArgs)
	Network.rpc(function ( cbFlag, dictData, bRet )
		requestFunc(cbFlag, dictData, bRet, tbArgs)
	end, "acopy.buyDestinyAtkNum", "acopy.buyDestinyAtkNum", args, true)
end