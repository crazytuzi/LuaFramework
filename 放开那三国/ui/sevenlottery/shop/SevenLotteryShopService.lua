-- FileName: SevenLotteryShopService.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-4
-- Purpose: 七星台商店Service

module("SevenLotteryShopService",package.seeall)
require "script/ui/sevenlottery/shop/SevenLotteryShopData"
-- /**
--  * 获取商店信息
--  * @return array
--  *         [
--  *             $goodsId	商品id
--               {
--					'num'  购买次数
--					'time' 购买时间
--                 }
--  *         ]
--  */
function getShopInfo(callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			SevenLotteryShopData.setShopInfo(dictData.ret)
			if(callBack ~= nil) then
				callBack()
			end
		end
	end
	Network.rpc(requestFunc, "sevenslottery.getShopInfo", "sevenslottery.getShopInfo", nil, true)	
end

-- /**
--  * 购买商品
--  * @param int $id  商品id
--  * @param int $num 数量
--  * @return 'ok'
--  */
function buy(id,num,callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(callBack ~= nil) then
				callBack()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(id))
	args:addObject(CCInteger:create(num))
	Network.rpc(requestFunc, "sevenslottery.buy", "sevenslottery.buy", args, true)
end