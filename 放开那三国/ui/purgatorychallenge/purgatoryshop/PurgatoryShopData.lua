-- Filename: PurgatoryShopData.lua
-- Author: lichenyang
-- Date: 2015-05-06
-- Purpose: 个人跨服赛商店数据层
require "db/DB_Lianyutiaozhan_shop"
module("PurgatoryShopData", package.seeall)

local _shopServerInfo = {}

function getItemList( ... )
    local itemArray = {}
    local index = 1
    for k,v in pairs(DB_Lianyutiaozhan_shop.Lianyutiaozhan_shop) do
        local str = string.split(tostring(k),"_")
        local data = DB_Lianyutiaozhan_shop.getDataById(tonumber(str[2]))
        if(UserModel.getHeroLevel() >= data.display_lv)then
            local itemInfo = getItemInfo(data, str[2])
            if(itemInfo~=nil)then
                itemArray[index] = itemInfo
                index = index+1
            end
        end
    end
    local function keySort ( itemArray1, itemArray2 )
        return tonumber(itemArray1.reorder) < tonumber(itemArray2.reorder)
    end
    table.sort( itemArray, keySort )
    return itemArray
end

function getItemInfo( p_itemConfig , p_index)
    local itemConfig = string.split(p_itemConfig.item, "|")
    -- 物品类型|ID|物品数量|货币数量|兑换数量
    if(tonumber(p_itemConfig.isSold))==1 then
        local itemInfo         = {}
        itemInfo.id            = p_itemConfig.ID
        itemInfo.type          = itemConfig[1]
        itemInfo.tid           = itemConfig[2]
        itemInfo.itemNum       = itemConfig[3]
        itemInfo.costNum       = p_itemConfig.cost
        itemInfo.limitType     = p_itemConfig.limitType
        itemInfo.exchangeCount = p_itemConfig.baseNum
        itemInfo.exchangeNum   = getItemExchangeNum(p_index)
        itemInfo.reorder	   = p_itemConfig.reorder
        itemInfo.needLevel 	   = p_itemConfig.needLevel
        itemInfo.display_lv	   = p_itemConfig.display_lv
        return itemInfo
    end
end


function getShopServerInfo( ... )
    return _shopServerInfo
end

function setShopServerInfo( p_shopInfo )
    _shopServerInfo = p_shopInfo or {}
end

function getItemExchangeNum( p_index )
    if _shopServerInfo[tostring(p_index)] then
        return tonumber(_shopServerInfo[tostring(p_index)].num) or 0
    else
        return 0
    end
end

function setItemExchangeNum( p_index, pNum )
    if _shopServerInfo[tostring(p_index)] == nil then
        _shopServerInfo[tostring(p_index)] = {}
    end
    _shopServerInfo[tostring(p_index)].num = tonumber(pNum)
    printTable("_shopServerInfo", _shopServerInfo)
end

function isShopOpen()
    local itemArray = getItemList()
    if table.count(itemArray) > 0 then
        return true
    else
        return false
    end
end


