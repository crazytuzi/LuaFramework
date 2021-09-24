BossBattleVoApi = {
    flag = nil,
    rankList = {},
    bossKiller = nil,
    isChatTip = nil, --是否已经发送世界boss开启时公告
    selectMyselfAttack = 0,
    isInDialog = false, --是否打开海德拉面板
}

function BossBattleVoApi:onRefreshData(data)
    self.dataNeedRefresh = false
    BossBattleVo:updateData(data)
end

function BossBattleVoApi:getBossMaxHp()
    if BossBattleVo.bossMaxHp then
        return tonumber(BossBattleVo.bossMaxHp)
    end
    return 0
end

function BossBattleVoApi:getBossAllDamage()
    if BossBattleVo.bossDamage then
        return tonumber(BossBattleVo.bossDamage)
    end
    return 0
end
function BossBattleVoApi:setBossAllDamage(damage)
    if BossBattleVo.bossDamage == nil then
        BossBattleVo.bossDamage = 0
    end
    
    BossBattleVo.bossDamage = damage
end

function BossBattleVoApi:getBossLv()
    if BossBattleVo.bossLv then
        return tonumber(BossBattleVo.bossLv)
    end
    return bossCfg.startLevel
end

function BossBattleVoApi:getBossGround()
    if BossBattleVo.bossGround then
        return tonumber(BossBattleVo.bossGround)
    end
    return 1
end

function BossBattleVoApi:getRewardLevel(...)
    local rewardLevelCfg = bossCfg.rewardInterval
    local level = self:getBossLv()
    for k, v in pairs(rewardLevelCfg) do
        if level < v then
            return (k - 1)
        end
    end
    return #rewardLevelCfg
end

function BossBattleVoApi:getBossNowHp()
    local maxHp = self:getBossMaxHp()
    local damage = self:getBossAllDamage()
    if maxHp >= damage then
        return tonumber(maxHp - damage)
    end
    return 0
end

function BossBattleVoApi:getMyselfPoint()
    if BossBattleVo.point then
        if BossBattleVo.point >= self:getBossMaxHp() then
            BossBattleVo.point = self:getBossMaxHp()
        end
        return tonumber(BossBattleVo.point)
    end
    return 0
end

function BossBattleVoApi:getAttackSelf()
    if BossBattleVo.attackSelf then
        return BossBattleVo.attackSelf
    end
    return 0
end

function BossBattleVoApi:setAttackSelf(attack)
    BossBattleVo.attackSelf = attack
    
end

function BossBattleVoApi:getAttackTime()
    if BossBattleVo.attack_at then
        return BossBattleVo.attack_at
    end
    return - 1
end
function BossBattleVoApi:getRewardTime()
    if BossBattleVo.rewardTime then
        return BossBattleVo.rewardTime
    end
    return - 1
end

function BossBattleVoApi:hadRankReward()
    if G_isToday(self:getRewardTime()) == true then
        return true
    end
    return false
end
function BossBattleVoApi:canRankReward()
    if G_isToday(self:getAttackTime()) == true and self:getMyselfPoint() > 0 then
        return true
    end
    return false
end
function BossBattleVoApi:getRankNum()
    return 10
end

function BossBattleVoApi:setHadBuyBuff(buff)
    BossBattleVo.buffInfo = buff
end
function BossBattleVoApi:getBattlefieldUser()
    local buffTb = {b1 = 0, b2 = 0, b3 = 0, b4 = 0}
    if BossBattleVo.buffInfo then
        for i = 1, 10 do
            if BossBattleVo.buffInfo["b"..i] == nil then
                buffTb["b"..i] = 0
            else
                buffTb["b"..i] = BossBattleVo.buffInfo["b"..i]
            end
        end
        return buffTb
    end
    return buffTb
end

function BossBattleVoApi:getBossOpenTime()
    local openTimeCfg = bossCfg.opentime
    local startTime = openTimeCfg[1][1] * 3600 + openTimeCfg[1][2] * 60
    local endTime = openTimeCfg[2][1] * 3600 + openTimeCfg[2][2] * 60
    local vo = dailyActivityVoApi:getActivityVo("boss")
    if vo then
        if vo.st and vo.et then
            startTime = vo.st - G_getWeeTs(vo.st)
            endTime = vo.et - G_getWeeTs(vo.et)
        end
    end
    
    return startTime, endTime
end

function BossBattleVoApi:getBossState()
    local dayTime = base.serverTime - G_getWeeTs(base.serverTime)
    local startTime, endTime = self:getBossOpenTime()
    local state, time
    if dayTime < (startTime - bossCfg.inTime) then
        state = 1
        time = (startTime - bossCfg.inTime) - dayTime
    elseif dayTime < startTime then
        state = 2
        time = startTime - dayTime
    elseif dayTime <= endTime then
        if self:getBossNowHp() > 0 then
            state = 3
            time = endTime - dayTime
        else
            state = 4
            time = (startTime + 24 * 60 * 60) - dayTime
        end
    elseif dayTime > endTime then
        state = 5
        time = (startTime + 24 * 60 * 60) - dayTime
    end
    return state, time
end
function BossBattleVoApi:setRankList(list, killer)
    self.rankList = list
    self.bossKiller = killer
end
function BossBattleVoApi:getRankList()
    if self.rankList then
        return self.rankList
    end
    return {}
end

function BossBattleVoApi:getBossKiller()
    if self.bossKiller then
        return self.bossKiller
    end
    return nil
end

function BossBattleVoApi:getMyRank()
    if self.rankList then
        for k, v in pairs(self.rankList) do
            if v and v[1] and v[1] == playerVoApi:getUid() then
                return k
            end
        end
    end
    return - 1
end

function BossBattleVoApi:getMyAttackedBoss()
    if BossBattleVo.attackedTb then
        return BossBattleVo.attackedTb
    end
    return {}
end

function BossBattleVoApi:getAllReward()
    local myRank = self:getMyRank()
    local level = self:getRewardLevel()
    local allReward = {}
    if self:getMyAttackedBoss() and SizeOfTable(self:getMyAttackedBoss()) > 0 then
        for k, v in pairs(self:getMyAttackedBoss()) do
            if v then
                if v == 6 then
                    table.insert(allReward, FormatItem(bossCfg.attackHpreward[level][2]))
                else
                    table.insert(allReward, FormatItem(bossCfg.attackHpreward[level][1]))
                end
            end
        end
    end
    if self:getBossNowHp() <= 0 and myRank ~= -1 then
        table.insert(allReward, self:getRankReward())
    end
    if self:getMyselfPoint() > 0 then
        local level = BossBattleVoApi:getRewardLevel()
        local damagePer = math.ceil(self:getMyselfPoint() / self:getBossMaxHp() * bossCfg.attacktolHprewardRate)
        local oneItem = FormatItem(bossCfg.attacktolHpreward[level][1])
        local twoItem = FormatItem(bossCfg.attacktolHpreward[level][2])
        local threeItem = FormatItem(bossCfg.attacktolHpreward[level][3])
        if damagePer >= 100 then
            for k, v in pairs(oneItem) do
                oneItem[k].num = v.num * math.floor(damagePer / 100)
            end
            table.insert(allReward, oneItem)
            
            if math.floor((damagePer - math.floor(damagePer / 100) * 100) / 10) > 0 then
                for k, v in pairs(twoItem) do
                    twoItem[k].num = v.num * math.floor((damagePer - math.floor(damagePer / 100) * 100) / 10)
                end
                table.insert(allReward, twoItem)
            end
            if (damagePer - math.floor(damagePer / 10) * 10) > 0 then
                for k, v in pairs(threeItem) do
                    threeItem[k].num = v.num * (damagePer - math.floor(damagePer / 10) * 10)
                end
                table.insert(allReward, threeItem)
            end
        elseif damagePer >= 10 then
            for k, v in pairs(twoItem) do
                twoItem[k].num = v.num * math.floor(damagePer / 10)
            end
            table.insert(allReward, twoItem)
            if (damagePer - math.floor(damagePer / 10) * 10) > 0 then
                for k, v in pairs(threeItem) do
                    threeItem[k].num = v.num * (damagePer - math.floor(damagePer / 10) * 10)
                end

                table.insert(allReward, threeItem)
            end
        elseif damagePer > 0 then
            for k, v in pairs(threeItem) do
                threeItem[k].num = v.num * damagePer
            end
            table.insert(allReward, threeItem)
        end
    end
    return allReward
end
function BossBattleVoApi:getRankReward()
    local rank1
    local rank2
    local reward = {}
    local myRank = self:getMyRank()
    local level = self:getRewardLevel()
    for k, v in pairs(bossCfg.rankReward[level]) do
        if v and type(v) == "table" then
            local award = {}
            for m, n in pairs(v) do
                if m == "range" then
                    rank1 = n[1]
                    rank2 = n[2]
                else
                    award = FormatItem(n)
                end
            end
            if myRank >= rank1 and myRank <= rank2 then
                reward = award
            end
        end
    end
    return reward
end

function BossBattleVoApi:getBossOldHp()
    if BossBattleVo.bossOldHp then
        return BossBattleVo.bossOldHp
    end
    return 0
end

function BossBattleVoApi:setBossOldHp(hp)
    BossBattleVo.bossOldHp = BossBattleVo.bossOldHp - hp
end

function BossBattleVoApi:getBossPaotou()
    local maxHp = self:getBossMaxHp()
    local bossHp = self:getBossOldHp()
    local tankTb = {}
    if bossHp <= 0 then
        return tankTb
    end
    for i = 1, 6 do
        if bossHp > maxHp / 6 * (i - 1) then
            tankTb[bossCfg.paotou[6 - i + 1]] = 1
        end
    end
    
    return tankTb
end

function BossBattleVoApi:getNoSubLifeBossPaotou(btdata, mm)--预先判断损失的炮口
    local subHp = 0
    for i = 1, mm do
        local curDate = btdata[i]
        local dataTb = Split(curDate, "-")
        subHp = subHp + tonumber(dataTb[1])
    end
    
    local newHp = BossBattleVo.bossOldHp - subHp
    local maxHp = self:getBossMaxHp()
    local tankTb = {}
    if newHp <= 0 then
        return tankTb
    end
    for i = 1, 6 do
        if newHp > maxHp / 6 * (i - 1) then
            tankTb[bossCfg.paotou[6 - i + 1]] = 1
        end
    end
    
    return tankTb
end

function BossBattleVoApi:isSameToGunNum(btdata, curIdx, beAttkPos)
    local GunNums = SizeOfTable(self:getBossPaotou())
    local addHurt = 0
    local isDie = 1
    local maxHp = self:getBossMaxHp()
    local bossHp = self:getBossOldHp()
    local tankTb = {}
    local isSame = true
    local nextAttPos = 0
    local curGunNum = 0
    for i = 1, curIdx do
        if btdata == nil or btdata[i] == nil then
            return isSame, 0
        end
        local willHurtTb = Split(btdata[i], "-")
        addHurt = addHurt + willHurtTb[1]
        if willHurtTb[2] == 0 then
            isDie = willHurtTb[2]
        end
    end
    for i = 1, 6 do
        if bossHp - addHurt > maxHp / 6 * (i - 1) then
            tankTb[bossCfg.paotou[6 - i + 1]] = 1
        end
    end
    for k, v in pairs(bossCfg.paotou) do
        if v == beAttkPos then
            curGunNum = k
        end
    end
    if SizeOfTable(tankTb) ~= GunNums and tankTb[bossCfg.paotou[curGunNum]] == nil then
        isSame = false
        for i = 1, 6 do
            if beAttkPos == bossCfg.paotou[i] then
                if i + 1 > 6 then
                    nextAttPos = bossCfg.paotou[i - 1]
                else
                    nextAttPos = bossCfg.paotou[i + 1]
                end
            end
        end
    end
    return isSame, isDie, nextAttPos
end

function BossBattleVoApi:getDestoryPaotouByHP(bossHP, oldHP)
    local maxHp = self:getBossMaxHp()
    local oldBossHP = oldHP
    local bossHp = bossHP
    local oldPaotou = {}
    if oldBossHP <= 0 then
        oldPaotou = {}
    end
    for i = 1, 6 do
        if oldBossHP > maxHp / 6 * (i - 1) then
            oldPaotou[bossCfg.paotou[6 - i + 1]] = 1
        end
    end
    
    local destoryPaotou = {}
    local tankTb = {}
    for i = 1, 6 do
        if bossHp > maxHp / 6 * (i - 1) then
            tankTb[bossCfg.paotou[6 - i + 1]] = 1
        end
    end
    
    for k, v in pairs(oldPaotou) do
        if v and tankTb[k] == nil then
            table.insert(destoryPaotou, k)
        end
    end
    return destoryPaotou
end

function BossBattleVoApi:pushMessage(params)
    --print("......params.damage",params.damage)
    self:setBossAllDamage(params.damage)
    
end
function BossBattleVoApi:setFlag(flag)
    self.flag = flag
end
function BossBattleVoApi:getFlag()
    if self.flag then
        return self.flag
    end
    return - 1
end

function BossBattleVoApi:showShop(layerNum)
    if playerVoApi:getPlayerLevel() < bossCfg.levelLimite then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage15001", {bossCfg.levelLimite}), 30)
        do return end
    end
    if(self:checkShopOpen())then
        require "luascript/script/game/scene/gamedialog/Boss/BossBattleDialog"
        local vd = BossBattleDialog:new()
        local dialog = vd:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {getlocal("playerInfo"), getlocal("BossBattle_damageRank"), getlocal("fleetCard")}, nil, nil, getlocal("BossBattle_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
        return td
    else
        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("BossBattle_notOpen"),30)
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("not_to_time"), 30)
        do return end
    end
end

function BossBattleVoApi:checkShopOpen()
    local state = self:getBossState()
    if state == 1 then
        return false
    else
        return true
    end
end

function BossBattleVoApi:getBossTroops()
    if BossBattleVo.bossTroops then
        return BossBattleVo.bossTroops
    end
    return {}
end

function BossBattleVoApi:getHurtNumAndMuzzle(data)
    local hurtNum = 0
    local isKill = false
    
    if data and data.data and data.data.worldboss and data.data.worldboss.boss then
        hurtNum = data.data.worldboss.boss[5] - (data.data.worldboss.boss[2] - data.data.worldboss.boss[3])
    end
    
    if data and data.destoryPaotou then
        for k, v in pairs(data.destoryPaotou) do
            if v and bossCfg.paotou[v] and bossCfg.paotou[v] == 6 then
                isKill = true
                do break end
            end
        end
    end
    
    if isKill == true then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("BossBattle_result_kill", {getlocal("BossBattle_name"), hurtNum, getlocal("BossBattle_name")}), nil, 7, nil, function() end)
    elseif SizeOfTable(data.destoryPaotou) > 0 then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("BossBattle_result_destory", {getlocal("BossBattle_name"), hurtNum, SizeOfTable(data.destoryPaotou)}), nil, 7, nil, function() end)
    else
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("BossBattle_result_damage", {getlocal("BossBattle_name"), hurtNum}), nil, 7, nil, function() end)
    end
end

function BossBattleVoApi:tick()
    -- print("BossBattleVoApi:tick()!!!!!!!!")
    local bossState, leftTime = self:getBossState()
    if bossState == 3 then --boss战进行中
        if BossBattleVo.attackSelf and BossBattleVo.attackSelf == 1 then
            if self:getAttackTime() and self:getAttackTime() > 0 and (base.serverTime - self:getAttackTime()) <= bossCfg.reBornTime then
            else
                if BossBattleVoApi.isInDialog == false then
                    local function attakcCallback(fn, data)
                        local ret, sData = base:checkServerData(data)
                        if ret == true then
                            if sData.data.worldboss then
                                self:attakcCallback(sData.data.worldboss)
                            end
                        elseif sData and sData.ret == -15005 then --如果海德拉被击退了则把伤害矫正
                        	BossBattleVoApi:setBossAllDamage(BossBattleVoApi:getBossMaxHp())
                        end
                    end
                    socketHelper:BossBattleAttack(0, attakcCallback)
                end
            end
        end
    end
    if base.boss == 1 then
        if playerVoApi:getPlayerLevel() >= bossCfg.levelLimite then
            local dayTime = base.serverTime - G_getWeeTs(base.serverTime)
            local stTime, endTime = self:getBossOpenTime()
            if dayTime >= stTime and dayTime < stTime + 10 and self.isChatTip == nil then
                self.isChatTip = true
                local message = {key = "BossBattle_boss_start_time", param = {}}
                local selfUid = playerVoApi:getUid()
                local selfName = playerVoApi:getPlayerName()
                local language = G_getCurChoseLanguage()
                local content = {subType = 4, contentType = 3, message = message, ts = base.serverTime, language = language, paramTab = {}}
                chatVoApi:addChat(1, selfUid, selfName, 0, "", content, base.serverTime)
            end
            if dayTime == endTime then
                local function onRequestEnd(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData and sData.data and sData.data.worldboss then
                            BossBattleVoApi:onRefreshData(sData.data.worldboss)
                        end
                        if self:getBossNowHp() > 0 then
                            local paramTab = {}
                            paramTab.functionStr = "boss"
                            paramTab.addStr = "go_attack"
                            local params = {subType = 4, contentType = 3, message = {key = "BossBattle_fail_chatSystemMessage", param = {getlocal("BossBattle_name")}}, ts = base.serverTime, paramTab = paramTab}
                            chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                        end
                    end
                end
                socketHelper:BossBattleInfo(onRequestEnd)
            end
        end
    end
end

function BossBattleVoApi:attakcCallback(data)
    
    if data then
        local params = {}
        local uid = playerVoApi:getUid()
        if data.boss then
            local bossData = data.boss
            local damage = 0
            if bossData[3] then
                damage = (bossData[3])
            end
            if damage >= 0 then
                params.damage = damage
                chatVoApi:sendUpdateMessage(15, params)
            end
        end
        self:onRefreshData(data)
        -- if self.tv then
        --   self.tv:reloadData()
        -- end
        local destoryPaotou = self:getDestoryPaotouByHP((data.boss[2] - data.boss[3]), data.boss[5]) or {}
        if destoryPaotou and type(destoryPaotou) == "table" and SizeOfTable(destoryPaotou) > 0 then
            local isKill = false
            for k, v in pairs(destoryPaotou) do
                if bossCfg.paotou[v] == 6 then
                    isKill = true
                else
                    local paramTab = {}
                    paramTab.functionStr = "boss"
                    paramTab.addStr = "go_attack"
                    local message = {key = "BossBattle_destory_chatSystemMessage", param = {playerVoApi:getPlayerName(), getlocal("BossBattle_name")}}
                    chatVoApi:sendSystemMessage(message, paramTab)
                    local params = {key = "BossBattle_destory_chatSystemMessage", param = {{playerVoApi:getPlayerName(), 1}, {"BossBattle_name", 2}}}
                    chatVoApi:sendUpdateMessage(41, params)
                end
            end
            if isKill == true then
                local paramTab = {}
                paramTab.functionStr = "boss"
                paramTab.addStr = "go_attack"
                local message = {key = "BossBattle_kill_chatSystemMessage", param = {playerVoApi:getPlayerName(), getlocal("BossBattle_name")}}
                chatVoApi:sendSystemMessage(message, paramTab)
                local params = {key = "BossBattle_kill_chatSystemMessage", param = {{playerVoApi:getPlayerName(), 1}, {"BossBattle_name", 2}}}
                chatVoApi:sendUpdateMessage(41, params)
                
            end
        end
    end
end

function BossBattleVoApi:clear()
    self.flag = nil
    self.rankList = nil
    self.bossKiller = nil
    self.isChatTip = nil
    self:setAttackSelf(0)
    self.isInDialog = false
end
