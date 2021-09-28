-- FileName: GuildBoxData.lua 
-- Author: licong 
-- Date: 14-11-13 
-- Purpose: 军团宝箱数据


module("GuildBoxData", package.seeall)

require "db/DB_Legion_chest"

--[[
	@des 	:得到每天开宝箱上限
	@param 	:
	@return :num
--]]
function getOpenBoxMaxNum()
	local dbData = DB_Legion_chest.getDataById(1)
	return tonumber(dbData.BoxTimes)
end

--[[
	@des 	:得到开一次宝箱需要的功勋值
	@param 	:
	@return :num
--]]
function getOpenBoxCostMeritNum()
	local dbData = DB_Legion_chest.getDataById(1)
	return tonumber(dbData.payBox)
end

--[[
	@des 	:得到宝箱奖励预览字符串
	@param 	:
	@return :str
--]]
function getBoxRewardPreview()
	local dbData = DB_Legion_chest.getDataById(1)
	return dbData.RewardPreview
end





































