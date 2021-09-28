-- FileName: BlackShopService.lua 
-- Author: yangrui
-- Date: 15-8-28
-- Purpose: function description of module 

module("BlackshopService", package.seeall)

require "script/network/Network"

 -- /*获取玩家已兑换次数
 -- * @return 
 -- *  [id] => [num] => int
 -- * */
function getBlackshopInfo( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil) then
				pCallBack(pData.ret)
			end
		end
	end
	Network.rpc(callBack, "blackshop.getBlackshopInfo" , "blackshop.getBlackshopInfo", nil, true)
end

-- /*兑换物品
--  * @param  id  int 兑换的配置id
--  *         num int  兑换个数
--  * @return   'ok'   
--  * */
function exchangeBlackshop( pGoodId, pGoodNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		else
			AnimationTip.showTip(GetLocalizeStringBy("yr_1009"))
			return
		end
	end
	local args = Network.argsHandlerOfTable({pGoodId, pGoodNum})
	Network.rpc(callBack, "blackshop.exchangeBlackshop", "blackshop.exchangeBlackshop", args, true)
end
