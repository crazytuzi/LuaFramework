-- FileName: SevenLotteryServices.lua
-- Author: LLP
-- Date: 16-8-3
module("SevenLotteryServices", package.seeall)

function getInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc, "sevenslottery.getSevensLotteryInfo", "sevenslottery.getSevensLotteryInfo", nil, true)
end

function lottery( callbackFunc,pType )
	local function requestFunc( cbFlag, dictData, bRet )
		if(dictData.err == "ok")then
			-- 回调
			if(callbackFunc)then
				callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(pType))
	Network.rpc(requestFunc, "sevenslottery.lottery", "sevenslottery.lottery", args, true)
end