-- Filename：	ActiveCache.lua
-- Author：		zhz
-- Date：		2013-9-29
-- Purpose：		数据缓存

-- 获得成长基金的prize： 'prized' => array( 0 => true , 1 => true ..), 
--  { 'prized' => array( 0 => true , 1 => true ..), 已经领取的奖励 'active_time' => ,用户激活该功能的时间 } 
--Or 'invalid_time'活动时间不对 or 'unactived' 用户未激活 or 'fetch_all' 已经领取了所有了（领完活动就应该停止了）
-- 手动设置 active

module ("ActiveCache", package.seeall)
require "script/model/utils/ActivityConfig"
require "script/ui/login/ServerList"
require "script/utils/TimeUtil"
require "script/ui/rechargeActive/travelShop/TravelShopData"
require "script/ui/active/NewActiveData"
require "script/ui/rechargeActive/rechargegift/RechargeGiftData"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeService"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeData"
-- 判断整个精彩活动是否有提示
-- 现在就2个，以后有一个，加一个
function hasTipInActive(  )
    if( isOnTime() or isHaveCardNum() or isHaveVIPBenefit() or isAllNewActivity() or isHaveMonthSign() or TravelShopData.canReceive() or NewActiveData.haveNewActiveTip() or isRechargeGiftHaveTip()) then
        return true
    else
        return false
    end
end

local _activityTable={}

function setAllNewOpenActivity( keys)
   
    -- for i=1, 7 do
    --     local tmpTable= {key= "", isNew= true}
    --     tmpTable.key= keys[i]
    --     table.insert(_activityTable, tmpTable )
    -- end

    -- _activityTable = {

    --     { key = "robTomb",isNew= false},
    --     { key = "spend",isNew= false},
    --     { key = "heroShop",isNew= false},
    --     { key = "signActivity",isNew= false},
    --     { key = "topupFund",isNew= false},
    --     { key = "weal",isNew= false},

    -- }

    -- for i=1, table.count(_activityTable) do
    --     _activityTable[i].isNew = CCUserDefault:sharedUserDefault():getBoolForKey(_activityTable[i].key)
    --     for k=1, #keys do
    --         if(  _activityTable[i].key== keys[k]) then
    --             _activityTable[i].key= true
    --         end
    --     end

    -- end
    
end


-- 判断是否所有的活动是否有开启的
function isAllNewActivity( ... )
    
    local has= false
    local allKeys = { "robTomb" , "spend" ,"heroShop" , "signActivity","topupFund", "weal", "mineralelves", "actExchange","groupon", "chargeRaffle", "travelShop"}

    for i=1, #allKeys do
        if( IsNewInActivityByKey(allKeys[i] ) ) then
            has= true
            break
        end
    end
    return has
end

-- 判断活动是否是第一次进入
function IsNewInActivityByKey(key  )
    
    -- for i=1, #_activityTable do
    --     if(key == _activityTable[i].key ) then
    --         return _activityTable[i].isNew
    --     end
    -- end
    -- return false
    
    if(key==nil) then
        return false
    end
    
    local time=  CCUserDefault:sharedUserDefault():getIntegerForKey(key)
    local activity_data  = ActivityConfig.ConfigCache[tostring(key)]

    if( ActivityConfigUtil.isActivityOpen(key) and  time <  tonumber(activity_data.start_time)) then
        return true
    else
        return false
    end    
end

-- 设置活动时间，将当前时间保存下来
function setActivityStatusByKey(key )
    -- for i=1, #_activityTable do
    --     if(key == _activityTable[i].key ) then
    --         _activityTable[i].isNew= status
    --         CCUserDefault:sharedUserDefault():getBoolForKey(key,status )
    --     end
    -- end

    local time= BTUtil:getSvrTimeInterval()
    CCUserDefault:sharedUserDefault():setIntegerForKey(tostring(key) , time )
end
-- 判断月签到活动是否是第一次进入
--add by djn
function IsNewInMonthSign( )
   local time=  CCUserDefault:sharedUserDefault():getIntegerForKey("monthSign")
  -- print("上次时间",time)
    if( time == 0) then
        return true
    else
        return false
    end    
end


local _prizeInfo = nil
function getPrizeInfo( )
	return _prizeInfo
end

function setPrizeInfo( prize)
	_prizeInfo = prize
	print("   in the        preize info ")
	print_t(_prizeInfo)
end

function addPrezedArray( index)
	table.insert(_prizeInfo.prized, index)
end

-- 整点送体力的时间
local _supplyTime = nil 
function getSupplyTime(  )
	return _supplyTime
end

function setSupplyTime( supplyTime )
	_supplyTime = tonumber(supplyTime)
end

-- 判断是否为今天
 function isToday(timestamp)
    local today = os.date("*t",BTUtil:getSvrTimeInterval())
    local secondOfToday = os.time({day=today.day, month=today.month,
        year=today.year, hour=0, minute=0, second=0})
    if timestamp >= secondOfToday and timestamp < secondOfToday + 24 * 60 * 60 then
        return true
    else
        return false
    end
end

-- 判断是否到时间了
function isOnTime( )   
    local isOnTime = false
    if(not ActiveCache.isPassTime( tonumber(_supplyTime), 115900) and ActiveCache.isOnAfternoon(BTUtil:getSvrTimeInterval())) then
        isOnTime = true
    -- elseif (not ActiveCache.isPassTime(tonumber(_supplyTime),155900) and  ActiveCache.isOnNight(BTUtil:getSvrTimeInterval())) then
    --     isOnTime = true
    elseif(not ActiveCache.isPassTime(tonumber(_supplyTime),175900) and  ActiveCache.isOnEvening(BTUtil:getSvrTimeInterval())) then
        isOnTime = true
    elseif(not ActiveCache.isPassTime(tonumber(_supplyTime),205900) and  ActiveCache.isOnNight(BTUtil:getSvrTimeInterval())) then
        isOnTime = true
    end
    return isOnTime
end

-- 判断是否有翻牌次数
function isHaveCardNum()
    local canCard = false
    
    if ActivityConfigUtil.isActivityOpen("weal") then
        local cardActiveData = ActivityConfigUtil.getDataByKey("weal").data
        print(GetLocalizeStringBy("key_2007"))
        print_t(cardActiveData)
        local isOpenCard = nil
        -- for k,v in pairs(cardActiveData) do
        --     if tonumber(v.open_act) == 1 then
        --         isOpenCard = v.open_draw
        --         break
        --     end
        -- end
        print("翻牌数据额")
        print_t(cardActiveData[1])
        if cardActiveData[1] ~= nil then
            isOpenCard = cardActiveData[1].open_draw
        end
        print(GetLocalizeStringBy("key_2641"), isOpenCard)

        if (isOpenCard ~= nil) and (tonumber(isOpenCard) == 1) then
            require "script/ui/rechargeActive/BenefitActiveLayer"
            print(GetLocalizeStringBy("key_1325"),accountNum)
            local accountNum = tonumber(BenefitActiveLayer.getAccountNum())
            print("算法罚款了",accountNum)
            local cardRate = tonumber(BenefitActiveLayer.getCostNum())
            local cardNum = math.floor(accountNum/cardRate)
            if tonumber(cardNum) > 0 then
                canCard = true
            end
        end
    end

    return canCard
end

function isHaveVIPBenefit()
    local haveVIP = false
    require "script/model/user/UserModel"
    require "script/ui/vip_benefit/VIPBenefitData"
    if tonumber(UserModel.getVipLevel()) > 0 then
        if tonumber(VIPBenefitData.getHave()) == 0 then
            print("不应该跑这啊")
            haveVIP = true
        end
    end
    print("haveVIP~~~",haveVIP)
    return haveVIP
end

--只有vip0以上才显示vip福利活动
function isOpenVIPBenefit()
    require "script/model/user/UserModel"
    local canSee = false
    if tonumber(UserModel.getVipLevel()) > 0 then
        canSee = true
    end
    return canSee
end

-- 一个时间戳，每天开始时间，每天结束时间，判断是否在开始时间和结束时间内
function isOnByTimeInterval(timeInt, startTime ,endTime)
    local _isOnTime = false
    local starTimeInt = TimeUtil.getIntervalByTime(startTime)
    local endTimeInt= TimeUtil.getIntervalByTime(endTime)
    if(timeInt > starTimeInt and timeInt< endTimeInt) then
        _isOnTime = true
    end
    return _isOnTime
end

-- 判断 是否在每天的18~20 点
function isOnEvening (timeInt) 
	return isOnByTimeInterval(timeInt, 175900,200000)
end

-- 判断 是否在下午
function isOnAfternoon(timeInt)
    return isOnByTimeInterval(timeInt, 115900,140000)
end

function isOnNight(timeInt)
    return isOnByTimeInterval(timeInt,205900,230000)
    --return isOnByTimeInterval(timeInt,155900,180000)
end

--[[
    @des    :判断所给的时间戳是否小于所给的时间点
    @param  :timeInt, timeHour
    @return :true or false 
]]
function isPassTime(timeInt, timeHour )
	local isPass = false
    local startTimeInt=  TimeUtil.getIntervalByTime(timeHour)
    if(timeInt > startTimeInt ) then
        isPass = true
    end
    return isPass

end



--------------------------------------------------  神秘商店 -----------------------
require "script/ui/item/ItemUtil"
require "db/DB_Mystical_goods"
require "db/DB_Mystical_shop"
require "db/DB_Vip"

local _shopInfo= {}

function  getShopInfo(  )
    return _shopInfo
end

function setShopInfo( shopInfo)
    _shopInfo = shopInfo    
end



--[[
    @des:       得到本次刷新花费的金币数量
    @return:    num
]]
function getRftGoldNum(  )
    local shopData = DB_Mystical_shop.getDataById(1)
    local baseGold = tonumber(shopData.baseGold)
    print("shopData.growGold is ,", shopData.growGold ) --, " shopData.growGold is ", _shopInfo.refresh_num )
    print_t(_shopInfo)
    local growGold= tonumber(shopData.growGold)*(tonumber(_shopInfo.refresh_num))
    local costGoldNum= baseGold+growGold
    return costGoldNum

end

-- 当前拥有涮洗令得数量
function getItemNum()
    local shopData = DB_Mystical_shop.getDataById(1)
    local num=0
    local num=  ItemUtil.getCacheItemNumBy(tonumber(shopData.item)) or 0
    -- if(itemInfo) then
    --     num = tonumber(itemInfo.item_num)
    -- end
    return num
 end 

--神秘商店是否提示
function secretTip( ... )
    -- body
    local freshNum = getAccRfcTime()
    if(freshNum>0)then
        return true
    else
        return false
    end
end

-- 得到累计的刷新时间
 function getAccRfcTime( )
     return  tonumber(_shopInfo.sys_refresh_num) or 0
 end

 function addAccRfcTime( num)
    _shopInfo.sys_refresh_num= tonumber(_shopInfo.sys_refresh_num)+ num
 end

-- 得到当前商店增加的时间
 function getShopAddTime(  )
    local mysticalShopAddTime = DB_Vip.getDataById( UserModel.getVipLevel()+1).mysicalShopAddTime
    return mysticalShopAddTime
 end

-- 判断当前免费刷新次数是否已达上限
-- true:达到上限
function isShopAddTimeMax(  )
    if(getAccRfcTime()>= getShopAddTime()) then
        return true
    else
        return false
    end    
end

-- 判断当前刷新次数是否达到最大值，true:到了， false:没有
function isRefreshMax( )
    require "script/model/user/UserModel"
    local mysteryShopTimes = DB_Vip.getDataById(tonumber(UserModel.getVipLevel()+1)).mystical_shop_time
    print("mystical_shop_time  is ,", tonumber(mysteryShopTimes))
    if( tonumber(mysteryShopTimes)>tonumber(_shopInfo.refresh_num) ) then
        return true
    end
    return false
end

--[[
    @des:       得到刷新剩余时间
    @return:    time interval
]]
function getRefreshCdTime( )
    local endShieldTime = tonumber(_shopInfo.refresh_cd)
    local havaTime = endShieldTime - BTUtil:getSvrTimeInterval()
    if(havaTime > 0) then
        return havaTime
    else
        return 0
    end
end

function addRefreshCdTime( num)
    local num = num or 1
    local cd= DB_Mystical_shop.getDataById(1).cd
    _shopInfo.refresh_cd = _shopInfo.refresh_cd+ num*cd
end

-- CCUserDefault:sharedUserDefault():setIntegerForKey(,)
function setMysteryCdTime( )
    CCUserDefault:sharedUserDefault():setIntegerForKey("mysteryNewCdTime",tonumber(_shopInfo.refresh_cd))
end

function isMysteryNewIn( )
    
    local lastRefreshCd= CCUserDefault:sharedUserDefault():getIntegerForKey("mysteryNewCdTime")
    print("lastRefreshCd  is : ", lastRefreshCd)
    print("(BTUtil:getSvrTimeInterval()  is ", BTUtil:getSvrTimeInterval())
    if(BTUtil:getSvrTimeInterval() >lastRefreshCd ) then
        return true
    else
        return false
    end
end

--[[
    @des:       得到物品的table
    @return:    table{
        item = {
            id : DB_Mystical_goods里的id
            type = 1：物品ID 2：英雄ID
            tid : 对应物品或英雄的模板id
            num: 出售的数量
            canBuyNum: 可以购买的次数
            costNum： 花费的数值
            costType: 1：花费类型为魂玉 , 2：花费类型为金币
        }
            
    }
]]

function getItemTable(  )

    local items ={}
    -- local index =1
    for goodsId,canBuyNum in pairs(_shopInfo.goods_list) do 
        local item = {}
        local goodData = DB_Mystical_goods.getDataById(tonumber(goodsId))
        -- print("goodsId  is : ", goodsId)
        -- print_t(goodData)
        goods = lua_string_split(goodData.items,"|")
        item.id = goodData.id
        item.index = index
        item.type = tonumber(goods[1])
        item.tid = tonumber(goods[2]) 
        item.num = tonumber(goods[3])
        item.canBuyNum= tonumber(canBuyNum)
        item.costNum= tonumber(goodData.costNum)
        item.costType= tonumber(goodData.costType) 
        item.isHot = goodData.isHot
        table.insert(items, item)
        -- index = index+1
    end
    return items
end

--[[
    @des:       修改神秘商店里canBuyNum
    @return:    time interval
]]
function changeCanBuyNumByid( id , value)
    for goodsId, canBuyNum  in pairs(_shopInfo.goods_list) do 
        print("good  is :0 ", goodsId)
        if(tonumber(goodsId)==tonumber(id)) then
          ---  print("gooId  is  :" goodsId, "  id is : ", id)
            _shopInfo.goods_list[goodsId] = tonumber(canBuyNum) -1
            break
        end
    end
end

------------------------------------------------- 神秘商人 ----------------------------------------
require "script/ui/item/ItemUtil"
require "db/DB_Copy_mysticalgoods"
require "db/DB_Copy_mysticalshop"
require "db/DB_Vip"

local MysteryMerchant = {}

ActiveCache.MysteryMerchant = MysteryMerchant

MysteryMerchant._info = {}
MysteryMerchant._copy_data = {}
MysteryMerchant._key_merchant_disappear_time = "mystery_merchant_disappear_time"
MysteryMerchant._key_next_refresh_time = "next_refresh_time"

-- 请求神秘商人的数据
function MysteryMerchant:requestData(callbackRequestSucceed, is_at_login)
    local handleGetShopInfoExtension = function(cbFlag, dictData, bRet)
        self:handleGetShopInfo(cbFlag, dictData, bRet)
        if not table.isEmpty(self._info) then
            if is_at_login == true then
            self:saveCdTime(false, true)
            else
                self:saveCdTime(true, true)
            end
        end
        if callbackRequestSucceed ~= nil then
            callbackRequestSucceed()
        end
    end
    Network.rpc(handleGetShopInfoExtension, "mysmerchant.getShopInfo", "mysmerchant.getShopInfo", nil , true)
end

-- 向服务器获取神秘商人数据的回调
function MysteryMerchant:handleGetShopInfo( cbFlag, dictData, bRet)
    print(GetLocalizeStringBy("key_1242"))
    print_t(dictData)
	if(dictData.err ~= "ok") then
        return
	end
    if table.isEmpty(dictData.ret) then
        return
    end
    self:setInfo(dictData.ret)
end

function MysteryMerchant:getInfo()
    return self._info
end

function MysteryMerchant:setInfo(info)
    self._info = info
end

-- 设置打完副本后返回的神秘商人是否出现的数据
function MysteryMerchant:setCopyData(copy_data)
    self._copy_data = copy_data
end

function MysteryMerchant:getCopyData()
    return self._copy_data
end

-- 得到购买永久神秘商人的VIP等级要求
function MysteryMerchant:getBuyPerpetualVipLevel()
    require "script/utils/LuaUtil"
    return getNecessaryVipLevel("openMysicalCost", nil)
end

-- 得到购买永久神秘商人所需的等级和金币
function MysteryMerchant:getLevelAndGold()
    require "script/model/user/UserModel"
    require "script/utils/LuaUtil"
    local  vip_necessary = self:getBuyPerpetualVipLevel()
    local vip_level = nil
    if vip_necessary > UserModel.getVipLevel() then
        vip_level = vip_necessary
    else
        vip_level = UserModel.getVipLevel()
    end
    local vip_db = parseDB(DB_Vip.getDataById(vip_level + 1))
    return strTableToTable(vip_db.openMysicalCost)
end

-- 神秘商人是否存在
function MysteryMerchant:isExist()
    if not table.isEmpty(self._info) then
        if self:getMerchantDisappearTime() > 0 or self:getMerchantDisappearTime() == -1 then
            return true
        end
    end
    return false
end

-- 战斗结束后神秘商人是否出现
function MysteryMerchant:isAppear()
    return not table.isEmpty(self._copy_data)
end

--[[
    @des:       得到本次刷新花费的金币数量
    @return:    num
]]
function MysteryMerchant:getRefreshCostGoldCount()
    local shopData = DB_Copy_mysticalshop.getDataById(1)
    local baseGold = tonumber(shopData.baseGold)
    local refresh_num = tonumber(self._info.refresh_num)
    local growGold = tonumber(shopData.growGold) * refresh_num
    local costGoldNum = baseGold + growGold
    return costGoldNum
end

-- 当前刷新所使用物品的数量，物品ID从表里取
function MysteryMerchant:getRefreshElseCount()
    local refresh_else_item_data = self:getRefreshElseItemData()
    local cost_item_data = ItemUtil.getCacheItemInfoBy(refresh_else_item_data._info.id)
    local count = 0
    if cost_item_data ~= nil then
        count = tonumber(cost_item_data.item_num)
    end
    return count
end

-- 得到刷新所需物品的数量
function MysteryMerchant:getRefreshElseItemData()
    local cost_item_data = {}
    local shop_data = DB_Copy_mysticalshop.getDataById(1)
    local item_data = lua_string_split(shop_data.item, "|")
    cost_item_data._info = ItemUtil.getItemById(tonumber(item_data[1]))
    cost_item_data._count = tonumber(item_data[2])
    return cost_item_data
end

-- 判断当前刷新次数是否达到最大值，true:到了， false:没有
function MysteryMerchant:isRefreshMax()
    require "script/model/user/UserModel"
    local mysteryShopTimes = DB_Vip.getDataById(tonumber(UserModel.getVipLevel() + 1)).copyShopTime
    if tonumber(mysteryShopTimes) > tonumber(self._info.refresh_num) then
        return true
    end
    return false
end

--[[
    @des:       得到刷新剩余时间
    @return:    time interval
]]
function MysteryMerchant:getRefreshCdTime( )
    local remain_time = tonumber(self._info.refresh_cd) - BTUtil:getSvrTimeInterval()
    if remain_time < 0 then
        remain_time = 0
    end
    return remain_time
end

-- 得到神秘商人离开的剩余时间
function MysteryMerchant:getMerchantDisappearTime()
    local remain_time = nil
    if self._info.merchant_end_time == "-1" then
        remain_time = -1
    else
        remain_time = tonumber(self._info.merchant_end_time) - BTUtil:getSvrTimeInterval()
        if remain_time < 0 then
            remain_time = 0
        end
    end
    return remain_time
end

function MysteryMerchant:isPerpetual()
    if self._info.merchant_end_time == "-1" then
        return true
    end
    return false
end

-- 保存神秘商人离开和下次刷新的时刻
function MysteryMerchant:saveCdTime(save_next_refresh_time, save_merchant_end_time)
    local user_default = CCUserDefault:sharedUserDefault()
    if save_next_refresh_time then
        user_default:setIntegerForKey(self._key_next_refresh_time, tonumber(self._info.refresh_cd))
    end
    if save_merchant_end_time then
        user_default:setIntegerForKey(self._key_merchant_disappear_time,
                                    tonumber(self._info.merchant_end_time))
    end
end

-- 商品是否刷新了
function MysteryMerchant:isRefreshed( )
    if not self:isExist() then
        return false
    end
    local user_default = CCUserDefault:sharedUserDefault()
    local lastRefreshCd = user_default:getIntegerForKey(self._key_next_refresh_time)
    return BTUtil:getSvrTimeInterval() > lastRefreshCd
end

-- 得到商品数据
function MysteryMerchant:getItemTable()

    local items ={}
    for goodsId,canBuyNum in pairs(self._info.goods_list) do
        local item = {}
        local goodData = DB_Copy_mysticalgoods.getDataById(tonumber(goodsId))
        print_t(goodData)
        goods = lua_string_split(goodData.items,"|")
        item.id = goodData.id
        item.index = index
        item.type = tonumber(goods[1])
        item.tid = tonumber(goods[2])
        item.num = tonumber(goods[3])
        item.canBuyNum= tonumber(canBuyNum)
        item.costNum= tonumber(goodData.costNum)
        item.costType= tonumber(goodData.costType) 
        item.isHot = goodData.ishot
        table.insert(items, item)
    end
    return items
end

function MysteryMerchant:getHeroTable()
    local items = {}
    require "db/DB_Normal_config"
    local normal_config_db = parseDB(DB_Normal_config.getDataById(1))
    local goods_ids = normal_config_db.openMysical
    for i = 1, #goods_ids do
        local item = {}
        print("goods_id=", goods_ids[i])
        --local goodData = DB_Copy_mysticalgoods.getDataById(--[[tonumber(goods_ids[i])]]1001)
        --goods = lua_string_split(goodData.items,"|")
        --item.id = goodData.id
        --item.index = index
        item.type = 1--tonumber(goods[1])
        item.tid = goods_ids[i]--tonumber(goods[2])
        --item.num = tonumber(goods[3])
        --item.canBuyNum= tonumber(canBuyNum)
        --item.costNum= tonumber(goodData.costNum)
        --item.costType= tonumber(goodData.costType) 
        table.insert(items, item)
    end
    return items
end

-- 商品的可购买次数变化了
function MysteryMerchant:changeCanBuyNumByid(id , value)
    for goodsId, canBuyNum  in pairs(self._info.goods_list) do
        if tonumber(goodsId) == tonumber(id) then
            self._info.goods_list[goodsId] = tonumber(canBuyNum) -1
            break
        end
    end
end

------------------------------------------------- 限时抽将 ----------------------------------------

require "db/DB_Card_active"
require "script/model/utils/ActivityConfig"
require "db/DB_Tavern"

function getCardData( )
    local cardData= ActivityConfig.ConfigCache.heroShop.data[1] --DB_Card_active.getDataById(1)
    return cardData
end

-- 军团商店开启时间
function getHeroShopStartTime( ... )
    return tonumber( ActivityConfig.ConfigCache.heroShop.start_time )
end

-- 军团的结束时间
function getHeroShopEndTime( ... )
    return  tonumber( ActivityConfig.ConfigCache.heroShop.end_time )
end

function getHeroShopOpenTime(  )
    return tonumber( ActivityConfig.ConfigCache.heroShop.need_open_time )
end

-- 判断卡包活动时间有没有开
function isCardActiveOpen( )

    if(table.isEmpty(ActivityConfig.ConfigCache.heroShop)) then
        return false
    end
    if(ActivityConfig.ConfigCache.heroShop.data[1] == nil) then
        return false
    end

    print("ActivityConfig.ConfigCache.heroShop.data[1]", ActivityConfig.ConfigCache.heroShop.data[1])
    local isOpen= false
    local startTime=  tonumber( ActivityConfig.ConfigCache.heroShop.start_time )
    local endTime =   tonumber( ActivityConfig.ConfigCache.heroShop.end_time )
    local openTime =  tonumber( ActivityConfig.ConfigCache.heroShop.need_open_time )
    local openDateTime= tonumber(ServerList.getSelectServerInfo().openDateTime)
    if(startTime <=BTUtil:getSvrTimeInterval() and BTUtil:getSvrTimeInterval() <= endTime+ ActiveCache.getCardData().coseTime and openTime >= tonumber(ServerList.getSelectServerInfo().openDateTime)  ) then
        return true
    end 
    return false
end

-- 获得金币话费的
function getGoldCost( )
    local cardData = getCardData()
    local goldCost= tonumber(cardData.goldCost)
    return goldCost
end

-- 获得freeScore
function getFreeScore( )
    local cardData = getCardData() --DB_Card_active.getDataById(1)
    local freeScore = tonumber(cardData.freeScore)
    return freeScore
end

-- 获得goldScore
function getGoldScore( )
    local cardData = getCardData()
    local goldScore = tonumber(cardData.goldScore) 
    return goldScore
end

-- 显示英雄
function getShowHeroes(  )
    local cardData = getCardData()
    local heroes = lua_string_split(cardData.showHeros, "|") 
    return heroes
end

-- 得到累计变更掉落表需要得次数
function getChangeTimes()
    local cardData = getCardData()
    local tavernId= tonumber(cardData.tavernId) 
    local tavernData = DB_Tavern.getDataById(tavernId)
    local changeTimes = lua_string_split(tavernData.changeTimes, ",")
    return tonumber(changeTimes[1]) , tonumber(changeTimes[2])

end

function getFirstRewardText( )
    local cardData = getCardData()
    local firstRewardText = lua_string_split(cardData.first_reward_text, "|") 
    return firstRewardText
end

function getSecondRewardtext( )
    local cardData = getCardData()
    local secondRewardText = lua_string_split(cardData.second_reward_text, "|")
    return  secondRewardText
end

function getThirdRewardtext( )
    local cardData = getCardData()
    local rewardText = lua_string_split(cardData.third_reward_text, "|")
    return  rewardText
end

function getForthRewardtext(  )
    local cardData = getCardData()
    local rewardText = lua_string_split(cardData.fourth_reward_text, "|")
    return  rewardText
end

------------------------------- 网络数据 ---------------------
local _cardInfo = {}
-- 保存buyHero 得类型
local _buyHeroType= nil

function getCardInfo( )
    return _cardInfo
end

function setCardInfo(  cardInfo)
    _cardInfo = cardInfo    
end

-- 获得排名排名
function getRankInfo( )
    local rank_info=  _cardInfo.rank_info
    local rankInfo= {}
    for k,v in pairs(rank_info) do
        table.insert(rankInfo, v)
    end

    print("rank_info  is :")
    print_t(rank_info)
    local function keySort ( data_1, data_2 )
        return tonumber(data_1.rank ) < tonumber(data_2.rank)
    end
     table.sort( rankInfo, keySort)
    return rankInfo
end

-- 设置排名信息
function setRankInfo(rank_info )
    _cardInfo.rank_info = rank_info
end

--获得积分 _cardInfo.shop_info
function getScoreNum( )
    if( not _cardInfo.shop_info.score ) then
        return 0
    end
    return tonumber(_cardInfo.shop_info.score) 
end

-- 设置购买得类型
function setBuyHeroType( heroType )
   _buyHeroType= tonumber(heroType)  
end

--保存购买得类型
function getBuyHeroType( )
    return _buyHeroType
end

-- 获得增加得积分
--：1免费抽将 2免费金币抽将 3金币招将
function getAddScore()
    local score=0
    local cardData = getCardData() 
    if(_buyHeroType ==1) then
        score= cardData.freeScore
       else
        score = cardData.goldScore
    end
    return score
end

-- 可以免费购买的次数
function getFreeNum(  )
    return tonumber(_cardInfo.shop_info.free_num )
end

-- -- 
function addFreeNum( value)
   _cardInfo.shop_info.free_num= tonumber(_cardInfo.shop_info.free_num) + value
end

--[[
    @des:       得到刷新剩余时间
    @return:    time interval
]]
function getFreeCdTime( ... )
    local endShieldTime = tonumber(_cardInfo.shop_info.free_cd)
    local havaTime = endShieldTime - BTUtil:getSvrTimeInterval()
    if(havaTime > 0) then
        return havaTime
    else
        return 0
    end
end


-- 活动期内，金币购买的次数
function getGoldBuyNum(  )
    return tonumber(_cardInfo.shop_info.buy_num)
end

-- function get( ... )
--     -- body
-- end


-- 设置shop_info 中得信息
function setRankShopInfo( shop_info)
    _cardInfo.shop_info= shop_info
end

-- 获得玩家排名
function getRankNum( )
    return tonumber(_cardInfo.rank)
end

-- 设置玩家排名
function setRankNum(value )
    _cardInfo.rank= value
end


------------------------------------------- 消费累积数据解析 -------------------------------------------------                            

-- 得到对应活动的配置
function getDataByActiveId()
    local showData = {}
    for k,v in pairs(ActivityConfig.ConfigCache.spend.data) do
        table.insert(showData, v)
    end

    local function keySort ( showData_1, showData_2 )
        return tonumber(showData_1.id ) < tonumber(showData_2.id)
    end
    table.sort( showData, keySort)

    return showData
end

-- 获得消费累积活动的开始时间
function getSpendStartTime(  )
    return tonumber(ActivityConfig.ConfigCache.spend.start_time)
end

-- 获得消费累积活动的结束时间
function getSpendEndTime( ... )
    return tonumber(ActivityConfig.ConfigCache.spend.end_time) 
end

-- 获得消费累积活动的openTime
function getSpendOpenTime( )
    return tonumber(ActivityConfig.ConfigCache.spend.need_open_time)
end

------------ 消费累积服务端数据 --------
local consumInfo = nil
-- 设置消费累积活动数据
function setConsumeServiceInfo( ret )
    consumInfo = ret
end 

-- 得到消费累积活动数据
function getConsumeServiceInfo( ... )
    return consumInfo
end

-- 得到已经消费的金币数量
function getConsumeGoldNum( ... )
    local data = getConsumeServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return 0
    end
    return tonumber(data.gold_accum)
end

-- 判断改奖励是否领取过
function isHaveGetRewardById( id )
    local data = getConsumeServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return false
    end
    local isData = false
    for k,v in pairs(data.reward) do
        if( tonumber(v) == tonumber(id) )then
            isData = true
            break
        end
    end
    return isData
end

-- 添加已经领取过的奖励id
function addHaveGetRewardId( id )
    local data = getConsumeServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return
    end
    local isData = false
    for k,v in pairs(data.reward) do
        if( tonumber(v) == tonumber(id) )then
            isData = true
            break
        end
    end
    if(isData == false)then
        table.insert(data.reward,id)
    end
end

-- 领取成功后修改本地数据
function addRewardById( id )
    -- 得到这条奖励的数据
    require "script/model/user/UserModel"
    local data = ActivityConfig.ConfigCache.spend.data[tonumber(id)]
    local thisData = getItemsDataByStr(data.reward)
    for k,v in pairs(thisData) do
        if( v.type == "silver" ) then
            -- 加银币
            UserModel.addSilverNumber(tonumber(v.num))
        elseif( v.type == "soul" ) then
            -- 加将魂
            UserModel.addSoulNum(tonumber(v.num))
       elseif( v.type == "gold" ) then
            -- 加金币
            UserModel.addGoldNumber(tonumber(v.num))
        elseif( v.type == "execution" ) then
            -- 加体力点
            UserModel.addEnergyValue(tonumber(v.num))
        elseif( v.type == "stamina" ) then
            -- 加耐力点
            UserModel.addStaminaNumber(tonumber(v.num))
        elseif( v.type == "prestige") then
            -- 加声望
            UserModel.addPrestigeNum(tonumber(v.num))
        elseif( v.type == "jewel") then
            -- 加魂玉
            UserModel.addJewelNum(tonumber(v.num))
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------

------------------------------------------------------ 春节礼包活动 -----------------------------------------------------
-- 得到对应活动的配置
function getNewYearDataByActiveId()
    local showData = {}
    for k,v in pairs(ActivityConfig.ConfigCache.signActivity.data) do
        table.insert(showData, v)
    end
    print("showData:")
    print_t(showData)
    local function keySort ( showData_1, showData_2 )
        return tonumber(showData_1.id ) < tonumber(showData_2.id)
    end
    table.sort( showData, keySort)

    return showData
end     

-- 获得春节礼包活动的开始时间
function getNewYearStartTime(  )
    return tonumber(ActivityConfig.ConfigCache.signActivity.start_time)
end

-- 获得春节礼包活动的结束时间
function getNewYearEndTime( ... )
    return tonumber(ActivityConfig.ConfigCache.signActivity.end_time) 
end

-- 获得春节礼包活动的openTime
function getNewYearOpenTime( )
    return tonumber(ActivityConfig.ConfigCache.signActivity.need_open_time)
end

---- 后端数据 --- 
local newYearInfo = nil

-- 设置春节礼包活动数据
function setNewYearServiceInfo( ret )
    newYearInfo = ret
end 

-- 得到春节礼包活动数据
function getNewYearServiceInfo( ... )
    print("newYearInfo~~~~~")
    print_t(newYearInfo)
    return newYearInfo
end

-- 得到已登录的天数
function getNewYearSignDayNum( ... )
    local data = getNewYearServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return 0
    end
    return tonumber(data.acti_sign_num)
end

-- 判断改奖励是否领取过
function isHaveGetNewYearRewardById( id )
    local data = getNewYearServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return false
    end
    local isData = false
    for k,v in pairs(data.va_acti_sign) do
        if( tonumber(v) == tonumber(id) )then
            isData = true
            break
        end
    end
    return isData
end

--获取已经领取的奖励数据 add by fuqiongqiong
function getHadSignIdArr( ... )
    local data = getNewYearServiceInfo()
    local tSignDays = {}
    for i,v in pairs(data.va_acti_sign) do
        tSignDays[tonumber(v)] = tonumber(v)
    end
    return tSignDays
end
--获取是活动的第几天 add by fuqiongqiong
function getTobayNum( ... )
    local data = getNewYearServiceInfo()
    return tonumber(data.today)
end
--判断当天的是否已经被领取了,false为未领取，true为领取
function ishaveGainToday( ... )
    local isHave = false
    local array_list = {}
    local dayNum = getTobayNum()
    local array = getHadSignIdArr()
    if(dayNum > 0 and  table.isEmpty(array))then
        return false
    end
    for k,v in pairs(array) do
        array_list[tonumber(v)] = tonumber(v)
        
    end
        if array_list[dayNum] == dayNum then
            isHave = true
        end
   return isHave
end
-- 添加已经领取过的奖励id
function addHaveGetNewYearRewardId( id )
    local data = getNewYearServiceInfo()
    if(data == nil or table.isEmpty(data) )then
        return 
    end
    local isData = false
    for k,v in pairs(data.va_acti_sign) do
        if( tonumber(v) == tonumber(id) )then
            isData = true
            break
        end
    end
    if(isData == false)then
        table.insert(data.va_acti_sign,id)
    end
end

-- 领取成功后修改本地数据
function addNewYearRewardById( id )
    -- 得到这条奖励的数据
    local data = ActivityConfig.ConfigCache.signActivity.data[tonumber(id)]
    local thisData = getItemsDataByStr(data.reward)
    for k,v in pairs(thisData) do
        if( v.type == "silver" ) then
            -- 加银币
            UserModel.addSilverNumber(tonumber(v.num))
        elseif( v.type == "soul" ) then
            -- 加将魂
            UserModel.addSoulNum(tonumber(v.num))
       elseif( v.type == "gold" ) then
            -- 加金币
            UserModel.addGoldNumber(tonumber(v.num))
        elseif( v.type == "execution" ) then
            -- 加体力点
            UserModel.addEnergyValue(tonumber(v.num))
        elseif( v.type == "stamina" ) then
            -- 加耐力点
            UserModel.addStaminaNumber(tonumber(v.num))
        elseif( v.type == "prestige") then
            -- 加声望
            UserModel.addPrestigeNum(tonumber(v.num))
        elseif( v.type == "jewel") then
            -- 加魂玉
            UserModel.addJewelNum(tonumber(v.num))
        end
    end
end


----------------------------------------- 解析表公用方法 --------------------------------------------

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
        data.type = tab[1]
        data.id   = tab[2]
        data.num  = tab[3]
        table.insert(goodsData,data)
    end
    return goodsData
end

-- 根据表配置得到展示物品的数据
function getItemsDataByStr( rewardDataStr )
    local goodsData = analyzeGoodsStr(rewardDataStr)
    print("--------------------")
    print_t(goodsData)
    if(goodsData == nil)then
        return
    end
    local itemData ={}
    for k,v in pairs(goodsData) do
        local tab = {}
        if( tonumber(v.type) == 1 ) then
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 2 ) then
            -- 将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
       elseif(tonumber(v.type) == 3 ) then
            -- 金币
            tab.type = "gold"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 4 ) then
            -- 体力
            tab.type = "execution"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 5 ) then
            -- 耐力
            tab.type = "stamina"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 6 ) then
            -- 单个物品  类型6 类型id|物品数量默认1|物品id  以前约定特殊处理
            tab.type = "item"
            tab.num  = 1
            tab.tid  = tonumber(v.num)
        elseif(tonumber(v.type) == 7 ) then
            -- 多个物品
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 8 ) then
            -- 等级*银币
            tab.type = "silver"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 9 ) then
            -- 等级*将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 10 ) then
            -- 单个英雄 类型10 类型id|物品数量默认1|英雄id  以前约定特殊处理
            tab.type = "hero"
            tab.num  = 1
            tab.tid  = tonumber(v.num)
        elseif(tonumber(v.type) == 11 ) then
            -- 魂玉
            tab.type = "jewel"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 12 ) then
            -- 声望
            tab.type = "prestige"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 13 ) then
            -- 多个英雄
            tab.type = "hero"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 14 ) then
            -- 多个物品
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        else
            print("此类型不存在。。。",tonumber(v.type))
            return
        end
        -- 存入数组
        table.insert(itemData,tab)
    end
    return  itemData
end

-----------------------------------------兑换活动数据----------------------------------

-- 得到可以兑换的次数
function getMaxChangeNum( id )
    return tonumber(ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].changeTime)
end

-- 得到参与等级
function getChangeOpenLv( ... )
    return tonumber(ActivityConfig.ConfigCache.actExchange.data[1].level)
end

-- 得到刷新的金币费用
-- 参数 当前已兑换次数
-- 刷新费用=刷新初始金币+ 已经刷新次数*递增金币
function getChangeRefreshGold( curNum , id)
    local data = string.split(ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].gold, "|")
    local spendCont = tonumber(data[1]) + tonumber(curNum)*tonumber(data[2])
    -- 刷新金币上限
    if(spendCont > tonumber(ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].goldTop) )then
        spendCont = tonumber(ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].goldTop)
    end
    return spendCont
end

-- 整理后端返回材料数据
-- 材料只有 金币，物品
function getListReqData( req )
    local items = {}
    for k,v in pairs(req) do
        if(k == "gold")then
            -- 金币
            local itemTab = {}
            itemTab.type = "gold"
            itemTab.needNum  = tonumber(v)
            itemTab.haveNum = UserModel.getGoldNumber()
            itemTab.tid  = 0
            itemTab.name = GetLocalizeStringBy("key_1491")
            table.insert(items,itemTab)
        elseif(k == "item")then
            -- 物品
            for tid,num in pairs(v) do
                local itemTab = {}
                itemTab.type = "item"
                itemTab.needNum  = tonumber(num)
                itemTab.tid  = tid
                itemTab.haveNum = ItemUtil.getCacheItemNumByTidAndLv(tid)
                local itemData = ItemUtil.getItemById(tid)
                itemTab.name = itemData.name
                table.insert(items,itemTab)
            end
        else
            print("no this Type")
        end
    end
    return items
end

-- 整理目标物品数据
function getListDesItemData( itemData )
    local items = {}
    for k,v in pairs(itemData) do
        if(k == "gold")then
            -- 金币
            local itemTab = {}
            itemTab.type = "gold"
            itemTab.num  = tonumber(v)
            itemTab.tid  = 0
            itemTab.name = GetLocalizeStringBy("key_1491")
            table.insert(items,itemTab)
        elseif(k == "item")then
            -- 物品
            for tid,num in pairs(v) do
                local itemTab = {}
                itemTab.type = "item"
                itemTab.num  = tonumber(num)
                itemTab.tid  = tid
                local itemData = ItemUtil.getItemById(tid)
                itemTab.name = itemData.name
                table.insert(items,itemTab)
            end
        else
            print("no this Type")
        end
    end
    return items
end


-- 得到兑换的物品的tid
function getChangeItemTid( ... )
    local items = {}
    local data = string.split(ActivityConfig.ConfigCache.actExchange.data[1].itemView, ",")
    for i=1,#data do
        local tab = {}
        tab.itemsTid = string.split(data[i],"|")
        tab.nameKey = i
        table.insert(items,tab)
    end
    return items
end

-- 得到兑换物品的类名称
function getChangeNames( )
    local data = string.split(ActivityConfig.ConfigCache.actExchange.data[1].viewName, ",")
    return data
end

-- 取得当天的活动配置数组
function getTodayData( p_day )
    local data = string.split(ActivityConfig.ConfigCache.actExchange.data[1].conversionFormula, ",")
    local retTab = string.split(data[tonumber(p_day)],"|")
    return retTab
end

-- 得到招神将是否有额外掉落
function getIsExtraDropAcitive( ... )
    local retData = false
    if(ActivityConfig.ConfigCache.actExchange.start_time == nil or ActivityConfig.ConfigCache.actExchange.end_time == nil)then
        print("return false1")
        return false
    elseif( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.actExchange.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.actExchange.end_time) ) then
        print("return false2")
        return false
    else
        print("go on 1")
    end 
    if(ActivityConfig.ConfigCache.actExchange.need_open_time == nil)then
        print("return false3")
        return false
    elseif(tonumber(ActivityConfig.ConfigCache.actExchange.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
        print("return false4")
        return false
    else
        print("go on 2")
    end
    -- 等级限制
    local level = ActiveCache.getChangeOpenLv()
    if(level == nil)then
        return false
    elseif(tonumber(level) > UserModel.getHeroLevel()) then
        return false
    else
        print("go on 3")
    end
    if(ActivityConfig.ConfigCache.actExchange.data[1])then
        local dataStr = ActivityConfig.ConfigCache.actExchange.data[1].tavernId
        if(dataStr ~= nil and dataStr ~= "")then
            print("dataStr == ", dataStr)
            local data = string.split(dataStr, ",")
            if(data[3])then
                if( tonumber(data[3]) > 0)then
                    print("go on 4")
                    -- tavernId 字段为 第三个不为0 表示抽奖第三档有额外掉落
                    retData = true
                end
            end
        end
    end
    return retData
end

-- 得到金币猎魂是否有额外掉落
function getIsExtraDropAcitiveInHunt( ... )
    local retData = false
    if(ActivityConfig.ConfigCache.actExchange.start_time == nil or ActivityConfig.ConfigCache.actExchange.end_time == nil)then
        print("return false1")
        return false
    elseif( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.actExchange.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.actExchange.end_time) ) then
        print("return false2")
        return false
    else
        print("go on 1")
    end 
    if(ActivityConfig.ConfigCache.actExchange.need_open_time == nil)then
        print("return false3")
        return false
    elseif(tonumber(ActivityConfig.ConfigCache.actExchange.need_open_time) < tonumber(ServerList.getSelectServerInfo().openDateTime) ) then
        print("return false4")
        return false
    else
        print("go on 2")
    end
    -- 等级限制
    local level = ActiveCache.getChangeOpenLv()
    if(level == nil)then
        return false
    elseif(tonumber(level) > UserModel.getHeroLevel()) then
        return false
    else
        print("go on 3")
    end
    if(ActivityConfig.ConfigCache.actExchange.data[1])then
        local dropId = ActivityConfig.ConfigCache.actExchange.data[1].soulDropId
        if( dropId ~= nil and dropId ~= "" and tonumber(dropId) > 0)then
            print("go on 4")
            -- soulDropId 字段不为0 表示金币召唤神龙有掉落
            retData = true
        end
    end
    return retData
end
-------------------------------------------武将变身-----------------------------------
function heroTransfer(callback, hid, countryId, selectedHtid)
    local handleHeroTransfer = function(cbFlag, dictData, bRet)
        if dictData.err ~= "ok" then
            return
        end
        if callback ~= nil then
            callback(dictData.ret)
        end
    end
    local arg = Network.argsHandler(hid, countryId, selectedHtid)
    Network.rpc(handleHeroTransfer, "hero.transfer", "hero.transfer", arg, true)
end

function heroTransferConfirm(callback, hid)
    local handleHeroTransferConfirm = function(cbFlag, dictData, bRet)
        if dictData.err ~= "ok" then
            return
        end
        if callback ~= nil then
            callback(dictData.ret)
        end
    end
    local arg = Network.argsHandler(hid)
    Network.rpc(handleHeroTransferConfirm, "hero.transferConfirm", "hero.transferConfirm", arg, true)
end

function heroTransferCancel(callback, hid)
    local handleHeroTransferCancel = function(cbFlag, dictData, bRet)
        if dictData.err ~= "ok" then
            return
        end
        if callback ~= nil then
            callback()
        end
    end
    local arg = Network.argsHandler(hid)
    Network.rpc(handleHeroTransferCancel, "hero.transferCancel", "hero.transferCancel", arg, true)
end

function getTransferHero()
    local heros = HeroModel.getAllHeroes()
    for htid, hero in pairs(heros) do
		if hero.transfer ~= nil and hero.transfer ~= "0" then
            hero.localInfo = DB_Heroes.getDataById(hero.htid)
            return hero
        end
	end
    return nil
end

-- 是否是未取消或者替换变身的武将
function isUnhandleTransfer(hid)
    require "script/model/utils/HeroUtil"
    local heroData = HeroUtil.getHeroInfoByHid(hid)
    return heroData.transfer ~= nil and heroData.transfer ~= "0"
end

--added by Zhang Zihang
--重生完武将后重置武将transfer
function setUserTransfer(hid)
    require "script/model/utils/HeroUtil"
    local heroData = HeroUtil.getHeroInfoByHid(hid)
    heroData.transfer = "0"
end

-- 筛选条件
function couldTransfers(hero)
    require "db/DB_Heroes"
    -- 是否是主角
    if HeroModel.isNecessaryHero(tonumber(hero.htid)) then
        return false
    end

    local heroDb = DB_Heroes.getDataById(tonumber(hero.htid))
    local index = nil
    if heroDb.heroQuality == 12 then
        index = 1
    elseif heroDb.heroQuality == 13 then
        index = 2
    elseif heroDb.heroQuality == 15 then
        index = 3
    else
        return false
    end
    local countryHtids = parseDB(DB_Normal_config.getDataById(1))[ string.format("changeCard%d", heroDb.country)]
    if countryHtids[4] ~= nil then
        for i = 1, #countryHtids[4] do
            table.insert(countryHtids[3], countryHtids[4][i])
        end
        countryHtids[4] = nil
    end
    local transferHtids = nil
    if countryHtids  ~= nil then
        transferHtids = countryHtids[index]
    end
    if transferHtids == nil then
        return false
    end
    -- 是否在阵容里
    require "script/ui/hero/HeroPublicLua"
    if HeroPublicLua.isBusyWithHid(hero.hid) then
        return false
    end
    -- 是否是小伙伴
    require "script/ui/formation/LittleFriendData"
    if LittleFriendData.isInLittleFriend(hero.hid) then
        return false
    end
    -- 是否是助战军
    require "script/ui/formation/secondfriend/SecondFriendData"
    if SecondFriendData.isInSecondFriendByHid(hero.hid) then
        return false
    end

    -- 是否在神兵副本的阵容里
    require "script/ui/godweapon/godweaponcopy/GodWeaponCopyData"
    if GodWeaponCopyData.isOnCopyFormationBy(hero.hid) then
        return false
    end
    
    for i = 1, #transferHtids do
        if transferHtids[i] == tonumber(hero.htid) then
            return true
        end 
    end
    return false
end

function getTransferHeroesFileter()
    local heroHtidFileter = {}
    local heros = HeroModel.getAllHeroes()
    for htid, hero in pairs(heros) do
        if not couldTransfers(hero) then
            table.insert(heroHtidFileter, hero.hid)
        end
	end
    return heroHtidFileter
end

function getTransferCost(hero)
    if hero == nil then
        return 0
    end
    local heroDb = DB_Heroes.getDataById(tonumber(hero.htid))
    local index = nil
    if heroDb.heroQuality == 12 then
        index = 1
    elseif heroDb.heroQuality == 13 then
        index = 2
    end 

    local cost = nil
    if index ~= nil then
        cost = parseDB(DB_Normal_config.getDataById(1)).changeCardCost[index][tonumber(hero.evolve_level) + 1]
    end
    return cost
end
--------判断月签到活动是否有红点，add by djn
function isHaveMonthSign( ... )
    require "script/ui/rechargeActive/MonthSignService"
    require "script/ui/rechargeActive/MonthSignData"
    require "script/model/user/UserModel"
    local tag = false
    if(IsNewInMonthSign())then
        --用户之前尚未进入过月签到活动，icon上添加new的图标，就不用红点了
        tag = false
    else
        local info =MonthSignData.getSignData()
        local timeArray = info.sign_time

        if(timeArray == nil or timeArray == 0)then
            --没有时间戳，说明没月签到过
           -- print("上次时间戳为空")
            tag = true
        end
        require "script/utils/TimeUtil"
        local curTime = TimeUtil.getSvrTimeByOffset() 
        local curdate = os.date("*t", curTime)
        local lastdate = os.date("*t", tonumber(timeArray))
       -- print("输出当前时间戳",curdate.day)
       -- print("输出上次时间戳",lastdate.day)
        if (curdate.year == lastdate.year and curdate.month == lastdate.month and curdate.day == lastdate.day)then
            --上次签到与当天是同一天，可能有机会
            --print("检测为同一天")
           -- require "script/ui/rechargeActive/MonthSignLayer"
            local haveChance = MonthSignData.haveChance(info.sign_num)
            if(haveChance)then
                if(MonthSignData.todayVip(info.sign_num) ~= -1 and UserModel.getVipLevel() >= MonthSignData.todayVip(info.sign_num))then
                   -- print("月签到今天有机会升级补领,并且已经达到了VIP等级，给提示")
                    tag = true
                else
                    tag = false
                end
            else
               -- print("月签到今天没机会升级补领，没提示")
                tag = false
            end
            --tag = false
        else
            --上次签到与当天不是同一天
            --要加上判断，这个月有没有签满
            if(tonumber(info.sign_num) >= MonthSignData.getSignNumInDB())then
                tag = false
            else
           
                tag = true
            end
        end
    end
        --print("tag的值",tag)
        return tag
    
end
--------判断积分轮盘是否有红点提示  add by DJN
function isHaveRoulette( ... )
    local flag = false
    if ActivityConfigUtil.isActivityOpen("roulette") then
        require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"
        local boxInfo = ScoreWheelData.getSignData().va_boxreward
        
        print("va_boxreward=========")
        if boxInfo == nil then
            flag = false
        else
            for k,v in pairs(boxInfo)do
                if(tonumber(v.status) == 2)then
                    return true
                end
            end
        end
      --又新增了排行榜 当排行榜有奖励的时候也有红点
        if(ScoreWheelData.isInWheel() == false and ScoreWheelData.ifGotReward() == false and ScoreWheelData.ifInRank() and ScoreWheelData.isScoreEnhough() )then
            return true
        end
        
    end
    return flag

end
------判断聚宝盆是否有红点提示  add by DJN
function isHaveBowl( ... )
    if ActivityConfigUtil.isActivityOpen("treasureBowl") then
        local bowlInfo = BowlData.getBowlInfo()
            if(table.isEmpty(bowlInfo) == true)then return false end
            for i = 1,3 do
                print("bowlInfo.type[tostring(i)].reward")
                print_t(bowlInfo.type[tostring(i)].reward)
                for k,v in pairs(bowlInfo.type[tostring(i)].reward)do
                    if(tonumber(v) == 1 )then
                        return true
                    end
                end
            end
    end
    return false
end
----判断积分商城是否有红点 add by DJN
function isHaveScoreShop( ... )
    if ActivityConfigUtil.isActivityOpen("scoreShop") then
        local shopInfo = ScoreShopData.getShopInfo()
            if (tonumber(shopInfo.point) >= ScoreShopData.getMinCost())then
                return true
            end
    end
    return false
end

--烧鸡福利活动是否开启
function isChickenActiveOpen()
    return ActivityConfigUtil.isActivityOpen("supply")
end

--烧鸡福利活动开始时间
function getChickenOpenTime()
    return ActivityConfigUtil.getDataByKey("supply").start_time
end

--烧鸡福利活动结束时间
function getChickenEndTime()
    return ActivityConfigUtil.getDataByKey("supply").end_time
end

-- 福利活动类型
WealType = {
    MULT_COPY = 11,             -- 普通副本多倍经验
}
-- 传入的福利活动是否开启
function isWealActivityOpen( p_wealType )
    local ret = false
    if p_wealType == WealType.MULT_COPY then
        require "db/DB_WealActivity_kaifu"
        local wealActivityKaifuData = DB_WealActivity_kaifu.getDataById(11)
        if wealActivityKaifuData.doubleExpNeedLv > UserModel.getHeroLevel() then
            return false
        end
        if ActivityConfigUtil.isActivityOpen("weal") then
            local activityData = ActivityConfigUtil.getDataByKey("weal")
            if activityData.data[1]["id"] == 11 then
                return true
            end
        end
    end
    return ret
end

-- 得到云游商人的配置
function getTravelShopConfig( ... )
    return ActivityConfig.ConfigCache.travelShop.data
end

-- 得到嘉年华配置
function getWorldcarnivalConfig( ... )
    return ActivityConfig.ConfigCache.worldcarnival.data
end

--[[
    @des    : 缤纷回馈 是否有 小红点  add by yangrui
    @param  : 
    @return : 
--]]
function isRechargeGiftHaveTip( ... )
    if ActivityConfigUtil.isActivityOpen("rechargeGift") then
        local waitReceiveRewardNum = getRechargeGiftTipNum()
        if waitReceiveRewardNum > 0 then
            return true
        else
            return false
        end
    else
        return false
    end
end

--[[
    @des    : 小红点中的数目  add by yangrui
    @param  : 
    @return : 
--]]
function getRechargeGiftTipNum( ... )
    -- 当前已充值金币数
    local curRechargedGoldNum = RechargeGiftData.getRechargedGoldNum()
    local curRewardTable = {}
    local rewardData = ActivityConfigUtil.getDataByKey("rechargeGift").data
    for index,data in pairs(rewardData) do
        if curRechargedGoldNum >= tonumber(rewardData[index].expenseGold) then
            table.insert(curRewardTable,index)
        end
    end
    local receivedRewardTable = RechargeGiftData.getReceivedRewardData()
    return #curRewardTable - #receivedRewardTable
end

--获取红包开启时间
function getRedPacketStartTime( ... )
    -- body
    return tonumber(ActivityConfig.ConfigCache.envelope.start_time)
end
--获取红包结束时间
function getRedPacketEndTime( ... )
    -- body
    return tonumber(ActivityConfig.ConfigCache.envelope.end_time)
end
--获取红包最多发多少个
function getRedPacketMacCount( ... )
    -- body
    return tonumber(ActivityConfig.ConfigCache.envelope.data[1].numlimit)
end
--获取最少发多少金币
function getRedPacketMinGold( ... )
    -- body
    return tonumber(ActivityConfig.ConfigCache.envelope.data[1].goldlimit)
end
