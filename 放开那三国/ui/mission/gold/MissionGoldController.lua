-- FileName: MissionGoldController.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionGoldController", package.seeall)

require "script/ui/mission/MissionMainService"
require "script/ui/mission/gold/MissionGoldData"
require "script/ui/tip/AnimationTip"
function doMissionGold( pGoldNum, pCallback)
	--1.判断当前阶段是否可以捐献
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local donateTime = MissionMainData.getStartTime() + MissionMainData.getDonateTime()
	if nowTime > donateTime then
		--当前时间小于排名结束时间
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1953"))
		return
	end
	--2.玩家等级达到可以捐献的等级
	if UserModel.getHeroLevel() < MissionMainData.getNeedJoinLevel() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1947", MissionMainData.getNeedJoinLevel()))
		return
	end
	--3.判断是否有足够的金币
	if UserModel.getGoldNumber() < pGoldNum then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip(-2000)
		return
	end
	local fame = MissionGoldData.getFameByGold(pGoldNum)
	local requestCallback = function ()
		--1.扣除玩家金币
		UserModel.addGoldNumber(-pGoldNum)
		--2.刷新玩家名望
		UserModel.addFameNum(fame)
		--3.弹出提示
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1942", fame))
		--4.刷新ui
		if pCallback then
			pCallback()
		end
	end
	MissionMainService.doMissionGold(pGoldNum, requestCallback)
end