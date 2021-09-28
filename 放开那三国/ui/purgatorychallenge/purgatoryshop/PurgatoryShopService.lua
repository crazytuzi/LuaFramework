-- Filename: PurgatoryShopService.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店网络层

module("PurgatoryShopService", package.seeall)
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopData"
-- /**
-- * array
-- * {
-- * 	goodId => num
-- * }
-- *
-- */
function getInfo(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			PurgatoryShopData.setShopServerInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "worldpass.getShopInfo", "worldpass.getShopInfo", nil, true)
end
-- /**
-- * ret
-- * {
-- * 	"ok"
-- * }
-- *
-- */
function buy( p_GoodIndex, p_num, p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_GoodIndex))
	args:addObject(CCInteger:create(p_num))
	Network.rpc(requestFunc, "worldpass.buyGoods", "worldpass.buyGoods", args, true)
end