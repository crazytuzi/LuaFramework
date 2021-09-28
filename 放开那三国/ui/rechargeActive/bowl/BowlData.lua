-- Filename：	BowlData.lua
-- Author：		DJN
-- Date：		2015-11-3
-- Purpose：		聚宝盆数据
module("BowlData", package.seeall)
require "script/model/utils/ActivityConfigUtil"
require "script/utils/TimeUtil"
require "script/model/user/UserModel"

local _tagCorper = 1       -- 铜宝盆
local _tagSilver = 2       -- 银宝盆
local _tagGold   = 3       -- 金宝盆
local _bowlTable = {_tagCorper,_tagSilver,_tagGold}
local _bowlInfo = {}  --个人聚宝信息


----设置个人聚宝信息
function setBowlInfo( p_info )
	_bowlInfo = p_info
	-- print("_bowInfo")
	-- print_t(_bowlInfo)
end
----获取个人聚宝信息
function getBowlInfo( ... )
	return _bowlInfo
end
----今日是否有未领取的reward 做红点提示用
function isHaveReward( ... )
	if(ActivityConfigUtil.getDataByKey("treasureBowl").end_time >= TimeUtil.getSvrTimeByOffset())then
		for i = 1,3 do
		    for k,v in pairs(_bowlInfo.type[tostring(i)].reward)do
		    	if(tonumber(v) == 1 )then
			    	return true
			    	--break
		    	end
		    end
		end
	end
end
----今日是否在活动列表中icon存在，即是否有活动入口
function isHaveIcon( ... )
	if(isInBowling() == true)then
		--聚宝期一定会有
		--print("在聚宝期，有icon")
		return true
	else
		local _,tableForIcon = getTodayBowl()
		if(table.isEmpty(tableForIcon) == false)then
			--领奖期有奖品可以领也会有
			--print("过了聚宝期，有奖励可以领，有icon")
			return true
		else
			--print("过了聚宝期，没有奖励，没有icon")
			return false
		end
	end
end
----是否在可聚宝期间，领奖期间不算聚宝期。因为整个活动配置配的活动期限为聚宝期+领奖期。
function isInBowling( ... )
	local startTime = ActivityConfigUtil.getDataByKey("treasureBowl").start_time
	local bowlDay = ActivityConfigUtil.getDataByKey("treasureBowl").data[1].bowltime --配置为聚宝期的天数
	local curTime = TimeUtil.getSvrTimeByOffset()

	if(TimeUtil.getDifferDay(startTime) < tonumber(bowlDay))then
		return true
	else
		return false
	end
	-- --原来是按照天数间隔算的，算法如上，又恐活动开启时间不按整天算的意外，用时间戳算的，如下
	-- if(curTime < tonumber(startTime) + tonumber(bowlDay)*24*60*60)then
	-- 	return true
	-- else
	-- 	return false
	-- end
end

----今日需要展示的宝盆(因为过了聚宝期后，就只展示可领奖励的宝盆)
function getTodayBowl( ... )
	local bowlTable = {}  --用于UI创建
	local tableForIcon = {} --用于判断是否有活动入口
	local max_bowl = nil
	--用两个变量table的原因：这个函数主要用于两处，一处是在聚宝三天活动过后根据返回的table是否为空来判断今日是否有活动入口，另一处是在创建UI的时候使用
	--因为暂无刷新精彩活动顶端icon的方法，在领取整个聚宝盆最后一份奖励后，依照策划意图，再进精彩活动的时候活动入口icon就消失了，但是如果玩家此时持有活动界面，不大退，只是进行
	--活动的切换，那么再切回来的时候因为返回的table为空，会出现无法创建UI的问题，所以引入max_bowl变量在遍历的时候对最后一个聚过宝的宝盆进行保存，在玩家持有活动界面不大退
	--的情况下，切回聚宝盆时展示最后一个聚过宝的宝盆，下次再进精彩活动次入口消失。
	if(isInBowling() == true)then
		--print("聚宝期，三个宝盆都有")
		--在聚宝期间是要都展示的
		bowlTable = _bowlTable	
		tableForIcon = _bowlTable	
	else
	   -- print("过了聚宝期")
	    if(ActivityConfigUtil.getDataByKey("treasureBowl").end_time < TimeUtil.getSvrTimeByOffset())then 
	        --已经超过了活动期
	    	return bowlTable,tableForIcon
		end

	    --还在整个活动期内

	    for i = 1,3 do
	    	if(table.isEmpty(_bowlInfo.type[tostring(i)].reward) == false)then
	    		--print("第i个盆不为空",i)
	    		--奖励表不为空
	    		max_bowl = i
		    	for k,v in pairs(_bowlInfo.type[tostring(i)].reward)do
		    		--遍历其中每一天的奖励
		    		if(tonumber(v) ~= 2 )then
		    			--print("不为空的盆中有可领取的箱子")
		    			--2代表已经领取，如果其中有未领取的 就代表需要将这个宝盆列表展示出来，如果这个宝盆的奖励已经全部领取过，就不展示了
			    		table.insert(bowlTable,_bowlTable[i])
			    		table.insert(tableForIcon,_bowlTable[i])
			    		break
		    		end
		    	end
	    	end
	    end
	end
	if( (table.isEmpty(bowlTable) == true) and (max_bowl ~= nil))then
		table.insert(bowlTable,_bowlTable[max_bowl])
	end
	return bowlTable,tableForIcon
end
--获取p_tag这个箱子今日是否有奖励可以领取或已经领取，来判断是否创建tableview 针对当日聚宝但是当日无法领奖这种情况
function haveRewardTodayByBowl(p_tag)
	local tag = tostring(p_tag)
	local flag = false
	for k,v in pairs(_bowlInfo.type[tag].reward)do
		if(tonumber(v) == 1 or tonumber(v) == 2)then
			flag = true
			break
    	end
    end
    return flag
end
--某个箱子购买后，改变缓存中其购买状态
function changeBowlStatus( p_tag )
	if( tonumber(_bowlInfo.type[tostring(p_tag)].state ) == 2)then
		_bowlInfo.type[tostring(p_tag)].state  = 3
	end 
end
--扣除购买某个箱子消耗的金币
function chargeByTag(p_tag )
	UserModel.addGoldNumber(-tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[tonumber(p_tag)].BowlCost) )
end
--领取奖励后更新本地宝盆状态缓存
function upBowlInfo(p_type,p_tag)
	_bowlInfo.type[tostring(p_type)].reward[tostring(p_tag)] = 2
	setBowlInfo(_bowlInfo)
end
--领奖后更新本地宝盆奖励列表缓存,减少一次发送网络请求
function changeBowlRewardList(p_tag)
	local rewardIdList = {}
	rewardIdList[tostring(1)] = 1
	for i=2,tonumber(ActivityConfigUtil.getDataByKey("treasureBowl").data[1].rewardtime) do
		rewardIdList[tostring(i)] = 0
	end
	_bowlInfo.type[tostring(p_tag)].reward = rewardIdList
end