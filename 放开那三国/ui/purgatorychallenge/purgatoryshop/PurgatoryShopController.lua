-- Filename: PurgatoryShopController.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店控制器

module("PurgatoryShopController", package.seeall)
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopService"
require "script/ui/purgatorychallenge/PurgatoryData"
require "script/model/user/UserModel"
require "script/ui/purgatorychallenge/purgatoryshop/PurgatoryShopData"
function buy( pGoodIndex,pNum )
	local index = 1
	for k,v in pairs(PurgatoryShopData.getItemList()) do
		if(tonumber(v.id)==tonumber(pGoodIndex))then
			index = k
			break
		end
	end
	local itemInfo = PurgatoryShopData.getItemList()[index]
	--判断兑换次数是否够用
	if tonumber(itemInfo.exchangeCount) ~= 0
		and tonumber(itemInfo.exchangeCount) - tonumber(itemInfo.exchangeNum) < pNum then
			AnimationTip.showTip(GetLocalizeStringBy("lcyx_1908")) -- 兑换次数不足，无法兑换
			return
	end
	--判断争霸令是否够用
	local needWm = tonumber(itemInfo.costNum) * pNum
	local purgatoryData = PurgatoryData.getCopyInfo()
	if tonumber(purgatoryData.hell_point) < needWm then
		AnimationTip.showTip(GetLocalizeStringBy("llp_197")) --争霸令不足无法兑换
		return
	end
	PurgatoryShopService.buy(pGoodIndex, pNum,function ( ... )
		--更新兑换次数
		PurgatoryShopData.setItemExchangeNum(pGoodIndex,PurgatoryShopData.getItemExchangeNum(pGoodIndex) + pNum)
		--更新争霸令
		PurgatoryData.addMoney(-needWm)
		--刷新显示的争霸令
		PurgatoryShopLayer.updateWmLable()

		--兑换成功增加物品
		local itemDesStr = itemInfo.type.."|"..itemInfo.tid.."|"..tonumber(itemInfo.itemNum) * pNum
    	local rewardInDb = ItemUtil.getItemsDataByStr(itemDesStr)
    	PurgatoryShopLayer.updateCell()
    	ReceiveReward.showRewardWindow(rewardInDb,nil, 1000, -1000)
	end)
end