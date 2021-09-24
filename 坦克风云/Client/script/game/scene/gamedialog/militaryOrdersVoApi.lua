militaryOrdersVoApi = {}

function militaryOrdersVoApi:getCfg()
    if self.ltmover ~= self.mover then --如果需要替换版本的话就先清一下原先的配置缓存
        package.loaded["luascript/script/config/gameconfig/militaryOrderCfg"] = nil
        package.loaded["luascript/script/config/gameconfig/militaryOrderCfg1"] = nil
    end
    self.ltmover = self.mover
    if self.mover == 2 then --版本为2时加载militaryOrderCfg1
        return G_requireLua("config/gameconfig/militaryOrderCfg1")
    else
        return G_requireLua("config/gameconfig/militaryOrderCfg")
    end
end

function militaryOrdersVoApi:isOpen()
    if base.militaryOrders == 1 and playerVoApi:getPlayerLevel() >= self:getCfg().openLv then
        return true
    end
    return false
end

function militaryOrdersVoApi:getEndTime()
    -- local year, month = os.date("%Y", base.serverTime), os.date("%m", base.serverTime)
    -- --通过os.time()获取当前月份的下一个月减去1天（即当月最后一天）的时间，然后通过os.date格式化时间，得到当月的总天数。
    -- -- local dayAmount = os.date("%d", os.time({year = year, month = month + 1, day = 0}))
    -- local dayAmountTs = os.time({year = year, month = month + 1, day = 0, hour = 23, min = 59, sec = 59})
    -- return dayAmountTs
    return G_getEOM()
end

function militaryOrdersVoApi:showMainDialog(layerNum)
    self:requestData(function()
        require "luascript/script/game/scene/gamedialog/militaryOrdersDialog"
        local td = militaryOrdersDialog:new(layerNum)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("militaryOrders_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
        self:setMainUIIconStatus()
    end)
end

function militaryOrdersVoApi:requestData(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:getMilitaryOrders(socketCallback)
end

function militaryOrdersVoApi:initData(data)
    if data then
        if data.daytask then --每日任务
            self.dayTaskData = data.daytask
        end
        if data.level then --玩家等级
            self.playerLv = data.level
        end
        if data.mlvl then --军令等级
            self.moLevel = data.mlvl
        end
        if data.num then --军令币数量
            self.moMoney = data.num
        end
        if data.amount then --充值金额数
            self.rechargeNum = data.amount
        end
        if data.privile then --已解锁的特权
            self.unlockPrivilege = data.privile
        end
        if data.statu then --激活状态
            self.activateStatu = data.statu
        end
        if data.receive then --军令奖励  [1]普通，[2]荣誉
            self.rewardStatusTb = data.receive
        end
        if data.shop then --已购买的商店信息
            self.shopBuyData = data.shop
        end
        if data.retime then --重置时间戳
            self.resetTimer = data.retime
        end
        if data.mover then
            self.mover = data.mover --军令系统的配置标识
        end
    end
end

function militaryOrdersVoApi:getDayTask()
    if self.dayTaskData and self.dayTaskData[1] then
        local tempData = {}
        for k, v in pairs(self.dayTaskData[1]) do
            table.insert(tempData, {key = k, needNum = v[1], num = v[2]})
        end
        return tempData
    end
end

function militaryOrdersVoApi:getItemData(itemId)
    if itemId == "b1" then --军令币
        local item = {
            name = getlocal("militaryOrders_moneyName"),
            desc = "militaryOrders_moneyDesc",
            pic = "moi_money.png",
        }
        return item
    end
end

function militaryOrdersVoApi:getRewardData()
    if self.playerLv then
        local cfg = self:getCfg()
        local index
        for k, v in pairs(cfg.rewardInterval) do
            if k > 1 and self.playerLv >= cfg.rewardInterval[k - 1] and self.playerLv < v then
                index = k - 1
                break
            end
        end
        if index == nil then
            index = SizeOfTable(cfg.rewardInterval)
        end
        return cfg.lvlLimit, cfg.normalReward[index], cfg.honourReward[index]
    end
    return 0
end

function militaryOrdersVoApi:getPrivilegeData()
    local normalPrivilegeData, honourPrivilegeData = {}, {}
    local cfg = self:getCfg()
    for k, v in pairs(cfg.privilegeList) do
        local tempData = {
            id = tostring(k),
            desc = getlocal("militaryOrders_privilegeDesc" .. k, {k == 4 and v.pValue or (v.pValue * 100)}),
            value = v.pValue,
            openLv = v.openLv,
            unlockType = v.unlockType,
        }
        tempData.unlockStatus = self:isUnlockByPrivilegeId(k)
        if v.unlockType == 1 then --普通军令特权
            table.insert(normalPrivilegeData, tempData)
        elseif v.unlockType == 2 then --荣誉军令特权
            table.insert(honourPrivilegeData, tempData)
        end
    end
    table.sort(normalPrivilegeData, function(a, b) return a.openLv < b.openLv end)
    table.sort(honourPrivilegeData, function(a, b) return a.openLv < b.openLv end)
    return normalPrivilegeData, honourPrivilegeData
end

--[[
1=攻打世界叛军时不会产生战损；
2=神秘组织扫荡立即完成；
3=关卡战斗获得的基础经验增加10%:；
4=午间/晚间补给可获得双倍能量:；
5=配件强化的基础成功几率+10%；
6=攻打关卡时，阵亡坦克100%进修理厂；
7=军令等级解锁功能开启；
8=激活荣誉奖励及荣誉特权
--]]
--特权是否解锁
--@ pId:特权id（参考militaryOrderCfg.lua文件中的privilegeList）
function militaryOrdersVoApi:isUnlockByPrivilegeId(pId)
    if self.unlockPrivilege and self.unlockPrivilege[tostring(pId)] then
        local cfg = self:getCfg()
        local value
        if cfg.privilegeList[pId] and cfg.privilegeList[pId].pValue then
            value = cfg.privilegeList[pId].pValue
        end
        return true, value
    end
    return false
end

--获取军令最大等级
function militaryOrdersVoApi:getMaxLevel()
    local cfg = self:getCfg()
    return cfg.lvlLimit
end

--获取军令等级
function militaryOrdersVoApi:getMilitaryOrdersLv()
    if self.moLevel then
        return self.moLevel
    end
    return 0
end

--获取军令币
function militaryOrdersVoApi:getMilitaryOrdersMoney()
    if self.moMoney then
        return self.moMoney
    end
    return 0
end

--获取已充值的金币数
function militaryOrdersVoApi:getRechargeGold()
    if self.rechargeNum then
        return self.rechargeNum
    end
    return 0
end

--购买荣誉军令激活卡需要充值金币数
function militaryOrdersVoApi:getRechargeNeedGold()
    local cfg = self:getCfg()
    return cfg.rechargeGold
end

--是否激活军令(荣誉奖励)
function militaryOrdersVoApi:isActivate()
    return (self.activateStatu == 1)
end

--是否可以购买激活卡
function militaryOrdersVoApi:isCanBuyActivateCard()
    if self.rechargeNum then
        if self.rechargeNum >= self:getRechargeNeedGold() then
            return true
        end
    end
    return false
end

--获取购买激活卡所要消耗的金币数
function militaryOrdersVoApi:getBuyActivateCardCost()
    local cfg = self:getCfg()
    return cfg.costGold
end

--显示军令特权小弹板
function militaryOrdersVoApi:showPrivilegeSmallDialog(layerNum, btnCallback)
    require "luascript/script/game/scene/gamedialog/militaryOrdersSmallDialog"
    militaryOrdersSmallDialog:showPrivilege(layerNum, getlocal("militaryOrders_privilegeTitle"), btnCallback)
end

--显示积分商店小弹板
function militaryOrdersVoApi:showShopSmallDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/militaryOrdersSmallDialog"
    militaryOrdersSmallDialog:showShop(layerNum, getlocal("militaryOrders_shopExchange"))
end

--显示解锁小弹板
function militaryOrdersVoApi:showUnlockSmallDialog(layerNum, paramsTb, btnCallback)
    require "luascript/script/game/scene/gamedialog/militaryOrdersSmallDialog"
    militaryOrdersSmallDialog:showUnlock(layerNum, paramsTb, btnCallback)
end

--显示一键领取奖励小弹板
function militaryOrdersVoApi:showRewardListSmallDialog(layerNum, paramsTb, closeBtnCallback)
    require "luascript/script/game/scene/gamedialog/militaryOrdersSmallDialog"
    militaryOrdersSmallDialog:showRewardList(layerNum, getlocal("award"), paramsTb, closeBtnCallback)
end

function militaryOrdersVoApi:getShopData()
    local cfg = self:getCfg()
    local moLevel = self:getMilitaryOrdersLv()
    local myScore = self:getMilitaryOrdersMoney()
    local canBuyTb, notCanBuyTb = {}, {}
    for k, v in pairs(cfg.exchangeShop) do
        local tempData = {
            id = k,
            cost = v.cost,
            num = v.limit,
            openLv = v.openLv,
            reward = v.reward,
        }
        local buyNum = self:getShopBuyNum(tempData.id)
        if moLevel >= tempData.openLv and buyNum < tempData.num and myScore >= tempData.cost then
            table.insert(canBuyTb, tempData)
        else
            table.insert(notCanBuyTb, tempData)
        end
    end
    table.sort(canBuyTb, function(a, b) return a.openLv < b.openLv end)
    table.sort(notCanBuyTb, function(a, b) return a.openLv < b.openLv end)
    local shopData = {}
    for k, v in pairs(canBuyTb) do table.insert(shopData, v) end
    for k, v in pairs(notCanBuyTb) do table.insert(shopData, v) end
return shopData
end

--获取商店物品已购买数量
--@ sid:商品id
function militaryOrdersVoApi:getShopBuyNum(sid)
    if self.shopBuyData and self.shopBuyData[sid] then
        return self.shopBuyData[sid]
    end
    return 0
end

function militaryOrdersVoApi:getUnlockData()
    local specialLv
    local moLevel = self:getMilitaryOrdersLv()
    local cfg = self:getCfg()
    for k, v in pairs(cfg.buyLvTo) do
        if k > 1 and moLevel >= cfg.buyLvTo[k - 1] and moLevel < v then
            specialLv = v
            break
        end
    end
    if specialLv == nil then
        specialLv = cfg.buyLvTo[SizeOfTable(cfg.buyLvTo)]
    end
    return {{moLevel + 1, cfg.cost}, {specialLv, (specialLv - moLevel) * cfg.cost}}
end

--【军令】激活军令(荣誉奖励)
function militaryOrdersVoApi:requestActivate(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:militaryOrdersActivate(socketCallback)
end

--【军令】领取奖励
--@ moLv:领取等级(一键领取 默认不传)
function militaryOrdersVoApi:requestReward(callback, moLv)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:militaryOrdersReward(socketCallback, moLv)
end

--【军令】商店购买
--@ sid:商品id
--@ num:购买数量
function militaryOrdersVoApi:requestBuy(callback, sid, num)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:militaryOrdersBuy(socketCallback, sid, num)
end

--【军令】解锁军令等级
--@ unlockType:解锁类型（1 解锁下一级，2 解锁至X级）
function militaryOrdersVoApi:requestUnlock(callback, unlockType)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if type(callback) == "function" then
                    callback()
                end
            end
        end
    end
    socketHelper:militaryOrdersUnlock(socketCallback, unlockType)
end

--是否已经领取过奖励
--@ rewardType:奖励类型 1-普通奖励，2-荣誉奖励
--@ moLv:军令等级
function militaryOrdersVoApi:isGetRewardOfLv(rewardType, moLv)
    if self.rewardStatusTb and self.rewardStatusTb[rewardType] then
        return (self.rewardStatusTb[rewardType][moLv] == 1)
    end
    return false
end

function militaryOrdersVoApi:setNewPrivilegeStatus(statusFlag)
    local settingsKey = "militaryOrders@newPrivilegeStatus@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
    CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey, (statusFlag == true) and 1 or 0)
    CCUserDefault:sharedUserDefault():flush()
end

function militaryOrdersVoApi:isHasNewPrivilege()
    local settingsKey = "militaryOrders@newPrivilegeStatus@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
    local valueStatus = CCUserDefault:sharedUserDefault():getIntegerForKey(settingsKey)
    return (valueStatus == 1)
end

function militaryOrdersVoApi:getItemDescParamById(itemId)
    local cfg = self:getCfg()
    local pData
    if itemId == 5042 then
        pData = cfg.privilegeList[3]
    elseif itemId == 5043 then
        pData = cfg.privilegeList[5]
    elseif itemId == 5044 then
        pData = cfg.privilegeList[4]
    end
    if pData and pData.pValue then
        return ((itemId == 5044) and pData.pValue or (pData.pValue * 100))
    end
end

function militaryOrdersVoApi:getResetTimer()
    if self.resetTimer then
        return self.resetTimer
    end
end

function militaryOrdersVoApi:setMainUIIconStatus()
    if self.resetTimer then
        local settingsKey = "militaryOrders@mainUIIconStatus@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
        CCUserDefault:sharedUserDefault():setIntegerForKey(settingsKey, self.resetTimer)
        CCUserDefault:sharedUserDefault():flush()
    end
end

function militaryOrdersVoApi:mainUIIconStatus(callback)
    if self.resetTimer then
        local resetTimeObj = G_getDate(self.resetTimer) --os.date("*t", self.resetTimer)
        local curTimeObj = G_getDate(base.serverTime) --os.date("*t", base.serverTime)
        if resetTimeObj.year == curTimeObj.year and resetTimeObj.month == curTimeObj.month and resetTimeObj.day == curTimeObj.day then
            local settingsKey = "militaryOrders@mainUIIconStatus@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
            local valueStatus = CCUserDefault:sharedUserDefault():getIntegerForKey(settingsKey)
            if valueStatus ~= self.resetTimer then
                return true
            end
        end
        local moLevel = self:getMilitaryOrdersLv()
        local m_isActivate = self:isActivate()
        for i = 1, moLevel do
            --@该判断语句：是否有奖励可领取
            if self:isGetRewardOfLv(1, i) == false or (m_isActivate == true and self:isGetRewardOfLv(2, i) == false) then
                return true
            end
        end
    else
        if self.m_isRequest then
            print("cjl -------->>> @后端 'retime' 字段出错")
        else
            self.m_isRequest = true
            self:requestData(callback)
        end
    end
end

--是否是充值购买
function militaryOrdersVoApi:isRechargeBuy()
	if G_isChina() == false then --国外平台不开放直接货币购买
		do return false end
	end
    local cfg = self:getCfg()
    if cfg and cfg.costRMB and cfg.rechargeID then
        return true
    end
    return false
end

function militaryOrdersVoApi:getRechargeBuyCost()
    local cfg = self:getCfg()
    return cfg.rechargeID, cfg.costRMB
end

function militaryOrdersVoApi:saveRechargeBuyTime()
	local buytimeKey = "militaryOrders@rechargebuyts@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
    CCUserDefault:sharedUserDefault():setIntegerForKey(buytimeKey, tonumber(base.serverTime + 60))
    CCUserDefault:sharedUserDefault():flush()
end

function militaryOrdersVoApi:getRechargeBuyTime()
	local buytimeKey = "militaryOrders@rechargebuyts@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
    return CCUserDefault:sharedUserDefault():getIntegerForKey(buytimeKey)
end

function militaryOrdersVoApi:syncMilitary(data)
    self:initData(data)
end

function militaryOrdersVoApi:clear()
    self.dayTaskData = nil
    self.playerLv = nil
    self.moLevel = nil
    self.moMoney = nil
    self.rechargeNum = nil
    self.unlockPrivilege = nil
    self.activateStatu = nil
    self.rewardStatusTb = nil
    self.shopBuyData = nil
    self.resetTimer = nil
    self.m_isRequest = nil
    self.ltmover = nil
    self.mover = nil
end
