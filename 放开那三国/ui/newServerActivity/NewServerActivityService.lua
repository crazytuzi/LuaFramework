-- FileName: NewServeActivityService.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-4
-- Purpose: 新服活动主界面


module("NewServerActivityService",package.seeall)

-- /**
-- 	 
-- 	 * 1.返回给前端小于等于当天能看到的任务的信息数组('taskInfo'字段)
--      * 2.返回给前端抢购商品的信息数组('purchase'字段)
--      * 3.返回给前端任务更新截止时间戳 ('DEADLINE'字段)和 “开服7天乐”关闭时间戳('CLOSEDAY'字段)
-- 	 * @return array
-- 	 * [
-- 	 * 	'taskInfo' => [
-- 	 *  	$taskId => array[
-- 	 *         	's' status缩写 => int (0未完成, 1完成, 2已领奖),
-- 	 *         	'fn' finish_num缩写=> int 完成进度,
-- 	 *  		]
-- 	 *  	],
-- 	 *  'purchase' => array[
-- 	 *  		$day => array[
-- 	 *  			'buyFlag' => int(用于区分当天的抢购商品是否购买了;表示 0未购买, 1已购买),
-- 	 *  			'remainNum' => int(当天的抢购商品剩余数量),
-- 	 *  		]
-- 	 *  	],
-- 	 *  'DEADLINE' => int 返回任务更新的截止时间戳（活动倒计时）
-- 	 *  'CLOSEDAY'	=> int 返回“开服7天乐”的关闭时间戳 （领取倒计时）
-- 	 * ]
-- 	 */
function getInfo(fight,callbackFunc )
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end
	
	local args = CCArray:create()
	args:addObject(CCInteger:create(fight))
	Network.rpc(requestFunc, "newserveractivity.getInfo", "newserveractivity.getInfo", args, true)
end
-- /**
-- 	 * 领取完成的任务奖励
-- 	 * @param $taskId int 完成的的任务id , 任务id在策划给的open_server_reward表中
-- 	 * @return string 'ok'
-- 	*/
function obtainReward(taskId,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc()
			end
		end
	end
	
	local args = CCArray:create()
	args:addObject(CCInteger:create(taskId))
	Network.rpc(requestFunc, "newserveractivity.obtainReward", "newserveractivity.obtainReward", args, true)
end
-- /**
-- 	 * @param $day int 天数
-- 	 * @return array
-- 	 * [
-- 	 * 	'ret' => 'ok':购买成功  或者  'limit':商品被购买完,购买失败 ,
-- 	 * 	'remainNum' => int(购买后抢购商品剩余数量),
-- 	 * ]
-- 	*/
function buy(day,callbackFunc)
	local function requestFunc( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if(callbackFunc ~= nil) then
				callbackFunc(dictData.ret)
			end
		end
	end

	local args = CCArray:create()
	args:addObject(CCInteger:create(day))
	Network.rpc(requestFunc, "newserveractivity.buy", "newserveractivity.buy", args, true)
end