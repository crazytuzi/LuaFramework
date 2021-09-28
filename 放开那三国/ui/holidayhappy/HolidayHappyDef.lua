-- FileName: HolidayHappyDef.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 

module("HolidayHappyDef",package.seeall)

--奖励已经领取
kTaskStausGot=2
--奖励可以领取
kTaskStausCanGet=1
--任务还未完成
kTaskStausNotAchive=0

--补签
kTaskStausBuQian = 3

--第一季
kSeasonOne = 1
--第二季
kSeasonTwo = 2

--任务类型,1为任务
kTypeOfTaskOne = 1
--折扣道具
kTypeOfTaskTwo = 2
--兑换任务
kTypeOfTaskThree = 3
--单笔充值
kTypeOfTaskFour  = 4



--得到开服当天以及前面几天的登陆信息
function getHolidayHappyEnter( pSeason )
	local uid = UserModel.getUserUid()
	local curDayEnterInfo = CCUserDefault:sharedUserDefault():getBoolForKey(uid.."_HolidayHappySeason_"..pSeason)
	return curDayEnterInfo
end

--修改新服活动登陆数据
function setHolidayHappyEnter( pSeason )
	local uid = UserModel.getUserUid()
	CCUserDefault:sharedUserDefault():setBoolForKey(uid.."_HolidayHappySeason_"..pSeason,true)
	CCUserDefault:sharedUserDefault():flush()
end