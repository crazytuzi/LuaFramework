-- FileName: CountryWarShopData.lua
-- Author: FQQ
-- Date: 2015-11-2
-- Purpose: 国战商店数据层

module("CountryWarShopData",package.seeall)
require "db/DB_National_war_shop"

local _shopServerInfo = {}
local _itemArray = {}

function getItemList( ... )
    if not table.isEmpty(_itemArray) then
        return _itemArray
    end
    for i=1,table.count(DB_National_war_shop.National_war_shop) do
        local data = DB_National_war_shop.getDataById(i)
        --添加可显示等级
        if(UserModel.getHeroLevel() >= data.display_lv)then
            local itemInfo = getItemInfo(data, i)
            table.insert(_itemArray, itemInfo)
        end
    end

        local function keySort ( dataCache1, dataCache2 )
            return tonumber(dataCache1.reorder) > tonumber(dataCache2.reorder)
        end
        table.sort( _itemArray, keySort )
   
    return _itemArray
end

function getItemInfo( p_itemConfig , p_index )
    local itemConfig = string.split(p_itemConfig.item, "|")
    -- 物品类型|ID|物品数量|货币数量|兑换数量
    local itemInfo         = {}
    itemInfo.type          = itemConfig[1]
    itemInfo.tid           = itemConfig[2]
    itemInfo.itemNum       = itemConfig[3]
    itemInfo.costNum       = p_itemConfig.cost
    itemInfo.exchangeCount = p_itemConfig.baseNum
    itemInfo.exchangeNum   = getItemExchangeNum(p_index)
    itemInfo.reorder	   = p_itemConfig.reorder
    itemInfo.needLevel 	   = p_itemConfig.needLevel
    itemInfo.limitType     = p_itemConfig.limitType
    itemInfo.display_lv	   = p_itemConfig.display_lv
    itemInfo.id            = p_itemConfig.id
    return itemInfo
end


function setShopServerInfo( p_shopInfo )
     _shopServerInfo = p_shopInfo or {}
    print("set_shopServerInfo")
    print_t(_shopServerInfo)
end
function getShopServerInfo( ... )
    print("get_shopServerInfo")
    print_t(_shopServerInfo)
    return _shopServerInfo
end

--获取物品兑换次数
function getItemExchangeNum( p_index )
    if _shopServerInfo.good_list[tostring(p_index)] then
        return tonumber(_shopServerInfo.good_list[tostring(p_index)]) or 0
    else
        return 0
    end
end

--设置物品兑换次数
function setItemExchangeNum( p_index, pNum )
    -- if _shopServerInfo.good_list[tostring(p_index)] == nil then
    --     _shopServerInfo.good_list[tostring(p_index)] = {}
    -- end
    -- _shopServerInfo.good_list[tostring(p_index)] = tonumber(pNum)
     _itemArray[p_index].exchangeNum = pNum

end

function isShopOpen()
    local itemArray = getItemList()
    if table.count(itemArray) > 0 then
        return true
    else
        return false
    end
end


--得到国战积分
function getCopoint( ... )
    local copoint = getShopServerInfo().copoint or 0
    print("国战积分:",tonumber(copoint))
    return tonumber(copoint)

end
--修改国战积分
function setCopoint( pNum )
    _shopServerInfo.copoint = tonumber(getCopoint()) + pNum
end
