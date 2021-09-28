-- FileName: BlackShopController.lua 
-- Author: yangrui 
-- Date: 15-8-28
-- Purpose: function description of module 

module ("BlackshopController", package.seeall)

--[[
	@des 	: 兑换物品
	@param 	: pGoodId  兑换配置id  pGoodNum  兑换次数
	@return : 
--]]
function exchangeBlackshop( pGoodId, pGoodNum )
	local pGoodId = tonumber(pGoodId)
	local reqItems = BlackshopData.getConvertNeedItem( pGoodId )
	local acqItems = BlackshopData.getConvertGetItem( pGoodId )

	local requestCallback = function( ... )
		-- 增加已兑换次数
		BlackshopData.addConvertedTimes(pGoodId,pGoodNum)
		-- 兑换后扣除所需兑换物品
		for i=1,pGoodNum do
			for i=1,#reqItems do
				if ( reqItems[i].type == "silver" ) then
					UserModel.addSilverNumber( -tonumber(reqItems[i].num) )
				elseif (reqItems[i].type == "gold") then
					UserModel.addGoldNumber( -tonumber(reqItems[i].num) )
				elseif (reqItems[i].type == "prestige") then
					UserModel.addPrestigeNum( -tonumber(reqItems[i].num) )
				elseif (reqItems[i].type == "honor") then
					UserModel.addHonorNum( -tonumber(reqItems[i].num) )
				end
			end
		end
		-- 展示兑换结果
		local acquire = {}
		local tmp = {}
		tmp[tostring(acqItems[1].tid)] = acqItems[1].num*pGoodNum
		acquire[tostring(acqItems[1].type)] = tmp

		local itemData = ActiveCache.getListDesItemData( acquire )
		-- BlackshopLayer.refreshUI()
	    require "script/ui/item/ReceiveReward"
	    ReceiveReward.showRewardWindow( itemData,BlackshopLayer.refreshUI, 1010 )
	end

	BlackshopService.exchangeBlackshop(pGoodId, pGoodNum, requestCallback)
end
