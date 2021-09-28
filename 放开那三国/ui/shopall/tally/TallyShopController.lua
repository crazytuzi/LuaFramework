-- FileName: TallyShopController.lua
-- Author: FQQ
-- Date: 2016-01-07
-- Purpose: 兵符商店Controller
module("TallyShopController",package.seeall)
require "script/ui/shopall/tally/TallyShopService"
--[[
	@des 	: 商店信息
	@param 	: 
	@return : 
--]]
function getTallyInfo( pCallBack )
    -- body
    local callBack = function ( pData )
        TallyShopData.setGoodsInfo(pData)
        if pCallBack then
            pCallBack()
        end
    end
    TallyShopService.getTallyInfo(callBack)
end
--[[
	@des 	: 刷新商店信息
	@param 	: 
	@return : 
--]]
function refreshTallyGoodsList( pCallBack )
    -- 金币是否充足
    local goldCost = TallyShopData.getGoldCost()
    print("goldCost~~~",goldCost)
    if goldCost > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        return
    end
    local callBack = function ( pData )
        -- 刷新成功，减去金币
        UserModel.addGoldNumber(-goldCost)
        TallyShopData.setGoodsInfo(pData)
        if pCallBack then
            pCallBack()
        end
    end
    TallyShopService.refreshTallyGoodsList(callBack)
end
--[[
	@des 	: 购买商品
	@param 	: pGoodInfo 商品信息
	@param 	: pNum 购买数量
	@return : 
--]]
function buyTally( pGoodInfo,pNum )
    --背包判断
    if(ItemUtil.isBagFull() == true )then
        TallyShopLayer.closeButtonCallFunc()
        return
    end
    -- body
    pNum = pNum or 1
    -- 1.可兑换次数判断
    local canExchangeNum = pGoodInfo.canExchangeNum
    if canExchangeNum < 1 then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1009"))
        return
    end
    -- 2.是否足够支付
    -- 支付类型信息
    local itemCostData = ItemUtil.getItemsDataByStr(pGoodInfo.cost)[1]
    if itemCostData.type == "tally_point" then
        -- 兵符积分
        if itemCostData.num > UserModel.getTallyPointNumber() then
            AnimationTip.showTip(GetLocalizeStringBy("fqq_052"))
            return
        end
    elseif itemCostData.type == "silver" then
        -- 银币
        if (itemCostData.num > UserModel.getSilverNumber()) then
            AnimationTip.showTip(GetLocalizeStringBy("zz_93"))
            return
        end
    elseif itemCostData.type == "gold" then
        -- 金币
        if (itemCostData.num > UserModel.getGoldNumber()) then
            AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
            return
        end
    end
    local callBack = function ( ... )
        -- 购买完成后
        if itemCostData.type == "tally_point" then
            -- 兵符积分
            UserModel.addTallyPointNumber(-itemCostData.num)
        elseif itemCostData.type == "silver" then
            -- 银币
            UserModel.addSilverNumber(-itemCostData.num)
        elseif itemCostData.type == "gold" then
            -- 金币
            UserModel.addGoldNumber(-itemCostData.num)
        end
        TallyShopData.setGoodNum(pGoodInfo,pNum)
        -- 刷新UI
        TallyShopLayer.updateAfterBuy()
        -- 显示奖励
        require "script/ui/item/ReceiveReward"
        local itemData = ItemUtil.getItemsDataByStr(pGoodInfo.items)
        ReceiveReward.showRewardWindow(itemData, nil, 999, -870)
    end
    TallyShopService.buyTally(pGoodInfo.id,1,callBack)
end

