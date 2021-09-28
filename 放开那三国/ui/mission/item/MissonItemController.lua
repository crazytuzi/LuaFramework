-- FileName: MissonItemController.lua
-- Author: lcy
-- Date: 2014-04-00
-- Purpose: 悬赏榜物品贡献

module("MissonItemController", package.seeall)

require "script/ui/mission/MissionMainService"
require "script/ui/mission/MissionMainData"
require "script/ui/tip/AnimationTip"
function doMissionItemCallback( pItemArray, pCallback)
	--1.当前时间是否还可以捐献
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
	--3.捐献的物品数量超过捐献上限
	local itemCount = 0
	local itemInfo = CCDictionary:create()
	for k,v in pairs(pItemArray) do
		if v.selectNum and v.selectNum > 0 then
			itemInfo:setObject(CCString:create(tostring(v.selectNum)), tostring(v.item_id))
			itemCount = itemCount + v.selectNum
		end
	end
	--4.捐献物品列表不能为空
	if itemCount == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1940"))
		return
	end
	local donateNum = MissionMainData.getDonateItemNum()
	local donateLimitNum = MissionMainData.getDonateLimit()
	if donateNum + itemCount > donateLimitNum then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1943"))
		return
	end
	local requestCallback = function ( pRetData )
		--1.刷新名望值
		local fameCount = MissionItemDialog.getFameCount()
		-- MissionMainData.addCurrFame(fameCount)
		--2.刷新用户名望
		UserModel.addFameNum(fameCount)
		--4.刷新已捐献物品数量
		MissionMainData.addDonateItemNum(itemCount)
		--5.提示
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1941", fameCount))
		if pCallback then
			pCallback()
		end
	end
	MissionMainService.doMissionItem(itemInfo, requestCallback)
end