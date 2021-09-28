-- FileName: CountryWarWorshipData.lua
-- Author: yangrui
-- Date: 2015-11-16
-- Purpose: 国战膜拜Data

module("CountryWarWorshipData", package.seeall)

require "db/DB_National_war"

--[[
	@des 	: 获取膜拜时间
	@param 	: 
	@return : 
--]]
function getWorshipTime( ... )
	local worshipData = CountryWarMainData.getWorShipInfo()  -- 膜拜数据
	return tonumber(worshipData.worship_time)
end

--[[
	@des 	: 设置膜拜时间
	@param 	: 
	@return : 
--]]
function setWorshipTime( pTime )
	local worshipData = CountryWarMainData.getWorShipInfo()  -- 膜拜数据
	worshipData.worship_time = pTime
end



---------------------------------------------------配置---------------------------------------------------

--[[
	@des 	: 获取膜拜奖励
	@param 	: 
	@return : 
--]]
function getWorshipRewardData( ... )
	-- TEST "1|0|100,1|0|100"
	return DB_National_war.getDataById(1).worship_reward
end
