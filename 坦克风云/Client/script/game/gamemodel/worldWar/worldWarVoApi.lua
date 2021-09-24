require "luascript/script/game/gamemodel/worldWar/worldWarBattleVo"
require "luascript/script/game/gamemodel/worldWar/worldWarPlayerVo"
require "luascript/script/game/gamemodel/worldWar/worldWarBetVo"
require "luascript/script/game/gamemodel/worldWar/worldWarShopVo"
require "luascript/script/game/gamemodel/worldWar/worldWarPointDetailVo"
require "luascript/script/game/gamemodel/worldWar/worldWarRankVo"
require "luascript/script/game/gamemodel/worldWar/worldWarBattleReportVo"
require "luascript/script/config/gameconfig/worldWarCfg"
worldWarVoApi =
{
    worldWarUrl = nil, --世界争霸域名
    initFlag = nil, --是否初始化数据
    initBuildingFlag = false, --建筑头顶是否已经显示了图标
    worldWarId = nil, --比赛id
    startTime = nil, --世界争霸开始时间
    endTime = nil, --世界争霸结束时间
    totalPlayerNum1 = 0, --报名参加NB赛的总人数
    totalPlayerNum2 = 0, --报名参加SB赛的总人数
    serverList = nil, --参与世界争霸的服务器列表
    playerList = nil, --淘汰赛选手列表
    battleList1 = nil, --NB淘汰赛的对阵表
    battleList2 = nil, --SB淘汰赛的对阵表
    tmatchTimeTb1 = nil, --一个table, 里面存的是NB组淘汰赛每轮战斗的开启时间戳
    tmatchTimeTb2 = nil, --一个table, 里面存的是SB组淘汰赛每轮战斗的开启时间戳
    pmatchTimeTb = {}, --一个table,里面存的是积分赛每轮战斗的开始时间戳
    
    scheduleExpireTime1 = 0, --NB淘汰赛对阵表过期时间
    scheduleExpireTime2 = 0, --SB淘汰赛对阵表过期时间
    warInfoExpireTime = 0, --初始化信息的过期时间
    
    betList1 = nil, --NB淘汰赛每一轮的送花记录
    betList2 = nil, --SB淘汰赛每一轮的送花记录
    commonList = nil, --道具列表
    rareList = nil, --珍品列表
    point = 0, --积分
    pointDetail = {}, --积分明细
    detailExpireTime = 0, --积分明细过期时间
    buyStatus = 0, --可以购买商店道具状态，0：都未开启，1：只有道具开启，2：道具和珍品都开启
    
    rankList = {{}, {}, {}, {}}, --排行榜
    rankExpireTime = {0, 0, 0, 0}, --排行榜过期时间，1，2积分大师，精英，3，4淘汰大师，精英
    lastSetFleetTime = {0, 0, 0},
    lastSetStrategyTime = 0, --上次设置战术和上阵顺序的时间
    
    signStatus = nil, --报名的是那种比赛，1是NB赛，2是SB赛，nil是没报名
    myRank = 0, --我的排名
    -- isRewardRank=false,--是否领取过排行奖励
    pMatchRank = 0, --积分赛排名
    pMatchTotalPlayer = 0, --积分赛总人数
    pMatchWinMatch = 0, --玩家自己的积分赛胜场数
    pMatchLoseMatch = 0, --玩家自己的积分赛败场数
    pMatchResultTb = {}, --每个元素表示积分赛每场战斗的结果, 0123分别是大败小败小胜大胜
    shopFlag = -1, --是否初始化商店数据,-1:未初始化，1:已经初始化
    pointDetailFlag = -1, --是否初始化积分明细,-1:未初始化，0:需要刷新面板，1:已经初始化
    -- rankFlag=-1,--是否初始化排行榜数据,-1:未初始化，1:已经初始化
    -- troopsFlag=-1,--是否初始化部队数据,-1:未初始化，1:已经初始化
    
    propertyIndexTab = {1, 2, 3}, --3场对应的属性位置
    tmatchDays = 0, --淘汰赛一共要打几天，这个是根据淘汰赛人数和组数动态算出来的
    
    messageTab = {{}, {}}, --连胜信息
    messageExpireTime = {0, 0}, --连胜信息过期时间，1全部，2个人
    myReportList = {}, --积分赛的我的战报列表
    myReportExpireTime = 0, --积分赛的我的战报列表过期时间
    reportNum = 0, --积分赛的我的战报总数
    reportHasMore = false, --积分赛战报分页显示，是否还有更多
    reportFlag = -1, --积分赛战报标示
    landtype = {}, --下场战斗地形
    championChatInit = false, --是否已经初始化过冠军聊天刷屏
    f_pShopItems = nil, --普通商店列表
    f_aShopItems = nil, --珍品商店列表
}

--是否初始化世界争霸数据
function worldWarVoApi:getInitFlag()
    return self.initFlag
end
function worldWarVoApi:setInitFlag(initFlag)
    self.initFlag = initFlag
end

--世界争霸id
function worldWarVoApi:getWorldWarId()
    return self.worldWarId
end
function worldWarVoApi:setWorldWarId(worldWarId)
    self.worldWarId = worldWarId
end

--3场对应的属性位置
function worldWarVoApi:getPropertyIndexTab()
    return self.propertyIndexTab
end
function worldWarVoApi:setPropertyIndexTab(propertyIndexTab)
    self.propertyIndexTab = propertyIndexTab
end
function worldWarVoApi:getPropertyIndex(index)
    return self.propertyIndexTab[index]
end
--交换2个场次的属性加成
function worldWarVoApi:setPropertyIndex(index1, index2, indexTab)
    if indexTab then
        local temp = indexTab[index2]
        indexTab[index2] = indexTab[index1]
        indexTab[index1] = temp
    else
        local temp = self.propertyIndexTab[index2]
        self.propertyIndexTab[index2] = self.propertyIndexTab[index1]
        self.propertyIndexTab[index1] = temp
    end
end

--获取参加本次世界争霸的各个服务器的ID和名字
--return 一个table, table的每个元素又是一个table B, table B的第一个元素是服务器的ID, 第二个元素是服务器的名称
function worldWarVoApi:getServerList()
    if(self.serverList)then
        return self.serverList
    else
        return {}
    end
end

--获取所有的选手信息
--return 一个table, table里面的元素是worldWarPlayerVo
function worldWarVoApi:getPlayerList()
    if(self.playerList)then
        return self.playerList
    else
        return {}
    end
end

--获取积分赛每轮的战斗时间表
function worldWarVoApi:getPointBattleTimeList()
    return self.pmatchTimeTb
end

--获取淘汰赛每轮的战斗时间表
--param type: 1是NB赛, 2是SB赛
--return 一个table, table里面是每轮战斗的时间戳
function worldWarVoApi:getBattleTimeList(type)
    if(type == 1)then
        return self.tmatchTimeTb1
    else
        return self.tmatchTimeTb2
    end
end

--获取淘汰赛对阵表
--param type: 1是获取NB赛的对阵表, 2是获取SB赛的对阵表
function worldWarVoApi:getBattleList(type)
    if(type ~= nil and self["battleList"..type])then
        return self["battleList"..type]
    else
        return {}
    end
end

--获取送花记录
--param type: 1是NB赛, 2是SB赛
function worldWarVoApi:getBetList(type)
    if(type ~= nil and self["betList"..type])then
        return self["betList"..type]
    else
        return {}
    end
end

--玩家自己的积分赛胜场数
function worldWarVoApi:getPMatchWinMatch()
    return self.pMatchWinMatch
end

--玩家自己的积分赛败场数
function worldWarVoApi:getPMatchLoseMatch()
    return self.pMatchLoseMatch
end

--积分赛排位分
--是根据配置用胜场数和败场数算出来的
function worldWarVoApi:getPMatchScore()
    local result = worldWarCfg.tmatchRankBasePt
    local length = #self.pMatchResultTb
    local conWinNum = 0
    for i = 1, length do
        local battleResult = self.pMatchResultTb[i]
        if(battleResult > 1)then
            conWinNum = conWinNum + 1
        else
            conWinNum = 0
        end
        if(conWinNum >= worldWarCfg.conWinTime)then
            result = result + worldWarCfg.tmatchRankPt[battleResult] + worldWarCfg.conWinPoint
        else
            result = result + worldWarCfg.tmatchRankPt[battleResult]
        end
    end
    return result
end

--积分赛排名
function worldWarVoApi:getPMatchRank()
    return self.pMatchRank
end

--积分赛总人数
function worldWarVoApi:getPMatchPlayers()
    return self.pMatchTotalPlayer
end

--根据battleIndex和roundID获取淘汰赛阶段比赛所在的分组ID
--param roundID: 比赛的轮次ID
--param battleIndex: 比赛在轮次内的index
--return 1~4, 这场比赛在哪个组
--return a~d, 1~4对应的abcd
function worldWarVoApi:getGroupIDByBIDAndRID(roundID, battleIndex)
    local roundBattleNum = worldWarCfg.tmatchplayer / math.pow(2, roundID)
    local space = roundBattleNum / worldWarCfg.tmatchgroup
    local groupID = math.floor((battleIndex - 1) / space) + 1
    local map = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"}
    return groupID, map[groupID]
end

--根据传来的淘汰赛轮次获取该轮比赛的状态
--param type: NB组还是SB组
--param roundID: 比赛的轮次
--param isSetFleet: 是否是设置部队的状态
--return 0: 下次比赛不是该轮次, 该轮比赛还处于不可献花的状态
--return 10: 可献花的状态
--return 11: 开赛前五分钟, 不可献花的状态
--return 21: 战斗中, 正在进行第1场
--return 22: 战斗中, 正在进行第2场
--return 23: 战斗中, 正在进行第3场
--return 30: 战斗已结束
function worldWarVoApi:getRoundStatus(type, roundID, isSetFleet)
    local inoperableTime
    if isSetFleet and isSetFleet == true then
        inoperableTime = worldWarCfg.setTroopsLimit
    else
        inoperableTime = worldWarCfg.betTime
    end
    local timeTb = self["tmatchTimeTb"..type]
    if(base.serverTime >= timeTb[roundID] + worldWarCfg.battleTime * 3)then
        return 30
    elseif(base.serverTime >= timeTb[roundID] + worldWarCfg.battleTime * 2)then
        return 23
    elseif(base.serverTime >= timeTb[roundID] + worldWarCfg.battleTime)then
        return 22
    elseif(base.serverTime >= timeTb[roundID])then
        return 21
    elseif(base.serverTime >= timeTb[roundID] - inoperableTime)then
        return 11
    else
        if(roundID == 1)then
            local zeroTime = G_getWeeTs(self["tmatchTimeTb"..type][1]) - 86400
            local lastPMatchTime = zeroTime + worldWarCfg["pmatchendtime"..type][1] * 3600 + worldWarCfg["pmatchendtime"..type][2] * 60
            if(base.serverTime > lastPMatchTime)then
                return 10
            else
                return 0
            end
        else
            if(self:getRoundStatus(type, roundID - 1) == 30)then
                return 10
            else
                return 0
            end
        end
    end
end

--淘汰赛，献花的状态
--param type: NB组还是SB组
--param isSetFleet: 是否是设置部队的状态
function worldWarVoApi:getSendFlowerStatus(type, isSetFleet)
    local warStatus = self:checkStatus()
    if warStatus >= 30 and warStatus < 40 then
        local timeTb = self["tmatchTimeTb"..type]
        if timeTb and SizeOfTable(timeTb) > 0 then
            local isOver = true
            local num = SizeOfTable(timeTb)
            for i = 1, num do
                local status = self:getRoundStatus(type, i, isSetFleet)
                if status > 0 and status < 30 then
                    return status
                end
                if status == 30 then
                else
                    isOver = false
                end
            end
            if isOver == true then
                return 30
            end
        end
    end
    return - 1
end

--弹出主面板
--param layerNum: 面板所在的层级
function worldWarVoApi:showMainDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarDialog"
    local td = worldWarDialog:new()
    local tbArr = {getlocal("world_war_sub_title1"), getlocal("world_war_sub_title2"), getlocal("world_war_sub_title3")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("world_war_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function worldWarVoApi:showRewardInfoDialog(layerNum, tab)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarRewardInfoDialog"
    local td = worldWarRewardInfoDialog:new()
    local tbArr = {getlocal("world_war_master_reward"), getlocal("world_war_elite_reward")}
    local vd = td:init("panelBg.png", true, CCSizeMake(768, 800), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("world_war_reward_info_title"), true, layerNum)
    sceneGame:addChild(vd, layerNum)
    if(tab)then
        td:tabClick(tab)
    end
end

--弹出报名面板
--param type: 1是NB赛，2是SB赛
function worldWarVoApi:showSignDialog(type, layerNum)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarSignSmallDialog"
    local sd = worldWarSignSmallDialog:new(type)
    sd:init(layerNum)
end

--弹出个人信息面板
function worldWarVoApi:showPlayerDetailDialog(data, layerNum)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarPlayerDetailDialog"
    local detailDialog = worldWarPlayerDetailDialog:new(data)
    detailDialog:init(layerNum)
end

--弹出对战面板
--param type: 1是NB赛，2是SB赛
--param data: worldWarBattleVo
--param isPointMatch: true是积分赛, 非true是淘汰赛
function worldWarVoApi:showBattleDialog(type, data, isPointMatch, layerNum, reportData)
    if(data.player1 and data.player2)then
        require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarBattleDialog"
        local battleDialog = worldWarBattleDialog:new(type, data, isPointMatch, reportData)
        battleDialog:init(layerNum + 1)
    else
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("world_war_battle_empty_tip"), 30)
    end
end

--弹出战报列表面板
--param type: 1积分赛 2淘汰赛
function worldWarVoApi:showReportListDialog(type, layerNum)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarReportDialog"
    local signStatus = worldWarVoApi:getSignStatus()
    local td = worldWarReportDialog:new(type, signStatus)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_fightRecord"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end

--弹出献花面板
--param type: 1是NB赛, 2是SB赛
--param data: worldWarBattleVo
function worldWarVoApi:showFlowerDialog(type, data, layerNum)
    if(data.player1 and data.player2)then
        require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarFlowerDialog"
        local flowerDialog = worldWarFlowerDialog:new(type, data)
        flowerDialog:init(layerNum + 1)
    end
end

--弹出说明面板
function worldWarVoApi:showIntroduceDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/worldWarDialog/worldWarIntroDialog"
    local td = worldWarIntroDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("activity_baseLeveling_ruleTitle"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function worldWarVoApi:getWarInfoExpireTime()
    return self.warInfoExpireTime
end

--获取世界争霸的整体信息
--param callback: 获取之后的回调函数
function worldWarVoApi:getWarInfo(callback)
    if(base.serverTime >= self.warInfoExpireTime)then
        local function onRequestEnd(fn, data)
            local ret, sData = base:checkServerData(data)
            if(ret == true)then
                if sData.data and sData.data.url then
                    self.worldWarUrl = sData.data.url
                end
                local warId
                if sData.data and sData.data.matchId then
                    warId = sData.data.matchId
                end
                if(warId == nil or sData.data.st == nil)then
                    do return end
                end
                self:setWorldWarId(warId)
                self.startTime = tonumber(sData.data.st)
                if(sData.data and sData.data.point)then
                    self:setPoint(tonumber(sData.data.point))
                end
                --先算淘汰赛的轮数, 最后要加上两轮总决赛
                local tmatchRounds = tonumber(string.format("%.0f", math.log(worldWarCfg.tmatchplayer / worldWarCfg.tmatchgroup) / math.log(2))) + 2
                --一天打两轮，所以除以2
                self.tmatchDays = tmatchRounds / 2
                self.tmatchTimeTb1 = {}
                self.tmatchTimeTb2 = {}
                local tmatchStartZeroTime = self:getStarttime() + worldWarCfg.signuptime * 86400 + worldWarCfg.pmatchdays * 86400
                for i = 1, tmatchRounds do
                    if(i % 2 == 1)then
                        self.tmatchTimeTb1[i] = tmatchStartZeroTime + math.floor(i / 2) * 86400 + worldWarCfg.tmatch1starttime1[1] * 3600 + worldWarCfg.tmatch1starttime1[2] * 60
                        self.tmatchTimeTb2[i] = tmatchStartZeroTime + math.floor(i / 2) * 86400 + worldWarCfg.tmatch1starttime2[1] * 3600 + worldWarCfg.tmatch1starttime2[2] * 60
                    else
                        self.tmatchTimeTb1[i] = tmatchStartZeroTime + (i / 2 - 1) * 86400 + worldWarCfg.tmatch2starttime1[1] * 3600 + worldWarCfg.tmatch2starttime1[2] * 60
                        self.tmatchTimeTb2[i] = tmatchStartZeroTime + (i / 2 - 1) * 86400 + worldWarCfg.tmatch2starttime2[1] * 3600 + worldWarCfg.tmatch2starttime2[2] * 60
                    end
                end
                if(sData.data.et)then
                    self.endTime = tonumber(sData.data.et)
                else
                    self.endTime = self.tmatchTimeTb1[#self.tmatchTimeTb1] + worldWarCfg.shoppingtime * 86400
                end
                
                self.pmatchTimeTb = {}
                local pmst = worldWarCfg.pmatchstarttime1
                local pmet = worldWarCfg.pmatchendtime1
                local signupDays = worldWarCfg.signuptime
                local firstBattleTime = G_getWeeTs(self.startTime) + 86400 * signupDays + pmst[1] * 3600 + pmst[2] * 60
                local perbattleDuringTime = worldWarCfg.battleTime * 3
                local battleDuringTotalTime = pmet[1] * 3600 + pmet[2] * 60 - (pmst[1] * 3600 + pmst[2] * 60)
                local dailyBattleNum = battleDuringTotalTime / perbattleDuringTime
                -- print("~~~~~~~~~~dailyBattleNum:",dailyBattleNum)
                for i = 1, worldWarCfg.pmatchdays do
                    for k = 1, dailyBattleNum do
                        local time = firstBattleTime + k * perbattleDuringTime + (i - 1) * 86400
                        -- local tab=os.date("*t",time)
                        -- print("time",time,tab.day,tab.hour,tab.min,tab.sec)
                        table.insert(self.pmatchTimeTb, time)
                    end
                end
                
                self.serverList = {}
                local servers = sData.data.servers
                for k, v in pairs(servers) do
                    local tmp = {}
                    tmp[1] = tostring(v)
                    tmp[2] = GetServerNameByID(v)
                    self.serverList[k] = tmp
                end
                self.signStatus = nil
                if(sData.data.applydata)then
                    if(sData.data.applydata.jointype)then
                        self.signStatus = tonumber(sData.data.applydata.jointype)
                    end
                    if(sData.data.applydata.tinfo)then
                        local tinfo = sData.data.applydata.tinfo
                        local troops = tinfo.troops or {}
                        local tskinTb = tinfo.skin or {}
                        for k, v in pairs(troops) do
                            local tType = k + 12
                            for m, n in pairs(v) do
                                if n and n[1] and n[2] then
                                    local tid = (tonumber(n[1]) or tonumber(RemoveFirstChar(n[1])))
                                    tankVoApi:setTanksByType(tType, m, tid, tonumber(n[2]))
                                else
                                    tankVoApi:deleteTanksTbByType(tType, m)
                                end
                            end
                            if base.tskinSwitch == 1 then
                                local tskin = tskinTb[k] or {}
                                tankSkinVoApi:setTankSkinListByBattleType(tType, tskin)
                            end
                        end
                        if base.heroSwitch == 1 then
                            local hero = tinfo.hero or {}
                            for k, v in pairs(hero) do
                                if v and SizeOfTable(v) > 0 then
                                    heroVoApi:setWorldWarHeroList(k, v)
                                end
                            end
                        end
                        if base.AITroopsSwitch == 1 then
                            local aitroops = tinfo.aitroops or {}
                            for k, v in pairs(aitroops) do
                                AITroopsFleetVoApi:setWorldWarAITroopsList(k, v)
                            end
                        end
                        -- 军徽
                        local emblemID = tinfo.equip or {}
                        for k, v in pairs(emblemID) do
                            emblemVoApi:setBattleEquip(k + 12, v)
                        end
                        -- 飞机
                        local planePos = tinfo.plane or {}
                        for k, v in pairs(planePos) do
                            planeVoApi:setBattleEquip(k + 12, v)
                        end
                        local airshipTb = tinfo.ap or {}
                        for k, v in pairs(airshipTb) do
                            airShipVoApi:setBattleEquip(k + 12, v)
                        end
                        local ts = tinfo.ts or {}
                        for k, v in pairs(ts) do
                            self:setLastSetFleetTime(k, tonumber(v))
                        end
                        if tinfo.sts then
                            local lastSetStrategyTime = tonumber(tinfo.sts) or 0
                            self:setLastSetStrategyTime(lastSetStrategyTime)
                        end
                    end
                    if(sData.data.applydata.line)then
                        local line = sData.data.applydata.line
                        if line and SizeOfTable(line) > 0 then
                            tankVoApi:setFleetIndexTb(line)
                        end
                    end
                    if(sData.data.applydata.strategy)then
                        local strategy = sData.data.applydata.strategy
                        if strategy and SizeOfTable(strategy) > 0 then
                            self:setPropertyIndexTab(strategy)
                        end
                    end
                end
                
                if(sData.data.point)then
                    self.point = tonumber(sData.data.point)
                else
                    self.point = 0
                end
                --献花信息
                self.betList1 = {}
                self.betList2 = {}
                if(sData.data.bet)then
                    for i = 1, 2 do
                        if(sData.data.bet["p"..i] and sData.data.bet["p"..i][self.worldWarId])then
                            for key, betRecord in pairs(sData.data.bet["p"..i][self.worldWarId]) do
                                if(key ~= "et")then
                                    local keyArr = Split(key, "_")
                                    local roundID = tonumber(keyArr[2])
                                    local battleID = tonumber(string.sub(keyArr[3], 2, string.len(keyArr[3])))
                                    local betData = {i, roundID, battleID, betRecord["uid"], betRecord["count"], betRecord["isGet"]}
                                    local betVo = worldWarBetVo:new()
                                    betVo:init(betData)
                                    self["betList"..i][roundID] = betVo
                                end
                            end
                        end
                    end
                end
                
                if self.playerList == nil then
                    self.playerList = {}
                end
                if sData.data and sData.data.shoplist then
                    -- "pShopItems" 是否显示俩个商店，参赛用户为['pShopItems','aShopItems']
                    if sData.data.shoplist[2] and sData.data.shoplist[2] == "aShopItems" then
                        self:setBuyStatus(2)
                    elseif sData.data.shoplist[1] and sData.data.shoplist[1] == "pShopItems" then
                        self:setBuyStatus(1)
                    end
                end
                
                local record = {}
                if sData.data and sData.data.pointlog then
                    local pointlog = sData.data.pointlog
                    if sData.data.pointlog.p0 then
                        pointlog = sData.data.pointlog.p0
                    end
                    local pointData = pointlog[warId]
                    if pointData then
                        record = pointData.rc --记录
                        local shopData = pointData.lm or {} --商店购买信息
                        --商店数据
                        if shopData then
                            self:getShopInfo(nil, shopData)
                        end
                        --是否领取过排行奖励
                        -- if pointData and pointData.rank then
                        -- self:setIsRewardRank(true)
                        -- end
                        
                    end
                end
                if(sData.data.joincount)then
                    self.pMatchTotalPlayer = tonumber(sData.data.joincount)
                end
                
                -- local scorepointlog={}
                -- if sData.data and sData.data.scorepointlog then
                -- scorepointlog=sData.data.scorepointlog
                -- end
                -- self:formatPointDetail(nil,{record=record,scorepointlog=scorepointlog})
                
                local warStatus = self:checkStatus()
                if(warStatus < 20)then
                    self.warInfoExpireTime = self.startTime + worldWarCfg.signuptime * 86400
                elseif(warStatus < 30)then
                    self.warInfoExpireTime = self.startTime + worldWarCfg.signuptime * 86400 + worldWarCfg.pmatchdays * 86400
                elseif(warStatus < 40)then
                    local lastBattleTime = self.tmatchTimeTb1[#self.tmatchTimeTb1]
                    self.warInfoExpireTime = lastBattleTime
                else
                    self.warInfoExpireTime = self.endTime
                end
                if(self:getRoundStatus(1, 1) == 0)then
                    local zeroTime = G_getWeeTs(self.tmatchTimeTb1[1]) - 86400
                    self.scheduleExpireTime1 = zeroTime + worldWarCfg.pmatchendtime1[1] * 3600 + worldWarCfg.pmatchendtime1[2] * 60 + 240
                end
                if(self:getRoundStatus(2, 1) == 0)then
                    local zeroTime = G_getWeeTs(self.tmatchTimeTb2[1]) - 86400
                    self.scheduleExpireTime2 = zeroTime + worldWarCfg.pmatchendtime2[1] * 3600 + worldWarCfg.pmatchendtime2[2] * 60 + 240
                end
                self:setInitFlag(1)
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:worldWarInit(onRequestEnd)
    elseif(callback)then
        callback()
    end
end

--获取对阵信息
--param type: 要获取的是哪一组对阵信息, 1是NB赛, 2是SB赛
function worldWarVoApi:getScheduleInfo(type, callback)
    if(base.serverTime >= self["scheduleExpireTime"..type])then
        local function onRequestEnd(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if(sData.data.crossuser)then
                    for k, serverData in pairs(sData.data.crossuser) do
                        local playerData = {type = type, zid = serverData[1], uid = serverData[2], fc = serverData[3], nickname = serverData[4], level = serverData[5], pic = serverData[6], aname = serverData[7], topRank = serverData[8], rank = serverData[9]}
                        local playerVo = worldWarPlayerVo:new()
                        playerVo:init(playerData)
                        local flag = false
                        for k, v in pairs(self.playerList) do
                            if(v.id == playerVo.id)then
                                flag = true
                                v:init(playerData)
                                break
                            end
                        end
                        if(flag == false)then
                            table.insert(self.playerList, playerVo)
                        end
                    end
                end
                self["battleList"..type] = {}
                self:initBattleList(sData.data.schedule or {}, type)
                if(sData.data.landform)then
                    local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
                    local landform = sData.data.landform
                    for k, v in pairs(landform) do
                        if v and v[4] and SizeOfTable(v[4]) > 0 then
                            local isSet = false
                            for m, n in pairs(v[4]) do
                                if n and n == selfID then
                                    isSet = true
                                end
                            end
                            if isSet == true then
                                for m, n in pairs(v) do
                                    if m <= 3 then
                                        self:setFleetLandType(m, n)
                                    end
                                end
                            end
                        end
                    end
                end
                local flag = false
                local tmatchRounds = #self["tmatchTimeTb"..type]
                for i = 1, tmatchRounds do
                    local roundStatus = self:getRoundStatus(type, i)
                    if(roundStatus < 20)then
                        self["scheduleExpireTime"..type] = self["tmatchTimeTb"..type][i] + 240
                        flag = true
                        break
                    end
                end
                if(flag == false)then
                    self["scheduleExpireTime"..type] = self.endTime
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:worldwarSchedule(type, onRequestEnd)
    elseif(callback)then
        callback()
    end
end

--根据后台数据初始化对阵信息
--param data: 后台传来的原始数据
--param type: 1为NB赛, 2为SB赛
function worldWarVoApi:initBattleList(data, type)
    local tmpBattleList = {}
    local function sortFunc(a, b)
        return a[5] < b[5]
    end
    for roundID, roundTb in pairs(data) do
        tmpBattleList[roundID] = {}
        local roundLength = worldWarCfg.tmatchplayer / math.pow(2, roundID)
        --最后一轮除了决出总冠军之外还需要加一场季军赛, 所以要加1
        if(roundLength == 1)then
            roundLength = roundLength + 1
        end
        for i = 1, roundLength do
            if(roundTb["g"..i] ~= nil)then
                roundTb["g"..i][7] = roundID
                roundTb["g"..i][8] = i
                roundTb["g"..i][9] = type
                table.insert(tmpBattleList[roundID], roundTb["g"..i])
            else
                local battleData = {"", "", ""}
                battleData[7] = roundID
                battleData[8] = i
                battleData[9] = type
                table.insert(tmpBattleList[roundID], battleData)
            end
        end
    end
    if(#tmpBattleList >= 2)then
        tmpBattleList = self:checkFormatRoundPlayer(tmpBattleList)
    end
    for roundIndex, roundTb in pairs(tmpBattleList) do
        self["battleList"..type][roundIndex] = {}
        for battleIndex, battleData in pairs(roundTb) do
            local battleVo = worldWarBattleVo:new()
            battleVo:init(battleData)
            self["battleList"..type][roundIndex][battleIndex] = battleVo
        end
    end
end

--因为后台返回的下一轮选手的分组不一定能保持与上一轮一致的顺序, 而且格式与前台所需的也有所差别, 所以格式化一下
function worldWarVoApi:checkFormatRoundPlayer(battleList)
    local totalLength = #battleList
    for i = 1, totalLength - 1 do
        local roundLength = #battleList[i]
        for j = 1, roundLength, 2 do
            local winnerID = battleList[i][j][3] or ""
            local nextRoundLength = #battleList[i + 1]
            local nextStartPos = math.ceil(j / 2)
            for k = nextStartPos, nextRoundLength do
                local nextID1 = battleList[i + 1][k][1]
                local nextID2 = battleList[i + 1][k][2]
                if(nextID1 == winnerID or nextID2 == winnerID)then
                    if(nextID2 == winnerID)then
                        local tmp = battleList[i + 1][k][1]
                        battleList[i + 1][k][1] = battleList[i + 1][k][2]
                        battleList[i + 1][k][2] = tmp
                        if(battleList[i + 1][k][6] and battleList[i + 1][k][6][1])then
                            tmp = battleList[i + 1][k][6][1]
                            battleList[i + 1][k][6][1] = battleList[i + 1][k][6][2]
                            battleList[i + 1][k][6][2] = tmp
                        end
                    end
                    local tmp = battleList[i + 1][nextStartPos]
                    battleList[i + 1][nextStartPos] = battleList[i + 1][k]
                    battleList[i + 1][k] = tmp
                    break
                end
            end
        end
    end
    return battleList
end

--报名
--param type: 要报名哪组, 1是NB赛, 2是SB赛
--param callback: 报名完成之后的回调
function worldWarVoApi:signUp(type, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            self.signStatus = type
            eventDispatcher:dispatchEvent("worldwar.signup")
            if(callback)then
                callback()
            end
        end
    end
    socketHelper:worldWarSign(type, onRequestEnd)
end

-- --因为后台返回的下一轮选手的分组不一定能保持与上一轮一致的顺序, 而且格式与前台所需的也有所差别, 所以格式化一下
-- function worldWarVoApi:checkFormatRoundPlayer(battleList)
-- local totalLength=#battleList
-- --先排胜者组, 胜者组是间隔两轮才开一场
-- for i=1,totalLength-2,2 do
-- local roundLength=(#battleList[i])/2
-- --遍历本轮的第1, 3, 5, 7场, 然后为下一场排序, 因为第一场和第二场的冠军在下一轮是排在同一场的同一个table里面的, 所以隔一个遍历就可以
-- for j=1,roundLength,2 do
-- local winnerID=battleList[i][j][3]
-- local nextRoundLength=#battleList[i+2]
-- for k=math.ceil(j/2),nextRoundLength do
-- local nextID1=battleList[i+2][k][1]
-- local nextID2=battleList[i+2][k][2]
-- if(nextID1==winnerID or nextID2==winnerID)then
-- --如果是下一场比赛的第二个人与本场的胜者ID相同, 那么就得把下场比赛的两个人的顺序颠倒一下
-- if(nextID2==winnerID)then
-- local tmp=battleList[i+2][k][1]
-- battleList[i+2][k][1]=battleList[i+2][k][2]
-- battleList[i+2][k][2]=tmp
-- end
-- --把下一场比赛放到应有的位置上
-- local tmp=battleList[i+2][math.ceil(j/2)]
-- battleList[i+2][math.ceil(j/2)]=battleList[i+2][k]
-- battleList[i+2][k]=tmp
-- break
-- end
-- end
-- end
-- end
-- --再排败者组
-- for i=1,totalLength-1 do
-- if(i==#self.timeTb-2)then
-- break
-- end
-- local roundLength=#battleList[i]
-- --如果是奇数轮, 那么遍历的初始下标要增加一个偏移量
-- local offset
-- --如果是奇数轮的话, 那么每一个元素都需要排序, 与上面的不同, 因为败者组的奇数轮的两场比赛的胜者在下一轮并不分在同一场, 偶数轮则与上面胜者组相同, 因为偶数轮相邻两场比赛的胜者在下一轮是同一场
-- local interval
-- if(i%2==0)then
-- offset=0
-- interval=2
-- else
-- offset=math.floor(roundLength/2)
-- interval=1
-- end
-- for j=1+offset,roundLength,interval do
-- local winnerID=battleList[i][j][3]
-- local nextRoundLength=#battleList[i+1]
-- local nextStartPos
-- --分情况决定遍历下一轮比赛的初始场次下标
-- if(i%2==0)then
-- nextStartPos=math.ceil(j/2)+math.floor(roundLength/2)
-- else
-- nextStartPos=j-offset
-- end
-- for k=nextStartPos,nextRoundLength do
-- local nextID1=battleList[i+1][k][1]
-- local nextID2=battleList[i+1][k][2]
-- if(nextID1==winnerID or nextID2==winnerID)then
-- --以下两个换位的原理同上
-- if(nextID2==winnerID)then
-- local tmp=battleList[i+1][k][1]
-- battleList[i+1][k][1]=battleList[i+1][k][2]
-- battleList[i+1][k][2]=tmp
-- end
-- local tmp=battleList[i+1][nextStartPos]
-- battleList[i+1][nextStartPos]=battleList[i+1][k]
-- battleList[i+1][k]=tmp
-- break
-- end
-- end
-- end
-- end
-- return battleList
-- end

--积分赛根据rid获取report
function worldWarVoApi:getBattleReportByRid(rid)
    local list = self:getMyReportList(1)
    for k, v in pairs(list) do
        if v and v.rid == rid and v.battleData and v.battleData.report then
            return v.battleData.report
        end
    end
    return {}
end

function worldWarVoApi:getMyPMatchBattleData(rid)
    local list = self:getMyReportList(1)
    for k, v in pairs(list) do
        if v and v.rid == rid and v.battleData then
            return v.battleData
        end
    end
    return {}
end
--从后台获取战报, 观看战斗
--param type: 1积分，2淘汰
--param bType: 1大师，2精英
--param roundIndex: 比赛轮次
--param battleID: 比赛的ID
--param battleIndex: 一场比赛有三局, 要观看的是第几局
function worldWarVoApi:getBattleReport(type, bType, roundIndex, battleID, battleIndex, rid)
    if type == 1 then
        if rid then
            local battleData = self:getMyPMatchBattleData(rid)
            if(battleData and battleData.report and battleData.report[battleIndex] and SizeOfTable(battleData.report[battleIndex]) > 0)then
                self:showBattleScene(roundIndex, battleData.report[battleIndex], battleData.landType[battleIndex])
            elseif self.worldWarUrl then
                local httpUrl = "http://"..self.worldWarUrl.."/tank-server/public/index.php/api/worldwar/pointMatchReport/detail"
                print("httpUrl", httpUrl)
                local reqStr = "rid="..rid
                local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                -- deviceHelper:luaPrint("libaoret:"..retStr)
                if(retStr ~= "")then
                    local retData = G_Json.decode(retStr)
                    if retData and retData.ret == 0 then
                        if retData.data and retData.data.detail then
                            local reportList = retData.data.detail or {}
                            for k, v in pairs(reportList) do
                                self:setBattleInfo(type, rid, nil, nil, k, v)
                                if battleIndex == k then
                                    self:showBattleScene(roundIndex, v, battleData.landType[battleIndex])
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        local function getReportHandler(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData and sData.data and sData.data.report then
                    local reportData = sData.data.report
                    local report = reportData.info
                    if report and SizeOfTable(report) > 0 then
                        self:setBattleInfo(type, roundIndex, roundIndex, battleID, battleIndex, report, bType)
                        local battleVo = worldWarVoApi:getBattleData(bType, roundIndex, battleID)
                        self:showBattleScene(roundIndex, report, battleVo.landType[battleIndex])
                    end
                end
            end
        end
        local battleVo = worldWarVoApi:getBattleData(bType, roundIndex, battleID)
        if battleVo and battleVo.report and battleVo.report[battleIndex] and SizeOfTable(battleVo.report[battleIndex]) > 0 then
            local report = battleVo.report[battleIndex]
            self:showBattleScene(roundIndex, report, battleVo.landType[battleIndex])
        else
            --比赛Id
            local bid = self:getWorldWarId()
            if bid then
                local pos = "g"..battleID
                socketHelper:worldwarReport(bType, bid, roundIndex, pos, battleIndex, getReportHandler)
            end
        end
    end
end

function worldWarVoApi:setBattleInfo(type, rid, roundIndex, battleID, battleIndex, report, bType)
    if type == 1 then
        if self.myReportList and SizeOfTable(self.myReportList) > 0 then
            for k, v in pairs(self.myReportList) do
                if v and v.rid == rid then
                    if(self.myReportList[k].battleData.report == nil)then
                        self.myReportList[k].battleData.report = {}
                    end
                    if(report)then
                        self.myReportList[k].battleData.report[battleIndex] = report
                    end
                end
            end
        end
    else
        if bType and self["battleList"..bType] and roundIndex and self["battleList"..bType][roundIndex] then
            for k, v in pairs(self["battleList"..bType][roundIndex]) do
                if v and v.battleID == battleID then
                    if self["battleList"..bType][roundIndex][k].report == nil then
                        self["battleList"..bType][roundIndex][k].report = {}
                    end
                    self["battleList"..bType][roundIndex][k].report[battleIndex] = report
                end
            end
        end
    end
end

function worldWarVoApi:showBattleScene(roundIndex, report, landType)
    local data = {data = {report = report}, isReport = true}
    if(landType)then
        data.landform = {landType, landType}
    end
    battleScene:initData(data)
end

--获取某场比赛在battleList中的数据
--param type: 1是NB赛, 2是SB赛
--param roundID: 比赛所在的轮次,
--param battleID: 比赛的ID
--return 一个worldWarBattleVo或者nil
function worldWarVoApi:getBattleData(type, roundID, battleID)
    local battleList = self["battleList"..type]
    if(battleList)then
        local roundList = battleList[roundID]
        if(roundList)then
            for k, v in pairs(roundList) do
                if(v.battleID == battleID)then
                    return v
                end
            end
        end
    end
    return nil
end

--获取某一轮的献花数据
--param roundIndex: 要获取第几轮的数据
--return 一个worldWarBetVo或者nil
function worldWarVoApi:getBetData(type, roundIndex)
    if type and self["betList"..type] and roundIndex then
        return self["betList"..type][roundIndex]
    end
    return nil
end

--根据ID获取玩家的数据vo
--param id: 要获取数据的id(zoneid+uid), 只有进入淘汰赛阶段才能取到其他人的数据
function worldWarVoApi:getPlayer(id)
    if(id == nil)then
        return nil
    end
    if id and self.playerList then
        for k, v in pairs(self.playerList) do
            if(v.id == id)then
                return v
            end
        end
    end
    return nil
end

--给某场比赛送花
--param type: 1是NB赛, 2是SB赛
--param roundID: 轮次ID
--param battleID: 场次ID
--param playerID: 给哪个选手送花
function worldWarVoApi:bet(type, roundID, battleID, playerID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(self["betList"..type][roundID])then
                self["betList"..type][roundID].times = self["betList"..type][roundID].times + 1
                self["betList"..type][roundID].battleID = battleID
                self["betList"..type][roundID].playerID = playerID
            else
                local betVo = worldWarBetVo:new()
                betVo:init({type, roundID, battleID, playerID, 1, 0})
                self["betList"..type][roundID] = betVo
            end
            local gems = tonumber(sData.data.gems)
            if(gems)then
                playerVoApi:setGems(gems)
            end
            if(callback)then
                callback()
            end
        end
    end
    local matchId = self:getWorldWarId()
    local detailId = self:getConnectId(matchId, roundID, battleID)
    socketHelper:worldwarBet(matchId, detailId, playerID, type, onRequestEnd)
end

function worldWarVoApi:getFleetLandType(fleetIndex)
    if self.landtype == nil then
        self.landtype = {}
    end
    if fleetIndex and self.landtype[fleetIndex] then
        return self.landtype[fleetIndex]
    end
    return 0
end
function worldWarVoApi:setFleetLandType(fleetIndex, landtype)
    if self.landtype == nil then
        self.landtype = {}
    end
    if fleetIndex then
        self.landtype[fleetIndex] = landtype
    end
end
function worldWarVoApi:getLastSetStrategyTime()
    return self.lastSetStrategyTime
end
function worldWarVoApi:setLastSetStrategyTime(time)
    self.lastSetStrategyTime = time
end

function worldWarVoApi:getLastSetFleetTime(index)
    if index then
        return self.lastSetFleetTime[index]
    end
    return 0
end
function worldWarVoApi:setLastSetFleetTime(index, time)
    if index and time and self.lastSetFleetTime and self.lastSetFleetTime[index] then
        self.lastSetFleetTime[index] = time
    end
end

function worldWarVoApi:getIsCanSetFleet(index, layerNum, isShowTip)
    if isShowTip == nil then
        isShowTip = true
    end
    local lastTime = self:getLastSetFleetTime(index)
    if lastTime then
        local leftTime = worldWarCfg.settingTroopsLimit - (base.serverTime - lastTime)
        if leftTime > 0 then
            do return false end
        end
    end
    
    local isEable = true
    local num = 0;
    local type = index + 12
    for k, v in pairs(tankVoApi:getTanksTbByType(type)) do
        if SizeOfTable(v) == 0 then
            num = num + 1;
        end
    end
    if num == 6 then
        isEable = false
    end
    if isEable == false then
        if isShowTip == true then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("allianceWarNoArmy"), nil, layerNum + 1, nil)
        end
        do return false end
    end
    return true
end

-- 0 可以设置
-- world_war_cannot_set_fleet1="比赛尚未开启，无法进行部队设置！",
-- world_war_cannot_set_fleet2="战斗即将开始，无法设置部队",
-- world_war_cannot_set_fleet3="战斗进行中，无法设置部队!",
-- world_war_cannot_set_fleet4="战斗已结束，无法设置部队！",
-- world_war_cannot_set_fleet5="您未参加世界争霸，无法进行部队设置！",
-- world_war_cannot_set_fleet6="您已被淘汰，无法设置部队！",
function worldWarVoApi:getSetFleetStatus()
    local status = self:checkStatus()
    local signStatus = self:getSignStatus()
    -- print("status",status)
    -- print("signStatus",signStatus)
    if signStatus == nil then
        return 5
    elseif status >= 10 and status < 20 then
        return 0
    elseif status >= 20 and status < 30 then
        local pMatchStatus = self:checkPMatchStatus(signStatus)
        -- print("pMatchStatus",pMatchStatus)
        if pMatchStatus > 0 and pMatchStatus < 10 then
            return 0
        elseif pMatchStatus >= 10 and pMatchStatus < 20 then
            return 2
        elseif pMatchStatus >= 20 and pMatchStatus < 30 then
            return 3
        elseif pMatchStatus >= 30 then
            local lastPMatchTime = G_getWeeTs(self.startTime) + (worldWarCfg.signuptime + worldWarCfg.pmatchdays - 1) * 86400 + worldWarCfg["pmatchendtime"..signStatus][1] * 3600 + worldWarCfg["pmatchendtime"..signStatus][2] * 60
            if base.serverTime > lastPMatchTime then
                if self:checkIsPlayer() == false then
                    return 6
                end
            end
            return 0
        end
    elseif status >= 30 and status < 40 then
        if self:checkIsPlayer() == false then
            return 6
        else
            local setFleetStatus = self:getSendFlowerStatus(signStatus, true)
            if setFleetStatus > 20 and setFleetStatus < 30 then
                return 3
            elseif self:checkIsOut(signStatus) == true then
                return 6
            elseif setFleetStatus == 10 then
                return 0
            elseif setFleetStatus == 11 then
                return 2
            elseif setFleetStatus == 30 then
                return 4
            else
                return 1
            end
        end
    elseif status >= 40 then
        return 4
    end
    return 1
end

-- function worldWarVoApi:getIsAllSetFleet()
-- local canSet=self:getSetFleetStatus()
-- if canSet==0 then
-- local isAllSet=tankVoApi:serverWarAllSetFleet()
-- if isAllSet==false then
-- return false
-- end
-- end
-- return true
-- end

--根据第几轮和献花次数，获得献花数量,isPoint:是否是取获得的积分
--type:1 大师，2 精英
function worldWarVoApi:getSendFlowerNum(type, roundID, num, isPoint, isWin)
    if type and roundID and num then
        local cfgIndex = worldWarCfg["betStyle4Round"..type][roundID]
        if cfgIndex then
            local winnerCfg = worldWarCfg["winner_"..cfgIndex]
            local failerCfg = worldWarCfg["failer_"..cfgIndex]
            if isPoint == true then
                local cfg
                if isWin ~= nil then
                    if isWin == true then
                        cfg = winnerCfg
                    else
                        cfg = failerCfg
                    end
                    if cfg and cfg[num] then
                        return cfg[num]
                    end
                end
            else
                if winnerCfg and winnerCfg[num] then
                    return winnerCfg[num]
                end
            end
        end
    end
    return 0
end

function worldWarVoApi:isShowBetRewardTip()
    local isShow = false
    for i = 1, 2 do
        local betList = self:getBetList(i)
        if betList and SizeOfTable(betList) > 0 then
            for k, v in pairs(betList) do
                if v and v.roundID then
                    local roundStatus = self:getRoundStatus(i, v.roundID)
                    if roundStatus and roundStatus >= 30 then --结束
                        if v.hasGet and v.hasGet == 1 then
                        else
                            isShow = true
                        end
                    end
                end
            end
        end
    end
    return isShow
end

function worldWarVoApi:betReward(type, roundID, point)
    if self["betList"..type] and roundID and self["betList"..type][roundID] then
        self["betList"..type][roundID].hasGet = 1
    end
    self:setPoint(self:getPoint() + point)
    self:addPointDetail({}, 1)
end

function worldWarVoApi:getTotalBetListNum()
    local num = 0
    for i = 1, 2 do
        local list = self:getBetList(i)
        num = num + SizeOfTable(list)
    end
    return num
end
function worldWarVoApi:getTotalBetList()
    local betList = {}
    for i = 1, 2 do
        local list = self:getBetList(i)
        for k, v in pairs(list) do
            table.insert(betList, v)
        end
    end
    local function sortFunc(a, b)
        if a and b and a.roundID and b.roundID then
            if a.roundID == b.roundID then
                if a.type and b.type then
                    return a.type < b.type
                end
            else
                return a.roundID > b.roundID
            end
        end
    end
    table.sort(betList, sortFunc)
    return betList
end

-- ------------以下世界争霸商店----------------
--世界争霸商店开启后，是否打开过,true：不显示，false：显示
function worldWarVoApi:getShopHasOpen()
    -- local status=self:checkStatus()
    -- if status and status>=30 then
    local status = self:getShopShowStatus()
    if status > 0 then
        local dataKey = "worldWarShopHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getWorldWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if (localData ~= nil and localData ~= "") then
            return true
        else
            return false
        end
    end
    return true
end
function worldWarVoApi:setShopHasOpen()
    -- local status=self:checkStatus()
    -- if status and status>=30 then
    local status = self:getShopShowStatus()
    if status > 0 then
        local dataKey = "worldWarShopHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getWorldWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        CCUserDefault:sharedUserDefault():setStringForKey(dataKey, "open")
    end
end
--普通道具配置
function worldWarVoApi:getShopCommonItems()
    if self.f_pShopItems and next(self.f_pShopItems) then
        do return self.f_pShopItems end
    end
    self.f_pShopItems = {}
    for k, v in pairs(worldWarCfg.pShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_pShopItems[k] = v
        end
    end
    return self.f_pShopItems
end
--珍品配置
function worldWarVoApi:getShopRareItems()
    if self.f_aShopItems and next(self.f_aShopItems) then
        do return self.f_aShopItems end
    end
    self.f_aShopItems = {}
    for k, v in pairs(worldWarCfg.aShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_aShopItems[k] = v
        end
    end
    return self.f_aShopItems
end
function worldWarVoApi:getShopFlag()
    return self.shopFlag
end
function worldWarVoApi:setShopFlag(shopFlag)
    self.shopFlag = shopFlag
end
function worldWarVoApi:getBuyStatus()
    return self.buyStatus
end
function worldWarVoApi:setBuyStatus(buyStatus)
    self.buyStatus = buyStatus
end
function worldWarVoApi:getShopShowStatus()
    local status = self:checkStatus()
    local buyStatus = self:getBuyStatus()
    local signStatus = self:getSignStatus()
    if status and status >= 40 then
        if signStatus ~= nil and buyStatus == 2 then
            return 2
        end
        return 1
    end
    return 0
end

--根据id获取道具的配置
function worldWarVoApi:getItemById(id)
    local item = nil
    if id then
        local commonList = self:getShopCommonItems()
        local rareList = self:getShopRareItems()
        local key = string.sub(id, 1, 1)
        if key == "i" then
            if commonList[id] then
                item = commonList[id]
            end
        elseif key == "a" then
            if rareList[id] then
                item = rareList[id]
            end
        end
    end
    return item
end
--初始化世界争霸的商店信息
function worldWarVoApi:initShopInfo()
    local commonItems = self:getShopCommonItems()
    local rareItems = self:getShopRareItems()
    self.commonList = {}
    self.rareList = {}
    for k, v in pairs(commonItems) do
        local vo = worldWarShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.commonList, vo)
    end
    for k, v in pairs(rareItems) do
        local vo = worldWarShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.rareList, vo)
    end
    local function sortAsc(a, b)
        if a and b and a.id and b.id then
            local aid = (tonumber(a.id) or tonumber(RemoveFirstChar(a.id)))
            local bid = (tonumber(b.id) or tonumber(RemoveFirstChar(b.id)))
            if aid and bid then
                return aid < bid
            end
        end
    end
    table.sort(self.commonList, sortAsc)
    table.sort(self.rareList, sortAsc)
end
--获取世界争霸的商店信息
--param callback: 获取之后的回调函数
function worldWarVoApi:getShopInfo(callback, data)
    local shopFlag = self:getShopFlag()
    if shopFlag == -1 then
        self:initShopInfo()
        self:setShopFlag(1)
    end
    
    if data then
        if self.commonList == nil or self.rareList == nil then
            self:initShopInfo()
        end
        for k, v in pairs(data) do
            local key = string.sub(k, 1, 1)
            if key == "i" then
                for m, n in pairs(self.commonList) do
                    if n and n.id == k then
                        self.commonList[m].num = v
                    end
                end
            elseif key == "a" then
                for m, n in pairs(self.rareList) do
                    if n and n.id == k then
                        self.rareList[m].num = v
                    end
                end
            end
        end
    end
    
    if(callback)then
        callback()
    end
end

function worldWarVoApi:getPointDetailFlag()
    return self.pointDetailFlag
end
function worldWarVoApi:setPointDetailFlag(pointDetailFlag)
    self.pointDetailFlag = pointDetailFlag
end

function worldWarVoApi:getDetailExpireTime()
    return self.detailExpireTime
end
function worldWarVoApi:setDetailExpireTime(detailExpireTime)
    self.detailExpireTime = detailExpireTime
end

function worldWarVoApi:clearPointDetail()
    if self.pointDetail ~= nil then
        for k, v in pairs(self.pointDetail) do
            self.pointDetail[k] = nil
        end
        self.pointDetail = nil
    end
    self.pointDetail = {}
    -- self.page=0
    -- self.hasMore=false
    self.pointDetailFlag = -1
    self.detailExpireTime = 0
end
--初始化积分明细
function worldWarVoApi:formatPointDetail(callback)
    local function getRecordHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            local pdData = sData.data
            if pdData and SizeOfTable(pdData) > 0 then
                self.pointDetail = nil
                self.pointDetail = {}
                
                --商店积分
                if pdData and pdData.point then
                    self:setPoint(tonumber(pdData.point))
                end
                
                --积分赛战斗获得积分
                local splog = pdData.scorepointlog
                local scorepointlog = {}
                if splog then
                    if type(splog) == "string" then
                        local arr = Split(splog, ",")
                        scorepointlog = arr
                    else
                        scorepointlog = splog
                    end
                end
                local winNum = 0
                local loseNum = 0
                self.pMatchResultTb = {}
                local curRound = self:getPMatchCurRound()
                if self.signStatus and scorepointlog and SizeOfTable(scorepointlog) > 0 then
                    for k, v in pairs(scorepointlog) do
                        local vv = tonumber(v)
                        if(k <= curRound and vv)then
                            if(vv == worldWarCfg["tmatchPoint"..self.signStatus][0])then
                                table.insert(self.pMatchResultTb, 0)
                                loseNum = loseNum + 1
                            elseif(vv == worldWarCfg["tmatchPoint"..self.signStatus][1])then
                                table.insert(self.pMatchResultTb, 1)
                                loseNum = loseNum + 1
                            elseif(vv == worldWarCfg["tmatchPoint"..self.signStatus][2])then
                                table.insert(self.pMatchResultTb, 2)
                                winNum = winNum + 1
                            elseif(vv == worldWarCfg["tmatchPoint"..self.signStatus][3])then
                                table.insert(self.pMatchResultTb, 3)
                                winNum = winNum + 1
                            end
                        end
                        local type, time, message, color = self:formatMessage({vv, k}, 0)
                        if type and time and message then
                            local isInsert = false
                            if (type == 3 or type == 4) then
                                if base.serverTime >= time then
                                    isInsert = true
                                end
                            else
                                isInsert = true
                            end
                            if isInsert == true then
                                local vo = worldWarPointDetailVo:new()
                                vo:initWithData(type, time, message, color)
                                table.insert(self.pointDetail, vo)
                            end
                        end
                    end
                end
                self.pMatchWinMatch = winNum
                self.pMatchLoseMatch = loseNum
                
                --淘汰赛献花和战斗获得积分
                -- local record=sData.data.record
                local record = pdData.record
                if record and record.add and SizeOfTable(record.add) > 0 then
                    for k, v in pairs(record.add) do
                        local type, time, message, color = self:formatMessage(v, 1)
                        if type and time and message then
                            local vo = worldWarPointDetailVo:new()
                            vo:initWithData(type, time, message, color)
                            table.insert(self.pointDetail, vo)
                        end
                    end
                end
                if record and record.buy and SizeOfTable(record.buy) > 0 then
                    for k, v in pairs(record.buy) do
                        local type, time, message, color = self:formatMessage(v, 2)
                        if type and time and message then
                            local vo = worldWarPointDetailVo:new()
                            vo:initWithData(type, time, message, color)
                            table.insert(self.pointDetail, vo)
                        end
                    end
                end
                local function sortAsc(a, b)
                    if a and b and a.time and b.time and tonumber(a.time) and tonumber(b.time) then
                        return tonumber(a.time) > tonumber(b.time)
                    end
                end
                table.sort(self.pointDetail, sortAsc)
                
                if self.pointDetail then
                    while SizeOfTable(self.pointDetail) > worldWarCfg.militaryrank do
                        table.remove(self.pointDetail, worldWarCfg.militaryrank + 1)
                    end
                end
                if(pdData.ranking)then
                    --后端的排名是从0开始的, 所以要加1
                    self.pMatchRank = tonumber(pdData.ranking) + 1
                else
                    self.pMatchRank = 0
                end
                
                local checkStatus = self:checkStatus()
                if(checkStatus < 20)then
                    self.detailExpireTime = self:getPMatchExpireTime(true)
                elseif checkStatus >= 20 and checkStatus < 30 then
                    -- local pmatchTimeTb=self:getPointBattleTimeList()
                    -- for k,v in pairs(pmatchTimeTb) do
                    -- local time=tonumber(v)
                    -- if base.serverTime<time then
                    -- self.detailExpireTime=time
                    -- break
                    -- end
                    -- end
                    self.detailExpireTime = self:getPMatchExpireTime(true)
                elseif checkStatus >= 30 and checkStatus < 40 then
                    -- local nextRoundID
                    -- --bType：1大师，2精英，现在2者开战时间一样，任取一个
                    -- local bType=1
                    -- local timeTb=self:getBattleTimeList(bType)
                    -- for i=0,#timeTb-1 do
                    -- local roundStatus=self:getRoundStatus(bType,i)
                    -- if(roundStatus<20)then
                    -- nextRoundID=i
                    -- break
                    -- end
                    -- end
                    -- if(nextRoundID)then
                    -- self.detailExpireTime=timeTb[nextRoundID]+worldWarCfg.battleTime*3
                    -- else
                    -- self.detailExpireTime=self.endTime
                    -- end
                    local bType = self:getSignStatus()
                    self.detailExpireTime = self:getTMatchExpireTime(bType)
                else
                    self.detailExpireTime = self.endTime
                end
            end
            self:setPointDetailFlag(1)
            
            if(callback)then
                callback()
            end
        end
    end
    if self:getPointDetailFlag() == -1 then
        local function getScheduleInfoHandler1()
            local function getScheduleInfoHandler2()
                local jointype = self:getSignStatus()
                socketHelper:worldwarRecord(jointype, getRecordHandler)
            end
            self:getScheduleInfo(2, getScheduleInfoHandler2)
        end
        self:getScheduleInfo(1, getScheduleInfoHandler1)
    else
        if(callback)then
            callback()
        end
    end
end

--获取淘汰赛的轮次描述
--roundID 轮次
--battleID 战斗id
--bType 1大师，2精英
function worldWarVoApi:getRoundTitleStr(roundID, battleID, bType)
    local roundStr = ""
    local areaStr = ""
    local bTypeStr = ""
    if roundID then
        roundStr = self:getRoundStr(roundID, bType, false)
        if battleID then
            local groupID, groupStr = self:getGroupIDByBIDAndRID(roundID, battleID)
            areaStr = groupStr
        end
    end
    if bType then
        if bType == 1 then
            bTypeStr = getlocal("world_war_sub_title12")
        else
            bTypeStr = getlocal("world_war_sub_title13")
        end
    end
    local str = ""
    if roundID >= 5 then
        str = getlocal("world_war_group_"..bType)
    else
        str = getlocal("world_war_scheduleTitle", {bTypeStr, areaStr})
    end
    local areaRoundStr = getlocal("world_war_exclude_report", {str, roundStr})
    return areaRoundStr
end

function worldWarVoApi:formatMessage(data, mType)
    local id
    local type
    local time = 0
    local point = 0
    local targetName = ""
    local fType
    local roundNum = 0
    local battleIndex = 1
    local color = G_ColorGreen
    local rank = 0
    local bType --战斗类型，1,大师，2精英
    if mType == 0 then
        point = tonumber(data[1]) or 0
        battleIndex = data[2]
        local index = 0
        for k, v in pairs(worldWarCfg.tmatchPoint1) do
            if point == v then
                index = k
            end
        end
        for k, v in pairs(worldWarCfg.tmatchPoint2) do
            if point == v then
                index = k
            end
        end
        if index >= 2 and index < 4 then
            type = 3
        else
            type = 4
        end
        if battleIndex then
            local pmatchTimeTb = self:getPointBattleTimeList()
            time = pmatchTimeTb[battleIndex]
        end
    elseif mType == 1 then
        if data and SizeOfTable(data) > 0 then
            point = tonumber(data[1]) or 0
            fType = tonumber(data[2])
            id = data[3]
            time = tonumber(data[4]) or 0
            bType = self:getSignStatus()
            if fType == 0 then
                bType = tonumber(data[5]) or 0
            end
        end
        if fType == 2 then
            type = 8
            rank = tonumber(data[5]) or 0
        else
            local warId, roundID, battleID = self:getFormatId(id)
            local battleVo = self:getBattleData(bType, roundID, battleID)
            roundNum = roundID
            if fType == 0 then
                local betVo = self:getBetData(bType, roundID)
                if betVo then
                    local targetId = betVo.playerID
                    if targetId then
                        local playerVo = self:getPlayer(targetId)
                        if playerVo then
                            targetName = playerVo.name or ""
                        end
                        if targetId and battleVo and battleVo.winnerID and tostring(targetId) == tostring(battleVo.winnerID) then
                            type = 1
                        else
                            type = 2
                        end
                    end
                end
            elseif fType == 1 then
                if battleVo then
                    local targetId
                    local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
                    if battleVo.id1 and battleVo.id1 == selfID then
                        targetId = battleVo.id2
                    elseif battleVo.id2 and battleVo.id2 == selfID then
                        targetId = battleVo.id1
                    end
                    if targetId then
                        local playerVo = self:getPlayer(targetId)
                        if playerVo then
                            targetName = playerVo.name or ""
                        end
                    end
                    -- if roundID==0 then
                    -- if battleVo.winnerID and battleVo.winnerID==selfID then
                    -- type=3
                    -- else
                    -- type=4
                    -- end
                    -- else
                    if battleVo.winnerID and battleVo.winnerID == selfID then
                        type = 5
                    else
                        type = 6
                    end
                    -- end
                end
            end
        end
        if point == 0 then
            color = G_ColorWhite
        end
    elseif mType == 2 then
        if data and data[1] then
            type = 7
            color = G_ColorRed
            itemId = data[1]
            time = tonumber(data[2]) or 0
            local cfg = self:getItemById(itemId)
            if cfg then
                if cfg.reward then
                    local rewardTb = FormatItem(cfg.reward)
                    local item = rewardTb[1]
                    targetName = item.name.."x"..item.num
                end
                if cfg.price then
                    point = tonumber(cfg.price)
                end
            end
        end
    end
    local params = {}
    local message = ""
    local isEmpty = false
    if type then
        if type == 1 or type == 2 then
            params = {targetName, point}
        elseif type == 3 or type == 4 then
            params = {battleIndex, point}
        elseif type == 5 or type == 6 then
            local areaRoundStr = self:getRoundTitleStr(roundNum, battleIndex, bType)
            if type == 5 and (targetName == nil or targetName == "") then
                isEmpty = true
                params = {areaRoundStr, point}
            else
                params = {areaRoundStr, targetName, point}
            end
        elseif type == 7 then
            params = {targetName, point}
        elseif type == 8 then
            params = {rank, point}
        end
        if type == 5 and isEmpty == true then
            message = getlocal("world_war_point_desc_"..type.."1", params)
        else
            message = getlocal("world_war_point_desc_"..type, params)
        end
    end
    return type, time, message, color
end
function worldWarVoApi:addPointDetail(data, mType)
    if self:getPointDetailFlag() == -1 then
        local function callback()
            self:setPointDetailFlag(0)
        end
        self:formatPointDetail(callback)
        do return end
    end
    
    local type, time, message, color
    if mType == 1 then
        self:setPointDetailFlag(-1)
        do return end
    elseif mType == 2 then
        type, time, message, color = self:formatMessage(data, 2)
    elseif mType == 3 then
        type, time, message, color = self:formatMessage(data, 1)
    end
    if type and time and message then
        local isInsert = false
        if (type == 3 or type == 4) then
            if base.serverTime >= time then
                isInsert = true
            end
        else
            isInsert = true
        end
        if isInsert == true then
            local vo = worldWarPointDetailVo:new()
            vo:initWithData(type, time, message, color)
            table.insert(self.pointDetail, vo)
            
            local function sortAsc(a, b)
                if a and b and a.time and b.time and tonumber(a.time) and tonumber(b.time) then
                    return tonumber(a.time) > tonumber(b.time)
                end
            end
            table.sort(self.pointDetail, sortAsc)
            
            self:setPointDetailFlag(0)
        end
    end
    
    if self.pointDetail then
        while SizeOfTable(self.pointDetail) > worldWarCfg.militaryrank do
            table.remove(self.pointDetail, worldWarCfg.militaryrank + 1)
        end
    end
end

function worldWarVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
    return date
end

--购买物品 type:1：道具，2：珍品 id：物品id
function worldWarVoApi:buyItem(type, id, callback)
    local function buyHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if type == 1 then
                local commonItems = self:getShopCommonItems()
                for k, v in pairs(self.commonList) do
                    if v.id == id then
                        self.commonList[k].num = self.commonList[k].num + 1
                    end
                end
                local cfg = commonItems[id]
                local rewardTb = FormatItem(cfg.reward)
                local price = cfg.price
                self:setPoint(self:getPoint() - price)
                for k, v in pairs(rewardTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                end
                G_showRewardTip(rewardTb, true)
                
                local addData = {id, sData.ts}
                self:addPointDetail(addData, 2)
            elseif type == 2 then
                local rareItems = self:getShopRareItems()
                for k, v in pairs(self.rareList) do
                    if v.id == id then
                        self.rareList[k].num = self.rareList[k].num + 1
                    end
                end
                local cfg = rareItems[id]
                local rewardTb = FormatItem(cfg.reward)
                local price = cfg.price
                self:setPoint(self:getPoint() - price)
                for k, v in pairs(rewardTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                end
                G_showRewardTip(rewardTb, true)
                
                local addData = {id, sData.ts}
                self:addPointDetail(addData, 2)
            end
            if callback then
                callback()
            end
        end
    end
    local sType
    if type == 1 then
        sType = "pShopItems"
    elseif type == 2 then
        sType = "aShopItems"
    end
    local matchId = self:getWorldWarId()
    if matchId and sType and id then
        socketHelper:worldwarBuy(matchId, sType, id, buyHandler)
    end
end

--获取商店里面的道具列表
function worldWarVoApi:getCommonList()
    if (self.commonList) then
        return self.commonList
    end
    return {}
end
--获取商店里面的珍品列表
function worldWarVoApi:getRareList()
    if (self.rareList) then
        return self.rareList
    end
    return {}
end
--获取积分明细
function worldWarVoApi:getPointDetail()
    if (self.pointDetail) then
        return self.pointDetail
    end
    return {}
end
--积分
function worldWarVoApi:getPoint()
    return self.point
end
function worldWarVoApi:setPoint(point)
    self.point = point
end
--我的排名
function worldWarVoApi:getMyRank()
    return self.myRank
end
function worldWarVoApi:setMyRank(myRank)
    self.myRank = myRank
end
--自己根据排名，可以领取的积分
function worldWarVoApi:getRewardPoint()
    local point = 0
    local myRank = self:getMyRank()
    if myRank and myRank > 0 then
        for k, v in pairs(worldWarCfg.rankReward) do
            local minRank = v.range[1]
            local maxRank = v.range[2]
            if myRank >= minRank and myRank <= maxRank then
                point = v.point
            end
        end
    end
    return point
end
--是否已经领取过排行奖励
-- function worldWarVoApi:getIsRewardRank()
-- return self.isRewardRank
-- end
-- function worldWarVoApi:setIsRewardRank(isRewardRank)
-- self.isRewardRank=isRewardRank
-- end
--领取排行榜奖励
-- function worldWarVoApi:rewardRank(callback)
-- local function rewardCallback(fn,data)
-- local ret,sData=base:checkServerData(data)
-- if ret==true then
--         self:setIsRewardRank(true)
--         local point=self:getPoint()
--         local rewardPoint=self:getRewardPoint()
--         self:setPoint(point+rewardPoint)

--         local myRank=self:getMyRank()
-- local data={rewardPoint,2,"",sData.ts,myRank}
--         self:addPointDetail(data,3)

--         if callback then
-- callback()
-- end
--     end
-- end
--    socketHelper:crossGetrankingreward(rewardCallback)
-- end
-- ------------以上世界争霸商店----------------

-- ------------以下排行榜----------------
-- --排行榜开启后，是否打开过,打开过true：不显示，未开过false：显示
-- function worldWarVoApi:getRankHasOpen()
-- local status=self:checkStatus()
-- if status and status>=30 then
-- local dataKey="serverWarRankHasOpen@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(self:getWorldWarId())
-- local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
-- if (localData~=nil and localData~="") then
--         return true
--     else
--         return false
--     end
-- end
-- return true
-- end
-- function worldWarVoApi:setRankHasOpen()
-- local status=self:checkStatus()
-- if status and status>=30 then
-- local dataKey="serverWarRankHasOpen@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(self:getWorldWarId())
-- local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
-- CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"open")
-- end
-- end

-- function worldWarVoApi:getRankFlag()
-- return self.rankFlag
-- end
-- function worldWarVoApi:setRankFlag(rankFlag)
-- self.rankFlag=rankFlag
-- end

function worldWarVoApi:getRankExpireTime(type)
    if type and self.rankExpireTime then
        return self.rankExpireTime[type]
    else
        return - 1
    end
end
--战斗结束后排行榜
function worldWarVoApi:clearRankList()
    self.rankList = {{}, {}, {}, {}}
end
function worldWarVoApi:formatRankList(type, callback)
    local isSuccess = false
    local status = self:checkStatus()
    if base.serverTime > self.rankExpireTime[type] then
        if type == 1 or type == 2 then
            local round = self:getPMatchCurRound()
            if status >= 20 and self.worldWarUrl and round and round > 0 then
                local httpUrl = "http://"..self.worldWarUrl.."/tank-server/public/index.php/api/worldwar/pointMatchRanking"
                print("httpUrl", httpUrl)
                local worldWarId = self:getWorldWarId()
                local matchType = type
                local reqStr = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&bid="..worldWarId.."&round="..round.."&matchType="..matchType
                print("reqStr", reqStr)
                local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                -- deviceHelper:luaPrint("libaoret:"..retStr)
                if(retStr ~= "")then
                    local retData = G_Json.decode(retStr)
                    if retData and retData.ret == 0 and retData.data and retData.data.pointMatchRank then
                        self.rankList[type] = {}
                        local pointMatchRank = retData.data.pointMatchRank
                        for k, v in pairs(pointMatchRank) do
                            if v then
                                local id = tonumber(v.uid)
                                local name = v.nickname
                                local server = GetServerNameByID(v.zid)
                                local rank = tonumber(k)
                                local power = tonumber(v.fc) or 0
                                local value = tonumber(v.score) or 0
                                local vo = worldWarRankVo:new()
                                vo:initWithData(id, name, server, rank, value, power)
                                table.insert(self.rankList[type], vo)
                            end
                        end
                        local function sortAsc(a, b)
                            if a and b then
                                if a.value and b.value and a.value ~= b.value then
                                    return a.value > b.value
                                else
                                    if a.rank and b.rank and a.rank ~= b.rank then
                                        return a.rank < b.rank
                                    else
                                        if a.power and b.power and a.power ~= b.power then
                                            return a.power > b.power
                                        else
                                            return a.id < b.id
                                        end
                                    end
                                end
                            end
                        end
                        table.sort(self.rankList[type], sortAsc)
                    end
                    
                    self.rankExpireTime[type] = self:getPMatchExpireTime(true)
                    -- self:setRankFlag(1)
                    isSuccess = true
                end
            end
            if callback then
                callback(isSuccess)
            end
        elseif type == 3 or type == 4 then
            local function getScheduleInfoHandler()
                self.rankList[type] = {}
                local playerList = self:getPlayerList()
                for k, v in pairs(playerList) do
                    if v then
                        if (type - 2) == v.type then
                            local id = v.uid
                            local name = v.name
                            local server = GetServerNameByID(v.serverID)
                            local rank = v.topRank
                            local value = v.power
                            local power = v.power
                            local vo = worldWarRankVo:new()
                            vo:initWithData(id, name, server, rank, value, power)
                            table.insert(self.rankList[type], vo)
                        end
                    end
                end
                local function sortAsc(a, b)
                    if a and b and a.rank and b.rank and tonumber(a.rank) and tonumber(b.rank) then
                        return tonumber(a.rank) < tonumber(b.rank)
                    end
                end
                table.sort(self.rankList[type], sortAsc)
                if callback then
                    callback(true)
                end
            end
            
            if status >= 40 then
                local sType = type - 2
                self:getScheduleInfo(sType, getScheduleInfoHandler)
                self.rankExpireTime[type] = self:getTMatchExpireTime(sType)
            else
                local sType = type - 2
                local timeList = worldWarVoApi:getBattleTimeList(sType)
                if timeList and SizeOfTable(timeList) > 0 then
                    self.rankExpireTime[type] = timeList[SizeOfTable(timeList)] + worldWarCfg.battleTime * 3
                end
                if callback then
                    callback()
                end
            end
        end
    elseif callback then
        callback()
    end
end
function worldWarVoApi:getRankList(type)
    if type and self.rankList and self.rankList[type] then
        return self.rankList[type]
    end
    return {}
end
function worldWarVoApi:getRankRewardCfg(type)
    if type and worldWarCfg["rankReward"..type] then
        return worldWarCfg["rankReward"..type]
    else
        return {}
    end
end
-- function worldWarVoApi:getSeverRewardCfg()
-- return worldWarCfg.severReward
-- end
-- function worldWarVoApi:isHasServerReward(index)
-- local severRewardCfg=worldWarVoApi:getSeverRewardCfg()
-- if index and severRewardCfg and severRewardCfg[index] then
-- return true
-- else
-- return false
-- end
-- end

-- function worldWarVoApi:getRankIcon(rank,startTime,notTimeLimit)
-- if rank and rank>0 and rank<=3 and worldWarCfg and worldWarCfg.rankReward and worldWarCfg.rankReward[rank] then
-- local sType=0
-- if notTimeLimit==true then
-- sType=1
-- elseif startTime and startTime>0 then
-- local cfg=worldWarCfg.rankReward[rank]
-- local normalLastTime=cfg.lastTime[1] or 0
-- local grayLastTime=cfg.lastTime[2] or 0
-- local toGrayTime=G_getWeeTs(startTime)+(normalLastTime+1)*3600*24
-- local toDisappearTime=G_getWeeTs(startTime)+(normalLastTime+grayLastTime+1)*3600*24
-- if base.serverTime>=startTime and base.serverTime<toGrayTime then
-- sType=1
-- elseif base.serverTime>=toGrayTime and base.serverTime<toDisappearTime then
-- sType=2
-- end
-- end
-- for k,v in pairs(worldWarCfg.rankReward) do
-- if v.range and v.range[1] and v.range[2] and v.icon then
-- if rank==v.range[1] and v.range[1]==v.range[2] then
-- return v.icon,sType,v
-- end
-- end
-- end
-- end
-- return nil
-- end
-- ------------以上排行榜----------------

--格式化后台的id获取数据 b319_1_g1
-- b319_1_g1：matchId_第几轮_战斗id(g1)
function worldWarVoApi:getFormatId(id)
    if id then
        local arr = Split(id, "_")
        if arr and SizeOfTable(arr) >= 3 then
            local warId = arr[1] --世界争霸id
            local roundIndex = tonumber(arr[2]) --第几轮
            local battleIDStr = arr[3]--第几场战斗
            local battleID = (tonumber(battleIDStr) or tonumber(RemoveFirstChar(battleIDStr)))
            return warId, roundIndex, battleID
        end
    end
    return nil
end

--组合id
function worldWarVoApi:getConnectId(warId, roundID, battleID)
    local detailId = tostring(warId) .. "_"..tostring(roundID) .. "_g"..tostring(battleID)
    return detailId
end

-- --获取前三名的数据
-- --return: 会异步返回一个table, table是回调函数的参数, table的第1,2,3号元素就是前三名的数据vo, 如果此时前两名还没有决出, 那么table只有3, 没有1和2
-- function worldWarVoApi:getTop3(callback)
-- local function onGetSchedule()
-- local result={}
-- if(self.knockOutBattleList[7] and self.knockOutBattleList[7][1])then
-- if(self.knockOutBattleList[7][1].winnerID and self.knockOutBattleList[7][1].winnerID==self.knockOutBattleList[7][1].id1)then
-- result[1]=self.knockOutBattleList[7][1].player1
-- result[2]=self.knockOutBattleList[7][1].player2
-- elseif(self.knockOutBattleList[7][1].winnerID and self.knockOutBattleList[7][1].winnerID==self.knockOutBattleList[7][1].id2)then
-- result[1]=self.knockOutBattleList[7][1].player2
-- result[2]=self.knockOutBattleList[7][1].player1
-- end
-- end
-- if(self.knockOutBattleList[6] and self.knockOutBattleList[6][1])then
-- if(self.knockOutBattleList[6][1].winnerID)then
-- if(self.knockOutBattleList[6][1].winnerID==self.knockOutBattleList[6][1].id1)then
-- result[3]=self.knockOutBattleList[6][1].player2
-- else
-- result[3]=self.knockOutBattleList[6][1].player1
-- end
-- end
-- end
-- if(callback)then
-- callback(result)
-- end
-- end
-- self:getScheduleInfo(onGetSchedule)
-- end

--检查是否要显示世界争霸
function worldWarVoApi:checkShowWorldWar()
    if(G_isHexie())then
        return false
    end
    if base.worldWarSwitch == 1 then
        if self.startTime and self.endTime then
            if base.serverTime > self.startTime and base.serverTime < self.endTime then
                return true
            end
        end
    end
    return false
end

--检查当前参赛玩家是否参加世界争霸
function worldWarVoApi:checkIsPlayer()
    if(self.playerList == nil)then
        return false
    end
    for k, v in pairs(self.playerList) do
        if(tostring(v.uid) == tostring(playerVoApi:getUid()) and tostring(v.serverID) == tostring(base.curZoneID))then
            return true
        end
    end
    return false
end
--检查当前参赛玩家是否已经淘汰
function worldWarVoApi:checkIsOut(type)
    local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
    local bList = self:getBattleList(type)
    if bList and SizeOfTable(bList) > 0 then
        if bList[SizeOfTable(bList)] then
            local curRoundBList = bList[SizeOfTable(bList)]
            for k, v in pairs(curRoundBList) do
                if v and SizeOfTable(v) > 0 then
                    if v.id1 and v.id1 == selfID then
                        return false
                    elseif v.id2 and v.id2 == selfID then
                        return false
                    end
                end
            end
        end
    end
    return true
end

-- --检查当前登录玩家今天是否有比赛
-- function worldWarVoApi:checkPlayerHasBattle()
-- if(self:checkIsPlayer()==false)then
-- return false
-- end
-- local curRound
-- if self.timeTb then
-- for i=0,#self.timeTb-1 do
-- local roundStatus=self:getRoundStatus(i)
-- if(roundStatus>=10 and roundStatus<30)then
-- curRound=i
-- break
-- end
-- end
-- end
-- if(curRound)then
-- local list
-- if(curRound==0)then
-- list=self.teamBattleList
-- else
-- list=self.knockOutBattleList[curRound]
-- end
-- if(list)then
-- local selfID=playerVoApi:getUid().."-"..base.curZoneID
-- for k,v in pairs(list) do
-- if(v.id1==selfID or v.id2==selfID)then
-- return true
-- end
-- end
-- end
-- end
-- return false
-- end

--检查积分赛的状态
--param type: 1是NB赛, 2是SB赛
--return 0~9: 0就是还没到积分赛阶段, 大于0表示积分赛的第几天的准备阶段, 可以设置部队什么的
--return 10~19: 每天的开战前N分钟, 不可以设置部队了
--return 20~29: 积分赛战斗中, 21表示第一天的下午几点到几点的战斗阶段, 22表示第二天的下午几点到几点的战斗阶段
--return 30~39: 第X天的积分赛赛后到当晚24点的战后阶段
--return 40: 积分赛阶段已经结束
function worldWarVoApi:checkPMatchStatus(type)
    local status = self:checkStatus()
    if(status < 20)then
        return 0
    elseif(status < 30)then
        if(base.serverTime < G_getWeeTs(base.serverTime) + worldWarCfg["pmatchstarttime"..type][1] * 3600 + worldWarCfg["pmatchstarttime"..type][2] * 60 - worldWarCfg.setTroopsLimit)then
            return status - 20
        elseif(base.serverTime < G_getWeeTs(base.serverTime) + worldWarCfg["pmatchstarttime"..type][1] * 3600 + worldWarCfg["pmatchstarttime"..type][2] * 60)then
            return status - 20 + 10
        elseif(base.serverTime < G_getWeeTs(base.serverTime) + worldWarCfg["pmatchendtime"..type][1] * 3600 + worldWarCfg["pmatchendtime"..type][2] * 60)then
            return status
        else
            return status - 20 + 30
        end
    else
        return 40
    end
end

--世界争霸的状态
--return 0: 没有比赛或者不在显示时间, 这时候啥都看不到
--return 10~19: 报名阶段, 返回十几就表示是报名阶段的第几天,例如11表示报名阶段第一天, 12表示报名阶段第二天
--return 20~29: 积分赛阶段, 返回二十几就表示是积分赛第几天, 同上
--return 30~39: 淘汰赛阶段, 返回三十几就表示是淘汰赛第几天, 同上
--return 40: 领奖阶段
function worldWarVoApi:checkStatus()
    if(self.startTime == nil or base.serverTime < self.startTime)then
        return 0
    elseif(base.serverTime < self.startTime + worldWarCfg.signuptime * 86400)then
        for i = 1, worldWarCfg.signuptime do
            if(base.serverTime < self.startTime + i * 86400)then
                return 10 + i
            end
        end
        return 10
    elseif(base.serverTime < self.startTime + worldWarCfg.signuptime * 86400 + worldWarCfg.pmatchdays * 86400)then
        for i = 1, worldWarCfg.pmatchdays do
            if(base.serverTime < self.startTime + worldWarCfg.signuptime * 86400 + i * 86400)then
                return 20 + i
            end
        end
        return 20
    else
        if(self.tmatchTimeTb1)then
            local lastBattleTime = self.tmatchTimeTb1[#self.tmatchTimeTb1]
            if(lastBattleTime and base.serverTime < lastBattleTime + worldWarCfg.battleTime * 3)then
                for i = 1, self.tmatchDays do
                    if(base.serverTime < self.startTime + worldWarCfg.signuptime * 86400 + worldWarCfg.pmatchdays * 86400 + i * 86400)then
                        return 30 + i
                    end
                end
                return 30
            elseif(base.serverTime < self.endTime)then
                return 40
            else
                return 0
            end
        else
            return 0
        end
    end
end

--检查是否可以报名
--return 0: 可以报名
--return 1: 军衔不够
--return 2: 不在报名时间
function worldWarVoApi:checkCanSign()
    if(playerVoApi:getRank() < worldWarCfg.signRank)then
        return 1
    end
    local warStatus = self:checkStatus()
    if(warStatus >= 10 and warStatus < 20)then
        return 0
    else
        return 2
    end
end

--获取自己的报名状态，1为NB赛，2为SB赛，nil为没报名
function worldWarVoApi:getSignStatus()
    return self.signStatus
end

--获取活动开始时间
function worldWarVoApi:getStarttime()
    return self.startTime
end

--获取活动结束时间
function worldWarVoApi:getEndtime()
    return self.endTime
end

function worldWarVoApi:tick()
    if self and self.startTime then
        -- local endTime=G_getWeeTs(self.endTime)
        -- print("self.endTime",self.endTime)
        -- local lTime=86400-(worldWarCfg.tmatch2starttime1[1]*3600+worldWarCfg.tmatch2starttime1[2]*60)
        -- local time=endTime-worldWarCfg.shoppingtime*86400-lTime+worldWarCfg.battleTime*3
        local time = G_getWeeTs(self.startTime) + (worldWarCfg.signuptime + worldWarCfg.pmatchdays + worldWarCfg.battletime - 1) * 86400 + (worldWarCfg.tmatch2starttime1[1] * 3600 + worldWarCfg.tmatch2starttime1[2] * 60) + worldWarCfg.battleTime * 3
        -- print("base.serverTime~~~~~chat:",base.serverTime)
        -- print("time~~~~~chat:",time)
        if self.championChatInit == false and base.serverTime >= time and base.serverTime < time + 600 then
            -- print("~~~~~~~~~~~~~1")
            local function callback()
                -- print("~~~~~~~~~~~~~2")
                local function callback1()
                    self.championChatInit = true
                    local pList = self:getPlayerList()
                    -- print("SizeOfTable(pList)",SizeOfTable(pList))
                    for k, v in pairs(pList) do
                        -- print("v.type",v.type)
                        if v and v.type and v.type == 1 then
                            local topRank = tonumber(v.topRank) or 0
                            -- print("topRank",topRank)
                            if topRank > 0 and topRank <= 3 then
                                -- print("~~~~~~~~~~~~~~~~~",topRank)
                                local chatMsgType = 21 + topRank
                                local name = v.name or ""
                                local serverName = v.serverName or ""
                                local params = {subType = 4, contentType = 3, message = {key = "chatSystemMessage"..chatMsgType, param = {name, serverName}}, ts = base.serverTime, isSystem = 1}
                                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                            end
                        end
                    end
                end
                local bType = 1 --只算大师的前3名
                self:getScheduleInfo(bType, callback1)
            end
            self:getWarInfo(callback)
        end
    end
    if(self.initBuildingFlag == false and self:checkShowWorldWar())then
        if(buildings.allBuildings)then
            for k, v in pairs(buildings.allBuildings) do
                if(v:getType() == 16)then
                    v:setSpecialIconVisible(3, true)
                    self.initBuildingFlag = true
                    break
                end
            end
        end
    end
    -- if self then
    -- if self.timeTb and SizeOfTable(self.timeTb)>0 then
    -- local battleTime=worldWarCfg.battleTime*3
    -- local thirdSendTime=self.timeTb[SizeOfTable(self.timeTb)-1]+battleTime
    -- local firstSendTime=self.timeTb[SizeOfTable(self.timeTb)]+battleTime
    -- -- print("base.serverTime",base.serverTime)
    -- -- print("thirdSendTime",thirdSendTime)
    -- -- print("firstSendTime",firstSendTime)
    -- if base.serverTime==thirdSendTime then
    -- local function thirdSendChat(result)
    -- -- print("result[3]",result[3])
    -- if result and result[3] then
    -- local playerVo=result[3]
    -- local name=playerVo.name or ""
    -- local serverName=playerVo.serverName or ""
    -- local params={subType=4,contentType=3,message={key="chatSystemMessage16",param={name,serverName}},ts=base.serverTime,isSystem=1}
    -- chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
    -- end
    -- end
    -- self:getTop3(thirdSendChat)
    -- elseif base.serverTime==firstSendTime then
    -- local function firstSendChat(result)
    -- if result then
    -- local selfUid=playerVoApi:getUid()
    -- for i=1,3 do
    -- if result[i] then
    -- local playerVo=result[i]
    -- local endTime=firstSendTime
    -- if playerVo and playerVo.uid then
    -- if tostring(playerVo.uid)==tostring(selfUid) then
    -- self:setMyRank(i)
    -- playerVoApi:setServerWarRank(i)
    -- playerVoApi:setServerWarRankStartTime(endTime)
    -- end
    -- end
    -- if i<3 then
    -- local key=""
    -- if i==1 then
    -- key="chatSystemMessage14"
    -- elseif i==2 then
    -- key="chatSystemMessage15"
    -- end
    -- local playerVo=result[i]
    -- local name=playerVo.name or ""
    -- local serverName=playerVo.serverName or ""
    -- local params={subType=4,contentType=3,message={key=key,param={name,serverName}},ts=base.serverTime,isSystem=1}
    -- chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
    -- end
    -- end
    -- end
    -- end
    -- end
    -- self:getTop3(firstSendChat)
    -- end
    
    -- for k,v in pairs(self.timeTb) do
    -- if v and tonumber(v) and base.serverTime==tonumber(v)+worldWarCfg.battleTime*3 then
    -- self:addPointDetail({},1)
    -- end
    -- end
    -- end
    
    -- local warInfoExpireTime=self:getWarInfoExpireTime()
    -- if (warInfoExpireTime and warInfoExpireTime>0 and base.serverTime>=warInfoExpireTime) then
    -- self:getWarInfo()
    -- end
    -- end
end

---------------------以下连胜记录------------------------

function worldWarVoApi:getMessageExpireTime(type)
    if self.messageExpireTime and type then
        return self.messageExpireTime[type]
    else
        return - 1
    end
end
function worldWarVoApi:formatMessageTab(type, callback)
    local isSuccess = false
    local round = self:getPMatchCurRound()
    local matchType = self:getSignStatus()
    if base.serverTime > self.messageExpireTime[type] and round > 0 and matchType ~= nil and self.worldWarUrl then
        local httpUrl = "http://"..self.worldWarUrl.."/tank-server/public/index.php/api/worldwar/pointMatchEvents"
        print("httpUrl", httpUrl)
        local worldWarId = self:getWorldWarId()
        local eventType
        if type == 1 then
            eventType = 2
        else
            eventType = 1
        end
        local reqStr = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&bid="..worldWarId.."&matchType="..matchType.."&eventType="..eventType.."&round="..round
        print("pointMatchEvents_reqStr", reqStr)
        local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
        -- deviceHelper:luaPrint("libaoret:"..retStr)
        if(retStr ~= "")then
            local retData = G_Json.decode(retStr)
            if retData and retData.ret == 0 then
                if retData.data and retData.data.eventDatas then
                    local eventDatas = retData.data.eventDatas
                    for k, v in pairs(eventDatas) do
                        self:addMessage(type, v)
                    end
                    if self.messageTab and self.messageTab[type] then
                        while SizeOfTable(self.messageTab[type]) > worldWarCfg.streakMaxNum do
                            table.remove(self.messageTab[type], worldWarCfg.streakMaxNum + 1)
                        end
                    end
                end
                
                self.messageExpireTime[type] = self:getPMatchExpireTime()
                isSuccess = true
            end
        end
    end
    if callback then
        callback(isSuccess)
    end
end

function worldWarVoApi:getMessageTab(type)
    if type and self.messageTab and self.messageTab[type] then
        return self.messageTab[type]
    else
        return self.messageTab
    end
end

function worldWarVoApi:addMessage(type, mData)
    if type and mData and SizeOfTable(mData) > 0 then
        local mType = tonumber(mData[1])
        local serverId = mData[2]
        local name = mData[3]
        local serverName = GetServerNameByID(serverId)
        -- print("mType",mType)
        -- print("serverId",serverId)
        -- print("name",name)
        local winNum = 0
        local color = G_ColorWhite
        for k, v in pairs(worldWarCfg.winningStreak) do
            if mType and mType == v then
                winNum = k
            end
        end
        if winNum > 0 then
            color = G_ColorGreen
        else
            color = G_ColorRed
        end
        if mType then
            local str
            if mType == 1 then
                str = getlocal("world_war_winning_streak_"..mType, {serverName, name})
            else
                str = getlocal("world_war_winning_streak_"..mType, {serverName, name, winNum})
            end
            local lb = GetTTFLabelWrap(str, 22, CCSizeMake(550, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            local cellHeight = lb:getContentSize().height + 5
            local msgData = {str, cellHeight, color}
            -- if type and type==2 then
            -- table.insert(self.messageTab[2],msgData)
            -- end
            table.insert(self.messageTab[type], msgData)
        end
    end
end

---------------------以上连胜记录------------------------

---------------------以下积分赛战报------------------------
function worldWarVoApi:getMyReportExpireTime()
    return self.myReportExpireTime
end
function worldWarVoApi:getReportNum()
    return self.reportNum
end
function worldWarVoApi:setReportNum(num)
    self.reportNum = num
end
function worldWarVoApi:formatMyReportList(callback)
    local isSuccess = false
    local round = self:getPMatchCurRound()
    if base.serverTime > self.myReportExpireTime and round > 0 and self.worldWarUrl then
        self.myReportList = {}
        
        -- http://192.168.8.213/tank-server/public/index.php/api/worldwar/pointMatchReport/list?uid=1000002&zoneid=1&bid=b25&round=4&matchType=1
        local httpUrl = "http://"..self.worldWarUrl.."/tank-server/public/index.php/api/worldwar/pointMatchReport/list"
        print("httpUrl", httpUrl)
        local worldWarId = self:getWorldWarId()
        
        local matchType = self:getSignStatus()
        local reqStr = "uid="..playerVoApi:getUid() .. "&zoneid="..base.curZoneID.."&bid="..worldWarId.."&round="..round.."&matchType="..matchType
        print("reqStr", reqStr)
        local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
        -- deviceHelper:luaPrint("libaoret:"..retStr)
        if(retStr ~= "")then
            local retData = G_Json.decode(retStr)
            if retData and retData.ret == 0 then
                if retData.data and retData.data.pointMatchReportlist then
                    local pointMatchReportlist = retData.data.pointMatchReportlist
                    self:addReport(pointMatchReportlist)
                    -- for k,v in pairs(pointMatchReportlist) do
                    -- print("k~~~",k,v,v[1],v[5],type(v[5]))
                    -- end
                end
                
                self.myReportExpireTime = self:getPMatchExpireTime()
                isSuccess = true
            end
        end
    end
    if callback then
        callback(isSuccess)
    end
end
function worldWarVoApi:addReport(data)
    -- local data={
    -- {
    -- [1] = 1,--id
    -- [2] = {1,1000067,"name1",20,-30,1,11,60,100000,"aname1","2,6,5",{2,1,3}},--服务器id，玩家id，名字，获得的商店积分，排位分变化，头像，军衔，等级，战力，公会名称，服务器名称，战斗地形，三场战斗对应的战术
    -- [3] = {1,1000077,"name2",20,30,2,12,70,120000,"aname2","2,6,5",{3,2,1}},
    -- [4] = "1-1000077",
    -- [5] = {
    -- [1] = "1-1000067",
    -- [2] = "1-1000077",
    -- [3] = "1-1000067",
    -- },
    -- [6] = 1,--积分赛第几场
    -- [7] = "2,6,5",--三场战斗对应的地形类型,1~6
    -- },
    -- }
    if data and SizeOfTable(data) > 0 then
        self.myReportList = {}
        for k, v in pairs(data) do
            local rid = v[1]
            local pData1 = v[2] or {}
            local pData2 = v[3] or {}
            local winnerID = v[4] or ""
            local resultTb = v[5] or {}
            if v[5] and type(v[5]) == "string" then
                resultTb = G_Json.decode(v[5])
            end
            local roundIndex = v[6] or 1
            local landType = v[7] or {}
            local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
            local strategy = {}
            local point = 0
            local rankPoint = 0
            if type(landType) == "string" then
                landType = Split(landType, ",")
            elseif type(landType) ~= "table" then
                landType = {}
            end
            local isRead = 1
            if type(pData1) ~= "table" then
                pData1 = {}
            end
            if type(pData2) ~= "table" then
                pData2 = {}
            end
            if type(winnerID) ~= "string" then
                winnerID = ""
            end
            
            local id1
            local id2
            local player1
            if pData1 then
                local pData = pData1
                local serverID = tostring(pData[1]) or ""
                local uid = tonumber(pData[2])
                if uid then
                    local id = uid.."-"..serverID
                    id1 = uid.."-"..serverID
                    local nickname = tostring(pData[3]) or ""
                    local point1 = tonumber(pData[4]) or 0
                    local rankPoint1 = tonumber(pData[5]) or 0
                    local pic = tonumber(pData[6]) or 1
                    local rank = tonumber(pData[7]) or 1
                    local level = tonumber(pData[8]) or 1
                    local fc = tonumber(pData[9]) or 0
                    local allianceName = tostring(pData[10]) or ""
                    local serverName = GetServerNameByID(serverID) or ""
                    -- local strategy=pData[11] or {}
                    -- if type(strategy)~="table" then
                    -- strategy={}
                    -- end
                    strategy[1] = pData[12] or {1, 2, 3}
                    if type(strategy[1]) ~= "table" then
                        strategy[1] = {1, 2, 3}
                    end
                    if selfID == id then
                        point = point1
                        rankPoint = rankPoint1
                    end
                    local data = {uid = uid, serverID = serverID, id = id, nickname = nickname, allianceName = allianceName, pic = pic, rank = rank, level = level, fc = fc, serverName = serverName}
                    player1 = worldWarPlayerVo:new()
                    player1:init(data)
                end
            end
            local player2
            if pData2 then
                local pData = pData2
                local serverID = tostring(pData[1]) or ""
                local uid = tonumber(pData[2])
                if uid then
                    local id = uid.."-"..serverID
                    id2 = uid.."-"..serverID
                    local nickname = tostring(pData[3]) or ""
                    local point2 = tonumber(pData[4]) or 0
                    local rankPoint2 = tonumber(pData[5]) or 0
                    local pic = tonumber(pData[6]) or 1
                    local rank = tonumber(pData[7]) or 1
                    local level = tonumber(pData[8]) or 1
                    local fc = tonumber(pData[9]) or 0
                    local allianceName = tostring(pData[10]) or ""
                    local serverName = GetServerNameByID(serverID) or ""
                    -- local strategy=pData[11] or {}
                    -- if type(strategy)~="table" then
                    -- strategy={}
                    -- end
                    strategy[2] = pData[12] or {1, 2, 3}
                    if type(strategy[2]) ~= "table" then
                        strategy[2] = {1, 2, 3}
                    end
                    if selfID == id then
                        point = point2
                        rankPoint = rankPoint2
                    end
                    local data = {uid = uid, serverID = serverID, id = id, nickname = nickname, allianceName = allianceName, pic = pic, rank = rank, level = level, fc = fc, serverName = serverName}
                    player2 = worldWarPlayerVo:new()
                    player2:init(data)
                end
            end
            
            local bType = self:getSignStatus()
            local battleData = {id1, id2, winnerID, resultTb, landType, strategy, nil, nil, bType, rid, isRead}
            local battleVo = worldWarBattleVo:new()
            battleVo:init(battleData, player1, player2)
            local reportData = {battleData = battleVo, point = point, isRead = isRead, rid = rid, rankPoint = rankPoint, roundIndex = roundIndex}
            local reportVo = worldWarBattleReportVo:new()
            reportVo:init(reportData)
            table.insert(self.myReportList, reportVo)
        end
        local function sortFunc(a, b)
            return a.rid > b.rid
        end
        table.sort(self.myReportList, sortFunc)
        
        -- if SizeOfTable(self.myReportList)>=self:getReportNum() then
        -- self:setReportHasMore(false)
        -- else
        -- self:setReportHasMore(true)
        -- end
    end
end
--type：1积分赛，2淘汰赛
function worldWarVoApi:getMyReportList(type)
    if type == nil or type == 1 then
        return self.myReportList
    else
        local reportList = {}
        local btype = self:getSignStatus()
        if btype ~= nil then
            local bList = self:getBattleList(btype)
            local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
            for k, v in pairs(bList) do
                if v then
                    for m, n in pairs(v) do
                        local rid = n.roundID
                        local roundIndex = n.roundID
                        if roundIndex and roundIndex > 0 then
                            local roundStatus = self:getRoundStatus(btype, roundIndex)
                            if roundStatus == 30 then
                                local rankPoint = 0
                                local point = 0
                                local winNum = 0
                                if n.resultTb then
                                    for k, v in pairs(n.resultTb) do
                                        if selfID == v then
                                            winNum = winNum + 1
                                        end
                                    end
                                end
                                if worldWarCfg["tmatchPoint"..btype] and worldWarCfg["tmatchPoint"..btype][winNum] then
                                    point = worldWarCfg["tmatchPoint"..btype][winNum]
                                end
                                local isRead = 1
                                if (n.id1 and n.id1 == selfID) or (n.id2 and n.id2 == selfID) then
                                    local reportData = {battleData = n, point = point, isRead = isRead, rid = rid, rankPoint = rankPoint, roundIndex = roundIndex}
                                    local reportVo = worldWarBattleReportVo:new()
                                    reportVo:init(reportData)
                                    table.insert(reportList, reportVo)
                                end
                            end
                        end
                    end
                end
            end
            if reportList and SizeOfTable(reportList) > 0 then
                local function sortFunc(a, b)
                    return a.rid > b.rid
                end
                table.sort(reportList, sortFunc)
            end
        end
        return reportList
    end
end
--type：1积分赛，2淘汰赛
function worldWarVoApi:getMyReportNum(type)
    local num = 0
    local list = self:getMyReportList(type)
    if list then
        num = SizeOfTable(list)
    end
    return num
end

function worldWarVoApi:setIsRead(rid)
    local list = self:getMyReportList()
    for k, v in pairs(list) do
        if v.rid == rid then
            self.myReportList[k].isRead = 1
        end
    end
end

function worldWarVoApi:getMinAndMaxRid()
    local minId, maxId = 0, 0
    local list = self:getMyReportList()
    local num = SizeOfTable(list)
    if list[1] and list[num] then
        if list[1].rid then
            maxId = list[1].rid
        end
        if list[num].rid then
            minId = list[num].rid
        end
    end
    return minId, maxId
end

function worldWarVoApi:getReportHasMore()
    return self.reportHasMore
end
function worldWarVoApi:setReportHasMore(reportHasMore)
    self.reportHasMore = reportHasMore
end

function worldWarVoApi:getReportFlag()
    return self.reportFlag
end
function worldWarVoApi:setReportFlag(reportFlag)
    self.reportFlag = reportFlag
end

---------------------以上积分赛战报------------------------
--积分赛当前的轮次，第几场，过了积分赛取最后一轮
function worldWarVoApi:getPMatchCurRound()
    local roundIndex = 0
    local pmatchTimeTb = self:getPointBattleTimeList()
    local checkStatus = self:checkStatus()
    if checkStatus >= 20 and checkStatus < 30 then
        for k, v in pairs(pmatchTimeTb) do
            local pTime = tonumber(v)
            if base.serverTime < pTime then
                break
            end
            roundIndex = k
        end
    elseif checkStatus >= 30 then
        roundIndex = SizeOfTable(pmatchTimeTb)
    end
    return roundIndex
end
--获取积分赛过期时间
function worldWarVoApi:getPMatchExpireTime(includeTMatch)
    local time = 0
    local checkStatus = self:checkStatus()
    local lastTime = self.endTime
    if includeTMatch == true then
        local bType = self:getSignStatus()
        lastTime = self:getTMatchExpireTime(bType) or self.endTime
    end
    if(checkStatus < 20)then
        time = self:getPointBattleTimeList()[1] or lastTime
    elseif checkStatus >= 20 and checkStatus < 30 then
        local flag = false
        local pmatchTimeTb = self:getPointBattleTimeList()
        for k, v in pairs(pmatchTimeTb) do
            local pTime = tonumber(v)
            if base.serverTime < pTime then
                time = pTime
                flag = true
                break
            end
        end
        if(flag == false)then
            time = lastTime
        end
    else
        time = lastTime
    end
    return time
end
--获取淘汰赛过期时间
function worldWarVoApi:getTMatchExpireTime(type)
    if type == nil then
        type = 1
    end
    local time = 0
    local warStatus = self:checkStatus()
    if(warStatus < 30)then
        time = self["tmatchTimeTb"..type][1] + worldWarCfg.battleTime * 3
    elseif(warStatus >= 40)then
        time = self.endTime
    else
        local tmatchRounds = #self["tmatchTimeTb"..type]
        for i = 1, tmatchRounds do
            local roundStatus = self:getRoundStatus(type, i)
            if(roundStatus < 30)then
                time = self["tmatchTimeTb"..type][i]
                break
            end
        end
        if time > 0 then
            time = time + worldWarCfg.battleTime * 3
        else
            time = self.endTime
        end
    end
    return time
end
function worldWarVoApi:getRoundStr(roundID, type, isShowGroup)
    if isShowGroup == nil then
        isShowGroup = true
    end
    local roundStr = ""
    if roundID >= 5 then
        if isShowGroup then
            local groupStr = getlocal("world_war_group_"..type)
            if roundID == 5 then
                roundStr = getlocal("world_war_semifinal", {groupStr})
            elseif roundID == 6 then
                roundStr = getlocal("world_war_typeFinal", {groupStr})
            end
        else
            if roundID == 5 then
                roundStr = getlocal("world_war_semi_final_battle")
            elseif roundID == 6 then
                roundStr = getlocal("world_war_final_battle")
            end
        end
    else
        local index = 5 - roundID
        if index then
            if index == 1 then
                roundStr = getlocal("world_war_groupChampion")
            else
                roundStr = getlocal("world_war_knockOutDesc", {math.pow(2, index), math.pow(2, index - 1)})
            end
        end
    end
    return roundStr
end

function worldWarVoApi:clear()
    self.initFlag = nil
    self.initBuildingFlag = false
    self.worldWarId = nil
    self.startTime = nil
    self.endTime = nil
    self.totalPlayerNum1 = 0
    self.totalPlayerNum2 = 0
    self.serverList = nil
    self.playerList = nil
    self.battleList1 = nil
    self.battleList2 = nil
    self.tmatchTimeTb1 = nil
    self.tmatchTimeTb2 = nil
    self.pmatchTimeTb = {}
    
    self.scheduleExpireTime1 = 0
    self.scheduleExpireTime2 = 0
    self.warInfoExpireTime = 0
    
    self.betList1 = nil
    self.betList2 = nil
    self.commonList = nil
    self.rareList = nil
    self.point = 0
    self.pointDetail = {}
    self.detailExpireTime = 0
    self.buyStatus = 0
    
    self.rankList = {{}, {}, {}, {}}
    self.rankExpireTime = {0, 0, 0, 0}
    self.lastSetFleetTime = {0, 0, 0}
    self.lastSetStrategyTime = 0
    
    self.signStatus = nil
    self.myRank = 0
    self.pMatchRank = 0
    self.pMatchTotalPlayer = 0
    self.pMatchWinMatch = 0
    self.pMatchLoseMatch = 0
    self.pMatchResultTb = {}
    self.shopFlag = -1
    self.pointDetailFlag = -1
    self.propertyIndexTab = {1, 2, 3}
    self.tmatchDays = 0
    
    self.messageTab = {{}, {}}
    self.messageExpireTime = {0, 0}
    self.myReportList = {}
    self.myReportExpireTime = 0
    self.reportNum = 0
    self.reportHasMore = false
    self.reportFlag = -1
    self.landtype = {}
    self.championChatInit = false
    self.f_aShopItems, self.f_pShopItems = nil, nil
end
