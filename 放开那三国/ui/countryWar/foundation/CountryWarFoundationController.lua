-- FileName : CountryWarFoundationController.lua
-- Author   : YangRui
-- Date     : 2015-11-23
-- Purpose  : 

module("CountryWarFoundationController", package.seeall)

--[[
	@des 	: 兑换
	@param 	: 
	@return : 
--]]
function exchangeCocoin( pNum, pCallback )
	-- ret:string	ok|fail|poor|limit,成功|失败|数值不足|已达上限
	-- 金币数量是否满足
	local goldNum = UserModel.getGoldNumber()
	local rechargeCountryWarCoinCostNum = pNum*CountryWarFoundationData.getGoldToCoutryWarCoinCost()
	if goldNum < rechargeCountryWarCoinCostNum then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5018"))
		return
	end
	-- 是否有兑换数量
	if pNum <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5019"))
		return
	end
	-- callback
	local requestCallback = function( pData )
		if pData == "ok" then
			-- 扣除相应的金币
			local needGoldNum = pNum*CountryWarFoundationData.getGoldToCoutryWarCoinCost()
			UserModel.addGoldNumber(-needGoldNum)
			-- 添加国战币
			CountryWarMainData.addCocoin(pNum)
			-- 刷新玩家的金币&国战币
			require "script/ui/countryWar/war/CountryWarPlaceLayer"
			CountryWarPlaceLayer.refreshCoin()
			if pCallback ~= nil then
				pCallback()
			end
		end
	end
	CountryWarFoundationService.exchangeCocoin(pNum,requestCallback)
end
