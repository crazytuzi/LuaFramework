--
-- Author: xurui
-- Date: 2016-07-27 17:59:48
--
local QBaseModel = import("..models.QBaseModel")
local QExchangeShop = class("QExchangeShop", QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")

function QExchangeShop:ctor(options)
	QExchangeShop.super.ctor(self)

	self._shopBuyInfos = {}
end

function QExchangeShop:updateShopInfo(shops)
    if shops == nil then return end

    for _, shop in pairs(shops) do
        self._shopBuyInfos[shop.id] = shop
    end
end

function QExchangeShop:getShopBuyInfo(shopId)
    if self._shopBuyInfos[tonumber(shopId)] == nil then return {} end

    local buyInfo = {}
    local info = string.split(self._shopBuyInfos[tonumber(shopId)].buy_info, ";")
    for i = 1, #info do
        local infos = string.split(info[i], ",")
        buyInfo[infos[1]] = infos[2]
    end
    local onceInfo = string.split(self._shopBuyInfos[tonumber(shopId)].buy_once_info, ";")
    for i = 1, #onceInfo do
        local infos = string.split(onceInfo[i], ",")
        buyInfo[infos[1]] = infos[2]
    end
    return buyInfo
end

-- 通过量表获得商店物品信息
function QExchangeShop:getShopInfoById(shopId)
	if shopId == nil then return {} end
    
    if shopId == SHOP_ID.monthSignInShop then
       local config = db:getStaticByName("check_in_exchange_shop") 
       local shopInfos = config[tostring(shopId)] or {}
       local yearAndMonthKey = remote.monthSignIn:getMonthSignInYearMonthKey()
       local tbl = {}
       for _, shopInfo in ipairs(shopInfos) do
            if shopInfo.month == yearAndMonthKey then
                table.insert(tbl, shopInfo)
            end
       end
       return tbl
    else
	   local shopInfos = QStaticDatabase:sharedDatabase():getExchangeShopInfo()
	   return shopInfos[tostring(shopId)] or {}
    end
end

function QExchangeShop:checkExchangeShopRedTipsById(shopId)
    if self:checkCanRefreshShop(shopId) then
        return true
    end
    local shopInfo = remote.stores:getShopResousceByShopId(shopId) or {}
    if remote.stores:checkAwardsShopCanBuyByShopId(shopInfo.arawdsId) then
        return true
    end
    return false
end

function QExchangeShop:checkCanRefreshShop(shopId)
    local lastRefreshTime = self:getLastShopGetTimeById(shopId)/1000
    local beforeTime = q.getTimeForHMS("5", "00", "00")+5
    if q.serverTime() < beforeTime then 
        beforeTime = beforeTime - 24 * 3600 
    end
    if lastRefreshTime < beforeTime then
        return true
    end
    return false
end

function QExchangeShop:getLastShopGetTimeById(shopId)
    if self._shopBuyInfos[tonumber(shopId)] == nil then return 0 end
    return self._shopBuyInfos[tonumber(shopId)].last_call_get_shop_time or 0 
end

-------------------------------request Handler------------------------------

function QExchangeShop:shopResponse(response, success)

    self:updateShopInfo(response.exchangeShops)

	if success and type(success) == "function" then
		success()
	end
end

-- 拉取兑换商店信息
function QExchangeShop:exchangeShopGetRequest(shopId, success, fail, status)
    local request = {api = "EXCHANGE_SHOP_GET", shopGetRequest = {shopId = shopId}}
    local successCallback = function (response)
        self:shopResponse(response, success)
    end
    app:getClient():requestPackageHandler("EXCHANGE_SHOP_GET", request, successCallback, fail)
end

-- 兑换物品
function QExchangeShop:exchangeShopBuyRequest(shopId, gridId, buyCount, success, fail, status)
    local request = {api = "EXCHANGE_SHOP_BUY", exchangeShopBuyRequest = {shopId = shopId, grid_id = gridId, buyCount = buyCount}}
    local successCallback = function (response)
        self:shopResponse(response, success)
        if shopId == SHOP_ID.metalCityShop then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.METALCITY_STORE_BUY_TASK_EVENT, buyCount)
        elseif shopId == SHOP_ID.sparShop then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.SPAR_STORE_BUY_TASK_EVENT, buyCount)
        elseif shopId == SHOP_ID.blackRockShop then
            app.taskEvent:updateTaskEventProgress(app.taskEvent.BLACKROCK_STORE_BUY_TASK_EVENT, buyCount)
        elseif shopId == SHOP_ID.sanctuaryShop then
            remote.user:addPropNumForKey("todaySanctuaryShopCount",buyCount)--记录全大陆精英赛购买货物次数
            app.taskEvent:updateTaskEventProgress(app.taskEvent.SANCTUARY_STORE_BUY_TASK_EVENT, buyCount)
        elseif shopId == SHOP_ID.mockbattleShop then
            remote.user:addPropNumForKey("todayMockBattleShopCount",buyCount)--记录大师模拟赛购买货物次数
        elseif shopId == SHOP_ID.godarmShop then
            remote.user:addPropNumForKey("todayTotemChallengeShopCount",buyCount)--记录圣柱挑战购买货物次数

        end
    end
    app:getClient():requestPackageHandler("EXCHANGE_SHOP_BUY", request, successCallback, fail)
end


return QExchangeShop