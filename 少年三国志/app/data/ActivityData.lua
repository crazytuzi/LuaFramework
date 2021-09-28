local ActivityDataWine = class("ActivityDataWine")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
require("app.cfg.login_reward_info_1")
require("app.cfg.login_reward_info_2")
require("app.cfg.activity_money_info")
require("app.cfg.task_icon_info")
require("app.cfg.holiday_time_info")
require("app.cfg.spread_reward_info")
require("app.cfg.vip_daily_boon")
require("app.cfg.vip_weekshop_info")
require("app.cfg.return_level_gift_info")

--喝酒
function ActivityDataWine:ctor()
    self.state = 0  -- 1午餐前 2未吃午餐 3已吃午餐 4午餐晚餐间 5未吃晚餐 6已吃晚餐 7晚餐后
    self.next_time = 0 -- 下次对酒时间
    self.initData = {status=0, lastUpdate="", wantUpdateTime = 0 }

end

function ActivityDataWine:isActivate()
    if self.initData.status == 0 then
        return false
    end
    if self.state == 2 or self.state ==5 then
        return true
    end

    return false

end

function ActivityDataWine:needShowTip()
    return self:isActivate()
end
------------------------------

--财神
local ActivityDataCaishen= class("ActivityDataCaishen")

ActivityDataCaishen.MAX_CAISHEN_COUNT = 7
function ActivityDataCaishen:ctor()
    self.today_count = 0  --今天已祭拜次数
    self.total_count = 0  -- 总共已祭拜次数
    self.next_time = 0 --下次祭拜时间
    self.initData = {status=0, lastUpdate="" , wantUpdateTime = 0, notifyTime = 0}
end

function ActivityDataCaishen:getCaiShenRecord(  )
    local levelValue = 0
    local level = G_Me.userData.level 
    if level < 40 then 
        levelValue = 0
    elseif level < 60 then 
        levelValue = 40 
    elseif level < 80 then 
        levelValue = 60
    elseif level < 100 then
        levelValue = 80
    elseif level < 120 then
        levelValue = 100
    else
        levelValue = 120
    end
    return activity_money_info.get(levelValue, self.total_count)
end

function ActivityDataCaishen:isActivate()
    if self.initData.status == 0 then
        return false
    end
    local len = ActivityDataCaishen.MAX_CAISHEN_COUNT
    if self.total_count == len or self.total_count == len-1 then
        return false
    end
   if self.today_count < 3 then
        --倒计时到了吗
        if self.next_time <= G_ServerTime:getTime() then
            return true
        else
            return false
        end
   end
   --有可能忘记可以领取 聚宝盆了
   if self.total_count == 6 then
        return false
   end

   return false

end

--是否有奖励可以领取
function ActivityDataCaishen:hasAward()
    return self.total_count == 6
end

function ActivityDataCaishen:needShowTip()
    return self:isActivate() or self:hasAward()
end

-------------------------------

--每日签到
local ActivityDataDaily= class("ActivityDataDaily")
function ActivityDataDaily:ctor()
    self.total1 = 0
    self.last_time1 =  0
    self.vipid = 0
    self.last_time_vip = 0
    self.cost = false
    self.vip_available = false
    self.initData = {status=0, lastUpdate="", wantUpdateTime = 0}
end


function ActivityDataDaily:isActivate()
    if self.initData.status == 0 then
        return false
    end
    --判断上次领取时间是否今天
    local isBefore = G_ServerTime:isBeforeToday(self.last_time1)
    if isBefore then
        return true
    end
    return false

end

function ActivityDataDaily:isVipActivate()
    if self.initData.status == 0 then
        return false
    end
    --判断上次领取时间是否今天
    -- local isBefore = G_ServerTime:isBeforeToday(self.last_time_vip)
    local isBefore = self.vip_available
    if isBefore then
        return true
    end
    return false
end

function ActivityDataDaily:needShowTip()
    return self:isActivate() or ( self:isVipActivate() )-- and self.cost )
end

function ActivityDataDaily:getNormalDailyType()
    if self.total1 % 30 == 0 and not self:isActivate() then
        return math.floor( (self.total1 - 1) / 30 ) + 1
    else
        return math.floor( (self.total1) / 30 ) + 1
    end
end

function ActivityDataDaily:getNormalDailyDay()
    if self.total1 % 30 == 0 and not self:isActivate() then
        return 30
    else
        return (self.total1) % 30
    end
end

-------------------------------

--开服基金
local ActivityDataFund= class("ActivityDataFund")
function ActivityDataFund:ctor()

end


function ActivityDataFund:isActivate()
    return G_Me.fundData:needTips()
end

function ActivityDataFund:needShowTip()
    return self:isActivate()
end

-------------------------------

--月基金
local ActivityDataMonthFund= class("ActivityDataMonthFund")
function ActivityDataMonthFund:ctor()

end


function ActivityDataMonthFund:isActivate()
    return G_Me.monthFundData:needTips()
end

function ActivityDataMonthFund:needShowTip()
    return self:isActivate()
end


-------------------------------

--拉新玩法
local ActivityDataInvitor = class("ActivityDataInvitor")
function ActivityDataInvitor:ctor()
    self.furScore = 0 --可领取的积分
    self.totalNum = 0 --绑定的人数
    self.spreadId = nil
    -- self.awardList = {}
    self.rewardList = {}
    -- self:initAward()
    self:resetRewardList()
end

-- function ActivityDataInvitor:initAward()
--     self.awardList = {}
--     for index = 1 , spread_reward_info.getLength() do 
--         local info = spread_reward_info.indexOf(index)
--         if info.type == "1" then
--             table.insert(self.awardList,#self.awardList+1,info)
--         end
--     end
-- end

function ActivityDataInvitor:getReward(reward_id)
    for k , v in pairs(self.rewardList) do 
        if v.reward_id == reward_id then
            return v
        end
    end
    return nil
end

function ActivityDataInvitor:getOneReward(reward_id)
    local info = self:getReward(reward_id)
    if info then
        local hero = info.can_reward[1]
        table.remove(info.can_reward,1)
        table.insert(info.has_reward,#info.has_reward+1,hero)
    end
end

function ActivityDataInvitor:resetRewardList()
    self.rewardList = {}
    for index = 1 , spread_reward_info.getLength() do 
        local info = spread_reward_info.indexOf(index)
        if info.type == "1" then
            table.insert(self.rewardList,#self.rewardList+1,{reward_id=info.id,info=info,can_reward={},has_reward={}})
        end
    end
end

function ActivityDataInvitor:initData(data)
    self.furScore = data.score
    self.totalNum = data.invited_num
    self:resetRewardList()
    if rawget(data,"can_reward") then
        for k , v in pairs(data.can_reward) do 
            local info = self:getReward(v.reward_id)
            if info then
                table.insert(info.can_reward,#info.can_reward+1,v)
            end
        end
    end
    if rawget(data,"has_reward") then
        for k , v in pairs(data.has_reward) do 
            local info = self:getReward(v.reward_id)
            if info then
                table.insert(info.has_reward,#info.has_reward+1,v)
            end
        end
    end
end

function ActivityDataInvitor:drawScore()
    self.furScore = 0
end

function ActivityDataInvitor:isActivate()
    for k , v in pairs(self.rewardList) do 
        if #v.can_reward > 0 then
            return true
        end
    end
    return false
end

function ActivityDataInvitor:needShowTip()
    return self:isActivate()
end

-------------------------------

--新手礼包
local ActivityDataInvited= class("ActivityDataInvited")
function ActivityDataInvited:ctor()
    self.awardList = {}
    self.gotList = {}
    self.hasBind = false
    -- self:initAward()
    for index = 1 , spread_reward_info.getLength() do 
        local info = spread_reward_info.indexOf(index)
        if info.type == "2" then
            self.id = info.id
            self.level = info.level
        end
    end
end

function ActivityDataInvited:initAward()
    -- local sortFunc = function ( a,b )
    --     if a.type == "2" then
    --         return true
    --     end
    --     if b.type == "2" then
    --         return false
    --     end
    --     if self:hasGot(a.id) then
    --         if self:hasGot(b.id) then
    --             return a.id < b.id
    --         else
    --             return false
    --         end
    --     else
    --         if self:hasGot(b.id) then
    --             return true
    --         else
    --             return a.id < b.id
    --         end
    --     end
    -- end
    self.awardList = {}
    for index = 1 , spread_reward_info.getLength() do 
        local info = spread_reward_info.indexOf(index)
        -- if info.type == "3" then
        --     table.insert(self.awardList,#self.awardList+1,info)
        -- end
        -- if info.type == "2" and not self.hasBind then
        if info.type == "2" and ( (not self.hasBind and G_Me.userData.level <= info.level) or (self.hasBind and not self:hasGot(info.id)) ) then
            table.insert(self.awardList,1,info)
        end
    end
    -- table.sort(self.awardList, sortFunc)
end

function ActivityDataInvited:hasGot(id)
    for k , v in pairs(self.gotList) do
        if v.id == id then
            return not v.stat
        end
    end
    return false
end

function ActivityDataInvited:got(id)
    local find = false
    for k , v in pairs(self.gotList) do
        if v.id == id then
            v.stat = false
            find = true
        end
    end
    if not find then
        table.insert(self.gotList,#self.gotList+1,{id=id,stat=false})
    end
    self:initAward()
end

function ActivityDataInvited:updateBindState(bind)
    self.hasBind = bind
    self:initAward()
end

function ActivityDataInvited:shouldShow()
    local levelStat = G_Me.userData.level <= self.level
    local bindStat = (self.hasBind and not self:hasGot(self.id)) or not self.hasBind
    return levelStat and bindStat
end

function ActivityDataInvited:isActivate()
    for index = 1 , spread_reward_info.getLength() do 
        local info = spread_reward_info.indexOf(index)
        -- if info.type == "3" and G_Me.userData.level>=info.level and not self:hasGot(info.id) then
        --     return true
        -- end
        if info.type == "2" and self.hasBind and not self:hasGot(info.id) then
            return true
        end
    end
    return false
end

function ActivityDataInvited:needShowTip()
    return self:isActivate()
end

-------------------------------

--手机绑定
local ActivityDataPhone = class("ActivityDataPhone")
function ActivityDataPhone:ctor()
    self.notice = ""
    self.count = 0
    self.state = false --是否已领取
end

function ActivityDataPhone:setNotice(str)
    self.notice = str
end

function ActivityDataPhone:setState(state)
    self.state = state == 2
end

function ActivityDataPhone:countMM()
    self.count = self.count - 1
end

function ActivityDataPhone:isActivate()
    return not self.state
end

function ActivityDataPhone:needShowTip()
    return self:isActivate()
end

-------------------------------

--充值返还
local ActivityDataFanhuan = class("ActivityDataFanhuan")
function ActivityDataFanhuan:ctor()
    self._has_recharge = true
    self._money = 0
    self._gold = 0
    self._vip_exp = 0
end


function ActivityDataFanhuan:isActivate()
    return self._has_recharge
end

function ActivityDataFanhuan:init(data)
    if data then
        self._has_recharge = data.has_recharge
        if rawget(data, "money") then
            self._money = data.money
        end
        if rawget(data, "gold") then
            self._gold = data.gold
        end
        if rawget(data, "vip_exp") then
            self._vip_exp = data.vip_exp
        end
    end
end

function ActivityDataFanhuan:setHas(data)
    self._has_recharge = data.has_recharge
end

function ActivityDataFanhuan:needShowTip()
    return self:isActivate()
end

-------------------------------


--vip周礼包
local ActivityDataVipDiscount = class("ActivityDataVipDiscount")
function ActivityDataVipDiscount:ctor()
    self.idList = {}
    self.buyId = 0
    self.curLevel = -1
    self.lastLevel = -1
    self.shopId = {}
end

function ActivityDataVipDiscount:initDaily(data)
    if rawget(data,"id") then
        self.curLevel = data.id 
    else
        self.curLevel = -1
    end
end

function ActivityDataVipDiscount:getDailyData(level)
    return vip_daily_boon.get(level+1)
end

function ActivityDataVipDiscount:getDaily()
    self.lastLevel = self.curLevel
    if self.curLevel == G_Me.userData.vip then
        self.curLevel = -1
    else
        self.curLevel = self.curLevel + 1
    end
end

function ActivityDataVipDiscount:isActivate()
    return (G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_LIBAO) and #self.shopId < 1) or self.curLevel ~= -1
end

function ActivityDataVipDiscount:hasToBuy()
    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_LIBAO) and #self.shopId < 1
end

function ActivityDataVipDiscount:hasToGet()
    return self.curLevel ~= -1
end

function ActivityDataVipDiscount:init(data)
    if rawget(data,"id") then
        self.idList = data.id
    else
        self.idList = {}
    end
end

function ActivityDataVipDiscount:getBuyState(id)
    -- dump(self.idList)
    for k , v in pairs(self.idList) do 
        if v == id then
            return true
        end
    end
    return false
end

function ActivityDataVipDiscount:buySuccess()
    if self.buyId > 0 then
        table.insert(self.idList,#self.idList+1,self.buyId)
        -- self.buyId = 0
    end
end

function ActivityDataVipDiscount:needShowTip()
    return self:isActivate()
end

function ActivityDataVipDiscount:getShopList()
    local data = {}
    for i = 1 , vip_weekshop_info.getLength() do 
        local info = vip_weekshop_info.indexOf(i)
        if G_Me.userData.level >= info.level_min and G_Me.userData.level <= info.level_max and G_Me.userData.vip >= info.vip_level_min and G_Me.userData.vip <= info.vip_level_max then
            table.insert(data,#data+1,info)
        end
    end
    return data
end

function ActivityDataVipDiscount:initShopInfo(data)
    self.shopId = {}
    if rawget(data,"id") then
        for k , v in pairs(data.id) do  
            table.insert(self.shopId,#self.shopId+1,{id=v,count=data.num[k]})  
        end
    end
end

function ActivityDataVipDiscount:getShopInfo(id)
    for k , v in pairs(self.shopId) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function ActivityDataVipDiscount:getShopCount(id)
    local info = self:getShopInfo(id)
    if info then
        return info.count
    end
    return 0
end

function ActivityDataVipDiscount:updateShopInfo(id)
    local info = self:getShopInfo(id)
    if info then
        info.count = info.count+1
    else
        table.insert(self.shopId,#self.shopId+1,{id=id,count=1})
    end
end

-- function ActivityDataVipDiscount:getShopInfoCount()
--     local info = self:getShopInfo()
--     for i = 1 , 4 do 
--         if info["bag_"..i.."_item_1_type"] == 0 then
--             return i - 1 
--         end
--     end
--     return 4
-- end

-------------------------------


---圣诞活动data

local ActivityHolidayData = class("ActivityHolidayData")

function ActivityHolidayData:ctor()
    self.isInit = false
    self.exchangeList = {}   -- key为id,num为已购买次数
    self.date = nil

end

function ActivityHolidayData:isInit()
    local date = G_ServerTime:getDate()
    if self.date == nil or self.date ~= date then
        return false
    end
    return self.isInit
end

--活动是否有效
function ActivityHolidayData:isActivate()
    --圣诞活动
    local holiday = holiday_time_info.indexOf(1)
    if self:checkHolidayActivate(holiday.id) then   --未过期才加入列表
        return true
    end
    return false
end

function ActivityHolidayData:setExchangeList(data)
    if not data and data.ret ~= 1 then
        self.isInit = false
        self.exchangeList = {}
        self.date = nil
    end
    self.isInit = true
    self.date = G_ServerTime:getDate()
    self.exchangeList = {}
    for i,v in ipairs(data.award) do 
        self.exchangeList[v.id] = v.num
    end
end

--[[
    检查活动是否过期
    true 过期
    false 未过期
]]

function ActivityHolidayData:checkHolidayActivate(id)
    if not id then
        return false
    end
    local holiday = holiday_time_info.get(id)
    if not holiday then
        return false
    end
    local leftSecond = G_ServerTime:getLeftSeconds(holiday.end_time)
    if leftSecond > 0 and holiday.start_time <= G_ServerTime:getTime() then
        return true
    else
        return false
    end
end

function ActivityHolidayData:setExchangeListNumById(id,num)
    if not id or type(id) ~= "number" then
        return
    end
    num = num or 0
    self.exchangeList[id] = num
end

--获取已经兑换次数
function ActivityHolidayData:getExchangeTimesById(id)
    if not id or type(id) ~= "number" then
        return -1
    end
    return self.exchangeList[id] or 0
end

function ActivityHolidayData:needShowTip(id)
    return self:isActivate()
end


-------------------------------


-- 分享
local ActivityShareData = class("ActivityShareData")

function ActivityShareData:set(data)
    self._data = data
end

function ActivityShareData:isActivate()
    if self._data then
        for i=1, #self._data do
            local data = self._data[i]
            if data.step == 1 then
                return true
            end
        end
    end
end

function ActivityShareData:needShowTip(id)
    return self:isActivate()
end


-------------------------------

-- 老玩家回归
local ActivityDataUserReturn = class("ActivityDataUserReturn")

require("app.cfg.vip_level_info")
local MIN_VIP_LEVEL = 3

function ActivityDataUserReturn:ctor()
    self._isOldUser     = true  -- 是否满足老玩家条件
    self._activityId    = 1     -- 活动ID
    self._activityStart = 0     -- 活动开始时间
    self._activityEnd   = 0     -- 活动结束时间
    self._loginLimitTime= 0     -- 最晚登陆限制时间
    self._limitLevel    = 0     -- 等级限制
    self._hasGotVip     = false -- 是否已领取VIP经验
    self._gotGiftList   = {}    -- 领取过的礼包列表

    self._vipExp        = 0
    self._vipLevel      = 0
end

function ActivityDataUserReturn:init(data)
    self._isOldUser = rawget(data, "is_older")
    self._activityId = rawget(data, "activity_id") or 1
    self._activityStart = rawget(data, "activity_start") or 0
    self._activityEnd = rawget(data, "activity_end") or 0
    self._loginLimitTime = rawget(data, "limit_time") or 0
    self._limitLevel = rawget(data, "limit_level") or 0
    self._hasGotVip = rawget(data, "vip")

    if rawget(data, "awards") then
        for i, v in ipairs(data.awards) do
            self._gotGiftList[#self._gotGiftList + 1] = v
        end
    end
end

function ActivityDataUserReturn:setVipExp(exp)
    self._vipExp = exp or 0
    
    local len = vip_level_info.getLength()
    local isSet = false
    for i = 0, len - 1 do
        local vipInfo = vip_level_info.get(i)
        if self._vipExp < vipInfo.low_value then
            self._vipLevel = vip_level_info.get(i - 1).level
            isSet = true
            break
        end
    end

    if not isSet then
        self._vipLevel = len - 1
    end

    if self._vipLevel < MIN_VIP_LEVEL then
        self._vipLevel = MIN_VIP_LEVEL
        self._vipExp = vip_level_info.get(MIN_VIP_LEVEL).low_value
    end
end

function ActivityDataUserReturn:setHasGotVipExp()
    self._hasGotVip = true
end

function ActivityDataUserReturn:setHasGotGift(giftId)
    self._gotGiftList[#self._gotGiftList + 1] = giftId
end

function ActivityDataUserReturn:isOldUser()
    return self._isOldUser
end

function ActivityDataUserReturn:getVipExpAndLevel()
    return self._vipExp, self._vipLevel
end

function ActivityDataUserReturn:getActivityTime()
    return self._activityStart, self._activityEnd
end

function ActivityDataUserReturn:getLoginLimitTime()
    return self._loginLimitTime
end

function ActivityDataUserReturn:hasGotGift(giftId)
    for i, v in ipairs(self._gotGiftList) do
        if v == giftId then
            return true
        end
    end

    return false
end

-- 是否需要显示玩家回归的活动入口
function ActivityDataUserReturn:needShowEntrance()
    return self._isOldUser and not self:isAllAwardsGot()
end

-- 是否有vip经验可领
function ActivityDataUserReturn:canGetVipExp()
    return not self._hasGotVip
end

-- 是否有礼包奖励可领
function ActivityDataUserReturn:canGetGift()
    local giftLen = return_level_gift_info.getLength()

    for i = 1, giftLen do
        local got = false
        for k, v in pairs(self._gotGiftList) do
            if i == v then
                got = true
                break
            end
        end

        if not got then
            local levelRequest = return_level_gift_info.get(i).level
            if G_Me.userData.level >= levelRequest then
                return true
            end
        end
    end

    return false
end

-- 是否所有东西都领完了（vip&礼包）
function ActivityDataUserReturn:isAllAwardsGot()
    local giftLen = return_level_gift_info.getLength()
    return not self:canGetVipExp() and #self._gotGiftList == giftLen
end

---------------------------------

-- 开服7日战力榜
local SevenDayFightValueRank = class("SevenDayFightValueRank")

require ("app.cfg.days7_competition_info")

function SevenDayFightValueRank:ctor( ... )
    self._awardPreviewData = {}
    self:_initAwardPreviewData()

    -- 战力排行榜信息
    self._compRankInfoList = nil
    -- 我的战力排行信息
    self._myCompInfo = nil
    -- 我的奖品
    self._myAward = nil
    -- 我是否已经领过奖励（1 尚未领取，0 已领取）
    self._myAwardFlag = 1
    -- 当前服务器的开服时间
    self._serverOpenTime = 0
    -- 该活动是否被后台配置为关闭（判断就不仅以时间为准了，需要配置和时间同时成立）
    self._isClosedByServer = false
end

function SevenDayFightValueRank:_initAwardPreviewData(  )
    for i=1, days7_competition_info.getLength() do
        local awardInfo = days7_competition_info.indexOf(i)
        table.insert(self._awardPreviewData, awardInfo)
    end
end

function SevenDayFightValueRank:setServerOpenTime( openTime )
    self._serverOpenTime = openTime
end

function SevenDayFightValueRank:getServerOpenTime(  )
    return self._serverOpenTime
end

-- 领奖结束时间
function SevenDayFightValueRank:getAwardCloseTime(  )
    return self._serverOpenTime + 7*24*60*60 * 2
end

-- 排名竞争结束时间
function SevenDayFightValueRank:getCompEndTime( ... )
    return self._serverOpenTime + 7*24*60*60
end

function SevenDayFightValueRank:getAwardPreviewData(  )
    return self._awardPreviewData
end

function SevenDayFightValueRank:setCompRankInfo( compRankList )
    self._compRankInfoList = compRankList

    local sortFunc = function ( a, b )
        if a.rank and b.rank then
            return a.rank < b.rank
        else
            return false
        end
    end

    table.sort(self._compRankInfoList, sortFunc)
end

function SevenDayFightValueRank:setMyCompInfo( myCompInfo )
    self._myCompInfo = myCompInfo
    self._myAwardFlag = myCompInfo.flag
end

function SevenDayFightValueRank:getCompRankInfo(  )
    return self._compRankInfoList
end

function SevenDayFightValueRank:getMyCompInfo(  )
    return self._myCompInfo
end

-- 根据我的排名到表里去读取对应的奖励
function SevenDayFightValueRank:getMyAwards(  )
    local lastAwardInfo = days7_competition_info.indexOf(days7_competition_info.getLength())
    local lastRank = lastAwardInfo.bottom_rank
    if self._myCompInfo then
        local myRank = self._myCompInfo.rank
        if myRank <= lastRank then
            for i=1, days7_competition_info.getLength() do
                local awardInfo = days7_competition_info.indexOf(i)
                if myRank >= awardInfo.top_rank and myRank <= awardInfo.bottom_rank then
                    self._myAward = awardInfo
                    break
                end
            end
        end
    end
    return self._myAward
end

function SevenDayFightValueRank:setMyAwardsFlag( flag )
    self._myAwardFlag = flag
end

function SevenDayFightValueRank:getMyAwardsFlag(  )
    return self._myAwardFlag
end

function SevenDayFightValueRank:needShowTip(  )
    return true
end

function SevenDayFightValueRank:setClosedByServer(  )
    self._isClosedByServer = true
end

function SevenDayFightValueRank:needShowEntrance(  )

    if self._isClosedByServer then
        return false
    end

    local compLeftSecond = G_ServerTime:getLeftSeconds(self:getCompEndTime())
    __Log("compLeftSecond: " .. compLeftSecond)
    if compLeftSecond > 0 then
        return true
    end

    local awardLeftTime = G_ServerTime:getLeftSeconds(self:getAwardCloseTime())
    __Log("awardLeftSecond: " .. awardLeftTime)
    if awardLeftTime > 0 and self._myAwardFlag == 1 and self._myCompInfo then
        return true
    end

    return false
end

---------------------------------------
-- 招财符
local ActivityDataFortune = class("ActivityDataFortune")


function ActivityDataFortune:ctor( ... )
    -- 当日已经发生的招财次数
    self._times = 0
    -- 当日累计招财获得的银两数
    self._totalMoney = 0
    -- 宝箱状态
    self._boxStatus = {false, false, false}
    -- 明细记录
    self._fortuneDetailInfo = {}
end

function ActivityDataFortune:needShowEntrance(  )
    return G_moduleUnlock:isModuleUnlock(FunctionLevelConst.FORTUNE)
end

-- 是否需要在首页活动按钮上显示红点
function ActivityDataFortune:needShowOutsideTips(  )
    return self:needShowEntrance() and self._times == 0
end

function ActivityDataFortune:needShowTip(  )
    -- 次数VIP类型
    local vipType = require("app.const.VipConst").FORTUNE
    local totalCanBuy = G_Me.vipData:getData(vipType).value
    local hasBuyTimes = totalCanBuy > self._times

    -- 是否有宝箱没领
    local hasBoxAward = false
    if (self._times >= 10 and not self._boxStatus[1])
        or (self._times >= 20 and not self._boxStatus[2])
        or (self._times >= 30 and not self._boxStatus[3]) then
        hasBoxAward = true
    end

    return hasBuyTimes or hasBoxAward
end

function ActivityDataFortune:setTimes( times )
    self._times = times
end

function ActivityDataFortune:getTimes(  )
    return self._times
end

function ActivityDataFortune:setBoxStatus( boxStatus )
    self._boxStatus = {false, false, false}
    for i=1, #boxStatus do
        self._boxStatus[boxStatus[i]] = true
    end
end

function ActivityDataFortune:updateBoxStatus( boxStatus )
    for i=1, #boxStatus do
        self._boxStatus[boxStatus[i]] = true
    end
end

function ActivityDataFortune:getBoxStatus(  )
    return self._boxStatus
end

function ActivityDataFortune:setFortuneDetailInfo( buyDetailInfo )
    -- dump(buyDetailInfo[#buyDetailInfo])
    -- __Log("=============[ActivityDataFortune:setFortuneDetailInfo]==============")
    self._fortuneDetailInfo = buyDetailInfo
    -- dump(self._fortuneDetailInfo[#self._fortuneDetailInfo])
end

function ActivityDataFortune:updateFortuneDetailInfo( buyInfo )
    table.insert(self._fortuneDetailInfo, buyInfo)
end

function ActivityDataFortune:getFortuneDetailInfo(  )
    return self._fortuneDetailInfo
end

function ActivityDataFortune:getTotalMoney(  )
    return self._totalMoney
end

-- 每次招财成功后更新，加上本次的数量
function ActivityDataFortune:updateTotalMoney( increaseNum )
    self._totalMoney = self._totalMoney + increaseNum
end

-- 拉取招财协议时更新，需清除原有的数量
function ActivityDataFortune:setTotalMoney( data )
    -- __Log("===========[ActivityDataFortune:setTotalMoney]============")
    self._totalMoney = 0

    for i=1, #data do
        self._totalMoney = self._totalMoney + data[i].silver
    end
end

-----------------------------------

local ActivityData =  class("ActivityData")

--由于活动数据有很多是跟时间有关的,所以活动的数据状态最好是全局维护, 加入到GameService里去做


function ActivityData:ctor()
    self.giftcode = nil
    self.caishen = ActivityDataCaishen.new()
    self.daily = ActivityDataDaily.new()
    self.fund = ActivityDataFund.new()
    self.monthFund = ActivityDataMonthFund.new()
    self.wine = ActivityDataWine.new()
    self.phone = ActivityDataPhone.new()
    self.fanhuan = ActivityDataFanhuan.new()
    self.vipDiscount = ActivityDataVipDiscount.new()
    self.invitor = ActivityDataInvitor.new()
    self.invited = ActivityDataInvited.new()
    self.custom = require("app.scenes.activity.gm.ActivityDataCustom").new()   --可配置活动
    self.holiday = ActivityHolidayData.new() --圣诞节活动
    self.share = ActivityShareData.new()    -- 分享数据
    self.userReturn = ActivityDataUserReturn.new()
    self.sevenDayFightValueRank = SevenDayFightValueRank.new()
    self.fortune = ActivityDataFortune.new()
    self._typeList = nil
end

--获得活动类型列表
--每日签到 > 首充礼包 > 月卡 > 迎财神 > 铜雀台 > 开服基金 > 礼品码
function ActivityData:getTypeList()
    self._typeList = {}

    -- TODO:开服战力榜 temp
    if self.sevenDayFightValueRank:needShowEntrance() then
        table.insert(self._typeList,{
            id="fightvaluerank",
            imageUrl = "ui/dungeon/xingshupaihang.png",
            titleUrl = G_lang:get("LANG_ACTIVITY_FIGHT_VALUE_RANK"),
            data = self.sevenDayFightValueRank,
            needShowTip = function()
                return self.sevenDayFightValueRank and self.sevenDayFightValueRank:needShowTip()
            end
        })
    end

    --每日
    table.insert(self._typeList,{
        id="daily",
        imageUrl = "ui/activity/icon_meiriqiandao.png",
        titleUrl = G_lang:get("LANG_ACTIVITY_MEI_RI_QIAN_DAO"),
        data = self.daily,
        needShowTip = function()
            return self.daily and self.daily:needShowTip()
        end
    })

    -- if G_Setting:get("open_activity_recharge") == "1" then
    --   table.insert(self._typeList,{
    --     id="activity_recharge",
    --     imageUrl = "ui/activity/icon_chongzhisonghuafei.png",
    --     titleUrl = require("app.scenes.activity.ActivityPageRecharge").iconTitle or "",
    --     data = nil,
    --     needShowTip = nil
    --     })
    -- end
    --[[
        --圣诞活动  去掉圣诞活动
        local holiday = holiday_time_info.indexOf(1)
        if holiday and self.holiday:checkHolidayActivate(holiday.id) then   --未过期才加入列表
            table.insert(self._typeList,{
                id="holiday",
                imageUrl = G_Path.getActivityIcon(1031),
                titleUrl = G_lang:get("LANG_ACTIVITY_HOLIDAY"),
                data = holiday
            })
        end
    ]]

    --可配置活动
    --[[
        接收可配置活动信息 
        1，推进
        2，限时
        3，限时贩售&物品兑换
        4，累冲/单冲
    ]]

    if self.custom and table.nums(self.custom.customList) then

        local iconUrlDefault = "icon/activity/1020.png"
        

        for i,v in pairs(self.custom.customList) do

            --等级和VIP等级解锁了才可能显示活动或者活动预览
            if v.act and self.custom:checkActUnlock(v.act) then
        
                --（预览期或者活动开启才添加）
                if (self.custom:checkPreviewByActId(v.act.act_id) or self.custom:checkActAward(v.act.act_id)) then 
                   
                    local iconUrl = nil
                    
                    if  v.act.icon_type and v.act.icon_type ~= 0 then
                        local good = G_Goods.convert(v.act.icon_type, v.act.icon_value)
                        iconUrl = good and good.icon or iconUrlDefault
                    elseif v.act.icon_value and v.act.icon_value ~= 0 then
                        iconUrl = G_Path.getActivityIcon(v.act.icon_value)
                    else
                        iconUrl = iconUrlDefault
                    end


                    if v.act.act_type == 1 then
                        table.insert(self._typeList,{
                                id = "lingqu" .. v.act.act_id,
                                -- imageUrl = "ui/activity/icon_hejiu.png",
                                imageUrl = iconUrl,
                                titleUrl = v.act.sub_title,
                                data = v.act,
                                needShowTip = function()
                                    return self.custom:showTipsByActId(v.act.act_id)
                                end   
                            })
                    elseif v.act.act_type == 2 then
                        table.insert(self._typeList,{
                                id = "xianshi" .. v.act.act_id,
                                -- imageUrl = "ui/activity/icon_hejiu.png",
                                imageUrl = iconUrl,
                                titleUrl = v.act.sub_title,
                                data = v.act,
                                needShowTip = function()
                                    return self.custom:showTipsByActId(v.act.act_id)
                                end  
                            })
                    elseif v.act.act_type == 3 then
                        table.insert(self._typeList,{
                                id = "wupinduihuan" .. v.act.act_id,
                                -- imageUrl = "ui/activity/icon_hejiu.png",
                                imageUrl = iconUrl,
                                titleUrl = v.act.sub_title,
                                data = v.act,
                                needShowTip = function()
                                    return self.custom:showTipsByActId(v.act.act_id)
                                end  
                            })
                    else
                        table.insert(self._typeList,{
                                id = "chongzhi" .. v.act.act_id,
                                -- imageUrl = "ui/activity/icon_hejiu.png",
                                imageUrl = iconUrl,
                                titleUrl = v.act.sub_title,
                                data = v.act,
                                needShowTip = function()
                                    return v.act and self.custom:showTipsByActId(v.act.act_id)
                                end  
                            })
                    end
                end
            end
        end
    end

    -- 招财符
    if self.fortune:needShowEntrance() then
        table.insert(self._typeList, {
            id = "daily_fortune",
            imageUrl = "ui/activity/icon_zhaocaifu.png",
            titleUrl = G_lang:get("LANG_ACTIVITY_DAILY_FORTUNE"),
            needShowTip = function()
                return self.fortune:needShowTip()    
            end
        })
    end

    -- 首冲
    if G_Setting:get("open_recharge") == "1" then
        if G_Me.vipData:getExp() == 0 or (not G_Me.shopData:firstRechargeForActivity()) then
            --未充值或者未领取奖励
            table.insert(self._typeList,{
                    id = "shou_chong",
                    imageUrl = "ui/activity/icon_shouchonglibao.png",
                    titleUrl = G_lang:get("LANG_ACTIVITY_SHOU_CHONG_LI_BAO"),
                    data = nil,
                    needShowTip = function()
                        --充值了但是未领取
                        return  G_Me.vipData:getExp() > 0 and not G_Me.shopData:firstRechargeForActivity() 
                    end  
                })
        end
    end

    --月卡
    if G_Setting:get("open_recharge") == "1" then
        table.insert(self._typeList,{
                id = "month_card",
                imageUrl = "ui/activity/icon_yueka.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_YUE_KA"),
                data = nil,
                needShowTip = function()
                    return G_Me.shopData:useEnabled(1) or G_Me.shopData:useEnabled(2) 
                end  
            })
    end

    --vip周礼包
    if G_Setting:get("open_vipDiscount") == "1" then
        table.insert(self._typeList,{
                id = "vipDiscount",
                imageUrl = "ui/activity/icon_fenxiang.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_VIPDISCOUNT"),
                data = self.vipDiscount,

                needShowTip = function()
                    return self.vipDiscount and self.vipDiscount:needShowTip()
                end

            })
    end


    --财神
    table.insert(self._typeList,{
        id="caishen",
        imageUrl = "ui/activity/icon_baiguangong.png",
        titleUrl = G_lang:get("LANG_ACTIVITY_YING_CAI_SHEN"),
        data = self.caishen,
        needShowTip = function()
            return self.caishen and self.caishen:needShowTip()    
        end
    })

    --对酒开放
    if G_Setting:get("open_wine") == "1" then
        table.insert(self._typeList,{
                id = "wine",
                imageUrl = "ui/activity/icon_hejiu.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_TONG_QUE_TAI"),
                data = self.wine,
                needShowTip = function()
                    return self.wine and self.wine:needShowTip()    
                end
            })
    end

    --开服基金
    if G_Setting:get("open_fund") == "1" and not G_Me.fundData:emptyAward() then
        table.insert(self._typeList,{
                id = "fund",
                imageUrl = "ui/activity/icon_kaifujiin.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_KAI_FU_JI_JIN"),
                data = self.fund,
                needShowTip = function()
                    return self.fund and self.fund:needShowTip()    
                end
            })
    end

    --老玩家回归
    if self.userReturn:needShowEntrance() then
        table.insert(self._typeList,{
                id = "userReturn",
                imageUrl = "ui/activity/icon_vipbox.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_USER_RETURN"),
                data = self.userReturn,
                needShowTip = function()
                    return self.userReturn and (self.userReturn:canGetVipExp() or 
                                                self.userReturn:canGetGift())
                end
            })
    end

    --月基金
    --if G_Setting:get("open_monthfund") == "1" and G_Me.monthFundData:dataReady() then
    if G_Me.monthFundData:dataReady() then
        table.insert(self._typeList,{
                id = "monthfund",
                imageUrl = "ui/activity/icon_yuejiin.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_MONTH_JI_JIN"),
                data = self.monthFund,
                needShowTip = function()
                    return self.monthFund and self.monthFund:needShowTip()    
                end
            })
    end


    if G_Setting:get("open_invitor") == "1" then
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.INVITOR) then 
            table.insert(self._typeList,{
                    id = "invitor",
                    imageUrl = "ui/activity/icon_tuiguangfuli.png",
                    titleUrl = G_lang:get("LANG_ACTIVITY_INVITOR"),
                    data = self.invitor,
                    needShowTip = function()
                        return self.invitor and self.invitor:needShowTip()    
                    end
                })
        end
        if self.invited:shouldShow() then
            table.insert(self._typeList,{
                    id = "invited",
                    imageUrl = "ui/activity/icon_fenxiang.png",
                    titleUrl = G_lang:get("LANG_ACTIVITY_INVITED"),
                    data = self.invited,
                    
                    needShowTip = function()
                        return self.invited and self.invited:needShowTip()    
                    end

                })
        end
    end
	
	-- 分享开放
    if G_ShareService:canShare() then
         table.insert(self._typeList,{
                id = "share",
                imageUrl = "ui/activity/icon_fenxiang.png",
                titleUrl = G_lang:get("LANG_ACTIVITY_SHARE"),
                data = self.share,
                needShowTip = function()
                     return self.share and self.share:needShowTip()    
                end
        })
    end
	
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    --礼品码开放
    if G_Setting:get("open_giftcode") == "1" then
        if not appstoreVersion then    
            table.insert(self._typeList,{
                    id = "giftcode",
                    imageUrl = "ui/activity/icon_lipinma.png",
                    titleUrl = G_lang:get("LANG_ACTIVITY_LI_PIN_MA"),
                    data = nil,
                    needShowTip = nil
               })
        end
    end

    -- --手机绑定
    if G_Setting:get("open_phone") == "1" then
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.PHONE_BIND) and not self.phone.state and not appstoreVersion then
            table.insert(self._typeList,{
                    id = "phone",
                    imageUrl = "ui/activity/icon_shoujibangding.png",
                    titleUrl = G_lang:get("LANG_ACTIVITY_PHONE"),
                    data = self.phone,
                    needShowTip = function()
                         return self.phone and self.phone:needShowTip()    
                    end
                })
        end
    end

    -- 双12活动
    if G_Setting:get("open_taobao_gift") == "1" then
        require("app.cfg.holiday_time_taobao_info")
        local tTmpl = holiday_time_taobao_info.get(1)
        local nCurTime = G_ServerTime:getTime()
        if nCurTime >= tTmpl.start_time and nCurTime <= tTmpl.end_time then
            if G_NativeProxy.platform == "ios" then
                table.insert(self._typeList,{
                        id = "taobao_gift",
                        imageUrl = "ui/activity/icon_taobaosongli.png",
                        titleUrl = G_lang:get("LANG_ACTIVITY_TAOBAO_GIFT"),
                        data = nil,
                        needShowTip = function()
                            return true 
                        end
                    })
            elseif G_NativeProxy.platform == "android" and GAME_VERSION_NO >= 10700 then
                table.insert(self._typeList,{
                        id = "taobao_gift",
                        imageUrl = "ui/activity/icon_taobaosongli.png",
                        titleUrl = G_lang:get("LANG_ACTIVITY_TAOBAO_GIFT"),
                        data = nil,
                        needShowTip = function()
                            return true 
                        end
                    })
            end
        end
    end

    -- --充值返还
    -- if G_Setting:get("open_fanhuan") == "1" and self.fanhuan._has_recharge then
    -- -- if G_Setting:get("open_fanhuan") == "1" then
    --     table.insert(self._typeList,{
    --             id = "fanhuan",
    --             imageUrl = "ui/activity/icon_chongzhikuizeng.png",
    --             titleUrl = G_lang:get("LANG_ACTIVITY_FANHUAN"),
    --             data = self.fanhuan,
    --             needShowTip = function()
    --                  return self.fanhuan and self.fanhuan:needShowTip()    
    --             end
    --         })
    -- end

    self:_resortTypeList()

    return self._typeList
end

--对所有活动进行排序，有红点提示的优先显示，其他按照原有活动类型优先级显示
function ActivityData:_resortTypeList( )
    
    local tempTypeList = {}

    --拷贝一份 
    for k, v in pairs(self._typeList) do
        table.insert(tempTypeList, v)
    end

    --清空self._typeList
    self._typeList = {}

    --先插入有红点提示的
    for k, v in pairs(tempTypeList) do
        if v.needShowTip and v.needShowTip() then
            table.insert(self._typeList, v)
        end
    end

    --后插入没有红点提示的
    for k, v in pairs(tempTypeList) do
        if  not v.needShowTip or not v.needShowTip() then
            table.insert(self._typeList, v)
        end
    end

end

--是否有活动等着去参加
function ActivityData:hasActivityToJoin()
    --财神  
    if not self then
        return false
    end

    if self.caishen and self.caishen:needShowTip() then
        return true
    end

    --喝酒
    if self.wine and self.wine:needShowTip() then
        return true
    end

    --每日
    if self.daily and self.daily:needShowTip() then
        return true
    end

    --vip福利
    if self.vipDiscount and self.vipDiscount:needShowTip() then
        return true
    end

    --推广
    if G_Setting:get("open_invitor") == "1" then

        if self.invitor and self.invitor:needShowTip() then
            return true
        end

        if self.invited and self.invited:needShowTip() then
           return true
        end
    end

    --基金
    if self.fund and self.fund:needShowTip() then
        return true
    end

    --月基金
    if self.monthFund and self.monthFund:needShowTip() then
        return true
    end

    if G_Setting:get("open_recharge") == "1" then
        --月卡
        if G_Me.shopData:useEnabled(1) or G_Me.shopData:useEnabled(2) then
            return true 
        end

        --充值了但是未领取
        if G_Me.vipData:getExp() > 0 and not G_Me.shopData:firstRechargeForActivity() then
            return true
        end
    end

    --可配置活动,琴总说不要了
    -- if self.custom.customList and table.nums(self.custom.customList) then
    --     for i,item in pairs(self.custom.customList) do
    --         local act = item.act
    --         if act then
    --             if self.custom:showTipsByActId(act.act_id) then
    --                 return true
    --             end
    --         end
    --     end
    -- end

    if G_Setting:get("open_fanhuan") == "1" and self.fanhuan and self.fanhuan:needShowTip() then
        return true
    end

    if G_Setting:get("open_phone") == "1" and self.phone and self.phone:needShowTip() then
        return true
    end

    if self.fortune and self.fortune:needShowOutsideTips() then
        return true
    end
    
    -- 分享数据
    if G_ShareService:canShare() and self.share and self.share:needShowTip() then
        return true
    end
    
    return false
end


--获取开服活动的index
function ActivityData:getFundIndex()
    local list = self:getTypeList()
    if list == nil or #list == 0 then
        return 1
    end
    for i,v in ipairs(list)do
        if v.id == "fund" then
            return i
        end
    end
    return 1
end

function ActivityData:getInvitorIndex()
    local list = self:getTypeList()
    if list == nil or #list == 0 then
        return 1
    end
    for i,v in ipairs(list)do
        if v.id == "invitor" then
            return i
        end
    end
    return 1
end

function ActivityData:getFortuneIndex()
    local list = self:getTypeList()
    if list == nil or #list == 0 then
        return 1
    end
    for i,v in ipairs(list)do
        if v.id == "daily_fortune" then
            return i
        end
    end
    return 1
end

--活动是否为GM可配置活动 add by kaka
function ActivityData:isGmActivity(activity)
     
    if not self or not self.custom or table.nums(self.custom.customList) == 0 or not activity then
        return false
    end

    return (string.match(activity.id,"lingqu") or 
        string.match(activity.id,"xianshi") or 
        string.match(activity.id,"wupinduihuan") or 
        string.match(activity.id,"chongzhi"))
end

return ActivityData
