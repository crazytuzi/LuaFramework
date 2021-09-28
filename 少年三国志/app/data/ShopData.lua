local ShopData =  class("shopData")
require "app.cfg.item_awaken_info"
local BagConst = require("app.const.BagConst")
function ShopData:ctor()

    --[[
        是否从VIP layer进入的,用于切换充值和viplayer切换
    ]]
    self._isVipEnter = false 

    -- --里面含
    self.dropKnightInfo={
        lp_free_count = 0, --良品已使用免费次数-每日
        lp_free_time = 0, -- 良品免费时间
        jp_free_time = 0, --极品免费时间
        jp_recruited_times = 0, --极品已招募次数
        zy_cycle = 0,   --魏蜀吴群  0-7
        zy_recruited_times = 0,  --今日已抽次数
    }
    self.secretShopInfo = {
        marketIds = {},
        marketIdNums = {},
        timerange = 0,
        refreshNum = 0,
        lastClickTime = 0,  -- 最后一次进入时间
        nextRefreshTime = 0,  -- 根据lastClickTime 计算出来的下一次刷新时间
    }
    self.awakenShopInfo = {
        lastClickTime = 0,  -- 最后一次进入时间
        nextRefreshTime = 0,  -- 根据lastClickTime 计算出来的下一次刷新时间
    }

    self.petShopInfo = {
        lastClickTime = 0,  -- 最后一次进入时间
        nextRefreshTime = 0,  -- 根据lastClickTime 计算出来的下一次刷新时间
    }

    self._dropDate = nil
    self._vipDate = nil
    self._scoreDate = nil

    --是否进入过积分商城
    self._hasEnterScore = false

    --是否获取过抽卡信息
    self._hasGetDropInfo = false

    --是否首充
    self._rechargeList = {}   --以id为key

    --是否领取过首充,活动里用到
    self._bonus = false
    self._monthCard = {} --以id为key



    --积分商城道具购买次数
    self.scorePurchaseList = nil


    --积分商店的商品类型
    self.TAB_SHANGPIN = 1      --商品
    self.TAB_ZIZHUANG = 2      --紫装
    self.TAB_CHENGZHUANG = 3   --橙装
    self.TAB_HONGZHUANG = 4    --红装
    self.TAB_JINZHUANG = 5     --金装
    self.TAB_JIANGLI   = 9     --奖励

    -- 神将商店免费刷新次数
    self._nSecretShopFreeCount = 0
    -- 觉醒商店免费刷新次数
    self._nAwakenShopFreeCount = 0
    -- 战宠商店免费刷新次数
    self._nPetShopFreeCount = 0

    -- 为了3个商店的红点机制，当有免费刷新次数增加时，才显示红点
    self._nSecretShopPreFreeCount = 0
    self._nAwakenShopPreFreeCount = 0
    self._nPetShopPreFreeCount = 0

    -- 觉醒道具标记
    self._awakenTags = {}
    self._awakenDetail = {}
    self._awakenTagsFlag = {}

    -- 上一次拉取月卡信息的日期
    self._monthCardDate = nil
end

function ShopData:setAwakenTags(_awakenTags)
    self._awakenTags = _awakenTags
    self._awakenTagsFlag = {}
    self._awakenDetail = {}
    for i,v in ipairs(self._awakenTags) do
        self._awakenTagsFlag[v] = true
        if v > 0 then 
            table.insert(self._awakenDetail,#self._awakenDetail+1,item_awaken_info.get(v))
        end 
    end
    local sortFunc = function(a, b)
        if not a or not b then 
            return true 
        end 
        return a.quality > b.quality
    end
    table.sort(self._awakenDetail,sortFunc)
end 

function ShopData:getAwakenTags()
    return self._awakenDetail
end 

function ShopData:isAwakenTags(_id)
    return self._awakenTagsFlag[_id] and true or false 
end 

-- 大于20个就不能再加了  并判断_id 是否合法
function ShopData:canAdd(_id)
    if item_awaken_info.get(_id) and #self._awakenTags < BagConst.AWAKEN_ITEM_MAXTAG then 
        return true 
    else 
        return false
    end 
end 
--是否自动显示神秘商店按钮的条件是, 
--等级>=10,
--从来没有点击过神秘商店, 或者 神秘商店的刷新时间点(2个小时1次) 已经到了
function ShopData:shouldShowSecretShop()
    if G_Me.userData.level < 10 then
        return false
    end

    if self.secretShopInfo.lastClickTime ==  0 then
        return true
    end

    if self.secretShopInfo.nextRefreshTime <= G_ServerTime:getTime()  then
        return true
    end

    if self:getSecretShopFreeCount() == 10 or self:isSecretShopFreeCountChanged() then
    	return true
    end

    return false
end


function ShopData:setShohwSecretShop()
    local t = G_ServerTime:getTime()   
    self.secretShopInfo.lastClickTime = t
    
    local d = math.floor( (t +7200) / 7200 )

    self.secretShopInfo.nextRefreshTime = d *7200

end


-- 判断是否需要显示战宠商店红点，规则同神将商店
function ShopData:shouldShowPetShop()
    if not G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").PET_SHOP) then
        return false
    end

    if self.petShopInfo.lastClickTime ==  0 then
        return true
    end

    if self.petShopInfo.nextRefreshTime <= G_ServerTime:getTime()  then
        return true
    end

    if self:getPetShopFreeCount() == 10 or self:isPetShopFreeCountChanged() then
    	return true
    end

    return false
end

function ShopData:setShowPetShop()
    local t = G_ServerTime:getTime()   
    self.petShopInfo.lastClickTime = t
    
    local d = math.floor( (t +7200) / 7200 )

    self.petShopInfo.nextRefreshTime = d *7200

end


-- 判断是否需要显示觉醒商店红点，规则同神将商店
function ShopData:shouldShowAwakenShop()
    if not G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").AWAKEN) then
        return false
    end

    if self.awakenShopInfo.lastClickTime ==  0 then
        return true
    end

    if self.awakenShopInfo.nextRefreshTime <= G_ServerTime:getTime()  then
        return true
    end

    if  self:getAwakenShopFreeCount() == 10 or self:isAwakenShopFreeCountChanged() then
    	return true
    end

    return false
end


function ShopData:setShowAwakenShop()
    local t = G_ServerTime:getTime()   
    self.awakenShopInfo.lastClickTime = t
    
    local d = math.floor( (t +7200) / 7200 )

    self.awakenShopInfo.nextRefreshTime = d *7200

end



function ShopData:setVipEnter(p)
    self._isVipEnter = p
end

function ShopData:getVipEnter()
    return self._isVipEnter
end

--function ShopData:setSecretShopInfo(ids, nums)
--    self.secretShopInfo.marketIds = ids
--    self.secretShopInfo.marketIdNums = nums or {}
--    self.secretShopInfo.timerange =  math.floor(os.date("%H", os.time())/2)
--
--end
--
--function ShopData:setSecretShopRefreshNum(num)
--    self.secretShopInfo.refreshNum = num
--end
--
---- 更新神秘商店缓存中的数据
--function ShopData:setSecretShopState(index, num)
--    self.secretShopInfo.marketIdNums[index] = num
--end


--检查是否已经进入过积分商城
function ShopData:checkEnterScoreShop()
    local date = G_ServerTime:getDate()
    if self._scoreDate ~= date then
        return false
    end
    return self._hasEnterScore
end

--检查礼包是否可购买
function ShopData:checkGiftItemPurchaseEnabled(item)
    if item == nil then
        return false
    end
    local vip = -1
    local maxNum = 0
    local key = nil
    repeat 
        vip = vip+1
        key =string.format("vip%s_num",vip)
    until item[key] ~= nil and item[key] >0
    vip = vip>=0 and vip or 0
    maxNum = item[key]
    local texture = nil   --判断是否是已经购买
    local purchasedNum = self:getScorePurchaseNumById(item.id)
    if purchasedNum >= maxNum then
        --已购买
        texture = "ui/text/txt-small-btn/yigoumai.png"
    else
        --vip等级限制
        texture = "ui/text/txt-small-btn/goumai.png"
    end

    return maxNum>purchasedNum,vip,texture
end

--获取某个礼包最大购买数量
function ShopData:getGiftMaxPurchaseNum(_id)
    require("app.cfg.shop_score_info")
    if _id == nil then
        return 1
    end
    local item = shop_score_info.get(_id)
    if item == nil then
        return 1
    end
    local vip = -1
    local maxNum = 0
    local key = nil
    repeat 
        vip = vip+1
        key =string.format("vip%s_num",vip)
    until item[key] ~= nil and item[key] >0
    vip = vip>=0 and vip or 0
    maxNum = item[key]

    return maxNum
end

--获取价格
--[[
    item 
    times:第几次购买，从已购买次数开始计数
]]
function ShopData:getPriceById(id,times)
    local item = shop_score_info.get(id)
    return self:getPrice(item,times)
end

function ShopData:getPrice(item,times)
    if not item then
        return 0
    end
    times = times or 1
    local purchasedNum = self:getScorePurchaseNumById(item.id)
    if item.price_add_id ~= nil and item.price_add_id > 0 then
        -- local vipKey = string.format("vip%s_num",G_Me.userData.vip)
        local info = shop_score_info.get(item.id)
        if not info then
            return item.price
        end
        local key = string.format("vip%d_num",G_Me.userData.vip)
        local maxNum = info[key]

        local price_info = nil
        if maxNum ~= 0 and purchasedNum ==  maxNum then
            --已经达到最大购买次数了,显示最后一次购买的价格
            price_info = require("app.scenes.shop.ShopTools").getPriceInfo(item.price_add_id, purchasedNum)
        else  
            price_info = require("app.scenes.shop.ShopTools").getPriceInfo(item.price_add_id, purchasedNum+times)
        end
        if price_info ~= nil then
            return price_info.price
        else
            return item.price
        end
    else
        return item.price
    end
end

--获取总金额
function ShopData:getTotalPrice(item,totalTimes)
    if not item then
        return 0
    end
    totalTimes = totalTimes or 1
    local totalPrice = 0
    for i=1,totalTimes do
        totalPrice = totalPrice + self:getPrice(item,i)
    end
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id)
    return isDiscount and math.ceil(totalPrice * discount / 1000) or totalPrice
end

--检查积分商城是否已达到最大购买次数
function ShopData:checkScoreMaxPurchaseNumber(itemId)
    require("app.cfg.shop_score_info")
    local item = shop_score_info.get(itemId)
    if item == nil then
        return true
    end
    local num_ban_type = item["num_ban_type"]
    if num_ban_type == 0 then
        return false
    end
    local vipKey = string.format("vip%s_num",G_Me.userData.vip)
   local maxNum = item[vipKey]
   local purchasedNum = self:getScorePurchaseNumById(itemId)
   if maxNum > 0 and purchasedNum >= maxNum then
       return true
   end
   return false
end

--检查积分商城是否达到购买条件
function ShopData:checkScoreBuyBanType(itemId)
    require("app.cfg.shop_score_info")
    local item = shop_score_info.get(itemId)
    if item == nil then
        return false
    end
    if item.buy_ban_type == 1 then  --竞技场达到x名可购买
        local maxRank = G_Me.arenaData:getMaxHistory()
        return item.buy_ban_value >= maxRank,G_lang:get("LANG_PURCHASE_ARENA_RANK_AVAILABLE",{rank=item.buy_ban_value})
    elseif item.buy_ban_type == 2 then --闯关到x星可购买
        local maxFloor = G_Me.wushData:getStarHis()
        return item.buy_ban_value <= maxFloor,G_lang:get("LANG_PURCHASE_TOWER_FLOOR_AVAILABLE",{star=item.buy_ban_value})
    elseif item.buy_ban_type == 4 then--军团等级达到 xx 可购买
        return item.buy_ban_value <= G_Me.legionData:getCorpLevel(),G_lang:get("LANG_PURCHASE_JUNTUAN_LEVEL_AVAILABLE",{level=item.buy_ban_value})
    elseif item.buy_ban_type == 5 then  --转盘总积分达到xxx可购买
        return item.buy_ban_value <= G_Me.wheelData.score_total,G_lang:get("LANG_PURCHASE_ZHUAN_PAN_TOTAL_SCORE_AVAILABLE",{score=item.buy_ban_value})
    elseif item.buy_ban_type == 10 then -- 激战虎牢关荣誉达到xxx可购买
        return item.buy_ban_value <= G_Me.dailyPvpData:getHonor(), G_lang:get("LANG_PURCHASE_DAILY_PVP_SCORE_AVAILABLE", {score=item.buy_ban_value})
    else --等级达到x可购买
        return item.buy_ban_value <= G_Me.userData.level,G_lang:get("LANG_PURCHASE_USER_LEVEL_AVAILABLE",{level=item.buy_ban_value})
    end
end


--[[
    param01 是否出售
    param02 是否已经结束了,决定是否添加到出售列表
            true可出售
            false不可出售
]]
function ShopData:checkItemXianShiEnabled(item)
    if not item then
        return true,false 
    end
    if item.sell_open_time > 0 then
        local cur_time = G_ServerTime:getTime()
        if item.sell_open_time > cur_time or cur_time > item.sell_close_time then
            return true,false
        end
        if item.sell_close_time == 0 or item.sell_close_time <= item.sell_open_time then 
            --[[
                结束时间配了0，返回可出售，
                但出售时间停止了，这样就不会加到出售列表里
            ]]
            return true,false
        end
        return true,true
    end
    return false
end

function ShopData:EnterScoreShop(data)
    self._hasEnterScore = true
    self._scoreDate = G_ServerTime:getDate()
    self.scorePurchaseList = {}
    if data.id == nil or #data.id == 0 then
    else 
        for i,v in ipairs(data.id) do
            self:setScorePurchaseNum(v,data.num[i])
        end
    end
end

--[[
    新手引导的时候
]]
function ShopData:isGodlyKnightDropEnabled() 
    --请求的数据还没到
    if G_Me.shopData.dropKnightInfo.jp_free_time == 0 then
        return false
    end 
    --极品
    local BagConst = require("app.const.BagConst")
    local JPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
    local JPTokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
    local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME
    if isDiscount then
        price = math.ceil(price * discount / 1000)
    end
    
    return JPLeftTime<=0 or JPTokenCount > 0 or G_Me.userData.gold >= price
end

--检查是否已经进入过vip商城
function ShopData:checkDropInfo()
    local date = G_ServerTime:getDate()
    if date ~= self._dropDate then
        --第二天了
        return false
    end
    return self._hasGetDropInfo
end

function ShopData:setDropInfo(data)
    if not data or type(data) ~= "table" then
        return
    end
    self._hasGetDropInfo = true
    self._dropDate = G_ServerTime:getDate()
    self.dropKnightInfo.lp_free_count = data.lp_free_count
    self.dropKnightInfo.lp_free_time = data.lp_free_time
    self.dropKnightInfo.jp_free_time = data.jp_free_time
    self.dropKnightInfo.jp_recruited_times = data.jp_recruited_times
    self.dropKnightInfo.zy_cycle = data.zy_cycle
    self.dropKnightInfo.zy_recruited_times = data.zy_recruited_times
end


function ShopData:setScorePurchaseNum(_id,num)
    if self.scorePurchaseList == nil then
        self.scorePurchaseList = {}
    end
    self.scorePurchaseList[_id] = num
end


--获取积分商城道具购买次数
--ID为shop_score_info中的ID,非item_info
function ShopData:getScorePurchaseNumById(_id)
    if self.scorePurchaseList == nil or self.scorePurchaseList[_id] == nil then
        return 0
    end
    return self.scorePurchaseList[_id]
end


--更新积分商城道具购买次数
function ShopData:updateScorePurchaseNumById(_id,num)
    if self.scorePurchaseList == nil then
        self.scorePurchaseList = {}
    end
    --为空表示未设置过
    if self.scorePurchaseList[_id] == nil then
        self.scorePurchaseList[_id] = num
        return 
    end 
    self.scorePurchaseList[_id] = self.scorePurchaseList[_id] + num
end

--是否必出紫将以上
--[[
    isCheng = true
    当times%10 == 0 ，isCheng = true
        表示本次必出橙
    当times%10 != 0 ，isCheng = true
        再招xxx必出橙
    当times%10 == 0 ，isCheng = false
        表示本次必出紫
    当times%10 != 0 ，isCheng = false
        再招xxx必出紫
]]
function ShopData:getDropGodlyKnightLeftTime()
    local times = self.dropKnightInfo.jp_recruited_times
    __Log("抽卡次数--> = %s",times)
    if times == 0 or times == 1 then
        -- 首抽和新手
        return 1,false
    else
        local leftTime = math.fmod(times,10)
        local isCheng = math.fmod(math.ceil((times+1)/10),2) == 1
        return 10-leftTime,isCheng
    end
end


function ShopData:getZhenYingDropKnightLeftTime()
    if not self.dropKnightInfo.zy_cycle then
        self.dropKnightInfo.zy_cycle = 0
    end
    local todayLeftSecond = G_ServerTime:getCurrentDayLeftSceonds()
    --第一天
    if math.fmod(self.dropKnightInfo.zy_cycle,2) == 0 then
        todayLeftSecond =  todayLeftSecond + 3600*24
    end
    if todayLeftSecond == 0 then
        --临界时间
        todayLeftSecond = 3600*48
        self:_zhenYingDropKnight2NextDay()
    end
    return todayLeftSecond
end

--临界时间 reset阵营抽将数据
function ShopData:_zhenYingDropKnight2NextDay()
    self.dropKnightInfo.zy_cycle = self.dropKnightInfo.zy_cycle + 1
    self.dropKnightInfo.zy_recruited_times = 15
end

--获取阵营抽将的价格 和概率
function ShopData:getZhenYingDropPrice()
    if self.dropKnightInfo.zy_recruited_times == 15 then
        --已结束
        return -1,0
    else
        require("app.cfg.camp_drop_info")
        local info = camp_drop_info.get(self.dropKnightInfo.zy_recruited_times+1)
        if not info then
            return -1,0
        end
        return info.cost,info.oran_probability
    end
end



function ShopData:setRecharge(data)
    self._monthCardDate = G_ServerTime:getDate()

    self._rechargeList = {}
    self._monthCard = {}
    if data == nil or type(data) ~= "table" or data.ret ~= 1 then
        self._monthCard = {}
        return
    end

    if data.mc ~= nil and #data.mc ~= 0 then
        for i,v in ipairs(data.mc) do
            self._monthCard[v.mc_id] = v
        end
    else
        --月卡可能是过期
        self._monthCard = {}
    end

    if data.recharge ~= nil and data.recharge.recharge_ids ~= nil and #data.recharge.recharge_ids ~= 0 then
        for i,v in ipairs(data.recharge.recharge_ids)do
            self._rechargeList[v] = v
        end
    end

    if rawget(data,"bonus") then
        self._bonus = data.bonus
    else
        self._bonus = false
    end

end


--是否首充
function ShopData:firstRecharge(_id)
    if self._rechargeList[_id] ~= nil then
        return false
    end
    return true
end

--[[
    活动内的首充,是否可领取
    false 未领取
    true 已领取
]]
function ShopData:firstRechargeForActivity()
    return self._bonus
end

function ShopData:setFirstRechargeForActivity(bonus)
    self._bonus = bonus
end

--今天是否可购买月卡
function ShopData:monthCardPurchasability(_id)
    if self._monthCard ~= nil then
        return self._monthCard[_id] == nil
    end
    return true
end

--今天是否可使用
function ShopData:useEnabled(_id)
    if self._monthCard ~= nil and self._monthCard[_id] ~= nil then
        return self._monthCard[_id].mc_use
    end
    return false
end

--剩余天数
function ShopData:getMonthCardLeftDay(_id)
    if self._monthCard ~= nil and self._monthCard[_id] then
        return self._monthCard[_id].mc_days
    end
    return 0
end

function ShopData:setMonthCardStatus(_id)
    if self._monthCard ~= nil and self._monthCard[_id] then
        self._monthCard[_id].mc_use = false
    end
end

function ShopData:isNeedRequestMonthCardData()
    local dateTime = G_ServerTime:getDate()
    if self._monthCardDate ~= nil and dateTime ~= self._monthCardDate then
        self._monthCardDate = G_ServerTime:getDate()
        return true
    else
        return false
    end
end


--获取积分商店里的数据
function ShopData:getScoreDataByType(_type)
    if not _type or type(_type) ~= "number" then
        return {}
    end
    require("app.const.ShopType")
    require("app.cfg.shop_score_info")
    local listData = {}
    local length = shop_score_info.getLength()
    for i=1,length do
        local item = shop_score_info.indexOf(i)
        --当该商品是终身限制时    
        -- if item.num_ban_type == 1  then
        --     maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(item.id)
        -- end
        if item.shop == _type then
            --[[
                item.tab == 4 || 5表示金装和红装，暂时不开放
            ]]
            if listData[item.tab] == nil and item.tab ~= self.TAB_HONGZHUANG and item.tab ~= self.TAB_JINZHUANG then
                listData[item.tab] = {}
            end

            -- 如果该商品有时间限制，则先判断是否在可买时间范围内
            local inTimeRange = true
            if item.sell_open_time > 0 and item.sell_close_time > 0 then
                local curTime = G_ServerTime:getTime()
                if curTime < item.sell_open_time or curTime > item.sell_close_time then
                    inTimeRange = false
                end
            end

            if inTimeRange then
                if item.show_ban_type == 1 then   --闯关到达xxx显示
                    --判断闯关条件
                    if item.show_ban_value <= G_Me.wushData:getStarHis() then
                        if listData[item.tab] ~= nil then
                            table.insert(listData[item.tab],item)
                        end
                    end
                elseif item.show_ban_type == 2 then  --等级到达xxx显示
                    if item.show_ban_value <= G_Me.userData.level then
                        if listData[item.tab] ~= nil then
                            table.insert(listData[item.tab],item)
                        end
                    end
                elseif item.show_ban_type == 3 then  --vip限制
                    if item.show_ban_value <= G_Me.userData.vip then
                        if listData[item.tab] ~= nil then
                            table.insert(listData[item.tab],item)
                        end
                    end
                elseif item.show_ban_type == 4 then   --军团等级限制
                    if item.show_ban_value <= G_Me.legionData:getCorpLevel() then
                        if listData[item.tab] ~= nil then
                            table.insert(listData[item.tab],item)
                        end
                    else
                    end
                elseif item.show_ban_type == 5 then  --总积分达到xxxx ,转盘积分
                    if G_Me.wheelData.score_total >= item.show_ban_value then
                        if listData[item.tab] ~= nil then
                            table.insert(listData[item.tab],item)
                        end
                    end
                end
            end
        end
    end
    local sortFunc = function(a,b) 
        local maxPurchasedA = G_Me.shopData:checkScoreMaxPurchaseNumber(a.id) and 0 or 1
        local maxPurchasedB = G_Me.shopData:checkScoreMaxPurchaseNumber(b.id) and 0 or 1
        if maxPurchasedB ~= maxPurchasedA then
            return maxPurchasedA > maxPurchasedB
        end
        return a.arrange < b.arrange
        end
    for i,v in pairs(listData) do
        table.sort( v, sortFunc)
    end 
    return listData
end

--显示奖励 的tips
function ShopData:checkAwardTipsByType(_type)
    require("app.const.ShopType")
    local listData = self:getScoreDataByType(_type)
    if listData == nil or #listData == 0 then
        return false
    end
    -- --判断条件
    if _type == SCORE_TYPE.JING_JI_CHANG then
        --最小排名 
        if listData[self.TAB_JIANGLI] == nil or #listData[self.TAB_JIANGLI] == 0 then
            return false
        end
        local history = G_Me.arenaData:getMaxHistory()
        if history == 0 then
            --没有历史排名
            return false
        end
        for i,v in ipairs(listData[self.TAB_JIANGLI]) do
            local maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(v.id)
            if v.buy_ban_value >= history and (not maxPurchased) then
                --发现符合条件的
                return true
            end
        end
        --未发现符合条件
        return false
    elseif _type == SCORE_TYPE.MO_SHEN then
        --
    elseif _type == SCORE_TYPE.DUO_BAO then
    elseif _type == SCORE_TYPE.CHUANG_GUAN then
        --最小星数
        --最大排名
        if listData[self.TAB_JIANGLI] == nil or #listData[self.TAB_JIANGLI] == 0 then
            return false
        end
        local maxHis = G_Me.wushData:getStarHis()
        if maxHis == 0 then
            ----没有星星
            return false
        end
        for i,v in ipairs(listData[self.TAB_JIANGLI]) do
            local maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(v.id)
            if v.buy_ban_value <= maxHis and (not maxPurchased) then
                --发现符合条件的
                return true
            end
        end
        --未发现符合条件
        return false
    elseif _type == SCORE_TYPE.JUN_TUAN then
        local level = G_Me.legionData:getCorpLevel()
        if level == 0 then   --没有军团或没拉取到数据
            return false
        end
        if listData[self.TAB_JIANGLI] == nil or #listData[self.TAB_JIANGLI] == 0 then
            return false
        end
        for i,v in ipairs(listData[self.TAB_JIANGLI]) do
            local maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(v.id)
            if v.buy_ban_value <= level and (not maxPurchased) then
                --发现符合条件的
                return true
            end
        end
    elseif _type == SCORE_TYPE.ZHUAN_PAN then
        local totalSocre = G_Me.wheelData.score_total
        if totalSocre == 0 then 
            return false
        end
        if listData[self.TAB_JIANGLI] == nil or #listData[self.TAB_JIANGLI] == 0 then
            return false
        end
        for i,v in ipairs(listData[self.TAB_JIANGLI]) do
            local maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(v.id)
            if v.buy_ban_value <= totalSocre and (not maxPurchased) then
                return true
            end
        end
    elseif _type == SCORE_TYPE.DAILY_PVP then
        local totalScore = G_Me.dailyPvpData:getHonor()
        if totalScore == 0 then 
            return false
        end
        if listData[self.TAB_JIANGLI] == nil or #listData[self.TAB_JIANGLI] == 0 then
            return false
        end
        for i,v in ipairs(listData[self.TAB_JIANGLI]) do
            local maxPurchased = G_Me.shopData:checkScoreMaxPurchaseNumber(v.id)
            if v.buy_ban_value <= totalScore and (not maxPurchased) then
                return true
            end
        end
    else
        assert("传入type:%s类型不对",self._type)
    end
    return false
end

------------------------------军团商店
function ShopData:setCorpShopInfo(data)
    self._corpList = {}
    self._corpIndexList = {}
    -- self.nextTimer = nil
    if data.ret == 1 then
        if self.nextTimer ~= data.next_refresh_time then
            self._junTuanClick = false
        end
        self.nextTimer = data.next_refresh_time
        for i,v in ipairs(data.item) do 
            self._corpList[#self._corpList+1] = v
            self._corpIndexList[v.id] = v
        end
    end

    local sortFunc = function(a,b)
        return a.id < b.id
    end
    table.sort(self._corpList,sortFunc)
end

function ShopData:clickJunTuan()
    self._junTuanClick = true
end

function ShopData:getJunTuanRefreshTime()
    return self.nextTimer or 0
end

function ShopData:getJunTuanHasNewData()
    local nextTime = self:getJunTuanRefreshTime()
    return G_ServerTime:getLeftSeconds(nextTime) < 0 or not self._junTuanClick
end

function ShopData:getCorpData()
    return self._corpList or {}
end

--是否进入过军团商店
function ShopData:checkEnterCorpShop()
    --[[
        --缓存机制
        if self.nextTimer == nil or type(self.nextTimer) ~= "number" then 
            return false
        end
        local curTime = G_ServerTime:getTime()

        --过时间了,需要重新刷新
        if self.nextTimer <= curTime then
            return false
        end
        return true
    ]]
    --改成每次进都刷新
    return false
end

--刷新次数
function ShopData:updateCorpItem(data)
    if data.ret == 1 then
        if rawget(data,"item") then
            for i,v in ipairs(self._corpList) do 
                if v.id == data.id then
                    local item = data.item
                    self._corpList[i] = item
                    self._corpIndexList[data.id] = item
                end
            end
        else
            local item = self._corpIndexList[data.id]
            if item then
                if item.num > 0 then
                    item.num = item.num - 1
                     --设置为已购买
                    item.bought = true
                end
            end
        end
    end
end

-- 神将商店，免费刷新次数
function ShopData:setSecretShopFreeCount(nCount)
    nCount = nCount or 0
    self._nSecretShopFreeCount = nCount
end

function ShopData:getSecretShopFreeCount()
    return self._nSecretShopFreeCount or 0
end

-- 觉醒商店，免费刷新次数
function ShopData:setAwakenShopFreeCount(nCount)
    nCount = nCount or 0
    self._nAwakenShopFreeCount = nCount
end

function ShopData:getAwakenShopFreeCount()
    return self._nAwakenShopFreeCount or 0
end

-- 战宠商店，免费刷新次数
function ShopData:setPetShopFreeCount(nCount)
    nCount = nCount or 0
    self._nPetShopFreeCount = nCount
end

function ShopData:getPetShopFreeCount()
    return self._nPetShopFreeCount or 0
end


-- 延迟缓存
function ShopData:setSecretShopPreFreeCount(nCount)
    nCount = nCount or 0
    self._nSecretShopPreFreeCount = nCount
end
function ShopData:setAwakenShopPreFreeCount(nCount)
    nCount = nCount or 0
    self._nAwakenShopPreFreeCount = nCount
end
function ShopData:setPetShopPreFreeCount(nCount)
    nCount = nCount or 0
    self._nPetShopPreFreeCount = nCount
end


-- 神将商店的免费刷新次数有没变化
function ShopData:isSecretShopFreeCountChanged()
    return self._nSecretShopFreeCount ~= self._nSecretShopPreFreeCount
end
-- 觉醒商店的免费刷新次数有没变化
function ShopData:isAwakenShopFreeCountChanged()
    return self._nAwakenShopFreeCount ~= self._nAwakenShopPreFreeCount
end
-- 战宠商店的免费刷新次数有没变化
function ShopData:isPetShopFreeCountChanged()
    return self._nPetShopFreeCount ~= self._nPetShopPreFreeCount
end

return ShopData
