-- FileName: DevilTowerShopService.lua 
-- Author: fuqiongqiong
-- Date: 2016-7-29
-- Purpose:试练塔商店网络层

module("DevilTowerShopService",package.seeall)
require "script/ui/deviltower/shop/DevilTowerShopData"


-- /**
--  * 获取商店信息
--  * @return array
--  *         [
--  *             'point':int     剩余积分
--  *             'info' : array  购买信息
--  *                         [
--  *                             id => num
--  *                         ]
--  *         ]
--  */
function getShopInfo(callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			DevilTowerShopData.setShopInfo(dictData.ret)
			if(callBack ~= nil) then
				callBack()
			end
		end
	end
	Network.rpc(requestFunc, "tower.getShopInfo", "tower.getShopInfo", nil, true)	
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
	Network.rpc(requestFunc, "tower.buy", "tower.buy", args, true)
end