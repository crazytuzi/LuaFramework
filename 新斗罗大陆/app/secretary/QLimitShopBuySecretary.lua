-- @Author: xurui
-- @Date:   2019-08-07 17:27:37
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-07 14:51:12
local QBaseSecretary = import(".QBaseSecretary")
local QLimitShopBuySecretary = class("QLimitShopBuySecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")

function QLimitShopBuySecretary:ctor(options)
	QLimitShopBuySecretary.super.ctor(self, options)
end

function QLimitShopBuySecretary:executeSecretary()
    local shopId = self._config.shopId
    
    if self:checkSecretaryIsNotActive() then
        remote.secretary:nextTaskRunning()
        return
    end

    local refreshShop = remote.exchangeShop:checkCanRefreshShop(shopId)
    if refreshShop then
        remote.exchangeShop:exchangeShopGetRequest(shopId, function()
            self:shopOnceQuickBuyRequest()
        end)
    else
        self:shopOnceQuickBuyRequest()
    end
end

function QLimitShopBuySecretary:convertSecretaryAwards(itemLog, logNum,info)
    QLimitShopBuySecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.token = tonumber(countTbl[1]) or 0
        info.money = tonumber(countTbl[2]) or 0    
    end
    return info
end

-- 限购商店购买
function QLimitShopBuySecretary:shopOnceQuickBuyRequest()
    local shopId = self._config.shopId
    local chooseItem = app:getUserOperateRecord():getShopLimitQuickBuyConfiguration(shopId)
    if q.isEmpty(chooseItem) then
        local curConfig = remote.secretary:getSecretaryConfigById(self._config.id)
        if not remote.secretary:isShowTips() then
            remote.secretary:setShowTips(true)
            app.tip:floatTip("魂师大人，您在"..(curConfig.name or "商店").."没有选中任何商品~")
        end
        remote.secretary:nextTaskRunning()
        return
    end

    local shops = remote.exchangeShop:getShopInfoById(shopId)
    local buyInfo = remote.exchangeShop:getShopBuyInfo(shopId)
    chooseItem = remote.secretary:recheckChooseItem2(shops, chooseItem)

    local myTokenNum = remote.user.token or 0
    local myMoneyNum = remote.user[self._config.resourceType] or 0
    local tbl = {}
    for _, choose in pairs(chooseItem) do
        for i, shopsItem in pairs(shops) do
            if shopsItem.grid_id == choose.gridId then
                local buyNum = buyInfo[tostring(shopsItem.grid_id)] or 0
                local leftNum = shopsItem.exchange_number - buyNum
                local buyCount = 0
                if shopsItem.resource_1 == "token" then
                    local price = shopsItem.resource_number_1 or 0
                    for i = 1, leftNum do
                        if myTokenNum - price > 0 then
                            myTokenNum = myTokenNum - price
                        else
                            break
                        end
                        buyCount = i
                    end
                else
                    local price = shopsItem.resource_number_1 or 0
                    for i = 1, leftNum do
                        if myMoneyNum - price > 0 then
                            myMoneyNum = myMoneyNum - price
                        else
                            break
                        end
                        buyCount = i
                    end
                end
                if buyCount > 0 then
                    table.insert(tbl, {gridId = choose.gridId, buyCount = buyCount})
                elseif leftNum > 0 and not remote.secretary:isShowTips() then
                    remote.secretary:setShowTips(true)
                    local wallet = remote.items:getWalletByType(shopsItem.resource_1) or {}
                    app.tip:floatTip((wallet.nativeName or "货币").."不足~")
                end
                break
            end
        end
    end

    local callback = function(data)
        local buyCount_ = 0
        for k,v in pairs(tbl or {}) do
            if v.buyCount and v.buyCount > 0 then
                buyCount_ = buyCount_ + v.buyCount
            end
        end    
        if buyCount_ > 0 then
            if shopId == SHOP_ID.sanctuaryShop then
                remote.user:addPropNumForKey("todaySanctuaryShopCount",buyCount_)--记录全大陆精英赛购买货物次数
            elseif shopId == SHOP_ID.mockbattleShop then
                remote.user:addPropNumForKey("todayMockBattleShopCount",buyCount_)--记录大师模拟赛购买货物次数
            elseif shopId == SHOP_ID.godarmShop then
                remote.user:addPropNumForKey("todayTotemChallengeShopCount",buyCount_)--记录圣柱挑战购买货物次数
            end
        end
        remote.secretary:updateSecretaryLog(data) 
        remote.secretary:nextTaskRunning()
    end

    if next(tbl) then
        self:shopLimitQuickBuySecretaryRequest(shopId, tbl, callback)
    else
        remote.secretary:nextTaskRunning()
    end
end

--刷新widget数据
function QLimitShopBuySecretary:refreshWidgetData(widget, itemData, index)
    QLimitShopBuySecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget and not self:checkSecretaryIsNotActive() then
        widget:setResourseIcon()
    end
end

-- 一键购买
function QLimitShopBuySecretary:shopLimitQuickBuySecretaryRequest(shopId, gridInfos, success, fail, status)
    local exchangeShopQuickBuyRequest = { shopId = shopId, gridInfos = gridInfos, isSecretary = true}
    local request = { api = "EXCHANGE_SHOP_QUICK_BUY", exchangeShopQuickBuyRequest = exchangeShopQuickBuyRequest }
    app:getClient():requestPackageHandler("EXCHANGE_SHOP_QUICK_BUY", request, success, fail)
end

function QLimitShopBuySecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreDailyQuickBuy", 
		options = {isSecretary = true, shopId = self._config.shopId}}, {isPopCurrentDialog = false})
end

return QLimitShopBuySecretary
