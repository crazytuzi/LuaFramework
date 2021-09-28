-- FileName: HolidayHappyService.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 节日狂欢网络层

module("HolidayHappyService",package.seeall)

--     /**
--      * 获得奖励数据
--      *
--      * @return array
--      * [
--     	*  'exchange' => array
-- 		*      [
-- 		*          301001 => array[m, 0], （参数一：已经使用的次数，参数二：0没买完1次数用完）
-- 		*          301002 => array[1, 0], 
-- 		*      ]
--      *  'data' => array
--      *      [
--      *          1 => array 第一季的信息
--      *          [
--      *              101001 => array[n, 1], （对于任务 参数一：这个任务完成的数量，参数二：0没完成1完成2领过奖励）
--      *              101002 => array[m, 0], （对于置换和限时购买，只读第一个参数：已经使用的次数）
--      *              101003 => array[m, 3], （对于充值领奖，参数一：已经领过奖励的次数， 参数二：一共可以领奖的次数）
--      *              ...
--      *          ]
--      *          2 => array 第二季的信息
--      *          ...
--      *      ],
--      *  'period' => int 当前是第几季 （从1开始）
--      *  'day' => int 活动第几天（从1开始）
--      * ]
--      */
function getInfo(callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	Network.rpc(requestFunc, "festivalact.getInfo", "festivalact.getInfo", nil, true)
end

-- /**
-- 	 * 完成任务领取奖励
-- 	 *
-- 	 * @param int $id 对应任务ID
-- 	 * @return 'ok':成功领取
-- 	 */
 function taskReward(id,callbackFunc)
 	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	local args = CCArray:create()
	args:addObject(CCInteger:create(id))
	Network.rpc(requestFunc, "festivalact.taskReward", "festivalact.taskReward", args, true)
 end


	-- /**
	--  * 充值后领取奖励
	--  *
	--  * @param int $d 奖励档位id
	--  * @return 'ok':成功领取
	--  */
	 function chargeReward(id,callbackFunc)
	 	local function requestFunc( cbFlag, dictData, bRet )
			if dictData.err == "ok" then
				if(callbackFunc ~= nil) then
					callbackFunc(dictData.ret)
				end
			end
		end
	
		local args = CCArray:create()
		args:addObject(CCInteger:create(id))
		Network.rpc(requestFunc, "festivalact.chargeReward", "festivalact.chargeReward", args, true)
	 end


	-- /**
	--  * 购买商品
	--  *
	--  * @param $Id:对应任务ID，购买数量num
	--  * @return 'ok':购买成功
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
		Network.rpc(requestFunc, "festivalact.buy", "festivalact.buy", args, true)
	end


	-- /**
	--  * 兑换商品
	--  *
	--  * @param $Id:对应任务ID
	--  * @return 'ok':兑换成功
	--  */
	function exchange(id,num,callbackFunc)
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
		Network.rpc(requestFunc, "festivalact.exchange", "festivalact.exchange", args, true)
	end


	-- /**
	--  * 登陆补签
	--  *
	--  * @param $Id:对应任务ID
	--  * @return 'ok':补签成功
	--  */
	function signReward(id,callbackFunc)
		local function requestFunc( cbFlag, dictData, bRet )
			if dictData.err == "ok" then
				if(callbackFunc ~= nil) then
					callbackFunc(dictData.ret)
				end
			end
		end
	
		local args = CCArray:create()
		args:addObject(CCInteger:create(id))
		Network.rpc(requestFunc, "festivalact.signReward", "festivalact.signReward", args, true)
	end