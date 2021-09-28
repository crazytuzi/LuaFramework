-- FileName: CountryWarSignController.lua
-- Author: shengyixian
-- Date: 2015-11-16
-- Purpose: 国战报名控制器
module("CountryWarSignController",package.seeall)
require "script/ui/countryWar/signUp/CountryWarSignService"

function signForOneCountry( countryId )
	-- 判断当前时间是否在报名期间
	local startTime = CountryWarMainData.getStageStartTime(CountryWarDef.SIGNUP)
	local endTime = CountryWarMainData.getStageOverTime(CountryWarDef.SIGNUP)
	local nowTime = TimeUtil.getSvrTimeByOffset()
	-- 1、报名时间未到
	if (nowTime < startTime) then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_172"))
		return
	end
	-- 2、报名时间已过
	if (nowTime > endTime) then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_171"))
		return
	end

	local callFunc = function ( pData )
		if pData.ret == "expired" then
			-- 报名时间已过
			AnimationTip.showTip(GetLocalizeStringBy("lcyx_171"))
			return
		end
		-- 奖励提示
		local rewardAry = CountryWarSignData.getSignReward()
		local tipStr = ""
		local rewardLen = table.count(rewardAry)
		for i,v in ipairs(rewardAry) do
			if v.type == "silver" then
				UserModel.addSilverNumber(v.num)
				tipStr = tipStr..GetLocalizeStringBy("syx_1051",v.num)
			else
				UserModel.addGoldNumber(v.num)
				tipStr = tipStr..GetLocalizeStringBy("key_8095",v.num)
			end
			if i ~= rewardLen then
				tipStr = tipStr..","
			end
		end
		local tipStr = GetLocalizeStringBy("syx_1045",tipStr)
		AnimationTip.showTip(tipStr)
		CountryWarSignData.setSignedCountryID(countryId)
		CountryWarSignData.setSignNumByID(countryId)
		CountryWarSignData.setSignedUpTime(pData.signup_time)
		CountryWarSignLayer.refreshAfterSignUp()
	end

	CountryWarSignService.signForOneCountry(countryId,callFunc)
end