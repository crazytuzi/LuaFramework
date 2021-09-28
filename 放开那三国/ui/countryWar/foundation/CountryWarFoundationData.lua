-- FileName : CountryWarFoundationData.lua
-- Author   : YangRui
-- Date     : 2015-11-23
-- Purpose  : 

module("CountryWarFoundationData", package.seeall)

require "db/DB_National_war"

local _haveCountryWarCoinNum = 0  -- 已拥有的数量

--[[
	@des 	: 设置拥有的国战币数量
	@param 	: 
	@return : 
--]]
function setHaveCountryWarCoinNum( pNum )
	_haveCountryWarCoinNum = tonumber(pNum)
end

--[[
	@des 	: 获取拥有的国战币数量
	@param 	: 
	@return : 
--]]
function getHaveCountryWarCoinNum( ... )
	return _haveCountryWarCoinNum
end

--[[
	@des 	: 增加拥有的国战币数量
	@param 	: 
	@return : 
--]]
function addHaveCountryWarCoinNum( pNum )
	_haveCountryWarCoinNum = _haveCountryWarCoinNum+tonumber(pNum)
end

--[[
	@des 	: 当前金币还可兑换多少国战币
	@param 	: 
	@return : 
--]]
function curGoldCanBuyNum( ... )
	local leftBuyNum = getCarryUpper()-CountryWarMainData.getCocoin()
	local haveGoldNum = UserModel.getGoldNumber()
	local canBuyNum = haveGoldNum/getGoldToCoutryWarCoinCost()
	if leftBuyNum > canBuyNum then
		leftBuyNum = canBuyNum
	end

	return tonumber(leftBuyNum)
end

--[[
	@des 	: 计算当前金币能兑换多少国战币
	@param 	: 
	@return : 
--]]
function calcGoldCanChargeNum( ... )
	local haveGoldNum = UserModel.getGoldNumber()
	local canBuyNum = haveGoldNum/getGoldToCoutryWarCoinCost()
	return canBuyNum
end

------------------------------------------------------配置------------------------------------------------------

--[[
	@des 	: 获取金币兑换国战币的消耗
	@param 	: 
	@return : 
--]]
function getGoldToCoutryWarCoinCost( ... )
	local cost = DB_National_war.getDataById(1).gold_coin
	return tonumber(cost)
end

--[[
	@des 	: 获取携带上限
	@param 	: 
	@return : 
--]]
function getCarryUpper( ... )
	local upper = DB_National_war.getDataById(1).coin_max
	return tonumber(upper)
end
