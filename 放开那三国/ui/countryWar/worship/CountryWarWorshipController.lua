-- FileName: CountyWarWorshipController.lua
-- Author: yangrui
-- Date: 2015-11-16
-- Purpose: 国战膜拜Controller

module("CountryWarWorshipController", package.seeall)

--[[
	@des    : 膜拜
	@para   : 
	@return : 
--]]
function worship( pCallback )
	-- 是否是膜拜阶段
	require "script/ui/countryWar/CountryWarMainData"
	require "script/ui/countryWar/CountryWarDef"
	local curStage = CountryWarMainData.getCurStage()
	local worshipStage = CountryWarDef.WORSHIP
	if curStage ~= worshipStage then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5024"))
		return
	end
	-- 是否可以膜拜
	local worshipTime = CountryWarWorshipData.getWorshipTime()
	local curTIme = TimeUtil.getSvrTimeByOffset(0)
	if TimeUtil.isSameDay(worshipTime,curTIme) then
		-- 不可膜拜
		AnimationTip.showTip(GetLocalizeStringBy("yr_2001"))
		return
	end
	-- 背包是否有剩余空间
    require "script/ui/item/ItemUtil"
    if( ItemUtil.isBagFull() == true )then
        return
    end
	local requestCallback = function( pData )
		if pData == "expired" then
			AnimationTip.showTip(GetLocalizeStringBy("yr_5024"))
			return
		else
			-- 设置膜拜时间
			CountryWarWorshipData.setWorshipTime(TimeUtil.getSvrTimeByOffset(0))
			CountryWarMainData.setWorShipTime(TimeUtil.getSvrTimeByOffset(0))
			-- 获取的奖励
			local rewardInfo = CountryWarWorshipData.getWorshipRewardData()
			local rewardData = ItemUtil.getItemsDataByStr(rewardInfo)
			-- 添加奖励到本地
			ItemUtil.addRewardByTable(rewardData)
			-- 弹出奖励面板
			require "script/ui/item/ReceiveReward"
		    ReceiveReward.showRewardWindow(rewardData,nil,1010)
		end
	    -- pCallback
		if pCallback ~= nil then
			pCallback()
		end
	end
	CountryWarWorshipService.worship(requestCallback)
end
