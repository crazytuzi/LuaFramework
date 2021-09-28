-- FileName: PlayerBackService.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动Service

module("PlayerBackService",package.seeall)

-- /**
-- 	 * @return int 0:功能图标不开启；    1：开启
-- 	 */
function getOpen(callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	Network.rpc(requestFunc, "welcomeback.getOpen", "welcomeback.getOpen", nil, true)
end
	
-- /**
-- 	 * @return array 
-- 	 * <code>
-- 	 * array
-- 	 * [
	   		
-- 'timeReamin' => time,			活动结束时间，秒数
	   		
-- 	   		'gift' => array(
-- 				id => 1|2				1:未领取，2：已经领取
-- 			), 
			
-- 			'task' => array(
-- 				id => array(
-- 						finishedTimes, 		目前执行次数
-- 						status				0:未完成任务，1：任务完成但还未领取奖励，2：已领取奖励
-- 				)
-- 			), 
			
-- 			'recharge' => array(
-- 				id => array(
-- 						hadRewardTimes,		已领奖次数
-- 						toRewardTimes		待领奖次数
-- 				)
-- 			),
			
-- 			'shop' => array(
-- 				id => 1				已购买次数
-- 			)
-- 	 * ]
-- 	 * </code>
-- 	 */
function getInfo(callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	Network.rpc(requestFunc, "welcomeback.getInfo", "welcomeback.getInfo", nil, true)
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
		Network.rpc(requestFunc, "welcomeback.buy", "welcomeback.buy", args, true)
	end

	-- /**
-- 	 * 完成任务领取奖励
-- 	 *
-- 	 * @param int $id 对应任务ID
--  * @param int $select	如果是可选奖励类型,则传选择的奖励物品在奖励数组中的顺序编号
-- 	 * @return 'ok':成功领取
-- 	 */
function gainReward(id,pSelect,callbackFunc)
 	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	local args = CCArray:create()
	args:addObject(CCInteger:create(id))
	args:addObject(CCInteger:create(pSelect))
	Network.rpc(requestFunc, "welcomeback.gainReward", "welcomeback.gainReward", args, true)
 end

