-- FileName: CountryWarSignData.lua
-- Author: shengyixian
-- Date: 2015-11-20
-- Purpose: 国战报名数据层

module("CountryWarSignData", package.seeall)
--[[
	@des 	: 获取已经报名的国家的ID
	@param 	: 
	@return : 
--]]
function getSignedCountryID( ... )
	-- body
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	local signedID = nil
	if (signUpInfo) then
		if signUpInfo.countryId and tonumber(signUpInfo.countryId) ~= 0 then
			signedID = tonumber(signUpInfo.countryId)
		end
	end
	return signedID
end
--[[
	@des 	: 设置已经报名的国家的ID
	@param 	: 
	@return : 
--]]
function setSignedCountryID( pId )
	-- body
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	signUpInfo.countryId = pId
end
--[[
	@des 	: 获取指定国家的报名人数占报名总人数的百分比
	@param 	: 
	@return : 
--]]
function getCountrySignNumByID( pId )
	-- body
	local ret = nil
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	if (signUpInfo and signUpInfo.country_sign_num) then
		local signUpNumAry = signUpInfo.country_sign_num
		local totalNum = 0
		local currCountrySignNum = 0
		for i,v in pairs(signUpNumAry) do
			v = tonumber(v)
			totalNum = totalNum + v
			if pId == tonumber(i) then
				currCountrySignNum = v
			end
		end
		if totalNum == 0 then
			ret = 0
		else
			local percentage = math.floor(currCountrySignNum / totalNum * 100 + 0.5)
			ret = percentage
		end
	else
		ret = 0
	end
	return ret
end
--[[
	@des 	: 获取报名人数最少的国家ID
	@param 	: 
	@return : 
--]]
function getMinNumCountry( ... )
	local minID = 1
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	if (signUpInfo and signUpInfo.country_sign_num) then
		local signUpNumAry = signUpInfo.country_sign_num
		-- 报名人数最少的国家的人数和国家ID
		local minNum = tonumber(signUpNumAry["1"])
		for i,v in pairs(signUpNumAry) do
			v = tonumber(v)
			if minNum > v then
				minNum = v
				minID = tonumber(i)
			end
		end
	end
	return minID
end
--[[
	@des 	: 获取报名时间
	@param 	: 
	@return : 
--]]
function getSignedUpTime( ... )
	-- body
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	if (signUpInfo) then
		return signUpInfo.signup_time
	end
	return nil
end
--[[
	@des 	: 设置报名时间
	@param 	: 
	@return : 
--]]
function setSignedUpTime( time )
	-- body
	time = time or TimeUtil.getSvrTimeByOffset()
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	signUpInfo.signup_time = time
end
--[[
	@des 	: 是否已经报名
	@param 	: 
	@return : 
--]]
function isSignedUp( ... )
	local signedUpTime = getSignedUpTime()
	local countryId = getSignedCountryID()
	if ((signedUpTime and tonumber(signedUpTime)~=0) or (countryId and tonumber(countryId)~=0)) then
		return true
	else
		return false
	end
end
--[[
	@des 	: 报名的国家的报名人数+1
	@param 	: 
	@return : 
--]]
function setSignNumByID( id )
	-- body
	local signUpInfo = CountryWarMainData.getSignUpInfo()
	if (signUpInfo and signUpInfo.country_sign_num) then
		signUpInfo.country_sign_num[tostring(id)] = tonumber(signUpInfo.country_sign_num[tostring(id)]) + 1
	end
end
--[[
	@des 	: 获取报名奖励
	@param 	: 
	@return : 
--]]
function getSignReward( ... )
	require "db/DB_National_war"
	local rewardStr = DB_National_war.getDataById(1).sign_rewards
	local rewardAry = ItemUtil.getItemsDataByStr(rewardStr)
	return rewardAry
end





