-- Filename: WeekendShopService.lua
-- Author: zhangqiang
-- Date: 2014-10-13
-- Purpose: 周末商人服务器接口调用

module("WeekendShopService", package.seeall)


--[[
	getInfo (line 31)
	return:
	      good_list:array
	      [
	          goodId => canBuyNum:int    可购买数量
	      ]
	      weekendshop_num:int 活动已开总次数（循环显示用）
	      has_buy_num:int 已经购买总次数
	      rfr_num_by_player:int 当天玩家刷新次数（计算金币用）
	access: public
	array getInfo ()
--]]
-- local count = 0
-- function getInfo( pCallBack )
-- 	local callBack = function ( pFlag, pData, pBool )
-- 		--计数拉取次数
-- 		count = count + 1
-- 		print("weekendshop.getInfo", count, pFlag, pBool)
-- 		if pData.err == "ok" then
-- 			count = 0
-- 			--成功获取数据
-- 			if pCallBack ~= nil then
-- 				pCallBack(pData.ret)
-- 			end
-- 		else
-- 			--延迟1s拉取
-- 			local startTime = os.time()
-- 			local delayTime = 1
-- 			while true do
-- 				if os.time() - startTime >= delayTime then
-- 					break
-- 				end
-- 			end

-- 			--限制拉取次数
-- 			if count <= 10 then
-- 				getInfo( pCallBack )
-- 			else
-- 				count = 0
-- 			end
-- 		end
-- 	end
-- 	Network.rpc(callBack, "weekendshop.getInfo", "weekendshop.getInfo", nil, true)
-- end
function getInfo( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		print("weekendshop.getInfo", count, pFlag, pBool)
		if pBool == true then
			if pCallBack ~= nil then
				pCallBack(pData.ret)
			end
		end
	end
	Network.rpc(callBack, "weekendshop.getInfo", "weekendshop.getInfo", nil, true)
end

--[[
	buyGood (line 55)
	return:
	      'ok'
	access: public
	string buyGood ($goodId $goodId)
	$goodId $goodId
--]]
function buyGood( pGoodId, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pBool == true then
			if pCallBack ~= nil then
				pCallBack()
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(pGoodId)))

	Network.rpc(callBack, "weekendshop.buyGood", "weekendshop.buyGood", args, true)
end

--[[
	rfrGoodList (line 48)
	return:
	      good_list:array
	      [
	          goodId => canBuyNum:int    可购买数量
	      ]
	      weekendshop_num:int 活动已开总次数（循环显示用）
	      has_buy_num:int 已经购买总次数
	      rfr_num_by_player:int 当天玩家刷新次数（计算金币用）
	access: public
	array rfrGoodList (type:int $type, [extra:int $extra = NULL])
	type:int $type: 1.使用金币刷新， 2.物品刷新
	extra:int $extra: 刷新需要的物品模板id
--]]
function refreshGoodList( pRefreshType, pCostTid, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pBool == true then
			if pCallBack ~= nil then
				pCallBack(pData.ret)
			end
		end
	end
	local args = CCArray:create()
	pRefreshType = tonumber(pRefreshType)
	args:addObject(CCInteger:create(pRefreshType))
	if pRefreshType ~= 1 then
		args:addObject(CCInteger:create(tonumber(pCostTid)))
	end

	Network.rpc(callBack, "weekendshop.rfrGoodList", "weekendshop.rfrGoodList", args, true)
end

--[[
	getShopNum (line 63)
	方便在活动没开启的时候 提供前端用

	return: 活动已开总次数（循环显示用）
	access: public
	int getShopNum ()
--]]
function getShopNum( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pBool == true then
			if pCallBack ~= nil then
				return pCallBack( pData.ret )
			end
		end
	end
	Network.rpc(callBack, "weekendshop.getShopNum", "weekendshop.getShopNum", nil, true)
end