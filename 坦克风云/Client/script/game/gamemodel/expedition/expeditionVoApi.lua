expeditionVoApi = {
    userInfo = {},
    reportList = {},
    flag = -1,
    maxNum = 10,
    shopInfo = {},
}

function expeditionVoApi:clear()
    self:clearUserInfo()
    self:clearReport()
    self:clearShop()
end

function expeditionVoApi:clearUserInfo()
    self.userInfo = {}
end

function expeditionVoApi:clearShop()
    self.shopInfo = {}
end

function expeditionVoApi:initShop(tb, rt)
    self:clearShop()
    if tb ~= nil then
        self.shopInfo = tb
        if rt then
            self.userInfo.rt = rt
        end
    end
end

function expeditionVoApi:getShop()
    return self.shopInfo
end

function expeditionVoApi:initVo(tb)
    self:clearUserInfo()
    if tb ~= nil then
        if tb.info then
            if tb.info.user then
                self.userInfo.atkName = tb.info.user[1]
                self.userInfo.atkPhoto = tb.info.user[2]
                self.userInfo.atkLv = tb.info.user[3]
                self.userInfo.atkPower = tb.info.user[4]
                self.userInfo.uid = tb.info.user[5]
                self.userInfo.troopsNum = tb.info.user[6]
                self.userInfo.aName = tb.info.user[7]
            end
            self.userInfo.atkTroops = tb.info.at
            self.userInfo.atkHero = tb.info.ah
            self.userInfo.atkHeroStr = tb.info.ahf --将领数据串，里面也包含将领副官的数据
            self.userInfo.atkAITroops = tb.info.ai --AI部队
            self.userInfo.atkTankSkinTb = tb.info.as --部队皮肤数据
            self.userInfo.deadTank = tb.info.dt
            self.userInfo.deadHero = tb.info.dh
            self.userInfo.deadAITroops = tb.info.dai --死亡的AI部队
            self.userInfo.killTank = tb.info.kt
            self.userInfo.reward = tb.info.r
            self.userInfo.grade = tb.info.grade
            self.userInfo.buy = tb.info.buy
            self.userInfo.win = tb.info.win
        end
        self.userInfo.eid = tb.eid
        self.userInfo.reset = tb.reset
        self.userInfo.point = tb.point
        self.userInfo.revive = tb.revive or {0, 0} --复活将领的数据，{复活次数，最近一次复活时间}
        self.userInfo.stage = tb.stage --远征军宝箱
        self.userInfo.failnum = tb.failnum --远征军连续失败次数
        eventDispatcher:dispatchEvent("expedition.reviveRefresh", {})
        --新版扫荡可以扫到第几关
        self.userInfo.raidgrade = 0
        if tb.info.raidgrade then
            self.userInfo.raidgrade = tb.info.raidgrade
        end
        --self.userInfo.rt=tb.info.rt
        -- 先清空阵亡的军徽
        emblemVoApi:clearEquipCanNotUse(11)
        -- 初始化远征军已经死亡的军徽
        if tb.info.dse and type(tb.info.dse) == "table" then
            for k, v in pairs(tb.info.dse) do
                emblemVoApi:setEquipCanNotUse(11, k, v)
            end
        end
        -- 先清空阵亡的飞机
        planeVoApi:clearEquipCanNotUse(11)
        -- 初始化远征军已经死亡的飞机
        if tb.info.dpe and type(tb.info.dpe) == "table" then
            planeVoApi:setEquipCanNotUse(11, tb.info.dpe)
        end
        
        --设置远征军阵亡飞艇
        airShipVoApi:setAirshipCanNotUse(11, {})
        if tb.info.dap then
            airShipVoApi:setAirshipCanNotUse(11, tb.info.dap)
        end
        
        -- 累计次数，用于判断扫荡  新加
        self.userInfo.acount = tb.acount or 0
        
        if self.userInfo.reward == nil then
            self.userInfo.reward = {}
        end
        if self.userInfo.deadHero == nil then
            self.userInfo.deadHero = {}
        end
        if self.userInfo.deadAITroops == nil then
            self.userInfo.deadAITroops = {}
        end
        if self.userInfo.deadTank == nil then
            self.userInfo.deadTank = {}
        end
        if self.userInfo.atkHero == nil then
            self.userInfo.atkHero = {}
        end
        if self.userInfo.buy == nil then
            self.userInfo.buy = {}
        end
        
        if self.userInfo.win == nil then
            self.userInfo.win = false
        end
        
    end
    
end

function expeditionVoApi:getRewardPoint(eid)
    local cfg = expeditionCfg.reward
    local point = 0
    local ee = eid
    local addreward = cfg['s'..ee]
    if addreward.point ~= nil then
        
        if addreward.rate.p ~= nil and addreward.rate.p > 0 then
            point = addreward.point + math.floor((math.pow(self:getGrade(), 0.8) * addreward.rate.p))
        else
            point = addreward.point
        end
        
    end
    return point
end

function expeditionVoApi:getRefreshTime()
    return self.userInfo.rt or 0
end

function expeditionVoApi:getRefreshTimeStr()
    local time = self:getRefreshTime()
    local timeStr
    if G_isGlobalServer() == true then
        timeStr = G_getCDTimeStr(time)
    else
        timeStr = G_getDataTimeStr(time)
    end
    return timeStr
end

function expeditionVoApi:getTroopsNum()
    return self.userInfo.troopsNum
end

function expeditionVoApi:getAname()
    return self.userInfo.aName
end

function expeditionVoApi:getApic()
    local uid = self:getUid()
    if tonumber(uid) == 0 then
        return 1
    end
    return self.userInfo.atkPhoto
end

function expeditionVoApi:getWin()
    return self.userInfo.win
end

function expeditionVoApi:setPoint(point)
    self.userInfo.point = point
end

function expeditionVoApi:addBuy(id)
    table.insert(self.userInfo.buy, id)
end

function expeditionVoApi:isSoldOut(id)
    local isSoldOut = false
    for k, v in pairs(self.userInfo.buy) do
        if v == id then
            isSoldOut = true
            break
        end
    end
    return isSoldOut
end
-- 远征积分
function expeditionVoApi:getPoint()
    if self.userInfo and self.userInfo.point then
        return self.userInfo.point or 0
    end
    return 0
end

-- 活动等给远征积分（相当于道具）
function expeditionVoApi:addPoint(addPoint)
    local point = self.userInfo.point or 0
    self.userInfo.point = point + addPoint
end

function expeditionVoApi:getGrade()
    return self.userInfo.grade
end
function expeditionVoApi:getDeadHero()
    return self.userInfo.deadHero
end

function expeditionVoApi:getDeadAITroops()
    return self.userInfo.deadAITroops
end

function expeditionVoApi:getDeadTank()
    local tb1 = {}
    for k, v in pairs(tankVoApi:getAllTanks()) do
        local tb2 = {}
        tb2.id = "a"..k
        
        local leftNum = 0
        local tnum = v[1]
        local deadNum = 0
        if self.userInfo.deadTank[tb2.id] ~= nil then
            deadNum = self.userInfo.deadTank[tb2.id]
        end
        tb2.num = deadNum
        
        if tnum ~= nil then
            leftNum = tnum - deadNum
            if leftNum <= 0 then
                leftNum = 0
            end
        end
        tb2.leftNum = leftNum
        tb2.power = tonumber(tankCfg[k].fighting)
        table.insert(tb1, tb2)
        
    end
    
    table.sort(tb1, function(a, b) return tonumber(a.power) > tonumber(b.power) end)
    
    -- for k,v in pairs(self.userInfo.deadTank) do
    -- local tb2 = {}
    -- tb2.id=k
    -- tb2.num=v
    -- local leftNum =0
    -- local tnum=tankVoApi:getAllTanks()[tonumber(RemoveFirstChar(k))]
    -- if tnum~=nil then
    -- leftNum = tnum[1]-v
    -- if leftNum<=0 then
    --    leftNum=0
    -- end
    -- end
    -- tb2.leftNum=leftNum
    -- table.insert( tb1, tb2 )
    -- end
    
    return tb1, self.userInfo.deadTank
end

function expeditionVoApi:getExpeditionVo()
    return self.userInfo
end

function expeditionVoApi:getEid()
    return self.userInfo.eid
    
end

function expeditionVoApi:getUid()
    return self.userInfo.uid
end

function expeditionVoApi:getName()
    return self.userInfo.atkName
end

function expeditionVoApi:getLevel()
    return self.userInfo.atkLv
end

function expeditionVoApi:getPower()
    return FormatNumber(self.userInfo.atkPower)
end

function expeditionVoApi:getTroops()
    local ktb = self.userInfo.killTank
    local atb = G_clone(self.userInfo.atkTroops)
    if ktb ~= nil then
        for k, v in pairs(atb) do
            if v[2] ~= nil and ktb[k] ~= nil then
                v[2] = v[2] - ktb[k]
            end
        end
    end
    return atb
end

--获取部队坦克皮肤数据
function expeditionVoApi:getTroopsSkinTb()
    return self.userInfo.atkTankSkinTb or {}
end

function expeditionVoApi:getAtkHeroTb()
    return self.userInfo.atkHero
end

--获取目标部队将领数据，格式为以"-"分隔的字符串
function expeditionVoApi:getAtkHeroStrTb()
    if self.userInfo and self.userInfo.atkHeroStr then
        return self.userInfo.atkHeroStr[1] or {}
    end
    return {}
end

function expeditionVoApi:getAtkAITroopsTb()
    return self.userInfo.atkAITroops or {}
end

function expeditionVoApi:getShowTank()
    local aid = nil
    for k, v in pairs(self.userInfo.atkTroops) do
        if v[2] ~= nil then
            aid = v[1]
            break
        end
    end
    local skinList = self:getTroopsSkinTb()
    local skinId = skinList[tankSkinVoApi:convertTankId(aid)]
    local sp = G_getTankPic(tonumber(RemoveFirstChar(aid)), nil, nil, nil, skinId, false)
    return sp
end

function expeditionVoApi:reward(id)
    table.insert(self.userInfo.reward, id)
end

function expeditionVoApi:isHaveLeftTanks()
    local isHave = false
    for k, v in pairs(self:getDeadTank()) do
        if v.leftNum > 0 then
            isHave = true
            break
        end
    end
    return isHave
end

function expeditionVoApi:isAllReward()
    local isAll = true
    if expeditionVoApi:getEid() > 1 then
        for i = 1, expeditionVoApi:getEid() - 1 do
            if self:isReward(i) == false then
                isAll = false
            end
        end
    end
    return isAll
end

function expeditionVoApi:isReward(id)
    local isReward = false
    for k, v in pairs(self.userInfo.reward) do
        if v == id then
            isReward = true
            break
        end
    end
    return isReward
end

function expeditionVoApi:getHeroTb()
    local heroTb = G_clone(heroVoApi:getHeroList())
    
    if SizeOfTable(self.userInfo.deadHero) == 0 then
        for k, v in pairs(heroTb) do
            if heroVoApi:isInQueueByHid(v.hid) then
                v.isDead = 2
            else
                v.isDead = 3
            end
        end
    end
    
    for k, v in pairs(self.userInfo.deadHero) do
        for i, j in pairs(heroTb) do
            if j.hid == v then
                j.isDead = 1
                
            end
        end
    end
    for k, v in pairs(heroTb) do
        if v.isDead ~= 1 then
            if heroVoApi:isInQueueByHid(v.hid) then
                v.isDead = 2
                
            else
                v.isDead = 3
                
            end
        end
    end
    -- for k,v in pairs(heroTb) do
    -- print("heroTb=",k,v,v.isDead)
    -- end
    table.sort(heroTb, function(a, b) return tonumber(a.isDead) > tonumber(b.isDead) end)
    
    return heroTb
end

function expeditionVoApi:getLeftNum()
    local tNum = expeditionCfg.resetNum[playerVoApi:getVipLevel() + 1]
    if not self.userInfo.reset then
        return 0
    end
    local num = self.userInfo.reset
    local rNum = tNum - num
    return rNum
end

-------------------以下远征战报-----------------------
function expeditionVoApi:clearReport()
    self:deleteAll()
    self.flag = -1
end
function expeditionVoApi:deleteAll()
    if self.reportList ~= nil then
        for k, v in pairs(self.reportList) do
            v = nil
        end
        self.reportList = nil
    end
    self.reportList = {}
end

function expeditionVoApi:getMaxNum()
    return self.maxNum
end

function expeditionVoApi:getFlag()
    return self.flag
end
function expeditionVoApi:setFlag(flag)
    self.flag = flag
end

function expeditionVoApi:getReportList()
    if self.reportList == nil then
        self.reportList = {}
    end
    return self.reportList
end

function expeditionVoApi:getNum()
    local num = 0
    local list = self:getReportList()
    if list then
        num = SizeOfTable(list)
    end
    return num
end

function expeditionVoApi:getReport(rid)
    local list = self:getReportList()
    if list then
        for k, v in pairs(list) do
            if v.rid == rid then
                return v
            end
        end
    end
    return nil
end

function expeditionVoApi:addReport(data, isRead)
    if data then
        for k, v in pairs(data) do
            local rid = tonumber(v.id)
            local uid = playerVoApi:getUid()
            local name = playerVoApi:getPlayerName()
            local enemyId = tonumber(v.receiver) or 0
            local enemyName = v.dfname or ""
            local enemyLevel = v.dlvl or 1
            local time = tonumber(v.update_at) or 0
            local isVictory = tonumber(v.isvictory) or 0
            local place = tonumber(v.eid)
            
            local lostShip, attInfo, defInfo, report, accessory, hero, emblemID, plane, airShipInfo
            local weapon = nil --超级武器{进攻方，防守方}
            local armor = nil --装甲矩阵{进攻方，防守方}
            local troops = nil --敌我双方部队信息
            local aitroops = nil --敌我双方的AI部队信息
            local extraReportInfo = nil --敌我双方新增功能数据
            if v.content then
                lostShip = {
                    attackerLost = {},
                    defenderLost = {},
                    attackerTotal = {},
                defenderTotal = {}}
                report = {}
                accessory = {}
                hero = {{{}, 0}, {{}, 0}}
                emblemID = {0, 0}
                if v.content.lostShip then
                    local lostShipTab = v.content.lostShip
                    --战斗损失
                    
                    if lostShipTab then
                        local attackerLost = lostShipTab.attacker
                        local defenderLost = lostShipTab.defenser
                        if attackerLost then
                            lostShip.attackerLost = FormatItem({o = attackerLost}, false)
                        end
                        if defenderLost then
                            lostShip.defenderLost = FormatItem({o = defenderLost}, false)
                        end
                    end
                end
                if v.content.tank then
                    local tankTotal = v.content.tank
                    if tankTotal then
                        local attackerTotal = tankTotal.a
                        local defenderTotal = tankTotal.d
                        if attackerTotal then
                            lostShip.attackerTotal = FormatItem({o = attackerTotal}, false)
                        end
                        if defenderTotal then
                            lostShip.defenderTotal = FormatItem({o = defenderTotal}, false)
                        end
                    end
                end
                if v.content.attInfo then
                    attInfo = v.content.attInfo
                end
                if v.content.defInfo then
                    defInfo = v.content.defInfo
                end
                if v.content.report and type(v.content.report) == "table" then
                    report = v.content.report
                end
                if v.content.aey and type(v.content.aey) == "table" then
                    accessory = v.content.aey
                end
                if v.content.hh and type(v.content.hh) == "table" then
                    hero = v.content.hh
                end
                if v.content.se and type(v.content.se) == "table" then
                    emblemID = v.content.se
                end
                if v.content.plane and type(v.content.plane) == "table" then
                    plane = v.content.plane
                end
                if v.content.weapon then
                    weapon = v.content.weapon
                end
                if v.content.armor then
                    armor = v.content.armor
                end
                if v.content.troops then
                    troops = v.content.troops
                end
                if v.content.ait then
                    aitroops = v.content.ait
                end
                if v.content.ri then
                    extraReportInfo = v.content.ri
                end
                if v.content.ap then
                    airShipInfo = v.content.ap
                end
            end
            local vo
            if isRead ~= true then --初始化战报列表时需要new出来
                vo = expeditionReportVo:new()
                table.insert(self.reportList, vo)
            else
                vo = self:getReport(rid)
            end
            if vo then
                vo:initWithData(rid, tonumber(v.type), uid, name, enemyId, enemyName, enemyLevel, time, isVictory, report, lostShip, accessory, hero, place, emblemID, plane, attInfo, defInfo, weapon, armor, troops, isRead, aitroops, extraReportInfo, airShipInfo)
            end
        end
        
        if isRead ~= true then
            if self.reportList and SizeOfTable(self.reportList) > 0 then
                local function sortAsc(a, b)
                    if a and b and a.time and b.time then
                        return a.time > b.time
                    end
                end
                table.sort(self.reportList, sortAsc)
            end
            
            local maxNum = expeditionVoApi:getMaxNum()
            while expeditionVoApi:getNum() > maxNum do
                print("self.reportList[expeditionVoApi:getNum()].rid", self.reportList[expeditionVoApi:getNum()].rid)
                table.remove(self.reportList, expeditionVoApi:getNum())
            end
        end
    end
end

--读取战报
function expeditionVoApi:readReport(rid, callback)
    local function readCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data.expeditionlog then
                self:addReport({sData.data.expeditionlog}, true)
                if callback then
                    local reportVo = self:getReport(rid)
                    callback(reportVo)
                end
            end
        end
    end
    socketHelper:expeditionReadReport(rid, readCallBack)
end

function expeditionVoApi:deleteReport(rid)
    if self.reportList then
        for k, v in pairs(self.reportList) do
            if v.rid == rid then
                table.remove(self.reportList, k)
            end
        end
    end
end

function expeditionVoApi:setIsRead(rid)
    if self.reportList then
        for k, v in pairs(self.reportList) do
            if tostring(rid) == tostring(v.rid) then
                if v.isRead == 0 then
                    v.isRead = 1
                end
            end
        end
    end
end

function expeditionVoApi:isShowAccessory()
    if base.ifAccessoryOpen == 1 then
        return true
    end
    return false
end

function expeditionVoApi:isShowHero()
    if base.heroSwitch == 1 then
        return true
    end
    return false
end
--是否在邮件面板显示军徽信息
function expeditionVoApi:isShowEmblem(report)
    -- print("report.emblemID",report.emblemID,report.emblemID[1],report.emblemID[2])
    if base.emblemSwitch == 1 and report.emblemID ~= nil and SizeOfTable(report.emblemID) > 0 and ((report.emblemID[1] ~= 0 and report.emblemID[1] ~= nil) or (report.emblemID[2] ~= 0 and report.emblemID[2] ~= nil)) then
        return true
    end
    return false
end
-------------------以上远征战报-----------------------

-- 新加 (远征新加 扫荡 商店手动刷新)
function expeditionVoApi:getAcount()
    return self.userInfo.acount
end

function expeditionVoApi:setAcount(acount)
    self.userInfo.acount = acount
end

function expeditionVoApi:setBuy(buy)
    self.userInfo.buy = buy or {}
end

function expeditionVoApi:initRfcAdnRft(rfc, rft)
    self.userInfo.rfc = rfc
    self.userInfo.rft = rft
end

function expeditionVoApi:getRft()
    return self.userInfo.rft
end

function expeditionVoApi:getRfc()
    return self.userInfo.rfc
end

function expeditionVoApi:getRefreshCost()
    local count = self:getRfc() or 0
    local num = count + 1
    local cost = 0
    
    local refreshCost = expeditionCfg.refreshCost or {}
    if num >= #refreshCost then
        cost = refreshCost[#refreshCost]
    else
        cost = refreshCost[num]
    end
    return cost
end

-- 自动刷新
function expeditionVoApi:isToday()
    local isToday = true
    if self.userInfo and self.userInfo.rt and base.serverTime > self.userInfo.rt then
        isToday = false
    end
    return isToday
end

function expeditionVoApi:getChallengeNum()
    return SizeOfTable(expeditionCfg.challenge)
end

function expeditionVoApi:getRaidgrade()
    return self.userInfo.raidgrade
end

function expeditionVoApi:isShowNewRaidBtn()
    if base.ea == 1 then
        local acount = self:getAcount() or 0
        if self:getWin() or acount < expeditionCfg.acount then
            local eid = self:getEid()
            local raidIndex = self:getRaidgrade()
            if eid and raidIndex and eid < raidIndex then
                return true, raidIndex
            end
        else
            return false
        end
    end
    return false
end

function expeditionVoApi:showExpeditionDialog(layerNum)
    local function callback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            require "luascript/script/game/scene/gamedialog/expedition/expeditionDialog"
            local vrd = expeditionDialog:new()
            local vd = vrd:init(layerNum)
        end
    end
    socketHelper:expeditionGet(callback)
end

--判断有没有远征奖励可以领取
function expeditionVoApi:canReward()
    if base.heroSwitch == 1 and base.expeditionSwitch == 1 and self.userInfo then
        if base.expeditionOpenLv <= playerVoApi:getPlayerLevel() then
            if self.userInfo.win ~= nil and self.userInfo.eid and self.userInfo.reward then
                local challengeNum = self:getChallengeNum()
                local num = self:getEid() - 1
                if self:getWin() then
                    num = challengeNum
                end
                for i = 1, num do
                    local rewardFlag = self:isReward(i)
                    if rewardFlag == false then
                        return true
                    end
                end
            end
        end
    end
    local boxNum = expeditionVoApi:boxCfg()
    for i = 1, boxNum do
        local boxState = expeditionVoApi:ifCanReward(i)
        if boxState == 2 then
            return true
        end
    end
    return false
end

--初始化远征部分数据
function expeditionVoApi:formatPartData(data)
    self.userInfo.eid = data.eid or 0
    if data.info then
        self.userInfo.reward = data.info.r
        self.userInfo.win = data.info.win
    end
    if self.userInfo.reward == nil then
        self.userInfo.reward = {}
    end
    if self.userInfo.win == nil then
        self.userInfo.win = false
    end
end

--获取复活将领的消耗
function expeditionVoApi:getReviveCost()
    local rnum = self:getReviveNum()
    if rnum == 0 then --第一次免费
        return 0
    end
    return expeditionCfg.reviveCost
end

--获取今日复活次数
function expeditionVoApi:getReviveNum()
    local rts = self.userInfo.revive[2]
    if rts and G_isToday(rts) == false then
        self.userInfo.revive[1] = 0
    end
    return self.userInfo.revive[1] or 0
end

--获取今日剩余复活次数
function expeditionVoApi:getLeftReviveNum()
    local rnum = self:getReviveNum()
    local leftNum = expeditionCfg.reviveCount - rnum
    if leftNum < 0 then
        leftNum = 0
    end
    return leftNum
end

--1：可以复活，2：复活次数已达上限，3：没有达到可以复活的关卡数 4：没有阵亡的将领
--isPopRevive 战斗结束后是否检测弹出复活页面
function expeditionVoApi:isCanRevive()
    if (self.userInfo.eid == nil) or (self.userInfo.eid < expeditionCfg.startRevive) then --从startRevive开始才可以复活将领
        return 3
    end
    local num = self:getReviveNum()
    if num >= expeditionCfg.reviveCount then
        return 2, expeditionCfg.reviveCount
    end
    local dhero = self:getDeadHero() or {}
    if SizeOfTable(dhero) == 0 then --没有阵亡的将领
        return 4
    end
    return 1
end

function expeditionVoApi:showReviveHeroDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/expedition/reviveHeroSmallDialog"
    reviveHeroSmallDialog:showReviveHeroView(layerNum)
end

function expeditionVoApi:reviveHero(callback)
    local cost = expeditionVoApi:getReviveCost()
    local function reviveCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.expedition then --更新远征数据
                expeditionVoApi:initVo(sData.data.expedition)
            end
            playerVoApi:setGems(playerVoApi:getGems() - cost) --扣除金币
            if callback then
                callback()
            end
        end
    end
    socketHelper:expeditionReviveHero(reviveCallBack)
end

function expeditionVoApi:boxStage(idx)
    local boxStage = expeditionCfg.stage[idx]
    return boxStage
end

--传参是该宝箱奖励配置，不传参是宝箱个数
function expeditionVoApi:boxCfg(idx)
    local boxCfg = expeditionCfg.stageReward
    if idx then
        local boxReward = boxCfg[idx]
        return boxReward
    else
        local boxNumCfg = 0
        for k, v in pairs(boxCfg) do
            boxNumCfg = boxNumCfg + 1
        end
        return boxNumCfg
    end
end

--远征宝箱数据-- 胜利次数
function expeditionVoApi:getVictoryNum()
    local victoryNum = 0
    if self.userInfo and self.userInfo.stage then
        if self.userInfo.stage[3] then
        else
            self.userInfo.stage[3] = base.serverTime
        end
        if G_getWeeTs(base.serverTime) ~= G_getWeeTs(self.userInfo.stage[3]) then--就表示跨天了，需要重置数据
            self.userInfo.stage[1] = 0
        end
        victoryNum = self.userInfo.stage[1] or 0
    end
    return victoryNum
end

--远征宝箱数据-- 领取状态:  1:不可领取  2：可领取  3：已领取
function expeditionVoApi:ifCanReward(idx)
    if self.userInfo and self.userInfo.stage then
        if self.userInfo.stage[3] then
        else
            self.userInfo.stage[3] = base.serverTime
        end
        if G_getWeeTs(base.serverTime) ~= G_getWeeTs(self.userInfo.stage[3]) then--就表示跨天了，需要重置数据
            self.userInfo.stage[2] = nil
        end
        local tb = self.userInfo.stage[2] -- 领取状态
        local victoryNum = self:getVictoryNum()
        local boxStage = self:boxStage(idx)
        if victoryNum < boxStage then
            return 1
        else
            if tb and tb ~= nil then
                for k, v in pairs(tb) do
                    if v == boxStage then
                        return 3
                    end
                end
                return 2
            else
                return 2
            end
        end
    end
    return 1
end

--进度条能量几段
function expeditionVoApi:expeditionSchedule()
    local boxNum = self:boxCfg()
    local victoryNum = self:getVictoryNum()
    local startNum = self:boxStage(1)
    local endNum = self:boxStage(boxNum)
    if victoryNum < startNum then
        victoryNum = startNum
    end
    if victoryNum > endNum then
        victoryNum = endNum
    end
    local showNum = victoryNum - startNum
    local totalNum = endNum - startNum
    local heightScale = showNum / totalNum
    return heightScale
end

function expeditionVoApi:socketExpedition(sid, showTb, refreshfun)
    local function callBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.expedition then --更新远征数据
                expeditionVoApi:initVo(sData.data.expedition)
            end
            local reward = {}
            for k, v in pairs(showTb) do
                table.insert(reward, v)
                if v.type == "h" then
                    heroVoApi:addSoul(v.key, v.num)
                elseif v.type == "n" then
                    
                else
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                end
            end
            if refreshfun then
                refreshfun(reward)
            end
        end
    end
    socketHelper:expeditionBox(sid, callBack)
end

function expeditionVoApi:getFailNum(...)
    local failnum = 0
    if self.userInfo and self.userInfo.failnum then
        failnum = self.userInfo.failnum
    end
    return failnum
end

function expeditionVoApi:getFailTimeCfg(...)
    local failTime = expeditionCfg.failTime
    return failTime
end

function expeditionVoApi:getGradeDown(...)
    local gradeDown = expeditionCfg.gradeDown
    return gradeDown
end
