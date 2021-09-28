-- FileName: LimitFundService.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-13
-- Purpose: 限时基金网络层

module("LimitFundService",package.seeall)

-- /**
-- 	 * 获取玩家的限时基金购买、领取情况
-- 	 * @return array
-- 	 * [
-- 	 * 		3 => array                                 基金id  => array
-- 	 * 			[
-- 	 * 				"buyNum" => 2,                     购买数量
-- 	 * 				"gain"   => array                  领奖记录 => array
-- 	 * 							[
-- 	 * 								1 => 0|1|2,        第1期       => 0：不到领奖时间； 1：可领； 2：已领
-- 	 * 								2 => 0|1|2,        第2期       => 0：不到领奖时间； 1：可领； 2：已领
-- 	 * 								...
-- 	 * 							]
-- 	 * 			]
-- 	 *      ...
-- 	 * ]
-- 	 * 玩家买了哪些id的基金就只包含这些id的信息，比如只买了1、3基金，那么返回的数组里就只有1、3号基金，没有2号基金。
-- 	 * 玩家没买就返回空数组。
-- 	 */
 function getInfo(callbackFunc)
 	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	Network.rpc(requestFunc, "limitfund.getInfo", "limitfund.getInfo", nil, true)
 end
	
	-- /**
	--  * 购买基金
	--  * @param int $id    基金id
	--  * @param int $num   数量
	--  */
 function buy(id,num,callbackFunc)
 	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(id))
	args:addObject(CCInteger:create(num))
	Network.rpc(requestFunc, "limitfund.buy", "limitfund.buy", args, true)
 end
	
	-- /**
	--  * 领取返金
	--  * @param int $id     基金id
	--  * @param int $index  第几期，从第1期开始
	--  */
 function gain(index,callbackFunc)
 	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(index))
	Network.rpc(requestFunc, "limitfund.gain", "limitfund.gain", args, true)
 end