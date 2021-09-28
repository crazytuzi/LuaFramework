-- FileName: CountryWarShopController.lua
-- Author: FQQ
-- Date: 2015-11-2
-- Purpose: 国战商店控制器

module ("CountryWarShopController",package.seeall)
require "script/ui/countryWar/shop/CountryWarShopLayer"
function buy( pGoodIndex,pNum,callBack )
    --判断背包满
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local itemInfo = CountryWarShopData.getItemList()[pGoodIndex]
    print_t(itemInfo)
    --判断兑换次数是否够用
    if tonumber(itemInfo.exchangeCount) ~= 0
        and  tonumber(itemInfo.exchangeNum) < pNum then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_1908")) -- 兑换次数不足，无法兑换
        return
    end
    --判断国战积分是否够用
    local needWm = tonumber(itemInfo.costNum) * pNum
    if CountryWarShopData.getCopoint() < needWm then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_030")) --国战积分不足无法兑换
        return
    end
    CountryWarShopService.buy(itemInfo.id, pNum,function ( ... )
        --更新兑换次数
        local itemInfoNum = CountryWarShopData.getItemList()[pGoodIndex].exchangeNum 
        CountryWarShopData.setItemExchangeNum(pGoodIndex,itemInfoNum - pNum)
        --更新国战积分
        CountryWarShopData.setCopoint(-needWm)
        callBack(itemInfoNum - pNum)

        --刷新显示的国战积分
        CountryWarShopLayer.updateWmLable()
        --更新显示
        CountryWarShopLayer.updateCell()
        --兑换成功增加物品
        local itemDesStr = itemInfo.type.."|"..itemInfo.tid.."|"..tonumber(itemInfo.itemNum) * pNum
        local rewardInDb = ItemUtil.getItemsDataByStr(itemDesStr)
        ReceiveReward.showRewardWindow(rewardInDb,nil,1000, -1000)
    end)
end

