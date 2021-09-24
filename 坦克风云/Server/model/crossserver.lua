local crossserver = {
    WIN=1, -- 胜者标识
    LOSE=2,    -- 败者标识
    DENY=3, -- 淘汰标识
    chatMsg = {},   -- 聊天信息
}

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

-- 每次战斗后需要保存的数据字段
local battleSaveField = {'round','ranking','point','status','pos','log'}

-- 从server端传过来的参赛用户数据对应的字段
local uDatafield = {"uid","nickname","zid","aname","pic","rank","level","fc","binfo","st","et","bid","servers","zrank","bpic","apic","aid","logo"}

-- 每轮(按胜败组)基础位置
local groupName2SortNum = {a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8}
local SortNum2GroupName = {'a','b','c','d','e','f','g','h'}

----------------------------------------------------------------------------

local getClientTs = getClientTs
local logn = math.logn

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

-- 返回回合产生的事件
-- table['产生季军轮次','产生冠军轮次']
-- 可依据此设置排名
local function getRoundEvents(num)
    return {logn(num,2) * 2 -2,logn(num,2) * 2 -1}
end

-- 设置聊天消息 
local function setChatMsg(self,msg)
    table.insert(self.chatMsg,msg)
end

-- 消息推送
-- {"sender":0,"reciver":0,"channel":1,"sendername":"","recivername":"","content":{"message":{"key":"chatSystemMessage13","param":["name"]},"ts":1413776805,"contentType":3,"subType":4,"isSystem":1},"type":"chat"}
-- chatSystemMessage13="恭喜%s在【跨服战】中一路过关斩将获得了总冠军的桂冠，并获得了海量奖励！",
-- chatSystemMessage14="恭喜%s在【跨服战】中获得了亚军！",
-- chatSystemMessage15="恭喜%s在【跨服战】中获得了季军！",
local function pushChat(self)
    local msg = {
        sender=0,
        reciver=0,
        channel=1,            
        sendername="",
        recivername="",
        type="chat",
        content={
            isSystem=1,
            message={
                key=nil,
                param={},
            },
            ts=getClientTs(),
            contentType=3,
            subType=4,
        },
    }

    local chatKey = {
        'chatSystemMessage13',
        'chatSystemMessage14',
        'chatSystemMessage15'
    }

    table.sort(self.chatMsg,function(a,b) return a.ranking < b.ranking end)

    for _,v in pairs(self.chatMsg) do      
        if chatKey[v.ranking] then
            msg.content.message.key = chatKey[v.ranking]
            msg.content.message.param[1] = v.nickname
            msg.content.message.param[2] = v.zid

            for _,zid in pairs(v.servers) do 
                sendMessage(msg,tonumber(zid))
            end
        end
    end
end

-- 删除掉已经被淘汰的用户数据
local function delDenyUserData(data)
    local tdata = {}
    for k,v in pairs(data) do
        -- 需要排除掉已经淘汰掉的数据
        if tonumber(v.status) ~= crossserver.DENY then
            table.insert(tdata,v)
        end
    end

    return tdata
end

local function getBattleRoundTs(st)
    local config = getConfig('serverWarPersonalCfg')
    local startCfg = config.startBattleTs
    local preTime = 0
    local betCfg = {config.betTs_a, config.betTs_b }

    --转换为时间戳
    local getStartTime = function(matchst, startTime, vate, pretime, eightTime)
        local st = getWeeTs(matchst)
        local diffTime = matchst - st
        local plusTime = 0
        if diffTime > (eightTime[1] * 3600 + eightTime[2] * 60) then
            plusTime = 24 * 3600
        end
        local vSt = st + (vate - 1) * 24 * 3600
        return vSt + startTime[1] * 3600 + startTime[2] * 60 + pretime * 24 * 3600 + plusTime
    end

    local needDay = getRoundEvents(config.sevbattlePlayer)
    local baseinfo = {
        [0] = getStartTime(st, startCfg[1], 1, preTime,startCfg[1]),
    }
    for i = 1, needDay[2] do
        local index = math.ceil(i/2) + 1
        local cfgIndex = ((i+1)%2) + 1
        table.insert(baseinfo, getStartTime(st, startCfg[cfgIndex], index, preTime,startCfg[1]))
    end

    for k,v in pairs(baseinfo) do
        baseinfo[k] = v - 60
    end

    return baseinfo
end

local function getCurrentRound(st)
    local config = getConfig('serverWarPersonalCfg')
    local ts = getClientTs()
    local roundInfo  = getRoundEvents(config.sevbattlePlayer)
    local maxRound = roundInfo[2]
    local battleTs = getBattleRoundTs (st)
    
    for i=0,maxRound do
        if i == 0 and ts <= battleTs[i] then 
            return i 
        end

        if i == maxRound and ts >= battleTs[i] then 
            return i 
        end

        if ts > battleTs[i] and ts <= battleTs[i+1] then
            return i
        end
    end
    
end

-- 是否能战斗
-- return bool
local function canBattle(round,battle_at,cfg)    
    if round == 0 then return true  end
        
    local todayRound = math.floor(round%2)
    if todayRound == 0 then todayRound = 2 end

    local weets = getWeeTs()
    local ts1 = weets + cfg[1][1] * 3600 + cfg[1][2] * 60
    local ts2 = weets + cfg[2][1] * 3600 + cfg[1][2] * 60
    
    -- 第一轮的战斗应该是在小组赛后第二天
    if todayRound == 1 then
         if battle_at < weets or (battle_at >= ts1 and battle_at <= ts1 + 600) then
            return true
        end
    elseif todayRound == 2 then
        if battle_at < ts2 or (battle_at >= ts2 and battle_at < ts1 + 600) then
            return true
        end
    end
end

-- 检测战斗数据是否完整
-- 小组赛前才进行检测，如果数据不完整，需要补充机器人
local function checkBattleData(data,sevbattleCfg)
    local playerNum = sevbattleCfg.sevbattlePlayer
    local repairFlag = {}

    if type(data) == 'table' and next(data) then
        local round , dataLen = 0, 0
        for k,v in pairs(data) do
            dataLen = dataLen + 1
            local dRound = tonumber(v and v.round) or 1
            round = round + dRound
        end

        if round == 0 and dataLen < playerNum then
            -- 按服id,服排名设置战斗数据标识
            local zData = {}
            for k,v in pairs(data) do 
                local zid = tonumber(v.zid)
                if not zData[zid] then zData[zid] = {} end
                zData[zid][tonumber(v.zrank)] = 1
            end

            -- 按参加的服务器检测是否缺数据
            local servers = json.decode(data[1].servers)   

            if type(servers) == 'table' then
                -- 每服应有的人数
                local znums = math.ceil(playerNum / #servers)

                for i=1,znums do
                    for _ , szid in pairs(servers) do   
                        szid = tonumber(szid)

                        if not zData[szid] and not table.contains(repairFlag,szid) then table.insert(repairFlag,szid) end

                        -- 如果没有此组服的数据，或者此组服数据中缺失数据
                        -- 按当前data数据补充npc
                        if not zData[szid] or not zData[szid][i] then
                            local tmpnpc = copyTab(data[1])

                            for npck,npcv in pairs(baseNpc) do
                                tmpnpc[npck] = npcv          
                            end

                            tmpnpc.zrank = i
                            tmpnpc.uid = i
                            tmpnpc.nickname = tmpnpc.nickname .. i
                            tmpnpc.zid = szid

                            -- 设置npc标识，以此为依据判断战斗结束后是插入数据还是修改数据
                            tmpnpc.npc = 1
                            -- tmpnpc.binfo = nil
                            
                            table.insert(data,tmpnpc)
                        end
                    end
                end
            end
        end
    end
    -- ptb:e(data)
    return data,repairFlag
end

-- 对分组赛进行排序
-- 无论开启几组服务器的跨服战，序号最小的服参赛的1到X名序号为1到X，序号第二小的服的1-X名序号为(X+1)到2X,依次类推
local function sortBattleDataByGroup(data)
    table.sort(data,function(a,b)
        if a.zid == b.zid then
            return tonumber(a.zrank) < tonumber(b.zrank)
        else
            return tonumber(a.zid) < tonumber(b.zid)
        end
    end
    )

    return data
end

-- 每轮比赛结束被淘汰后，从配置文件中获取排名
-- cfg produceRank={{13,16},{9,12},{7,8},{5,6},{4,4},{3,3},{1,2},},
-- round 轮次
-- pos 所在位置
local function getRanking (cfg,round,pos)
    round = tonumber(round)
    local posn = groupName2SortNum[pos]
    local n = 1
    if cfg[round] then
        for i= cfg[round][1] , cfg[round][2] do
            if posn == n then
                return i
            end
            n = n + 1
        end
    end
end

-- 格式化从server过来的用户数据(传过来是没有字段标识的简写数据)
local function formatServerUserData(uData)
    local tmp = {}
    for m,n in ipairs(uDatafield) do
        if uData[m] then tmp[n] = uData[m] end
    end

    return tmp
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
local function formatTroops(attField,troops,landform)
    local attTroops = {}
    local worldGroundCfg = getConfig("worldGroundCfg")
    local attrNumForAttrStr = getConfig("common.attrNumForAttrStr")

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
        end
    end

    return  attTroops
end

-- 淘汰赛的队列(按上次匹配的位置分配队列)
-- 小组赛用config来分配不用这个方法
local function getMatchListByPos(data)
    local list = {win={},lose={}}
    local win,lose = {}, {}

    -- 记录数据id对应data中的下标
    local id2data = {}

    for k,v in pairs(data) do
        id2data[v.id] = k

        -- 已经淘汰的数据不进行处理
        if tonumber(v.status) == crossserver.WIN then
            table.insert(win,v)
        elseif tonumber(v.status) == crossserver.LOSE then
            table.insert(lose,v)
        end
    end

    -- 按位置排序后，相临近的两个出现在下一次比赛的相同位置
    local s = function (a,b) return a.pos < b.pos end    
    table.sort(win,s)
    table.sort(lose,s)

    -- 胜者组与败者组的位置（A,B...）经过一轮后，会缩减一半
    for k,v in pairs(win) do
        local gname = SortNum2GroupName[math.ceil(k / 2)]
        if not list.win[gname] then list.win[gname] = {} end
        table.insert(list.win[gname],id2data[v.id])
    end

    for k,v in pairs(lose) do
        local gname = SortNum2GroupName[math.ceil(k / 2)]
        if not list.lose[gname] then list.lose[gname] = {} end
        table.insert(list.lose[gname],id2data[v.id])
    end

    return list
end

-- 生成下一轮战斗匹配队列
-- 第一轮(round为0时)是小组赛
-- 其它轮为淘汰赛
-- roundEvents 如果是最后一轮，需要将败者组的人拉入胜者组，决出冠军
local function mkMatchList(data,matchList,roundEvents)
    if not data or not next(data) then return {} end

    local list = {
        -- group = {}, -- 分组
        -- win = {},   -- 胜组
        -- lose = {},  -- 败组
        }

    local round = tonumber(data[1].round) or 0

    if round == 0 then
        data = sortBattleDataByGroup(data)
        list.group = {}
        for k,v in pairs(matchList) do
            k = SortNum2GroupName[k]
            list.group[k] = {}
            for _,n in ipairs(v) do
                if not data[n] then error('group matches pos is empty:' .. n) end
                table.insert(list.group[k],data[n])
            end
        end
    else
        local pos2List = getMatchListByPos(data)
        for g,gdata in pairs(pos2List) do
            list[g] = {}
            for gname,ginfo in pairs(gdata) do
                list[g][gname] = {}
                for _,n in ipairs(ginfo) do
                    -- data[n].binfo = nil     -- TEST
                    table.insert(list[g][gname],data[n])
                    round = tonumber(data[n].round)
                end
            end
        end
    end

    -- 如果是最后一轮，需要把败者组挪到胜者组进行战斗
    if roundEvents and round == roundEvents[2] and list.win and list.lose then
        if table.length(list.win) == 1 and table.length(list.lose) == 1 then
            table.insert(list.win.a,list.lose.a[1])
            list.lose = nil
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
local function crossbattle(fleetInfo1,fleetInfo2,inning,landform)
    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][inning],landform)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][inning],landform)

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

----------------------------------------------------------------------------

-- 插入跨服战用户数据
local function setUserBattleData (self,data)
    data.updated_at = getClientTs()
    return self.db:insert('battle',data)
end

-- 修改跨服战用户数据
local function updateUserBattleData(self,id,data)
    data.updated_at = getClientTs()
    return self.db:update('battle',data,"id="..id)
end

-- 获取用户跨服数据
local function getUserBattleData(self,zid,bid,uid)
    return self.db:getRow("select * from battle where zid=:zid and uid=:uid and bid=:bid",{uid=uid,zid=zid,bid=bid})
end

-- 根据时间和结束轮次获取跨服战数据
-- 满足条件的数据将进行战斗
local function getBattleDataByTime(self,ts,endRound)
    local weets = getWeeTs()
    return self.db:getAllRows("select * from battle where status != 3 and round <= :endRound and st < :ts and et > :lts limit 2600",{ts=ts,lts=ts-86400,weets=weets,endRound=endRound} )
end

-- 根据BID获取跨服数据
local function getBattleDataByBid(self,bid)
    return self.db:getAllRows("select * from battle where bid = :bid  limit 50",{bid=bid} )
end

local function countBattleDataByBid(self,bid)
    local count = 0
    local res = self.db:getRow("select count(*) as num from battle where bid = :bid limit 1",{bid=bid})    
    if res then count = tonumber(res.num) or 0 end

    return count
end

-- 设置跨服战战报
local function setBattleReport(self,data)
    local report = {}
    report.updated_at = getClientTs()
    report.bid = data.bid
    report.info = data.report
    report.bkey = mkBattleLogKey(data.bid,data.round,data.group,data.pos,data.inning)

    local ret = self.db:insert("battlelog",report)
    if not ret then writeLog(self.db:getError() or 'no report error','setReport') end

    return ret
end

-- 获取跨服战战报
local function getBattleReport(self,bid,round,group,pos,inning)
    local bkey = mkBattleLogKey(bid,round,group,pos,inning)
    return self.db:getRow("select * from battlelog where bkey = :bkey",{bkey=bkey})
end

local function setBattleDatas(self,datas)
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

        local ret 

        -- 如果数据是补充过来的npc,需要插入NPC数据，否则修改数据
        if data.npc == 1 then            
            data.id = nil
            data.npc = nil
            ret = self:setUserBattleData (data)      
            data.id = self.db.conn:getlastautoid()
        else
            ret = self:updateUserBattleData (data.id,tmpData)
        end
        returns [data.id or mkBattleUidKey(data.zid,data.uid)] = ret
    end

    return returns
end

-- 生成跨服战所需的全部地形
local function createCrossBattleLandform()
    local randLandforms = {}

    local worldGroundCfg = getConfig("worldGroundCfg")
    local sevbattleCfg = getConfig('serverWarPersonalCfg')
    local roundEvents = getRoundEvents(sevbattleCfg.sevbattlePlayer)

    -- 队伍数,2人一组,总参赛人数/2
    local teamNum = sevbattleCfg.sevbattlePlayer/2

    -- 地形库,从这里面随机
    local landformCfg = {}
    for k,v in pairs(worldGroundCfg) do
        table.insert(landformCfg,v.id)
    end

    setRandSeed()

    -- 产生冠军的轮次是最后一轮,实际战都是0-7，0是分组赛
    -- 这里生成的时候为了存储方便从1开始1-8,所以+1
    local maxRound = roundEvents[2] + 1

    local copyTable = copyTable
    for i=1, maxRound do
        randLandforms[i] = {{},{}}

        for _,groupData in pairs(randLandforms[i]) do
            for j=1,teamNum do
                local landformSeed = copyTable(landformCfg)
                local teamIndex = SortNum2GroupName[j]
                
                groupData[teamIndex] = {}

                for k=1,3 do
                    local randNum = rand(1,#landformSeed)
                    table.insert(groupData[teamIndex],landformSeed[randNum])
                    table.remove(landformSeed,randNum)
                end
            end
        end
    end

    return randLandforms
end

-- 获取战斗地形
local function getCrossBattleLandform(self,bid)
    local landforms = {}

    local data = self.db:getRow("select * from battle_bid where bid = :bid",{bid=bid})
    if data and data.landform ~= "" then
        landforms = json.decode(data.landform)
    end

    if type(landforms) ~= 'table' or not next(landforms) then
        landforms = createCrossBattleLandform()
        self.db:insert("battle_bid",{bid=bid,landform=json.encode(landforms),updated_at=getClientTs()})
    end 

    return landforms
end

----------------------------------------------------------------------------

local function setautocommit(self,value)
    assert(self.db.conn:setautocommit(value),'mysql transaction set failed')
end

local function commit(self)
    return self.db.conn:commit()
end

local function connect(self)
    self.db = getCrossDbo("crossserver")
end

local function writeCrossLog(log)
    writeLog(log,'crossserver')
end
----------------------------------------------------------------------------

local methods = {
    mkMatchList = mkMatchList,
    mkBattleUidKey = mkBattleUidKey,
    getBattleSeq = getBattleSeq,
    crossbattle = crossbattle,
    getRoundEvents=getRoundEvents,
    getRanking = getRanking,
    formatServerUserData = formatServerUserData,
    checkBattleData = checkBattleData,
    delDenyUserData = delDenyUserData,
    getBattleRoundTs = getBattleRoundTs,
    getCurrentRound = getCurrentRound,
    setChatMsg = setChatMsg,
    pushChat = pushChat,
    formatTroops = formatTroops,
    -- connection
    connect = connect,
    -- data
    setUserBattleData = setUserBattleData,
    getUserBattleData = getUserBattleData,
    getBattleDataByTime = getBattleDataByTime,
    setBattleDatas = setBattleDatas,
    getBattleDataByBid = getBattleDataByBid,
    updateUserBattleData = updateUserBattleData,
    countBattleDataByBid = countBattleDataByBid,
    -- report
    setBattleReport = setBattleReport,
    getBattleReport = getBattleReport,
    getCrossBattleLandform=getCrossBattleLandform,
    -- db
    setautocommit = setautocommit,
    commit = commit,
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
