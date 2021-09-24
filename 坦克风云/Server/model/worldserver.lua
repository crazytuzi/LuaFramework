local crossserver = {
    WIN=1, -- 胜者标识
    LOSE=2,    -- 败者标识
    DENY=3, -- 淘汰标识
    chatMsg = {},   -- 聊天信息
}

-- 每次战斗后需要保存的数据字段
local battleSaveField = {
    'round',
    'sround',
    'ranking',
    'point',
    'status',
    'pos',
    'log',
    'eliminateFlag',
    'score',
    'pointlog',
    'winStreak',
    'maxWinStreak',
    'winNum',
    'loseNum',
    'landform',
    'strategy',
}

-- 按组标识获取组号，g1=>1,g2=>2
local function groupName2SortNum (groupName)
    return tonumber(string.sub(groupName,2))
end

-- 按组数字标号获取字串标识，1=>g1,2=>g2
local function SortNum2GroupName(groupNum)
    return 'g' .. groupNum
end

-- 表名，大师和精英
local tableNames = {
    user={
        "worldwar_master",
        "worldwar_elite",
    }
}

-- NPC兵力，如果玩家没有设置兵力，以NPC兵力代替玩家战斗
local baseNpc = {
    id = '',
    nickname='playernc',
    level=60,
    fc=1000000,
    pic=1,
    rank=9,
    aname='',
    zrank = 1,
    binfo = '[["buffvalue","maxhp","abilityID","crit","evade","hp","abilityInfo","abilityLv","anticrit","landform","double_hit","salvo","evade_reduce","arp","accuracy","dmg","type","id","buff_value","armor","num","buffType","dmg_reduce"],[[[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1]],[[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1]],[[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1],[0.05,90,"",0,0,90,{"buff":{},"debuff":{}},"",0.05,0,0,1,0,0,0,18,1,"a10001",0,0,1,1,1]]]]'
}

----------------------------------------------------------------------------

local getClientTs = getClientTs
-- 随机种子标识
local setRandSeedFlag = false
-- 世界大战配置
local worldWarCfg = nil
-- 世界地图配置，为积分赛分配地图，地形属性加成时用
local worldGroundCfg = nil
-- 属性数字标识对应的字串标识,110=>dmg
local attrNumForAttrStr = nil
-- 记录积分赛事件
local pointMatchEvents = {}

----------------------------------------------------------------------------

-- 生成战报标识
local function mkBattleLogKey(...)
    local tmp = {...}
    return table.concat(tmp,'-')
end

-- 生成战斗log中的uid标识，防止有不同服的uid一样的情况
local function mkBattleUidKey(...)
    local tmp = {...}
    return table.concat(tmp,'-')
end

-- 详细战斗的时间
-- params int st 跨服战起始时间
-- return table {积分赛,淘汰赛}
local function getBattleRoundTs(st)
    -- ptb:p(os.date('%Y%m%d %X',st))
    local pRoundTsInfo = {}

    local config = getConfig('worldWarCfg')
    local dailyStCfg = config.pmatchstarttime1
    local dailyEtCfg = config.pmatchendtime1

    local dailySt = dailyStCfg[1] * 3600 + dailyStCfg[2] * 60
    local dailyEt = dailyEtCfg[1] * 3600 + dailyEtCfg[2] * 60 
    
    local battleStWeets = getWeeTs(st)
    local dayRoundNum = math.floor( (dailyEt - dailySt) / config.breaktime)

    for i=1,config.pmatchdays do
        local dayTs = (i-1)*24*3600
        for j=1,dayRoundNum do
            -- 这里减300是把开始时间往前提前了300秒
            -- local tmpDayRoundSt = battleStWeets + dailySt + dayTs + config.breaktime * (j-1)-300
            local tmpDayRoundSt = battleStWeets + dailySt + dayTs + config.breaktime * (j-1)-120
            table.insert(pRoundTsInfo,{tmpDayRoundSt,tmpDayRoundSt+config.breaktime})
            -- table.insert(pRoundTsInfo,{os.date('%Y%m%d %X',tmpDayRoundSt),os.date('%Y%m%d %X',tmpDayRoundSt+config.breaktime-60)})
        end
    end

    local tRoundTsInfo = {}

    -- 淘汰赛起始当天的凌晨时间戳
    local tBattleStWeets = battleStWeets + config.pmatchdays * 24 * 3600
    local tDailySt1 = config.tmatch1starttime1[1] * 3600 + config.tmatch1starttime1[2] * 60
    local tDailySt2 = config.tmatch2starttime1[1] * 3600 + config.tmatch2starttime1[2] * 60 
    for i=1,3  do
        local dayTs = (i-1) * 24 * 3600
        table.insert(tRoundTsInfo,tBattleStWeets+dayTs+tDailySt1-245)
        -- table.insert(tRoundTsInfo,os.date('%Y%m%d %X',tBattleStWeets+dayTs+tDailySt1-120))
        table.insert(tRoundTsInfo,tBattleStWeets+dayTs+tDailySt2-245)
        -- table.insert(tRoundTsInfo,os.date('%Y%m%d %X',tBattleStWeets+dayTs+tDailySt2))
    end
    
    return {pRoundTsInfo,tRoundTsInfo}
end

-- 积分赛当前轮次
-- params int st 起始时间
local function getPointCurrentRound(st)
    local ts = getClientTs()
    local battleTs = getBattleRoundTs (st)
    local currentRound = 0
    
    for k,v in ipairs(battleTs[1]) do
        -- print(os.date('%Y%m%d %X',v[1]))
        -- print(ts,v[1],ts>=v[1])
        if ts >= v[1] then 
            currentRound = k
        else
            break
        end
    end

    return currentRound
end

-- 获取积分赛最大轮数
local function getPointBattleMaxRound()
    local config = getConfig('worldWarCfg')
    return config.pmatchdays * (config.pmatchendtime1[1] - config.pmatchstarttime1[1]) * 4
end

-- 淘汰赛当前轮次
-- params int st 起始时间戳
local function getEliminateCurrentRound(st)
    local ts = getClientTs()
    local battleTs = getBattleRoundTs (st)
    local currentRound = 0

    for k,v in ipairs(battleTs[2]) do
        -- print(os.date('%Y%m%d %X',ts),os.date('%Y%m%d %X',v),k)
        if ts >= v then 
            currentRound = k
        else
            break
        end
    end

    return currentRound
end

-- 积分赛随机战斗地形
-- 一次把3场的都随机出来，保证三场地形不一样，需要去重
local function randBattleLandform()
    local randLandforms = {}

    if not worldGroundCfg then worldGroundCfg = getConfig('worldGroundCfg') end
    local landformSeed = {}
    
    for i=1,#worldGroundCfg do
        table.insert(landformSeed,i)
    end

    for i=1,3 do
        local randNum = rand(1,#landformSeed)
        table.insert(randLandforms,landformSeed[randNum])
        table.remove(landformSeed,randNum)
    end

    return randLandforms
end

-- 根据轮次随机淘汰赛的战斗地型
-- 淘汰赛的地型是战斗前随机生成的。战斗过程中读已经生成好的进行战斗
-- params int round 轮次
-- return table
local function randEliminateBattleLandform(round)
    local landforms = {} 
    
    local rnums = {32,16,8,4,2,2}
    if rnums[round] then
        for i=1,rnums[round] do
            table.insert(landforms,randBattleLandform())
        end
    end

    return landforms
end

-- 从生成好的地形中获取淘汰赛地形
-- params table landforms 提前生成好的地形
-- params string gname 战斗所属小级
-- return table 三小场战斗地形
local function getEliminateBattleLandform(landforms,gname)
    return landforms[groupName2SortNum(gname)] or {}
end

-- 对参与淘汰赛的成员按积分，战力，uid进行排序，用来分组
-- params table data 参与淘汰赛的所有用户数据
local function sortBattleDataByGroup(data)
    table.sort(data,function(a,b)
        if a.score == b.score then
            return tonumber(a.uid) < tonumber(b.uid)
        else
            return tonumber(a.score) > tonumber(b.score)
        end
    end
    )

    return data
end

-- 每轮比赛结束被淘汰后，从配置文件中获取排名
-- 直接写死，第6与第7场胜利与失败都有名次，其它场只有淘汰有名次
-- 将第6轮进行的冠军争夺赛视为第7轮方便取配置
-- params table cfg produceRank={{33,64},{17,32},{9,16},{5,8},{},{3,4},{1,2}}, --轮次对应出现的排名 
-- params int round 轮次
-- params int status 状态，成功/失败
-- params string gname 所属组 
-- return int
local function getRanking (cfg,round,status,gname)
    round = tonumber(round)
    if round == 6 and gname == 'g1' then round = 7 end

    if round < 5 then
        if status == crossserver.DENY then
            return cfg[round][1]
        end
    elseif round > 5 then
        return cfg[round][status] or cfg[round][2]
    end
end

-- 获取战斗结束后的用户状态，根据轮数
-- 前5轮直接淘汰，第5轮淘汰的用户还要继续争夺第3，4名
-- params int round 轮次
local function getOverStatusByRound(round)
    round = tonumber(round)

    if round < 5 then
        return {crossserver.WIN,crossserver.DENY}
    elseif round == 5 then
        return {crossserver.WIN,crossserver.LOSE}
    elseif round > 5 then
        return {crossserver.WIN,crossserver.DENY}
    end
end

-- 地形对坦克的加成
-- params table tank
-- params table attributeType 属性类型
local function  landformAdd(tank,landformInfo,landformCfg,attributeType)
    local addAttributeValue = {}
    
    if type(landformCfg[landformInfo]) == 'table' then
        for k,v in ipairs(landformCfg[landformInfo].attType) do
            local attrName = attributeType[v]
            local rate = landformCfg[landformInfo].attValue[k]

            if attrName == 'maxhp' or attrName == 'dmg' then
                addAttributeValue[attrName] = tank[attrName] * rate 
            elseif attrName == 'dmg_reduce' then
                addAttributeValue[attrName] = 1 - rate
            else
                addAttributeValue[attrName] = rate
            end
        end            
    end
    
    return addAttributeValue
end

-- 格式化部队（处理成能战斗的格式，保存的时候是简化了的数据）
-- attField 属性字段
-- troops 部队数据
-- landform 地形
-- strategys 双方策略
local function formatTroops(attField,troops,landform,strategys)
    local attTroops = {}

    for m,n in pairs(troops) do
        attTroops[m] = {}
        if next(n) then
            for k,v in pairs(attField) do
                attTroops[m][v] = n[k]
            end

            if landform then
                local landformAddValue = landformAdd(attTroops[m],landform,worldGroundCfg,attrNumForAttrStr)
                if type(landformAddValue) == 'table' and next(landformAddValue) then
                    attTroops[m].landform = landform
                    for landBuffKey,landBuffValue in pairs(landformAddValue) do
                        if landBuffKey == 'dmg_reduce' then
                            attTroops[m][landBuffKey] = attTroops[m][landBuffKey] * (landBuffValue or 1)
                        else
                            attTroops[m][landBuffKey] = attTroops[m][landBuffKey] + (landBuffValue or 0)
                        end
                    end
                end
            end

            if strategys[1] then
                -- 策略值相克的时候，属性值加成为双倍
                local relativeFlag = 1
                local strategyCfg = worldWarCfg.strategyAtt
                if strategys[2] and strategyCfg[strategys[1]][2] == strategys[2] then
                    relativeFlag = 2
                end
                
                if type(strategyCfg[strategys[1]][1]) == 'table' then
                    for attKey,attVal in pairs(strategyCfg[strategys[1]][1]) do
                        if attTroops[m][attrNumForAttrStr[attKey]] then
                            if attrNumForAttrStr[attKey] == 'maxhp' or attrNumForAttrStr[attKey] == 'dmg' then
                                attTroops[m][attrNumForAttrStr[attKey]] = attTroops[m][attrNumForAttrStr[attKey]] * (1 + attVal / 100 * relativeFlag)
                            else
                                attTroops[m][attrNumForAttrStr[attKey]] = attTroops[m][attrNumForAttrStr[attKey]] + attVal / 100 * relativeFlag
                            end
                        end
                    end

                    -- 总血量重新计算
                    attTroops[m].hp   = attTroops[m].maxhp * attTroops[m].num
                end 
            end
        end
    end

    return  attTroops
end

-- 淘汰赛的队列(按上次匹配的位置分配队列)
-- 小组赛用config来分配不用这个方法
local function getMatchListByPos(data)
    local list = {}

    -- 记录数据id对应data中的下标
    local id2data = {}
    local idlistWin = {}
    local idlistLose = {}

    for k,v in pairs(data) do
        id2data[v.id] = k
        if tonumber(v.status) == crossserver.WIN then
            table.insert(idlistWin,v)
        end

        if tonumber(v.status) == crossserver.LOSE then
            table.insert(idlistLose,v)
        end
    end

    -- 按位置排序后，相临近的两个出现在下一次比赛的相同位置
    local s = function (a,b) return groupName2SortNum(a.pos) < groupName2SortNum(b.pos) end    
    table.sort(idlistWin,s)
    if #idlistLose > 0 then
        table.sort(idlistLose,s)
    end
    
    -- 胜者组与败者组的位置（A,B...）经过一轮后，会缩减一半
    for k,v in pairs(idlistWin) do
        local tmpPos = groupName2SortNum(v.pos)
        local gname = SortNum2GroupName(math.ceil(tmpPos / 2))
        if not list[gname] then list[gname] = {} end
        table.insert(list[gname],id2data[v.id])
        -- table.insert(list[gname],v.pos)
    end

    -- 最后一轮才有可能有失败者进行战斗，直接让其去g2组
    for k,v in pairs(idlistLose) do
        local gname = 'g2'
        if not list[gname] then list[gname] = {} end
        table.insert(list[gname],id2data[v.id])
        -- table.insert(list[gname],v.pos)
    end

    return list
end

-- 生成下一轮战斗匹配队列
-- 第一轮(round为0时)是小组赛
-- 其它轮为淘汰赛
local function mkMatchList(round,data,matchList)
    if not data or not next(data) then return {} end

    local list = {}

    if round == 1 then
        data = sortBattleDataByGroup(data)

        for gk,gv in ipairs(matchList) do
            local gvLen = #gv
            for k,v in pairs(gv) do
                k = SortNum2GroupName(k+gvLen*(gk-1))

                if not list[k] then list[k] = {} end

                for _,n in ipairs(v) do
                    if data[n] then 
                        table.insert(list[k],data[n])
                    end
                end
            end
        end

    else

        local pos2List = getMatchListByPos(data)
        
        for gname,ginfo in pairs(pos2List) do
            list[gname] = {}
            for _,n in ipairs(ginfo) do
                -- data[n].binfo = nil     -- TEST
                table.insert(list[gname],data[n])
                round = tonumber(data[n].round)
            end
        end
    end

    -- ptb:e(list) -- TEST
    return list
end

-- 从格式化的部队数据中获取设置的部队数据{{'a10001',5},{'a10002',5},}
-- 存的数据是属性加成算好的，需要换成动画能播的格式
local function getTroopsByInitTroopsInfo(initTroopsInfo)
    local troops = {}
    for k,v in pairs(initTroopsInfo) do
        table.insert(troops,{v.id,v.num})
    end
    return troops
end

-- 从战斗后的部队数据中获取胜余的坦克数量
-- return num
local function getAliveNumByInavlidFleet(inavlidFleet)
    local num = 0
    for k,v in pairs(inavlidFleet) do            
        num = num + (v.num or 0)
    end
    return num
end

-- 获取战斗攻击出手顺序
-- round 第几次战斗
-- aAliveNums 攻方剩余坦克数
-- dAliveNums   防守剩余坦克
-- prevAttSeq 上一场的战斗出手顺序
local function getBattleSeq(round,aAliveNums, dAliveNums,prevAttSeq)
    setRandSeed()
    local attSeq = prevAttSeq

    if round == 1 then
        attSeq = rand (1,2)
    elseif round == 2 then
        attSeq = attSeq == 1 and 2 or 1
    elseif round == 3 then
        if aAliveNums > dAliveNums then
            attSeq = 1
        elseif aAliveNums == dAliveNums then
            attSeq = rand (1,2)
        else
            attSeq = 2
        end
    end

    return attSeq
end

-- 战斗
-- 这里要额外加上地形和策略
local function crossbattle(fleetInfo1,fleetInfo2,inning,landform,strategys)
    fleetInfo1 = fleetInfo1 or json.decode(baseNpc.binfo)
    fleetInfo2 = fleetInfo2 or json.decode(baseNpc.binfo)

    local aStrategy = strategys[1] and strategys[1][inning]
    local dStrategy = strategys[2] and strategys[2][inning]
    
    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][inning],landform,{aStrategy,dStrategy})
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][inning],landform,{dStrategy,aStrategy})

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInavlidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.r, aInavlidFleet, dInvalidFleet, attSeq, setPoint = battle(aFleetInfo,defFleetInfo)

    local aAliveNum = getAliveNumByInavlidFleet(aInavlidFleet)
    local dAliveNum = getAliveNumByInavlidFleet(dInvalidFleet)

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if fleetInfo1[3] and fleetInfo1[3][inning] then
        report.h[2] = fleetInfo1[3][inning]
    end

    if fleetInfo2[3] and fleetInfo2[3][inning] then
        report.h[1] = fleetInfo2[3][inning]
    end

    report.se={0, 0}
    if fleetInfo1[4] and fleetInfo1[4][inning] then
        report.se[2] = fleetInfo1[4][inning]
    end    
    if fleetInfo2[4] and fleetInfo2[4][inning] then
        report.se[1] = fleetInfo2[4][inning]
    end
    
    return report, aAliveNum, dAliveNum, attSeq, setPoint
end

-- 获取积分赛分组列表
local function getPointMatchList(data)
    if type(data) == 'table' then
        setRandSeed()
        local list = {}

        while next(data) do

            local tmpGroup = {data[1]}
            table.remove(data,1)

            if #data < 1 then 
                table.insert(list,tmpGroup)
                break 
            end

            local randNum = rand(1, (#data >=9 and 9 or #data))

            table.insert(tmpGroup,data[randNum])
            table.insert(list,tmpGroup)

            table.remove(data,randNum)
        end

        return list

    end

end

-- 积分赛的消息事件
local function addPointMatchEvent(self,eventInfo)
    local maxNum = worldWarCfg.streakMaxNum + 5
    table.insert(pointMatchEvents,eventInfo)
end

-- 设置积分赛消息事件
local function setPointMatchEvent(self,bid,round,matchType)
    local strKey = bid .. "." .. matchType
    local eventCacheKey = "pointMatchEvents.all." .. round .. "." .. strKey
    local maxNum = worldWarCfg.streakMaxNum + 5
    local pEventsLen = #pointMatchEvents

    local ltrimFlag = false
    local i = 0;
    for _,eventInfo in ipairs(pointMatchEvents) do
        if type(eventInfo) == 'table' and eventInfo[3] then
            local tmpUid = eventInfo[3]
            local tmpUserCacheKey = "pointMatchEvents.user." .. tmpUid .. "." .. strKey
            table.remove(eventInfo,3)
            local eventInfoJsonStr = json.encode(eventInfo)

            self.redis:lpush(tmpUserCacheKey,eventInfoJsonStr)
            self.redis:ltrim(tmpUserCacheKey,0,maxNum)
            self.redis:expire(tmpUserCacheKey,777600)

            if pEventsLen - i <= maxNum then
                self.redis:lpush(eventCacheKey,eventInfoJsonStr)
                ltrimFlag = true
            end
            i = i + 1;
        end
    end
    
    pointMatchEvents = {}

    if ltrimFlag then
        self.redis:ltrim(eventCacheKey,0,maxNum)
    end

    -- 跨服战一共持续
    return self.redis:expire(eventCacheKey,777600)
end

-- 设置积分赛的排行
local function setPointMatchRanking(self,bid,round,uid,score,fc,matchType)
    local cacheKey = string.format("pointMatch.user.rank.%s.%s.%s",bid,round,matchType)
    score = score * 1000000
    fc = math.ceil(fc / 1000000)
    score = score + fc
    self.redis:zadd(cacheKey,score,uid)
    self.redis:expire(cacheKey,259200)
end

-- 获取积分赛排行
local function getPointMatchRanking(self,bid,round,uid,matchType)
    local cacheKey = string.format("pointMatch.user.rank.%s.%s.%s",bid,round,matchType)
    return self.redis:zrevrank(cacheKey,uid)
end 

local function delPointMatchRanking( self,bid,round,matchType )
    local delRound = round - 2 
    if delRound > 0 and delRound < getPointBattleMaxRound() then
        local userCacheKey = string.format("pointMatch.user.rank.%s.%s.%s",bid,delRound,matchType) 
        local allCacheKey = string.format("pointMatch.rank.%s.%s.%s",bid,delRound,matchType) 
        local eventCacheKey = string.format("pointMatchEvents.all.%s.%s.%s",delRound,bid,matchType)
        self.redis:del(userCacheKey,allCacheKey,eventCacheKey)
    end
end

----------------------------------------------------------------------------

local function setUserApplyNum(self,bid,matchType,num)
    local cacheKey = "pointMatchEvents.apply.num." .. bid .. '.' .. matchType
    if num and num > 0 then
        self.redis:set(cacheKey,num)
    else
        self.redis:incr(cacheKey)
    end

    self.redis:expire(cacheKey,777600)
end

local function getUserApplyNum(self,bid,matchType)
    local cacheKey = "pointMatchEvents.apply.num." .. bid .. '.' .. matchType
    local num = tonumber(self.redis:get(cacheKey))

    if not num then
        local tbname = tableNames.user[matchType]
        local data = self.db:getRow("select count(*) as count from "  ..tbname .. " where bid=:bid ",{bid=bid})
        num = tonumber(data['count']) or 0
        setUserApplyNum(self,bid,matchType,num)
    end

    return num
end

-- 获取自己报名的信息
local function getUserApplyData(self,bid,zid,uid,matchType)
    local tbname = tableNames.user[matchType]
    return self.db:getRow("select * from "  ..tbname .. " where bid=:bid and uid=:uid and zid=:zid limit 1",{uid=uid,bid=bid,zid=zid} )
end

-- 设置自己的信息
local function setUserApplyData(self,data,matchType)
    local ret, err
    local table = tableNames.user[matchType]
    if data.bid then
        data.updated_at = getClientTs()
        data.apply_at = data.updated_at
        ret = self.db:insert(table,data)
        if not ret then err = self.db:getError() end
    end

    return ret, err
end

-- 按id获取bid数据
local function getBidDataById(self,id,matchType)
    return self.db:getRow("select * from worldwar_bid where bid = :bid and matchType = :matchType",{bid=id,matchType=matchType})
end

-- 按时间获取bid数据
local function getBidDataByMatchType(self,matchType,st)
    return self.db:getAllRows("select * from worldwar_bid where matchType = :matchType and st <= :st",{st=st,matchType=matchType})
end

-- 设置bid数据
local function setBidData(self,data)
    data.updated_at = getClientTs()
    
    if not data.landform then 
        data.landform = randEliminateBattleLandform(1)
    end

    if not self.db:insert("worldwar_bid",data) then
        return nil,self.db:getError()
    end

    return true
end

-- 更新bid信息
local function updateBidData(self,data)
    data.updated_at = getClientTs()
    if not self.db:update("worldwar_bid",data,string.format("bid='%s' and matchType='%s'",data.bid,data.matchType)) then
        return nil,self.db:getError()
    end
    
    return true
end

-- 获取战斗数据
-- params string bid 战斗标识
-- params int btype 类型[1是大师]，2是精英
local function getBattleDataByBid(self,bid,sround,btype)
    if btype == 1 then
        return self.db:getAllRows("select * from worldwar_master where bid = :bid and sround <= :sround order by score desc limit 1000",{bid=bid,sround=sround})
    else
        return self.db:getAllRows("select * from worldwar_elite where bid = :bid and sround <= :sround order by score desc limit 1000",{bid=bid,sround=sround})
    end
end

local function getEliminateBattleDataByBid(self,bid,tround,btype)
    local data = {}
    local tb = tableNames.user[btype]

    if tonumber(tround) == 1 then
        data = self.db:getAllRows("select * from " .. tb .. " where bid = :bid order by score desc ,fc desc,uid asc limit 64",{bid=bid})

        for k,v in pairs(data) do
            if tonumber(v.eliminateFlag) == 1 then
                data = {}
                break
            end
        end
    else
        data = self.db:getAllRows("select * from ".. tb .. " where bid = :bid and eliminateFlag = 1 and round <= :tround and status != 3 limit 64",{bid=bid,tround=tround})
    end
    
    for k, v in pairs(data) do
        --淘汰赛未设置兵，用NPC代替
        if tonumber(v.eliminateTroopsFlag) ~= 1 then
            data[k].binfo = baseNpc.binfo
        end
    end
    
    return data
end

local function getAllEliminateBattleDataByBid(self,bid,tround,matchType)
    local tb = tableNames.user[matchType]

    if tround == 1 then
        return self.db:getAllRows("select * from ".. tb .." where bid = :bid order by score desc ,fc desc,uid asc limit 64",{bid=bid})
    end

    return self.db:getAllRows("select * from ".. tb .." where bid = :bid and eliminateFlag = 1 limit 64",{bid=bid})
end

-- 设置积分赛战报
local function setPointBattleReport(self,reportInfo)
    local report = {
        bid = reportInfo.bid,
        round = reportInfo.round,
    }

    local winerInfo,loserInfo

    if reportInfo.winFlag then 
        winerInfo = reportInfo.userinfo1
        loserInfo = reportInfo.userinfo2
    else
        winerInfo = reportInfo.userinfo2
        loserInfo = reportInfo.userinfo1
    end

    if type(winerInfo) == 'table' then
        report.winerId = winerInfo.userinfo.uid
        report.wLevel = winerInfo.userinfo.level
        report.wNickname = winerInfo.userinfo.nickname
        report.wPic = winerInfo.userinfo.pic
        report.wbPic = winerInfo.userinfo.bpic
        report.waPic = winerInfo.userinfo.apic
        report.wRank = winerInfo.userinfo.rank
        report.wFc = winerInfo.userinfo.fc
        report.wAName = winerInfo.userinfo.aname
        report.wZid = winerInfo.userinfo.zid
        report.wStrategy = winerInfo.userinfo.strategy
        report.wPoint = winerInfo.point
        report.wScore = winerInfo.score
    end

    if type(loserInfo) == 'table' then
        report.loserId = loserInfo.userinfo.uid
        report.lLevel = loserInfo.userinfo.level
        report.lNickname = loserInfo.userinfo.nickname
        report.lPic = loserInfo.userinfo.pic
        report.lbPic = loserInfo.userinfo.bpic
        report.laPic = loserInfo.userinfo.apic
        report.lRank = loserInfo.userinfo.rank
        report.lFc = loserInfo.userinfo.fc
        report.lAName = loserInfo.userinfo.aname
        report.lZid = loserInfo.userinfo.zid
        report.lStrategy = loserInfo.userinfo.strategy
        report.lPoint = loserInfo.point
        report.lScore = loserInfo.score
    end

    if type(reportInfo.landforms) == 'table' and #reportInfo.landforms > 0 then
        report.landformInfo = table.concat(reportInfo.landforms,',')
    end

    report.battleWiners = reportInfo.battleWiners
    
    if type(reportInfo.reports) == 'table' then
        report.report1 = reportInfo.reports[1]
        report.report2 = reportInfo.reports[2]
        report.report3 = reportInfo.reports[3]
    end
    
    local lUid = loserInfo and loserInfo.userinfo.uid or 0
    report.bkey = mkBattleLogKey(reportInfo.bid,reportInfo.round,winerInfo.userinfo.uid,lUid)
    report.updated_at = getClientTs()

    local ret = self.db:insert("worldwar_battlelog",report)

    if not ret then writeLog(self.db:getError() or 'no report error','setWWarReport') end

    return ret
end

-- 设置淘汰赛跨服战战报
local function setEliminateBattleReport(self,data)
    local report = {}
    report.updated_at = getClientTs()
    report.info = data.report
    report.bkey = mkBattleLogKey(data.bid,data.matchType,data.round,data.pos,data.inning)

    local ret = self.db:insert("worldwar_eliminate_battlelog",report)

    if not ret then 
        print(self.db:getError())
        writeLog(self.db:getError() or 'no report error','setWWarReport') 
    end

    return ret
end

-- 获取淘汰赛跨服战战报
local function getEliminateBattleReport(self,bid,matchType,round,pos,inning)
    local bkey = mkBattleLogKey(bid,matchType,round,pos,inning)
    return self.db:getRow("select * from worldwar_eliminate_battlelog where bkey = :bkey",{bkey=bkey})
end

-- 修改跨服战用户数据
local function updateUserApplyData(self,id,data,matchType)
    data.updated_at = getClientTs()
    local table = tableNames.user[matchType]
    return self.db:update(table,data,"id="..id)
end

-- 修改跨服战用户数据
local function updateUserBattleData(self,id,data,matchType)
    data.updated_at = getClientTs()
    return self.db:update(tableNames.user[matchType],data,"id="..id)
end

-- 保存战斗结果
local function setBattleDatas(self,datas,matchType)
    local returns = {}
    local ts = getClientTs()

    for k,data in pairs(datas) do
        local tmpData = {}
        tmpData.battle_at = ts
        tmpData.updated_at = ts

        for _,field in ipairs(battleSaveField) do
            tmpData[field] = data[field]
        end

        -- 战斗纪录是一个json串
        if type(tmpData.log) == 'table' then
            tmpData.log = json.encode(tmpData.log)
        end
        
        local ret = self:updateUserBattleData (data.id,tmpData,matchType)
        
        returns [data.id] = ret
    end

    return returns
end

-- 获取结束后的排名信息
local function getUserEndRanking(self,bid)
    local  master,elite
    local sql="select uid,ranking from worldwar_master where ranking>=0 and bid='"..bid.."'"
    local sql1="select uid,ranking from worldwar_elite where ranking>=0 and bid='"..bid.."'"
    local master=self.db:getAllRows(sql)
    local elite=self.db:getAllRows(sql1)
    return master,elite
end

local function setPointMatchBattleDatas(self,datas,matchType)
    local returns = {}
    local ts = getClientTs()
    
    for _,matchData in pairs(datas) do
        for _,data in pairs(matchData) do
            local tmpData = {}
            tmpData.battle_at = ts
            tmpData.updated_at = ts

            for _,field in ipairs(battleSaveField) do
                tmpData[field] = data[field]
            end

            -- 战斗纪录是一个json串
            if type(tmpData.log) == 'table' then
                tmpData.log = json.encode(tmpData.log)
            end
            
            local ret = self:updateUserBattleData (data.id,tmpData,matchType)
            
            returns [data.id] = ret
        end
    end
    
    return returns
end

----------------------------------------------------------------------------

local function setautocommit(self,value)
    assert(self.db.conn:setautocommit(value),'mysql transaction set failed')
end

local function commit(self)
    return self.db.conn:commit()
end

local function rollback(self)
    self.db.conn:rollback()
end

local function connect(self)
    self.db = getCrossDbo("worldwarserver")--getWorldWarDbo()
    self.redis = getAllianceCrossRedis("worldwarserver")
end

local function initBattle()
    if not worldGroundCfg then
        worldGroundCfg = getConfig("worldGroundCfg")
    end

    if not worldWarCfg then
        worldWarCfg = getConfig("worldWarCfg")
    end

    if not setRandSeedFlag then
        setRandSeed()
    end

    if not attrNumForAttrStr then
        attrNumForAttrStr = getConfig("common.attrNumForAttrStr")
    end
end

local function writeCrossLog(log)
    writeLog(log,'worldWar')
end
----------------------------------------------------------------------------

local methods = {
    initBattle = initBattle,
    randBattleLandform = randBattleLandform,
    randEliminateBattleLandform = randEliminateBattleLandform,
    getEliminateBattleLandform = getEliminateBattleLandform,

    getUserApplyData=getUserApplyData,
    setUserApplyData=setUserApplyData,

    getBidDataById = getBidDataById,
    getBidDataByMatchType = getBidDataByMatchType,
    setBidData = setBidData,
    getBattleDataByBid = getBattleDataByBid,
    getPointMatchList = getPointMatchList,
    updateUserBattleData = updateUserBattleData,
    setPointMatchBattleDatas = setPointMatchBattleDatas,
    getBattleRoundTs = getBattleRoundTs,
    getPointBattleMaxRound = getPointBattleMaxRound,
    getPointCurrentRound = getPointCurrentRound,
    getEliminateCurrentRound = getEliminateCurrentRound,
    getEliminateBattleDataByBid = getEliminateBattleDataByBid,
    getOverStatusByRound = getOverStatusByRound,
    getAllEliminateBattleDataByBid = getAllEliminateBattleDataByBid,
    setPointBattleReport = setPointBattleReport,
    setEliminateBattleReport = setEliminateBattleReport,
    getEliminateBattleReport = getEliminateBattleReport,
    updateBidData = updateBidData,

    addPointMatchEvent = addPointMatchEvent,
    setPointMatchEvent = setPointMatchEvent,
    setPointMatchRanking = setPointMatchRanking,
    getPointMatchRanking = getPointMatchRanking,
    delPointMatchRanking = delPointMatchRanking,

    mkMatchList = mkMatchList,
    mkBattleUidKey = mkBattleUidKey,
    getBattleSeq = getBattleSeq,
    crossbattle = crossbattle,
    getRanking = getRanking,
    setUserApplyNum = setUserApplyNum,
    getUserApplyNum = getUserApplyNum,
    getUserEndRanking= getUserEndRanking,
    
    -- connection
    connect = connect,
    -- data
    
    setBattleDatas = setBattleDatas,
    updateUserApplyData = updateUserApplyData,
    
    -- db
    setautocommit = setautocommit,
    commit = commit,
    rollback = rollback,
    writeCrossLog = writeCrossLog,
}

local new = function()
    local r = crossserver
    connect(r)
    return setmetatable(r, {__index = methods})
end

return {
    new = new
}
