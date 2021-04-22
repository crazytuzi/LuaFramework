-- @Author: xurui
-- @Date:   2019-08-07 17:27:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-08-22 18:45:43
local QBaseSecretary = import(".QBaseSecretary")
local QSanctuaryShopBuySecretary = class("QSanctuaryShopBuySecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")

function QSanctuaryShopBuySecretary:ctor(options)
	QSanctuaryShopBuySecretary.super.ctor(self, options)
end

function QSanctuaryShopBuySecretary:executeSecretary()
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

-- 限购商店购买
function QSanctuaryShopBuySecretary:shopOnceQuickBuyRequest()
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

        for k,v in pairs(tbl or {}) do
            if v.buyCount and v.buyCount > 0 then
                remote.user:addPropNumForKey("todaySanctuaryShopCount",v.buyCount)
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

-- 一键购买
function QSanctuaryShopBuySecretary:shopLimitQuickBuySecretaryRequest(shopId, gridInfos, success, fail, status)
    local exchangeShopQuickBuyRequest = { shopId = shopId, gridInfos = gridInfos, isSecretary = true}
    local request = { api = "EXCHANGE_SHOP_QUICK_BUY", exchangeShopQuickBuyRequest = exchangeShopQuickBuyRequest }
    fail = function(data)
        remote.secretary:executeInterruption()
    end

    app:getClient():requestPackageHandler("EXCHANGE_SHOP_QUICK_BUY", request, success, fail)
end

function QSanctuaryShopBuySecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStoreDailyQuickBuy", 
		options = {isSecretary = true, shopId = self._config.shopId}}, {isPopCurrentDialog = false})
end

return QSanctuaryShopBuySecretary
