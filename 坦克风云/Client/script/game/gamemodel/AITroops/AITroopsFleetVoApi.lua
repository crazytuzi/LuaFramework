--AI部队所有战斗设置部队相关
AITroopsFleetVoApi = {
    stats = {d = {}, m = {}, a = {}, w = {}, l = {}}, --各种队列状态
    troopsTb = {0, 0, 0, 0, 0, 0}, --设置部队时缓存列表
    defTroops = {0, 0, 0, 0, 0, 0},
    arenaTroops = {0, 0, 0, 0, 0, 0},
    allianceTroops = {0, 0, 0, 0, 0, 0},
    serverWarTroop1 = {0, 0, 0, 0, 0, 0}, --跨服个人战AI第一场
    serverWarTroop2 = {0, 0, 0, 0, 0, 0}, --跨服个人战英雄第二场
    serverWarTroop3 = {0, 0, 0, 0, 0, 0}, --跨服个人战英雄第三场
    serverWarTeamTroops = {0, 0, 0, 0, 0, 0}, --跨服军团战英雄
    bossbattleTroops = {0, 0, 0, 0, 0, 0}, --世界boss
    worldWarTroop1 = {0, 0, 0, 0, 0, 0}, --世界争霸AI部队一
    worldWarTroop2 = {0, 0, 0, 0, 0, 0}, --世界争霸AI部队二
    worldWarTroop3 = {0, 0, 0, 0, 0, 0}, --世界争霸AI部队三
    localWarTroops = {0, 0, 0, 0, 0, 0}, --区域战预设AI
    localWarCurTroops = {0, 0, 0, 0, 0, 0}, --区域战当前AI
    swAttackTroops = {0, 0, 0, 0, 0, 0}, --超级武器攻击AI
    swDefenceTroops = {0, 0, 0, 0, 0, 0}, --超级武器防守AI
    platWarTroop1 = {0, 0, 0, 0, 0, 0}, --平台战AI部队一
    platWarTroop2 = {0, 0, 0, 0, 0, 0}, --平台战AI部队二
    platWarTroop3 = {0, 0, 0, 0, 0, 0}, --平台战AI部队三
    serverWarLocalTroop1 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队一
    serverWarLocalTroop2 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队二
    serverWarLocalTroop3 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队三
    serverWarLocalCurTroop1 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队现状一
    serverWarLocalCurTroop2 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队现状二
    serverWarLocalCurTroop3 = {0, 0, 0, 0, 0, 0}, --群雄争霸AI部队现状三
    allianceWar2Troops = {0, 0, 0, 0, 0, 0}, --新军团战预设AI
    allianceWar2CurTroops = {0, 0, 0, 0, 0, 0}, --新军团战当前AI
    newYearBossTroops = {0, 0, 0, 0, 0, 0}, --除夕活动攻击bossAI
    dimensionalWarTroops = {0, 0, 0, 0, 0, 0}, --异元战场报名AI
    dimensionalWarTroopsData = {0, 0, 0, 0, 0, 0}, --异元战场报名AI数据，hid-品阶-等级
    serverWarTeamCurTroops = {0, 0, 0, 0, 0, 0}, --跨服军团战当前AI
    championshipWarPersonalAITroops = {0, 0, 0, 0, 0, 0}, --军团锦标赛个人战AI部队
    championshipWarAITroops = {0, 0, 0, 0, 0, 0}, --军团锦标赛军团战AI部队
}

--显示选择出战AI部队的页面
function AITroopsFleetVoApi:showSelectAITroopsDialog(battleType, layerNum, callBack, cid)
    require "luascript/script/game/scene/gamedialog/AITroops/selectAITroopsDialog"
    selectAITroopsDialog:showSelectAITroopsDialog(battleType, layerNum, callBack, cid)
end

--可以设置AI部队的部队数量
function AITroopsFleetVoApi:AITroopsEquipLimitNum()
    local aiTroopsCfg = AITroopsVoApi:getModelCfg()
    return aiTroopsCfg.aiTroopsEquipLimit
end

function AITroopsFleetVoApi:setAITroopsByPos(pos, atid, battleType)
    self.troopsTb[pos] = atid
    self:syncAITroopsByPos(pos, atid, battleType)
end

function AITroopsFleetVoApi:clearAITroops()
    self.troopsTb = {0, 0, 0, 0, 0, 0}
end

function AITroopsFleetVoApi:getAITroopsTb()
    return self.troopsTb
end

function AITroopsFleetVoApi:setAITroopsTb(tb)
    if tb ~= nil then
        self.troopsTb = G_clone(tb)
    end
end

function AITroopsFleetVoApi:isHaveAITroops()
    local ishave = false
    for k, v in pairs(self.troopsTb) do
        if v and v ~= 0 and v ~= "" then
            ishave = true
        end
    end
    return ishave
end

function AITroopsFleetVoApi:deleteAITroopsByPos(pos, battleType)
    self.troopsTb[pos] = 0
    self:syncAITroopsByPos(pos, 0, battleType)
end

function AITroopsFleetVoApi:syncAITroopsByPos(pos, atid, battleType)
    if battleType then
        if battleType == 7 or battleType == 8 or battleType == 9 then
            self:setServerWarAITroopsByIndex(battleType - 6, pos, atid)
        elseif battleType == 10 then
            self:setServerWarTeamAITroopsByPos(pos, atid)
        elseif battleType == 13 or battleType == 14 or battleType == 15 then
            self:setWorldWarAITroopsByIndex(battleType - 12, pos, atid)
        elseif battleType == 17 then
            self:setLocalWarAITroopsByPos(pos, atid)
        elseif battleType == 18 then
            self:setLocalWarCurAITroopsByPos(pos, atid)
        elseif battleType == 21 or battleType == 22 or battleType == 23 then
            self:setPlatWarAITroopsByIndex(battleType - 20, pos, atid)
        elseif battleType == 24 or battleType == 25 or battleType == 26 then
            self:setServerWarLocalAITroopsByIndex(battleType - 23, pos, atid)
        elseif battleType == 27 or battleType == 28 or battleType == 29 then
            self:setServerWarLocalCurAITroopsByIndex(battleType - 26, pos, atid)
        elseif battleType == 33 then
            self:setDimensionalWarAITroopsByPos(pos, atid)
        elseif battleType == 34 then
            self:setServerWarTeamCurAITroopsByPos(pos, atid)
        elseif battleType == 35 or battleType == 36 then -- 领土争夺战
            ltzdzFightApi:setAITroopsByPos(pos, atid, battleType)
        elseif battleType == 38 then
            self:setChampionshipWarPersonalAITroopsByPos(pos, atid)
        elseif battleType == 39 then
            self:setChampionshipWarAITroopsByPos(pos, atid)
        end
    end
end

function AITroopsFleetVoApi:getAITroopsByType(battleType)
    if battleType == 1 then --防守部队
        return self:getDefAITroopsList()
    elseif battleType == 5 then --军事演习
        return self:getArenaAITroopsList()
    elseif battleType == 10 then --军团跨服战
        return self:getServerWarTeamAITroopsList()
    elseif battleType == 12 then --世界boss
        return self:getBossAITroopsList()
    elseif battleType == 7 or battleType == 8 or battleType == 9 then
        return self:getServerWarAITroopsList(battleType - 6)
    elseif battleType == 13 or battleType == 14 or battleType == 15 then
        return self:getWorldWarAITroopsList(battleType - 12)
    elseif battleType == 17 then
        return self:getLocalWarAITroopsList()
    elseif battleType == 18 then
        return self:getLocalWarCurAITroopsList()
    elseif battleType == 20 then --超级武器掠夺
        return self:getSWDefenceAITroopsList()
    elseif battleType == 21 or battleType == 22 or battleType == 23 then
        return self:getPlatWarAITroopsList(battleType - 20)
    elseif battleType == 24 or battleType == 25 or battleType == 26 then
        return self:getServerWarLocalAITroopsList(battleType - 23)
    elseif battleType == 27 or battleType == 28 or battleType == 29 then
        return self:getServerWarLocalCurAITroopsList(battleType - 26)
    elseif battleType == 30 then --夕兽降临活动
        return self:getNewYearBossAITroopsList()
    elseif battleType == 31 then --新版军团战当前AI部队
        return self:getAllianceWar2CurAITroopsList()
    elseif battleType == 32 then --新版军团战
        return self:getAllianceWar2AITroopsList()
    elseif battleType == 33 then
        return self:getDimensionalWarAITroopsList()
    elseif battleType == 34 then
        return self:getServerWarTeamCurAITroopsList()
    elseif battleType == 35 or battleType == 36 then -- 领土争夺战 防守
        return ltzdzFightApi:getAITroopsTbByType(battleType)
    elseif battleType == 38 then
        return self:getChampionshipWarPersonalAITroopsTb()
    elseif battleType == 39 then
        return self:getChampionshipWarAITroopsTb()
    else
        return self.troopsTb
    end
end

--获取当前可以用的AI部队列表
function AITroopsFleetVoApi:getCanUseAITroopsList(battleType, cid)
    if battleType == 35 or battleType == 36 then
        return ltzdzFightApi:getCanUseAITroopsList(battleType, cid)
    end
    local AITroopsTb = G_clone(AITroopsVoApi:getTroopsList())
    local idTb = G_clone(AITroopsVoApi:getTroopsIds())
    local tmpId
    for k, v in pairs(self.troopsTb) do
        local isMirror, arr = AITroopsVoApi:checkIsAITroopsMirror(v)
        if isMirror == true then
            tmpId = arr[1]
        else
            tmpId = v
        end
        for i, j in pairs(idTb) do
            if tostring(tmpId) == tostring(j) then
                table.remove(idTb, i)
                AITroopsTb[j] = nil
                break
            end
        end
    end
    local allTb = self:allAtkAITroops()
    for k, v in pairs(allTb) do
        for i, j in pairs(idTb) do
            if tostring(v) == tostring(j) then
                table.remove(idTb, i)
                AITroopsTb[j] = nil
                break
            end
        end
    end
    local notUseAITroopsTb = {} --不可用的AI部队
    if battleType == 7 or battleType == 8 or battleType == 9 then
        for k = 1, 3 do
            local tb = G_clone(self:getServerWarAITroopsList(k))
            for k, v in pairs(tb) do
                table.insert(notUseAITroopsTb, v)
            end
        end
    elseif battleType == 11 then
        notUseAITroopsTb = expeditionVoApi:getDeadAITroops()
    elseif battleType == 13 or battleType == 14 or battleType == 15 then
        for k = 1, 3 do
            local tb = G_clone(self:getWorldWarAITroopsList(k))
            for k, v in pairs(tb) do
                table.insert(notUseAITroopsTb, v)
            end
        end
    elseif battleType == 21 or battleType == 22 or battleType == 23 then
        for k = 1, 3 do
            local tb = G_clone(self:getPlatWarAITroopsList(k))
            for k, v in pairs(tb) do
                table.insert(notUseAITroopsTb, v)
            end
        end
    elseif battleType == 24 or battleType == 25 or battleType == 26 then
        for k = 1, 3 do
            local tb = G_clone(self:getServerWarLocalAITroopsList(k))
            for k, v in pairs(tb) do
                table.insert(notUseAITroopsTb, v)
            end
        end
    elseif battleType == 35 or battleType == 36 then
        
    end
    for k, v in pairs(notUseAITroopsTb) do
        local isMirror, arr = AITroopsVoApi:checkIsAITroopsMirror(v)
        if isMirror == true then
            tmpId = arr[1]
        else
            tmpId = v
        end
        for i, j in pairs(idTb) do
            if tostring(tmpId) == tostring(j) then
                table.remove(idTb, i)
                AITroopsTb[j] = nil
                break
            end
        end
    end
    local canUseTb = {}
    for k, v in pairs(idTb) do
        table.insert(canUseTb, AITroopsTb[v])
    end
    
    return canUseTb
end

function AITroopsFleetVoApi:syncStats(tb)
    --stats={d={},m={},a={},w={}},--各种队列状态 d防守，m军事演习，a进攻队列或异星矿场进攻，w超级武器抢夺防守部队
    self.stats = tb
end

--获取所有处于攻击状态的AI部队
function AITroopsFleetVoApi:allAtkAITroops()
    local tb = {}
    if self.stats then
        if self.stats.a ~= nil then
            for k, v in pairs(self.stats.a) do
                for i, j in pairs(v) do
                    table.insert(tb, j)
                end
            end
        end
        if self.stats.l ~= nil then
            for k, v in pairs(self.stats.l) do
                for i, j in pairs(v) do
                    table.insert(tb, j)
                end
            end
        end
    end
    return tb
end

--ai部队是否出征
function AITroopsFleetVoApi:getIsBattled(atid)
    if self.stats and self.stats.a then
        for k, v in pairs(self.stats.a) do
            for m, n in pairs(v) do
                if atid == n then
                    return true
                end
            end
        end
    end
    return false
end

function AITroopsFleetVoApi:setDefAITroopsList(tb)
    if tb ~= nil then
        if self.stats.d == nil then
            self.stats.d = {}
            self.stats.d[1] = {}
        end
        self.stats.d[1] = tb
        self.defTroops = tb
    end
end

--防守部队AI部队布置列表
function AITroopsFleetVoApi:getDefAITroopsList()
    local tmpDefTroops = {0, 0, 0, 0, 0, 0}
    if self.stats.d ~= nil and SizeOfTable(self.stats.d) > 0 then
        self.defTroops = self.stats.d[1]
        
        local tankTb = tankVoApi:getTemDefenseTanks()
        for k, v in pairs(tankTb) do
            if SizeOfTable(v) == 0 or (v[2] and v[2] == 0) then
                --当前位置没有坦克时，清空该位置的AI部队
                self.defTroops[k] = 0
            end
        end
        --除去出战的英雄
        tmpDefTroops = G_clone(self.defTroops)
        local tb = self:allAtkAITroops()
        if tb and SizeOfTable(tb) > 0 then
            for k, v in pairs(tb) do
                for m, n in pairs(tmpDefTroops) do
                    if v == n then
                        tmpDefTroops[m] = 0
                    end
                end
            end
        end
    end
    return tmpDefTroops
end

--军事演习AI部队
function AITroopsFleetVoApi:getArenaAITroopsList()
    if self.stats.m ~= nil and SizeOfTable(self.stats.m) > 0 then
        self.arenaTroops = self.stats.m[1]
    end
    return self.arenaTroops
end

function AITroopsFleetVoApi:setArenaAITroopsList(tb)
    if tb == nil then
        tb = {0, 0, 0, 0, 0, 0}
    end
    if self.stats.m == nil then
        self.stats.m = {}
        self.stats.m[1] = {}
    end
    self.stats.m[1] = tb
    self.arenaTroops = tb
end

--世界boss
function AITroopsFleetVoApi:getBossAITroopsList()
    return self.bossbattleTroops
end

function AITroopsFleetVoApi:setBossAITroopsList(tb)
    if tb == nil then
        tb = {0, 0, 0, 0, 0, 0}
    end
    self.bossbattleTroops = tb
end

function AITroopsFleetVoApi:getAllianceAITroopsList()
    if self.stats and self.stats.l ~= nil and SizeOfTable(self.stats.l) > 0 then
        self.allianceTroops = self.stats.l[1]
    end
    return self.allianceTroops
end

--跨服战某一场AI部队
function AITroopsFleetVoApi:getServerWarAITroopsList(index)
    if index and self["serverWarTroop"..index] then
        return self["serverWarTroop"..index]
    end
    return {0, 0, 0, 0, 0, 0}
end

function AITroopsFleetVoApi:setServerWarAITroopsList(index, aitroops)
    if index then
        self["serverWarTroop"..index] = {0, 0, 0, 0, 0, 0}
        if aitroops then
            for k, v in pairs(aitroops) do
                if v then
                    self["serverWarTroop"..index][k] = v
                end
            end
        end
    end
end
--跨服战某一场设置英雄
function AITroopsFleetVoApi:setServerWarAITroopsByIndex(index, pos, atid)
    if index then
        if pos and self["serverWarTroop"..index] then
            self["serverWarTroop"..index][pos] = atid
        end
    end
end

function AITroopsFleetVoApi:clearServerWarAITroops()
    self.serverWarTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarTroop3 = {0, 0, 0, 0, 0, 0}
end

--selectType ：选中的设置部队的类型，如果传了这个参数则取出刨去该支部队的所有Ai部队，如果没有传则取所有部队的AI部队
--传入selectType一般用于设置部队，不传一般用于设置部队最大战力
function AITroopsFleetVoApi:getServerWarUsedAITroops(selectType)
    local useTb = {}
    for k = 1, 3 do
        if (tonumber(selectType) or 0) ~= (k + 6) then
            local tb = self:getServerWarAITroopsList(k)
            for k, v in pairs(tb) do
                table.insert(useTb, v)
            end
        end
    end
    return useTb
end

--清空军团跨服战AI部队设置
function AITroopsFleetVoApi:clearServerWarTeamAITroops()
    self.serverWarTeamTroops = {0, 0, 0, 0, 0, 0}
end

--军团跨服战AI部队
function AITroopsFleetVoApi:getServerWarTeamAITroopsList()
    if self.serverWarTeamTroops then
        return self.serverWarTeamTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--军团跨服战AI部队
function AITroopsFleetVoApi:setServerWarTeamAITroopsList(aitroops)
    self.serverWarTeamTroops = aitroops
end

--军团跨服战AI部队
function AITroopsFleetVoApi:setServerWarTeamAITroopsByPos(pos, atid)
    if pos and self.serverWarTeamTroops then
        self.serverWarTeamTroops[pos] = atid
    else
        self.serverWarTeamTroops = {0, 0, 0, 0, 0, 0}
    end
end

--清空军团跨服战当前AI部队设置
function AITroopsFleetVoApi:clearServerWarTeamCurAITroops()
    self.serverWarTeamCurTroops = {0, 0, 0, 0, 0, 0}
end

--军团跨服战当前AI部队信息
function AITroopsFleetVoApi:getServerWarTeamCurAITroopsList()
    if self.serverWarTeamCurTroops then
        return self.serverWarTeamCurTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--军团跨服战当前AI部队信息
function AITroopsFleetVoApi:setServerWarTeamCurAITroopsList(aitroops)
    self.serverWarTeamCurTroops = aitroops
end

--军团跨服战当前AI部队信息
function AITroopsFleetVoApi:setServerWarTeamCurAITroopsByPos(pos, atid)
    if pos and self.serverWarTeamCurTroops then
        self.serverWarTeamCurTroops[pos] = atid
    else
        self.serverWarTeamCurTroops = {0, 0, 0, 0, 0, 0}
    end
end

--世界争霸某一场AI部队信息
function AITroopsFleetVoApi:getWorldWarAITroopsList(index)
    if index and self["worldWarTroop"..index] then
        return self["worldWarTroop"..index]
    end
    return {0, 0, 0, 0, 0, 0}
end

--世界争霸某一场设置AI部队
function AITroopsFleetVoApi:setWorldWarAITroopsList(index, aitroops)
    if index then
        self["worldWarTroop"..index] = {0, 0, 0, 0, 0, 0}
        if aitroops then
            for k, v in pairs(aitroops) do
                if v then
                    self["worldWarTroop"..index][k] = v
                end
            end
        end
    end
end

--世界争霸某一场设置AI部队
function AITroopsFleetVoApi:setWorldWarAITroopsByIndex(index, pos, atid)
    if index then
        if pos and self["worldWarTroop"..index] then
            self["worldWarTroop"..index][pos] = atid
        end
    end
end

--清空区域战AI部队设置
function AITroopsFleetVoApi:clearLocalWarAITroops()
    self.localWarTroops = {0, 0, 0, 0, 0, 0}
end

function AITroopsFleetVoApi:clearLocalWarCurAITroops()
    self.localWarCurTroops = {0, 0, 0, 0, 0, 0}
end

--军团区域战AI部队信息
function AITroopsFleetVoApi:getLocalWarAITroopsList()
    if self.localWarTroops then
        return self.localWarTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--军团区域战当前AI部队信息
function AITroopsFleetVoApi:getLocalWarCurAITroopsList()
    if self.localWarCurTroops then
        return self.localWarCurTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--军团区域战设置AI部队
function AITroopsFleetVoApi:setLocalWarAITroopsList(aitroops)
    self.localWarTroops = aitroops
end

--军团区域战设置当前AI部队
function AITroopsFleetVoApi:setLocalWarCurAITroopsList(aitroops)
    self.localWarCurTroops = aitroops
end

--区域战某一个位置设置AI部队
function AITroopsFleetVoApi:setLocalWarAITroopsByPos(pos, atid)
    if pos and self.localWarTroops then
        self.localWarTroops[pos] = atid
    else
        self.localWarTroops = {0, 0, 0, 0, 0, 0}
    end
end

--区域战当前某一个位置设置AI部队
function AITroopsFleetVoApi:setLocalWarCurAITroopsByPos(pos, atid)
    if pos and self.localWarCurTroops then
        self.localWarCurTroops[pos] = atid
    else
        self.localWarCurTroops = {0, 0, 0, 0, 0, 0}
    end
end

--清空超级武器防守部队AI部队设置
function AITroopsFleetVoApi:clearSWDefenceAITroops()
    self.swDefenceTroops = {0, 0, 0, 0, 0, 0}
end

--超级武器防守部队AI部队信息
function AITroopsFleetVoApi:getSWDefenceAITroopsList()
    if self.stats.w ~= nil and SizeOfTable(self.stats.w) > 0 then
        self.swDefenceTroops = self.stats.w[1]
    end
    if self.swDefenceTroops then
        return self.swDefenceTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--超级武器防守部队设置AI部队
function AITroopsFleetVoApi:setSWDefenceAITroopsList(aitroops)
    if aitroops then
        if self.stats.w == nil then
            self.stats.w = {}
        end
        if self.stats.w[1] == nil then
            self.stats.w[1] = {}
        end
        for k, v in pairs(aitroops) do
            if v and v ~= 0 and v ~= "" then
                self.swDefenceTroops[k] = v
                self.stats.w[1][k] = v
            else
                self.swDefenceTroops[k] = 0
                self.stats.w[1][k] = 0
            end
        end
    end
end

--超级武器防守部队某一个位置设置AI部队
function AITroopsFleetVoApi:setSWDefenceAITroopsByPos(pos, atid)
    if self.stats.w == nil or SizeOfTable(self.stats.w) == 0 then
        self.stats.w = {}
        self.stats.w[1] = {0, 0, 0, 0, 0, 0}
    end
    if pos and self.swDefenceTroops then
        self.swDefenceTroops[pos] = atid
        self.stats.w[1][pos] = atid
    else
        self.swDefenceTroops = {0, 0, 0, 0, 0, 0}
        self.stats.w[1] = {0, 0, 0, 0, 0, 0}
    end
end

--平台战某一场AI部队信息
function AITroopsFleetVoApi:getPlatWarAITroopsList(index)
    if index and self["platWarTroop"..index] then
        return self["platWarTroop"..index]
    end
    return {0, 0, 0, 0, 0, 0}
end

--平台战某一场设置AI部队
function AITroopsFleetVoApi:setPlatWarAITroopsList(index, heroList)
    if index then
        self["platWarTroop"..index] = {0, 0, 0, 0, 0, 0}
        if heroList then
            for k, v in pairs(heroList) do
                if v then
                    self["platWarTroop"..index][k] = v
                end
            end
        end
    end
end

--平台战某一场设置AI部队
function AITroopsFleetVoApi:setPlatWarAITroopsByIndex(index, pos, atid)
    if index then
        if pos and self["platWarTroop"..index] then
            self["platWarTroop"..index][pos] = atid
        end
    end
end

--群雄争霸某一场AI部队信息
function AITroopsFleetVoApi:getServerWarLocalAITroopsList(index)
    if index and self["serverWarLocalTroop"..index] then
        return self["serverWarLocalTroop"..index]
    end
    return {0, 0, 0, 0, 0, 0}
end

--群雄争霸某一场AI部队设置
function AITroopsFleetVoApi:setServerWarLocalAITroopsList(index, aitroops)
    if index then
        self["serverWarLocalTroop"..index] = {0, 0, 0, 0, 0, 0}
        if aitroops then
            for k, v in pairs(aitroops) do
                if v then
                    self["serverWarLocalTroop"..index][k] = v
                end
            end
        end
    end
end

--群雄争霸某一场设置AI部队
function AITroopsFleetVoApi:setServerWarLocalAITroopsByIndex(index, pos, atid)
    if index then
        if pos and self["serverWarLocalTroop"..index] then
            self["serverWarLocalTroop"..index][pos] = atid
        end
    end
end

--群雄争霸清空某一场的AI部队设置
function AITroopsFleetVoApi:deleteServerWarLocalAITroopsByIndex(index, pos)
    if index then
        if pos and self["serverWarLocalTroop"..index] then
            self["serverWarLocalTroop"..index][pos] = 0
        else
            self["serverWarLocalTroop"..index] = {0, 0, 0, 0, 0, 0}
        end
    end
end

--群雄争霸清空AI部队设置
function AITroopsFleetVoApi:clearServerWarLocalAITroops()
    self.serverWarLocalTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalTroop3 = {0, 0, 0, 0, 0, 0}
end

--群雄争霸某一场AI部队现状信息
function AITroopsFleetVoApi:getServerWarLocalCurAITroopsList(index)
    if index and self["serverWarLocalCurTroop"..index] then
        return self["serverWarLocalCurTroop"..index]
    end
    return {0, 0, 0, 0, 0, 0}
end

--群雄争霸某一场设置现状AI部队
function AITroopsFleetVoApi:setServerWarLocalCurAITroopsList(index, aitroops)
    if index then
        self["serverWarLocalCurTroop"..index] = {0, 0, 0, 0, 0, 0}
        if aitroops then
            for k, v in pairs(aitroops) do
                if v then
                    self["serverWarLocalCurTroop"..index][k] = v
                end
            end
        end
    end
end

--某一场设置现状AI部队
function AITroopsFleetVoApi:setServerWarLocalCurAITroopsByIndex(index, pos, atid)
    if index then
        if pos and self["serverWarLocalCurTroop"..index] then
            self["serverWarLocalCurTroop"..index][pos] = atid
        end
    end
end

--清空某一场的现状AI部队设置
function AITroopsFleetVoApi:deleteServerWarLocalCurAITroopsByIndex(index, pos)
    if index then
        if pos and self["serverWarLocalCurTroop"..index] then
            self["serverWarLocalCurTroop"..index][pos] = 0
        else
            self["serverWarLocalCurTroop"..index] = {0, 0, 0, 0, 0, 0}
        end
    end
end

--清空现状AI部队设置
function AITroopsFleetVoApi:clearServerWarLocalCurAITroops()
    self.serverWarLocalCurTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalCurTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalCurTroop3 = {0, 0, 0, 0, 0, 0}
end

--夕兽降临活动AI部队
function AITroopsFleetVoApi:getNewYearBossAITroopsList()
    return self.newYearBossTroops
end

--夕兽降临活动AI部队
function AITroopsFleetVoApi:setNewYearBossAITroopsList(tb)
    if tb == nil then
        tb = {0, 0, 0, 0, 0, 0}
    end
    self.newYearBossTroops = tb
end

--清空新军团战AI部队设置
function AITroopsFleetVoApi:clearAllianceWar2AITroops()
    self.allianceWar2Troops = {0, 0, 0, 0, 0, 0}
end

--新军团战AI部队信息
function AITroopsFleetVoApi:getAllianceWar2AITroopsList()
    if self.allianceWar2Troops then
        return self.allianceWar2Troops
    end
    return {0, 0, 0, 0, 0, 0}
end

--新军团战设置AI部队
function AITroopsFleetVoApi:setAllianceWar2AITroopsList(aitroops)
    if aitroops then
        for k, v in pairs(aitroops) do
            if v and v ~= 0 and v ~= "" then
                self.allianceWar2Troops[k] = v
            else
                self.allianceWar2Troops[k] = 0
            end
        end
    end
end

--新军团战某一个位置设置AI部队
function AITroopsFleetVoApi:setAllianceWar2AITroopsByPos(pos, atid)
    if pos and self.allianceWar2Troops then
        self.allianceWar2Troops[pos] = atid
    else
        self.allianceWar2Troops = {0, 0, 0, 0, 0, 0}
    end
end

--清空新军团战当前AI部队设置
function AITroopsFleetVoApi:clearAllianceWar2CurAITroops()
    self.allianceWar2CurTroops = {0, 0, 0, 0, 0, 0}
end

--新军团战当前AI部队信息
function AITroopsFleetVoApi:getAllianceWar2CurAITroopsList()
    if self.allianceWar2CurTroops then
        return self.allianceWar2CurTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--新军团战设置当前AI部队
function AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(aitroops)
    if aitroops then
        for k, v in pairs(aitroops) do
            if v and v ~= 0 and v ~= "" then
                self.allianceWar2CurTroops[k] = v
            else
                self.allianceWar2CurTroops[k] = 0
            end
        end
    end
end

--新军团战当前某一个位置设置AI部队
function AITroopsFleetVoApi:setAllianceWar2CurAITroopsByPos(pos, atid)
    if pos and self.allianceWar2CurTroops then
        self.allianceWar2CurTroops[pos] = atid
    else
        self.allianceWar2CurTroops = {0, 0, 0, 0, 0, 0}
    end
end

--获取异元战场设置AI部队
function AITroopsFleetVoApi:getDimensionalWarAITroopsList()
    if self.dimensionalWarTroops then
        return self.dimensionalWarTroops
    end
    return {0, 0, 0, 0, 0, 0}
end

--异元战场设置AI部队
function AITroopsFleetVoApi:setDimensionalWarAITroopsList(aitroops)
    if aitroops then
        for k, v in pairs(aitroops) do
            if v and v ~= 0 and v ~= "" then
                self.dimensionalWarTroops[k] = v
            else
                self.dimensionalWarTroops[k] = 0
            end
        end
    end
end

--异元战场某一个位置设置AI部队
function AITroopsFleetVoApi:setDimensionalWarAITroopsByPos(pos, atid)
    if pos and self.dimensionalWarTroops then
        self.dimensionalWarTroops[pos] = atid
    else
        self.dimensionalWarTroops = {0, 0, 0, 0, 0, 0}
    end
end

function AITroopsFleetVoApi:setChampionshipWarAITroopsByPos(pos, atid)
    if pos and self.championshipWarAITroops then
        self.championshipWarAITroops[pos] = atid
    else
        self.championshipWarAITroops = {0, 0, 0, 0, 0, 0}
    end
end

function AITroopsFleetVoApi:setChampionshipWarPersonalAITroopsByPos(pos, atid)
    if pos and self.championshipWarPersonalAITroops then
        self.championshipWarPersonalAITroops[pos] = atid
    else
        self.championshipWarPersonalAITroops = {0, 0, 0, 0, 0, 0}
    end
end

--设置军团锦标赛军团战AI部队数据
function AITroopsFleetVoApi:setChampionshipWarAITroopsTb(aitroops)
    if aitroops == nil or SizeOfTable(aitroops) == 0 then
        aitroops = {0, 0, 0, 0, 0, 0}
    end
    self.championshipWarAITroops = aitroops
end

--设置军团锦标赛个人战AI部队数据
function AITroopsFleetVoApi:setChampionshipWarPersonalAITroopsTb(aitroops)
    if aitroops == nil or SizeOfTable(aitroops) == 0 then
        aitroops = {0, 0, 0, 0, 0, 0}
    end
    self.championshipWarPersonalAITroops = aitroops
end

--获取军团锦标赛军团战AI部队数据
function AITroopsFleetVoApi:getChampionshipWarAITroopsTb()
    return self.championshipWarAITroops
end

--获取军团锦标赛个人战AI部队数据
function AITroopsFleetVoApi:getChampionshipWarPersonalAITroopsTb()
    return self.championshipWarPersonalAITroops
end

--清除军团锦标赛军团战AI部队数据
function AITroopsFleetVoApi:clearChampionshipWarAITroopsTb()
    self.championshipWarAITroops = {0, 0, 0, 0, 0, 0}
end

--清除军团锦标赛个人战AI部队数据
function AITroopsFleetVoApi:clearChampionshipWarPersonalAITroopsTb()
    self.championshipWarPersonalAITroops = {0, 0, 0, 0, 0, 0}
end

-- 两个位置交换AI部队
function AITroopsFleetVoApi:exchangeAITroopsByType(battleType, id1, id2)
    local tempTab = self:getAITroopsTb()
    local tab1 = tempTab[id1]
    tempTab[id1] = tempTab[id2]
    if battleType == 3 or battleType == 35 or battleType == 36 then
        self:setAITroopsByPos(id1, tempTab[id1], battleType)
        self:setAITroopsByPos(id2, tab1, battleType)
    end
    tempTab[id2] = tab1
end

function AITroopsFleetVoApi:getMatchAITroopsList(tb)
    if base.AITroopsSwitch == 0 then
        do return {0, 0, 0, 0, 0, 0} end
    end
    for k, v in pairs(self.troopsTb) do
        if SizeOfTable(tb[k]) == 0 then --如果此位置没有坦克部队，则要清空该位置的AI部队
            self:setAITroopsByPos(k, 0)
        end
    end
    local aitTb = {0, 0, 0, 0, 0, 0}
    for k, v in pairs(self.troopsTb) do
        local atid = AITroopsVoApi:getRealAITroopsId(v)
        aitTb[k] = atid
    end
    -- return self.troopsTb
    return aitTb
end

--发送请求时，没有部队不设置AI部队
--isSetTroops 不设置troops,只检测AI部队对应位置是否有部队，不在设置部队发请求时使用
function AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, tb, battleType, isSetTroops)
    if isSetTroops == nil then
        isSetTroops = true
    end
    local aitTb = {0, 0, 0, 0, 0, 0}
    if base.AITroopsSwitch == 0 then
        return aitTb
    end
    local tmpTb = {}
    if isSetTroops == true then
        for k, v in pairs(aitroops) do
            if SizeOfTable(tb[k]) == 0 then
                self:setAITroopsByPos(k, 0, battleType)
            end
        end
        tmpTb = aitroops
        -- return aitroops
    else
        local list = G_clone(aitroops)
        for k, v in pairs(list) do
            if SizeOfTable(tb[k]) == 0 then
                list[k] = 0
            end
        end
        tmpTb = list
        -- return list
    end
    for k, v in pairs(tmpTb) do
        local atid = AITroopsVoApi:getRealAITroopsId(v)
        aitTb[k] = atid
    end
    return aitTb
end

--AI部队是否完全一样
function AITroopsFleetVoApi:isSameAITroops(aitroops1, aitroops2)
    local isSame = true
    if aitroops1 and aitroops2 then
        for k, v in pairs(aitroops1) do
            if aitroops2[k] == nil then
                isSame = false
            elseif aitroops2[k] ~= v then
                local atid1, atid2 = v, aitroops2[k]
                local isMirror1, arr1 = AITroopsVoApi:checkIsAITroopsMirror(atid1)
                local isMirror2, arr2 = AITroopsVoApi:checkIsAITroopsMirror(atid2)
                if isMirror1 == true then
                    atid1 = arr1[1]
                end
                if isMirror2 == true then
                    atid2 = arr2[1]
                end
                if atid1 ~= atid2 then
                    isSame = false
                end
            end
        end
    end
    return isSame
end

--判断AI部队的可用列表里有没有不可以一起上阵的队伍
function AITroopsFleetVoApi:judgeAILimit( AITroopsTb,n,atid )
    local limitTb = AITroopsVoApi:getLimitTroopsCfg(atid)
    for i,j in pairs(AITroopsTb) do
        if i<n then
            for k,v in pairs(limitTb) do
                if v==j then
                    return false
                end
            end
        end
    end
    return true
end

--AI部队最大战力
function AITroopsFleetVoApi:bestAITroops(battleType, tanks)
    if base.AITroopsSwitch == 0 then
        do return {0, 0, 0, 0, 0, 0} end
    end
    local tankTb = tanks or tankVoApi:getTanksTbByType(battleType)
    
    local AITroopsTb = G_clone(AITroopsVoApi:getTroopsList())
    local idTb = G_clone(AITroopsVoApi:getTroopsIds())
    
    local allTb = self:allAtkAITroops()
    for k, v in pairs(allTb) do
        for i, j in pairs(idTb) do
            if tostring(v) == tostring(j) then
                table.remove(idTb, i)
                break
            end
        end
    end
    local notUseAITroopsTb = {}
    if battleType then
        if battleType == 7 or battleType == 8 or battleType == 9 then
            local selectId = battleType - 6
            for k = 1, 3 do
                if k ~= selectId then
                    local tb = G_clone(self:getServerWarAITroopsList(k))
                    for k, v in pairs(tb) do
                        table.insert(notUseAITroopsTb, v)
                    end
                end
            end
        elseif battleType == 11 then
            notUseAITroopsTb = expeditionVoApi:getDeadAITroops()
        elseif battleType == 13 or battleType == 14 or battleType == 15 then
            local selectId = battleType - 12
            for k = 1, 3 do
                if k ~= selectId then
                    local tb = G_clone(self:getWorldWarAITroopsList(k))
                    for k, v in pairs(tb) do
                        table.insert(notUseAITroopsTb, v)
                    end
                end
            end
        elseif battleType == 21 or battleType == 22 or battleType == 23 then
            local selectId = battleType - 20
            for k = 1, 3 do
                if k ~= selectId then
                    local tb = G_clone(self:getPlatWarAITroopsList(k))
                    for k, v in pairs(tb) do
                        table.insert(notUseAITroopsTb, v)
                    end
                end
                
            end
        elseif battleType == 24 or battleType == 25 or battleType == 26 then
            local selectId = battleType - 23
            for k = 1, 3 do
                if k ~= selectId then
                    local tb = G_clone(self:getServerWarLocalAITroopsList(k))
                    for k, v in pairs(tb) do
                        table.insert(notUseAITroopsTb, v)
                    end
                end
            end
        end
    end
    local aiTroopsCfg = AITroopsVoApi:getModelCfg()
    local aitroopType = aiTroopsCfg.aitroopType
    function sort(t1, t2)
        local vo1, vo2 = AITroopsTb[t1], AITroopsTb[t2]
        local tcfg1, tcfg2 = aitroopType[t1], aitroopType[t2]
        if vo1 and vo2 and vo1.getTroopsStrength and vo2.getTroopsStrength and tcfg1 and tcfg2 then
            local strength1, strength2 = vo1:getTroopsStrength(), vo2:getTroopsStrength()
            local id1, id2 = tonumber(RemoveFirstChar(t1)), tonumber(RemoveFirstChar(t2))
            local w1 = tcfg1.quality * 1000000 + strength1 * 100 + (10 - id1)
            local w2 = tcfg2.quality * 1000000 + strength2 * 100 + (10 - id2)
            return w1 > w2
        end
        return false
    end
    table.sort(idTb, sort)
    local tmpId
    for k, v in pairs(notUseAITroopsTb) do
        tmpId = AITroopsVoApi:getAITroopsId(v)
        for i, j in pairs(idTb) do
            if tostring(tmpId) == tostring(j) then
                table.remove(idTb, i)
                break
            end
        end
    end

    local idTb1 = {}
    for k,v in pairs(idTb) do
        if self:judgeAILimit(idTb,k,v) then
            table.insert(idTb1, v)
        end
    end

    local tb = {0, 0, 0, 0, 0, 0}
    local num = 0
    local equipLimitNum = self:AITroopsEquipLimitNum()
    for k, v in pairs(tankTb) do
        local tankId, tankNum = v[1], v[2]
        if tankId and tankNum and tonumber(tankNum) > 0 then --该位置有坦克
            num = num + 1
            tb[k] = idTb1[num] or 0
            if num >= equipLimitNum then
                do break end
            end
        end
    end  
    return tb
end

function AITroopsFleetVoApi:clearDimensionalWarAITroopsList()
    self.dimensionalWarTroops={0, 0, 0, 0, 0, 0}
end

function AITroopsFleetVoApi:clear()
    self.stats = {d = {}, m = {}, a = {}, w = {}, l = {}}
    self.troopsTb = {0, 0, 0, 0, 0, 0}
    self.defTroops = {0, 0, 0, 0, 0, 0}
    self.arenaTroops = {0, 0, 0, 0, 0, 0}
    self.allianceTroops = {0, 0, 0, 0, 0, 0}
    self.serverWarTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarTroop3 = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamTroops = {0, 0, 0, 0, 0, 0}
    self.bossbattleTroops = {0, 0, 0, 0, 0, 0}
    self.worldWarTroop1 = {0, 0, 0, 0, 0, 0}
    self.worldWarTroop2 = {0, 0, 0, 0, 0, 0}
    self.worldWarTroop3 = {0, 0, 0, 0, 0, 0}
    self.localWarTroops = {0, 0, 0, 0, 0, 0}
    self.localWarCurTroops = {0, 0, 0, 0, 0, 0}
    self.swAttackTroops = {0, 0, 0, 0, 0, 0}
    self.swDefenceTroops = {0, 0, 0, 0, 0, 0}
    self.platWarTroop1 = {0, 0, 0, 0, 0, 0}
    self.platWarTroop2 = {0, 0, 0, 0, 0, 0}
    self.platWarTroop3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalTroop3 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalCurTroop1 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalCurTroop2 = {0, 0, 0, 0, 0, 0}
    self.serverWarLocalCurTroop3 = {0, 0, 0, 0, 0, 0}
    self.allianceWar2Troops = {0, 0, 0, 0, 0, 0}
    self.allianceWar2CurTroops = {0, 0, 0, 0, 0, 0}
    self.newYearBossTroops = {0, 0, 0, 0, 0, 0}
    self.dimensionalWarTroops = {0, 0, 0, 0, 0, 0}
    self.dimensionalWarTroopsData = {0, 0, 0, 0, 0, 0}
    self.serverWarTeamCurTroops = {0, 0, 0, 0, 0, 0}
    self.championshipWarPersonalAITroops = {0, 0, 0, 0, 0, 0}
    self.championshipWarAITroops = {0, 0, 0, 0, 0, 0}
end

