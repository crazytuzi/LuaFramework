-- Filename: LordwarShopService.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店网络层

module("LordwarShopService", package.seeall)
require "script/ui/lordWar/shop/LordwarShopData"
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
			LordwarShopData.setShopServerInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "lordwarshop.getInfo", "lordwarshop.getInfo", nil, true)
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
	Network.rpc(requestFunc, "lordwarshop.buy", "lordwarshop.buy", args, true)
end