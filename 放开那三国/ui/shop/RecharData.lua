-- Filename: RecharData.lua.
-- Author: zhz  
-- Date: 2014-06-16
-- Purpose: 该文件用于显示充值界面数据

module("RecharData",  package.seeall)

require "script/ui/item/ItemUtil"

-- 返利类型 (类型1为只返利1档，充值后消失；类型2为每档均返利）
local kTypeBackOne = 1
local kTypeBackAll = 2

local _chargeInfo= {} -- 玩家充值的一些信息:is_pay, can_buy_monthlycard 

function getChargeInfo( )
    return _chargeInfo
end

-- 
function setChargeInfo(chargeInfo )
    _chargeInfo = chargeInfo
end

-- 得到是否可以买月卡
function getCanBuyMonthCard( )
    local canBuyMonthCard= true
    if(_chargeInfo.can_buy_monthlycard== "false" or _chargeInfo.can_buy_monthlycard== false ) then
        canBuyMonthCard= false
    end    

    return canBuyMonthCard
end

function setCanBuyMonthCard(  canBuy)
    _chargeInfo.can_buy_monthlycard = tostring(canBuy) 
end


function setIsPay( isPay )
      _chargeInfo.is_pay = tostring(isPay) 
end

-- 得到是否冲过值
function getIsPay()
    local ret = false
    if _chargeInfo.is_pay == nil or _chargeInfo.is_pay == "false" or _chargeInfo.is_pay == false then
        ret = false
    else
        ret = true
    end
    return ret
end

function getPayTypeParam( )
    local payTypeParam =  1      --充值类型参数，默认1
    if(type(Platform.getConfig().getPayTypeParam) == "function"        
        and Platform.getConfig().getPayTypeParam() ~= nil 
        and Platform.getConfig().getPayTypeParam() ~= "")then
        payTypeParam = Platform.getConfig().getPayTypeParam()
    end   
    -- print("getPayTypeParam =>",payTypeParam)
    return payTypeParam
end

-- 得到首充礼包的数据
 function getFirstData(  )
    local targetDataInfo = getFirstDataInfo()
    
    local consume_money =  string.split(targetDataInfo.money_nums, ",")
    local consume_grade = string.split(targetDataInfo.gold_nums, ",")
    local gold_num = string.split(targetDataInfo.return_gold, ",")
    local product_id = {}

    if (targetDataInfo.product_id ~= nil) then
        product_id = string.split(targetDataInfo.product_id, ",")
    else
        local  giftInfo = DB_First_gift.getDataById(2)
        print("giftInfo")
        print_t(giftInfo)
        if(giftInfo.product_id) then
            product_id= string.split(giftInfo.product_id, ",")
        end
    end
    
    local payData={}
    for i =1,#consume_money do
        local tempGiftData = {}
        tempGiftData.consume_money = consume_money[i]
        tempGiftData.consume_grade = consume_grade[i]
        tempGiftData.gold_num = gold_num[i]
        -- 首充重置每档双倍,记录是否此档是否充值 20160607 add by lgx
        tempGiftData.hadBuy = false
        if(not table.isEmpty(product_id)) then
            tempGiftData.product_id = tonumber(product_id[i])
        else
            tempGiftData.product_id = tonumber(product_id)
        end
        print("product_id[i]", product_id[i])
        table.insert(payData,tempGiftData)
    end
    return payData
end

--[[
    @des:得到首冲配置信息
--]]
function getFirstDataInfo( ... )
    local firstGiftData={}
    
    if(Platform.getCurrentPlatform() == kPlatform_AppStore) then
        firstGiftData = DB_First_gift.getArrDataByField("platform_type", 2)
    else
        firstGiftData = DB_First_gift.getArrDataByField("platform_type", getPayTypeParam())
    end

    local targetDataInfo = nil
    for k,v in pairs(firstGiftData) do
        if v.start_time and v.end_time then
            local startTime = TimeUtil.getIntervalByTimeDesString(v.start_time)
            local overTime  = TimeUtil.getIntervalByTimeDesString(v.end_time)
            local curTime   = TimeUtil.getSvrTimeByOffset()
            if startTime < curTime and overTime > curTime then
                targetDataInfo = v
                break
            end
        end
    end
    if targetDataInfo == nil then
        targetDataInfo = firstGiftData[1]
    end
    return targetDataInfo
end


function getKiMiAndroidFirstPay( firstGiftData) 

    local payData= {}

    local consume_money =  string.split(firstGiftData.money_nums, ",")
    local consume_grade = string.split(firstGiftData.gold_nums, ",")
    local gold_num = string.split(firstGiftData.return_gold, ",")
    local isShow= lua_string_split(firstGiftData.is_show, ",")

    for i=1,#isShow do
        local tempGiftData= {}
        local showIndex= tonumber(isShow[i])
        tempGiftData.consume_money = tonumber(consume_money[showIndex])
        tempGiftData.consume_grade = consume_grade[showIndex]
        tempGiftData.gold_num = gold_num[showIndex]
        table.insert(payData, tempGiftData)
    end
    return payData
end

-- 得到非首冲礼包的数据
function getPayListData(  )
    
    local payData = {}

    print("BTUtil:isAppStore()  is : ",BTUtil:isAppStore() )
    local platformName = Platform.getPlatformUrlName()
    if(platformName == "Android_km" or platformName == "Android_kmgp" or platformName == "Android_kmoc") then
        local allPayData= DB_Pay_list.getArrDataByField("platform_type",4)
        for id, data in pairs(allPayData) do
            if(data.is_show==1) then
                table.insert(payData, data)
            end
        end
    elseif(Platform.getCurrentPlatform() == kPlatform_AppStore) then
        payData = DB_Pay_list.getArrDataByField("platform_type", 2)
    else
        payData= DB_Pay_list.getArrDataByField("platform_type",getPayTypeParam())
    end

    -- 首充重置每档双倍 20160607 add by lgx
    local payFirstData = getFirstDataInfo() 
    -- 如果是首充每档双倍 返利类型 类型2为每档均返利
    if (payFirstData.type == kTypeBackAll) then
        -- 后端返回的充值过的档位 档位金币数 => 充值时间
        local firstListInfo = getFirstListInfo()
        -- print("-----------firstListInfo-----------")
        -- print_t(firstListInfo)

        local chargeInfoArr = getChargeInfo().charge_info or {}
        -- print("-----------chargeInfoArr-----------")
        -- print_t(chargeInfoArr)
        for i,v in ipairs(payData) do
            -- print("----------payData %i----------",i)
            -- print_t(v)
            if ( not table.isEmpty(chargeInfoArr) and ( chargeInfoArr[v.consume_grade] ~= nil or chargeInfoArr[tostring(v.consume_grade)] ~= nil ) ) then
                -- 充值过
                -- 首充重置每档双倍,记录是否此档是否充值 20160607 add by lgx
                v.hadBuy = true
                v.gold_num = nil
            else
                -- 未充值
                local firstInfo = firstListInfo[v.consume_grade]
                if (not table.isEmpty(firstInfo)) then
                    v.hadBuy = false
                    v.gold_num = firstInfo.gold_num
                end
            end
        end

    end

    local function keySort ( w1 , w2 )
        return tonumber(w1.id) < tonumber(w2.id)
    end
    table.sort( payData, keySort )


    -- print("-----------payData-----------")
    -- print_t(payData)

    return payData
end


-- 处理充值的数据
function getChargeData()

   local  payData ={}
    -- 没有首冲
    if(_chargeInfo.is_pay== "false" or _chargeInfo.is_pay== false)  then
        local platformName = Platform.getPlatformUrlName()
        -- 台湾android
        if(platformName == "Android_km" or platformName == "Android_kmgp" or platformName == "Android_kmoc") then
            local firstGiftData = DB_First_gift.getArrDataByField("platform_type",4)[1]
            payData = getKiMiAndroidFirstPay(firstGiftData)
        else
            payData = RecharData.getFirstData()
        end
    else
        payData = RecharData.getPayListData()
    end

    -- print("-----------getChargeData-----------")
    -- print_t(payData)
    return payData
end



-- 得到月卡里面的数据
function getMonthCardData( pId)
    local cardId = pId
    require "db/DB_Vip_card"
    if(cardId == nil)then
        cardId = 1
    end
    local monthCardData= DB_Vip_card.getDataById(cardId)

    local items= ItemUtil.getItemsDataByStr( monthCardData.cardReward)
    -- monthCardData.product_id=monthCardData.productId
    monthCardData.items= items
    return monthCardData

end


--[[
    @desc   : 得到首充列表的数据
    @param  :
    @return : table {goldNum => tableValue}
--]]
 function getFirstListInfo()
    local targetDataInfo = getFirstDataInfo()
    
    local consume_money =  string.split(targetDataInfo.money_nums, ",")
    local consume_grade = string.split(targetDataInfo.gold_nums, ",")
    local gold_num = string.split(targetDataInfo.return_gold, ",")
    local product_id = {}

    if (targetDataInfo.product_id ~= nil) then
        product_id = string.split(targetDataInfo.product_id, ",")
    else
        local  giftInfo = DB_First_gift.getDataById(2)
        if(giftInfo.product_id) then
            product_id = string.split(giftInfo.product_id, ",")
        end
    end

    local payData = {}
    for i =1,#consume_money do
        local tempGiftData = {}
        tempGiftData.consume_money = consume_money[i]
        tempGiftData.consume_grade = consume_grade[i]
        tempGiftData.gold_num = gold_num[i]
        -- 首充重置每档双倍,记录是否此档是否充值 20160607 add by lgx
        tempGiftData.hadBuy = false
        if(not table.isEmpty(product_id)) then
            tempGiftData.product_id = tonumber(product_id[i])
        else
            tempGiftData.product_id = tonumber(product_id)
        end
        payData[tonumber(tempGiftData.consume_grade)] = tempGiftData
    end
    return payData
end

--[[
    @desc   : 获取是否首充每档双倍
    @param  : 
    @return : bool 是否首充每档双倍
--]]
function isNeedShowDoubleTip()
    -- 首充重置每档双倍 20160621 add by lgx
    local isNeedShowDoubleTip = false
    local payFirstData = getFirstDataInfo() 
    -- 如果是首充每档双倍 返利类型 类型2为每档均返利
    if (payFirstData.type == kTypeBackAll) then
        isNeedShowDoubleTip = true
    end
    return isNeedShowDoubleTip
end




