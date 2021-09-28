-- Filename：    WorldGroupData.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：    跨服团购数据


module ("WorldGroupData", package.seeall)
require "script/utils/TimeUtil"
-- local _netInfo = {}  --从后端获取的全部信息
local _userInfo = {} --个人信息
local _stage = nil   --所处阶段
local _crossInfo = {} --当前线上团购的总数
local _previewCrossInfo = {}--伪造的当前线上团购的总数 主要用于批量购买的时候预览价格 而又不影响真实缓存
local _buyStartTime = nil
local _buyEndTime = nil
--后端数据结构
  -- buy_start_time :开始购买的时间戳
  -- buy_end_time   :购买结束的时间戳
  -- userInfo:array
  --    *  [
  --    *      point => int 积分,
  --    *      coupon => int 团购券,
  --    *      his => array[
  --    *          array[0=>goodId物品id, 1=>num团购数量, 2=>gold花费金币, 3=>coupon券, 4=>buyTime时间]
  --    *      ]
  --    *      pointReward => array[$reward已领取的奖励id,...]
  --    *  ]
 -- *  stage:{team:分组阶段, buy:购买阶段, reward:发奖阶段}
 -- *  如果购买阶段：
 --     *  crossInfo:array
 --     *  [
 --     *      $goodId => [goodId物品id, goodNum购买总数,],...
 --     *  ]
function setNetInfo( p_ret)
    -- print("setNetInfo p_ret")
    -- print_t(p_ret)
 
    if(table.isEmpty(p_ret))then
        return
    end
    if(p_ret.userInfo)then
        _userInfo = p_ret.userInfo
    end
    if(p_ret.stage)then
        _stage = p_ret.stage
    end
    if(p_ret.crossInfo)then
        _crossInfo = p_ret.crossInfo
    end
    if(p_ret.buy_start_time)then
        _buyStartTime = p_ret.buy_start_time
    end
    if(p_ret.buy_end_time)then
        _buyEndTime = p_ret.buy_end_time
    end

end

--获取活动配置数据
function getActiveData( ... )
   return ActivityConfigUtil.getDataByKey("worldgroupon").data
end
function getCorssInfo( ... )
    return _crossInfo
end
function getUserInfo( ... )
    return _userInfo
end
function getStage( ... )
    return _stage
end
--获取购买记录
function getRecord( ... )
    if(not table.isEmpty(_userInfo))then
        return _userInfo.his
    end
end

--更改缓存中的总购买数据
function addCrossNumById( p_id ,p_num)
    local p_id = tostring(p_id)
    if(table.isEmpty(_crossInfo))then
        _crossInfo = {}
    end
  
    if(table.isEmpty(_crossInfo[p_id]))then
        _crossInfo[p_id] = {}
        _crossInfo[p_id]["good_id"] = p_id
        _crossInfo[p_id]["good_num"] = 0
    end
    _crossInfo[p_id]["good_num"] = tonumber(_crossInfo[p_id]["good_num"]) + tonumber(p_num)

end
--根据id获取这一条活动配置   
function getActiveDataByID( p_id)
    local p_id = tonumber(p_id)
    local activeData = getActiveData()
    if(not table.isEmpty(activeData))then
        for f,v in pairs(activeData)do
            if(tonumber(v.id) == p_id)then
                return v
            end
        end
    end
end
--解析表中的 ， | 形式 变成二维数组
function analysisDbStr(p_info)
    if(p_info == nil)then
        return
    end
    local resultTab = {}
    local tabData = string.split(p_info,",")
  
    for k , v in pairs(tabData)do
        local tmpTab = string.split(v,"|")
        table.insert(resultTab,tmpTab)

    end
    return resultTab
end
--根据物品id获取原价和当前售价（有团购折扣后） 因为刷新延迟的问题 可能与后端不一致 以后端为准
function getPriceByID(p_id )
    local p_id = tostring(p_id)
    local crossInfo = _crossInfo[p_id]
    local crossNum = 0 --当前线上这个物品已经购买的总数
    local discountRate = 1 --打折比例

    --在活动配置里找这条记录
    local activeData = getActiveDataByID(p_id)
    if(table.isEmpty(activeData))then 
        return
    end
    if(crossInfo)then
        crossNum = tonumber(crossInfo.good_num)
    end
    --print("crossNum",crossNum)
    local discount = activeData["discount"]
    discount = analysisDbStr(discount)
    
    if(not table.isEmpty(discount))then
        local discountNum = table.count(discount)
        -- for k,v in pairs(discount)do
        --     if(tonumber(v[2]) >= crossNum)then 

        --         discountRate = tonumber(v[1])/10000
        --         print("当前折扣",discountRate)
        --         break       

        --     end
        -- end
        for i = 1 ,discountNum do
            if crossNum >= tonumber(discount[discountNum][2])then 
                --向外越界情况，向内越界不用考虑 因为折扣的初始值是1 没买过就不打折
                discountRate = tonumber(discount[discountNum][1])/10000
                --print("当前折扣",discountRate)
                break       
            end
            if(crossNum >= tonumber(discount[i][2]) and crossNum < tonumber(discount[i+1][2]))then
                discountRate = tonumber(discount[i][1])/10000
                --print("当前折扣",discountRate)
                break  
            end
        end
    end
    local acticePrice = tonumber(activeData["price"]) --原价
    local costSum = math.floor(acticePrice * discountRate )       --现价
    return acticePrice,costSum

end
function disCountSort(p_data1,p_data2)
    return p_data1[2] < p_data2[2]
    -- body
end
--根据物品id获取今日购买上限和今日已经购买数量 
function getNumByID( p_id )
    local p_id = tostring(p_id)

    local activeData = getActiveDataByID(p_id)
    local boughtNum = 0    --已经买
    local totalNum = 0    --总共可买
    if(table.isEmpty(activeData))then 
        return
    end
    totalNum =   tonumber(activeData["type"]) == 0 and 1 or tonumber(activeData["type"])
    local goodId = tonumber(p_id)
    if(_userInfo and _userInfo.his)then
        for k,v in pairs (_userInfo.his) do
            if(tonumber(v["goodId"]) == goodId and TimeUtil.getDifferDay(v["buyTime"]) == 0)then
                boughtNum = boughtNum + tonumber(v["num"])
            end
        end
    
    end
    return totalNum,boughtNum
end
--获取物品还可以买多少件
function getCanBuyTimeById(p_id)
    local totalNum,boughtNum = getNumByID( p_id )
    return (totalNum - boughtNum)<0 and 0 or totalNum - boughtNum
end
--获取当前线上总共购买了多少件
function getBoughtNumById( P_ID)
    if(table.isEmpty(_crossInfo))then
        return 0
    end
    local p_id = tostring(P_ID)
    crossInfo = _crossInfo[p_id]
    if(crossInfo)then
        return  tonumber(crossInfo.good_num)
    end
    return 0
end
--根据物品id获取当前需要花费多少 (包括团购券) 因为刷新延迟的问题 可能与后端扣取的不一致 真正扣缓存的时候以后端返回的为准
function getCostByID(p_id)
    local p_id = tostring(p_id)

    local costGold = 0    --需要多少金币
    local costCoupon = 0  --需要多少团购券

    --在活动配置里找这条记录
    local activeData = getActiveDataByID(p_id)
    if(table.isEmpty(activeData))then 
        return
    end

    local _,costSum = getPriceByID(p_id )
    local userCoupon = tonumber(_userInfo.coupon)
    if( userCoupon >0)then
        --当前有团购券再算需要多少个 不积跬步无以至千里 不积小流无以成江海  
        --最多可以用多少个团购券
        costCoupon = math.floor(costSum * tonumber(activeData["replace_rate"])/10000)
        if(costCoupon > userCoupon)then
            costCoupon = userCoupon
        end
    end 

    if(costCoupon < costSum)then
        costGold = costSum - costCoupon
    end
    return costGold,costCoupon
end
function getTotalCostByNum(p_id,p_num )

    local num = tonumber(p_num)
    local costGold = 0    --需要多少金币
    local costCoupon = 0  --需要多少团购券
    for i=1,num do
        local curGold,curCoupon = getCostByID(p_id)
        costGold = costGold + curGold
        costCoupon = costCoupon + curCoupon
    end
    return costGold,costCoupon
end
--获取今日可购买的物品id集合
function getTodayGoods( ... )
    local activeData = getActiveData()
    if(table.isEmpty(activeData))then
        return
    end
    local resultTab = {}
    local deltaDay = TimeUtil.getDifferDay(ActivityConfigUtil.getDataByKey("worldgroupon").start_time) +1
    print("getTodayGoods 今天是活动的第*天",deltaDay)
    print("getTodayGoods activeData")
    print_t(activeData)
    print("ActivityConfigUtil.activeData")
    print_t(ActivityConfigUtil.getDataByKey("worldgroupon").data)
    for i = 1,#activeData do
         local tabData = string.split(activeData[i]["day"],",")
         for _,j in pairs(tabData)do
            if(tonumber(j) == deltaDay)then
                table.insert(resultTab,activeData[i]["id"])
                break
            end
         end
    end
    -- print("今天可以买的id序列")
    -- print_t(resultTab)
    return resultTab
end

--获取购买截止的时间点
function getBuyEndTime( ... )

    return _buyEndTime 
end
--获取购买的起始时间点
function getBuyStartTime( ... )
    return _buyStartTime
end
--根据活动配置的id获取这个id的购买记录
function getRecordById( p_id)
    local recordList = getRecord()
    local p_id = tonumber(p_id)
    local resultTab = {}
    if not table.isEmpty(recordList) then
        for k,v in pairs(recordList)do
            if tonumber(v.goodId) == p_id then
                table.insert(resultTab,v)
            end
        end
    end
    return resultTab
end
--获取积分奖励的数组（做预览用）
function getPointRewardList( ... )
    local listStr = getActiveDataByID(1)["points_reward"]
    local list = parseField(listStr, 2)
    local retTab = {}
    local retIndex = 0
    local curPoint = nil
    for i = 1, #list do
        local data = list[i]
        local pointTemp = data[1]
        if pointTemp ~= curPoint then
            curPoint = pointTemp
            retIndex = retIndex + 1
            retTab[retIndex] = {}
            retTab[retIndex].point = curPoint
            retTab[retIndex].items = {}
        end
        local ret = retTab[retIndex]
        local itemData = ItemUtil.getServiceReward({{data[2], data[3], data[4]}})[1]
        table.insert(ret.items, itemData)
    end
    return retTab
end

-- 奖励是否已经领取
function rewardIsReceived( p_point )
    local isReceived = false
    for i = 1, #_userInfo.pointReward do
        if tonumber(p_point) == tonumber(_userInfo.pointReward[i]) then
            isReceived = true
            break;
        end
    end
    return isReceived
end
--增加一条已领奖记录
function addRewardRecord( p_id )
    _userInfo.pointReward = _userInfo.pointReward  or {}
    table.insert(_userInfo.pointReward,p_id)
end
--是否有未领取的奖励 做红点提示用
function  ifPointReward( ... )
    if(TimeUtil.getSvrTimeByOffset() > tonumber(getBuyEndTime()) )then
        return false
    end
    if(table.isEmpty(_userInfo))then
        return false
    end
    local point = tonumber(_userInfo.point)
    if point <= 0 then
        return false
    end
    local rewardList = getPointRewardList()
    if(table.isEmpty(rewardList))then
        return false
    end

    for i = 1,#rewardList do
        if(point >= tonumber(rewardList[i].point))then
            if( not rewardIsReceived(rewardList[i].point) )then
                return true
            end
        else
            break
        end
    end
    return false
end
--跨服团购是否开启入口 （因为活动开始后 有一段时间是 分组时间 这个时候入口不开放）
function isWorldGroupBuyOpen( ... )
    if(ActivityConfigUtil.isActivityOpen("worldgroupon"))then
        local curTime = TimeUtil.getSvrTimeByOffset() 
        local startTime = getBuyStartTime() 
        print("isWorldGroupBuyOpen startTime",startTime)
        print("isWorldGroupBuyOpen curTime",curTime)
        if(startTime == nil)then
            --没有拿到服务器数据
            return false
        end
        if(curTime >= tonumber(startTime))then
            print("isWorldGroupBuyOpen true")
            return true
        end
    end
    print("isWorldGroupBuyOpen false")
    return false
end
----判断跨服团购是否有红点 add by DJN
function isHaveWorldGroup( ... )
    local startBuyTime = getBuyStartTime()
    if ActivityConfigUtil.isActivityOpen("worldgroupon") and startBuyTime and TimeUtil.getSvrTimeByOffset() >= tonumber(startBuyTime) then
       return ifPointReward()
    end
end
-----------------------------------------------------新增假数据专场----------------------------------
--初始化本地的假数据 每次进入购买预览界面初始化同步一下
--和后端策划沟通后，对于购买数量跨越折扣区间的这种可能，以折扣前*购买数量直接算，并不分区间段 所以这个假数据做得没什么意义了 预览面板上调用的还是假数据算出来的方法 实际和真数据算出来的无差异 这些函数保留 以备以后该需求
function initPreviewCrossInfo( ... )

    _previewCrossInfo = table.hcopy(_crossInfo,{})

end
--更改缓存假数据中的总购买数据
function addPreviewCrossNumById( p_id ,p_num)
    local p_id = tostring(p_id)
    if(table.isEmpty(_previewCrossInfo))then
        _previewCrossInfo = {}
    end
    if(table.isEmpty(_previewCrossInfo[p_id]))then
        _previewCrossInfo[p_id] = {}
        _previewCrossInfo[p_id]["good_id"] = p_id
        _previewCrossInfo[p_id]["good_num"] = 0
    end
    _previewCrossInfo[p_id]["good_num"] = tonumber(_previewCrossInfo[p_id]["good_num"]) + tonumber(p_num)
end
--根据物品id获取原价和当前售价（有团购折扣后） 因为刷新延迟的问题 可能与后端不一致 以后端为准
function getPreviewPriceByID(p_id )
    local p_id = tostring(p_id)
    local crossInfo = _previewCrossInfo[p_id]
    local crossNum = 0 --当前线上这个物品已经购买的总数
    local discountRate = 1 --打折比例

    --在活动配置里找这条记录
    local activeData = getActiveDataByID(p_id)
    if(table.isEmpty(activeData))then 
        return
    end
    if(crossInfo)then
        crossNum = tonumber(crossInfo.good_num)
    end
    local discount = activeData["discount"]
    discount = analysisDbStr(discount)

    if(not table.isEmpty(discount))then
        local discountNum = table.count(discount)
        for i = 1 ,discountNum do
            if crossNum >= tonumber(discount[discountNum][2])then 
                --向外越界情况，向内越界不用考虑 因为折扣的初始值是1 没买过就不打折
                discountRate = tonumber(discount[discountNum][1])/10000
                break       
            end
            if(crossNum >= tonumber(discount[i][2]) and crossNum < tonumber(discount[i+1][2]))then
                discountRate = tonumber(discount[i][1])/10000
                break  
            end
        end
    end
    local acticePrice = tonumber(activeData["price"]) --原价
    local costSum = math.floor(acticePrice * discountRate )       --现价
    return acticePrice,costSum

end
--根据物品id获取当前需要花费多少 (包括团购券)  批量购买面板预览用
function getPreviewCostByID(p_id)
    local p_id = tostring(p_id)
    local costGold = 0    --需要多少金币
    local costCoupon = 0  --需要多少团购券

    --在活动配置里找这条记录
    local activeData = getActiveDataByID(p_id)
    if(table.isEmpty(activeData))then 
        return
    end

    local _,costSum = getPreviewPriceByID(p_id )
    -- print("getPreviewPriceByID",costSum)
    local userCoupon = tonumber(_userInfo.coupon)
    if( userCoupon >0)then
        --当前有团购券再算需要多少个 不积跬步无以至千里 不积小流无以成江海  
        --最多可以用多少个团购券
        costCoupon = math.floor(costSum * tonumber(activeData["replace_rate"])/10000)
        if(costCoupon > userCoupon)then
            costCoupon = userCoupon
        end
    end 

    if(costCoupon < costSum)then
        costGold = costSum - costCoupon
    end
    return costGold,costCoupon
end
function getTotalPreviewCostByNum(p_id,p_num )

    local num = tonumber(p_num)
    local costGold = 0    --需要多少金币
    local costCoupon = 0  --需要多少团购券
    local costGold,costCoupon = getPreviewCostByID(p_id)
    costGold = costGold * num
    costCoupon = costCoupon * num
    -- for i=1,num do
    --     local curGold,curCoupon = getPreviewCostByID(p_id)
    --     costGold = costGold + curGold
    --     costCoupon = costCoupon + curCoupon
    -- end
    return costGold,costCoupon
end
-------------------------------------------------新增假数据专场结束----------------------------------