-- Filename：	ScoreShopData.lua
-- Author：		DJN
-- Date：		2015-3-3
-- Purpose：    积分商店数据


module ("ScoreShopData", package.seeall)
require "script/model/utils/ActivityConfigUtil"

local  _shopInfo = {}     --玩家的商店信息本地缓存
function setShopInfo(p_data )
	_shopInfo = p_data
end
function getShopInfo( ... )
    -- print("取缓存数据")
    -- print_t(_shopInfo)
	return _shopInfo
end
--  分解表中物品字符串数据
function analyzeGoodsStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodTab = string.split(goodsStr, ",")
    for k,v in pairs(goodTab) do
        local data = {}
        local tab = string.split(v, "|")
        data.type = tab[1] --类型
        data.id   = tab[2] --id
        data.num  = tab[3] --数量
        data.time = tonumber(tab[4]) --总共可兑换次数
        data.cost = tonumber(tab[5])--消耗积分
        table.insert(goodsData,data)
    end
    -- print("~~~~~~~~~")
    -- print_t(goodsData)
    -- print("~~~~~~~~~")
    return goodsData
end
--[[
    @des    :获取配置中的奖励表
    @param  :
    @return :
--]]
function getRewardTable( ... )
	local activityData = ActivityConfigUtil.getDataByKey("scoreShop").data[1]["exchange_items"]
	return analyzeGoodsStr(activityData)
end
--[[
    @des    :获取奖励表中兑换一个需要的最少积分，用于判断是否有红点提示
    @param  :
    @return :
--]]
function getMinCost( ... )
    local activityData = getRewardTable()
    local minCost = activityData[1].cost
    for k,v in pairs(activityData) do
        if(minCost > tonumber(v.cost))then
            minCost = tonumber(v.cost)
        end
    end

    return minCost
end
--[[
    @des    :获取配置中的消耗数组
    @param  :
    @return :
--]]
function getPointTable( ... )
    local activityData = ActivityConfigUtil.getDataByKey("scoreShop").data[1]["point"]
    local pointTable = {}
    activityData = string.split(activityData,"|")
    for k,v in pairs(activityData)do
        table.insert(pointTable,v)
    end
    return pointTable
end
--[[
    @des    :获取这个tag索引的物品已经购买次数
    @param  :
    @return :
--]]
function getBuiedTime( p_tag )
    p_tag = tonumber(p_tag)
    local hasBuyTime = 0
    for k,v in pairs (_shopInfo.hasBuy) do
        if tonumber(k) == p_tag then
            hasBuyTime =  tonumber(v.num)
            break
        end
    end
    return hasBuyTime
end
--[[
    @des    :更新本地缓存中这个tag索引的物品已经购买次数
    @param  :
    @return :
--]]
function addBuiedTime( p_tag ,p_time)
    print("addBuiedTime",p_tag,p_time)
    p_tag = tostring(p_tag)
    p_time = tonumber(p_time)
    print_t(_shopInfo.hasBuy[p_tag])
   -- _shopInfo.hasBuy[tostring(p_tag)].num = (_shopInfo.hasBuy[tostring(p_tag)].num == nil and tonumber(p_time)
   --                          or _shopInfo.hasBuy[tostring(p_tag)].num) + tonumber(p_time)
    if(table.isEmpty(_shopInfo.hasBuy[p_tag]) == true )then
        _shopInfo.hasBuy[p_tag] = {}
        _shopInfo.hasBuy[p_tag].num = p_time
    elseif(_shopInfo.hasBuy[p_tag].num == nil)then
        _shopInfo.hasBuy[p_tag].num = p_time
    else
        _shopInfo.hasBuy[p_tag].num = _shopInfo.hasBuy[p_tag].num + p_time
    end
    print("again")
    print_t(_shopInfo.hasBuy[p_tag])
end
--[[
    @des    :更新本地缓存中积分
    @param  :
    @return :
--]]
function addPoint( p_num )
    print("改变积分前，要改的积分",_shopInfo.point,p_num)
    _shopInfo.point = _shopInfo.point + p_num
    print("改变积分后",_shopInfo.point)
end
--[[
    @des    :获取这个tag索引的物品用积分可购买几次 
    @param  :
    @return :
--]]
function getScoreTime( p_tag )
    p_tag = tonumber(p_tag)
    return math.floor( _shopInfo.point / getRewardTable()[p_tag].cost )
end
    
--[[
    @des    :获取这个tag索引的物品在购买上限的限制中还可购买几次
    @param  :
    @return :
--]]
function getLimitTime( p_tag )
    p_tag = tonumber(p_tag)
    
    return ( getRewardTable()[p_tag].time - getBuiedTime(p_tag) < 0 ) and 0 
                    or (getRewardTable()[p_tag].time - getBuiedTime(p_tag))
    
end
--[[
    @des    :获取可获取积分的截止时间
    @param  :
    @return :
--]]
function getGainEndTime()
    local gainDay = ActivityConfigUtil.getDataByKey("scoreShop").data[1]["time"]
    --print("gainDay",gainDay)
    local startTime = TimeUtil.getCurDayZeroTime(ActivityConfigUtil.getDataByKey("scoreShop").start_time)
    return startTime + 86400 * gainDay -1
end
-- --[[
--     @des    :获取当前是否是可得到积分的时间段
--     @param  :
--     @return :
-- --]]
function ifInGain( ... )
    local gainDay = tonumber(ActivityConfigUtil.getDataByKey("scoreShop").data[1]["time"])
    --print("gainDay",gainDay)
    local startTime = ActivityConfigUtil.getDataByKey("scoreShop").start_time
    if(TimeUtil.getDifferDay(startTime) <= (gainDay-1))then
        return true
    end
end