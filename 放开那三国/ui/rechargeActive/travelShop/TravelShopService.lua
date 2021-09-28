-- Filename：	TravelShopService.lua
-- Author：		bzx
-- Date：		2015-9-6
-- Purpose：		云游商人接口


module ("TravelShopService", package.seeall)

btimport "script/ui/rechargeActive/travelShop/TravelShopData"
--[[
	获取信息
	{
		score: 积分
		finish_time: 完成进度时间
		sum: 购买总人次数
		topup: 充值金币数
		buy:{
			goodsId => num    商品id => 购买次数
		}
		payback:{ 返利信息
			id => status    完成进度的次数 => 领取状态 0 未领 1已领
		}
		reward:{ 奖励信息
			id 已领取的奖励id
		}
	}
--]]
function getInfo(p_callback)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		TravelShopData.setTravelShopInfo(dictData.ret)
		if p_callback ~= nil then
			p_callback(dictData)
		end
	end
	Network.rpc(rpcCallback, "travelshop.getInfo", "travelshop.getInfo", nil, true)
	-- local data = {
	-- 	err = "ok",
	-- 	ret = "ok",
	-- }
	-- rpcCallback(nil, data, true)
end

--[[
	@desc: 	购买
	@param  goodsId    商品id
	@param 	num 		数量
	@return  'ok'
--]]
function buy(p_callback, p_goodsId, p_num)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		TravelShopData.handleBuyInfo(p_goodsId, p_num, dictData.ret)
		if p_callback ~= nil then
			p_callback(dictData)
		end
	end
	local param = Network.argsHandler(p_goodsId, p_num)
	Network.rpc(rpcCallback, "travelshop.buy", "travelshop.buy", param, true)
end

--[[
	@desc: 		领取充值返利
	@return:  'ok'
--]]
function getPayback( p_callback, p_index )
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		TravelShopData.handlePayback()
		if p_callback ~= nil then
			p_callback(dictData)
		end
	end
	local param = Network.argsHandler(p_index)
	Network.rpc(rpcCallback, "travelshop.getPayback", "travelshop.getPayback", param, true)
end

--[[
	@desc:			 领取普天奖励
	@param:	  id 	奖励id
	@return:	'ok'
--]]
function getReward(p_callback, p_id)
	local rpcCallback = function ( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		TravelShopData.handleRewardInfo(p_id)
		if p_callback ~= nil then
			p_callback(dictData)
		end
	end
	local param = Network.argsHandler(p_id)
	Network.rpc(rpcCallback, "travelshop.getReward", "travelshop.getReward", param, true)
end