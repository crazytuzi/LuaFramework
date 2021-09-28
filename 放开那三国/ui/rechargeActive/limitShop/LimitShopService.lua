-- Filename：	LimitShopService.lua
-- Author：		Zhang Zihang
-- Date：		2014-11-24
-- Purpose：		限时商店网络层

module("LimitShopService", package.seeall)

require "script/ui/rechargeActive/limitShop/LimitShopData"

--[[
	@des 	:得到当前天数
	@param 	:UI回调
--]]
-- function getLimitShopDay(p_callBack)
-- 	local callBack = function(cbFlag,dictData,bRet)
-- 		if not bRet then
-- 			return
-- 		end

-- 		if cbFlag == "limitshop.getLimitShopDay" then
-- 			--设置当前天数
-- 			LimitShopData.setCurDay(dictData.ret)
-- 			LimitShopData.setCurDayInfo()
-- 			--设置今天刷新时间
-- 			LimitShopData.setRefreshTime()

-- 			--UI回调
-- 			p_callBack()
-- 		end
-- 	end

-- 	Network.rpc(callBack, "limitshop.getLimitShopDay","limitshop.getLimitShopDay", nil, true)
-- end

--[[
	@des 	:得到限时商城信息
	@param 	:网络回调
--]]
function getLimitShopInfo(p_callBack)
	local callBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "limitshop.getLimitShopInfo" then
			--设置数据信息
			LimitShopData.setConfigInfo()
			LimitShopData.setServerInfo(dictData.ret)

			--设置当前天数
			LimitShopData.setCurDay()
			LimitShopData.setCurDayInfo()
			--设置今天刷新时间
			LimitShopData.setRefreshTime()
			
			p_callBack()
		end
	end

	Network.rpc(callBack, "limitshop.getLimitShopInfo","limitshop.getLimitShopInfo", nil, true)
end

--[[
	@des 	:购买物品
	@param 	: $ p_callBack 			:回调函数
	@param 	: $ p_id 				:配置id
--]]
function buyGoods(p_callBack,p_id,p_num)
	local callBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end

		if cbFlag == "limitshop.buyGoods" then
			--购买次数加1
			LimitShopData.setBuyNum(p_id,p_num)
			
			p_callBack(p_num)
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_id)))
	args:addObject(CCInteger:create(p_num))

	Network.rpc(callBack, "limitshop.buyGoods","limitshop.buyGoods",args,true)
end