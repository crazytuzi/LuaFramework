-- FileName: CountryWarShopService.lua
-- Author: FQQ
-- Date: 2015-11-2
-- Purpose: 国战商店网络层


module ("CountryWarShopService",package.seeall)
-- require "script/ui/countryWarShop/CountryWarShopData"
-- -/**
-- 	 * 获取商店信息
-- 	 *
-- 	 * @return
-- 	 *
-- 	 * <code>
-- 	 *
-- 	 * array
-- 	 * {	
--			copoint:int 国战积分
-- 	 * 		good_list:array
-- 	 *      [
-- 	 *          goodsId => canBuyNum:int    可购买数量
-- 	 *      ]
-- 	 * }
-- 	 *
-- 	 *</code>
-- 	 *
-- 	 */
function getInfo(p_callbackFunc)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			CountryWarShopData.setShopServerInfo(dictData.ret)
			if(p_callbackFunc ~= nil) then
				p_callbackFunc()
			end
		end
	end
	Network.rpc(requestFunc, "countrywarshop.getShopInfo", "countrywarshop.getShopInfo", nil, true)
end


-- /**
-- 	 * 购买商品
-- 	 * @param int $goodsId，$p_num
-- 	 * @return 'ok'
-- 	*/
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
	Network.rpc(requestFunc, "countrywarshop.buy", "countrywarshop.buy", args, true)
end