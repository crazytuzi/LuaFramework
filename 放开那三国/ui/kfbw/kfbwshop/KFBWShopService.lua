-- FileName: KFBWShopController.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店网络层
module("KFBWShopService",package.seeall)

-- /**
--  * 商店信息
--  *
--  * @return array
--  * <code>
--  * {
--  *     goodsId => array			商品id
--  *     {
--  *         'num'				    购买次数 
--  * 		  'time'				购买时间
--  *     }
--  * }
--  * </code>
--  */
function getShopInfo(pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"worldcompete.getShopInfo","worldcompete.getShopInfo",nil,true)
end

-- /**
--  * 购买商品
--  *
--  * @param goodsId 商品ID
--  * @param num     商品数量
--  * @return string 'ok'
--  */
function buyGoods(goodsId, num , pCallback)
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ goodsId, num })
	Network.rpc(requestFunc,"worldcompete.buyGoods","worldcompete.buyGoods",args,true)
end