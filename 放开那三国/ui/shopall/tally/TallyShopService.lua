-- FileName: TallyShopService.lua
-- Author: FQQ
-- Date: 2016-01-07
-- Purpose: 兵符商店Service
module("TallyShopService",package.seeall)
--[[
	@des 	: 商店信息
	@param 	: 
	@return : 
	/**
	 * 商店信息
	 *
	 * @return array
	 * <code>
	 * [
	 *     goods_list:array
	 *     [
	 *         goodsId=>canBuyNum
	 *     ]
	 *     gold_refresh_num:int   		玩家当日金币刷新次数
	 *     free_refresh_num			    当天免费刷新剩余的次数
	 * ]
	 * </code>
	 */
--]]
function getTallyInfo( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"moon.getTallyInfo","moon.getTallyInfo",nil,true)
end
--[[
	@des 	: 刷新商品
	@param 	: 
	<code>
	 * [
	 *     goods_list:array
	 *     [
	 *         goodsId=>canBuyNum
	 *     ]
	 *     gold_refresh_num:int       玩家当日金币刷新次数
	 *     free_refresh_num			      当天免费刷新剩余的次数
	 * ]
	 * </code>
	 */
--]]
function refreshTallyGoodsList( pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	Network.rpc(requestFunc,"moon.refreshTallyGoodsList","moon.refreshTallyGoodsList",nil,true)
end
--[[
	@des 	: 购买兵符商店的商品
	@param 	: pGoodsId 商品id
	@param 	: pNum 购买数量
	@return : 
--]]
function buyTally( pGoodsId,pNum,pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pGoodsId,pNum })
	Network.rpc(requestFunc,"moon.buyTally","moon.buyTally",args,true)
end