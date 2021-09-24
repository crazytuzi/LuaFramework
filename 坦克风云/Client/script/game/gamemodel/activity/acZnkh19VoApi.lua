acZnkh19VoApi = {
}

function acZnkh19VoApi:getAcVo()
    if self.vo == nil then
        self.vo = activityVoApi:getActivityVo("znkh2019")
    end
    return self.vo
end

function acZnkh19VoApi:getVersion()
    local vo = self:getAcVo()
    if vo and vo.version then
        return vo.version
    end
    return 1 --默认
end

--充值奖励
function acZnkh19VoApi:getRechargeRewards()
    local vo = self:getAcVo()
    if vo and vo.cfg.rechargeReward then
        return FormatItem(vo.cfg.rechargeReward, nil, true)
    end
    return {}
end

--是否处于领奖时间
function acZnkh19VoApi:isRewardTime()
    local vo = self:getAcVo()
    if vo then
        if base.serverTime > vo.acEt - 86400 and base.serverTime < vo.acEt then
            return true
        end
    end
    return false
end

function acZnkh19VoApi:getTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local timeValue = vo.et - base.serverTime - 86400 -- 要是有1天发奖励需要减 86400
        local activeTime = timeValue > 0 and G_formatActiveDate(timeValue) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return str
end

function acZnkh19VoApi:getRewardTimeStr()
    local str = ""
    local vo = self:getAcVo()
    if vo then
        local activeTime = G_formatActiveDate(vo.et - base.serverTime)
        if self:isRewardTime() == false then
            activeTime = getlocal("notYetStr")
        end
        return getlocal("sendReward_title_time")..activeTime
    end
    return str
end

--获取数字道具显示数据
function acZnkh19VoApi:getNumeralPropShowInfo(key)
    local num = tonumber(RemoveFirstChar(key))
    local pic, bgname, desc, name
    if num <= 10 or num == 99 then
        bgname = "acZnkh19_yellowka.png"
    else
        bgname = "acZnkh19_purpleka.png"
    end
    if num == 99 then
        pic = "acZnkh2019_z"..num..".png"
        name = getlocal("znkh19_numeral_rand")
    else
        num = num % 10
        if num == 0 then
            pic = "acZnkh2019_z9.png"
            name = getlocal("znkh19_numeral", {9})
        else
            pic = "acZnkh2019_z" .. (num - 1) .. ".png"
            name = getlocal("znkh19_numeral", {(num - 1)})
        end
    end
    desc = "znkh19_numeral_prop_desc"
    return pic, bgname, name, desc
end

function acZnkh19VoApi:getNumeralPropIcon(key, callback, nsc)
    local pic, bgname = self:getNumeralPropShowInfo(key)
    local iconBg = LuaCCSprite:createWithSpriteFrameName(bgname, function ()
        if callback then
            callback()
        end
    end)
    local iconSp = CCSprite:createWithSpriteFrameName(pic)
    iconSp:setPosition(iconBg:getContentSize().width / 2, 53)
    iconBg:addChild(iconSp)
    
    --nsc 为显示卡片数量时，数量显示的配置信息
    if nsc and type(nsc) == "table" then
        local num, fs = nsc[1] or 0, nsc[2] or 18
        if num > 0 then
            local numLb = GetTTFLabel(FormatNumber(num), fs)
            numLb:setTag(22)
            numLb:setAnchorPoint(ccp(1, 0.5))
            local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
            numBg:setAnchorPoint(ccp(1, 0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
            numBg:setPosition(ccp(iconBg:getContentSize().width - 3, 7))
            numBg:setOpacity(150)
            numBg:setTag(11)
            iconBg:addChild(numBg, 2)
            numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
            numBg:addChild(numLb)
        end
    end
    
    return iconBg
end

--刷新卡片数量显示
function acZnkh19VoApi:refreshNumeralPropIcon(iconSp, num)
    if iconSp == nil or tolua.cast(iconSp, "LuaCCSprite") == nil then
        do return end
    end
    local numBg = iconSp:getChildByTag(11)
    if numBg and tolua.cast(numBg, "LuaCCScale9Sprite") and num and num > 0 then
        local numLb = numBg:getChildByTag(22)
        if numLb and tolua.cast(numLb, "CCLabelTTF") then
            numLb:setString(FormatNumber(num))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
            numBg:setScale(1 / iconSp:getScale())
            numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
        end
    end
end

function acZnkh19VoApi:getNumerals()
    local vo = self:getAcVo()
    if vo and vo.numerals then
        return vo.numerals
    end
    return {}
end

--获取拥有数字的数量
function acZnkh19VoApi:getNumeralNum(key)
    local vo = self:getAcVo()
    if vo and vo.numerals then
        local nk = "active_"..key
        return vo.numerals[nk] or 0
    end
    return 0
end

function acZnkh19VoApi:getNumeralKeyForServer(numkey)
    return "active_"..numkey
end

--后端给的数字卡片奖励格式以active_开头，这里需要处理一下
function acZnkh19VoApi:getNumeralKeyFromServer(numkey)
    local m = Split(numkey, "_")
    if m and m[1] and m[2] and m[1] == "active" then
        return m[2]
    end
    return numkey
end

--获取可以选择的数字序列
--sltNumerals已经选择的数字
function acZnkh19VoApi:getCanSelectNumerals(sltNumerals, ktype)
    if sltNumerals == nil then
        sltNumerals = {}
    end
    local numerals = {}
    local all = acZnkh19VoApi:getNumerals()
    for k, v in pairs(all) do
        local numKey = acZnkh19VoApi:getNumeralKeyFromServer(k)
        local n = tonumber(RemoveFirstChar(numKey))
        if (ktype == 1 and n <= 10) or (ktype == 2 and n > 10) then
            local num = v - (sltNumerals[numKey] or 0)
            if num > 0 then
                numerals[n] = {numKey, num}
            end
        end
    end
    
    return numerals
end

--可以瓜分的金币总数
function acZnkh19VoApi:getTotalGems()
    return self.gems or 0
end

function acZnkh19VoApi:getExchangePool()
    if self.exchangePool then
        return self.exchangePool
    end
    local vo = self:getAcVo()
    self.exchangePool = {}
    for k, v in pairs(vo.cfg.exchangeS) do
        local reward = FormatItem(v.reward, nil, true)[1]
        reward.znkh19_rpos = "s"..k
        table.insert(self.exchangePool, reward)
    end
    for k, v in pairs(vo.cfg.exchangeP) do
        local reward = FormatItem(v.reward, nil, true)[1]
        reward.znkh19_rpos = "p"..k
        table.insert(self.exchangePool, reward)
    end
    
    return self.exchangePool
end

--获取选择数字对应的兑换奖励
function acZnkh19VoApi:getExchangeReward(numkey1, numkey2)
    local vo = self:getAcVo()
    if vo == nil or vo.cfg == nil or self:isNumeralEmpty(numkey1) == false or self:isNumeralEmpty(numkey2) == false then --其中一个数字未选择的话，则没有兑换奖励
        return nil
    end
    local etb = {numkey1, numkey2}
    for k, v in pairs(vo.cfg.exchangeS) do --先判断是否是特殊兑换组合
        local need = G_clone(v.need)
        local on = 0
        for k, v in pairs(etb) do
            for nk, nv in pairs(need) do
                if v == nv then
                    on = on + 1
                    table.remove(need, nk)
                    do break end
                end
            end
        end
        if on == 2 then
            return FormatItem(v.reward)[1]
        end
    end
    if vo and vo.cfg.number then --判断是否是普通兑换组合
        local rg1 = vo.cfg.number[numkey1] or 0
        local rg2 = vo.cfg.number[numkey2] or 0
        local rg = rg1 + rg2 --数字组合价值之和
        for k, v in pairs(vo.cfg.exchangeP) do
            if rg >= v.range[1] and rg <= v.range[2] then
                local reward = FormatItem(v.reward)[1]
                reward.num = reward.num + rg - v.range[1] --道具数量为 基础数量 +（数字价值 - 价值下限）
                return reward
            end
        end
    end
    return nil
end

--判断传入的数字格式是否合法
function acZnkh19VoApi:isNumeralEmpty(numkey)
    if numkey ~= nil and numkey ~= "o0" then
        return true
    end
    return false
end

function acZnkh19VoApi:getLotteryCost()
    local vo = self:getAcVo()
    if vo and vo.cfg and vo.cfg.cost then
        return vo.cfg.cost[1], vo.cfg.cost[2]
    end
    return 0, 0
end

--是否为免费抽取
function acZnkh19VoApi:isFreeLottery()
    local vo = self:getAcVo()
    if vo and vo.lottery_at and (vo.lottery_at == 0 or G_isToday(vo.lottery_at) == false) then
        return 1
    end
    return 0
end

function acZnkh19VoApi:getLotteryPool()
    local vo = self:getAcVo()
    if vo.cfg and vo.cfg.gachaShow then
        return FormatItem(vo.cfg.gachaShow, nil, true)
    end
    return {}
end

--获取活动数据
function acZnkh19VoApi:znkhGet(callback)
    local function getCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if callback then
                callback()
            end
        end
    end
    socketHelper:acZnkh19Get(getCallBack)
end

--抽奖
function acZnkh19VoApi:znkhLottery(free, num, cost, callback)
    local function lotteryCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if sData.data.reward then --奖励
                local rewardList = {}
                for k, v in pairs(sData.data.reward) do
                    local r = FormatItem(v, nil, true)[1]
                    table.insert(rewardList, r)
                end
                if callback then
                    local hxReward = self:getHxReward()
                    if hxReward then --插入和谐版奖励
                        hxReward.num = hxReward.num * num
                        table.insert(rewardList, 1, hxReward)
                    end
                    for k, v in pairs(rewardList) do
                        if v.type ~= "ac" or v.eType ~= "o" then
                            G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                        end
                    end
                    playerVoApi:setGems(playerVoApi:getGems() - cost) --扣除金币
                    callback(rewardList)
                end
                self.lotryFlag = true
                eventDispatcher:dispatchEvent("znkh19.refresh", {})
            end
        end
    end
    socketHelper:acZnkh19Lottery(free, num, lotteryCallBack)
end

--获取和谐版奖励
function acZnkh19VoApi:getHxReward()
    local vo = self:getAcVo()
    if vo and vo.hxReward then
        local rewardTb = FormatItem(vo.hxReward, nil, true)
        return rewardTb[1]
    end
    return nil
end

function acZnkh19VoApi:getRechargeGems()
    local vo = self:getAcVo()
    if vo and vo.recharge then
        return vo.recharge[1], vo.recharge[2]
    end
    return 0, 0
end

--是否可以领取充值奖励
function acZnkh19VoApi:isCanRewardGems()
    local gems = self:getTotalGems()
    local vo = self:getAcVo()
    if vo == nil then
        return false
    end
    local pr = vo.cfg.recharge --每充recharge即可领奖
    local rgn, grn = self:getRechargeGems()
    --当前充值金额可领奖次数大于已领奖次数时则可以领取充值奖励
    local rn = math.floor(rgn / pr) - grn
    if rn > 0 then
        return true, rgn, rn
    end
    return false, rgn, rn
end

--领取充值奖励
function acZnkh19VoApi:gemsReward(callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if sData.data.reward then
                local rewardList = FormatItem(sData.data.reward, nil, true)
                for k, v in pairs(rewardList) do
                    if v.type ~= "ac" or v.eType ~= "o" then
                        G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                    end
                end
                if callback then
                    callback(rewardList)
                end
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:acZnkh19GemsReward(handler)
end

--是否已瓜分金币奖励
function acZnkh19VoApi:isDevidedGems()
    local vo = self:getAcVo()
    if vo and vo.isDivided then
        return vo.isDivided
    end
    return 0
end

--瓜分金币奖池
function acZnkh19VoApi:devideGems(callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if callback then
                callback()
            end
            eventDispatcher:dispatchEvent("znkh19.refresh", {})
        end
    end
    socketHelper:acZnkh19DevideGems(handler)
end

--兑换数字组合奖励
function acZnkh19VoApi:exchangeNumeralReward(etb, num, callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if sData.data.reward then
                local reward = FormatItem(sData.data.reward, nil, true)[1]
                G_addPlayerAward(reward.type, reward.key, reward.id, reward.num, nil, true)
                if callback then
                    callback(reward)
                end
                self.exrFlag = true
            end
        end
    end
    socketHelper:acZnkh19Exchange(etb, num, handler)
end

--赠送数字
function acZnkh19VoApi:numeralSend(ackey, receiver, callback)
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if callback then
                callback(reward)
            end
            eventDispatcher:dispatchEvent("znkh19.refresh", {})
        end
    end
    socketHelper:acZnkh19NumeralSend(ackey, receiver, handler)
end

function acZnkh19VoApi:getGiveNumeralPool()
    local vo = self:getAcVo()
    if vo and vo.cfg.sendNum then
        return vo.cfg.sendNum
    end
    return {"o1", "o2", "o3", "o4", "o5", "o6", "o7", "o8", "o9", "o10"}
end

function acZnkh19VoApi:getGiveNumInfo()
    local num = 0
    local vo = self:getAcVo()
    if vo and vo.giveRecords then
        for k, v in pairs(vo.giveRecords) do
            num = num + SizeOfTable(v)
        end
    end
    return num, vo.cfg.sendMax
end

--玩家赠送记录
function acZnkh19VoApi:getGiveRecordList()
    local vo = self:getAcVo()
    if vo and vo.giveRecords then
        return vo.giveRecords
    end
    return {}
end

--获取日志
--logType 1：抽检 2：兑换 3：奖励兑换
function acZnkh19VoApi:getLog(logType, callback)
    if (logType == 1 and self.lotryFlag == false) or (logType == 2 and self.exrFlag == false) then --日志需要刷新时才重新拉日志数据，不需要每次都拉
        if callback then callback() end
        do return end
    end
    local function handler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:updateData(sData.data)
            if sData.data.log then
                if logType == 1 then
                    self.lotteryLogs = sData.data.log
                    self.lotryFlag = false
                elseif logType == 2 then
                    self.exchangeRecords = sData.data.log
                    self.exrFlag = false
                end
                if callback then
                    callback(sData.data.log)
                end
            end
        end
    end
    socketHelper:acZnkh19NumeralLog(logType, handler)
end

function acZnkh19VoApi:getRewardExchangeRecords(reward)
    local vo = self:getAcVo()
    if vo and vo.exrecords then
        local records = {}
        local rpos = reward.znkh19_rpos
        for k, v in pairs(vo.exrecords) do
            if v[2] == rpos then
                table.insert(records, v)
            end
        end
        return records
    end
    return {}
end

function acZnkh19VoApi:getLotteryLog()
    return self.lotteryLogs or {}
end

function acZnkh19VoApi:getExchangeRecords()
    return self.exchangeRecords or {}
end

function acZnkh19VoApi:getMaxDivideGems()
    local vo = self:getAcVo()
    if vo and vo.cfg.gemsMax then
        return vo.cfg.gemsMax
    end
    return 0
end

function acZnkh19VoApi:canReward()
    local vo = self:getAcVo()
    if vo == nil then
        return false
    end
    return false
end

function acZnkh19VoApi:updateData(data)
    local vo = self:getAcVo()
    if data.znkh2019 then
        vo:updateSpecialData(data.znkh2019)
        activityVoApi:updateShowState(vo)
    end
    if data.gempool then
        self.gems = data.gempool
    end
end

function acZnkh19VoApi:isEnd()
    local vo = self:getAcVo()
    if vo and base.serverTime < vo.et then
        return false
    end
    return true
end

--选择数字页面
function acZnkh19VoApi:showSelectNumeralDialog(ktype, numeralKa, confirmCallback, layerNum)
    local znkhsmd = G_requireLua("game/scene/gamedialog/activityAndNote/acZnkh19SmallDialog")
    znkhsmd:showSelectNumeralDialog(ktype, numeralKa, confirmCallback, layerNum)
end

--选择数字页面
function acZnkh19VoApi:showGiveNumeralDialog(layerNum)
    local znkhsmd = G_requireLua("game/scene/gamedialog/activityAndNote/acZnkh19SmallDialog")
    znkhsmd:showGiveNumeralDialog(layerNum)
end

--奖励兑换记录
function acZnkh19VoApi:showRewardExchangeRecordDialog(reward, layerNum)
    local znkhsmd = G_requireLua("game/scene/gamedialog/activityAndNote/acZnkh19SmallDialog")
    znkhsmd:showRewardExchangeRecordDialog(reward, layerNum)
end

--兑换记录
function acZnkh19VoApi:showExchangeRecordsDialog(layerNum)
    local znkhsmd = G_requireLua("game/scene/gamedialog/activityAndNote/acZnkh19SmallDialog")
    znkhsmd:showExchangeRecordsDialog(layerNum)
end

--瓜分奖池所需数字组合
function acZnkh19VoApi:getGemsNeed()
    local vo = self:getAcVo()
    if vo and vo.cfg.getGemsNeed then
        return vo.cfg.getGemsNeed
    end
    return {}
end

function acZnkh19VoApi:getOpenLv()
    local vo = self:getAcVo()
    if vo and vo.cfg and vo.cfg.playerLv then
        return vo.cfg.playerLv
    end
    return 30
end

function acZnkh19VoApi:clearAll()
    self.gems = nil
    self.exchangeRecords = nil
    self.exrFlag = nil
    self.lotryFlag = nil
    self.exchangePool = nil
    self.vo = nil
end

function acZnkh19VoApi:addActivieIcon()
    spriteController:addPlist("public/activeCommonImage3.plist")
    spriteController:addTexture("public/activeCommonImage3.png")
end
function acZnkh19VoApi:removeActivieIcon()
    spriteController:removePlist("public/activeCommonImage3.plist")
    spriteController:removeTexture("public/activeCommonImage3.png")
end
