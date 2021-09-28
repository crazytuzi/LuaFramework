
local Shop = {}

function Shop.requestTabs(cb, failCb)
    Pomelo.ShopMallHandler.getMallTabsRequest(function (ex,sjson)
        if not ex then
            local data = sjson:ToData()
            
            cb(data.s2c_tabs)
        else
           failCb()
        end
    end
    )
end

function Shop.requestScoreShopItemList(cb, failCb)
    Pomelo.ShopMallHandler.getMallScoreItemListRequest(function (ex,sjson)
        if not ex then
            local data = sjson:ToData()
            
            cb(data.s2c_items)
        else
           failCb()
        end
    end,
    XmdsNetManage.PackExtData.New(false, false, failCb)
    )
end

function Shop.requestShopItemList(moneyType, itemType, cb, failCb)
    Pomelo.ShopMallHandler.getMallItemListRequest(moneyType, itemType, function (ex,sjson)
        if not ex then
            local data = sjson:ToData()
            
            cb(data.s2c_items, data.s2c_endTime)
        else
            failCb()
        end
    end,
    XmdsNetManage.PackExtData.New(false, false, failCb)
    )
end

function Shop.requestBuyScoreShopItem(itemId, cb)
    Pomelo.ShopMallHandler.buyMallScoreItemRequest(itemId, function (ex,sjson)
        if not ex then
            local data = sjson:ToData()
            cb()
        end
    end)
end

function Shop.requestBuyShopItem(itemId, count, playerId, buyType, cb)
    Pomelo.ShopMallHandler.buyMallItemRequest(itemId, count, playerId or "", buyType, function (ex,sjson)
        if not ex then
            local data = sjson:ToData()
            local totalNum = data.total_num
            cb(totalNum)
        end
    end)
end

return Shop
