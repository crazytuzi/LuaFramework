-- FileName: MissionMainController.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionMainController", package.seeall)

require "script/ui/mission/MissionMainService"
require "script/ui/mission/MissionMainData"
require "script/utils/TimeUtil"
require "script/ui/tip/AnimationTip"
function receiveDayReward( pCallback )
	--1.判断当前是否在领奖时间段内
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local donateTime = MissionMainData.getStartTime() + MissionMainData.getDonateTime()
	if nowTime < donateTime +  MissionMainData.getRankSpendTime() and nowTime > MissionMainData.getStartTime() then
		--当前时间小于排名结束时间
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1952"))
		return
	end
	--2.下届活动开始前两分钟不能领取
	if nowTime < MissionMainData.getStartTime() and MissionMainData.getConfigSeason() > 0 then
		if nowTime > MissionMainData.getStartTime() - MissionMainData.getRankSpendTime() then
			AnimationTip.showTip(GetLocalizeStringBy("lcyx_1971"))
			return
		end
	end
	--3.今天是否已经领过奖励
	local reciveTime = MissionMainData.getDayrewardTime()
	local nowTime = TimeUtil.getSvrTimeByOffset()
	if TimeUtil.isSameDay(reciveTime, nowTime) then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1946"))
		return
	end
	--3.判断背包满
	require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
	local requestCallback = function ( ... )
		--1.更新领奖时间
		local nowTime = TimeUtil.getSvrTimeByOffset()
		MissionMainData.setDayrewardTime(nowTime)
		--2.领奖提示
		local rewardInfo = ItemUtil.getItemsDataByStr(table.concat(MissionMainData.getDayRewardItemList(),","))
	    ReceiveReward.showRewardWindow( rewardInfo, nil , 10008, -800 )
	    ItemUtil.addRewardByTable(rewardInfo)
		if pCallback then
			pCallback()
		end
	end
	MissionMainService.receiveDayReward(requestCallback)
end