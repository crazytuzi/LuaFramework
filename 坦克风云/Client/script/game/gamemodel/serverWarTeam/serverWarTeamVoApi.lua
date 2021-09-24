require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamAllianceVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamShopVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamPointDetailVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamRankVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamRecordVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamPRecordVo"
require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamBetVo"
require "luascript/script/config/gameconfig/serverWarTeam/serverWarTeamCfg"
serverWarTeamVoApi =
{
    serverWarId = nil, --跨服战id
    serverList = nil, --参与跨服战的服务器列表
    localTeamList = nil, --本服有资格参赛的团队列表
    teamList = nil, --参赛团队列表
    outBatteList = nil, --跨服赛对阵数据
    inBattleList = nil, --服内赛对阵数据
    startTime = nil, --跨服战开始时间
    endTime = nil, --跨服战结束时间
    timeTb = nil, --一个table, 里面存的是每轮战斗的开启时间戳
    
    warInfoExpireTime = 0, --初始化信息过期时间,现在只是判断初始化使用
    
    betList = nil, --每一轮的送花记录
    commonList = nil, --道具列表
    rareList = nil, --珍品列表
    point = 0, --积分
    pointDetail = {}, --积分明细
    detailExpireTime = 0, --积分明细过期时间
    buyStatus = 0, --可以购买商店道具状态，0：都未开启，1：只有道具开启，2：道具和珍品都开启
    
    rankList = nil, --排行榜
    lastSetFleetTime = 0, --上一次设置部队时间
    
    myRank = 0, --我的军团的排名
    isRewardRank = false, --是否领取过排行奖励
    shopFlag = -1, --是否初始化商店数据,-1:未初始化，1:已经初始化
    pointDetailFlag = -1, --是否初始化积分明细,-1:未初始化，0:需要刷新面板，1:已经初始化
    rankFlag = -1, --是否初始化排行榜数据,-1:未初始化，1:已经初始化
    troopsFlag = -1, --是否初始化部队数据,-1:未初始化，1:已经初始化
    
    memFlag = -1, --上阵变化标示
    memList = {}, --上阵人员
    isApply = -1, --自己军团是否已经报过名，-1没有，1有
    lastSetMemTime = 0, --上一次设置上阵成员时间
    carrygems = 0, --本场战斗总共注入的金币
    gems = 0, --本场战斗可以使用的金币
    baseDonateNum = 0, --本场战斗捐献基地的次数
    basetroops = {}, --本场战斗基地守军的部队信息
    lastDonateTime = 0, --上次捐献的时间
    donateFlag = -1, --捐献变化标示
    
    --战斗统计数据
    redPoint = 0,
    bluePoint = 0,
    redDestroy = {},
    blueDestroy = {},
    rewardContribution = 0,
    redVip = "",
    blueVip = "",
    personDestroyTab = {},
    allianceDestroyTab = {},
    recordTab = {}, --各场战斗军团战报
    dFlag = {}, --各场战斗军团战报标示
    nextPageTab = {}, --战报数据请求到哪一页
    pageNum = 10, --战报一页10条战报
    pRecordTab = {}, --各场战斗个人战报
    pFlag = {}, --各场战斗个人战报标示
    pNextPageTab = {}, --个人战报数据请求到哪一页
    pPageNum = 10, --个人战报一页10条战报
    
    curMaxPageTab = {}, --当前已经获取到数据的页数
    curMaxPPageTab = {}, --当前已经获取到个人战报数据的页数
    
    isMemChange = 0, --军团成员是否变化，-1没有，1有
    isSendNotice = true, --是否发过冠亚军公告
    
    socketHost = nil, --第二个Socket的地址和端口
    
    --组编号ABCD和1234的对应关系
    keyMap = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10, k = 11, l = 12, m = 13, n = 14, o = 15, p = 16},
    f_pShopItems = nil, --普通商店列表
    f_aShopItems = nil, --珍品商店列表
}

--跨服战id
function serverWarTeamVoApi:getServerWarId()
    return self.serverWarId
end
function serverWarTeamVoApi:setServerWarId(serverWarId)
    self.serverWarId = serverWarId
end

function serverWarTeamVoApi:getWarInfoExpireTime()
    return self.warInfoExpireTime
end
function serverWarTeamVoApi:setWarInfoExpireTime(warInfoExpireTime)
    self.warInfoExpireTime = warInfoExpireTime
end

--获取参加本次跨服战的各个服务器的ID和名字
--return 一个table, table的每个元素又是一个table B, table B的第一个元素是服务器的ID, 第二个元素是服务器的名称
function serverWarTeamVoApi:getServerList()
    if(self.serverList)then
        return self.serverList
    else
        return {}
    end
end

--获取所有的参赛团队信息
--return 一个table, table里面的元素是serverWarTeamAllianceVo
function serverWarTeamVoApi:getTeamList()
    if(self.teamList)then
        return self.teamList
    else
        return {}
    end
end

--根据ID获取参赛团队的数据vo
function serverWarTeamVoApi:getTeam(id)
    for k, v in pairs(self.teamList) do
        if(id == v.id)then
            return v
        end
    end
end

--获取服外赛每轮的战斗时间表
--return 一个table, table里面是每轮战斗的时间戳
function serverWarTeamVoApi:getBattleTimeList()
    if(self.timeTb)then
        return self.timeTb
    else
        return {}
    end
end

--获取某轮的某场比赛的开战时间
--param roundIndex: 比赛的轮次
--param battleID: 比赛的ID, abcde...
--return: 开战时间戳
function serverWarTeamVoApi:getOutBattleTime(roundIndex, battleID)
    local battleIndex = self.keyMap[battleID]
    return self.timeTb[roundIndex][battleIndex]
end

--获取服内赛的战斗数据
function serverWarTeamVoApi:getInBattleList()
    return {}
end

--获取服外赛的战斗数据
function serverWarTeamVoApi:getOutBattleList()
    if(self.outBatteList)then
        return self.outBatteList
    else
        return {}
    end
end

--获取服外赛有几轮，即持续几天
function serverWarTeamVoApi:getRoundNum()
    local roundNum = serverWarTeamCfg.durationtime - serverWarTeamCfg.shoppingtime
    return roundNum
end

--获取某一场战斗是否获胜
function serverWarTeamVoApi:getBattleIsWin(roundIndex, battleID)
    if self.keyMap and self.keyMap[battleID] then
        local battleIndex = self.keyMap[battleID]
        if(self.outBatteList and self.outBatteList[roundIndex] and self.outBatteList[roundIndex][battleIndex])then
            local battleData = self.outBatteList[roundIndex][battleIndex]
            if(battleData and battleData.winnerID)then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.aid then
                    local id = base.curZoneID.."-"..selfAlliance.aid
                    if id == battleData.winnerID then
                        return true
                    end
                end
            end
        end
    end
    return false
end

--获取当前正在进行的战斗的serverWarTeamBattleVo
function serverWarTeamVoApi:getCurrentBattle()
    local curRoundID
    for i = 1, #self.timeTb do
        local roundStatus = self:getRoundStatus(i)
        if(roundStatus == 20)then
            curRoundID = i
            break
        end
    end
    if(curRoundID)then
        for k, startTime in pairs(self.timeTb[curRoundID]) do
            if(base.serverTime < startTime + serverWarTeamCfg.warTime)then
                return self.outBatteList[curRoundID][k]
            end
        end
    end
    return nil
end

--当前的roundIndex第几轮，每一天是一轮 0:目前不在任何一轮
function serverWarTeamVoApi:getCurrentRoundIndex()
    local status = self:checkStatus()
    if status == 11 then
        return 1
        -- elseif status==20 then
    elseif(base.serverTime < (self.endTime - (serverWarTeamCfg.shoppingtime) * 86400))then
        local beginTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400
        for i = 1, 3 do
            if base.serverTime >= beginTime + 86400 * (i - 1) and base.serverTime < beginTime + 86400 * i then
                return i
            end
        end
    end
    return 0
end
--根据当前的轮次，获取今天自己军团是否参赛
function serverWarTeamVoApi:getBattleID(roundIndex)
    local battleList = self:getOutBattleList()
    if roundIndex and roundIndex > 0 and battleList and battleList[roundIndex] then
        -- print("G_Json.encode(battleList)",G_Json.encode(battleList))
        for k, v in pairs(battleList[roundIndex]) do
            if v then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.aid then
                    local id = base.curZoneID.."-"..selfAlliance.aid
                    if id and v then
                        if v.id1 and v.id1 == id then
                            return v.battleID
                        end
                        if v.id2 and v.id2 == id then
                            return v.battleID
                        end
                    end
                end
            end
        end
    end
    return nil
end
--根据轮次，和战斗id，获取战斗数据
function serverWarTeamVoApi:getBattleVoByID(roundIndex, battleID)
    local battleList = self:getOutBattleList()
    if roundIndex and battleList and battleList[roundIndex] then
        for k, v in pairs(battleList[roundIndex]) do
            if v and v.battleID and battleID then
                if battleID == v.battleID then
                    return v
                end
            end
        end
    end
    return nil
end

--根据个人数据获取，激活守军和进入战场的按钮状态变化，
--param roundIndex: 比赛的轮次
--return 0: 显示激活守军，不可点击(默认)
--return 1: 可激活守军
--return 2: 显示进入战场，不可点击
--return 3: 可进入战场
function serverWarTeamVoApi:getEnterBattleStatus()
    if self:getIsApply() == 1 then
        if self:checkStatus() == 11 then
            return 0
        elseif self:checkStatus() == 20 then
            local roundIndex = self:getCurrentRoundIndex()
            if roundIndex == 1 and base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60 then
                return 0
            elseif roundIndex == 1 and base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60 then
                return 1
            else
                --今天自己军团有没有参赛
                local battleID = self:getBattleID(roundIndex)
                if roundIndex and roundIndex > 0 and battleID then
                    local battleStatus = self:getOutBattleStatus(roundIndex, battleID)
                    if battleStatus < 11 then
                        return 1
                    elseif battleStatus == 11 then
                        return 2
                    elseif battleStatus >= 12 and battleStatus < 30 then
                        -- local isBattleMem=self:isBattleMem()
                        -- if isBattleMem==true then
                        if self:canJoinServerWarTeam(nil, true) == true then
                            return 3
                        else
                            return 2
                        end
                    elseif battleStatus >= 30 then
                        local isWin = self:getBattleIsWin(roundIndex, battleID)
                        if isWin == true and roundIndex < 3 and battleStatus > 30 then
                            return 1
                        else
                            return 0
                        end
                    end
                else
                    return 0
                end
            end
        else
            return 0
        end
    else
        return 0
    end
end

--根据传来的比赛轮次获取该轮比赛的状态
--param roundIndex: 比赛的轮次
--param type: 0是服内赛, 1是服外赛, 默认是1
--return 0: 下次比赛不是该轮次, 不可献花的状态
--return 10: 可献花
--return 20: 战斗进行中不能献花
--return 30: 战斗已结束
function serverWarTeamVoApi:getRoundStatus(roundIndex, type)
    if(type == nil)then
        type = 1
    end
    local roundZeroTs = G_getWeeTs(self.timeTb[roundIndex][1])
    if(base.serverTime >= roundZeroTs + serverWarTeamCfg.flowerLimit[roundIndex][2][1] * 3600 + serverWarTeamCfg.flowerLimit[roundIndex][2][2] * 60)then
        return 30
    elseif(base.serverTime >= roundZeroTs + serverWarTeamCfg.flowerLimit[roundIndex][1][1] * 3600 + serverWarTeamCfg.flowerLimit[roundIndex][1][2] * 60)then
        return 20
    else
        if(roundIndex == 1)then
            if(base.serverTime >= G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60)then
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

--根据传来的比赛轮次和比赛ID获取服外赛的某场比赛的状态
--param roundIndex: 比赛的轮次
--param battleID: 比赛的ID, abcde...
--return 0: 没开战
--return 11: 开赛前10分钟, 不可设置部队买NPC什么的, 也不能进场
--return 12: 开赛前5分钟, 可以进场可以买buff但是不能移动
--return 20: 战斗中
--return 30: 战斗已结束
--return 31: 战斗已结束,战斗最长时间已过
function serverWarTeamVoApi:getOutBattleStatus(roundIndex, battleID)
    local battleIndex = self.keyMap[battleID]
    if(self.outBatteList and self.outBatteList[roundIndex] and self.outBatteList[roundIndex][battleIndex])then
        local battleData = self.outBatteList[roundIndex][battleIndex]
        if(base.serverTime >= self.timeTb[roundIndex][battleIndex] + serverWarTeamCfg.warTime)then
            return 31
        elseif(battleData and battleData.winnerID)then
            return 30
        elseif(base.serverTime >= self.timeTb[roundIndex][battleIndex])then
            return 20
        elseif(base.serverTime >= self.timeTb[roundIndex][battleIndex] - serverWarTeamCfg.enterBattleTime)then
            return 12
        elseif(base.serverTime >= self.timeTb[roundIndex][battleIndex] - serverWarTeamCfg.setTroopsLimit)then
            return 11
        else
            return 0
        end
    else
        return 0
    end
end

--弹出跨服战当前部队信息面板
--param layerNum: 面板所在的层级
function serverWarTeamVoApi:showCurTroopsDialog(layerNum)
    require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamFightVoApi"
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamCurTroopsDialog"
    local td = serverWarTeamCurTroopsDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverwarteam_title"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end

--弹出跨服战主面板
--param layerNum: 面板所在的层级
function serverWarTeamVoApi:showMainDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialog"
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogTab2"
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamDialogTab3"
    local td = serverWarTeamDialog:new()
    local tbArr = {getlocal("serverwar_schedule"), getlocal("serverwar_troops"), getlocal("serverwar_shop")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverwarteam_title"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end

--进入战场
--param layerNum: 战场要显示的层级
--param data: serverWarTeamBattleVo
function serverWarTeamVoApi:showMap(layerNum, data)
    require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamFightVoApi"
    serverWarTeamFightVoApi:showMap(layerNum, data)
end

--获取跨服战的整体信息
--param callback: 获取之后的回调函数
function serverWarTeamVoApi:getWarInfo(callback)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamOutScene"
    if(base.serverTime >= self.warInfoExpireTime)then
        local function initHandler(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                self.needRefresh = 0
                local warId
                if sData.data and sData.data.matchId then
                    warId = sData.data.matchId
                end
                if(warId == nil or sData.data.st == nil)then
                    do return end
                end
                self:setServerWarId(warId)
                self.startTime = tonumber(sData.data.st)
                self.endTime = tonumber(sData.data.et)
                
                --报名，上阵数据
                if sData.data.applydata then
                    local applydata = sData.data.applydata
                    if applydata.aid then
                        if allianceVoApi:isHasAlliance() == true then
                            local selfAlliance = allianceVoApi:getSelfAlliance()
                            if selfAlliance and selfAlliance.aid then
                                if tonumber(selfAlliance.aid) == tonumber(applydata.aid) then
                                    self:setIsApply(1)
                                end
                            end
                        end
                    end
                    --上阵的军团成员
                    if applydata.teams then
                        self:formatMemList(applydata.teams)
                        self:setMemFlag(0)
                    end
                    --上次设置上阵的时间
                    if applydata.updated_at then
                        self:setLastSetMemTime(tonumber(applydata.updated_at))
                    end
                    --上次捐献基地的时间，次数，守军信息
                    self:setBaseDonateInfo(applydata.donate_at, applydata.basedonatenum, applydata.basetroops)
                end
                
                --本服可以报名的军团列表
                if sData.data.crossainfo then
                    self:setLocalTeamList(sData.data.crossainfo)
                end

                --自己的数据
                if sData.data.mydata then
                    local mydata = sData.data.mydata
                    if mydata then
                        if mydata.updated_at then
                            self:setLastSetFleetTime(mydata.updated_at)
                        end
                        if mydata.troops then
                            for k, v in pairs(mydata.troops) do
                                if v and v[1] and v[2] then
                                    local tType = 10
                                    local index = k
                                    local tid = (tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                                    local num = tonumber(v[2])
                                    tankVoApi:setTanksByType(tType, index, tid, num)
                                end
                            end
                            if base.tskinSwitch == 1 then
                                local tskin = mydata.skin or {}
                                tankSkinVoApi:setTankSkinListByBattleType(10, tskin)
                            end
                        end
                        if mydata.hero then
                            heroVoApi:clearServerWarTeamTroops()
                            heroVoApi:setServerWarTeamHeroList(mydata.hero)
                        end
                        if mydata.aitroops then --AI部队
                            AITroopsFleetVoApi:clearServerWarTeamAITroops()
                            AITroopsFleetVoApi:setServerWarTeamAITroopsList(mydata.aitroops)
                        end
                        -- 同步装备的超级装备
                        emblemVoApi:setBattleEquip(10, mydata.equip)
                        if mydata.plane then
                            if type(mydata.plane) == "string" then
                                local planeVo = planeVoApi:getPlaneVoById(mydata.plane)
                                if planeVo and planeVo.idx then
                                    planeVoApi:setBattleEquip(10, planeVo.idx)
                                else
                                    planeVoApi:setBattleEquip(10, nil)
                                end
                            else
                                planeVoApi:setBattleEquip(10, mydata.plane)
                            end
                        else
                            planeVoApi:setBattleEquip(10, nil)
                        end

                        airShipVoApi:setBattleEquip(10, mydata.ap)
                        
                        if mydata.carrygems then
                            self:setCarrygems(tonumber(mydata.carrygems))
                        end
                        if mydata.gems then
                            self:setGems(tonumber(mydata.gems))
                        end
                    end

                end
                
                self.timeTb = {}
                for i = 1, 3 do
                    self.timeTb[i] = {}
                    local num = 8 / (2 ^ i)
                    for k = 1, num do
                        local index = serverWarTeamCfg.startBattleIndex[i][k]
                        local timeTab = serverWarTeamCfg.startBattleTs[index]
                        local time = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime + i - 1) * 86400 + timeTab[1] * 3600 + timeTab[2] * 60
                        table.insert(self.timeTb[i], time)
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
                
                self.teamList = {}
                if(sData.data.across and sData.data.across.ainfo)then
                    for k, v in pairs(sData.data.across.ainfo) do
                        local allianceVo = serverWarTeamAllianceVo:new()
                        allianceVo:init(v)
                        table.insert(self.teamList, allianceVo)
                    end
                end
                
                self.outBatteList = {}
                if(sData.data.across and sData.data.across.schedule)then
                    self:initBattleList(sData.data.across.schedule)
                end
                local nextRoundID
                for i = 1, #self.timeTb do
                    local roundStatus = self:getRoundStatus(i)
                    if(roundStatus < 30)then
                        nextRoundID = i
                        break
                    end
                end
                if(nextRoundID)then
                    if(nextRoundID == 1 and self:getRoundStatus(nextRoundID) == 0)then
                        if(base.serverTime < G_getWeeTs(self.startTime) + serverWarTeamCfg.preparetime * 86400)then
                            self.warInfoExpireTime = G_getWeeTs(self.startTime) + serverWarTeamCfg.preparetime * 86400
                        else
                            self.warInfoExpireTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60
                        end
                    else
                        for k, startTime in pairs(self.timeTb[nextRoundID]) do
                            if(base.serverTime < startTime + serverWarTeamCfg.warTime)then
                                self.warInfoExpireTime = startTime + serverWarTeamCfg.warTime
                                break
                            end
                        end
                    end
                else
                    self.warInfoExpireTime = self.endTime
                end
                if sData.data.host then
                    self.socketHost = sData.data.host
                end
                if(self:checkShowServerWar())then
                    if(buildings.allBuildings)then
                        for k, v in pairs(buildings.allBuildings) do
                            if(v:getType() == 16)then
                                v:setSpecialIconVisible(2, true)
                                break
                            end
                        end
                    end
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:acrossInit(self.needRefresh, initHandler)
    elseif(callback)then
        callback()
    end
end

--一场战斗结束后，请求后台，刷新数据
function serverWarTeamVoApi:updateAfterBattle(callback)
    local function getWarInfoHandler()
        --重新请求积分明细，标示
        self:setPointDetailFlag(-1)
        --重新请求积分和献花信息
        self:setShopFlag(-1)
        self:getShopAndBetInfo()
        
        if callback then
            callback()
        end
    end
    --请求warInfo数据
    self.warInfoExpireTime = 0
    self.needRefresh = 1
    self:getWarInfo(getWarInfoHandler)
end

--根据后台数据初始化对阵信息
--param data: 后台传来的原始数据
--param type: 1为服外赛, 0为服内赛, 不传默认是1
function serverWarTeamVoApi:initBattleList(data, type)
    require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamBattleVo"
    if(type == nil)then
        type = 1
    end
    local tmpBattleList = {}
    local function sortFunc(a, b)
        return self.keyMap[a[5]] < self.keyMap[b[5]]
    end
    for roundID, roundTb in pairs(data) do
        tmpBattleList[roundID] = {}
        for battleID, battleData in pairs(roundTb) do
            battleData[4] = roundID
            battleData[5] = battleID
            table.insert(tmpBattleList[roundID], battleData)
        end
        table.sort(tmpBattleList[roundID], sortFunc)
    end
    if(#tmpBattleList >= 2)then
        tmpBattleList = self:checkFormatRoundPlayer(tmpBattleList)
    end
    for roundIndex, roundTb in pairs(tmpBattleList) do
        self.outBatteList[roundIndex] = {}
        for battleIndex, battleData in pairs(roundTb) do
            local battleVo = serverWarTeamBattleVo:new()
            battleVo:init(battleData)
            self.outBatteList[roundIndex][battleIndex] = battleVo
        end
    end
end

--因为后台返回的下一轮选手的分组不一定能保持与上一轮一致的顺序, 而且格式与前台所需的也有所差别, 所以格式化一下
function serverWarTeamVoApi:checkFormatRoundPlayer(battleList)
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

--本服可以报名的军团列表
function serverWarTeamVoApi:getLocalTeamList()
    return self.localTeamList
end
function serverWarTeamVoApi:setLocalTeamList(localTeamList)
    self.localTeamList = localTeamList
end

function serverWarTeamVoApi:canJoinServerWarTeam(time, isLvLimit)
    local canJoin = false
    if self.startTime then
        local joinEndTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 - serverWarTeamCfg.jointime * 3600
        if time and time > 0 then
            if time < joinEndTime then
                canJoin = true
            end
        else
            local joinTime = allianceVoApi:getJoinTime()
            if joinTime and joinTime > 0 and joinTime < joinEndTime then
                if (isLvLimit == nil or isLvLimit == true) then
                    if self:canJoinBattleLvLimit() == true then
                        canJoin = true
                    end
                else
                    canJoin = true
                end
            end
        end
    end
    return canJoin
end

function serverWarTeamVoApi:canJoinBattleLvLimit()
    local canJoin = false
    if playerVoApi:getPlayerLevel() >= serverWarTeamCfg.joinlv then
        canJoin = true
    end
    return canJoin
end

--报名接口
function serverWarTeamVoApi:serverWarTeamApply(callback)
    local function applyCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            self:setIsApply(1)
            
            -- if sData.data and sData.data.teams then
            --     self:formatMemList(sData.data.teams)
            -- end
            -- local memList=self:getMemList()
            -- if memList then
            --     self.battleMemList={}
            --     for k,v in pairs(memList) do
            --         table.insert(self.battleMemList,tonumber(v))
            --     end
            -- end
            
            if callback then
                callback()
            end
            
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverwarteam_signup_success"), 30)
            
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance then
                local aid = selfAlliance.aid
                local isApply = self:getIsApply()
                -- local params={isApply,memList}
                local params = {isApply}
                chatVoApi:sendUpdateMessage(13, params, aid + 1)
            end
        end
    end
    socketHelper:acrossApply(2, applyCallback)
end

function serverWarTeamVoApi:showApplyDialog(layerNum, callback)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamApplySmallDialog"
    local applyDialog = serverWarTeamApplySmallDialog:new()
    applyDialog:init(layerNum, callback)
end

-----------------以下基地捐献，激活守军------------
--查看基地守军部队的信息
function serverWarTeamVoApi:showBaseDefendersInfoDialog(layerNum, title, index)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamBaseDefendersInfoDialog"
    local basetroops = serverWarTeamVoApi:getBasetroops()
    local fleetInfo = basetroops[index]
    if fleetInfo and SizeOfTable(fleetInfo) > 0 then
        local td = serverWarTeamBaseDefendersInfoDialog:new(fleetInfo)
        local tbArr = {}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, title, true, layerNum + 1)
        sceneGame:addChild(dialog, layerNum + 1)
    end
end
--捐献变化标示
function serverWarTeamVoApi:getDonateFlag()
    return self.donateFlag
end
function serverWarTeamVoApi:setDonateFlag(donateFlag)
    self.donateFlag = donateFlag
end
--基地捐献的次数配置
function serverWarTeamVoApi:getBaseDonateTimeCfg()
    return serverWarTeamCfg.baseDonateTime
end
--用资源捐献基地配置
function serverWarTeamVoApi:getBaseDonateResCfg()
    local donateRes = serverWarTeamCfg.baseDonateRes.q
    local resTb = FormatItem(donateRes, nil, true)
    local item = resTb[1]
    return item
end
--上次捐献基地的时间
function serverWarTeamVoApi:getLastDonateTime()
    return self.lastDonateTime
end
--本场战斗基地守军的部队信息
function serverWarTeamVoApi:getBasetroops()
    -- local lastTime=self:getLastDonateTime()
    -- if G_isToday(lastTime)==true then
    if self.basetroops then
        return self.basetroops
    else
        return {}
    end
    -- else
    -- return {}
    -- end
end
--基地捐献的次数
function serverWarTeamVoApi:getBaseDonateNum()
    -- local lastTime=self:getLastDonateTime()
    -- if G_isToday(lastTime)==true then
    if self.baseDonateNum then
        return self.baseDonateNum
    else
        return 0
    end
    -- else
    -- return 0
    -- end
end
--设置捐献的信息，lastDonateTime 上次捐献时间，上次不是今天，则清除数据，baseDonateNum，次数，basetroops，守军信息
function serverWarTeamVoApi:setBaseDonateInfo(lastDonateTime, baseDonateNum, basetroops)
    -- local lastTime=self:getLastDonateTime()
    -- if G_isToday(lastTime)==false then
    -- self.basetroops={}
    -- self.baseDonateNum=0
    -- end
    if lastDonateTime then
        self.lastDonateTime = tonumber(lastDonateTime) or 0
    end
    if baseDonateNum then
        self.baseDonateNum = tonumber(baseDonateNum) or 0
    end
    if basetroops then
        self.basetroops = basetroops or {}
    end
end

--不能捐献守军提示 -1 当前轮次没有战斗，0 可以，1 轮空提示，2 没军团，3 当前轮次战斗结果失败
function serverWarTeamVoApi:donateTipStatus(roundIndex)
    -- print("roundIndex",roundIndex)
    if roundIndex and roundIndex > 0 then
        local battleID = serverWarTeamVoApi:getBattleID(roundIndex)
        -- print("battleID",battleID)
        if battleID then
            local battleVo = serverWarTeamVoApi:getBattleVoByID(roundIndex, battleID)
            -- print("battleVo",battleVo)
            if(battleVo == nil)then
                do return - 1 end
            else
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance == nil then
                    do return 2 end
                end
                if battleVo.winnerID then
                    local selfID = base.curZoneID.."-"..selfAlliance.aid
                    if battleVo.winnerID == selfID then
                        if roundIndex < 3 then
                            return 0
                        else
                            return - 1
                        end
                        do return self:donateTipStatus(roundIndex + 1) end
                    else
                        do return 3 end
                    end
                elseif(battleVo.alliance1 == nil or battleVo.alliance2 == nil) then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverwarteam_win_direct"), 30)
                    do return 1 end
                end
            end
            do return 0 end
        end
    end
    return - 1
end

--有军饷未提取，提取军饷
function serverWarTeamVoApi:extractFunds(layerNum)
    local usegems = playerVoApi:getServerWarTeamUsegems()
    if usegems and usegems > 0 then
        local function extractHandler()
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local function extractCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local leftFunds = sData.data.salaries or 0
                    self:setGems(0)
                    playerVoApi:setGems(playerVoApi:getGems() + leftFunds)
                    playerVoApi:setServerWarTeamUsegems(0)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverwarteam_extract_success", {leftFunds}), 30)
                end
            end
            socketHelper:acrossTakegems(extractCallback)
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("serverwarteam_extract_left_funds"), nil, layerNum + 1, nil, extractHandler)
    end
end

-----------------以上基地捐献，激活守军------------

-----------------以下设置部队，军饷---------------

--本场战斗总共注入的金币
function serverWarTeamVoApi:getCarrygems()
    return self.carrygems
end
function serverWarTeamVoApi:setCarrygems(carrygems)
    self.carrygems = carrygems
end

--本场战斗可以使用的金币
function serverWarTeamVoApi:getGems()
    return self.gems
end
function serverWarTeamVoApi:setGems(gems)
    self.gems = gems
end

--战斗结束了还有资金未提取
function serverWarTeamVoApi:getLeftGems()
    local leftGems = self:getGems()
    local roundIndex = self:getCurrentRoundIndex()
    local battleStatus = self:checkBattleStatus(roundIndex)
    if battleStatus >= 40 and leftGems > 0 then
        return true
    end
    return false
end

--上次设置部队时间
function serverWarTeamVoApi:getLastSetFleetTime()
    return self.lastSetFleetTime
end
function serverWarTeamVoApi:setLastSetFleetTime(time)
    self.lastSetFleetTime = time
end

-- 0 可以设置
-- serverwar_cannot_set_fleet1="比赛尚未开启，无法进行部队和军饷设置！",
-- serverwar_cannot_set_fleet2="战斗即将开始，无法设置部队和军饷",
-- serverwar_cannot_set_fleet3="战斗进行中，无法设置部队和军饷!",
-- serverwar_cannot_set_fleet4="战斗已结束，无法设置部队和军饷！",
-- serverwar_cannot_set_fleet5="您未参加跨服战，无法进行部队和军饷设置！",
-- 6 参加跨服战战败，可以进入提取资金，不能设置部队和资金
-- serverwar_cannot_set_fleet7="您加入军团时间过晚，无法设置部队！",
-- serverwar_cannot_set_fleet8="您等级过低，无法进行部队设置！",
function serverWarTeamVoApi:getSetFleetStatus()
    local status = self:checkStatus()
    if status < 11 then
        return 1
    elseif self:checkIsPlayer() == false then
        return 5
    else
        if self:canJoinServerWarTeam(nil, false) == false then
            return 7
        elseif self:canJoinBattleLvLimit() == false then
            return 8
        elseif status == 11 then
            return 0
        elseif status == 20 then
            local roundIndex = self:getCurrentRoundIndex()
            if roundIndex == 1 and base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60 then
                return 0
            else
                local battleStatus = self:checkBattleStatus(roundIndex)
                local battleID = self:getBattleID(roundIndex)
                -- print("battleStatus",battleStatus)
                if battleStatus and battleStatus > 0 and battleID then
                    if battleStatus <= 20 then
                        return 0
                    elseif battleStatus == 21 or battleStatus == 22 then
                        return 2
                    elseif battleStatus == 30 then
                        return 3
                    elseif battleStatus >= 40 then
                        local isWin = self:getBattleIsWin(roundIndex, battleID)
                        if isWin == true and roundIndex < 3 then
                            return 0
                        else
                            return 6
                        end
                    end
                else
                    return 6
                end
            end
        elseif status > 20 then
            return 6
        end
        return 1
    end
end

--可以设置部队和资金
function serverWarTeamVoApi:canSetFleet()
    local status = self:getSetFleetStatus()
    if status and status == 0 then
        return true
    end
    return false
end
--可以设置部队，没有设置部队
function serverWarTeamVoApi:getIsAllSetFleet()
    local canSet = self:getSetFleetStatus()
    if canSet == 0 then
        local isAllSet = tankVoApi:serverWarTeamIsSetFleet()
        if isAllSet == false then
            return false
        end
    end
    return true
end
--没有设置部队（不管可不可以设置部队）
function serverWarTeamVoApi:getIsSetFleet()
    local isAllSet = tankVoApi:serverWarTeamIsSetFleet()
    if isAllSet == false then
        return false
    end
    return true
end

-----------------以上设置部队，军饷---------------

-----------------以下献花相关--------------------
--弹出个人信息面板
function serverWarTeamVoApi:showAllianceDetailDialog(data, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarAllianceDetailDialog"
    local detailDialog = serverWarAllianceDetailDialog:new(data)
    detailDialog:init(layerNum + 1)
end

--弹出献花面板
function serverWarTeamVoApi:showFlowerDialog(data, roundIndex, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamFlowerDialog"
    local flowerDialog = serverWarTeamFlowerDialog:new(data)
    flowerDialog:init(layerNum + 1)
end

--给某场比赛送花
--param groupID: 1是服内组, 2是淘汰组，现在只有2
--param roundID: 轮次ID, 0是分组赛
--param battleID: 场次ID
--param allianceID: 给哪个军团送花
function serverWarTeamVoApi:bet(groupID, roundID, battleID, allianceID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if(ret == true)then
            if(self.betList[roundID])then
                self.betList[roundID].times = self.betList[roundID].times + 1
                self.betList[roundID].battleID = battleID
                self.betList[roundID].allianceID = allianceID
            else
                local betVo = serverWarTeamBetVo:new()
                betVo:init({roundID, battleID, allianceID, 1, 0})
                self.betList[roundID] = betVo
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
    local detailId = self:getConnectId(matchId, groupID, roundID, battleID)
    local aid = allianceID
    socketHelper:acrossBet(matchId, detailId, aid, onRequestEnd)
end

--获取送花记录
function serverWarTeamVoApi:getBetList()
    if(self.betList)then
        return self.betList
    else
        return {}
    end
end

--获取某一轮的献花数据
--param roundIndex: 要获取第几轮的数据
--return 一个BetVo或者nil
function serverWarTeamVoApi:getBetData(roundIndex)
    if self.betList and roundIndex then
        return self.betList[roundIndex]
    end
    return nil
end

--根据第几轮和献花次数，获得献花数量,isPoint:是否是取获得的积分
function serverWarTeamVoApi:getSendFlowerNum(roundID, num, isPoint, isWin)
    if roundID and num then
        local cfgIndex = serverWarTeamCfg.betStyle4Round[roundID]
        if cfgIndex then
            local winnerCfg = serverWarTeamCfg["winner_"..cfgIndex]
            local failerCfg = serverWarTeamCfg["failer_"..cfgIndex]
            if isPoint == true then
                local cfg
                -- if isWin~=nil then
                if isWin == true then
                    cfg = winnerCfg
                else
                    cfg = failerCfg
                end
                if cfg and cfg[num] then
                    return cfg[num]
                end
                -- end
            else
                if winnerCfg and winnerCfg[num] then
                    return winnerCfg[num]
                end
            end
        end
    end
    return 0
end

function serverWarTeamVoApi:betReward(roundIndex, point)
    local betList = self:getBetList()
    if betList and roundIndex and betList[roundIndex] then
        betList[roundIndex].hasGet = 1
    end
    self:setPoint(self:getPoint() + point)
    self:addPointDetail({}, 1)
end

function serverWarTeamVoApi:getIsCanRewardBet()
    local isShow = false
    local betList = self:getBetList()
    if betList and SizeOfTable(betList) > 0 then
        for k, v in pairs(betList) do
            if v and v.roundID and v.battleID then
                local outBattleStatus = self:getOutBattleStatus(v.roundID, v.battleID)
                if outBattleStatus and outBattleStatus >= 30 then --结束
                    if v.hasGet and v.hasGet == 1 then
                    else
                        isShow = true
                    end
                end
            end
        end
    end
    return isShow
end

-----------------以上献花相关--------------------

------------以下积分商店----------------
--积分商店开启后，是否打开过,true：不显示，false：显示
function serverWarTeamVoApi:getShopHasOpen()
    -- local status=self:checkStatus()
    -- if status and status>=30 then
    -- local dataKey="serverWarTeamShopHasOpen@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(self:getServerWarId())
    -- local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    -- if (localData~=nil and localData~="") then
    --         return true
    --     else
    --         return false
    --     end
    -- end
    return true
end
function serverWarTeamVoApi:setShopHasOpen()
    -- local status=self:checkStatus()
    -- if status and status>=30 then
    -- local dataKey="serverWarTeamShopHasOpen@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..tostring(self:getServerWarId())
    -- local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    -- CCUserDefault:sharedUserDefault():setStringForKey(dataKey,"open")
    -- end
end
--普通道具配置
function serverWarTeamVoApi:getShopCommonItems()
    if self.f_pShopItems and next(self.f_pShopItems) then
        do return self.f_pShopItems end
    end
    self.f_pShopItems = {}
    for k, v in pairs(serverWarTeamCfg.pShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_pShopItems[k] = v
        end
    end
    return self.f_pShopItems
end
--珍品配置
function serverWarTeamVoApi:getShopRareItems()
    if self.f_aShopItems and next(self.f_aShopItems) then
        do return self.f_aShopItems end
    end
    self.f_aShopItems = {}
    for k, v in pairs(serverWarTeamCfg.aShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_aShopItems[k] = v
        end
    end
    return self.f_aShopItems
end
function serverWarTeamVoApi:getShopFlag()
    return self.shopFlag
end
function serverWarTeamVoApi:setShopFlag(shopFlag)
    self.shopFlag = shopFlag
end
function serverWarTeamVoApi:getBuyStatus()
    if self:checkStatus() > 10 then
        if self:getIsApply() == 1 then
            if self:canJoinServerWarTeam() == true then
                return 1
            end
        end
    end
    return 0
end
-- function serverWarTeamVoApi:setBuyStatus(buyStatus)
-- self.buyStatus=buyStatus
-- end
--根据id获取道具的配置
function serverWarTeamVoApi:getItemById(id)
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
function serverWarTeamVoApi:initShopInfo()
    local commonItems = self:getShopCommonItems()
    local rareItems = self:getShopRareItems()
    self.commonList = {}
    self.rareList = {}
    for k, v in pairs(commonItems) do
        local vo = serverWarTeamShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.commonList, vo)
    end
    for k, v in pairs(rareItems) do
        local vo = serverWarTeamShopVo:new()
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
--获取跨服战的商店信息和鲜花信息
--param callback: 获取之后的回调函数
function serverWarTeamVoApi:getShopAndBetInfo(callback)
    local shopFlag = self:getShopFlag()
    if shopFlag == -1 then
        self:initShopInfo()
        self:setShopFlag(1)
        local function acrossBetpointinfoCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                self:setShopFlag(1)
                
                local warId = self:getServerWarId()
                if warId and sData.data then
                    --积分商店信息
                    if sData.data.point and sData.data.point[warId] then
                        local shopData = sData.data.point[warId]
                        if shopData.lm then
                            if self.commonList == nil or self.rareList == nil then
                                self:initShopInfo()
                            end
                            for k, v in pairs(shopData.lm) do
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
                        if shopData.nm then
                            self:setPoint(tonumber(shopData.nm) or 0)
                        end
                        --是否领取过排行榜奖励
                        if shopData.rank then
                            self:setIsRewardRank(true)
                        end
                    end
                    --鲜花信息
                    if sData.data.bet and sData.data.bet[warId] then
                        self.betList = {}
                        for k, v in pairs(sData.data.bet[warId]) do
                            if(type(v) == "table")then
                                local infoTb = Split(k, "_")
                                local length = #infoTb
                                local battleID = infoTb[length]
                                local roundID = tonumber(infoTb[length - 1])
                                local type = tonumber(infoTb[length - 2])
                                local betVo = serverWarTeamBetVo:new()
                                betVo:init({roundID, battleID, v.aid, v.count, v.isGet})
                                self.betList[roundID] = betVo
                            end
                        end
                    end
                end
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:acrossBetpointinfo(acrossBetpointinfoCallback)
    elseif(callback)then
        callback()
    end

end

function serverWarTeamVoApi:getPointDetailFlag()
    return self.pointDetailFlag
end
function serverWarTeamVoApi:setPointDetailFlag(pointDetailFlag)
    self.pointDetailFlag = pointDetailFlag
end

function serverWarTeamVoApi:getDetailExpireTime()
    return self.detailExpireTime
end
function serverWarTeamVoApi:setDetailExpireTime(detailExpireTime)
    self.detailExpireTime = detailExpireTime
end

function serverWarTeamVoApi:clearPointDetail()
    if self.pointDetail ~= nil then
        for k, v in pairs(self.pointDetail) do
            self.pointDetail[k] = nil
        end
        self.pointDetail = nil
    end
    self.pointDetail = {}
    self.pointDetailFlag = -1
    self.detailExpireTime = 0
end
--初始化积分明细
function serverWarTeamVoApi:formatPointDetail(callback)
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
                            local vo = serverWarTeamPointDetailVo:new()
                            vo:initWithData(type, time, message, color)
                            table.insert(self.pointDetail, vo)
                        end
                    end
                end
                if record.buy and SizeOfTable(record.buy) > 0 then
                    for k, v in pairs(record.buy) do
                        local type, time, message, color = self:formatMessage(v, 2)
                        if type and time and message then
                            local vo = serverWarTeamPointDetailVo:new()
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
                
                -- local nextRoundID
                -- for i=0,#self.timeTb-1 do
                -- local roundStatus=self:getRoundStatus(i)
                -- if(roundStatus<20)then
                -- nextRoundID=i
                -- break
                -- end
                -- end
                -- if(nextRoundID)then
                -- self.detailExpireTime=self.timeTb[nextroundID]+serverWarTeamCfg.warTime
                -- else
                -- self.detailExpireTime=self.endTime
                -- end
                
                self:setPointDetailFlag(1)
            end
            if(callback)then
                callback()
            end
        end
    end
    if self:getPointDetailFlag() == -1 then
        local function getWarInfoHandler()
            socketHelper:acrossRecord(getRecordHandler)
        end
        self:getWarInfo(getWarInfoHandler)
    else
        if(callback)then
            callback()
        end
    end
end
function serverWarTeamVoApi:formatMessage(data, mType)
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
            local warId, groupID, roundIndex, battleID = self:getFormatId(id)
            local battleVo = nil
            local battleVo = self:getBattleVoByID(roundIndex, battleID)
            roundNum = roundIndex
            if fType == 0 then
                local betVo = self:getBetData(roundIndex)
                if betVo then
                    local targetId = betVo.allianceID
                    if targetId then
                        local allianceVo = self:getTeam(targetId)
                        if allianceVo then
                            targetName = allianceVo.name or ""
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
                    mData = data[5]
                    targetName = mData[1] or ""
                    local isWin = mData[2] or 0
                    if isWin == 1 then
                        type = 5
                    else
                        type = 6
                    end
                    -- local targetId
                    -- local selfAlliance=allianceVoApi:getSelfAlliance()
                    -- local selfId=base.curZoneID.."-"..selfAlliance.aid
                    -- if battleVo.id1 and battleVo.id1==selfId then
                    -- targetId=battleVo.id2
                    -- elseif battleVo.id2 and battleVo.id2==selfId then
                    -- targetId=battleVo.id1
                    -- end
                    -- if targetId then
                    -- local allianceVo=self:getTeam(targetId)
                    -- if allianceVo then
                    -- targetName=allianceVo.name or ""
                    -- end
                    -- end
                    -- -- if roundIndex==0 then
                    -- -- if battleVo.winnerID and battleVo.winnerID==selfId then
                    -- -- type=3
                    -- -- else
                    -- -- type=4
                    -- -- end
                    -- -- else
                    -- if battleVo.winnerID and battleVo.winnerID==selfId then
                    -- type=5
                    -- else
                    -- type=6
                    -- end
                    -- -- end
                end
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
        message = getlocal("serverwarteam_point_desc_"..type, params)
    end
    
    return type, time, message, color
end
function serverWarTeamVoApi:addPointDetail(data, mType)
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
        local vo = serverWarTeamPointDetailVo:new()
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
        while SizeOfTable(self.pointDetail) > serverWarTeamCfg.militaryrank do
            table.remove(self.pointDetail, serverWarTeamCfg.militaryrank + 1)
        end
    end
end

function serverWarTeamVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
    return date
end

--购买物品 type:1：道具，2：珍品 id：物品id
function serverWarTeamVoApi:buyItem(type, id, callback)
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
        socketHelper:acrossBuy(matchId, sType, id, buyHandler)
    end
end

--获取商店里面的道具列表
function serverWarTeamVoApi:getCommonList()
    if (self.commonList) then
        return self.commonList
    end
    return {}
end
--获取商店里面的珍品列表
function serverWarTeamVoApi:getRareList()
    if (self.rareList) then
        return self.rareList
    end
    return {}
end
--获取积分明细
function serverWarTeamVoApi:getPointDetail()
    if (self.pointDetail) then
        return self.pointDetail
    end
    return {}
end
--积分
function serverWarTeamVoApi:getPoint()
    return self.point
end
function serverWarTeamVoApi:setPoint(point)
    self.point = point
end
--我的排名
function serverWarTeamVoApi:getMyRank()
    return self.myRank
end
function serverWarTeamVoApi:setMyRank(myRank)
    self.myRank = myRank
end
--自己根据排名，可以领取的积分
function serverWarTeamVoApi:getRewardPoint()
    local point = 0
    if allianceVoApi:isHasAlliance() == true then
        selfAlliance = allianceVoApi:getSelfAlliance()
        if selfAlliance and selfAlliance.joinTime and self.startTime then
            if self:canJoinServerWarTeam() == true then
                local myRank = self:getMyRank()
                if myRank and myRank > 0 then
                    for k, v in pairs(serverWarTeamCfg.rankReward) do
                        local minRank = v.range[1]
                        local maxRank = v.range[2]
                        if myRank >= minRank and myRank <= maxRank then
                            point = v.point
                        end
                    end
                end
            end
        end
    end
    return point
end
--是否已经领取过排行奖励
function serverWarTeamVoApi:getIsRewardRank()
    return self.isRewardRank
end
function serverWarTeamVoApi:setIsRewardRank(isRewardRank)
    self.isRewardRank = isRewardRank
end
--领取排行榜奖励
function serverWarTeamVoApi:rewardRank(callback)
    local function rewardCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            local time = sData.ts
            self:setIsRewardRank(true)
            local point = self:getPoint()
            local rewardPoint = self:getRewardPoint()
            self:setPoint(point + rewardPoint)
            
            local myRank = self:getMyRank()
            local data = {rewardPoint, 2, "", time, myRank}
            self:addPointDetail(data, 3)
            
            if callback then
                callback()
            end
        end
    end
    socketHelper:acrossGetrankingreward(rewardCallback)
end
------------以上积分商店----------------

------------以下排行榜----------------
--排行榜开启后，是否打开过,打开过true：不显示，未开过false：显示
function serverWarTeamVoApi:getRankHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarTeamRankHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if (localData ~= nil and localData ~= "") then
            return true
        else
            return false
        end
    end
end
function serverWarTeamVoApi:setRankHasOpen()
    local status = self:checkStatus()
    if status and status >= 30 then
        local dataKey = "serverWarTeamRankHasOpen@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        CCUserDefault:sharedUserDefault():setStringForKey(dataKey, "open")
    end
end

function serverWarTeamVoApi:getRankFlag()
    return self.rankFlag
end
function serverWarTeamVoApi:setRankFlag(rankFlag)
    self.rankFlag = rankFlag
end
--战斗结束后排行榜
function serverWarTeamVoApi:clearRankList()
    self.rankList = nil
end
function serverWarTeamVoApi:formatRankList(callback, isUpdate)
    local function acrossRankingHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.ranking then
                local rankData = sData.data.ranking
                self.rankList = {}
                -- local selfId=playerVoApi:getUid().."-"..base.curZoneID
                local selfId
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance and selfAlliance.aid then
                    selfId = base.curZoneID.."-"..selfAlliance.aid
                end
                for k, v in pairs(rankData) do
                    local id = k
                    local rank = v[1]
                    local value = 0--tonumber(v[2]) or 0
                    local allianceVo = self:getTeam(id)
                    local name = ""
                    local server = ""
                    if allianceVo then
                        name = allianceVo.name or ""
                        server = allianceVo.serverName or ""
                        value = allianceVo.fight or 0
                    end
                    
                    if selfId and selfId == id and rank and rank > 0 then
                        self:setMyRank(rank)
                    end
                    
                    -- local playerVo=self:getPlayer(id)
                    -- if playerVo then
                    -- name=playerVo.name or ""
                    -- server=playerVo.serverName or ""
                    -- value=playerVo.power or 0
                    -- end
                    
                    if rank and rank > 0 then
                        local vo = serverWarTeamRankVo:new()
                        vo:initWithData(id, name, server, rank, value)
                        table.insert(self.rankList, vo)
                    end
                end
                local function sortAsc(a, b)
                    if a and b and a.rank and b.rank and tonumber(a.rank) and tonumber(b.rank) then
                        if tonumber(a.rank) == tonumber(b.rank) then
                            if a.value and b.value then
                                return a.value > b.value
                            end
                        else
                            return tonumber(a.rank) < tonumber(b.rank)
                        end
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
    if isUpdate == true then
        socketHelper:acrossRanking(acrossRankingHandler)
    else
        local status = self:checkStatus()
        if status >= 30 and flag == -1 then
            socketHelper:acrossRanking(acrossRankingHandler)
        else
            if callback then
                callback()
            end
        end
    end
end
function serverWarTeamVoApi:getRankList()
    if self.rankList then
        return self.rankList
    end
    return {}
end
function serverWarTeamVoApi:getRankRewardCfg()
    return serverWarTeamCfg.rankReward
end
function serverWarTeamVoApi:getSeverRewardCfg()
    return serverWarTeamCfg.severReward
end
function serverWarTeamVoApi:isHasServerReward(index)
    local severRewardCfg = serverWarTeamVoApi:getSeverRewardCfg()
    if index and severRewardCfg and severRewardCfg[index] then
        return true
    else
        return false
    end
end
------------以上排行榜----------------

--格式化后台的id获取数据 b16_2_1_a
--id，matchId_服内赛or淘汰赛_第几轮_a or b or c..... "detailId":"b16_2_1_a"
function serverWarTeamVoApi:getFormatId(id)
    if id then
        local arr = Split(id, "_")
        if arr and SizeOfTable(arr) >= 4 then
            local warId = arr[1]--跨服战id
            local groupID = tonumber(arr[2])--服内赛 1，淘汰赛 2
            local roundIndex = tonumber(arr[3]) --第几轮
            local battleID = arr[4]--第几场战斗
            return warId, groupID, roundIndex, battleID
        end
    end
    return nil
end
--组合id
function serverWarTeamVoApi:getConnectId(warId, groupID, roundID, battleID)
    local detailId = tostring(warId) .. "_"..tostring(groupID) .. "_"..tostring(roundID) .. "_"..tostring(battleID)
    return detailId
end

--检查是否要显示跨服战
function serverWarTeamVoApi:checkShowServerWar()
    local status = self:checkStatus()
    if(status >= 10 and status < 40)then
        return true
    else
        return false
    end
end

--检查当前登录玩家是否报名，参加军团跨服战
function serverWarTeamVoApi:checkIsPlayer()
    local isApply = self:getIsApply()
    if isApply == 1 and allianceVoApi:isHasAlliance() == true then
        return true
    end
    return false
end

------------以下设置上下阵----------------
function serverWarTeamVoApi:showSetBattleMemDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamSetBattleMemDialog"
    local td = serverWarTeamSetBattleMemDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverwarteam_set_battle_menber"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end
function serverWarTeamVoApi:getAllianceMemNum()
    if allianceVoApi:isHasAlliance() then
        local memberTab = allianceMemberVoApi:getMemberTab()
        return SizeOfTable(memberTab)
    end
    return 0
end
function serverWarTeamVoApi:getAllianceMemList(memberList)
    if allianceVoApi:isHasAlliance() then
        local memberTab = allianceMemberVoApi:getMemberTab()
        local memList = {}
        if memberList then
            memList = memberList
        else
            memList = self:getMemList()
        end
        if memList then
            for k, v in pairs(memberTab) do
                memberTab[k].isBattle = 0
                for m, n in pairs(memList) do
                    if tonumber(memberTab[k].uid) == tonumber(n) then
                        if self:canJoinServerWarTeam(tonumber(memberTab[k].joinTime)) == true then
                            memberTab[k].isBattle = 1
                        end
                    end
                end
            end
        end
        local function sortAsc(a, b)
            if a and b then
                if a.isBattle and b.isBattle then
                    if a.isBattle == b.isBattle then
                        if tonumber(a.fight) and tonumber(b.fight) then
                            return tonumber(a.fight) > tonumber(b.fight)
                        end
                    else
                        return a.isBattle > b.isBattle
                    end
                end
            end
        end
        table.sort(memberTab, sortAsc)
        return memberTab
    end
    return {}
end

--上一次设置上阵成员时间
function serverWarTeamVoApi:getIsMemChange()
    return self.isMemChange
end
function serverWarTeamVoApi:setIsMemChange(isMemChange)
    self.isMemChange = isMemChange
end
--上一次设置上阵成员时间
function serverWarTeamVoApi:getLastSetMemTime()
    return self.lastSetMemTime
end
function serverWarTeamVoApi:setLastSetMemTime(time)
    self.lastSetMemTime = time
end
function serverWarTeamVoApi:getIsApply()
    return self.isApply
end
function serverWarTeamVoApi:setIsApply(isApply)
    self.isApply = isApply
end
function serverWarTeamVoApi:getMemFlag()
    return self.memFlag
end
function serverWarTeamVoApi:setMemFlag(memFlag)
    self.memFlag = memFlag
end
function serverWarTeamVoApi:clearMemList()
    if self.memList then
        for k, v in pairs(self.memList) do
            v = nil
        end
        self.memList = nil
    end
    self.memList = {}
end
function serverWarTeamVoApi:formatMemList(data)
    if allianceVoApi:isHasAlliance() then
        if data then
            self.memList = data
        end
    end
end
function serverWarTeamVoApi:getMemList()
    local memList = {}
    if self.memList and SizeOfTable(self.memList) > 0 then
        local memberTab = allianceMemberVoApi:getMemberTab()
        for k, v in pairs(memberTab) do
            for m, n in pairs(self.memList) do
                if tonumber(memberTab[k].uid) == tonumber(n) then
                    if self:canJoinServerWarTeam(tonumber(memberTab[k].joinTime)) == true then
                        table.insert(memList, tonumber(n))
                    end
                end
            end
        end
    end
    return memList
end
function serverWarTeamVoApi:getNumberOfBattle()
    return serverWarTeamCfg.numberOfBattle or 0
end
function serverWarTeamVoApi:isBattleMem()
    if self.memList and SizeOfTable(self.memList) > 0 then
        for k, v in pairs(self.memList) do
            if v and tonumber(v) and tonumber(v) == playerVoApi:getUid() then
                return true
            end
        end
    end
    return false
end

--是否有报名资格
function serverWarTeamVoApi:checkCanApply()
    if allianceVoApi:isHasAlliance() == true then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        -- if selfAlliance and selfAlliance.role and tostring(selfAlliance.role)=="2" then
        if selfAlliance and selfAlliance.aid then
            local localTeamList = self:getLocalTeamList()
            if localTeamList then
                for k, v in pairs(localTeamList) do
                    if tonumber(v[1]) == tonumber(selfAlliance.aid) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

--报名的状态：返回，-2 未到报名时间 ，-1 军团没有资格报名(军团不是前几名)，0 团员不能报名，1 可以报名，2 已经报名，3 报名已截止，4 没有军团
function serverWarTeamVoApi:canApplyStatus()
    if allianceVoApi:isHasAlliance() == true and self:getIsApply() == 1 then
        do return 2 end
    end
    if self:checkStatus() < 11 then
        return - 2
    elseif self:checkStatus() == 11 then
        if allianceVoApi:isHasAlliance() == true then
            if self:checkCanApply() == true then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance.role and tostring(selfAlliance.role) == "2" then
                    if self:getIsApply() == 1 then
                        return 2
                    else
                        return 1
                    end
                else
                    return 0
                end
            else
                return - 1
            end
        else
            return 4
        end
    else
        return 3
    end
end

--返回，-1 不能点击进入，0 可以查看，1 可以报名，2 可以上阵，3 战斗期间，不能上阵，10 可以报名但是没有报，过期了
function serverWarTeamVoApi:canSetOrApply()
    if self:checkStatus() >= 11 and self:checkStatus() <= 20 then
        local signupEndTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60
        if self:checkStatus() == 11 or (self:checkStatus() == 20 and base.serverTime < signupEndTime) then
            if self:checkCanApply() == true and allianceVoApi:isHasAlliance() == true then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance.role and tostring(selfAlliance.role) == "2" then
                    if self:getIsApply() == 1 then
                        return 2
                    else
                        return 1
                    end
                else
                    return 0
                end
            else
                return - 1
            end
        elseif self:checkStatus() == 20 and base.serverTime >= signupEndTime then
            if self:checkCanApply() == true and allianceVoApi:isHasAlliance() == true then
                if self:getIsApply() == 1 then
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance.role and tostring(selfAlliance.role) == "2" then
                        local roundIndex = self:getCurrentRoundIndex()
                        if roundIndex == 1 and base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60 then
                            return 2
                        else
                            --今天自己军团有没有参赛
                            local battleID = self:getBattleID(roundIndex)
                            if roundIndex and roundIndex > 0 and battleID then
                                local battleStatus = self:getOutBattleStatus(roundIndex, battleID)
                                local battleSt = self:getOutBattleTime(roundIndex, battleID)
                                if battleStatus < 11 and battleSt and base.serverTime < battleSt then
                                    return 2
                                elseif battleStatus >= 11 and battleStatus < 31 then
                                    return 3
                                elseif battleStatus >= 31 then
                                    local isWin = self:getBattleIsWin(roundIndex, battleID)
                                    if isWin == true and roundIndex < 3 then
                                        return 2
                                    else
                                        return - 1
                                    end
                                else
                                    return 0
                                end
                            else
                                return 0
                            end
                        end
                    else
                        return 0
                    end
                else
                    return 10
                end
            else
                return - 1
            end
        else
            return - 1
        end
    end
    return - 1
end

--报名，上阵提示
function serverWarTeamVoApi:isShowSetMemTip()
    local state = self:canSetOrApply()
    if state >= 0 and self:getIsMemChange() == 1 then
        return true
    elseif state == 1 then
        return true
    elseif state == 2 then
        local memList = self:getMemList()
        if memList and SizeOfTable(memList) < serverWarTeamCfg.numberOfBattle then
            return true
        end
    end
    return false
end

------------以上设置上下阵----------------

------------以下战报统计----------------
function serverWarTeamVoApi:showRecordDialog(layerNum, roundIndex, battleID, isBattle)
    local function showDialog()
        require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamRecordDialog"
        local td = serverWarTeamRecordDialog:new(layerNum + 1, roundIndex, battleID, isBattle)
        local tbArr = {getlocal("serverwarteam_total_report"), getlocal("serverwarteam_destory_report")}
        if self:getIsApply() == 1 then
            tbArr = {getlocal("serverwarteam_total_report"), getlocal("serverwarteam_destory_report"), getlocal("serverwarteam_person_report")}
        end
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("arena_fightRecord"), true, layerNum + 1)
        sceneGame:addChild(dialog, layerNum + 1)
    end
    
    local function acrossTroopsreportHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.report then
                self:formatStatsData(sData.data.report, roundIndex, battleID)
                self:setDFlag(roundIndex, battleID, 1)
                showDialog()
            end
        end
    end
    
    local warId = self:getServerWarId()
    local dFlag = self:getDFlag(roundIndex, battleID)
    if warId and roundIndex and battleID and dFlag then
        if isBattle and isBattle == 1 then
            showDialog()
        elseif dFlag and dFlag == -1 then
            -- print("socketHost====>>>",self.socketHost["host"])
            --         local httpUrl="http://"..self.socketHost["host"].."/tank-server/public/index.php/across/report/getreport"
            --         -- local reqTb = {bid=warId,round=roundIndex,group=battleID,uid=playerVoApi:getUid() }--,dtype=dtype,page=page}
            --         local reqTb="bid="..warId.."&round="..roundIndex.."&group="..battleID.."&uid="..playerVoApi:getUid().."&dtype="..1
            --     local retStr=G_sendHttpRequestPost(httpUrl,reqTb)
            --   if(retStr~="")then
            --   local sData=G_Json.decode(retStr)
            --   G_dayin(sData)
            --   if sData and sData.ret==0 then
            -- -- refreshData(retData.data)
            --             self:formatStatsData(sData.data.report,roundIndex,battleID)
            --             self:setDFlag(roundIndex,battleID,1)
            --             showDialog()
            -- end
            --   end
            --"http://"..base.serverIp.."/tank-server/public/index.php/killrace/ranking/grade"
            
            socketHelper:acrossTroopsreport(2, warId, roundIndex, battleID, acrossTroopsreportHandler)
        else
            showDialog()
        end
    end
end

function serverWarTeamVoApi:clearRecord()
    if self.recordTab then
        for k, v in pairs(self.recordTab) do
            self.recordTab[k] = nil
        end
        self.recordTab = nil
    end
    self.recordTab = {}
end
function serverWarTeamVoApi:clearPRecord()
    if self.pRecordTab then
        for k, v in pairs(self.pRecordTab) do
            self.pRecordTab[k] = nil
        end
        self.pRecordTab = nil
    end
    self.pRecordTab = {}
end
function serverWarTeamVoApi:getDFlag(roundIndex, battleID, dtype)
    if roundIndex and battleID then
        if dtype and dtype == 1 then
            if self.pFlag == nil then
                self.pFlag = {}
            end
            if self.pFlag[roundIndex] == nil then
                self.pFlag[roundIndex] = {}
            end
            if self.pFlag[roundIndex][battleID] == nil then
                self.pFlag[roundIndex][battleID] = -1
            end
            return self.pFlag[roundIndex][battleID]
        else
            if self.dFlag == nil then
                self.dFlag = {}
            end
            if self.dFlag[roundIndex] == nil then
                self.dFlag[roundIndex] = {}
            end
            if self.dFlag[roundIndex][battleID] == nil then
                self.dFlag[roundIndex][battleID] = -1
            end
            return self.dFlag[roundIndex][battleID]
        end
    end
    return nil
end
function serverWarTeamVoApi:setDFlag(roundIndex, battleID, flag, dtype)
    if roundIndex and battleID then
        if dtype and dtype == 1 then
            if self.pFlag == nil then
                self.pFlag = {}
            end
            if self.pFlag[roundIndex] == nil then
                self.pFlag[roundIndex] = {}
            end
            self.pFlag[roundIndex][battleID] = flag
        else
            if self.dFlag == nil then
                self.dFlag = {}
            end
            if self.dFlag[roundIndex] == nil then
                self.dFlag[roundIndex] = {}
            end
            self.dFlag[roundIndex][battleID] = flag
        end
    end
end

function serverWarTeamVoApi:getRedDestroy(roundIndex, battleID)
    if roundIndex and battleID then
        if self.redDestroy and self.redDestroy[roundIndex] and self.redDestroy[roundIndex][battleID] then
            return self.redDestroy[roundIndex][battleID]
        end
    end
    return 0
end
function serverWarTeamVoApi:setRedDestroy(roundIndex, battleID, num)
    if roundIndex and battleID then
        if self.redDestroy == nil then
            self.redDestroy = {}
        end
        if self.redDestroy[roundIndex] == nil then
            self.redDestroy[roundIndex] = {}
        end
        if self.redDestroy[roundIndex][battleID] == nil then
            self.redDestroy[roundIndex][battleID] = 0
        end
        self.redDestroy[roundIndex][battleID] = num
    end
end
function serverWarTeamVoApi:getBlueDestroy(roundIndex, battleID)
    if roundIndex and battleID then
        if self.blueDestroy and self.blueDestroy[roundIndex] and self.blueDestroy[roundIndex][battleID] then
            return self.blueDestroy[roundIndex][battleID]
        end
    end
    return 0
end
function serverWarTeamVoApi:setBlueDestroy(roundIndex, battleID, num)
    if roundIndex and battleID then
        if self.blueDestroy == nil then
            self.blueDestroy = {}
        end
        if self.blueDestroy[roundIndex] == nil then
            self.blueDestroy[roundIndex] = {}
        end
        if self.blueDestroy[roundIndex][battleID] == nil then
            self.blueDestroy[roundIndex][battleID] = 0
        end
        self.blueDestroy[roundIndex][battleID] = num
    end
end
function serverWarTeamVoApi:formatStatsData(data, roundIndex, battleID)
    -- data={}
    -- data["1-1167"]={a10003=10,a10001=5}
    -- data["1-1164"]={a10003=10}
    
    if self.allianceDestroyTab == nil then
        self.allianceDestroyTab = {}
    end
    if self.allianceDestroyTab[roundIndex] == nil then
        self.allianceDestroyTab[roundIndex] = {}
    end
    if self.allianceDestroyTab[roundIndex][battleID] == nil then
        self.allianceDestroyTab[roundIndex][battleID] = {}
    end
    
    local battleVo = self:getBattleVoByID(roundIndex, battleID)
    local alliance1, alliance2 = self:getRedAndBlueAlliance(battleVo)
    
    if data then
        local rednum = {}
        local bluenum = {}
        for k, v in pairs(data) do
            if k and alliance1 and alliance1.id and k == alliance1.id then
                rednum = v
            elseif k and alliance2 and alliance2.id and k == alliance2.id then
                bluenum = v
            end
        end
        
        local function sortAsc(a, b)
            if a and b and a[4] and b[4] then
                return tonumber(a[4]) > tonumber(b[4])
            end
        end
        
        self:setRedDestroy(roundIndex, battleID, 0)
        self:setBlueDestroy(roundIndex, battleID, 0)
        for k, v in pairs(tankCfg) do
            if v then
                local redDestroyNum = 0
                local blueDestroyNum = 0
                if rednum and rednum["a"..v.sid] then
                    redDestroyNum = tonumber(rednum["a"..v.sid])
                    local redNum = self:getRedDestroy(roundIndex, battleID)
                    self:setRedDestroy(roundIndex, battleID, redNum + redDestroyNum)
                end
                if bluenum and bluenum["a"..v.sid] then
                    blueDestroyNum = tonumber(bluenum["a"..v.sid])
                    local blueNum = self:getBlueDestroy(roundIndex, battleID)
                    self:setBlueDestroy(roundIndex, battleID, blueNum + blueDestroyNum)
                end

                local aHasKey = false
                for m, n in pairs(self.allianceDestroyTab[roundIndex][battleID]) do
                    if tonumber(n[1]) == tonumber(v.sid) then
                        self.allianceDestroyTab[roundIndex][battleID][m][2] = redDestroyNum
                        self.allianceDestroyTab[roundIndex][battleID][m][3] = blueDestroyNum
                        aHasKey = true
                    end
                end
                if aHasKey == false and (redDestroyNum > 0 or blueDestroyNum > 0) then
                    local destroyTab = {tonumber(v.sid), redDestroyNum, blueDestroyNum, tonumber(v.sortId)}
                    table.insert(self.allianceDestroyTab[roundIndex][battleID], destroyTab)
                end
                
            end
        end
        table.sort(self.allianceDestroyTab[roundIndex][battleID], sortAsc)
    end
end

--军团战报数据
function serverWarTeamVoApi:formatRecordData(data, roundIndex, battleID, page)
    -- data={
    -- {1,1,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-1,1},
    -- {1,2,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-2,2},
    -- {1,3,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-3,3},
    -- {1,4,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-4,4},
    -- {1,5,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-5,5},
    -- {1,6,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-6,6},
    -- {1,7,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-7,7},
    -- {1,8,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-8,8},
    
    -- {2,11,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-11,1},
    -- {2,12,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-12,2},
    -- {2,13,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-13,3},
    -- {2,14,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-14,4},
    -- {2,15,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-15,5},
    -- {2,16,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-16,6},
    -- {2,17,1,1013824,1013766,"attName","defName",1,2,"attAName","defAName",base.serverTime-17,7},
    -- {2,18,1,1013766,1013824,"attName","defName",1,2,"attAName","defAName",base.serverTime-18,8},
    
    -- }
    
    if self.recordTab == nil then
        self.recordTab = {}
    end
    if self.recordTab[roundIndex] == nil then
        self.recordTab[roundIndex] = {}
    end
    if self.recordTab[roundIndex][battleID] == nil then
        self.recordTab[roundIndex][battleID] = {}
    end
    if self.recordTab[roundIndex][battleID][page] == nil then
        self.recordTab[roundIndex][battleID][page] = {}
    end
    if data then
        local function sortAsc(a, b)
            return tonumber(a.time) > tonumber(b.time)
        end
        for k, v in pairs(data) do
            local attAid = tonumber(v[10])
            local defAid = tonumber(v[11])
            local attZoneId
            local defZoneId
            if attAid == nil then
                attZoneId, attAid = Split(v[10], "-")
            end
            if defAid == nil then
                defZoneId, defAid = Split(v[11], "-")
            end
            
            -- local type,warid,rid,attId,attName,defId,defName,attAName,defAName,time,placeIndex,report=tonumber(v[1]),tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),v[5],tonumber(v[6]),v[7],v[8],v[9],tonumber(v[12]),v[13],v[14]
            local type, warid, rid, attId, attName, defId, defName, attAName, defAName, time, placeIndex, aLastPlace, dLastPlace, baseblood, victor, placeOid = tonumber(v[1]), tonumber(v[2]), tonumber(v[3]), v[4], v[5], v[6], v[7], v[8], v[9], tonumber(v[12]), v[13], v[14], v[15], tonumber(v[16]), v[17], v[18]
            
            local attIsAttacker = true
            if placeOid then
                if tostring(placeOid) == "0" then
                    if type ~= 2 then
                        type = 3
                        if tonumber(victor) == tonumber(defId) then --这里设置攻击方为胜利方，战报文字显示用
                            attIsAttacker = false
                        end
                    end
                else
                    if placeOid == v[10] then
                        attIsAttacker = false
                    end
                end
            end
            
            if type == 1 or type == 2 or type == 3 then
                local vo = serverWarTeamRecordVo:new()
                if attIsAttacker == true then
                    vo:initWithData(type, warid, rid, attId, defId, attName, defName, attAid, defAid, attAName, defAName, attZoneId, defZoneId, time, placeIndex, {})
                else
                    vo:initWithData(type, warid, rid, defId, attId, defName, attName, defAid, attAid, defAName, attAName, defZoneId, attZoneId, time, placeIndex, {})
                end
                table.insert(self.recordTab[roundIndex][battleID][page], vo)
            end
        end
        table.sort(self.recordTab[roundIndex][battleID][page], sortAsc)
        
    end
    
end

--个人战报数据
function serverWarTeamVoApi:formatPRecordData(data, roundIndex, battleID, page)
    require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamFightVoApi"
    if self.pRecordTab == nil then
        self.pRecordTab = {}
    end
    if self.pRecordTab[roundIndex] == nil then
        self.pRecordTab[roundIndex] = {}
    end
    if self.pRecordTab[roundIndex][battleID] == nil then
        self.pRecordTab[roundIndex][battleID] = {}
    end
    if self.pRecordTab[roundIndex][battleID][page] == nil then
        self.pRecordTab[roundIndex][battleID][page] = {}
    end
    if data and allianceVoApi:isHasAlliance() then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        local selfID = base.curZoneID.."-"..selfAlliance.aid
        local function sortAsc(a, b)
            return tonumber(a.time) > tonumber(b.time)
        end
        for k, v in pairs(data) do
            -- local attAid=tonumber(v[10])
            -- local defAid=tonumber(v[11])
            -- local attZoneId
            -- local defZoneId
            -- if attAid==nil then
            -- attZoneId,attAid=Split(v[10],"-")
            -- end
            -- if defAid==nil then
            -- defZoneId,defAid=Split(v[11],"-")
            -- end
            local attZoneId, attAid = 0, 0
            local defZoneId, defAid = 0, 0
            local attArr = {}
            local defArr = {}
            if v[10] and v[10] ~= "" then
                attArr = Split(v[10], "-")
            end
            if v[11] and v[11] ~= "" then
                defArr = Split(v[11], "-")
            end
            if attArr and SizeOfTable(attArr) > 0 then
                attZoneId, attAid = tonumber(attArr[1]), tonumber(attArr[2])
            end
            if defArr and SizeOfTable(defArr) > 0 then
                defZoneId, defAid = tonumber(defArr[1]), tonumber(defArr[2])
            end
            
            -- [0,"warid(b14381)","rid(11525)","0","","0","","","","","","1480428907","轰炸地点(a15)","0","我的上次所在地点(a13)","0","0","0","1"]
            local type, warid, rid, attId, attName, defId, defName, attAName, defAName, time, placeIndex, aLastPlace, dLastPlace, baseblood, victor, placeOid, bomb = tonumber(v[1]), tonumber(v[2]), tonumber(v[3]), v[4], v[5], v[6], v[7], v[8], v[9], tonumber(v[12]), v[13], v[14], v[15], tonumber(v[16]), v[17], v[18], tonumber(v[19])

            attId = (tonumber(attId) or tonumber(RemoveFirstChar(attId))) or 0
            defId = (tonumber(defId) or tonumber(RemoveFirstChar(defId))) or 0
            if attId > 0 and attId < 100 then
                attName = getlocal("serverwarteam_npcName", {attId})
            end
            if defId > 0 and defId < 100 then
                defName = getlocal("serverwarteam_npcName", {defId})
            end
            
            if tonumber(aLastPlace) and tonumber(aLastPlace) == 0 then
                aLastPlace = placeIndex
            end
            if tonumber(dLastPlace) and tonumber(dLastPlace) == 0 then
                dLastPlace = placeIndex
            end
            
            local selfIsAttPlayer = 0 --自己是否是attId这个玩家
            local selfId = playerVoApi:getUid()
            local selfName = playerVoApi:getPlayerName()
            local selfAName = selfAlliance.name
            local selfZoneId = base.curZoneID
            local selfAid = selfAlliance.aid
            local targetId = 0
            local target = ""
            local targetAName = ""
            local targetZoneId = 0
            local targetAId = 0
            local myLastPlace, targetLastPlace
            if attId == playerVoApi:getUid() then
                targetId = defId
                targetName = defName
                targetAName = defAName
                myLastPlace = aLastPlace
                targetLastPlace = dLastPlace
                targetZoneId = defZoneId
                targetAId = defAid
            else
                targetId = attId
                targetName = attName
                targetAName = attAName
                myLastPlace = dLastPlace
                targetLastPlace = aLastPlace
                targetZoneId = attZoneId
                targetAId = attAid
                selfIsAttPlayer = 1
            end
            
            local isAllAttacker = false--是否都是攻击者(据点没人占领，双方同时达到)
            local isAttacker = true
            local title = ""
            local isVictory = false
            local isBase = 0
            local lossBlood = 0
            local isOccupy = 0
            local isBomb = 0
            if bomb and bomb > 0 then
                isBomb = bomb
            end
            if isBomb > 0 then
                title = getlocal("fight_content_fight_title")..getlocal("email_figth_title3")
                myLastPlace = dLastPlace
            else
                
                if tostring(placeOid) == "0" then
                    if placeIndex == myLastPlace then
                        isAttacker = false
                    elseif placeIndex ~= aLastPlace and placeIndex ~= dLastPlace then
                        isAllAttacker = true
                    end
                elseif selfID == placeOid then
                    isAttacker = false
                end
                if tonumber(selfId) == tonumber(victor) then
                    isVictory = true
                end
                if type == 2 then
                    isAttacker = true
                    isVictory = true
                    local placeName = getlocal("serverwarteam_report_emeny_base")--self:getAreaNameByIndex(placeIndex)
                    title = getlocal("fight_content_fight_title")..getlocal("email_figth_title1", {placeName})
                else
                    if isAttacker == true then
                        title = getlocal("fight_content_fight_title")..getlocal("email_figth_title1", {targetName})
                    else
                        title = getlocal("fight_content_fight_title")..getlocal("email_figth_title2", {targetName})
                    end
                end

                local battlePlace = (tonumber(placeIndex) or tonumber(RemoveFirstChar(placeIndex)))
                local mapCfg = serverWarTeamFightVoApi:getMapCfg()
                local baseId1, baseId2 = mapCfg.baseCityID[1], mapCfg.baseCityID[2]
                local baseCityID1, baseCityID2 = (tonumber(baseId1) or tonumber(RemoveFirstChar(baseId1))), (tonumber(baseId2) or tonumber(RemoveFirstChar(baseId2)))
                if battlePlace == baseCityID1 or battlePlace == baseCityID2 then
                    isBase = 1
                    if isAttacker == true and targetId == 0 then
                        lossBlood = serverWarTeamCfg.lossBlood
                    end
                end
                if type == 1 then
                    -- if (isAttacker==true and isVictory==true) or (isAttacker==false and isVictory==false) then
                    if (isAttacker == true and isVictory == true) then
                        isOccupy = 1
                    end
                end
                if isAllAttacker == true and isVictory == false then
                    isOccupy = 0
                end
            end
            
            local vo = serverWarTeamPRecordVo:new()
            vo:initWithData(type, warid, rid, selfIsAttPlayer, selfId, selfName, selfAName, targetId, targetName, targetAName, myLastPlace, targetLastPlace, time, placeIndex, isAttacker, isVictory, title, baseblood, isBase, lossBlood, isOccupy, isBomb)
            table.insert(self.pRecordTab[roundIndex][battleID][page], vo)
        end
        table.sort(self.pRecordTab[roundIndex][battleID][page], sortAsc)
    end
end

function serverWarTeamVoApi:formatPRecordDetailData(data, roundIndex, battleID, rid)
    if data and SizeOfTable(data) > 0 and self.pRecordTab[roundIndex][battleID] then
        for page, pageTab in pairs(self.pRecordTab[roundIndex][battleID]) do
            for index, record in pairs(pageTab) do
                if record.rid == rid then
                    local lostShip = {
                        attackerLost = {},
                    defenderLost = {}}
                    local accessory = {}
                    local hero = {{{}, 0}, {{}, 0}}
                    local aitroops = {{{0, 0, 0, 0, 0, 0}, 0}, {{0, 0, 0, 0, 0, 0}, 0}}
                    local report = {}
                    local superEquip = {0, 0}
                    local plane
                    local airship
                    
                    if data then
                        if data.destroy then
                            local destroyTab = data.destroy
                            if destroyTab then
                                local attackerLost
                                local defenderLost
                                if record.isAttacker == true then
                                    attackerLost = destroyTab.defenser
                                    defenderLost = destroyTab.attacker
                                else
                                    attackerLost = destroyTab.attacker
                                    defenderLost = destroyTab.defenser
                                end
                                if record.selfIsAttPlayer == 1 then
                                    if record.isAttacker == true then
                                        attackerLost = destroyTab.attacker
                                        defenderLost = destroyTab.defenser
                                    else
                                        attackerLost = destroyTab.defenser
                                        defenderLost = destroyTab.attacker
                                    end
                                end
                                if record.isBomb and record.isBomb > 0 then
                                    defenderLost = destroyTab.attacker
                                    attackerLost = destroyTab.defenser
                                end
                                if attackerLost then
                                    lostShip.attackerLost = FormatItem({o = attackerLost}, false)
                                end
                                if defenderLost then
                                    lostShip.defenderLost = FormatItem({o = defenderLost}, false)
                                end
                            end
                        end
                        if data.aey then
                            accessory = data.aey
                            if record.selfIsAttPlayer == 1 then
                                accessory = {data.aey[2], data.aey[1]}
                            end
                        end
                        if data.hh then
                            hero = data.hh
                            if record.selfIsAttPlayer == 1 then
                                hero = {data.hh[2], data.hh[1]}
                            end
                        end
                        if data.ait then --AI部队
                            aitroops = data.ait
                            if record.selfIsAttPlayer == 1 then
                                aitroops = {data.ait[2], data.ait[1]}
                            end
                        end
                        if data.equip then
                            superEquip = data.equip
                            if record.selfIsAttPlayer == 1 then
                                superEquip = {data.equip[2], data.equip[1]}
                            end
                        end
                        if data.plane then
                            plane = data.plane
                            if record.selfIsAttPlayer == 1 then
                                plane = {data.plane[2], data.plane[1]}
                            end
                        end
                        if data.ap then
                            airship = data.ap
                            if record.selfIsAttPlayer == 1 then
                                airship = {data.ap[2], data.ap[1]}
                            end
                        end
                        if data.report then
                            report = data.report
                        end
                    end
                    
                    self.pRecordTab[roundIndex][battleID][page][index].lostShip = lostShip
                    self.pRecordTab[roundIndex][battleID][page][index].accessory = accessory
                    self.pRecordTab[roundIndex][battleID][page][index].hero = hero
                    self.pRecordTab[roundIndex][battleID][page][index].aitroops = aitroops
                    self.pRecordTab[roundIndex][battleID][page][index].report = report
                    self.pRecordTab[roundIndex][battleID][page][index].superEquip = superEquip
                    self.pRecordTab[roundIndex][battleID][page][index].plane = plane
                    self.pRecordTab[roundIndex][battleID][page][index].airship = airship
                    
                    return record
                end
            end
        end
    end
    return nil
end

function serverWarTeamVoApi:getReportDesc(record)
    local content = {}
    local color = {}
    if record and SizeOfTable(record) > 0 then
        local msgStr1 = ""
        local msgStr2 = ""
        local msgStr3 = ""
        local msgStr4 = ""
        local msgStr5 = ""
        local msgStr6 = ""
        
        local isAttacker = record.isAttacker
        local isBomb = record.isBomb or 0
        if isBomb > 0 then
            msgStr1 = getlocal("serverwarteam_report_fight_3")
            msgStr3 = getlocal("serverwarteam_report_my_last_place", {self:getAreaNameByIndex(record.myLastPlace)})
        else
            local targetName
            if record.type == 2 then
                targetName = getlocal("serverwarteam_report_emeny_base")--self:getAreaNameByIndex(record.placeIndex)
            else
                targetName = record.targetName
            end
            if isAttacker == true then
                msgStr1 = getlocal("serverwarteam_report_fight_1", {targetName})
                msgStr3 = getlocal("serverwarteam_report_my_last_place", {self:getAreaNameByIndex(record.myLastPlace)})
            else
                msgStr1 = getlocal("serverwarteam_report_fight_2", {targetName})
                msgStr3 = getlocal("serverwarteam_report_target_last_place", {self:getAreaNameByIndex(record.targetLastPlace)})
            end
        end
        msgStr2 = getlocal("fight_content_place1", {self:getAreaNameByIndex(record.placeIndex)})
        msgStr4 = getlocal("fight_content_time", {G_getDataTimeStr(record.time)})
        color = {G_ColorWhite, G_ColorWhite, G_ColorWhite, G_ColorWhite}
        
        if isBomb > 0 then
            msgStr5 = getlocal("serverwarteam_report_result", {getlocal("serverwarteam_report_death")})
            table.insert(color, G_ColorRed)
        else
            local resultStr = ""
            if record.isVictory == true then
                if isAttacker == true then
                    resultStr = getlocal("serverwarteam_report_fight_win")
                else
                    resultStr = getlocal("serverwarteam_report_defend_win")
                end
                table.insert(color, G_ColorGreen)
            else
                if isAttacker == true then
                    resultStr = getlocal("serverwarteam_report_fight_fail")
                else
                    resultStr = getlocal("serverwarteam_report_defend_fail")
                end
                table.insert(color, G_ColorRed)
            end
            if record.isOccupy == 1 and record.isBase ~= 1 then
                resultStr = resultStr.." "..getlocal("serverwarteam_report_fight_occupy")
            end
            msgStr5 = getlocal("serverwarteam_report_result", {resultStr})
        end

        if isBomb > 0 then
            if isBomb == 1 then
                content = {msgStr1, msgStr2, msgStr3, msgStr4}
            else
                content = {msgStr1, msgStr2, msgStr3, msgStr4, msgStr5}
            end
        elseif record.isBase == 1 then
            if record.lossBlood and record.lossBlood > 0 then
                msgStr6 = getlocal("serverwarteam_report_basep_blood", {record.baseblood, serverWarTeamCfg.baseBlood, "<rayimg>(-"..record.lossBlood..")"})
            else
                msgStr6 = getlocal("serverwar_team_baseHp", {record.baseblood, serverWarTeamCfg.baseBlood})
            end
            table.insert(color, G_ColorWhite)
            content = {msgStr1, msgStr2, msgStr3, msgStr4, msgStr5, msgStr6}
        else
            content = {msgStr1, msgStr2, msgStr3, msgStr4, msgStr5}
        end
    end
    return content, color
end

function serverWarTeamVoApi:isShowAccessory()
    if base.ifAccessoryOpen == 1 then
        return true
    end
    return false
end

function serverWarTeamVoApi:isShowHero()
    if base.heroSwitch == 1 then
        return true
    end
    return false
end

--一页显示数量
function serverWarTeamVoApi:getPageNum(dtype)
    if dtype and dtype == 1 then
        return self.pPageNum
    else
        return self.pageNum
    end
end
function serverWarTeamVoApi:setPageNum(pageNum, dtype)
    if dtype and dtype == 1 then
        self.pPageNum = self.pageNum
    else
        self.pageNum = self.pageNum
    end
end

function serverWarTeamVoApi:hasMore(roundIndex, battleID, curPage, dtype)
    local maxPage = self:getCurMaxPageTab(roundIndex, battleID, dtype)
    if curPage < maxPage then
        return true
    else
        local nextPage = self:getNextPage(roundIndex, battleID, dtype)
        if nextPage and nextPage > 0 then
            return true
        else
            return false
        end
    end
end

function serverWarTeamVoApi:getNextPage(roundIndex, battleID, dtype)
    local nextPage = 1
    if dtype and dtype == 1 then
        if self.pNextPageTab and self.pNextPageTab[roundIndex] and self.pNextPageTab[roundIndex][battleID] then
            nextPage = self.pNextPageTab[roundIndex][battleID]
        end
    else
        if self.nextPageTab and self.nextPageTab[roundIndex] and self.nextPageTab[roundIndex][battleID] then
            nextPage = self.nextPageTab[roundIndex][battleID]
        end
    end
    return nextPage
end
function serverWarTeamVoApi:setNextPage(roundIndex, battleID, nextPage, dtype)
    if dtype and dtype == 1 then
        if self.pNextPageTab == nil then
            self.pNextPageTab = {}
        end
        if self.pNextPageTab[roundIndex] == nil then
            self.pNextPageTab[roundIndex] = {}
        end
        self.pNextPageTab[roundIndex][battleID] = nextPage
    else
        if self.nextPageTab == nil then
            self.nextPageTab = {}
        end
        if self.nextPageTab[roundIndex] == nil then
            self.nextPageTab[roundIndex] = {}
        end
        self.nextPageTab[roundIndex][battleID] = nextPage
    end
end

function serverWarTeamVoApi:getCurMaxPageTab(roundIndex, battleID, dtype)
    local maxPage = 1
    if dtype and dtype == 1 then
        if self.curMaxPPageTab and self.curMaxPPageTab[roundIndex] and self.curMaxPPageTab[roundIndex][battleID] then
            maxPage = self.curMaxPPageTab[roundIndex][battleID]
        end
    else
        if self.curMaxPageTab and self.curMaxPageTab[roundIndex] and self.curMaxPageTab[roundIndex][battleID] then
            maxPage = self.curMaxPageTab[roundIndex][battleID]
        end
    end
    return maxPage
end
function serverWarTeamVoApi:setCurMaxPageTab(roundIndex, battleID, maxPage, dtype)
    if dtype and dtype == 1 then
        if self.curMaxPPageTab == nil then
            self.curMaxPPageTab = {}
        end
        if self.curMaxPPageTab[roundIndex] == nil then
            self.curMaxPPageTab[roundIndex] = {}
        end
        self.curMaxPPageTab[roundIndex][battleID] = maxPage
    else
        if self.curMaxPageTab == nil then
            self.curMaxPageTab = {}
        end
        if self.curMaxPageTab[roundIndex] == nil then
            self.curMaxPageTab[roundIndex] = {}
        end
        self.curMaxPageTab[roundIndex][battleID] = maxPage
    end
end

function serverWarTeamVoApi:getRecordNum(roundIndex, battleID, page, dtype)
    if dtype and dtype == 1 then
        local pageNum = self:getPageNum(dtype)
        local num = pageNum * (page - 1)
        local pRecordTab = self:getRecordTab(dtype)
        if pRecordTab and pRecordTab[roundIndex] and pRecordTab[roundIndex][battleID] and pRecordTab[roundIndex][battleID][page] then
            num = num + SizeOfTable(pRecordTab[roundIndex][battleID][page])
        end
        return num
    else
        local pageNum = self:getPageNum()
        local num = pageNum * (page - 1)
        local recordTab = self:getRecordTab()
        if recordTab and recordTab[roundIndex] and recordTab[roundIndex][battleID] and recordTab[roundIndex][battleID][page] then
            num = num + SizeOfTable(recordTab[roundIndex][battleID][page])
        end
        return num
    end
end
function serverWarTeamVoApi:getRecordTab(dtype)
    if dtype and dtype == 1 then
        if self.pRecordTab == nil then
            self.pRecordTab = {}
        end
        return self.pRecordTab
    else
        if self.recordTab == nil then
            self.recordTab = {}
        end
        return self.recordTab
    end
end
function serverWarTeamVoApi:getRecordTabByPage(roundIndex, battleID, page, callback, dtype, noCache)
    if dtype == nil then
        dtype = 0
    end
    local function refreshData(getData)
        if getData then
            if dtype and dtype == 1 then
                if getData.nextPage then
                    self:setNextPage(roundIndex, battleID, getData.nextPage, dtype)
                    if getData.nextPage > 1 then
                        self:setCurMaxPageTab(roundIndex, battleID, getData.nextPage - 1, dtype)
                    end
                end
                if getData.report then
                    self:formatPRecordData(getData.report, roundIndex, battleID, page)
                end
            else
                if getData.nextPage then
                    self:setNextPage(roundIndex, battleID, getData.nextPage)
                    if getData.nextPage > 1 then
                        self:setCurMaxPageTab(roundIndex, battleID, getData.nextPage - 1)
                    end
                end
                if getData.report then
                    self:formatRecordData(getData.report, roundIndex, battleID, page)
                end
            end
            if callback then
                callback()
            end
        end
    end
    
    local function acrossReportCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            refreshData(sData.data)
        end
    end
    
    local function sendRequestHandle()
        local category = 2
        local bid = self:getServerWarId()
        if bid then
            if noCache == 1 then -- 跨服数据，用http请求获取
                local httpUrl = "http://"..self.socketHost["host"] .. "/tank-server/public/index.php/across/report/getreport"
                local reqTb = "bid="..bid.."&round="..roundIndex.."&group="..battleID.."&uid="..playerVoApi:getUid() .. "&dtype="..dtype.."&page="..page.."&category="..category
                local retStr = G_sendHttpRequestPost(httpUrl, reqTb)
                if(retStr ~= "")then
                    local sData = G_Json.decode(retStr)
                    -- G_dayin(sData)
                    if sData and sData.ret == 0 then
                        refreshData(sData.data)
                    end
                end
            else
                socketHelper:acrossReport(category, bid, roundIndex, battleID, page, acrossReportCallback, dtype, noCache)
            end
        end
    end
    
    if roundIndex and battleID and page then
        if dtype and dtype == 1 then
            if self.pRecordTab and self.pRecordTab[roundIndex] and self.pRecordTab[roundIndex][battleID] and self.pRecordTab[roundIndex][battleID][page] and SizeOfTable(self.pRecordTab[roundIndex][battleID][page]) > 0 then
                if callback then
                    callback()
                end
                do return end
            end
        else
            if self.recordTab and self.recordTab[roundIndex] and self.recordTab[roundIndex][battleID] and self.recordTab[roundIndex][battleID][page] and SizeOfTable(self.recordTab[roundIndex][battleID][page]) > 0 then
                if callback then
                    callback()
                end
                do return end
            end
        end
        sendRequestHandle()
    end
end
function serverWarTeamVoApi:getRecordByIndex(roundIndex, battleID, index, dtype)
    if dtype and dtype == 1 then
        local pageNum = self:getPageNum(dtype)
        local page = math.ceil(index / pageNum)
        local idx = index % pageNum
        if idx == 0 then
            idx = pageNum
        end
        if self.pRecordTab and roundIndex and battleID and self.pRecordTab[roundIndex] and self.pRecordTab[roundIndex][battleID] and self.pRecordTab[roundIndex][battleID][page] and self.pRecordTab[roundIndex][battleID][page][idx] then
            return self.pRecordTab[roundIndex][battleID][page][idx]
        end
    else
        local pageNum = self:getPageNum()
        local page = math.ceil(index / pageNum)
        local idx = index % pageNum
        if idx == 0 then
            idx = pageNum
        end
        if self.recordTab and roundIndex and battleID and self.recordTab[roundIndex] and self.recordTab[roundIndex][battleID] and self.recordTab[roundIndex][battleID][page] and self.recordTab[roundIndex][battleID][page][idx] then
            return self.recordTab[roundIndex][battleID][page][idx]
        end
    end
    return nil
end

-- function serverWarTeamVoApi:getPersonNum()
-- local destroyNum=0
-- local lostNum=0
-- for k,v in pairs(self.personDestroyTab) do
-- destroyNum=destroyNum+(v[2] or 0)
-- lostNum=lostNum+(v[3] or 0)
-- end
-- return destroyNum,lostNum
-- end
-- function serverWarTeamVoApi:getPersonDestroyTab()
-- if self.personDestroyTab==nil then
-- self.personDestroyTab={}
-- end
-- return self.personDestroyTab
-- end
function serverWarTeamVoApi:getAllianceDestroyTab(roundIndex, battleID)
    if roundIndex and battleID then
        if self.allianceDestroyTab == nil then
            self.allianceDestroyTab = {}
        end
        if self.allianceDestroyTab[roundIndex] == nil then
            self.allianceDestroyTab[roundIndex] = {}
        end
        if self.allianceDestroyTab[roundIndex][battleID] == nil then
            self.allianceDestroyTab[roundIndex][battleID] = {}
        end
        return self.allianceDestroyTab[roundIndex][battleID]
    else
        return {}
    end
end

function serverWarTeamVoApi:getAreaNameByIndex(idx)
    return getlocal("serverwarteam_cityName"..idx)
end
-- serverwarteam_record_type1="%s 【%s】\n【%s】的【%s】对此处驻军发起了攻击，守军【%s】的【%s】进行了坚决的抵抗，不幸战败，麾下部队溃败返回己方基地，此据点中的防守力量已全部扫除，【%s】占领了此处。",
-- serverwarteam_record_type2="%s 【%s】\n【%s】的【%s】对此处驻军发起了攻击，守军【%s】的基地防御终于崩溃，基地耐久损失【%s】，基地耐久剩余【%s】。【%s】获得了本场战斗的胜利，【%s】成功实施了最后一击。",
-- serverwarteam_record_type3="%s %s\n%s军团的%s和%s军团的%s在该据点发生了激烈的争夺战，%s不幸战败，麾下部队溃败返回己方基地，%s占领了此处。",
function serverWarTeamVoApi:getBattleDesc(record)
    local descStr = ""
    local color = G_ColorWhite
    if record then
        local timeStr = G_getDataTimeStr(record.time)
        
        local type = record.type
        local attId = record.attId
        local defId = record.defId
        local attName = record.attName
        local defName = record.defName
        local areaIndex = record.placeIndex
        local areaName = self:getAreaNameByIndex(areaIndex)
        local attAName = record.attAName
        local defAName = record.defAName
        local lossBlood = serverWarTeamCfg.lossBlood
        
        local params = {}
        -- if type==1 then
        -- params={timeStr,areaName,attAName,attName,defAName,defName,attName}
        -- elseif type==2 then
        -- params={timeStr,areaName,attAName,attName,defAName,lossBlood,attAName,attName}
        -- elseif type==3 then
        -- params={timeStr,areaName,attAName,attName,defAName,defName,defName,attName}
        -- end
        if type == 1 then
            params = {attAName, attName, defAName, defName, attName}
        elseif type == 2 then
            params = {attAName, attName, defAName, lossBlood, attAName, attName}
        elseif type == 3 then
            params = {attAName, attName, defAName, defName, defName, attName}
        end
        descStr = getlocal("serverwarteam_record_type"..type, params)
    end
    return descStr, color
end

--获取战斗是否至少有一方军团为空，即轮空
function serverWarTeamVoApi:getIsBothHasAlliance(battleVo)
    if battleVo and battleVo.alliance1 and battleVo.alliance2 then
        return true
    else
        return false
    end
end

--获取参赛军团是红方还是蓝方,return red,blue
function serverWarTeamVoApi:getRedAndBlueAlliance(battleVo)
    local allianceList = {}
    if battleVo then
        local isBothHas = self:getIsBothHasAlliance(battleVo)
        if isBothHas == true then
            local alliance1 = battleVo.alliance1
            local alliance2 = battleVo.alliance2
            if alliance1 and alliance2 and alliance1.signTime and alliance2.signTime then
                if(alliance1.signTime == alliance2.signTime)then
                    if(tonumber(alliance1.serverID) == tonumber(alliance2.serverID))then
                        if(alliance1.aid < alliance2.aid)then
                            allianceList[1] = alliance1
                            allianceList[2] = alliance2
                        else
                            allianceList[1] = alliance2
                            allianceList[2] = alliance1
                        end
                    elseif(tonumber(alliance1.serverID) < tonumber(alliance2.serverID))then
                        allianceList[1] = alliance1
                        allianceList[2] = alliance2
                    else
                        allianceList[1] = alliance2
                        allianceList[2] = alliance1
                    end
                elseif(alliance1.signTime < alliance2.signTime)then
                    allianceList[1] = alliance1
                    allianceList[2] = alliance2
                else
                    allianceList[1] = alliance2
                    allianceList[2] = alliance1
                end
            end
        end
    end
    return allianceList[1], allianceList[2]
    
end

------------以上战报统计----------------

--军团跨服战最外面的按钮是否提示，里面只要有一个提示，就显示
function serverWarTeamVoApi:isTotalShowTip()
    local isShow = false
    --是否有鲜花奖励未领取
    if self:getIsCanRewardBet() == true then
        isShow = true
    end
    
    --是否有排行榜奖励未领取
    local rewardPoint = self:getRewardPoint()
    local isRewardRank = self:getIsRewardRank()
    if rewardPoint and rewardPoint > 0 then
        if isRewardRank == true then
        else
            isShow = true
        end
    end
    
    --是否有排行榜数据
    if self:getRankHasOpen() == false then
        isShow = true
    end
    
    --是否可以进入战场
    if self:getEnterBattleStatus() == 3 then
        if self:getIsSetFleet() == true then
            isShow = true
        end
    end
    
    if self:getLastBattleIsEnd() == true then
    else
        --是否可以报名，上阵，可以上阵时上阵人数是否15人
        if self:isShowSetMemTip() == true then
            isShow = true
        end
        --是否设置部队和军饷
        if self:getIsAllSetFleet() == false or self:getLeftGems() == true then
            isShow = true
        end
    end
    
    return isShow
end

--自己军团参加跨服战状态描述
function serverWarTeamVoApi:getWarStatusDesc()
    local descStr = ""
    local countdown = 0
    if(self.startTime == nil or base.serverTime < self.startTime)then
        return descStr
    elseif(base.serverTime < G_getWeeTs(self.startTime) + serverWarTeamCfg.preparetime * 86400)then
        countdown = G_getWeeTs(self.startTime) + serverWarTeamCfg.preparetime * 86400 - base.serverTime
        descStr = getlocal("serverwarteam_desc1", {GetTimeStr(countdown), math.ceil(serverWarTeamCfg.sevbattleAlliance / SizeOfTable(self:getServerList()))})
    elseif(base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60)then
        countdown = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60 - base.serverTime
        if self:checkCanApply() == true then
            descStr = getlocal("serverwarteam_desc21", {GetTimeStr(countdown)})
        else
            descStr = getlocal("serverwarteam_desc2")
        end
    elseif(base.serverTime < (self.endTime - (serverWarTeamCfg.shoppingtime) * 86400 - (86400 - serverWarTeamCfg.flowerLimit[3][2][1] * 3600 - serverWarTeamCfg.flowerLimit[3][2][2] * 60)))then
        local isApply = self:getIsApply()
        if(base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60)then
            countdown = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60 - base.serverTime
            if isApply == 1 then
                descStr = getlocal("serverwarteam_desc31", {GetTimeStr(countdown)})
            else
                descStr = getlocal("serverwarteam_desc3", {GetTimeStr(countdown)})
            end
        else
            local timeList = self:getBattleTimeList()
            local roundIndex = self:getCurrentRoundIndex()
            if timeList and SizeOfTable(timeList) > 0 and roundIndex and roundIndex > 0 then
                if isApply == 1 then
                    local battleID = self:getBattleID(roundIndex)
                    if battleID then
                        local battleSt = self:getOutBattleTime(roundIndex, battleID)
                        local battleVo = self:getBattleVoByID(roundIndex, battleID)
                        local curRoundTimeTab = timeList[roundIndex]
                        local curRoundBattleSt = curRoundTimeTab[1]
                        local curRoundBattleEt = curRoundTimeTab[SizeOfTable(curRoundTimeTab)] + serverWarTeamCfg.warTime
                        if battleSt and battleVo then
                            if base.serverTime < battleSt - serverWarTeamCfg.setTroopsLimit then
                                -- local memList=self:getMemList()
                                -- if memList and SizeOfTable(memList)>0 then
                                -- return statusStr4,battleSt-serverWarTeamCfg.setTroopsLimit
                                -- else
                                -- return statusStr3,battleSt-serverWarTeamCfg.setTroopsLimit
                                -- end
                                countdown = battleSt - serverWarTeamCfg.setTroopsLimit - base.serverTime
                                descStr = getlocal("serverwarteam_desc31", {GetTimeStr(countdown)})
                            elseif base.serverTime < battleSt - serverWarTeamCfg.enterBattleTime then
                                countdown = battleSt - serverWarTeamCfg.enterBattleTime - base.serverTime
                                descStr = getlocal("serverwarteam_desc4", {GetTimeStr(countdown)})
                            elseif base.serverTime < battleSt then
                                countdown = battleSt - base.serverTime
                                descStr = getlocal("serverwarteam_desc51", {GetTimeStr(countdown)})
                            elseif base.serverTime < battleSt + serverWarTeamCfg.warTime then
                                if battleVo and battleVo.winnerID then
                                    descStr = getlocal("serverwarteam_desc62")
                                    -- local isWin=self:getBattleIsWin(roundIndex,battleID)
                                    -- if isWin==true then
                                    -- else
                                    -- end
                                else
                                    countdown = battleSt + serverWarTeamCfg.warTime - base.serverTime
                                    descStr = getlocal("serverwarteam_desc61", {GetTimeStr(countdown)})
                                    -- return statusStr6,battleSt+serverWarTeamCfg.warTime
                                end
                            elseif base.serverTime < curRoundBattleEt then
                                descStr = getlocal("serverwarteam_desc62")
                            else
                                local isWin = self:getBattleIsWin(roundIndex, battleID)
                                if isWin == true and roundIndex < SizeOfTable(timeList) then
                                    local nextBattleSt = timeList[roundIndex + 1][1]
                                    countdown = nextBattleSt - serverWarTeamCfg.setTroopsLimit - base.serverTime
                                    descStr = getlocal("serverwarteam_desc31", {GetTimeStr(countdown)})
                                    -- if memList and SizeOfTable(memList)>0 then
                                    -- return statusStr4,nextBattleSt-serverWarTeamCfg.setTroopsLimit
                                    -- else
                                    -- return statusStr3,nextBattleSt-serverWarTeamCfg.setTroopsLimit
                                    -- end
                                else
                                    descStr = getlocal("serverwarteam_desc7")
                                end
                            end
                        else
                            descStr = getlocal("serverwarteam_desc7")
                        end
                    else
                        descStr = getlocal("serverwarteam_desc7")
                    end
                else
                    local curRoundTimeTab = timeList[roundIndex]
                    local battleSt = curRoundTimeTab[1]
                    local battleEt = curRoundTimeTab[SizeOfTable(curRoundTimeTab)] + serverWarTeamCfg.warTime
                    -- print("battleSt,battleEt",battleSt,battleEt)
                    if base.serverTime < battleSt - serverWarTeamCfg.setTroopsLimit then
                        countdown = battleSt - serverWarTeamCfg.setTroopsLimit - base.serverTime
                        descStr = getlocal("serverwarteam_desc3", {GetTimeStr(countdown)})
                    elseif base.serverTime < battleSt - serverWarTeamCfg.enterBattleTime then
                        countdown = battleSt - serverWarTeamCfg.enterBattleTime - base.serverTime
                        descStr = getlocal("serverwarteam_desc4", {GetTimeStr(countdown)})
                    elseif base.serverTime < battleSt then
                        countdown = battleSt - base.serverTime
                        descStr = getlocal("serverwarteam_desc5", {GetTimeStr(countdown)})
                    elseif base.serverTime > battleSt and base.serverTime < battleEt then
                        countdown = battleEt - base.serverTime
                        descStr = getlocal("serverwarteam_desc6", {GetTimeStr(countdown)})
                    elseif base.serverTime > battleEt then
                        if roundIndex < SizeOfTable(timeList) then
                            local nextRoundTimeTab = timeList[roundIndex + 1]
                            local nextBattleSt = nextRoundTimeTab[1]
                            countdown = nextBattleSt - serverWarTeamCfg.setTroopsLimit - base.serverTime
                            descStr = getlocal("serverwarteam_desc3", {GetTimeStr(countdown)})
                        end
                    end
                end
            end
        end
    else
        if self:getRankFlag() == -1 then
            self:formatRankList()
        end
        local rankList = self:getRankList()
        if rankList and SizeOfTable(rankList) > 0 then
            for k, v in pairs(rankList) do
                if v and v.rank and v.rank == 1 then
                    local champion = v.name or ""
                    descStr = getlocal("serverwarteam_desc8", {champion})
                end
            end
        end
    end
    -- print("descStr",descStr)
    return descStr
end

function serverWarTeamVoApi:getLastBattleIsEnd()
    local battleList = self:getOutBattleList()
    if battleList and SizeOfTable(battleList) > 0 then
        if battleList[3] and battleList[3][1] then
            if battleList[3][1].winnerID then
                return true
            end
        end
    end
    return false
end

--自己军团参加跨服战状态和倒计时
-- statusStr1=serverwarteam_signup_open="开启报名",
-- statusStr2=serverwarteam_signup_stop="报名截止",
-- statusStr3=serverwarteam_commit_member="提交名单",
-- statusStr4=serverwarteam_battle_prepare="战斗准备",
-- statusStr5=serverwarteam_battle_soon="即将开战",
-- statusStr6=serverwarteam_battleing="战斗中",
-- statusStr7=serverwarteam_end="-",
-- statusStr8=serverwarteam_all_end="已结束",
function serverWarTeamVoApi:getWarStatusAndNextTime()
    local statusStr1 = getlocal("serverwarteam_signup_open")
    local statusStr2 = getlocal("serverwarteam_signup_stop")
    local statusStr3 = getlocal("serverwarteam_commit_member")
    local statusStr4 = getlocal("serverwarteam_battle_prepare")
    local statusStr5 = getlocal("serverwarteam_battle_soon")
    local statusStr6 = getlocal("serverwarteam_battleing")
    local statusStr7 = getlocal("serverwarteam_end")
    local statusStr8 = getlocal("serverwarteam_all_end")
    if(self.startTime == nil or base.serverTime < self.startTime)then
        return statusStr7
    elseif(base.serverTime < self.startTime + serverWarTeamCfg.preparetime * 86400)then
        return statusStr1, self.startTime + serverWarTeamCfg.preparetime * 86400
    elseif(base.serverTime < G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60)then
        local signupEndTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60
        return statusStr2, signupEndTime
    elseif(base.serverTime < (self.endTime - (serverWarTeamCfg.shoppingtime) * 86400))then
        local timeList = self:getBattleTimeList()
        local roundIndex = self:getCurrentRoundIndex()
        local isApply = self:getIsApply()
        local allBattleIsEnd = self:getLastBattleIsEnd()
        -- print("roundIndex",roundIndex)
        if allBattleIsEnd == true then
            return statusStr8
        elseif roundIndex and roundIndex <= 0 then
            return statusStr7
        elseif isApply == 1 then
            local battleID = self:getBattleID(roundIndex)
            if battleID then
                local battleSt = self:getOutBattleTime(roundIndex, battleID)
                local battleVo = self:getBattleVoByID(roundIndex, battleID)
                if battleSt and battleVo then
                    -- local memList=self:getMemList()
                    if base.serverTime < battleSt - serverWarTeamCfg.setTroopsLimit then
                        -- if memList and SizeOfTable(memList)>0 then
                        return statusStr4, battleSt - serverWarTeamCfg.setTroopsLimit
                        -- else
                        -- return statusStr3,battleSt-serverWarTeamCfg.setTroopsLimit
                        -- end
                    elseif base.serverTime < battleSt then
                        return statusStr5, battleSt
                    elseif base.serverTime < battleSt + serverWarTeamCfg.warTime then
                        if battleVo and battleVo.winnerID then
                            local isWin = self:getBattleIsWin(roundIndex, battleID)
                            if roundIndex < SizeOfTable(timeList) and isWin == true then
                                local nextBattleSt = timeList[roundIndex + 1][1]
                                -- if memList and SizeOfTable(memList)>0 then
                                return statusStr4, nextBattleSt - serverWarTeamCfg.setTroopsLimit
                                -- else
                                -- return statusStr3,nextBattleSt-serverWarTeamCfg.setTroopsLimit
                                -- end
                            else
                                return statusStr8
                            end
                        else
                            return statusStr6, battleSt + serverWarTeamCfg.warTime
                        end
                    else
                        local isWin = self:getBattleIsWin(roundIndex, battleID)
                        if roundIndex < SizeOfTable(timeList) and isWin == true then
                            local nextBattleSt = timeList[roundIndex + 1][1]
                            -- if memList and SizeOfTable(memList)>0 then
                            return statusStr4, nextBattleSt - serverWarTeamCfg.setTroopsLimit
                            -- else
                            -- return statusStr3,nextBattleSt-serverWarTeamCfg.setTroopsLimit
                            -- end
                        else
                            return statusStr8
                        end
                    end
                else
                    -- if self:getLastBattleIsEnd()==true then
                    -- return statusStr8
                    -- else
                    -- return statusStr8
                    -- end
                    return statusStr8
                end
            else
                if self:getLastBattleIsEnd() == true then
                    return statusStr8
                else
                    return statusStr8
                end
            end
        else
            local battleSt = timeList[roundIndex][1]
            local battleEt = timeList[roundIndex][SizeOfTable(timeList[roundIndex])] + serverWarTeamCfg.warTime
            if base.serverTime < battleSt - serverWarTeamCfg.setTroopsLimit then
                return statusStr4, battleSt - serverWarTeamCfg.setTroopsLimit
            elseif base.serverTime < battleSt then
                return statusStr5, battleSt
            elseif base.serverTime < battleEt then
                return statusStr6, battleEt
            elseif base.serverTime >= battleEt then
                if roundIndex >= SizeOfTable(timeList) then
                    return statusStr8
                else
                    local nextBattleSt = timeList[roundIndex + 1][1]
                    return statusStr4, nextBattleSt - serverWarTeamCfg.setTroopsLimit
                end
            end
        end
    else
        return statusStr8
    end
end

--玩家自己的军团跨服战状态变化
--0  不在战斗期间,没参加战斗
--10 报名阶段
--20 开战前
--21 开战前10分钟，不能设置部队
--22 开战前5分钟
--30 战斗中
--40 战斗结束
--41 最长战斗结束时间，开战后30分钟
--50 最后一场战斗结束，开战后30分钟
function serverWarTeamVoApi:checkBattleStatus(roundIndex)
    local status = self:checkStatus()
    if status == 20 then
        local signupEndTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600 + serverWarTeamCfg.applyedtime[2] * 60
        local setFleetEndTime = G_getWeeTs(self.startTime) + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.settroopstime[1] * 3600 + serverWarTeamCfg.settroopstime[2] * 60
        if roundIndex == 1 and base.serverTime < setFleetEndTime then
            if base.serverTime < signupEndTime then
                return 10
            else
                return 20
            end
        else
            if self:getIsApply() == 1 and roundIndex and roundIndex > 0 then
                local battleID = self:getBattleID(roundIndex)
                if battleID then
                    local battleStatus = self:getOutBattleStatus(roundIndex, battleID)
                    if battleStatus < 11 then
                        return 20
                    elseif battleStatus == 11 then
                        return 21
                    elseif battleStatus == 12 then
                        return 22
                    elseif battleStatus == 20 then
                        return 30
                    elseif battleStatus >= 30 then
                        return 40
                        -- elseif battleStatus==31 then
                        -- if roundIndex==3 then
                        -- return 50
                        -- else
                        -- return 41
                        -- end
                    end
                else
                    return 40
                end
            else
                return 0
            end
        end
    end
    return 0
end

--跨服战的状态
--return 0: 最近都没有安排过跨服战或者还没到跨服战的预热时间
--return 10: 跨服战预热阶段，不能做任何操作
--return 11: 跨服战准备阶段，可以报名，提交上阵名单，设置资金和部队
--return 20: 战斗阶段
--return 30: 战斗结束,领奖时间
--return 40: 领奖时间也过去了,跨服战彻底结束
function serverWarTeamVoApi:checkStatus()
    if(self.startTime == nil or base.serverTime < self.startTime)then
        return 0
    elseif(base.serverTime < self.startTime + serverWarTeamCfg.preparetime * 86400)then
        return 10
    elseif(base.serverTime < self.startTime + (serverWarTeamCfg.preparetime + serverWarTeamCfg.signuptime) * 86400 + serverWarTeamCfg.applyedtime[1] * 3600)then
        return 11
    else
        local timeList = self:getBattleTimeList()
        local lastBattleTimeTb = timeList[SizeOfTable(timeList)]
        local allBattleEndTime = lastBattleTimeTb[SizeOfTable(lastBattleTimeTb)] + serverWarTeamCfg.warTime
        if base.serverTime < allBattleEndTime then
            return 20
            -- if(base.serverTime<self.endTime-serverWarTeamCfg.shoppingtime*86400)then
            -- return 20
        elseif(base.serverTime < self.endTime)then
            return 30
        else
            return 40
        end
    end
end

function serverWarTeamVoApi:getHasSendNotice()
    if base.serverWarTeamSwitch == 1 and self and self.startTime and self.startTime > 0 and self:getServerWarId() then
        local dataKey = "serverWarTeamSendNotice@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        if (localData ~= nil and localData ~= "") then
            return true
        else
            return false
        end
    end
    return true
end
function serverWarTeamVoApi:setHasSendNotice()
    if self:getServerWarId() then
        local dataKey = "serverWarTeamSendNotice@"..tostring(playerVoApi:getUid()) .. "@"..tostring(base.curZoneID) .. "@"..tostring(self:getServerWarId())
        local localData = CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        CCUserDefault:sharedUserDefault():setStringForKey(dataKey, "send")
    end
end
function serverWarTeamVoApi:tick()
    if base.serverWarTeamSwitch == 1 and self and self.startTime and self.startTime > 0 then
        if serverWarTeamVoApi:getHasSendNotice() == false then
            if self:getLastBattleIsEnd() == true then
                local function formatRankListHandler()
                    local rankList = self:getRankList()
                    -- print("SizeOfTable(rankList)",SizeOfTable(rankList))
                    if rankList and SizeOfTable(rankList) > 0 then
                        for k, v in pairs(rankList) do
                            if v and v.rank and (v.rank == 1 or v.rank == 2) then
                                local type = 18 + v.rank
                                local name = v.name or ""
                                local serverName = v.server or ""
                                local params = {subType = 4, contentType = 3, message = {key = "chatSystemMessage"..type, param = {name, serverName}}, ts = base.serverTime, isSystem = 1}
                                chatVoApi:addChat(1, 0, "", 0, "", params, base.serverTime)
                                self.isSendNotice = true
                            end
                        end
                    end
                end
                self:formatRankList(formatRankListHandler, true)
                serverWarTeamVoApi:setHasSendNotice()
            end
        end
        if(self.endTime == nil or base.serverTime > self.endTime)then
            if(buildings.allBuildings)then
                for k, v in pairs(buildings.allBuildings) do
                    if(v:getType() == 16)then
                        v:setSpecialIconVisible(2, false)
                        break
                    end
                end
            end
        end
    end
end

-- 战报是否显示军徽
function serverWarTeamVoApi:isShowSuperEquip(report)
    if base.emblemSwitch == 1 and report.superEquip ~= nil and SizeOfTable(report.superEquip) == 2 and (report.superEquip[1] ~= 0 or report.superEquip[2] ~= 0) then
        return true
    end
    return false
end

function serverWarTeamVoApi:clear()
    self.serverWarId = nil
    self.serverList = nil
    self.localTeamList = nil
    self.teamList = nil
    self.batteList = nil
    self.startTime = nil
    self.endTime = nil
    self.timeTb = nil
    
    self.warInfoExpireTime = 0
    
    self.betList = nil
    self.commonList = nil
    self.rareList = nil
    self.point = 0
    self.pointDetail = {}
    self.detailExpireTime = 0
    self.buyStatus = 0
    
    self.rankList = nil
    self.lastSetFleetTime = 0
    
    self.myRank = 0
    self.isRewardRank = false
    self.shopFlag = -1
    self.pointDetailFlag = -1
    self.rankFlag = -1
    self.troopsFlag = -1
    
    self.memFlag = -1
    self.memList = {}
    self.isApply = -1
    self.lastSetMemTime = 0
    self.carrygems = 0
    self.gems = 0
    self.baseDonateNum = 0
    self.basetroops = {}
    self.lastDonateTime = 0
    self.donateFlag = -1
    
    self.redPoint = 0
    self.bluePoint = 0
    self.redDestroy = {}
    self.blueDestroy = {}
    self.rewardContribution = 0
    self.redVip = ""
    self.blueVip = ""
    self.personDestroyTab = {}
    self.allianceDestroyTab = {}
    self:clearRecord()
    self.dFlag = {}
    self.nextPageTab = {}
    self.curMaxPageTab = {}
    self:clearPRecord()
    self.pFlag = {}
    self.pNextPageTab = {}
    self.curMaxPPageTab = {}
    if(serverWarTeamFightVoApi)then
        serverWarTeamFightVoApi:clear()
    end
    self.isMemChange = 0
    self.isSendNotice = true
    self.socketHost = nil
    self.f_pShopItems = nil
    self.f_aShopItems = nil
end
