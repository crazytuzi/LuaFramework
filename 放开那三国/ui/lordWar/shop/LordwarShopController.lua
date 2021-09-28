-- Filename: LordWarShopController.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店控制器

module("LordwarShopController", package.seeall)
require "script/ui/lordWar/shop/LordwarShopService"
require "script/model/user/UserModel"
require "script/ui/lordWar/shop/LordwarShopData"
function buy( pGoodIndex,pNum )
	--判断背包满
	require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
	local itemInfo = LordwarShopData.getItemList()[pGoodIndex]
	print_t(itemInfo)
	--判断兑换次数是否够用
	if tonumber(itemInfo.exchangeCount) ~= 0 
		and tonumber(itemInfo.exchangeCount) - tonumber(itemInfo.exchangeNum) < pNum then
			AnimationTip.showTip(GetLocalizeStringBy("lcyx_1908")) -- 兑换次数不足，无法兑换
			return
	end
	--判断争霸令是否够用
	local needWm = tonumber(itemInfo.costNum) * pNum
	if UserModel.getWmNum() < needWm then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_1909")) --争霸令不足无法兑换
		return
	end
	LordwarShopService.buy(pGoodIndex, pNum,function ( ... )
		--更新兑换次数
		LordwarShopData.setItemExchangeNum(pGoodIndex,LordwarShopData.getItemExchangeNum(pGoodIndex) + pNum)
		--更新争霸令
		UserModel.addWmNum(-needWm)
		--刷新显示的争霸令
		LordwarShopLayer.updateWmLable()

		--兑换成功增加物品
		local itemDesStr = itemInfo.type.."|"..itemInfo.tid.."|"..tonumber(itemInfo.itemNum) * pNum
    	local rewardInDb = ItemUtil.getItemsDataByStr(itemDesStr)
    	LordwarShopLayer.updateCell()
    	ReceiveReward.showRewardWindow(rewardInDb,nil,1000, -1000)
	end)
end