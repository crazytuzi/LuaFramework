-- FileName: MissionShopService.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: 悬赏榜商店网络层


module("MissionShopService", package.seeall)

-- Cocos2d: 
--   dictionary{
--       err : "ok"
--       callback : 
--           dictionary{
--               callbackName : "missionmall.getShopInfo"
--           }
--       ret : 
--           dictionary{
--               1 : "50"
--               2 : "1"
--               3 : "10"
--               4 : "15"
--               5 : "20"
--           }
--   }
function getInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"missionmall.getShopInfo","missionmall.getShopInfo",nil,true)
end

-- /**
--  * 
--  * @param int $goodId
--  * @param int $num
--  */
function buy( pGoodId, pNum, pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pGoodId, pNum })
	Network.rpc(requestFunc,"missionmall.buy","missionmall.buy",args,true)
end


