--Filename:	TimerRequestCenter.lua
--Author:	chengliang
--Date:		2013/12/17
--Purpose:	通知的相关方法

module ("TimerRequestCenter", package.seeall)

require "script/utils/TimeUtil"
require "script/ui/copy/CopyService"

-------- 定时程序
local _updateTimeScheduler 	= nil	-- scheduler


-- 00:00 点调用
function startZeroRequest()
	-- 获取服务器时间
	local targetTime = TimeUtil.getIntervalByTime("000000") + UserModel.getSvrDayOffsetSec()
	local curTimeSec = TimeUtil.getSvrTimeByOffset()
	if(targetTime<=curTimeSec)then
		targetTime = targetTime + 86400
	end
	local leftTimeInterval = targetTime - TimeUtil.getSvrTimeByOffset() + 1
	-- leftTimeInterval = 180
	print("leftTimeInterval==", leftTimeInterval)
	if(leftTimeInterval>0)then
		startScheduler(leftTimeInterval)
	end
end

-- 停止scheduler
function stopScheduler()
	if(_updateTimeScheduler ~= nil)then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

-- 启动scheduler
function startScheduler(timeInterval)
	if(_updateTimeScheduler == nil) then
		_updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimeFunc, timeInterval, false)
	end
end

-- 
function updateTimeFunc()
	stopScheduler()
	startRequest()
	startZeroRequest()
end

-- 开始刷新各项数据
function startRequest( )
	if(DataCache.getSwitchNodeState(ksSwitchEliteCopy,false)) then
		-- 拉取精英副本
    	PreRequest.getEliteCopy_noLoading()
	end
	if(DataCache.getSwitchNodeState(ksSwitchActivityCopy,false)) then
		-- 活动副本
    	PreRequest.getActiveCopy_noLoading()
	end
	if(  UserModel.getHeroLevel() and UserModel.getHeroLevel()>=5 )then
		-- 普通副本
		CopyService.ncopyGetCopyList_noLoading()
	end
	if(DataCache.getSwitchNodeState(ksSwitchGuild , false)) then
		-- 军团副本
    	PreRequest.getGuildCopyInfo_noLoading()
	end
	if(DataCache.getSwitchNodeState(ksSwitchStar , false)) then
		-- 获得占星数据
    	PreRequest.preGetAstroInfo_noLoading()
	end
	if(DataCache.getSwitchNodeState(ksSwitchSignIn,false)) then
		-- 签到刷新
		PreRequest.getSignInfo_noLoading()
	end
	if(DataCache.getSwitchNodeState(ksSwitchGreatSoldier,false)) then
		-- 主角学习技能每天晚上零点重新拉取名将信息刷新翻牌次数
		PreRequest.getAllStarInfo_noloading()	
	end
	if ( DataCache.getSwitchNodeState(ksSwitchKFBW,false) ) then
		-- 跨服比武刷新 add by yangrui 15-10-13
		require "script/ui/kfbw/KuafuLayer"
		KuafuLayer.refreshInZero()
	end
	-- 天工阁
	if(DataCache.getSwitchNodeState(ksSwitchMoon, false))then
		require "script/ui/moon/MoonLayer"
		require "script/ui/moon/MoonShopLayer"
		MoonLayer.refresh()
		MoonShopLayer.refresh()
	end
	-- 神兵商店
	if(DataCache.getSwitchNodeState( ksSwitchGodWeapon,false))then
		require "script/ui/shopall/godShop/GodShopLayer"
		GodShopLayer.refresh()
	end
	-- 跨服团购
	if(ActivityConfigUtil.isActivityOpen("worldgroupon"))then
		require "script/ui/rechargeActive/worldGroupBuy/WorldGroupLayer"
		if( not tolua.isnull (WorldGroupLayer.getByLayer()) )then
	    	WorldGroupService.getInfo(0,WorldGroupLayer.refreshAtTwelve)
	    end
	end
	-- 云游商人
	if ActivityConfigUtil.isActivityOpen("travelshop") then
		require "script/ui/rechargeActive/travelShop/TravelShopLayer"
		TravelShopLayer.refresh()
	end
	-- 黑市兑换
	if ActivityConfigUtil.isActivityOpen("blackshop") then
		require "script/ui/rechargeActive/blackshop/BlackshopLayer"
		BlackshopLayer.refresh()
	end
	-- 悬赏榜商店
	require "script/ui/mission/shop/MissionShopLayer"
	if MissionShopLayer.isOpen() then
		MissionShopLayer.refresh()
	end
	-- 跨服比武商店
	require "script/ui/kfbw/kfbwshop/KFBWShopLayer"
	require "script/ui/kfbw/KuafuData"
	if KuafuData.isOpenKuafuShop() then
		KFBWShopLayer.refresh()
	end
	--兵符商店
	if(DataCache.getSwitchNodeState(ksSwitchTally, false))then
		require "script/ui/shopall/tally/TallyShopLayer"
		TallyShopLayer.refresh()
	end
	--月卡
	require "script/ui/month_card/MonthCardLayer"
	MonthCardLayer.refresh()
	
	--节日狂欢
	require "script/ui/holidayhappy/HolidayHappyLayer"
	HolidayHappyLayer.rfreshZero()
end
