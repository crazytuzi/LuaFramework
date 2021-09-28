-- FileName: PlayerBackDef.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动

module("PlayerBackDef",package.seeall)

--活动开启
kIsOpen = 1
--活动未开启
kNotOpen = 0

--奖励已经领取(已领取)
kTaskStausGot=2
--奖励可以领取(领取)
kTaskStausCanGet=1
--任务还未完成(前往)
kTaskStausNotAchive=0


--任务类型,1 回归礼包
kTypeOfTaskOne = 1
--回归任务
kTypeOfTaskTwo = 2
--单笔充值
kTypeOfTaskThree = 3
--折扣商品
kTypeOfTaskFour  = 4

--得到开服当天以及前面几天的登陆信息
function getPlayerBackEnter( pDay )
	local uid = UserModel.getUserUid()
	local curDayEnterInfo = CCUserDefault:sharedUserDefault():getBoolForKey(uid.."_PlayerBack_"..pDay)
	return curDayEnterInfo
end

--修改新服活动登陆数据
function setPlayerBackEnter( pDay )
	local uid = UserModel.getUserUid()
	CCUserDefault:sharedUserDefault():setBoolForKey(uid.."_PlayerBack_"..pDay,true)
	CCUserDefault:sharedUserDefault():flush()
end