championshipWarVoApi = {
    battleInfo = nil, --军团战对战信息
    stateRoundTb = {[21] = 1, [22] = 2, [23] = 3, [24] = 4, [30] = 5}, --军团战状态对应的轮次
    applyFlag = false, --是否报名过军团战的标识
    rankList = nil, --军团排行
    reportList = nil, --战报详情列表
    serverhost = nil, --获取战报的域名
    tinfoErr = false, --玩家部队信息数据串超长了，用这个字段判断是不是超长
}

function championshipWarVoApi:getWarCfg()
    local chamWarCfg = G_requireLua("config/gameconfig/championshipsWar")
    if self:isTestServer() == true then --为了方便测试，测试服军团参战人数改为1
        chamWarCfg.allianceJoinNum = 1
    end
    return chamWarCfg
end

--系统是否开启 1：开启，0：开关未开，-1：等级不够,-2：没有加入军团
function championshipWarVoApi:isOpen()
    if base.championshipWarSwitch == 0 then
        return 0
    end
    local playerLv = playerVoApi:getPlayerLevel()
    local warCfg = self:getWarCfg()
    if playerLv < warCfg.openLevel then
        return - 1, warCfg.openLevel
    end
    local myAlliance = allianceVoApi:getSelfAlliance()
    if myAlliance == nil then
        return - 2
    end
    return 1
end

--赛季相关数据
function championshipWarVoApi:setChampionshipWarSeasonInfo(info)
    self.seasonInfo = info
end

--判断是否更换过军团（如果当前所处军团与自己当初报名军团战的军团不一样，则不能参加军团锦标赛）
function championshipWarVoApi:sameBattleAllianceOrNot()
    local myAlliance = allianceVoApi:getSelfAlliance()
    if self.warAid == nil then
        return true
    elseif myAlliance and tonumber(myAlliance.aid) == tonumber(self.warAid) then --参战军团跟当前军团是一个军团
        return true
    end
    return false
end

--获取当前军团锦标赛当前赛季
function championshipWarVoApi:getWarSeason()
    if self.seasonInfo and self.seasonInfo.season then
        return self.seasonInfo.season
    end
    return 1
end

--获取军团锦标赛当前状态
--return
-- -1：数据异常了
--10：个人战和军团战报名时期
--20：军团战匹配对阵列表时期
--21：军团战16进8结算期
--22：8进4结算期
--23：4进2结算期
--24：2进1结算期
--30：领奖时间
--40：锦标赛休息期（此阶段不可进入锦标赛功能）
function championshipWarVoApi:getWarState()
    local warCfg = self:getWarCfg()
    local seasonInfo = self.seasonInfo
    if seasonInfo and seasonInfo.st and seasonInfo.nextst then
        if base.serverTime >= seasonInfo.nextst then
            seasonInfo.st = seasonInfo.nextst
            seasonInfo.nextst = seasonInfo.nextst + warCfg.durationTime * 86400
        end
        local personalWarEt = seasonInfo.st + warCfg.standTime --个人战结束时间
        local allianceWarEt = personalWarEt + warCfg.settlementTime
        local warEt = seasonInfo.st + warCfg.warCycle
        if base.serverTime >= seasonInfo.st and base.serverTime < personalWarEt then
            return 10, personalWarEt - base.serverTime
        elseif base.serverTime <= allianceWarEt then
            if base.serverTime <= (personalWarEt + 5 * 60) then --给后台10分钟的生成对阵列表的时间
                return 20, warEt - base.serverTime
            end
            local stateTb = {21, 22, 23, 24}
            local totalTime, settlementTime = 0, 0
            for k, dt in pairs(warCfg.warStageDurationTime) do
                totalTime = totalTime + dt
                settlementTime = personalWarEt + totalTime
                if base.serverTime <= settlementTime then
                    return stateTb[k], settlementTime - base.serverTime
                end
            end
            return 30, warEt - base.serverTime
        elseif base.serverTime <= warEt then
            return 30, warEt - base.serverTime
        else
            return 40, seasonInfo.nextst - base.serverTime
        end
    end
    return - 1
end

--是否可以报名设置军团战部队
--return
--1：可以设置
--0：不在个人战期间
-- -1：设置太频繁（1分钟cd时间）
function championshipWarVoApi:isCanSetTroop()
    local state = self:getWarState()
    if state ~= 10 then --只有个人战期间才能报名军团战
        return 0
    end
    if self.allianceWarTroopTs and base.serverTime - self.allianceWarTroopTs < 60 then
        return - 1
    end
    return 1
end

--设置要攻击关卡的难度id
function championshipWarVoApi:setAttackCheckpointDiffId(diffId)
    self.diffId = diffId
end
--获取个人战当前攻击关卡的坦克部队
function championshipWarVoApi:getAttackCheckpointEnemyTanks(diffId)
    local idx = diffId or self.diffId
    local tankTb = {{}, {}, {}, {}, {}, {}}
    if self.troops and self.troops[idx] then
        tankTb = self.troops[idx]
    end
    return tankTb
end

--获取对应难度部队带兵量
function championshipWarVoApi:getAttackCheckpointEnemyTroopNum(diffId)
    local tankTb = self:getAttackCheckpointEnemyTanks(diffId)
    local troopNum, tankNum = 0, 0
    for k, v in pairs(tankTb) do
        local tankId = v[1]
        if tankId then
            tankId = tonumber(RemoveFirstChar(tankId))
        end
        if tankId and tankId ~= 0 then
            troopNum = troopNum + 1
            tankNum = tankNum + tonumber(v[2])
        end
    end
    if troopNum == 0 then
        return 0
    end
    return tankNum / troopNum
end

--判断个人战攻击关卡部队相应位置有没有坦克（如果敌方该位置没有坦克，则我方对应位置不能设置坦克和将领）
function championshipWarVoApi:isHasTankByPosIdx(posIdx)
    local tankTb = self:getAttackCheckpointEnemyTanks()
    if tankTb and tankTb[posIdx] then
        local tankId, num = tankTb[posIdx][1], tankTb[posIdx][2]
        if tankId then
            tankId = tonumber(RemoveFirstChar(tankId))
        end
        if tankId and tankId ~= 0 and num and num > 0 then
            return true
        end
    end
    return false
end

function championshipWarVoApi:initData(data)
    local battleType = 39
    --先清空部队数据
    tankVoApi:clearTanksTbByType(battleType)
    tankSkinVoApi:clearTankSkinListByBattleType(battleType)
    heroVoApi:clearChampionshipWarHeroTb()
    emblemVoApi:setBattleEquip(battleType, nil)
    emblemVoApi:setTmpEquip(nil, battleType)
    planeVoApi:setBattleEquip(battleType, nil)
    planeVoApi:setTmpEquip(nil, battleType)
    airShipVoApi:setTempLineupId(nil, battleType)
    if data.tinfo then --军团战报名设置的部队信息
        if type(data.tinfo) == "string" then
            self.tinfoErr = true
        end
        self.allianceWarTroopTs = data.tinfo.ts
        if data.tinfo.troops then --坦克部队
            for k, v in pairs(data.tinfo.troops) do
                if v[1] and v[2] then
                    self.applyFlag = true --有数据说明报过名
                    tankVoApi:setTanksByType(39, k, tonumber(RemoveFirstChar(v[1])), v[2])
                end
            end
            if data.tinfo.skin then --坦克皮肤数据
                tankSkinVoApi:setTankSkinListByBattleType(battleType, data.tinfo.skin)
            end
        end
        if data.tinfo.hero then --将领
            heroVoApi:setChampionshipWarHeroTb(data.tinfo.hero)
        end
        if data.tinfo.aitroops then --AI部队
            AITroopsFleetVoApi:setChampionshipWarAITroopsTb(data.tinfo.aitroops)
        end
        if data.tinfo.equip then --军徽
            emblemVoApi:setTmpEquip(data.tinfo.equip, battleType)
            emblemVoApi:setBattleEquip(battleType, data.tinfo.equip)
        end
        if data.tinfo.plane then --飞机
            planeVoApi:setTmpEquip(data.tinfo.plane, battleType)
            planeVoApi:setBattleEquip(battleType, data.tinfo.plane)
        end
        if data.tinfo.ap then --飞艇
            airShipVoApi:setTempLineupId(data.tinfo.ap, battleType)
            airShipVoApi:setBattleEquip(battleType, data.tinfo.ap)
        end
    end
    if data.stars then --个人战各个关卡的得星情况
        self.checkpointStars = data.stars
    end
    if data.info then --个人战当前攻击关卡三个难度对应的部队数据
        self.troops, self.plane, self.airship = nil, nil, nil
        if data.info.troops then --坦克数据
            self.troops = data.info.troops
        end
        if data.info.plane then --飞机数据
            self.plane = data.info.plane
        end
        self.airship = data.info.ap or {}    
        if data.info.tid then --当前攻击的关卡id
            self.checkpointId = data.info.tid
        end
        self.endBattle = nil
        if data.info.endbattle then --是否战斗结束
            self.endBattle = data.info.endbattle
        end
        if data.info.attacknum then --个人战攻打的第几轮，没有默认是1
            self.attackNum = data.info.attacknum
        end
        self.buyData = data.info.buy --购买数据
        self.rd = data.info.rd or 0 --军团结算奖励领取标识
        
        --个人战每轮所消耗的星星数
        local cfg = self:getWarCfg()
        for i = 1, cfg.singleWarTimes do
            if self.costStars == nil then
                self.costStars = {}
            end
            if data.info["bs" .. i] then
                self.costStars[i] = data.info["bs" .. i]
            else
                self.costStars[i] = 0
            end
        end
        
    end
    if data.aid then --参战时所在军团
        self.warAid = data.aid
    end
    self.checkpointBuff, self.myBuff = nil, nil
    if data.buff then --玩家当前得到的buff
        if data.buff.checkbuff then --每三关选的buff列表
            self.checkpointBuff = data.buff.checkbuff
        end
        if data.buff.totalbuff then --当前已经加成的buff数据（三轮个人战斗所有的buff）
            --{attrRate=1,buff={{1,3}}} attrRate：每五关加成的属性次数，buff是攻打关卡已加成的属性列表，格式对应配置里的buffGroup
            self.myBuff = data.buff.totalbuff
        end
        if data.buff.troopsAdd then --购买的带兵量次数
            self.buyTroopsNum = data.buff.troopsAdd
        end
    end
    if self.myPoint and self.myPoint > 0 and data.point then
        self.oldMyPoint = self.myPoint
    end
    self.myPoint = data.point or 0 --个人当前积分
    self.myCoin = data.coin or 0 --联赛币
end

--初始化公共的数据
function championshipWarVoApi:initPublicData(data)
    if data.alliancestage then --军团总通关数
        self.allianceStageNum = data.alliancestage
    end
    if data.apply then --军团战报名人数
        self.apply = data.apply
    end
    if data.gradeinfo then
        self.grade = data.gradeinfo[1] or 1 --军团所处联赛阶层
        self.lastGrade = data.gradeinfo[2] or 1--历史联赛阶层
        self.rank = data.gradeinfo[3] or 0 --军团排行
        self.status = data.gradeinfo[4] or 0 --本赛季军团赛是否真正结算的标识(因为后端提前结算，结算后此标识为1)
    end
end

function championshipWarVoApi:updateData(data)
    if data.userchampion then
        self:initData(data.userchampion)
    end
    if data.otherchampion then
        self:initPublicData(data.otherchampion)
    end
end

function championshipWarVoApi:championshipWarGet(callback, waitingFlag)
    local function getHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                self:updateData(sData.data)
                if sData.data.championhost then
                    self.serverhost = sData.data.championhost
                end
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarGet(getHandler, waitingFlag)
end

--个人战攻击关卡设置部队页面
--diffId：关卡难易程度
function championshipWarVoApi:showPersonalWarTroopDialog(diffId, layerNum)
    G_requireLua("game/scene/gamedialog/championshipWar/championshipWarPersonalTroopDialog")
    local td = championshipWarPersonalTroopDialog:new(diffId)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("fleetCard"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--军团战个人设置部队页面
function championshipWarVoApi:showAllianceWarTroopDialog(layerNum)
    G_requireLua("game/scene/gamedialog/championshipWar/championshipWarAllianceTroopDialog")
    local td = championshipWarAllianceTroopDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("fleetCard"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function championshipWarVoApi:showMainDialog(layerNum)
    local function onCallback()
        if self:sameBattleAllianceOrNot() == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_change_allianceTip"), 30)
            do return end
        end
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarDialog"
        local td = championshipWarDialog:new(layerNum)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("championshipWar_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    self:championshipWarGet(onCallback)
end

function championshipWarVoApi:showPersonalDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarPersonalDialog"
    local td = championshipWarPersonalDialog:new(layerNum)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("championshipWar_personal_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function championshipWarVoApi:personalWarBattle(checkpointId, fleetinfo, hero, equip, plane, aitroops, airshipId, defender, callback, battleResultHandler)
    local function battleHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then --同步数据
                self:updateData(sData.data)
            end
            if sData.data.report then
                local nameStr = getlocal("championshipWar_checkpoint_numth", {checkpointId})
                if tonumber(defender) == 1 then
                    nameStr = nameStr..getlocal("championshipWar_personal_easy")
                elseif tonumber(defender) == 2 then
                    nameStr = nameStr..getlocal("championshipWar_personal_medium")
                else
                    nameStr = nameStr..getlocal("championshipWar_personal_difficulty")
                end
                sData.data.report.p[1][1] = nameStr
                local dataTb = {data = {report = sData.data.report}, battleType = 38, diffId = defender, troops = fleetinfo}
                dataTb.landform = {1, 1} --地形
                battleScene:initData(dataTb, battleResultHandler)
                if sData.data.report.r and type(sData.data.report.r) == "table" then
                    local rewardlist = FormatItem(sData.data.report.r)
                    for k, v in pairs(rewardlist) do
                        G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                    end
                end
                if sData.data.report.r and sData.data.report.r ~= -1 then --战斗胜利
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and selfAlliance.aid then --军团全员同步军团通关数
                        local aid = selfAlliance.aid
                        local uid = playerVoApi:getUid()
                        local params = {uid = uid, stageNum = self:getAllianceStageNum()}
                        chatVoApi:sendUpdateMessage(57, params, aid + 1)
                    end
                end
            end
            if callback then
                callback()
            end
            eventDispatcher:dispatchEvent("championshipWarPersonalDialog.refreshUI")
        end
    end
    socketHelper:championshipWarPersonalBattle(fleetinfo, hero, equip, plane, aitroops, airshipId, defender, battleHandler)
end

--个人战结算页面
function championshipWarVoApi:showPersonalWarBattleResultDialog(isVictory, result, isWipe, layerNum, callback, parent)
    require "luascript/script/game/scene/gamedialog/championshipWar/personalWarBattleResultSmallDialog"
    personalWarBattleResultSmallDialog:showBattleResultDialog(isVictory, result, isWipe, layerNum, callback, parent)
end

function championshipWarVoApi:clear()
    self.oldMyPoint = nil
    self.seasonInfo = nil
    self.allianceWarTroopTs = nil
    self.checkpointStars = nil
    self.troops = nil
    self.plane = nil
    self.airship = nil
    self.checkpointId = nil
    self.endBattle = nil
    self.attackNum = nil
    self.buyData = nil
    self.rd = nil
    self.costStars = nil
    self.warAid = nil
    self.checkpointBuff = nil
    self.myBuff = nil
    self.buyTroopsNum = nil
    self.myPoint = nil
    self.myCoin = nil
    self.allianceStageNum = nil
    self.apply = nil
    self.grade = nil
    self.lastGrade = nil
    self.rank = nil
    self.status = nil
    self.battleInfo = nil
    self.applyFlag = false
    self.rankList = nil
    self.serverhost = nil
    self.reportList = nil
    self.tinfoErr = nil
end

--获取个人战当前攻打的关卡ID
function championshipWarVoApi:getCurrentCheckpointId()
    return self.checkpointId
end

--获取个人战当前攻打的关卡部队数据
function championshipWarVoApi:getCurrentCheckpointTroops()
    return self.troops
end

--获取个人战最佳成绩
function championshipWarVoApi:getBestScore()
    local bestScore = 0
    if self.checkpointStars then
        for k, v in pairs(self.checkpointStars) do
            local size = SizeOfTable(v)
            if bestScore < size then
                bestScore = size
            end
        end
    end
    return bestScore
end

--获取个人战本轮已获得的星星数
function championshipWarVoApi:getStarNum(attackNum)
    local starNum = 0
    local starsSize = 0
    if self.checkpointStars and attackNum then
        local stars = self.checkpointStars[attackNum]
        if stars then
            starsSize = SizeOfTable(stars)
            for k, v in pairs(stars) do
                starNum = starNum + v
            end
        end
    end
    return starNum, starsSize
end

--获取个人战某一轮共消耗的星星数
function championshipWarVoApi:getCostStarNum(attackNum)
    if self.costStars and attackNum then
        return self.costStars[attackNum]
    end
    return 0
end

--获取个人战攻打的次数，默认是1
function championshipWarVoApi:getAttackNum()
    if self.attackNum then
        return self.attackNum
    else
        return 1
    end
end

--获取个人战购买的带兵量次数
function championshipWarVoApi:getBuyTroopsNum()
    if self.buyTroopsNum then
        return self.buyTroopsNum
    end
    return 0
end

--获取可选择buff的数据
function championshipWarVoApi:getSelectBuffData()
    if self.checkpointBuff then
        local bData = nil
        local cfg = self:getWarCfg()
        for k, v in pairs(self.checkpointBuff) do
            local buffData = cfg.buffGroup[v[1]][v[2]]
            local buffTypeData = cfg["buffType" .. buffData.buff]["b"..buffData.buffId]
            local fleetNameMap = {[1] = getlocal("tanke"), [2] = getlocal("jianjiche"), [4] = getlocal("zixinghuopao"), [8] = getlocal("huojianche"), [15] = getlocal("believer_all_fleet")}
            local str = ""
            if buffData.buff == 1 then
                str = getlocal("championshipWar_personal_propertyDesc1", {fleetNameMap[buffTypeData[1]], fleetNameMap[buffTypeData[2]], (buffData.value * 100) .. "%%"})
            elseif buffData.buff == 2 then
                str = getlocal("championshipWar_personal_propertyDesc2", {fleetNameMap[buffTypeData[2]], fleetNameMap[buffTypeData[1]], (buffData.value * 100) .. "%%"})
            end
            if str ~= "" then
                local strColor = {nil, G_ColorYellow, nil, G_ColorYellow, G_ColorGreen, nil}
                str = {str, strColor}
            end
            if bData == nil then
                bData = {}
            end
            local pic = "csi_buff" .. buffData.buff .. "_" .. buffTypeData[2] .. ".png"
            table.insert(bData, {icon = pic, desc = str, starNum = cfg.buffStageCostStarsNum[k]})
        end
        return bData
    end
end

--是否需要选择buff
function championshipWarVoApi:isSelectBuff()
    if self.checkpointBuff then
        return true
    end
    return false
end

--是否结束本轮个人站
function championshipWarVoApi:isEndBattle()
    if self.endBattle == 1 then
        return true
    end
    return false
end

--获取个人战当前攻打的关卡头像ID
function championshipWarVoApi:getCurrentCheckpointIconId()
    -- local key = "championshipWarPersonalDialog_checkpointIconId@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
    -- local checkpointIconId = CCUserDefault:sharedUserDefault():getStringForKey(key)
    -- if checkpointIconId == nil or checkpointIconId == "" then
    --     checkpointIconId = ""
    --     local cfg = self:getWarCfg()
    --     local ratioCount = SizeOfTable(cfg.getStarRatio)
    --     local npcIconCount = SizeOfTable(cfg.npcIcon)
    --     for i = 1, ratioCount do
    --         checkpointIconId = checkpointIconId .. cfg.npcIcon[math.random(1, npcIconCount)]
    --         if i ~= ratioCount then
    --             checkpointIconId = checkpointIconId .. ","
    --         end
    --     end
    --     CCUserDefault:sharedUserDefault():setStringForKey(key, checkpointIconId)
    -- end
    -- CCUserDefault:sharedUserDefault():flush()
    -- return Split(checkpointIconId, ",")
    
    local iconIdTb = {}
    local warCfg = self:getWarCfg()
    if warCfg.npc and warCfg.npc[(self.checkpointId or 1)] then
        for k, v in pairs(warCfg.npc[self.checkpointId]) do
            table.insert(iconIdTb, tostring(v.npcIcon))
        end
    end
    return iconIdTb
end

--清空个人战当前攻打的关卡头像ID
function championshipWarVoApi:clearCheckpointIconId()
    -- local key = "championshipWarPersonalDialog_checkpointIconId@" .. tostring(playerVoApi:getUid()) .. "@" .. tostring(base.curZoneID)
    -- CCUserDefault:sharedUserDefault():setStringForKey(key, "")
    -- CCUserDefault:sharedUserDefault():flush()
end

--单次个人战结束后会结算积分：关卡数*X + 星数*Y=积分数
function championshipWarVoApi:getPersonalIntegral(attackNum)
    local cfg = self:getWarCfg()
    local x, y = cfg.singleWarScoreParm[1], cfg.singleWarScoreParm[2]
    local starNum, checkpointNum = championshipWarVoApi:getStarNum(attackNum)
    return checkpointNum * x + starNum * y
end

function championshipWarVoApi:getCheckpointName(nameId)
    local nameStr = ""
    if tonumber(nameId) == 1 then
        nameStr = getlocal("championshipWar_personal_easy")
    elseif tonumber(nameId) == 2 then
        nameStr = getlocal("championshipWar_personal_medium")
    else
        nameStr = getlocal("championshipWar_personal_difficulty")
    end
    return getlocal()
end

--获取个人战关卡的战力
--@diffId: 难度ID
function championshipWarVoApi:getCheckpointFight(diffId)
    local fight = 0
    local cfg = self:getWarCfg()
    local npcData = cfg.npc[self:getCurrentCheckpointId()]
    if npcData then
        for m, n in pairs(npcData) do
            if n.diff == diffId then
                fight = n.fight
                break
            end
        end
    end
    return fight
end

--获取最优的攻击轮次
function championshipWarVoApi:getBestAttackNum()
    local bestAttackNum = 0
    local attackNum = self:getAttackNum()
    local stage = 0
    local star = 0
    if attackNum > 1 or self.endBattle == 1 then
        for i = 1, attackNum do
            if attackNum == i then --等于当前轮的时候必须判断是打完了。
                if self.endBattle ~= 1 then
                    break
                end
            end
            local stars = self.checkpointStars[i] or {}
            local tmpStage = #stars
            local tmpStar = 0
            for k, v in pairs(stars) do
                tmpStar = tmpStar + v
            end
            if tmpStage > stage then
                stage = tmpStage
                bestAttackNum = i
                star = tmpStar
            elseif tmpStage == stage then
                if tmpStar >= star then
                    star = tmpStar
                    bestAttackNum = i
                end
            end
        end
    end
    return bestAttackNum
end

--获取指定轮次继承的坦克额外属性的比例
function championshipWarVoApi:getAttrRate(attackNum)
    local warCfg = self:getWarCfg()
    local extraAttrRate = warCfg.attrReduceRate --进入个人战坦克所有额外属性只继承attrReduceRate的值
    if self.myBuff and self.myBuff[attackNum] then
        local curBuff = self.myBuff[attackNum]
        extraAttrRate = extraAttrRate + (curBuff.attrRate or 0) * warCfg.fiveStageReward[1].buff --每五关增加额外属性的继承比例
    end
    return extraAttrRate
end

--获取自己当前获得的所有buff
function championshipWarVoApi:getMyBuff(isBest)
    local attackNum = 1
    if isBest == true then
        attackNum = self:getBestAttackNum()
    else
        attackNum = self:getAttackNum()
    end
    local warCfg = self:getWarCfg()
    local checkpointBuff = {}
    if self.myBuff and self.myBuff[attackNum] then
        local curBuff = self.myBuff[attackNum]
        local cfg
        local buffTb = {}
        for k, v in pairs(curBuff.cpbuff or {}) do --cpbuff是选择的关卡buff
            if warCfg.buffGroup[v[1]] then
                cfg = warCfg.buffGroup[v[1]][v[2]]
            end
            if cfg then
                if buffTb[cfg.buff] == nil then
                    buffTb[cfg.buff] = {}
                end
                buffTb[cfg.buff][cfg.buffId] = (buffTb[cfg.buff][cfg.buffId] or 0) + cfg.value --累加属性值
            end
        end
        for k, v in pairs(buffTb) do
            if checkpointBuff[k] == nil then
                checkpointBuff[k] = {}
            end
            for buffId, buffValue in pairs(v) do
                table.insert(checkpointBuff[k], {buffId, buffValue})
            end
        end
        for k, v in pairs(checkpointBuff) do
            local buffTypeCfg = warCfg["buffType"..k]
            local function sort(a, b) --按照坦克类型排序
                local abuffId, bbuffId = "b"..a[1], "b"..b[1]
                if buffTypeCfg and buffTypeCfg[abuffId] and buffTypeCfg[bbuffId] then
                    local atankId, btankId = buffTypeCfg[abuffId][1], buffTypeCfg[bbuffId][1]
                    if atankId < btankId then
                        return true
                    end
                end
                return false
            end
            table.sort(v, sort)
            checkpointBuff[k] = v
        end
    end
    local extraAttrRate = self:getAttrRate(attackNum)
    return extraAttrRate, checkpointBuff
end

--获取当前获取的带兵量
function championshipWarVoApi:getTroopsAdd()
    local troopsAdd = 0
    local warCfg = self:getWarCfg()
    if warCfg and warCfg.troopsAdd then
        troopsAdd = (self.buyTroopsNum or 0) * warCfg.troopsAdd --购买次数*购买量
    end
    return troopsAdd
end

--属性总览数据
function championshipWarVoApi:getTotalBuffDescStr(isBest)
    local descTb = {}
    local troopsAdd = self:getTroopsAdd()
    local first = self:getFirst()
    
    --带兵量
    if troopsAdd > 0 then
        local buffCfg = buffEffectCfg[buffKeyMatchCodeCfg["troopsAdd"]]
        local troopsAddStr = getlocal(buffCfg.name) .. "<rayimg>" .. "+" ..troopsAdd
        table.insert(descTb, {troopsAddStr, {G_ColorWhite, G_ColorGreen}})
    end
    
    --先手值
    if first > 0 then
        local buffCfg = buffEffectCfg[buffKeyMatchCodeCfg["first"]]
        local firstStr = getlocal(buffCfg.name) .. "<rayimg>" .. "+" ..first
        table.insert(descTb, {firstStr, {G_ColorWhite, G_ColorGreen}})
    end
    
    local attrRate, checkpointBuff = self:getMyBuff(isBest)
    --继承坦克额外属性比例
    local attrRateStr = getlocal("championshipWar_personal_propertyDesc3", {attrRate * 100})
    table.insert(descTb, {attrRateStr, {G_ColorWhite, G_ColorGreen}})
    --关卡加成buff
    local fleetNameMap = {[1] = getlocal("tanke"), [2] = getlocal("jianjiche"), [4] = getlocal("zixinghuopao"), [8] = getlocal("huojianche"), [15] = getlocal("believer_all_fleet")}
    local warCfg = self:getWarCfg()
    local buffId, value
    local buffTypeCfg, buffTypeData
    for k, v in pairs(checkpointBuff) do
        for bidx, buff in pairs(v) do
            buffTypeCfg = warCfg["buffType"..k]
            buffId, value = "b"..buff[1], buff[2]
            buffTypeData = buffTypeCfg[buffId]
            if buffTypeData then
                local str = ""
                if k == 1 then
                    str = getlocal("championshipWar_personal_propertyDesc1", {fleetNameMap[buffTypeData[1]], fleetNameMap[buffTypeData[2]], (value * 100) .. "%%"})
                elseif k == 2 then
                    str = getlocal("championshipWar_personal_propertyDesc2", {fleetNameMap[buffTypeData[2]], fleetNameMap[buffTypeData[1]], (value * 100) .. "%%"})
                end
                local colorTb = {nil, G_ColorYellow, nil, G_ColorYellow, G_ColorGreen, nil}
                table.insert(descTb, {str, colorTb})
            end
        end
    end
    return descTb
end

--获取当前军团总通关数
function championshipWarVoApi:getAllianceStageNum()
    return tonumber(self.allianceStageNum) or 0
end

--同步军团通关数
function championshipWarVoApi:setAllianceStageNum(stageNum)
    if stageNum > self.allianceStageNum then
        self.allianceStageNum = stageNum
    end
end

--获取当前增加的先手值
function championshipWarVoApi:getFirst()
    local first = 0
    local stageNum = tonumber(self.allianceStageNum) or 0
    local warCfg = self:getWarCfg()
    for k, v in pairs(warCfg.stageNumBuff) do
        if stageNum >= v.stageNum then
            first = v.first
        end
    end
    return first
end

--获取最大通关数和最大先手值
function championshipWarVoApi:getMaxStageNumAndFirst()
    local stageNum = self:getAllianceStageNum()
    local warCfg = self:getWarCfg()
    local stageData = warCfg.stageNumBuff[SizeOfTable(warCfg.stageNumBuff)]
    local maxStageNum, maxFirst = stageData.stageNum, stageData.first
    for k, v in pairs(warCfg.stageNumBuff) do
        if stageNum < v.stageNum then
            maxStageNum, maxFirst = v.stageNum, v.first
            break
        end
    end
    return maxStageNum, maxFirst
end

--个人站选择属性接口
function championshipWarVoApi:selectProperty(selectIndex, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarPersonalSelectProperty(selectIndex, socketCallback)
end

--个人战购买带兵量和关卡重置接口
--@typeNum: 1 购买带兵量, 2 购买攻击次数（重置关卡）
function championshipWarVoApi:buyBuffOrTroops(typeNum, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarPersonalBuyBuff(typeNum, socketCallback)
end

--军团战设置部队
function championshipWarVoApi:championshipWarSetTroops(fleetinfo, hero, equip, plane, aitroops, airshipId, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
            end
            if callback then
                callback((sData and sData.data) and sData.data.troopsreward or nil)
            end
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.aid then --军团全员同步军团通关数
                local aid = selfAlliance.aid
                local uid = playerVoApi:getUid()
                local params = {uid = uid, apply = self.apply}
                chatVoApi:sendUpdateMessage(57, params, aid + 1)
            end
            eventDispatcher:dispatchEvent("championshipWarDialog.refreshApplyInfo")
        end
    end
    socketHelper:championshipWarSetTroops(fleetinfo, hero, equip, plane, aitroops, airshipId, socketCallback)
end

--获取最近五个关卡获取的总星星数
function championshipWarVoApi:getLatestFiveStarNum()
    local warCfg = self:getWarCfg()
    local fiveIdx = math.floor(self.checkpointId / warCfg.extraStageReward)
    local attackNum = self:getAttackNum()
    local stars = self.checkpointStars[attackNum]
    if stars and fiveIdx >= 1 then
        local min, max = (fiveIdx - 1) * warCfg.extraStageReward + 1, fiveIdx * warCfg.extraStageReward
        local starNum = 0
        for k = min, max do
            starNum = starNum + (stars[k] or 0)
        end
        return starNum
    end
    return 0
end

--显示每五关奖励页面
function championshipWarVoApi:showFiveStageRewardDialog(autoFlag, layerNum, closeFunc)
    require "luascript/script/game/scene/gamedialog/championshipWar/personalWarFiveStageRewardDialog"
    personalWarFiveStageRewardDialog:showFiveStageRewardDialog(autoFlag, layerNum, closeFunc)
end

--当前积分
function championshipWarVoApi:getMyPoint()
    return self.myPoint or 0
end

--当前联赛币
function championshipWarVoApi:getMyCoin()
    return self.myCoin or 0
end

function championshipWarVoApi:getBuyData()
    return self.buyData or {b1 = {}, b2 = {}}
end

--获取当前军团锦标赛的阶层
function championshipWarVoApi:getGrade()
    local warCfg = self:getWarCfg()
    if self.grade and self.grade > warCfg.warGradeLevel then
        self.grade = warCfg.warGradeLevel
    end
    return self.grade or 1
end

function championshipWarVoApi:getLastGrade()
    return self.lastGrade or 1
end

--获取当前赛季军团所处联赛阶层
function championshipWarVoApi:getCurrentSeasonGrade()
    if self:isAllianceCanJoinBattle() == false then --如果该赛季军团没有参战，则取当前的军团阶层
        do return self:getGrade() end
    end
    local state = self:getWarState()
    if state >= 30 or (state < 30 and tonumber(self.status) == 1) then --本赛季结算后取升阶或降阶之前的阶层
        return self:getLastGrade()
    end
    return self:getGrade() --取当前阶层
end

function championshipWarVoApi:getRank()
    return self.rank or 0
end

--商店购买
function championshipWarVoApi:championshipWarShopBuy(method, id, shop, callback)
    local function buyCallBack(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                self:updateData(sData.data)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarShopBuy(method, id, shop, buyCallBack)
end

--商店页面
function championshipWarVoApi:showShopDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarShopDialog"
    local td = championshipWarShopDialog:new()
    local tbArr = {getlocal("serverwar_shop"), getlocal("believer_kcoin")..getlocal("market")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("market"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function championshipWarVoApi:tick()
    
end

--排行榜页面
function championshipWarVoApi:showRankDialog(layerNum, tabIndex)
    local function onCallback(data)
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarRankDialog"
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarRankOneDialog"
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarRankTwoDialog"
        local titleTab = {getlocal("championshipWar_signUpList"), getlocal("championshipWar_checkpointRank")}
        local td = championshipWarRankDialog:new(data, layerNum, tabIndex)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), titleTab, nil, nil, getlocal("championshipWar_personal_title"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    self:getPersonalRankList(onCallback)
end

--个人站排行榜接口
function championshipWarVoApi:getPersonalRankList(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if callback then
                    callback(sData.data)
                end
            end
        end
    end
    socketHelper:championshipWarRankList(socketCallback)
end

--个人战扫荡接口
function championshipWarVoApi:personalWarRaid(tid, defender, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
            end
            if sData and sData.data and sData.data.report then
                if sData.data.report.r then
                    local rewardlist = FormatItem(sData.data.report.r)
                    for k, v in pairs(rewardlist) do
                        G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                    end
                end
                if callback then
                    callback(sData.data.report)
                end
                eventDispatcher:dispatchEvent("championshipWarPersonalDialog.refreshUI")
            end
        end
    end
    socketHelper:championshipWarRaid(tid, defender, socketCallback)
end

--是否可以快速战斗(扫荡)
function championshipWarVoApi:isCanQuickBattle(attackNum, checkpointId)
    if not attackNum then
        attackNum = self:getAttackNum()
    end
    if not checkpointId then
        checkpointId = self:getCurrentCheckpointId()
    end
    if self.checkpointStars and attackNum > 1 then
        local cfg = self:getWarCfg()
        local bestContinuousCheckpointId = 0 --最佳连续达到[cfg.sweapStarNum]星的关卡Id
        for k, v in pairs(self.checkpointStars) do
            if k == (attackNum - 1) then
                for m, n in ipairs(v) do
                    if n >= cfg.sweapStarNum then
                        if bestContinuousCheckpointId < m then
                            bestContinuousCheckpointId = m
                        end
                    else
                        break
                    end
                end
            end
        end
        if checkpointId <= bestContinuousCheckpointId then
            return true
        end
    end
    return false
end

function championshipWarVoApi:quickBattleNow(layerNum, callback)
    if not self:isCanQuickBattle() then
        G_showTipsDialog(getlocal("championshipWar_personal_unableQuickBattle"))
        do return end
    end
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
                
                local needTb = {"championshipWarQuickBattle", getlocal("raids_raids_result"), callback}
                local starNums, starSize = championshipWarVoApi:getStarNum(self.attackNum)
                table.insert(needTb, starSize)--当前这轮通关数  4
                table.insert(needTb, starNums)--当前这轮通关总星数  5
                -- if self.oldMyPoint and self.myPoint then--当前这轮通关总积分  6
                --     table.insert(needTb,self.myPoint - self.oldMyPoint)
                -- elseif self.myPoint then
                --     table.insert(needTb,self.myPoint)
                -- else
                table.insert(needTb, 0)--当前这轮通关总积分  6 (目前作废)
                -- end
                
                if sData.data.report and sData.data.report and sData.data.report.r then
                    local reward = FormatItem(sData.data.report.r, nil, true)
                    -- print("SizeOfTable(reward)-->>",SizeOfTable(reward))
                    table.insert(needTb, reward)--当前这轮通关 获得的奖励  7
                end
                G_showCustomizeSmallDialog(layerNum, needTb)
            end
        end
    end
    socketHelper:championshipWarQuickBattle(socketCallback)
end

--军团战对阵列表
function championshipWarVoApi:championshipWarScheduleGet(callback, waitingFlag)
    -- local data = "{\"msg\":\"Success\", \"ts\":1538624723, \"data\":{\"schedule\":{\"id\":12, \"st\":1538539200, \"info\":[[[\"1-200004-8\",0],[\"1-100059-8\",0],[\"1-100004-8\",0],[0,0],[\"1-100058-8\",0],[0,0],[\"1-200006-8\",0],[0,0]], [[\"1-200004-7\",\"1-100059-8\"],[\"1-100004-8\",0],[\"1-100058-8\",0],[\"1-200006-8\",0]], [[\"1-100059-8\",\"1-100004-7\"],[\"1-100058-7\",\"1-200006-8\"]], [[\"1-100059-7\",\"1-200006-8\"]], [[\"1-200006\"]]], \"status\":1, \"grade\":1, \"ainfo\":{\"1-200004\":[\"Wings\"], \"1-100058\":[\"vip1\"], \"1-200006\":[\"Qui\"], \"1-100059\":[\"Ym1\"], \"1-100004\":[\"授勋\"]}, \"updated_at\":1538539801}}, \"zoneid\":1, \"cmd\":\"alliancechampion.alliancewar.schedule\", \"rnum\":26, \"uid\":2000238, \"ret\":0}"
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
                if sData.data.schedule then
                    self.battleInfo = sData.data.schedule
                end
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarScheduleGet(socketCallback, waitingFlag)
end

--军团战对阵列表页面
function championshipWarVoApi:showAllianceWarDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipAllianceWarDialog"
    local td = championshipAllianceWarDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("championshipWar_allianceWar_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--获取军团战对战列表
function championshipWarVoApi:getAllianceWarBattleInfo()
    return self.battleInfo or {}
end

--显示回放页面
function championshipWarVoApi:showReplayDialog(rid, round, report, layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarReplayDialog"
    local td = championshipWarReplayDialog:new(rid, round, report, layerNum)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("championshipWar_replay_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function championshipWarVoApi:getHttpPrefixUrl(islocal)
    return "http://"..self.serverhost.."/tank-server/public/index.php/kuafu/champion/"
end

--获取战报
function championshipWarVoApi:getReport(method, rid, round, zaid1, zaid2, callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
                if sData.data.report then --战报详情
                    if callback then
                        callback(sData.data.report)
                    end
                end
            end
        end
    end
    socketHelper:championshipWarReport(method, rid, round, zaid1, zaid2, socketCallback)
end

--获取战报列表
function championshipWarVoApi:getReportList(rid, round, callback)
    if self.serverhost == nil then
        do return end
    end
    local httpUrl = self:getHttpPrefixUrl() .. "report"
    local reqStr = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&rid="..rid.."&round="..round
    -- print("httpUrl", httpUrl.."?"..reqStr.."\n")
    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
    if(retStr ~= "")then
        local retData = G_Json.decode(retStr)
        -- G_dayin(retData)
        if retData and retData.ret == 0 then
            if callback then
                callback(retData.data.report)
            end
        end
    end
end

--读取战报详情
function championshipWarVoApi:readReport(report, callback)
    local reportId = report.id
    if self.reportList and self.reportList[reportId] then
        callback(self.reportList[reportId])
        do return end
    end
    if self.serverhost == nil then
        do return end
    end
    local httpUrl = self:getHttpPrefixUrl() .. "content"
    local reqStr = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&id="..reportId
    print("httpUrl", httpUrl.."?"..reqStr.."\n")
    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
    if(retStr ~= "")then
        local retData = G_Json.decode(retStr)
        G_dayin(retData)
        if retData and retData.ret == 0 then
            report.content = retData.data.content
            self:addReportContent(report)
            if callback then
                local detail = self.reportList[reportId]
                if detail then
                    callback(detail)
                end
            end
        end
    end
end

function championshipWarVoApi:addReportContent(data)
    local selfUid = playerVoApi:getUid()
    local winFlag = data.win -- 0: 防守方胜利,进攻方失败，1：进攻方胜利,防守方失败
    local isVictory = false
    local typeFlag -- 0：防守方，1：攻击方 (针对自己)
    local myUid, myName, myLv, myFight, myVip, myRank, myPic, myHFid, myAllianceName
    local enemyUid, enemyName, enemyLv, enemyFight, enemyVip, enemyRank, enemyPic, enemyHFid, enemyAllianceName
    if selfUid == data.defuid then --我是防守方
        if winFlag == 0 then
            isVictory = true
        end
        typeFlag = 0
        
        myUid = data.defenser
        myName = data.defname
        enemyUid = data.attacker
        enemyName = data.attname
        
        if data.content.info then
            myLv = data.content.info.defenserLevel
            if data.content.info.defInfo then
                myFight = data.content.info.defInfo[1]
                myVip = data.content.info.defInfo[2]
                myRank = data.content.info.defInfo[3]
                myPic = data.content.info.defInfo[4]
                myHFid = data.content.info.defInfo[5]
            end
            myAllianceName = data.content.info.DAName
            
            enemyLv = data.content.info.attackerLevel
            if data.content.info.attInfo then
                enemyFight = data.content.info.attInfo[1]
                enemyVip = data.content.info.attInfo[2]
                enemyRank = data.content.info.attInfo[3]
                enemyPic = data.content.info.attInfo[4]
                enemyHFid = data.content.info.attInfo[5]
            end
            enemyAllianceName = data.content.info.AAName
        end
    elseif selfUid == data.attuid then --我是进攻方
        if winFlag == 1 then
            isVictory = true
        end
        typeFlag = 1
        
        myUid = data.attacker
        myName = data.attname
        enemyUid = data.defenser
        enemyName = data.defname
        
        if data.content.info then
            myLv = data.content.info.attackerLevel
            if data.content.info.attInfo then
                myFight = data.content.info.attInfo[1]
                myVip = data.content.info.attInfo[2]
                myRank = data.content.info.attInfo[3]
                myPic = data.content.info.attInfo[4]
                myHFid = data.content.info.attInfo[5]
            end
            myAllianceName = data.content.info.AAName
            
            enemyLv = data.content.info.defenserLevel
            if data.content.info.defInfo then
                enemyFight = data.content.info.defInfo[1]
                enemyVip = data.content.info.defInfo[2]
                enemyRank = data.content.info.defInfo[3]
                enemyPic = data.content.info.defInfo[4]
                enemyHFid = data.content.info.defInfo[5]
            end
            enemyAllianceName = data.content.DAName
        end
    end
    
    --战斗损失
    local lostShip = {
        attackerLost = {},
        defenderLost = {},
        attackerTotal = {},
    defenderTotal = {}}
    if data.content.destroy then
        local attackerLost = data.content.destroy.attacker
        local defenderLost = data.content.destroy.defenser
        if attackerLost then
            lostShip.attackerLost = FormatItem({o = attackerLost}, false)
        end
        if defenderLost then
            lostShip.defenderLost = FormatItem({o = defenderLost}, false)
        end
    end
    if data.content.tank then
        local attackerTotal = data.content.tank.a
        local defenderTotal = data.content.tank.d
        if attackerTotal then
            lostShip.attackerTotal = FormatItem({o = attackerTotal}, false)
        end
        if defenderTotal then
            lostShip.defenderTotal = FormatItem({o = defenderTotal}, false)
        end
    end
    
    local tempTb = {
        id = data.id,
        rid = data.rid,
        round = data.round,
        time = data.ts,
        isVictory = isVictory,
        type = typeFlag,
        report = data.content.report,
        lostShip = lostShip,
        accessory = data.content.aey or {},
        hero = data.content.hh or {{{}, 0}, {{}, 0}},
        emblemID = data.content.equip,
        plane = data.content.plane,
        weapon = data.content.weapon,
        armor = data.content.armor,
        troops = data.content.troops,
        aitroops = data.content.aitroops,
        airship = data.content.ap,
        myInfo = {
            uid = myUid,
            name = myName or "",
            level = myLv or 0,
            pic = myPic or headCfg.default,
            fight = myFight or 0,
            vip = myVip,
            rank = myRank,
            hfid = myHFid or headFrameCfg.default,
            allianceName = myAllianceName,
        },
        enemyInfo = {
            uid = enemyUid,
            name = enemyName or "",
            level = enemyLv or 0,
            pic = enemyPic or headCfg.default,
            fight = enemyFight or 0,
            vip = enemyVip,
            rank = enemyRank,
            hfid = enemyHFid or headFrameCfg.default,
            allianceName = enemyAllianceName,
        },
        --ri字段为战报新增功能扩展字段
        --tskinList：敌我双方坦克皮肤数据
    tskinList = G_formatExtraReportInfo(data.content.repInfo)}
    if self.reportList == nil then
        self.reportList = {}
    end
    self.reportList[data.id] = tempTb
end

function championshipWarVoApi:clearReport()
    self.reportList = nil, nil
end

--判断指定军团战结算是否已经有结算数据
function championshipWarVoApi:checkIfSettledByWarState(state)
    local round = self.stateRoundTb[state]
    if round and self.battleInfo and self.battleInfo.info and self.battleInfo.info[round] and SizeOfTable(self.battleInfo.info[round]) > 0 then --该轮次有数据
        return true
    end
    return false
end

--获取军团排名
function championshipWarVoApi:getAllianceWarRank(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.ranklist then
                
            end
        end
    end
    socketHelper:championshipWarAllianceRank(socketCallback)
end

--是否报名了军团战（玩家设置过军团战参战部队说明就报名过）
function championshipWarVoApi:isApplyAllianceWar()
    return self.applyFlag
end

--军团排名奖励面板
function championshipWarVoApi:showRankRewardDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarRankRewardDialog"
    championshipWarRankRewardDialog:showRankRewardDialog(layerNum)
end

function championshipWarVoApi:showSettleDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarSettleDialog"
    championshipWarSettleDialog:showSettlementDialog(layerNum)
end

--是否领取结算奖励的标识
function championshipWarVoApi:hasRankRewarded()
    return self.rd
end

--领取结算奖励
function championshipWarVoApi:rankRewardRequest(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:updateData(sData.data)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarRankReward(self.rank, socketCallback)
end

function championshipWarVoApi:getRankReward()
    local warCfg = self:getWarCfg()
    if warCfg and warCfg.rankingReward then
        local rewardGrade = self:getCurrentSeasonGrade()
        local rewardCfg = warCfg.rankingReward[rewardGrade]
        if rewardCfg then
            local minRank, maxRank = 0, 0
            local coin
            for k, v in pairs(rewardCfg) do
                minRank, maxRank = v.rank[1], v.rank[2]
                if tonumber(self.rank) >= tonumber(minRank) and tonumber(self.rank) <= tonumber(maxRank) then
                    coin = v.coin
                    do break end
                end
            end
            -- if coin == nil then
            --     coin = rewardCfg[SizeOfTable(rewardCfg)].coin
            -- end
            return coin or 0
        end
    end
    return 0
end

function championshipWarVoApi:allianceWarRankListRequest(callback)
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.ranklist and SizeOfTable(sData.data.ranklist) > 0 then
                self.rankList = sData.data.ranklist
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:championshipWarAllianceRankRequest(socketCallback)
end

function championshipWarVoApi:getAllianceWarRankList()
    return self.rankList or {}
end

function championshipWarVoApi:showAllianceWarRankDialog(layerNum)
    local function realShow()
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarAllianceRankDialog"
        local td = championshipWarAllianceRankDialog:new(layerNum)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("mainRank"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    if self.rankList == nil then
        self:allianceWarRankListRequest(realShow)
    else
        realShow()
    end
end

--获取军团战报名人数
function championshipWarVoApi:getApply()
    if self.apply then
        return self.apply
    end
    return 0
end

function championshipWarVoApi:setApply(apply)
    if self.apply and self.apply < apply then
        self.apply = apply
        eventDispatcher:dispatchEvent("championshipWarDialog.refreshApplyInfo")
    end
end

function championshipWarVoApi:getRoundTitle(round)
    local titleStrTb = {
        getlocal("championshipWar_final"),
        getlocal("championshipWar_powerhouse", {4}),
        getlocal("championshipWar_powerhouse", {8}),
    getlocal("championshipWar_powerhouse", {16})}
    return (titleStrTb[round] or "")
end

--显示战报列表页面
function championshipWarVoApi:showReportDialog(rid, round, layerNum, callback)
    local function socketCallback(report)
        require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarReportDialog"
        local td = championshipWarReportDialog:new(report, layerNum)
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("allianceWar_battleReport"), true, layerNum)
        sceneGame:addChild(dialog, layerNum)
    end
    self:getReportList(rid, round, socketCallback)
end

function championshipWarVoApi:showReportDetailDialog(report, layerNum)
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarReportDetailDialog"
    local td = championshipWarReportDetailDialog:new(report, layerNum)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("allianceWar_battleReport"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function championshipWarVoApi:getAttackCheckpointEnemyTroopInfo(diffId)
    return self.troops[diffId] or {}, self.plane[diffId] or {}, self.airship[diffId] or {}
end

--查看军团出战成员的部队
function championshipWarVoApi:showMemberTroopDialog(memberNameStr, troopInfo, layerNum)
    local titleStr = getlocal("championshipWar_memberTroop", {memberNameStr})
    require "luascript/script/game/scene/gamedialog/championshipWar/championshipWarCheckTroopDialog"
    championshipWarCheckTroopDialog:showTroopDialog(troopInfo, titleStr, layerNum)
end

--是否可以领取军团结算奖励
--1：没有报名 2：军团未达到参赛资格 3：已经领取过结算奖励 4: 军团参战数据异常，或者没有参战导致rank为0
function championshipWarVoApi:isCanReceiveAllianceWarReward()
    if tonumber(self.rank) <= 0 then
        return false, 4
    end
    if self.applyFlag == false and self.tinfoErr ~= true then --如果没有申请参战则不可以领取
        return false, 1
    end
    if self:hasRankRewarded() == 1 then --如果本轮已经领取也不可以领取
        return false, 3
    end
    if self:isAllianceCanJoinBattle() == false then --军团没有达到参战资格，不可领奖
        return false, 2
    end
    return true
end

--判断自己所在军团是否达到了参战资格
function championshipWarVoApi:isAllianceCanJoinBattle()
    local warCfg = self:getWarCfg()
    if tonumber(self.apply or 0) >= warCfg.allianceJoinNum then --如果军团参战人数达到需求就任务该军团可以参战
        return true
    end
    return false
end

--判断部队阵型保存的部队是否可用
function championshipWarVoApi:isTroopsCanUse(tank, hero)
    if self.diffId == nil then
        do return false end
    end
    local tankTb = self:getAttackCheckpointEnemyTanks(self.diffId) --当前攻击关卡的部队
    if tankTb then
        for k, v in pairs(tankTb) do
            local tankId, tankNum = v[1], v[2]
            if tankId == nil and tankNum == nil then --敌方该位置没有坦克，但是阵型有则不可用
                if tank and tank[k] and tank[k][1] and tank[k][2] then
                    return false
                end
                if hero and hero[k] and tostring(hero[k]) ~= "0" then --该位置有将领也不可用
                    return false
                end
            end
        end
    end
    return true
end

--当前是否处于休赛期
function championshipWarVoApi:isRestBattle(tipFlag)
    local state = self:getWarState()
    if state >= 40 then
        if tipFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_restbattle_disable"), 30)
        end
        return true
    end
    return false
end

--判断是否是测试服
function championshipWarVoApi:isTestServer()
    if tonumber(base.curZoneID) == 997 or tonumber(base.curZoneID) == 998 then
        return true
    end
    return false
end
