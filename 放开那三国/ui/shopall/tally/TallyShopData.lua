-- FileName: TallyShopData.lua
-- Author: FQQ
-- Date: 2016-01-07
-- Purpose: 兵符商店Data
module("TallyShopData",package.seeall)
require "db/DB_Bingfu_shop_items"
require "db/DB_Bingfu_shop"

-- 商品数据
local _goodsData = nil
-- 商品信息表
local _goodsList = nil
-- 刷新次数与价格的映射
local _costMap = nil
--[[
    @des    : 设置商品数据
    @param  : 
    @return : 
--]]
function setGoodsInfo( pData )
    _goodsData = pData
    print("_goodsData")
    print_t(_goodsData)
    local goodsList = _goodsData["goods_list"]
    _goodsList = {}
    for id,num in pairs(goodsList) do
        local goodInfo = DB_Bingfu_shop_items.getDataById(id)
        goodInfo.canExchangeNum = tonumber(num)
        -- 判断商品是否是碎片
        local itemData = ItemUtil.getItemsDataByStr(goodInfo.items)[1]
        if ItemUtil.isFragment(tonumber(itemData.tid)) then
            goodInfo.itemCount = ItemUtil.getCacheItemNumBy(itemData.tid)
            goodInfo.tid = itemData.tid
        end
        table.insert(_goodsList,goodInfo)
    end
    -- 解析刷新次数与价格的配置
    _costMap = {}
    local costData = (DB_Bingfu_shop.getDataById(1)).goldGost
    local costStrAry = string.split(costData,",")
    for i,costStr in ipairs(costStrAry) do
        local costSubStrAry = string.split(costStr,"|")
        table.insert(_costMap,{time = tonumber(costSubStrAry[1]),goldNum = tonumber(costSubStrAry[2])})
        -- _costMap[tonumber(costSubStrAry[1])] = tonumber(costSubStrAry[2])
    end

end
--[[
    @des    : 获取商品列表
    @param  : 
    @return : 
--]]
function getGoodsList( ... )
    return _goodsList
end
--[[
    @des    : 获取指定商品兑换次数
    @param  : 
    @return : 
--]]
function getGoodsNumById( pID )
    return tonumber(_goodsData["goods_list"][tostring(pID)])
end
--[[
    @des    : 设置指定商品的可购买次数和已拥有次数
    @param  : 
    @return : 
--]]
function setGoodNum( pGoodInfo,pNum )
    for i,goodInfo in ipairs(_goodsList) do
        if goodInfo.id == pGoodInfo.id then
            if not changeExchangeNum then
                goodInfo.canExchangeNum = goodInfo.canExchangeNum - 1
            end
        end
        if goodInfo.tid == pGoodInfo.tid then
            if(goodInfo.itemCount ~= nil)then
                goodInfo.itemCount = goodInfo.itemCount + pNum
            end
        end
    end
end
--[[
    @des    : 获取免费刷新次数
    @param  : 
    @return : 
--]]
function getFreeTimes( ... )
    return tonumber(_goodsData["free_refresh_num"])
end
--[[
    @des    : 获取金币刷新次数
    @param  : 
    @return : 
--]]
function getGoldTime( ... )
    return tonumber(_goodsData["gold_refresh_num"])
        -- return 30
end
--[[
    @des    : 获取刷新需要花费的金币
    @param  : 
    @return : 
--]]
function getGoldCost()
    local goldCost =0
    local freeTimes = getFreeTimes()
    if freeTimes == 0 then
        local curTime = getGoldTime() + 1
        for i = 1, #_costMap do
            local time = _costMap[i].time
            local goldNum = _costMap[i].goldNum
            if curTime  <= time  then
                goldCost = goldNum
                break
            end
        end
    end
    --     for time,goldNum in pairs(_costMap) do
    --         if curTime  <= time  then
    --             goldCost = goldNum
    --             break
    --         end
    --     end
    -- end
    return goldCost
end


--[[
    @des    : 获取刷新的最大次数
    @param  : 
    @return : 
--]]
function getMaxFefreshNumber( ... )
    local maxRefreshNum = 0
    for i =1,#_costMap do
        local time = _costMap[i].time
        if time >= maxRefreshNum then
            maxRefreshNum = time
        end
    end
    -- for time, goldNum in pairs(_costMap) do
    --     if time >= maxRefreshNum then
    --         maxRefreshNum = time
    --     end
    -- end
    return maxRefreshNum
end
--[[
    @des    : 获取刷新的最大次数
    @param  : 
    @return : 
--]]
-- function getMaxGoldCost( ... )
--     local getMaxGoldCost = 0
--     for time, goldNum in pairs(_costMap) do
--         if time >= getMaxGoldCost then
--             getMaxGoldCost = goldNum
--         end
--     end
--     return getMaxGoldCost
-- end


