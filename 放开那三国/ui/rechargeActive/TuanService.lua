-- FileName: TuanService.lua 
-- Author: licong 
-- Date: 14-5-21 
-- Purpose: 团购网络请求 


module("TuanService", package.seeall)

-- 得到团购活动数据
-- callbackFunc: 回调
function getShopInfo( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getShopInfo---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			-- print("dictData.ret")
			-- print_t(dataRet)
			if(callbackFunc ~= nil)then
				callbackFunc(dataRet)
			end
		end
	end
	Network.rpc(requestFunc, "groupon.getShopInfo", "groupon.getShopInfo", nil, true)
end

-- 购买
-- goodsId:物品id
function buyGood( goodsId, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("buyGood---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			-- print("dictData.ret")
			-- print_t(dataRet)
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc(dataRet)
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(goodsId))
	Network.rpc(requestFunc, "groupon.buyGood", "groupon.buyGood", args, true)
end

-- 领奖
-- goodsId:物品id
-- rewardId:该物品的奖励id
function recReward( goodsId, rewardId, callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("recReward---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			-- print("dictData.ret")
			-- print_t(dataRet)
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc(dataRet)
				end
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(goodsId))
	args:addObject(CCString:create("reward" .. rewardId))
	Network.rpc(requestFunc, "groupon.recReward", "groupon.recReward", args, true)
end



-- 离开团购活动
-- callbackFunc: 回调
function leaveGroupOn( callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("leaveGroupOn---后端数据")
		if(dictData.err == "ok")then
			local dataRet = dictData.ret
			-- print("dictData.ret")
			-- print_t(dataRet)
			if(dataRet == "ok")then
				if(callbackFunc ~= nil)then
					callbackFunc(dataRet)
				end
			end
		end
	end
	Network.rpc(requestFunc, "groupon.leaveGroupOn", "groupon.leaveGroupOn", nil, true)
end


