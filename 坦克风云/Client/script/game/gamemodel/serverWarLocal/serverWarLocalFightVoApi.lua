--群雄争霸战斗相关的操作放在这里
serverWarLocalFightVoApi =
{
    battleID = 0, --战斗ID
    groupID = 0, --战斗分组
    dataExpireTime = 0, --数据过期的时间, 如果serverTime大于这个时间的话就需要重新向后台拉取数据
    initFlag = nil, --是否已经进行过初始化
    endFlag = false, --战斗结束的标识
    cityList = {}, --所有的据点数据, table的key是城市ID, value是serverWarLocalCityVo
    troopList = {}, --所有的部队数据，key是部队id，value是serverWarLocalTroopVo
    allianceList = {}, --本次比赛的4个军团
    startTime = 0, --本次战斗的开始时间
    selfTroops = {}, --玩家自己的部队列表
    lastBattleTime = 0, --上一次战斗的时间戳
    order = {}, --军团指令, e.g.:{{"a1",4},{"a3",3}}
    connected = false, --是否已经连接到战斗服务器
    buffData = {}, --自己购买的buff数据
    gems = 0, --玩家带过来的金币数
    role = 0, --玩家进入战场时候的职位
    mapCfg = nil, --本次战斗的地图配置
    pointTb = {}, --得分列表
    buffList = {}, --购买的buff数据
    taskList = {}, --各个军团的突袭任务情况, key是军团ID, value是一个table，table的第一个元素是要进攻的城市，第二个元素是完成任务的时间（可能为nil），第三个元素是任务结束时间
    taskExpireTime = 0, --军团突袭任务的结束时间, 一个时间戳
    blockMoveTs = 0, --如果后端移动报错，客户端要锁定移动一段时间
    blockMoveTb = {}, --移动请求发出去之后，同一支部队在数据返回或者超时之前不能再次移动
    lastBattleTimeTmp = nil, -- 如果当前服务器时间没到最近的战斗时间戳，则先存储在临时里面
}

--进入战场
function serverWarLocalFightVoApi:showMap(layerNum)
    if(serverWarLocalVoApi.socketHost == nil)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage1985"), 30)
        do return end
    end
    self.battleID = serverWarLocalVoApi:getServerWarlocalId()
    self.groupID = serverWarLocalVoApi:getGroupID()
    
    local everyStartBattleTimeTb = serverWarLocalVoApi:getEveryStartBattleTimeTb()
    local startTime = everyStartBattleTimeTb[1]
    if serverWarLocalVoApi:isEndOfoneBattle() then
        startTime = everyStartBattleTimeTb[2]
    end
    
    self.startTime = startTime
    local function onSocketConnected()
        require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalMapScene"
        require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalAllianceVo"
        require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalCityVo"
        require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalTroopVo"
        if(base.serverTime > self.dataExpireTime)then
            local function onRefresh()
                serverWarLocalMapScene:show(layerNum, 1)
            end
            self:refreshData(onRefresh)
        else
            serverWarLocalMapScene:show(layerNum, 1)
        end
    end
    if(self.connected)then
        onSocketConnected()
    else
        require "luascript/script/netapi/socketHelper2"
        local function connectHandler(...)
            print("成功连接socket2!")
            serverWarLocalFightVoApi.connected = true
            onSocketConnected()
        end
        socketHelper2:socketConnect(serverWarLocalVoApi.socketHost["host"], serverWarLocalVoApi.socketHost["port"], connectHandler)
    end
end

--点击战场城市, 弹出面板
function serverWarLocalFightVoApi:showCityDialog(cityID, troopID, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalCitySmallDialog"
    local sd = serverWarLocalCitySmallDialog:new(cityID, troopID)
    sd:init(layerNum)
    self.cityDialog = sd
end

--给城市下达指令
function serverWarLocalFightVoApi:showCityOrderDialog(cityID, layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalCityOrderSmallDialog"
    local sd = serverWarLocalCityOrderSmallDialog:new(cityID)
    sd:init(layerNum)
end

function serverWarLocalFightVoApi:showRepairDialog(troopID, reviveTime, layerNum, callback)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalRepairSmallDialog"
    local repairDialog = serverWarLocalRepairSmallDialog:new()
    repairDialog:init(troopID, reviveTime, layerNum, callback)
end

--获取本次比赛的地图配置
function serverWarLocalFightVoApi:getMapCfg()
    local cfg
    if(true)then
        require "luascript/script/config/gameconfig/serverWarLocal/serverWarLocalMapCfg1"
        cfg = serverWarLocalMapCfg1
    else
        require "luascript/script/config/gameconfig/serverWarLocal/serverWarLocalMapCfg2"
        cfg = serverWarLocalMapCfg2
    end
    return cfg
end

--获取自己的三支部队信息
function serverWarLocalFightVoApi:getSelfTroops()
    return self.selfTroops
end

--根据id获取部队的serverWarLocalTroopVo
--param id: 部队的id
function serverWarLocalFightVoApi:getTroop(id)
    return self.troopList[id]
end

--获取所有部队的列表
function serverWarLocalFightVoApi:getTroops()
    return self.troopList
end

--根据ID获取城市的localWarCityVo
--param ID: 城市ID
function serverWarLocalFightVoApi:getCity(id)
    return self.cityList[id]
end

--获取本次战斗所有城市的数据
function serverWarLocalFightVoApi:getCityList()
    return self.cityList
end

--获取此次对战的军团
function serverWarLocalFightVoApi:getAllianceList()
    return self.allianceList
end

--获取购买的buff数据
function serverWarLocalFightVoApi:getBuffList()
    return self.buffList
end

--玩家带过来的金币数
function serverWarLocalFightVoApi:getCarryGems()
    return self.gems
end

--设置带过来的军饷
function serverWarLocalFightVoApi:setCarryGems(gems)
    self.gems = gems
    serverWarLocalVoApi:setFunds(self.gems)
end

--玩家进入战场时候的职位
function serverWarLocalFightVoApi:getRole()
    return self.role
end

--获取得分列表
function serverWarLocalFightVoApi:getPointTb()
    return self.pointTb
end

--获取自己的突袭任务
--return 当前的突袭任务
--return 突袭任务过期时间
function serverWarLocalFightVoApi:getSelfTask()
    local selfID = base.curZoneID.."-"..playerVoApi:getPlayerAid()
    return self.taskList[selfID], self.taskExpireTime
end

--获取城中所有防御部队的列表
--按照到达时间和uid和troopID排序
function serverWarLocalFightVoApi:getDefendersInCity(cityID)
    local cityVo = self:getCity(cityID)
    local result = {}
    if(cityVo and cityVo.allianceID ~= 0)then
        for id, troopVo in pairs(self.troopList) do
            if(troopVo.canMoveTime <= base.serverTime and troopVo.arriveTime <= base.serverTime and troopVo.cityID == cityID and troopVo.allianceID == cityVo.allianceID)then
                local insertFlag = false
                for k, v in pairs(result) do
                    if(troopVo.arriveTime < v.arriveTime or (troopVo.arriveTime == v.arriveTime and troopVo.uid < v.uid) or (troopVo.arriveTime == v.arriveTime and troopVo.uid == v.uid and troopVo.troopID < v.troopID))then
                        table.insert(result, k, troopVo)
                        insertFlag = true
                        break
                    end
                end
                if(insertFlag == false)then
                    table.insert(result, troopVo)
                end
            end
        end
    end
    if(cityVo and cityVo.npc == 1)then
        local troopVo = serverWarLocalTroopVo:new()
        troopVo.name = getlocal("local_war_npc_name")
        troopVo.allianceName = getlocal(cityVo.cfg.name)
        table.insert(result, troopVo)
    end
    return result
end

--获取城外所有进攻者的列表
--按照到达时间和uid和troopID排序
function serverWarLocalFightVoApi:getAttackersInCity(cityID)
    local cityVo = self:getCity(cityID)
    local result = {}
    if(cityVo)then
        for id, troopVo in pairs(self.troopList) do
            if(troopVo.canMoveTime <= base.serverTime and troopVo.arriveTime <= base.serverTime and troopVo.cityID == cityID and troopVo.allianceID ~= cityVo.allianceID)then
                local insertFlag = false
                for k, v in pairs(result) do
                    if(troopVo.arriveTime < v.arriveTime or (troopVo.arriveTime == v.arriveTime and troopVo.uid < v.uid) or (troopVo.arriveTime == v.arriveTime and troopVo.uid == v.uid and troopVo.troopID < v.troopID))then
                        table.insert(result, k, troopVo)
                        insertFlag = true
                        break
                    end
                end
                if(insertFlag == false)then
                    table.insert(result, troopVo)
                end
            end
        end
        return result
    else
        return result
    end
end

--检测城市是否在战斗状态
--只要城外有进攻者存在就算是战斗状态
function serverWarLocalFightVoApi:checkCityInWar(cityID)
    if(base.serverTime < self:getStartTime())then
        return false
    end
    local cityVo = self:getCity(cityID)
    local result = {}
    if(cityVo)then
        for id, troopVo in pairs(self.troopList) do
            if(troopVo.canMoveTime <= base.serverTime and troopVo.arriveTime <= base.serverTime and troopVo.cityID == cityID and troopVo.allianceID ~= cityVo.allianceID)then
                return true
            end
        end
        return false
    else
        return false
    end
end

--获取本次区域战开启的时间戳
function serverWarLocalFightVoApi:getStartTime()
    return self.startTime
end

--检查某个城市是否可以过去
--param cityID: 要去的城市ID
--param troopID: 玩家三支部队中的哪一支
--return 0: 可以出发
--return 1: 玩家死了, 处于无法移动的状态
--return 2: 玩家正在路上, 无法移动
--return 3: 要去的城市与玩家当前城市不相邻
--return 4: 围城的部队无法向非友方城市撤退
--return 5: 没有设置部队或者不是参赛选手
--return 6: 当前就在这个城
--return 7: 不能去主基地
--return 8: 后端报错，移动锁定一段时间
function serverWarLocalFightVoApi:checkCityCanReach(cityID, troopID)
    local selfTroops = self:getSelfTroops()
    if(selfTroops == nil or selfTroops[troopID] == nil)then
        return 5
    end
    local troopVo = selfTroops[troopID]
    if(troopVo.canMoveTime > base.serverTime)then
        return 1
    end
    if(troopVo.arriveTime > base.serverTime)then
        return 2
    end
    if(troopVo.cityID == cityID)then
        return 6
    end
    if(self.blockMoveTs and base.serverTime < self.blockMoveTs)then
        return 8
    end
    if(self.blockMoveTb and self.blockMoveTb[troopID] and base.serverTime < self.blockMoveTb[troopID])then
        return 8
    end
    for k, baseID in pairs(self:getMapCfg().baseCityID) do
        if(baseID == cityID)then
            return 7
        end
    end
    local startCity = self:getCity(troopVo.cityID)
    local canReach = false
    for k, v in pairs(startCity.cfg.adjoin) do
        if(v == cityID)then
            if(startCity.cfg.roadType[k] == 2)then
                if(base.serverTime < self.startTime + serverWarLocalCfg.countryRoadTime)then
                    return 3
                else
                    canReach = true
                    break
                end
            else
                canReach = true
                break
            end
        end
    end
    if(canReach == false)then
        return 3
    end
    local targetCity = self:getCity(cityID)
    if(startCity.allianceID ~= troopVo.allianceID and targetCity.allianceID ~= troopVo.allianceID)then
        return 4
    end
    return 0
end

--检查某只部队是否在主基地
--return: true or false, true表示在主基地，false反之
function serverWarLocalFightVoApi:checkTroopInBase(troopID)
    local troopVo = self.selfTroops[troopID]
    if(troopVo == nil)then
        return true
    end
    for key, cityID in pairs(self:getMapCfg().baseCityID) do
        if(cityID == troopVo.cityID)then
            return true
        end
    end
    return false
end

--向后台发请求拉所有数据, 刷新本地数据
function serverWarLocalFightVoApi:refreshData(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if ret == true then
            if sData and sData.data then
                local serverData = sData.data.areaWarserver
                if(self.initFlag ~= true)then
                    self.initFlag = true
                    base:addNeedRefresh(self)
                    local function activeListener(event, data)
                        serverWarLocalFightVoApi:refreshData()
                    end
                    serverWarLocalFightVoApi.activeListener = activeListener
                    eventDispatcher:addEventListener("game.active", activeListener)
                end
                if(base.serverTime < self:getStartTime() - 30)then
                    self.dataExpireTime = self:getStartTime() - 30 + math.random(0, 30)
                    self.lastBattleTime = self.startTime
                elseif(base.serverTime < self.startTime + serverWarLocalCfg.maxBattleTime)then
                    self.dataExpireTime = base.serverTime + 60 + math.random() * 3 - 6
                    self.lastBattleTime = base.serverTime - base.serverTime % serverWarLocalCfg.cdTime
                else
                    self.dataExpireTime = base.serverTime + 864000
                    self.lastBattleTime = self.startTime + serverWarLocalCfg.maxBattleTime
                end
                if(serverData.userinfo)then
                    local userInfo = serverData.userinfo
                    self.gems = userInfo.gems or 0
                    self.gems = tonumber(self.gems)
                    self.role = userInfo.role or 0
                    self.role = tonumber(self.role)
                    self.buffList = {}
                    for buffID, v in pairs(serverWarLocalCfg.buffSkill) do
                        if(userInfo[buffID])then
                            self.buffList[buffID] = tonumber(userInfo[buffID])
                        else
                            self.buffList[buffID] = 0
                        end
                    end
                end
                if(#self.allianceList == 0)then
                    local tmpTb = {}
                    if(serverData.alliancesInfo)then
                        for id, value in pairs(serverData.alliancesInfo) do
                            local allianceVo = serverWarLocalAllianceVo:new()
                            allianceVo:init(value)
                            table.insert(self.allianceList, allianceVo)
                            table.insert(tmpTb, allianceVo)
                        end
                    end
                    local function sortFunc(a, b)
                        if(a.rankPoint == b.rankPoint)then
                            if(a.power == b.power)then
                                if(a.serverID == b.serverID)then
                                    return a.aid < b.aid
                                else
                                    return a.serverID < b.serverID
                                end
                            else
                                return a.power > b.power
                            end
                        else
                            return a.rankPoint > b.rankPoint
                        end
                    end
                    table.sort(tmpTb, sortFunc)
                    for k, allianceVo in pairs(tmpTb) do
                        allianceVo.side = k
                    end
                end
                local flag = false
                for id, vo in pairs(self.cityList) do
                    if(vo and vo.id)then
                        flag = true
                        break
                    end
                end
                if(flag == false)then
                    for id, cityCfg in pairs(self:getMapCfg().cityCfg) do
                        local cityVo = serverWarLocalCityVo:new()
                        cityVo:init(cityCfg)
                        self.cityList[id] = cityVo
                    end
                end
                local sortTb = {}
                if(serverData.placesInfo)then
                    local eventTb = {}
                    for cityID, cityData in pairs(serverData.placesInfo) do
                        if(self.cityList[cityID])then
                            self.cityList[cityID].allianceID = cityData[1] or 0
                            self.cityList[cityID].npc = tonumber(cityData[2]) or 0
                            self.cityList[cityID].hp = tonumber(cityData[3]) or 100
                            table.insert(eventTb, self.cityList[cityID])
                            for key, baseID in pairs(self:getMapCfg().baseCityID) do
                                if(cityID == baseID)then
                                    sortTb[key] = self.cityList[cityID].allianceID
                                    break
                                end
                            end
                        end
                    end
                    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "city", data = eventTb})
                end
                if(#sortTb > 0)then
                    local function sortFunc(a, b)
                        for k, id in pairs(sortTb) do
                            if(id == a.id)then
                                return true
                            elseif(id == b.id)then
                                return false
                            end
                        end
                        return true
                    end
                    table.sort(self.allianceList, sortFunc)
                end
                if(serverData.usersActionInfo)then
                    local eventTb = {}
                    for key, value in pairs(serverData.usersActionInfo) do
                        local uid = tonumber(value[1])
                        local serverID = tonumber(value[9])
                        local troopID = tonumber(value[10])
                        local id = serverID.."-"..uid.."-"..troopID
                        if(self.troopList[id] == nil)then
                            local troopVo = serverWarLocalTroopVo:new()
                            self.troopList[id] = troopVo
                            if(serverID == tonumber(base.curZoneID) and uid == playerVoApi:getUid())then
                                self.selfTroops[troopID] = troopVo
                            end
                        end
                        self.troopList[id]:init(value)
                        table.insert(eventTb, self.troopList[id])
                    end
                    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "troop", data = eventTb})
                end
                if(serverData.command and type(serverData.command) == "table")then
                    self.order = {}
                    for k, v in pairs(serverData.command) do
                        if(v[1] and self.cityList[v[1]] and type(v[2]) == "number")then
                            self.order[k] = {v[1], v[2]}
                        end
                    end
                    local eventTb = self.order
                    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "order", data = eventTb})
                end
                if(serverData.battlePointInfo)then
                    for allianceID, point in pairs(serverData.battlePointInfo) do
                        self.pointTb[allianceID] = tonumber(point)
                    end
                    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "point"})
                end
                if(serverData.battleTasks)then
                    for allianceID, task in pairs(serverData.battleTasks) do
                        if(allianceID == "et")then
                            self.taskExpireTime = tonumber(task)
                        else
                            self.taskList[allianceID] = {}
                            if(task[1])then
                                self.taskList[allianceID][1] = tostring(task[1])
                            end
                            if(task[2])then
                                self.taskList[allianceID][2] = tonumber(task[2])
                            end
                        end
                    end
                    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "task"})
                end
                self:setTroopsData(serverData)
                if(serverData.over)then
                    self:over(serverData.over)
                else
                    self.endFlag = false
                end
            end
            if(callback)then
                callback()
            end
        else
            self.dataExpireTime = base.serverTime + 30
        end
    end
    local isShowLoading
    if(#self.allianceList == 0)then
        isShowLoading = true
    else
        isShowLoading = false
    end
    socketHelper2:serverWarLocalInit(playerVoApi:getPlayerAid(), self.battleID, self.groupID, onRequestEnd, isShowLoading)
end

--向目标城市移动
--param targetID: 要去的城市ID
--param troopID: 哪只部队
function serverWarLocalFightVoApi:move(targetID, troopID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if ret == true then
            self.blockMoveTb[troopID] = 0
            if sData and sData.data and sData.data.areaWarserver then
                local serverData = sData.data.areaWarserver
                if(serverData.over)then
                    self:over(serverData.over)
                    do return end
                end
                local troopData = serverData.usersActionInfo[1]
                local troopVo = self:getSelfTroops()[troopID]
                troopVo:init(troopData)
                if(callback)then
                    callback()
                end
            end
        else
            self.blockMoveTs = base.serverTime + 5
        end
    end
    self.blockMoveTb[troopID] = base.serverTime + 5
    socketHelper2:serverWarLocalMove(playerVoApi:getPlayerAid(), self.battleID, self.groupID, targetID, troopID, onRequestEnd)
end

--复活
--param troopID: 哪只部队
function serverWarLocalFightVoApi:revive(troopID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if(ret == true)then
            local serverData = sData.data.areaWarserver
            if(serverData.over)then
                self:over(serverData.over)
                do return end
            end
            if(serverData.usersActionInfo and serverData.usersActionInfo[1])then
                self:getSelfTroops()[troopID]:init(serverData.usersActionInfo[1])
                eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "troop", data = {self:getSelfTroops()[troopID]}})
            end
            if(serverData.userinfo)then
                local userInfo = serverData.userinfo
                self.gems = userInfo.gems or 0
                self.gems = tonumber(self.gems)
                self.role = userInfo.role or 0
                self.role = tonumber(self.role)
                self.buffList = {}
                for buffID, v in pairs(serverWarLocalCfg.buffSkill) do
                    if(userInfo[buffID])then
                        self.buffList[buffID] = tonumber(userInfo[buffID])
                    else
                        self.buffList[buffID] = 0
                    end
                end
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper2:serverWarLocalRevive(playerVoApi:getPlayerAid(), self.battleID, self.groupID, troopID, onRequestEnd)
end

--发送指挥命令
--param cityID: 指令所指向的城市
--param type: 指令类型
function serverWarLocalFightVoApi:sendOrder(cityID, type, callback)
    local flag = false
    for k, v in pairs(self.order) do
        if(v[1] == cityID)then
            v[2] = type
            flag = true
            break
        end
    end
    if(flag == false)then
        table.insert(self.order, {cityID, type})
    end
    if(#self.order > 2)then
        table.remove(self.order, 1)
    end
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if(ret == true)then
            local serverData = sData.data.areaWarserver
            if(serverData.over)then
                self:over(serverData.over)
                do return end
            end
            if(callback)then
                callback()
            end
        end
    end
    socketHelper2:serverWarLocalOrder(playerVoApi:getPlayerAid(), self.battleID, self.groupID, self.order, onRequestEnd)
end

function serverWarLocalFightVoApi:buyBuff(buffID, callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if(ret == true)then
            if sData and sData.data and sData.data.areaWarserver then
                local serverData = sData.data.areaWarserver
                if(serverData.userinfo)then
                    local userInfo = serverData.userinfo
                    self.gems = userInfo.gems or 0
                    self.gems = tonumber(self.gems)
                    self.role = userInfo.role or 0
                    self.role = tonumber(self.role)
                    self.buffList = {}
                    for buffID, v in pairs(serverWarLocalCfg.buffSkill) do
                        if(userInfo[buffID])then
                            self.buffList[buffID] = tonumber(userInfo[buffID])
                        else
                            self.buffList[buffID] = 0
                        end
                    end
                end
                if(callback)then
                    callback()
                end
            end
        end
    end
    socketHelper2:serverWarLocalBuyBuff(playerVoApi:getPlayerAid(), self.battleID, self.groupID, buffID, onRequestEnd)
end

function serverWarLocalFightVoApi:refreshTroops(callback)
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData2(data)
        if(ret == true)then
            if sData and sData.data and sData.data.areaWarserver then
                local serverData = sData.data.areaWarserver
                self:setTroopsData(serverData)
                if(callback)then
                    callback()
                end
            end
        end
    end
    socketHelper2:serverWarLocalTroop(playerVoApi:getPlayerAid(), self.battleID, self.groupID, onRequestEnd)
end

function serverWarLocalFightVoApi:setTroopsData(troopsData)
    if troopsData then
        if(troopsData.troops)then
            if SizeOfTable(troopsData.troops) > 0 then
                local skinTb = troopsData.skin or {}
                for i = 1, 3 do
                    local tType = i + 26
                    local v = troopsData.troops[i]
                    if v == nil then
                        v = troopsData.troops[tostring(i)]
                    end
                    local tskin = skinTb[i]
                    if tskin == nil then
                        tskin = skinTb[tostring(i)]
                    end
                    if v and SizeOfTable(v) > 0 and self:checkTroopInBase(i) == false then
                        for m, n in pairs(v) do
                            if n and n[1] and n[2] then
                                local tid = (tonumber(n[1]) or tonumber(RemoveFirstChar(n[1])))
                                tankVoApi:setTanksByType(tType, m, tid, tonumber(n[2]))
                            else
                                tankVoApi:deleteTanksTbByType(tType, m)
                            end
                        end
                        tankSkinVoApi:setTankSkinListByBattleType(tType, tskin)
                    else
                        tankVoApi:clearTanksTbByType(tType)
                    end
                end
            else
                for i = 1, 3 do
                    local tType = i + 26
                    tankVoApi:clearTanksTbByType(tType)
                end
            end
        end
        if(troopsData.hero)then
            -- if SizeOfTable(troopsData.hero)>0 then
            for i = 1, 3 do
                local v = troopsData.hero[i]
                if v == nil then
                    v = troopsData.hero[tostring(i)]
                end
                if v and SizeOfTable(v) > 0 and self:checkTroopInBase(i) == false then
                    heroVoApi:setServerWarLocalCurHeroList(i, v)
                else
                    -- heroVoApi:deleteServerWarLocalCurTroopsByIndex(i)
                    local heroList = G_clone(heroVoApi:getServerWarLocalHeroList(i))
                    heroVoApi:setServerWarLocalCurHeroList(i, heroList)
                end
            end
            -- else
            -- heroVoApi:clearServerWarLocalCurTroops()
            -- end
        end
        --AI部队数据
        if(troopsData.aitroops)then
            for i = 1, 3 do
                local v = troopsData.aitroops[i]
                if v == nil then
                    v = troopsData.aitroops[tostring(i)]
                end
                if v and SizeOfTable(v) > 0 and self:checkTroopInBase(i) == false then
                    AITroopsFleetVoApi:setServerWarLocalCurAITroopsList(i, v)
                else
                    local aitroops = G_clone(AITroopsFleetVoApi:getServerWarLocalAITroopsList(i))
                    AITroopsFleetVoApi:setServerWarLocalCurAITroopsList(i, aitroops)
                end
            end
        end
        
        if troopsData.equip then
            for i = 1, 3 do
                local emblemId = troopsData.equip[i]
                if emblemId == nil then
                    emblemId = troopsData.equip[tostring(i)]
                end
                local tType = 26 + i
                if self:checkTroopInBase(i) == false then
                    emblemVoApi:setBattleEquip(tType, emblemId)
                else
                    emblemId = emblemVoApi:getBattleEquip(tType - 3)
                    emblemVoApi:setBattleEquip(tType, emblemId)
                end
            end
        end
        if troopsData.plane then
            for i = 1, 3 do
                local planePos = troopsData.plane[i]
                if planePos == nil then
                    planePos = troopsData.plane[tostring(i)]
                end
                local tType = 26 + i
                if self:checkTroopInBase(i) == false then
                    planeVoApi:setBattleEquip(tType, planePos)
                else
                    planePos = planeVoApi:getBattleEquip(tType - 3)
                    planeVoApi:setBattleEquip(tType, planePos)
                end
            end
        end
        if troopsData.ap then
            for k = 1, 3 do
                local airshipId = troopsData.ap[k]
                if airshipId == nil then
                    airshipId = troopsData.ap[tostring(k)]
                end
                local tType = 26 + k
                if self:checkTroopInBase(k) == false then
                    airShipVoApi:setBattleEquip(tType, airshipId)
                else
                    airshipId = airShipVoApi:getBattleEquip(tType - 3)
                    airShipVoApi:setBattleEquip(tType, airshipId)
                end
            end
        end
    end
end

--战斗是否已经结束
function serverWarLocalFightVoApi:checkIsEnd()
    return self.endFlag
end

--后台报了错误码
--param code: 错误码
function serverWarLocalFightVoApi:serverError(code)
    self.dataExpireTime = 0
    local localCode = 0 - code
    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage"..localCode), 30)
end

--处理后台的推送请求
function serverWarLocalFightVoApi:receiveServerPush(data)
    if(data.bts)then
        -- local lastTime = tonumber(data.bts)
        -- if base.serverTime<lastTime then
        -- self.lastBattleTimeTmp=lastTime
        -- else
        -- self.lastBattleTime=lastTime
        -- self.lastBattleTimeTmp=nil
        -- end
        self.lastBattleTime = data.bts
    end
    if(data.usersActionInfo)then
        local eventTb = {}
        for k, v in pairs(data.usersActionInfo) do
            local uid = v[1]
            local serverID = v[9]
            local troopID = v[10]
            local id = serverID.."-"..uid.."-"..troopID
            if(self.troopList[id] == nil)then
                local troopVo = serverWarLocalTroopVo:new()
                self.troopList[id] = troopVo
                if(serverID == tonumber(base.curZoneID) and uid == playerVoApi:getUid())then
                    self.selfTroops[troopID] = troopVo
                end
            end
            self.troopList[id]:init(v)
            table.insert(eventTb, self.troopList[id])
        end
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "troop", data = eventTb})
    end
    if(data.placesInfo)then
        local eventTb = {}
        for cityID, cityData in pairs(data.placesInfo) do
            if(self.cityList[cityID])then
                self.cityList[cityID].allianceID = cityData[1] or 0
                self.cityList[cityID].npc = tonumber(cityData[2]) or 0
                self.cityList[cityID].hp = tonumber(cityData[3]) or 100
                table.insert(eventTb, self.cityList[cityID])
            end
        end
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "city", data = eventTb})
    end
    if(data.command and type(data.command) == "table")then
        self.order = {}
        for k, v in pairs(data.command) do
            if(v[1] and self.cityList[v[1]] and type(v[2]) == "number")then
                self.order[k] = {v[1], v[2]}
            end
        end
        local eventTb = self.order
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "order", data = eventTb})
    end
    if(data.battlePointInfo)then
        for allianceID, point in pairs(data.battlePointInfo) do
            self.pointTb[allianceID] = tonumber(point)
        end
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "point"})
    end
    if(data.battleTasks)then
        for allianceID, task in pairs(data.battleTasks) do
            if(allianceID == "et")then
                self.taskExpireTime = tonumber(task)
            else
                self.taskList[allianceID] = {}
                if(task[1])then
                    self.taskList[allianceID][1] = tostring(task[1])
                end
                if(task[2])then
                    self.taskList[allianceID][2] = tonumber(task[2])
                end
            end
        end
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "task"})
    end
    self:setTroopsData(data)
    if(data.bossKilled)then
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "boss", data = data.bossKilled})
    end
    if(data.over)then
        self:over(data.over)
    end
end

function serverWarLocalFightVoApi:over(data)
    if(data.battlePointInfo)then
        for allianceID, point in pairs(data.battlePointInfo) do
            self.pointTb[allianceID] = tonumber(point)
        end
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "point"})
    end
    if(serverWarLocalMapScene and serverWarLocalMapScene.isShow and self.endFlag == false)then
        local endTs
        if(data.ts and tonumber(data.ts) > 0)then
            endTs = tonumber(data.ts)
        else
            endTs = base.serverTime
        end
        require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalResultSmallDialog"
        local sd = serverWarLocalResultSmallDialog:new(data.winner, endTs)
        sd:init(serverWarLocalMapScene.layerNum + 1)
        serverWarLocalVoApi:getInitData(callback, false, 1)
    end
    self.endFlag = true
    eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "over"})
end

--获取下回合战斗的时间戳
function serverWarLocalFightVoApi:getNextBattleTime()
    return self.lastBattleTime + 20
end

function serverWarLocalFightVoApi:isBGroupBattleing()
    local weets = G_getWeeTs(base.serverTime)
    local bgroupBattleSt = weets + serverWarLocalCfg.startWarTime["b"][1] * 3600 + serverWarLocalCfg.startWarTime["b"][2] * 60 --b组战斗开始时间
    local bgroupBattleEt = bgroupBattleSt + serverWarLocalCfg.maxBattleTime --b组战斗结束时间
    if base.serverTime >= bgroupBattleSt and base.serverTime <= bgroupBattleEt then
        return true
    end
    return false
end

--断开跨服连接
function serverWarLocalFightVoApi:disconnectSocket2()
    require "luascript/script/netapi/socketHelper2"
    socketHelper2:disConnect()
    socketHelper2:dispose()
    self.connected = nil
end

--tick无需解释
function serverWarLocalFightVoApi:tick()
    if(self.endFlag or self.connected ~= true)then
        do return end
    end
    if self.groupID and self.groupID == "a" and serverWarLocalFightVoApi:isBGroupBattleing() == true then
        do return end
    end
    if self.lastBattleTime > 0 then
        if(base.serverTime < self:getStartTime() - 30)then
            self.lastBattleTime = self.startTime
        elseif(base.serverTime < self.startTime + serverWarLocalCfg.maxBattleTime)then
            self.lastBattleTime = base.serverTime - base.serverTime % serverWarLocalCfg.cdTime
        else
            self.lastBattleTime = self.startTime + serverWarLocalCfg.maxBattleTime
        end
    end
    -- -- 到达最近战斗时间，更新最近战斗时间
    -- if self.lastBattleTimeTmp~=nil and base.serverTime>=self.lastBattleTimeTmp then
    -- self.lastBattleTime=self.lastBattleTimeTmp
    -- self.lastBattleTimeTmp=nil
    -- end
    if(base.serverTime >= self.dataExpireTime)then
        self:refreshData()
    end
    if(base.serverTime > self:getNextBattleTime())then
        if(self.dataExpireTime > self.lastBattleTime + 25)then
            self.dataExpireTime = self.lastBattleTime + 25
        end
    end
    local eventTroopTb = {}
    local eventCityTb = {}
    for id, troopVo in pairs(self.troopList) do
        if(troopVo.arriveTime == base.serverTime or troopVo.canMoveTime == base.serverTime)then
            table.insert(eventTroopTb, troopVo)
            local city = self:getCity(troopVo.cityID)
            table.insert(eventCityTb, city)
        end
    end
    if(#eventTroopTb > 0)then
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "troop", data = eventTroopTb})
    end
    if(#eventCityTb > 0)then
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "city", data = eventCityTb})
    end
    if(base.serverTime == self:getStartTime() + serverWarLocalCfg.countryRoadTime)then
        eventDispatcher:dispatchEvent("serverWarLocal.battle", {type = "road"})
    end
end

function serverWarLocalFightVoApi:clear()
    base:removeFromNeedRefresh(self)
    self.battleID = 0
    self.groupID = 0
    self.dataExpireTime = 0
    self.initFlag = nil
    self.endFlag = false
    self.battleData = nil
    self.cityList = {}
    self.troopList = {}
    self.allianceList = {}
    self.startTime = 0
    self.selfTroops = {}
    self.lastBattleTime = 0
    self.order = {}
    self.buffData = {}
    self.gems = 0
    self.role = 1
    self.mapCfg = nil
    self.pointTb = {}
    self.buffList = {}
    self.taskList = {}
    self.order = {}
    self.taskExpireTime = 0
    self.connected = false
    self.blockMoveTs = 0
    self.blockMoveTb = {}
    self.lastBattleTimeTmp = nil
    eventDispatcher:removeEventListener("game.active", serverWarLocalFightVoApi.activeListener)
end
