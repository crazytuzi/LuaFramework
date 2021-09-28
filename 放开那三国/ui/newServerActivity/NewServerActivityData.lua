-- FileName: NewServeActivityData.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-4
-- Purpose: 新服活动数据层


module("NewServerActivityData",package.seeall)
require "script/model/user/UserModel"
require "db/DB_Open_seven_reward"
require "db/DB_Open_seven_act"

-- /**
-- 	 * @param $fight 前端传来的战斗力,
-- 	 * 目的是为了让战斗力数据与前端及时同步,把前端的战斗力计算交给后端处理,因为框架的战斗力计算是必须打副本的
-- 	 * 
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
local _dataInfo = {}

--设置信息
function setInfo( pData )
	_dataInfo = pData
	print("_dataInfo总数据")
	print_t(_dataInfo)
end

--获取taskInfo数据
function getInfotaskId( ... )
	return _dataInfo.taskInfo
end

--后端推送来的数据加到_dataInfo中
function addTaskId( pTaskId )
	if( table.isEmpty(_dataInfo))then
		_dataInfo = {}
	end
	if(table.isEmpty(_dataInfo.taskInfo))then
		_dataInfo.taskInfo = {}
	end
	_dataInfo.taskInfo[pTaskId] = {}
	_dataInfo.taskInfo[pTaskId]["s"] = tostring(1)
	print("后端推送来的数据加到_dataInfo中")
	print_t(_dataInfo.taskInfo)
end

--购买商品后修改purchase里面的数据
function setPurchaseBuyflag(pDay)
	local data = _dataInfo.purchase
	data[tostring(pDay)].buyFlag = 1
end

-- 按天取标签相关的数据
function getTapInfoByDay( pDay )
	return DB_Open_seven_act.getDataById(pDay)
end

--从奖励表获取数据
function getDBInfoByTaskId(missionId)
	local data = DB_Open_seven_reward.getDataById(missionId)
	return data
end

--排序(可以领取的优先在上面)
function priorityOrder( mission_id )
	local status = getTaskStatusByTaskId(mission_id)
	return status
end
--判断任务状态(0未完成, 1完成, 2已领奖)
function getTaskStatusByTaskId( missionId )
	local status
	local dataInfo = _dataInfo.taskInfo
	for k,v in pairs(dataInfo) do
		if(missionId == tonumber(k))then
			status = tonumber(v.s)
			break
		else
			status = 0
		end
	end
	return status
end

--改变按钮状态
function setStatues( missionId,pValue )
local data = _dataInfo.taskInfo
	data[tostring(missionId)].s = tostring(pValue)
	-- print("_dataInfo.taskInfo改变")
	-- print_t(_dataInfo.taskInfo)
end

--活动倒计时
function countDownTime( ... )
	return _dataInfo.DEADLINE - BTUtil:getSvrTimeInterval()
end

--领取倒计时
function receiveCountDownTime( ... )
	return _dataInfo.CLOSEDAY - BTUtil:getSvrTimeInterval()
end

--判断点击的这天是否可以看到奖励和任务
function isCan( pDay )
	local curDay = getCurDay()
	-- local curDay = 4
	if(pDay <= curDay)then
		return true
	else
		return false
	end
end

--获取开服抢购人数上限
function getMaxBuyNum( pDay )
	local data = getTapInfoByDay(pDay)
	return tonumber(data.limited_num)
end

--获取剩余商品数量
function getremainBuyNum( pDay )
	local remainNum
	local data = _dataInfo.purchase
	for k,v in pairs(data) do
		if(tonumber(k) == pDay)then
			remainNum = tonumber(v.remainNum)
			break
		end
	end
	return remainNum
end

--判断商品是否购买
function isBuyGoods( pDay )
	local status = 1
	local dataInfo = _dataInfo.purchase
	for k,v in pairs(dataInfo) do
		if(tonumber(k) == pDay)then
			status = tonumber(v.buyFlag)
			break
		end	
	end
	return status
end

--红点提示(此方法用在主界面图标的大提示)
function isRedTip( ... )
	local curDay = getCurDay()
	local redTip = false
	if not isOpen() then
		--活动未开启
		return false
	end

	if(table.isEmpty(_dataInfo)) then
		--数据为nil
		return false
	end

	if(curDay > 7)then
	--当开服天数大于7时
		curDay = 7
	end
	for i=1,curDay do
		redTip = isRedTipOfDayButton(i)
		if(redTip)then
			break
		end
	end

	local isRedTip = false
	for i=1,curDay do
		isRedTip = isRedTipOfOpenBuy(i)
		if(isRedTip)then
			break
		end
	end
	if(isRedTip or redTip)then
		return true
	else
		return false
	end
end

--判断在第X天按钮上面的红点提示
function isRedTipOfDayButton( pDay )
	local isRedTip = false
	local data = getTapInfoByDay(pDay)
	for i=1,3 do
		local dataArray = string.split(data["mission_"..i],"|")
		if(isRedTipOfReceive(dataArray)) then
			isRedTip = true
			break
		end
	end
 	return isRedTip
end

--判断在标签上面的红点提示
function isRedTipOfReceive( missionIdTable )
	local isRedTip = false
	-- print("=== missionIdTable ====")
	-- print_t( missionIdTable)
	-- print("======_dataInfo.taskInfo=====")
	-- print_t(_dataInfo.taskInfo)
	for k,v in pairs(missionIdTable) do
		for k1,v1 in pairs(_dataInfo.taskInfo) do
			if(tonumber(v) == tonumber(k1) and tonumber(v1.s) == NewServerDef.kTaskStausCanGet)then
				isRedTip = true
				break
			end
		end
	end
	-- print("isRedTip",isRedTip)
	return isRedTip
end

--获取到活动的第几天
function getCurDay( ... )
	-- 开服时间
	local openDateTime= tonumber(ServerList.getSelectServerInfo().openDateTime)
	local day=1
	local mergeZeroTime = TimeUtil.getCurDayZeroTime(tonumber(openDateTime))
	local lastTime= BTUtil:getSvrTimeInterval() - mergeZeroTime
	local lastDay= math.ceil(lastTime/(24*60*60)) 
	print("lastDay***",lastDay)
	return lastDay
end

-- 开服超过10天新服7天乐图标消失
function isOpen( )
	--判断开服时间和上线时间
	--开服时间
	local openDateTime= tonumber(ServerList.getSelectServerInfo().openDateTime)
	if openDateTime < UserModel.getNewServerOnlineTime() then
		-- 如果开服时间大于上线时间
		print("新服活动未开启")
		return false
	end
	local isOpen = true
	local lastDay = getCurDay()
	if(lastDay > 10)then
		isOpen = false
	end
    return isOpen
end


--开服抢购红点是否显示
function isRedTipOfOpenBuy( pDay )
	local isRedTip = not getNewServerActivityEnter( pDay )
	return isRedTip
end


--得到开服当天以及前面几天的登陆信息
function getNewServerActivityEnter( pDay )
	require "script/ui/newServerActivity/NewServerActivityData"
	local uid = UserModel.getUserUid()
	local curDayEnterInfo = CCUserDefault:sharedUserDefault():getBoolForKey(uid.."_NewServerActivityday_"..pDay)
	return curDayEnterInfo
end

--修改新服活动登陆数据
function setNewServerActivityEnter( pDay )
	local uid = UserModel.getUserUid()
	CCUserDefault:sharedUserDefault():setBoolForKey(uid.."_NewServerActivityday_"..pDay,true)
	CCUserDefault:sharedUserDefault():flush()
end
