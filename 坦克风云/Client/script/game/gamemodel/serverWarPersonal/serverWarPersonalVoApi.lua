serverWarPersonalVoApi =
{
    serverWarId = nil, --跨服战id
    serverList = nil, --参与跨服战的服务器列表
    playerList = nil, --参赛选手列表
    teamBattleList = nil, --小组赛对阵表
    knockOutBattleList = nil, --淘汰赛对阵表
    startTime = nil, --个人跨服战开始时间
    endTime = nil, --个人跨服战结束时间
    timeTb = nil, --一个table, 里面存的是每轮战斗的开启时间戳
    
    infoExpireTime = 0, --赛程信息的过期时间
    troopsExpireTime = 0, --部队信息的过期时间
    shopExpireTime = 0, --商店信息的过期时间
    warInfoExpireTime = 0, --初始化信息过期时间
    
    betList = nil, --每一轮的送花记录
    commonList = nil, --道具列表
    rareList = nil, --珍品列表
    point = 0, --积分
    pointDetail = {}, --积分明细
    detailExpireTime = 0, --积分明细过期时间
    -- page=0,--积分明细当前第几页
    -- hasMore=false,--积分明细是否还有更多
    -- perPageNum=10,--积分明细每一页条数
    -- maxPage=5,--积分明细最多多少页
    buyStatus = 0, --可以购买商店道具状态，0：都未开启，1：只有道具开启，2：道具和珍品都开启
    
    rankList = nil, --排行榜
    lastSetFleetTime = {0, 0, 0}, --上一次设置部队时间,3个时间对应3场的部队设置
    
    myRank = 0, --我的排名
    isRewardRank = false, --是否领取过排行奖励
    shopFlag = -1, --是否初始化商店数据,-1:未初始化，1:已经初始化
    pointDetailFlag = -1, --是否初始化积分明细,-1:未初始化，0:需要刷新面板，1:已经初始化
    rankFlag = -1, --是否初始化排行榜数据,-1:未初始化，1:已经初始化
    troopsFlag = -1, --是否初始化部队数据,-1:未初始化，1:已经初始化
    lastSetStrategyTime = 0, --上次设置战术和上阵顺序的时间
    f_pShopItems = nil, --普通商店列表
    f_aShopItems = nil, --参赛商店列表
}

--跨服战id
function serverWarPersonalVoApi:getServerWarId()
    return self.serverWarId
end
function serverWarPersonalVoApi:setServerWarId(serverWarId)
    self.serverWarId = serverWarId
end

function serverWarPersonalVoApi:getLastSetStrategyTime()
    return self.lastSetStrategyTime
end
function serverWarPersonalVoApi:setLastSetStrategyTime(time)
    self.lastSetStrategyTime = time
end

function serverWarPersonalVoApi:getLastSetFleetTime(index)
    if index then
        return self.lastSetFleetTime[index]
    end
    return 0
end
function serverWarPersonalVoApi:setLastSetFleetTime(index, time)
    if index and time and self.lastSetFleetTime and self.lastSetFleetTime[index] then
        self.lastSetFleetTime[index] = time
    end
end

--获取参加本次跨服战的各个服务器的ID和名字
--return 一个table, table的每个元素又是一个table B, table B的第一个元素是服务器的ID, 第二个元素是服务器的名称
function serverWarPersonalVoApi:getServerList()
    if(self.serverList)then
        return self.serverList
    else
        return {}
    end
end

--获取所有的选手信息
--return 一个table, table里面的元素是serverWarPersonalPlayerVo
function serverWarPersonalVoApi:getPlayerList()
    if(self.playerList)then
        return self.playerList
    else
        return {}
    end
end

--获取每轮的战斗时间表
--return 一个table, table里面是每轮战斗的时间戳
function serverWarPersonalVoApi:getBattleTimeList()
    if(self.timeTb)then
        return self.timeTb
    else
        return {}
    end
end

--获取小组赛对阵表
function serverWarPersonalVoApi:getTeamBattleList()
    if(self.teamBattleList)then
        return self.teamBattleList
    else
        return {}
    end
end

--获取淘汰赛对阵表
function serverWarPersonalVoApi:getKOBattleList()
    if(self.knockOutBattleList)then
        return self.knockOutBattleList
    else
        return {}
    end
end

--获取送花记录
function serverWarPersonalVoApi:getBetList()
    if(self.betList)then
        return self.betList
    else
        return {}
    end
end

--根据传来的比赛轮次获取该轮比赛的状态
--param roundIndex: 比赛的轮次, 如果传0的话是小组赛
--return 0: 下次比赛不是该轮次, 该轮比赛还处于不可献花的状态
--return 10: 可献花的状态
--return 11: 开赛前五分钟, 不可献花的状态
--return 21: 战斗中, 正在进行第1场
--return 22: 战斗中, 正在进行第2场
--return 23: 战斗中, 正在进行第3场
--return 30: 战斗已结束
function serverWarPersonalVoApi:getRoundStatus(roundIndex)
    if(base.serverTime >= self.timeTb[roundIndex + 1] + serverWarPersonalCfg.battleTime * 3)then
        return 30
    elseif(base.serverTime >= self.timeTb[roundIndex + 1] + serverWarPersonalCfg.battleTime * 2)then
        return 23
    elseif(base.serverTime >= self.timeTb[roundIndex + 1] + serverWarPersonalCfg.battleTime)then
        return 22
    elseif(base.serverTime >= self.timeTb[roundIndex + 1])then
        return 21
    elseif(base.serverTime >= self.timeTb[roundIndex + 1] - serverWarPersonalCfg.betTime)then
        return 11
    else
        if(roundIndex == 0)then
            if(self.playerList and #self.playerList > 0)then
                return 10
            else
                return 0
            end
        else
            if(self:getRoundStatus(roundIndex - 1) == 30)then
                return 10
            else
                return 0
            end
        end
    end
end

--可献花的状态 处于分组赛还是淘汰赛
function serverWarPersonalVoApi:getSendFlowerStatus()
    for i = 0, 7 do
        if self:getRoundStatus(i) == 10 then
            return i
        end
    end
    return - 1
end

--弹出个人跨服战主面板
--param layerNum: 面板所在的层级
function serverWarPersonalVoApi:showMainDialog(layerNum)
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalBattleVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalPlayerVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalBetVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalShopVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPointDetailVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPointRankVo"
    require "luascript/script/config/gameconfig/serverWarPersonalCfg"
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialog"
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogTab2"
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalDialogTab3"
    local td = serverWarPersonalDialog:new()
    local tbArr = {getlocal("serverwar_schedule"), getlocal("serverwar_troops"), getlocal("serverwar_shop")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverwar_title"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end

--弹出个人信息面板
function serverWarPersonalVoApi:showPlayerDetailDialog(data, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPlayerDetailDialog"
    local detailDialog = serverWarPlayerDetailDialog:new(data)
    detailDialog:init(layerNum + 1)
end

--弹出对战面板
function serverWarPersonalVoApi:showBattleDialog(data, roundIndex, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalBattleDialog"
    local battleDialog = serverWarPersonalBattleDialog:new(data, roundIndex)
    battleDialog:init(layerNum + 1)
end

--弹出献花面板
function serverWarPersonalVoApi:showFlowerDialog(data, roundIndex, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalFlowerDialog"
    local flowerDialog = serverWarPersonalFlowerDialog:new(data)
    flowerDialog:init(layerNum + 1)
end

function serverWarPersonalVoApi:getWarInfoExpireTime()
    return self.warInfoExpireTime
end

--获取跨服战的整体信息
--param callback: 获取之后的回调函数
function serverWarPersonalVoApi:getWarInfo(callback)
    if(G_isHexie())then
        do return end
    end
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalBattleVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalPlayerVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalBetVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPersonalShopVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPointDetailVo"
    require "luascript/script/game/gamemodel/serverWarPersonal/serverWarPointRankVo"
    require "luascript/script/config/gameconfig/serverWarPersonalCfg"
    if(base.serverTime >= self.warInfoExpireTime)then
        local function initHandler(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                local warId
                if sData.data and sData.data.matchId then
                    warId = sData.data.matchId
                end
                if(warId == nil or sData.data.st == nil)then
                    do return end
                end
                self:setServerWarId(warId)
                self.startTime = tonumber(sData.data.st)
                self.timeTb = {}
                self.timeTb[1] = self.startTime + serverWarPersonalCfg.preparetime * 86400 + serverWarPersonalCfg.startBattleTs[1][1] * 3600 + serverWarPersonalCfg.startBattleTs[1][2] * 60
                for i = 2, 8 do
                    if(i % (#serverWarPersonalCfg.startBattleTs) == 0)then
                        self.timeTb[i] = G_getWeeTs(self.timeTb[i - 1]) + 86400 + serverWarPersonalCfg.startBattleTs[1][1] * 3600 + serverWarPersonalCfg.startBattleTs[1][2] * 60
                    else
                        self.timeTb[i] = G_getWeeTs(self.timeTb[i - 1]) + serverWarPersonalCfg.startBattleTs[2][1] * 3600 + serverWarPersonalCfg.startBattleTs[2][2] * 60
                    end
                end
                self.endTime = G_getWeeTs(self.timeTb[#self.timeTb]) + serverWarPersonalCfg.shoppingtime * 86400
                self.serverList = {}
                local servers = sData.data.servers
                for k, v in pairs(servers) do
                    local tmp = {}
                    tmp[1] = tostring(v)
                    tmp[2] = GetServerNameByID(v)
                    self.serverList[k] = tmp
                end
                
                self.playerList = {}
                if(sData.data.crossuser)then
                    for k, v in pairs(sData.data.crossuser) do
                        local playerVo = serverWarPersonalPlayerVo:new()
                        playerVo:init(v)
                        table.insert(self.playerList, playerVo)
                    end
                end
                --记录
                if sData.data and sData.data.point and sData.data.point[warId] then
                    local pointData = sData.data.point[warId]
                    local point = tonumber(pointData.nm or 0) or 0 --积分数
                    local endTime = pointData.et or 0 --跨服战本轮结束时间
                    local record = pointData.rc --记录
                    local shopData = pointData.lm or {} --商店购买信息
                    --积分
                    self:setPoint(point)
                    --是否领取过排行奖励
                    if pointData and pointData.rank then
                        self:setIsRewardRank(true)
                    end
                    --商店数据
                    if shopData then
                        self:getShopInfo(nil, shopData)
                    end
                end
                --献花信息
                self.betList = {}
                if sData.data.bet and sData.data.bet[warId] then
                    for k, v in pairs(sData.data.bet[warId]) do
                        if(type(v) == "table")then
                            local infoTb = Split(k, "_")
                            local length = #infoTb
                            local battleID = infoTb[length]
                            local groupID = tonumber(infoTb[length - 1])
                            local roundID = tonumber(infoTb[length - 2])
                            local type = tonumber(infoTb[length - 3])
                            if(type == 1)then
                                roundID = 0
                            end
                            local betVo = serverWarPersonalBetVo:new()
                            betVo:init({roundID, groupID, battleID, v.uid, v.count, v.isGet})
                            self.betList[roundID + 1] = betVo
                        end
                    end
                end
                if sData.data and sData.data.shoplist then
                    -- "pShopItems" 是否显示俩个商店，参赛用户为['pShopItems','aShopItems']
                    if sData.data.shoplist[2] and sData.data.shoplist[2] == "aShopItems" then
                        self:setBuyStatus(2)
                    elseif sData.data.shoplist[1] and sData.data.shoplist[1] == "pShopItems" then
                        self:setBuyStatus(1)
                    end
                end
                if(self:checkShowServerWar())then
                    if(buildings.allBuildings)then
                        for k, v in pairs(buildings.allBuildings) do
                            if(v:getType() == 16)then
                                v:setSpecialIconVisible(1, true)
                                break
                            end
                        end
                    end
                end
                
                local nextRoundID
                for i = 0, #self.timeTb - 1 do
                    local roundStatus = self:getRoundStatus(i)
                    if(roundStatus and roundStatus < 30)then
                        nextRoundID = i
                        break
                    end
                end
                if(nextRoundID)then
                    if(nextRoundID == 0 and self:getRoundStatus(nextRoundID) == 0)then
                        self.warInfoExpireTime = G_getWeeTs(self.timeTb[nextRoundID + 1])
                    else
                        self.warInfoExpireTime = self.timeTb[nextRoundID + 1] + serverWarPersonalCfg.battleTime * 3
                    end
                else
                    self.warInfoExpireTime = self.endTime
                end
                if(self:checkStatus() == 20 and (self.playerList == nil or #self.playerList < 16))then
                    self.warInfoExpireTime = base.serverTime + 30
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:crossInit(initHandler)
    elseif(callback)then
        callback()
    end
end

--获取对阵信息
function serverWarPersonalVoApi:getScheduleInfo(callback)
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalTeamScene"
    require "luascript/script/game/scene/gamedialog/serverWarPersonal/serverWarPersonalKnockOutScene"
    if(base.serverTime >= self.infoExpireTime)then
        local function onRequestEnd(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                self.teamBattleList = {}
                self.knockOutBattleList = {}
                local map = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10, k = 11, l = 12, m = 13, n = 14, o = 15, p = 16}
                if(sData.data.schedule)then
                    --初始化分组赛信息
                    if(sData.data.schedule[1])then
                        local tmp = sData.data.schedule[1][1]
                        if(tmp)then
                            for groupID, groupData in pairs(tmp) do
                                for battleID, battleData in pairs(groupData) do
                                    local battleVo = serverWarPersonalBattleVo:new(0, groupID, battleID)
                                    battleVo:init(battleData)
                                    self.teamBattleList[map[battleID]] = battleVo
                                end
                            end
                        end
                    end
                    --初始化淘汰赛信息
                    if(sData.data.schedule[2])then
                        local tmpBattleList = {}
                        local allData = sData.data.schedule[2]
                        local function sortFunc(a, b)
                            if(a[7] == b[7])then
                                return map[a[8]] < map[b[8]]
                            else
                                return a[7] < b[7]
                            end
                        end
                        for roundID, roundTb in pairs(allData) do
                            tmpBattleList[roundID] = {}
                            for groupID, groupData in pairs(roundTb) do
                                for battleID, battleData in pairs(groupData) do
                                    battleData[6] = roundID
                                    battleData[7] = groupID
                                    battleData[8] = battleID
                                    table.insert(tmpBattleList[roundID], battleData)
                                end
                            end
                            table.sort(tmpBattleList[roundID], sortFunc)
                        end
                        if(#tmpBattleList >= 2)then
                            tmpBattleList = self:checkFormatRoundPlayer(tmpBattleList)
                        end
                        for roundIndex, roundTb in pairs(tmpBattleList) do
                            self.knockOutBattleList[roundIndex] = {}
                            for battleIndex, battleData in pairs(roundTb) do
                                local battleVo = serverWarPersonalBattleVo:new(battleData[6], battleData[7], battleData[8])
                                battleVo:init(battleData)
                                self.knockOutBattleList[roundIndex][battleIndex] = battleVo
                            end
                        end
                        
                    end
                end
                local nextRoundID
                for i = 0, #self.timeTb - 1 do
                    local roundStatus = self:getRoundStatus(i)
                    if(roundStatus < 20)then
                        nextRoundID = i
                        break
                    end
                end
                if(nextRoundID)then
                    if(nextRoundID == 0 and self:getRoundStatus(nextRoundID) == 0)then
                        self.infoExpireTime = G_getWeeTs(self.timeTb[nextRoundID + 1])
                    else
                        self.infoExpireTime = self.timeTb[nextRoundID + 1]
                    end
                else
                    self.infoExpireTime = self.endTime
                end
                if(self:checkStatus() == 20 and (self.playerList == nil or #self.playerList < 16))then
                    self.infoExpireTime = base.serverTime + 10
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:crossSchedule(onRequestEnd)
    elseif(callback)then
        callback()
    end
end

--因为后台返回的下一轮选手的分组不一定能保持与上一轮一致的顺序, 而且格式与前台所需的也有所差别, 所以格式化一下
function serverWarPersonalVoApi:checkFormatRoundPlayer(battleList)
    local totalLength = #battleList
    --先排胜者组, 胜者组是间隔两轮才开一场
    for i = 1, totalLength - 2, 2 do
        local roundLength = (#battleList[i]) / 2
        --遍历本轮的第1, 3, 5, 7场, 然后为下一场排序, 因为第一场和第二场的冠军在下一轮是排在同一场的同一个table里面的, 所以隔一个遍历就可以
        for j = 1, roundLength, 2 do
            local winnerID = battleList[i][j][3]
            local nextRoundLength = #battleList[i + 2]
            for k = math.ceil(j / 2), nextRoundLength do
                local nextID1 = battleList[i + 2][k][1]
                local nextID2 = battleList[i + 2][k][2]
                if(nextID1 == winnerID or nextID2 == winnerID)then
                    --如果是下一场比赛的第二个人与本场的胜者ID相同, 那么就得把下场比赛的两个人的顺序颠倒一下
                    if(nextID2 == winnerID)then
                        local tmp = battleList[i + 2][k][1]
                        battleList[i + 2][k][1] = battleList[i + 2][k][2]
                        battleList[i + 2][k][2] = tmp
                    end
                    --把下一场比赛放到应有的位置上
                    local tmp = battleList[i + 2][math.ceil(j / 2)]
                    battleList[i + 2][math.ceil(j / 2)] = battleList[i + 2][k]
                    battleList[i + 2][k] = tmp
                    break
                end
            end
        end
    end
    --再排败者组
    for i = 1, totalLength - 1 do
        if(i == #self.timeTb - 2)then
            break
        end
        local roundLength = #battleList[i]
        --如果是奇数轮, 那么遍历的初始下标要增加一个偏移量
        local offset
        --如果是奇数轮的话, 那么每一个元素都需要排序, 与上面的不同, 因为败者组的奇数轮的两场比赛的胜者在下一轮并不分在同一场, 偶数轮则与上面胜者组相同, 因为偶数轮相邻两场比赛的胜者在下一轮是同一场
        local interval
        if(i % 2 == 0)then
            offset = 0
            interval = 2
        else
            offset = math.floor(roundLength / 2)
            interval = 1
        end
        for j = 1 + offset, roundLength, interval do
            local winnerID = battleList[i][j][3]
            local nextRoundLength = #battleList[i + 1]
            local nextStartPos
            --分情况决定遍历下一轮比赛的初始场次下标
            if(i % 2 == 0)then
                nextStartPos = math.ceil(j / 2) + math.floor(roundLength / 2)
            else
                nextStartPos = j - offset
            end
            for k = nextStartPos, nextRoundLength do
                local nextID1 = battleList[i + 1][k][1]
                local nextID2 = battleList[i + 1][k][2]
                if(nextID1 == winnerID or nextID2 == winnerID)then
                    --以下两个换位的原理同上
                    if(nextID2 == winnerID)then
                        local tmp = battleList[i + 1][k][1]
                        battleList[i + 1][k][1] = battleList[i + 1][k][2]
                        battleList[i + 1][k][2] = tmp
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

--从后台获取战报, 观看战斗
--param roundIndex: 比赛轮次
--param groupIndex: 是胜者组为1, 败者组为2
--param battleID: 比赛的ID
--param battleIndex: 一场比赛有三局, 要观看的是第几局
function serverWarPersonalVoApi:getBattleReport(roundIndex, groupID, battleID, battleIndex, callback)
    local function getReportHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.report then
                local reportData = sData.data.report
                local report = reportData.info
                if report and SizeOfTable(report) > 0 then
                    local battleVo1 = serverWarPersonalVoApi:getBattleData(roundIndex, groupID, battleID)
                    local landform
                    if battleIndex and battleVo1 and battleVo1.landformTb and battleVo1.landformTb[battleIndex] then
                        landform = battleVo1.landformTb[battleIndex]
                    end
                    self:showBattleScene(roundIndex, report, landform)
                    self:setBattleInfo(roundIndex, groupID, battleID, battleIndex, report)
                end
            end
        end
    end
    local battleVo = serverWarPersonalVoApi:getBattleData(roundIndex, groupID, battleID)
    if battleVo and battleVo.report and battleVo.report[battleIndex] and SizeOfTable(battleVo.report[battleIndex]) > 0 then
        local report = battleVo.report[battleIndex]
        local landform
        if battleIndex and battleVo and battleVo.landformTb and battleVo.landformTb[battleIndex] then
            landform = battleVo.landformTb[battleIndex]
        end
        self:showBattleScene(roundIndex, report, landform)
    else
        --比赛Id
        local bid = self:getServerWarId()
        if bid then
            socketHelper:crossReport(bid, roundIndex, groupID, battleID, battleIndex, getReportHandler)
        end
    end
end

function serverWarPersonalVoApi:showBattleScene(roundIndex, report, landform)
    if serverWarPersonalTeamScene and serverWarPersonalTeamScene.setVisible then
        serverWarPersonalTeamScene:setVisible(false)
    end
    if serverWarPersonalKnockOutScene and serverWarPersonalKnockOutScene.setVisible then
        serverWarPersonalKnockOutScene:setVisible(false)
    end
    
    local serverWarType
    if roundIndex == 0 then
        serverWarType = 1
    else
        serverWarType = 2
    end
    local data = {data = {report = report}, isReport = true, serverWarType = serverWarType}
    if landform then
        data.landform = {landform, landform}
    end
    battleScene:initData(data)
end

--获取某场比赛在battleList中的数据
--param roundIndex: 比赛所在的轮次, 小组赛为0
--param groupID: 比赛属于胜者组还是败者组
--param battleID: 比赛在该组中的ID
--return 一个serverWarPersonalBattleVo或者nil
function serverWarPersonalVoApi:getBattleData(roundIndex, groupID, battleID)
    local roundTb = nil
    if(roundIndex == 0)then
        roundTb = self.teamBattleList
    else
        if self.knockOutBattleList then
            roundTb = self.knockOutBattleList[roundIndex]
        end
    end
    local result
    if(roundTb)then
        for k, v in pairs(roundTb) do
            if(v.groupID == groupID and v.battleID == battleID)then
                return v
            end
        end
    end
    return nil
end

function serverWarPersonalVoApi:setBattleInfo(roundIndex, groupID, battleID, battleIndex, report)
    local roundTb
    if(roundIndex == 0)then
        roundTb = self.teamBattleList
        if self.teamBattleList then
            for k, v in pairs(self.teamBattleList) do
                if(v.groupID == groupID and v.battleID == battleID)then
                    if self.teamBattleList[k].report == nil then
                        self.teamBattleList[k].report = {}
                    end
                    self.teamBattleList[k].report[battleIndex] = report
                end
            end
        end
    else
        if self.knockOutBattleList and self.knockOutBattleList[roundIndex] then
            for k, v in pairs(self.knockOutBattleList[roundIndex]) do
                if(v.groupID == groupID and v.battleID == battleID)then
                    if self.knockOutBattleList[roundIndex][k].report == nil then
                        self.knockOutBattleList[roundIndex][k].report = {}
                    end
                    self.knockOutBattleList[roundIndex][k].report[battleIndex] = report
                end
            end
        end
    end
end

--获取某一轮的献花数据
--param roundIndex: 要获取第几轮的数据
--return 一个serverWarPersonalBetVo或者nil
function serverWarPersonalVoApi:getBetData(roundIndex)
    if self.betList and roundIndex then
        return self.betList[roundIndex + 1]
    end
    return nil
end

--根据ID获取玩家的数据vo
function serverWarPersonalVoApi:getPlayer(id)
    for k, v in pairs(self.playerList) do
        if(id == v.id)then
            return v
        end
    end
end

--获取跨服战的出战部队信息
--param callback: 获取之后的回调函数
function serverWarPersonalVoApi:getTroopsInfo(callback)
    local isCallback = false
    if self:checkIsPlayer() == true then
        if self.troopsFlag == -1 then
            isCallback = true
        end
    end
    local function getFleetInfoHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                if sData.data.troops then
                    local tskinTb = sData.data.skin or {}
                    for k, v in pairs(sData.data.troops) do
                        if v and type(v) == "table" then
                            local isSetting = false
                            if sData.data and sData.data.flag and sData.data.flag[k] and tonumber(sData.data.flag[k]) and tonumber(sData.data.flag[k]) > 1 then
                                isSetting = true
                            end
                            if sData.data and sData.data.ts then
                                if type(sData.data.ts) == "table" then
                                    for k, v in pairs(sData.data.ts) do
                                        serverWarPersonalVoApi:setLastSetFleetTime(k, v)
                                    end
                                end
                            end
                            if isSetting == true then
                                for m, n in pairs(v) do
                                    if n and n.id and n.num and tonumber(n.num) then
                                        local tType = 6 + k
                                        local index = m
                                        local tid = (tonumber(n.id) or tonumber(RemoveFirstChar(n.id)))
                                        local num = tonumber(n.num)
                                        tankVoApi:setTanksByType(tType, index, tid, num)
                                    elseif n and n[1] and n[2] then
                                        local tType = 6 + k
                                        local index = m
                                        local tid = (tonumber(n[1]) or tonumber(RemoveFirstChar(n[1])))
                                        local num = tonumber(n[2])
                                        tankVoApi:setTanksByType(tType, index, tid, num)
                                    end
                                end
                            end
                        end
                        if base.tskinSwitch == 1 then
                            local tType = 6 + k
                            local tskin = tskinTb[k] or {}
                            tankSkinVoApi:setTankSkinListByBattleType(tType, tskin)
                        end
                    end
                end
                if sData.data.hero then
                    heroVoApi:clearServerWarTroops()
                    for k, v in pairs(sData.data.hero) do
                        if v and type(v) == "table" then
                            heroVoApi:setServerWarHeroList(k, v)
                        end
                    end
                end
                if sData.data.aitroops then --AI部队
                    AITroopsFleetVoApi:clearServerWarAITroops()
                    for k, v in pairs(sData.data.aitroops) do
                        if v and type(v) == "table" then
                            AITroopsFleetVoApi:setServerWarAITroopsList(k, v)
                        end
                    end
                end
                if sData.data.equip then
                    for k, v in pairs(sData.data.equip) do
                        emblemVoApi:setBattleEquip(k + 6, v)
                    end
                end
                if sData.data.plane then
                    for k, v in pairs(sData.data.plane) do
                        planeVoApi:setBattleEquip(k + 6, v)
                    end
                end
                if sData.data.ap then
                    for k, v in pairs(sData.data.ap) do
                        airShipVoApi:setBattleEquip(k + 6, v)
                    end
                end
                self.troopsFlag = 1
                if sData.data.line then
                    tankVoApi:setServerWarFleetIndexTb(sData.data.line)
                end
            end
            
            if(callback)then
                callback()
            end
        end
    end
    if isCallback == true then
        socketHelper:crossGetInfo(getFleetInfoHandler)
    else
        if(callback)then
            callback()
        end
    end
end

--给某场比赛送花
--param roundID: 轮次ID, 0是分组赛
--param groupID: 1是胜者组, 2是败者组
--param battleID: 场次ID
--param playerID: 给哪个选手送花
function serverWarPersonalVoApi:bet(roundID, groupID, battleID, playerID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(self.betList[roundID + 1])then
                self.betList[roundID + 1].times = self.betList[roundID + 1].times + 1
                self.betList[roundID + 1].battleID = battleID
                self.betList[roundID + 1].playerID = playerID
            else
                local betVo = serverWarPersonalBetVo:new()
                betVo:init({roundID, groupID, battleID, playerID, 1, 0})
                self.betList[roundID + 1] = betVo
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
    local matchId = self:getServerWarId()
    local type
    local paramRound
    if(roundID == 0)then
        type = 1
        paramRound = roundID + 1
    else
        type = 2
        paramRound = roundID
    end
    local detailId = matchId.."_"..type.."_"..paramRound.."_"..groupID.."_"..battleID
    local joinUser = playerID
    socketHelper:crossBet(matchId, detailId, joinUser, onRequestEnd)
end

function serverWarPersonalVoApi:getLastSetFleetTime(index)
    if index then
        return self.lastSetFleetTime[index]
    end
    return 0
end
function serverWarPersonalVoApi:setLastSetFleetTime(index, time)
    if index and time and self.lastSetFleetTime and self.lastSetFleetTime[index] then
        self.lastSetFleetTime[index] = time
    end
end

-- 0 可以设置
-- serverwar_cannot_set_fleet1="比赛尚未开启，无法进行部队设置！",
-- serverwar_cannot_set_fleet2="战斗即将开始，无法设置部队",
-- serverwar_cannot_set_fleet3="战斗进行中，无法设置部队!",
-- serverwar_cannot_set_fleet4="战斗已结束，无法设置部队！",
-- serverwar_cannot_set_fleet5="您未参加跨服战，无法进行部队设置！",
function serverWarPersonalVoApi:getSetFleetStatus()
    local status = self:checkStatus()
    if status < 20 then
        return 1
    elseif self:checkIsPlayer() == false then
        return 5
    elseif status == 20 then
        for i = 0, 7 do
            local roundStatus = self:getRoundStatus(i)
            if roundStatus == 10 then
                return 0
            elseif roundStatus == 11 then
                return 2
            elseif roundStatus >= 21 and roundStatus <= 23 then
                return 3
            end
        end
    elseif status > 20 then
        return 4
    end
    return 1
end

function serverWarPersonalVoApi:getIsAllSetFleet()
    local canSet = self:getSetFleetStatus()
    if canSet == 0 then
        local isAllSet = tankVoApi:serverWarAllSetFleet()
        if isAllSet == false then
            return false
        end
    end
    return true
end

function serverWarPersonalVoApi:isHasServerReward(index)
    local severRewardCfg = serverWarPersonalVoApi:getSeverRewardCfg()
    if index and severRewardCfg and severRewardCfg[index] then
        return true
    else
        return false
    end
end

--根据第几轮和献花次数，获得献花数量,isPoint:是否是取获得的积分
function serverWarPersonalVoApi:getSendFlowerNum(roundID, num, isPoint, isWin)
    if roundID and num then
        local cfgIndex = serverWarPersonalCfg.betStyle4Round[roundID + 1]
        if cfgIndex then
            local winnerCfg = serverWarPersonalCfg["winner_"..cfgIndex]
            local failerCfg = serverWarPersonalCfg["failer_"..cfgIndex]
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

function serverWarPersonalVoApi:betReward(roundIndex, point)
    local betList = self:getBetList()
    if betList and roundIndex and betList[roundIndex + 1] then
        betList[roundIndex + 1].hasGet = 1
    end
    self:setPoint(self:getPoint() + point)
    self:addPointDetail({}, 1)
end

------------以下积分商店----------------
--积分商店开启后，是否打开过,true：不显示，false：显示
function serverWarPersonalVoApi:getShopHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarShopHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if (localData ~= nil and localData ~= "") then
            return true
        else
            return false
        end
    end
    return true
end
function serverWarPersonalVoApi:setShopHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarShopHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        CCUserDefault:sharedUserDefault():setStringForKey(dataKey, "open")
    end
end
--普通道具配置
function serverWarPersonalVoApi:getShopCommonItems()
    if self.f_pShopItems and next(self.f_pShopItems) then
        do return self.f_pShopItems end
    end
    self.f_pShopItems = {}
    for k, v in pairs(serverWarPersonalCfg.pShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_pShopItems[k] = v
        end
    end
    return self.f_pShopItems
end
--珍品配置
function serverWarPersonalVoApi:getShopRareItems()
    if self.f_aShopItems and next(self.f_aShopItems) then
        do return self.f_aShopItems end
    end
    self.f_aShopItems = {}
    for k, v in pairs(serverWarPersonalCfg.aShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_aShopItems[k] = v
        end
    end
    return self.f_aShopItems
end
function serverWarPersonalVoApi:getShopFlag()
    return self.shopFlag
end
function serverWarPersonalVoApi:setShopFlag(shopFlag)
    self.shopFlag = shopFlag
end
function serverWarPersonalVoApi:getBuyStatus()
    return self.buyStatus
end
function serverWarPersonalVoApi:setBuyStatus(buyStatus)
    self.buyStatus = buyStatus
end
--根据id获取道具的配置
function serverWarPersonalVoApi:getItemById(id)
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
--初始化跨服战的商店信息
function serverWarPersonalVoApi:initShopInfo()
    local commonItems = self:getShopCommonItems()
    local rareItems = self:getShopRareItems()
    self.commonList = {}
    self.rareList = {}
    for k, v in pairs(commonItems) do
        local vo = serverWarPersonalShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.commonList, vo)
    end
    for k, v in pairs(rareItems) do
        local vo = serverWarPersonalShopVo:new()
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
--获取跨服战的商店信息
--param callback: 获取之后的回调函数
function serverWarPersonalVoApi:getShopInfo(callback, data)
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

function serverWarPersonalVoApi:getPointDetailFlag()
    return self.pointDetailFlag
end
function serverWarPersonalVoApi:setPointDetailFlag(pointDetailFlag)
    self.pointDetailFlag = pointDetailFlag
end

function serverWarPersonalVoApi:getDetailExpireTime()
    return self.detailExpireTime
end
function serverWarPersonalVoApi:setDetailExpireTime(detailExpireTime)
    self.detailExpireTime = detailExpireTime
end

function serverWarPersonalVoApi:clearPointDetail()
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
function serverWarPersonalVoApi:formatPointDetail(callback)
    local function getRecordHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.record then
                self.pointDetail = nil
                self.pointDetail = {}
                
                local record = sData.data.record
                if record.add and SizeOfTable(record.add) > 0 then
                    for k, v in pairs(record.add) do
                        local type, time, message, color = self:formatMessage(v, 1)
                        if type and time and message then
                            local vo = serverWarPointDetailVo:new()
                            vo:initWithData(type, time, message, color)
                            table.insert(self.pointDetail, vo)
                        end
                    end
                end
                if record.buy and SizeOfTable(record.buy) > 0 then
                    for k, v in pairs(record.buy) do
                        local type, time, message, color = self:formatMessage(v, 2)
                        if type and time and message then
                            local vo = serverWarPointDetailVo:new()
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
                
                local nextRoundID
                for i = 0, #self.timeTb - 1 do
                    local roundStatus = self:getRoundStatus(i)
                    if(roundStatus < 20)then
                        nextRoundID = i
                        break
                    end
                end
                if(nextRoundID)then
                    self.detailExpireTime = self.timeTb[nextRoundID + 1] + serverWarPersonalCfg.battleTime * 3
                else
                    self.detailExpireTime = self.endTime
                end
                
                self:setPointDetailFlag(1)
            end
            if(callback)then
                callback()
            end
        end
    end
    if self:getPointDetailFlag() == -1 then
        local function getScheduleInfoHandler()
            socketHelper:crossRecord(getRecordHandler)
        end
        self:getScheduleInfo(getScheduleInfoHandler)
    else
        if(callback)then
            callback()
        end
    end
end
function serverWarPersonalVoApi:formatMessage(data, mType)
    local id
    local type
    local time = 0
    local point = 0
    local targetName = ""
    local fType
    local roundNum = 0
    local color = G_ColorGreen
    local rank = 0
    if mType == 1 then
        if data and SizeOfTable(data) > 0 then
            point = tonumber(data[1]) or 0
            fType = tonumber(data[2])
            id = data[3]
            time = tonumber(data[4]) or 0
        end
        if fType == 2 then
            type = 8
            rank = tonumber(data[5]) or 0
        else
            local warId, roundIndex, groupID, battleID = self:getFormatId(id)
            local battleVo = self:getBattleData(roundIndex, groupID, battleID)
            roundNum = roundIndex
            if fType == 0 then
                local betVo = self:getBetData(roundIndex)
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
                    local selfId = playerVoApi:getUid() .. "-"..base.curZoneID
                    if battleVo.id1 and battleVo.id1 == selfId then
                        targetId = battleVo.id2
                    elseif battleVo.id2 and battleVo.id2 == selfId then
                        targetId = battleVo.id1
                    end
                    if targetId then
                        local playerVo = self:getPlayer(targetId)
                        if playerVo then
                            targetName = playerVo.name or ""
                        end
                    end
                    if roundIndex == 0 then
                        if battleVo.winnerID and battleVo.winnerID == selfId then
                            type = 3
                        else
                            type = 4
                        end
                    else
                        -- print("roundIndex",roundIndex)
                        -- print("battleVo.winnerID",battleVo.winnerID)
                        -- print("selfId",selfId)
                        if battleVo.winnerID and battleVo.winnerID == selfId then
                            type = 5
                        else
                            type = 6
                        end
                    end
                end
                -- if time then
                -- time=time+serverWarPersonalCfg.battleTime*3
                -- end
            end
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
    if type then
        if type == 1 or type == 2 or type == 3 or type == 4 then
            params = {targetName, point}
        elseif type == 5 or type == 6 then
            params = {roundNum, targetName, point}
        elseif type == 7 then
            params = {targetName, point}
        elseif type == 8 then
            params = {rank, point}
        end
        message = getlocal("serverwar_point_desc_"..type, params)
    end
    
    return type, time, message, color
end
function serverWarPersonalVoApi:addPointDetail(data, mType)
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
        local vo = serverWarPointDetailVo:new()
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
    
    if self.pointDetail then
        while SizeOfTable(self.pointDetail) > serverWarPersonalCfg.militaryrank do
            table.remove(self.pointDetail, serverWarPersonalCfg.militaryrank + 1)
        end
    end
end

function serverWarPersonalVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
    return date
end

-- function serverWarPersonalVoApi:getPerPageNum()
-- return self.perPageNum
-- end
-- function serverWarPersonalVoApi:getPage()
-- return self.page
-- end
-- function serverWarPersonalVoApi:setPage(page)
-- self.page=page
-- end
-- function serverWarPersonalVoApi:isHasMore()
-- return self.hasMore
-- end
-- function serverWarPersonalVoApi:getMinTime()
-- local pointDetail=self:getPointDetail()
-- local minTime=0
-- if pointDetail then
-- local function sortAsc(a, b)
-- if a.time and b.time then
-- return a.time > b.time
-- end
-- end
-- table.sort(pointDetail,sortAsc)
-- minTime=pointDetail[SizeOfTable(pointDetail)].time  or 0
-- end
-- return minTime
-- end

--购买物品 type:1：道具，2：珍品 id：物品id
function serverWarPersonalVoApi:buyItem(type, id, callback)
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
    local matchId = self:getServerWarId()
    if matchId and sType and id then
        socketHelper:crossBuy(matchId, sType, id, buyHandler)
    end
end

--获取商店里面的道具列表
function serverWarPersonalVoApi:getCommonList()
    if (self.commonList) then
        return self.commonList
    end
    return {}
end
--获取商店里面的珍品列表
function serverWarPersonalVoApi:getRareList()
    if (self.rareList) then
        return self.rareList
    end
    return {}
end
--获取积分明细
function serverWarPersonalVoApi:getPointDetail()
    if (self.pointDetail) then
        return self.pointDetail
    end
    return {}
end
--积分
function serverWarPersonalVoApi:getPoint()
    return self.point
end
function serverWarPersonalVoApi:setPoint(point)
    self.point = point
end
--我的排名
function serverWarPersonalVoApi:getMyRank()
    return self.myRank
end
function serverWarPersonalVoApi:setMyRank(myRank)
    self.myRank = myRank
end
--自己根据排名，可以领取的积分
function serverWarPersonalVoApi:getRewardPoint()
    local point = 0
    local myRank = self:getMyRank()
    if myRank and myRank > 0 then
        for k, v in pairs(serverWarPersonalCfg.rankReward) do
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
function serverWarPersonalVoApi:getIsRewardRank()
    return self.isRewardRank
end
function serverWarPersonalVoApi:setIsRewardRank(isRewardRank)
    self.isRewardRank = isRewardRank
end
--领取排行榜奖励
function serverWarPersonalVoApi:rewardRank(callback)
    local function rewardCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:setIsRewardRank(true)
            local point = self:getPoint()
            local rewardPoint = self:getRewardPoint()
            self:setPoint(point + rewardPoint)
            
            local myRank = self:getMyRank()
            local data = {rewardPoint, 2, "", sData.ts, myRank}
            self:addPointDetail(data, 3)
            
            if callback then
                callback()
            end
        end
    end
    socketHelper:crossGetrankingreward(rewardCallback)
end
------------以上积分商店----------------

------------以下排行榜----------------
--排行榜开启后，是否打开过,打开过true：不显示，未开过false：显示
function serverWarPersonalVoApi:getRankHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarRankHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if (localData ~= nil and localData ~= "") then
            return true
        else
            return false
        end
    end
    return true
end
function serverWarPersonalVoApi:setRankHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarRankHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        CCUserDefault:sharedUserDefault():setStringForKey(dataKey, "open")
    end
end

function serverWarPersonalVoApi:getRankFlag()
    return self.rankFlag
end
function serverWarPersonalVoApi:setRankFlag(rankFlag)
    self.rankFlag = rankFlag
end
--战斗结束后排行榜
function serverWarPersonalVoApi:clearRankList()
    self.rankList = nil
end
function serverWarPersonalVoApi:formatRankList(callback)
    local function crossRankingHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.ranking then
                self.rankList = {}
                local selfId = playerVoApi:getUid() .. "-"..base.curZoneID
                for k, v in pairs(sData.data.ranking) do
                    local id = k
                    local rank = tonumber(v) or 0
                    local name = ""
                    local server = ""
                    local value = 0
                    
                    if selfId == id and rank and rank > 0 then
                        self:setMyRank(rank)
                    end
                    
                    local playerVo = self:getPlayer(id)
                    if playerVo then
                        name = playerVo.name or ""
                        server = playerVo.serverName or ""
                        value = playerVo.power or 0
                    end
                    
                    if rank and rank > 0 then
                        local vo = serverWarPointRankVo:new()
                        vo:initWithData(id, name, server, rank, value)
                        table.insert(self.rankList, vo)
                    end
                end
                local function sortAsc(a, b)
                    if a and b and a.rank and b.rank and tonumber(a.rank) and tonumber(b.rank) then
                        return tonumber(a.rank) < tonumber(b.rank)
                    end
                end
                table.sort(self.rankList, sortAsc)
            end
            
            self:setRankFlag(1)
            if callback then
                callback()
            end
        end
    end
    local flag = self:getRankFlag()
    local status = serverWarPersonalVoApi:checkStatus()
    if status >= 30 and flag == -1 then
        socketHelper:crossRanking(crossRankingHandler)
    else
        if callback then
            callback()
        end
    end
end
function serverWarPersonalVoApi:getRankList()
    if self.rankList then
        return self.rankList
    end
    return {}
end
function serverWarPersonalVoApi:getRankRewardCfg()
    return serverWarPersonalCfg.rankReward
end
function serverWarPersonalVoApi:getSeverRewardCfg()
    return serverWarPersonalCfg.severReward
end
function serverWarPersonalVoApi:getRankIcon(rank, startTime, notTimeLimit)
    if rank and rank > 0 and rank <= 3 and serverWarPersonalCfg and serverWarPersonalCfg.rankReward and serverWarPersonalCfg.rankReward[rank] then
        local sType = 0
        if notTimeLimit == true then
            sType = 1
        elseif startTime and startTime > 0 then
            local cfg = serverWarPersonalCfg.rankReward[rank]
            local normalLastTime = cfg.lastTime[1] or 0
            local grayLastTime = cfg.lastTime[2] or 0
            local toGrayTime = G_getWeeTs(startTime) + (normalLastTime + 1) * 3600 * 24
            local toDisappearTime = G_getWeeTs(startTime) + (normalLastTime + grayLastTime + 1) * 3600 * 24
            if base.serverTime >= startTime and base.serverTime < toGrayTime then
                sType = 1
            elseif base.serverTime >= toGrayTime and base.serverTime < toDisappearTime then
                sType = 2
            end
        end
        for k, v in pairs(serverWarPersonalCfg.rankReward) do
            if v.range and v.range[1] and v.range[2] and v.icon then
                if rank == v.range[1] and v.range[1] == v.range[2] then
                    return v.icon, sType, v
                end
            end
        end
    end
    return nil
end
------------以上排行榜----------------

--格式化后台的id获取数据 36_1_1_1_1_e
-- 4278_1_1_1_1_a：matchId_分组赛or淘汰赛_第几轮_胜者组or败者组_a or b or c.....
function serverWarPersonalVoApi:getFormatId(id)
    if id then
        local arr = Split(id, "_")
        if arr and SizeOfTable(arr) >= 6 then
            local warId = arr[1] .. "_"..arr[2] --跨服战id
            local group = tonumber(arr[3])--分组赛 1，淘汰赛 2
            local roundIndex = tonumber(arr[4]) --第几轮
            local groupID = tonumber(arr[5]) --胜者组 1，败者组 2
            local battleID = arr[6]--第几场战斗
            if group == 1 then
                roundIndex = 0
            end
            return warId, roundIndex, groupID, battleID
        end
    end
    return nil
end
--组合id
function serverWarPersonalVoApi:getConnectId(warId, roundID, groupID, battleID)
    local group
    local round
    if roundID == 0 then
        group = 1
        round = 1
    else
        group = 2
        round = roundID
    end
    local detailId = tostring(warId) .. "_"..tostring(group) .. "_"..tostring(round) .. "_"..tostring(groupID) .. "_"..tostring(battleID)
    return detailId
end

--获取前三名的数据
--return: 会异步返回一个table, table是回调函数的参数, table的第1,2,3号元素就是前三名的数据vo, 如果此时前两名还没有决出, 那么table只有3, 没有1和2
function serverWarPersonalVoApi:getTop3(callback)
    local function onGetSchedule()
        local result = {}
        if(self.knockOutBattleList[7] and self.knockOutBattleList[7][1])then
            if(self.knockOutBattleList[7][1].winnerID and self.knockOutBattleList[7][1].winnerID == self.knockOutBattleList[7][1].id1)then
                result[1] = self.knockOutBattleList[7][1].player1
                result[2] = self.knockOutBattleList[7][1].player2
            elseif(self.knockOutBattleList[7][1].winnerID and self.knockOutBattleList[7][1].winnerID == self.knockOutBattleList[7][1].id2)then
                result[1] = self.knockOutBattleList[7][1].player2
                result[2] = self.knockOutBattleList[7][1].player1
            end
        end
        if(self.knockOutBattleList[6] and self.knockOutBattleList[6][1])then
            if(self.knockOutBattleList[6][1].winnerID)then
                if(self.knockOutBattleList[6][1].winnerID == self.knockOutBattleList[6][1].id1)then
                    result[3] = self.knockOutBattleList[6][1].player2
                else
                    result[3] = self.knockOutBattleList[6][1].player1
                end
            end
        end
        if(callback)then
            callback(result)
        end
    end
    self:getScheduleInfo(onGetSchedule)
end

--检查是否要显示跨服战
function serverWarPersonalVoApi:checkShowServerWar()
    local status = self:checkStatus()
    if(status >= 10 and status < 40)then
        return true
    else
        return false
    end
end

--检查当前登录玩家是否参加跨服战
function serverWarPersonalVoApi:checkIsPlayer()
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

--检查当前登录玩家今天是否有比赛
function serverWarPersonalVoApi:checkPlayerHasBattle()
    if(self:checkIsPlayer() == false)then
        return false
    end
    local curRound
    if self.timeTb then
        for i = 0, #self.timeTb - 1 do
            local roundStatus = self:getRoundStatus(i)
            if(roundStatus >= 10 and roundStatus < 30)then
                curRound = i
                break
            end
        end
    end
    if(curRound)then
        local list
        if(curRound == 0)then
            list = self.teamBattleList
        else
            list = self.knockOutBattleList[curRound]
        end
        if(list)then
            local selfID = playerVoApi:getUid() .. "-"..base.curZoneID
            for k, v in pairs(list) do
                if(v.id1 == selfID or v.id2 == selfID)then
                    return true, v
                end
            end
        end
    end
    return false
end

--跨服战的状态
--return 0: 最近都没有安排过跨服战或者还没到跨服战的预热时间
--return 10: 跨服战预热阶段
--return 20: 战斗阶段
--return 30: 战斗结束,领奖时间
--return 40: 领奖时间也过去了,跨服战彻底结束
function serverWarPersonalVoApi:checkStatus()
    if(self.startTime == nil or base.serverTime < self.startTime)then
        return 0
    elseif(base.serverTime < self.startTime + serverWarPersonalCfg.preparetime * 86400)then
        return 10
    else
        local timeList = serverWarPersonalVoApi:getBattleTimeList()
        local lastBattleTime = timeList[SizeOfTable(timeList)]
        local allBattleEndTime = lastBattleTime + serverWarPersonalCfg.battleTime * 3
        if base.serverTime < allBattleEndTime then
            return 20
            -- elseif(base.serverTime<self.endTime-serverWarPersonalCfg.shoppingtime*86400)then
            -- return 20
        elseif(base.serverTime < self.endTime)then
            return 30
        else
            return 40
        end
    end
end

function serverWarPersonalVoApi:tick()
    if self then
        if self.timeTb and SizeOfTable(self.timeTb) > 0 then
            local battleTime = serverWarPersonalCfg.battleTime * 3
            local thirdSendTime = self.timeTb[SizeOfTable(self.timeTb) - 1] + battleTime
            local firstSendTime = self.timeTb[SizeOfTable(self.timeTb)] + battleTime
            -- print("base.serverTime",base.serverTime)
            -- print("thirdSendTime",thirdSendTime)
            -- print("firstSendTime",firstSendTime)
            if base.serverTime == thirdSendTime then
                local function thirdSendChat(result)
                    -- print("result[3]",result[3])
                    if result and result[3] then
                        local playerVo = result[3]
                        local name = playerVo.name or ""
                        local serverName = playerVo.serverName or ""
                        local params = {subType = 4, contentType = 3, message = {key = "chatSystemMessage16", param = {name, serverName}}, ts = base.serverTime, isSystem = 1}
                        chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                    end
                end
                self:getTop3(thirdSendChat)
            elseif base.serverTime == firstSendTime then
                local function firstSendChat(result)
                    if result then
                        local selfUid = playerVoApi:getUid()
                        for i = 1, 3 do
                            -- print("result[i]",i,result[i])
                            if result[i] then
                                local playerVo = result[i]
                                local endTime = firstSendTime
                                if playerVo and playerVo.uid then
                                    if tostring(playerVo.uid) == tostring(selfUid) then
                                        self:setMyRank(i)
                                        playerVoApi:setServerWarRank(i)
                                        playerVoApi:setServerWarRankStartTime(endTime)
                                    end
                                end
                                if i < 3 then
                                    local key = ""
                                    if i == 1 then
                                        key = "chatSystemMessage14"
                                    elseif i == 2 then
                                        key = "chatSystemMessage15"
                                    end
                                    local playerVo = result[i]
                                    local name = playerVo.name or ""
                                    local serverName = playerVo.serverName or ""
                                    local params = {subType = 4, contentType = 3, message = {key = key, param = {name, serverName}}, ts = base.serverTime, isSystem = 1}
                                    chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                                end
                            end
                        end
                    end
                end
                self:getTop3(firstSendChat)
            end
            
            for k, v in pairs(self.timeTb) do
                if v and tonumber(v) and base.serverTime == tonumber(v) + serverWarPersonalCfg.battleTime * 3 then
                    self:addPointDetail({}, 1)
                end
            end
        end
        
        local warInfoExpireTime = self:getWarInfoExpireTime()
        if (warInfoExpireTime and warInfoExpireTime > 0 and base.serverTime >= warInfoExpireTime) then
            self:getWarInfo()
        end
        
        -- if self.timeTb then
        -- for k,v in pairs(self.timeTb) do
        -- if v and tonumber(v) and base.serverTime==tonumber(v)+serverWarPersonalCfg.battleTime*3 then
        -- self:addPointDetail({},1)
        
        -- if k==SizeOfTable(self.timeTb) then
        -- local function callback(result)
        -- if result and SizeOfTable(result)>0 then
        -- local selfUid=playerVoApi:getUid()
        -- local playerVo1=result[1]
        -- local playerVo2=result[2]
        -- local playerVo3=result[3]
        -- local endTime=tonumber(v)+serverWarPersonalCfg.battleTime*3
        -- if playerVo1 and playerVo1.uid then
        -- if tostring(playerVo1.uid)==tostring(selfUid) then
        -- playerVoApi:setServerWarRank(1)
        -- playerVoApi:setServerWarRankStartTime(endTime)
        -- end
        -- end
        -- if playerVo2 and playerVo2.uid then
        -- if tostring(playerVo2.uid)==tostring(selfUid) then
        -- playerVoApi:setServerWarRank(2)
        -- playerVoApi:setServerWarRankStartTime(endTime)
        -- end
        -- end
        -- if playerVo3 and playerVo3.uid then
        -- if tostring(playerVo3.uid)==tostring(selfUid) then
        -- playerVoApi:setServerWarRank(3)
        -- playerVoApi:setServerWarRankStartTime(endTime)
        -- end
        -- end
        -- end
        -- end
        -- self:getTop3(callback)
        -- end
        -- end
        -- end
        -- end
    end
end

function serverWarPersonalVoApi:clear()
    self.serverWarId = nil
    self.serverList = nil
    self.playerList = nil
    self.teamBattleList = nil
    self.knockOutBattleList = nil
    self.startTime = nil
    self.endTime = nil
    self.timeTb = nil
    self.infoExpireTime = 0
    self.troopsExpireTime = 0
    self.shopExpireTime = 0
    self.warInfoExpireTime = 0
    self.detailExpireTime = 0
    self.betList = nil
    self.commonList = nil
    self.rareList = nil
    self.point = 0
    self:clearPointDetail()
    self.pointDetail = {}
    -- self.page=0
    -- self.hasMore=false
    -- self.perPageNum=10
    -- self.maxPage=5
    self.buyStatus = 0
    self.rankList = nil
    self.lastSetFleetTime = {0, 0, 0}
    self.myRank = 0
    self.isRewardRank = false
    self.flag = -1
    self.shopFlag = -1
    self.pointDetailFlag = -1
    self.rankFlag = -1
    self.troopsFlag = -1
    self.lastSetStrategyTime = 0
    self.f_pShopItems = nil
    self.f_aShopItems = nil
end
