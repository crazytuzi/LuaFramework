local acrossserver = {
    WIN=1, -- 胜者标识
    LOSE=2,    -- 败者标识
}

-------------------- tb name
local tbAlliance = "alliance"
local tbAllianceMember = "alliance_members"

-------------------- cache name
-- 本次跨服战的所有标识，按此标识来扫描
local stringAllBid = 'acrosswar.bid.all.%s.%s' -- group,weets
-- 按bid，分组将军团数据放入缓存
local hashBidAlliance = 'acrosswar.alliance.%s.%s.%s' -- bid, group, weets
-- 存放用户，一个用户一个key
local hashBidMember = 'acrosswar.members.%s.%s.%s.%s.%s' -- bid,zid,aid,uid weets
-- 存放用户的行动信息
local hashBidActions = 'acrosswar.actions.%s.%s.%s' -- bid, group, weets
-- 记录战场据点信息
local hashBidPlaces = "acrosswar.places.%s.%s.%s" -- bid, group, weets
-- 军团双方战斗分数
local hashBidAidPoint = "acrosswar.point.%s.%s.%s" -- bid, group, weets
-- 军团基地的耐久值和基地剩余部队数
local hashBidAidPlaceBlood = "acrosswar.blood.%s.%s.%s" -- bid, group, weets
-- 跨服战结束标识，提前结束，定时会继续扫描，如果有此标识，程序直接停止
local hashBidAidEndFlags = "acrosswar.endflags.%s" -- bid, group, weets
-- 跨服战击杀数，直接存成了json串，每次扫描的时候，不逐一据点入缓存，而用变量记录整个战场的击杀数，然后一起入缓存
local stringBidKillTroops = "acrosswar.kills.%s.%s.%s" -- bid, group, weets
-- 用户贡献值
local stringBidUsersDonate = "acrosswar.donate.%s.%s.%s" -- bid, group, weets
-- 记录军团长发出的军团指令
local hashAllianceCommandMsg = "acrosswar.commandmsg.%s" -- bid
-- 按军团记录加入战场的用户id，按此队列推送消息
local setAllianceMemId = "acrosswar.members.uids.%s.%s.%s.%s" -- bid,group,zidAid,weets

--------------------
-- 存放推送信息
local pushData = {}
-- 存放推送的所有用户
local pushUsers = {}
-- 存放军团杀敌数
local aKillTroops = {}
-- 存放用户的贡献
local usersDonate = {}
-- 胜利者
local battleWinners = {}
-- 用户信息
local battleUsersInfo = {}
-- 暂存战报信息
local battleReports = {}
-- 被炸的用户
local bombedUsers = {}

-- repair
local repairUserData = {}
local repairAllianceData = {}
-- 这个用来计数，因为修数据用了递归，防止没考虑到的情况他妈的出现了死循环，如果这个值大于20，直接把他弄死，要不机器就死了
local repairCount = 0

--------------------
-- 缓存过期时间
local expireTs = 72000
-- 本日凌晨时间戳
local asweets
-- 大战的战报模块type类型(战报中心)
local moduleReportType

-- buff对应的战斗属性
local buffAttribute = {
    b1 = {'dmg','maxhp','armor','arp'},
    b2 = {'accuracy','evade','crit','anticrit'},
}

-- 每轮(按胜败组)基础位置
local groupName2SortNum = {a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8}
local SortNum2GroupName = {'a','b','c','d','e','f','g','h'}

----------------------------------------------------------------------------

local getClientTs = getClientTs
local logn = math.logn

----------------------------------------------------------------------------

-- 生成标识
local function mkKey(...)
    local tmp = {...}
    return table.concat(tmp,'-')
end

-- 解析mkKey生成的标识
local function splitKey(key,...)
    local split = {}

    local strKey = string.split(key,'-')
    for k,v in pairs({...}) do
        split[v] = strKey[k]
    end

    return split
end

-- 生成缓存key
local function mkCacheKey(cacheKey,...)
    return string.format(cacheKey,...)
end

-- 获取战报的类型
local function getModuleReportType()
    if not moduleReportType then
        local reportCenter = require "lib/reportcenter"
        moduleReportType = reportCenter.getModuleType("across")
    end

    return moduleReportType
end

-- 返回回合产生的事件
-- table['产生季军轮次','产生冠军轮次']
-- 可依据此设置排名
local function getRoundEvents(num)
    return {logn(num,2)-1,logn(num,2)}
end

-- list 据点当前的人员列表
-- return 队列中的第一个用户和队列总用户数（如果攻打主基地，需要攻城部队数*基础掉血量来计算）
local function getPlaceBattleUser(list)
    if type(list) == 'table' then
        local users = {}
        local ucount = {}

        for k,v in pairs(list) do
            table.sort(v,function(a,b)
                if a.dist == b.dist then                    
                    return tonumber(a.uid) < tonumber(b.uid)
                else
                    return tonumber(a.dist) < tonumber(b.dist)
                end
            end)

            table.insert(ucount,#v)
            table.insert(users,v[1])
        end

        return users, ucount
    end
end

-- 按用户数据获取buff效果，这里会检测购买buff的日期，如果不是在今日购买的，会把buff置为0
-- 用今日时间戳来判断是因为，用户不管在什么情况下，每天都只能参加一次跨服战
local function getUserBuffs(userinfo)
    local buffs = {b1=0,b2=0,b3=0,b4=0}
    if (tonumber(userinfo.buff_at) or 0) >= asweets then
        buffs.b1 = tonumber(userinfo.b1) or 0
        buffs.b2 = tonumber(userinfo.b2) or 0
        buffs.b3 = tonumber(userinfo.b3) or 0
        buffs.b4 = tonumber(userinfo.b4) or 0
    end
    
    return buffs
end

-- 是否主基地
local function isBasePlace(place,basePlaces)
    return table.contains(basePlaces,place)
end

-- 格式化出来的用户数据返给客户端
-- 不需要binfo,hero,troops,updated_at字段
local function formatUserDataForClient(data)
    local userdata = {}
    local unField = {binfo=1,hero=1,updated_at=1,troops=1,heroAccessoryInfo=1}

    for k,v in pairs(data) do
        if not unField[k] then
            userdata[k] = v
        end
    end

    unField = nil

    return userdata
end

-- 格式化出来的军团数据返给客户端
-- 不需要binfo,hero,troops,updated_at字段
local function formatAllianceDataForClient(data)
    local alliancedata = {}

    local field = {
        aid=1,
        zid=1,
        name=1,
        logo=1,
        apply_at=1,
        donate_at=1,
        status=1,
        battle_at=1,
        teams=1,
        round=1,
        ranking=1,
        point=1,
        commander=1,
        level=1,
        fight=1,
        num=1,
    }

    for k,v in pairs(data) do
        if field[k] then
            if k == 'teams' or k == 'logo' then
                alliancedata[k] = json.decode(v) or {}
            else
                alliancedata[k] = v
            end
        end
    end

    field = nil

    return alliancedata
end

-- 设置本场跨服战需要推送的用户
local function setPushUsers(bid,group,data)
    local bgkey = mkKey(bid,group)
    pushUsers[bgkey] = data
end

-- 设置战斗中需要推送的数据
local function setBattlePushData(bid,group,data)
    local bgkey = mkKey(bid,group)
    if not pushData[bgkey] then pushData[bgkey] = {} end
    if next(data) then
        table.insert(pushData[bgkey],data)
    end
end

-- 推送数据
-- 会将5秒内，所有变化数据集中处理后，一并发给前端
local function battlePush(bid,group)
    local bgkey = mkKey(bid,group)
    local pushCmd = 'acrossserver.battle.push'

    if pushData[bgkey] and pushUsers[bgkey] then
        local pData = {}

        for k,v in pairs(pushData[bgkey]) do
            for k1,v1 in pairs(v) do
                if type(v1) == 'table' then
                    if not pData[k1] then pData[k1] = {} end
                    for k2,v2  in pairs(v1) do
                        pData[k1][k2] = v2
                    end
                else
                    pData[k1] = v1
                end
            end
        end

        local response = {
            data={acrossserver=pData},
            ret=0,
            cmd=pushCmd,
            ts = getClientTs(),
        }
        
        -- pData = {acrossserver=pData}

        for _,v in pairs(pushUsers[bgkey]) do
            if type(v) == 'table' then
                local uid = tonumber(v.uid)
                if uid then
                    response.data.acrossserver.isBomb = bombedUsers[uid] and 1 or 0
                    -- regSendMsg(uid,pushCmd,pData)

                    sendMsgByUid(uid,json.encode(response))
                end
            end
        end
    else
        if next(bombedUsers) then
            local pData = {
                acrossserver={
                    isBomb = 1
                }
            }

            for uid in pairs(bombedUsers) do
                local uid = tonumber(uid)
                if uid then
                    regSendMsg(uid,pushCmd,pData)
                end
            end
        end
    end 

end

-- 按击毁部队取得贡献值
local function getDonateByTroops(troops)
    local donate = 0
    local point = 0
    local tankCfg = getConfig('tank')

    for k,v in pairs(troops or {}) do
        if tankCfg[k] and tankCfg[k].point and (v or 0) > 0 then
            point = point + tankCfg[k].point * v
        end
    end

    if point > 0 then
        donate = donate + math.floor(math.sqrt(point)/20)
    end
    
    return donate
end

-- TODO
local function getBattleRoundTs(st)
    local sevCfg = getConfig("serverWarTeamCfg")
    local battleTime = {
        {
            st + sevCfg.startBattleTs[1][1] * 3600 + sevCfg.startBattleTs[1][2] * 60,
            st + sevCfg.startBattleTs[2][1] * 3600 + sevCfg.startBattleTs[2][2] * 60,
            st + sevCfg.startBattleTs[3][1] * 3600 + sevCfg.startBattleTs[3][2] * 60,
            st + sevCfg.startBattleTs[4][1] * 3600 + sevCfg.startBattleTs[4][2] * 60,
        },
        {
            st + 24 * 3600 + sevCfg.startBattleTs[1][1] * 3600 + sevCfg.startBattleTs[1][2] * 60,
            st + 24 * 3600 + sevCfg.startBattleTs[2][1] * 3600 + sevCfg.startBattleTs[2][2] * 60,
        },
        {
            st + 2 * 24 *3600 + sevCfg.startBattleTs[1][1] * 3600 + sevCfg.startBattleTs[1][2] * 60,
        },
    }

    local battleEndTime = {
        battleTime[1][4] + sevCfg.warTime + 180,
        battleTime[2][2] + sevCfg.warTime + 180,
        battleTime[3][1] + sevCfg.warTime + 180,
    }
    return battleTime,battleEndTime
end

-- TODO
local function getCurrentRound(st)
    local config = getConfig('serverWarTeamCfg')
    local ts = getClientTs()
    local roundInfo  = getRoundEvents(config.sevbattleAlliance)
    local maxRound = roundInfo[2]
    local _,battleTs = getBattleRoundTs (st)

    for i=1,maxRound do
        if i == 1 and ts <= battleTs[i] then
            return i
        end

        if i == maxRound then
            if ts > battleTs[i] then
                return i + 1
            end

            return i
        end

        if ts > battleTs[i] and ts <= battleTs[i+1] then
            return i + 1
        end
    end

end

--[[
    玩家进入战场,按aid存储玩家集合
    按军团推送或全地图推送数据时用到此集合

    param int uid 玩家id
    param int aid 玩家军团id
    param int zid 玩家的服id
]]
local function joinBattlefield(self,bid,uid,aid,zid,group)
    local aidKey = mkKey(zid,aid)
    local acKey1 = mkCacheKey(setAllianceMemId,bid,group,aidKey,asweets)

    self.redis:sadd(acKey1,uid)
    self.redis:expire(acKey1,expireTs)
end

--[[
    获取进入战场的成员
    有军团id就查军团的成员,否则查战场上的所有成员

    params int aid 军团id
]]
local function getAllianceMemUids(self,bid,aid,zid,group)
    local aidKey = mkKey(zid,aid)
    return self.redis:smembers(mkCacheKey(setAllianceMemId,bid,group,aidKey,asweets))
end

-- 检测战斗数据是否完整
-- 小组赛前才进行检测，如果数据不完整，直接补充一个空table占位
local function checkBattleData(data,sevbattleCfg)
    local playerNum = sevbattleCfg.sevbattleAlliance

    if type(data) == 'table' and next(data) then
        local dataLen = table.length(dataLen)

        if dataLen < playerNum then
            -- 按服id,服排名设置战斗数据标识
            local zData = {}
            for k,v in pairs(data) do
                local zid = tonumber(v.zid)
                if not zData[zid] then zData[zid] = {} end
                zData[zid][tonumber(v.zrank)] = 1
            end

            -- 按参加的服务器检测是否缺数据
            local servers = data[1].servers
            if type(servers) ~= 'table' then
                servers = json.decode(servers)
            end

            if type(servers) == 'table' then
                -- 每服应有的人数
                local znums = math.ceil(playerNum / #servers)

                for i=1,znums do
                    for _ , szid in pairs(servers) do
                        szid = tonumber(szid)

                        -- 如果没有此组服的数据，或者此组服数据中缺失数据
                        -- 按当前data数据补充npc
                        if not zData[szid] or not zData[szid][i] then
                            local tmpnpc = {
                                npc = 1
                            }

                            tmpnpc.zrank = i
                            tmpnpc.round = 1
                            tmpnpc.zid = szid
                            table.insert(data,tmpnpc)
                        end
                    end
                end
            end
        end
    end
    -- ptb:e(data)
    return data
end

-- 对分组赛进行排序
-- 无论开启几组服务器的跨服战，序号最小的服参赛的1到X名序号为1到X，序号第二小的服的1-X名序号为(X+1)到2X,依次类推
local function sortBattleDataByGroup(data)
    table.sort(data,function(a,b)
        if tonumber(a.zid) == tonumber(b.zid) then
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
local function getRanking (cfg,round,pos,status)
    round = tonumber(round)
    status = tonumber(status)
    
    if not cfg or not cfg[round] or not cfg[round][status] then
        writeLog({'getRanking err:',round=round,status=status,cfg=cfg},'getrankerr')
    end

    return cfg[round][status]
end

-- 格式化部队（处理成能战斗的格式，保存的时候是简化了的数据）
-- attField 属性字段
-- troops 部队数据
-- currTroops 当前存活下来的部队，如果有此值，需要将部队的数量和血量按当前数据重新计算
local function formatTroops(attField,troops,currTroops,buffs)
    local attTroops = {}

    for m,n in pairs(troops) do
        attTroops[m] = {}
        if n[1] then
            for k,v in pairs(attField) do
                attTroops[m][v] = n[k]
            end
        end
    end

    if #currTroops > 0 then
        for k,v in ipairs(currTroops) do
            if not next(v) or (v[2] or 0) <= 0 then
                attTroops[k] = {}
            else
                attTroops[k].num = v[2]
                attTroops[k].hp = v[2] * attTroops[k].maxhp
            end
        end
    end

    if buffs then
        local sevbattleCfg = getConfig("serverWarTeamCfg")
        for buff,lv in pairs(buffs) do
            lv = tonumber(lv) or 0
            if lv > 0 and buffAttribute[buff] then
                for _,attribute in ipairs(buffAttribute[buff]) do
                    for k,v in pairs(attTroops) do
                        if v[attribute] then
                            if buff == 'b1' then
                                attTroops[k][attribute] =  attTroops[k][attribute] * (1 + sevbattleCfg.buffSkill[buff].per * lv)
                                if attribute == 'maxhp' then
                                    attTroops[k].hp = attTroops[k].num * attTroops[k][attribute]
                                end
                            elseif buff == 'b2' then
                                attTroops[k][attribute] =  attTroops[k][attribute] + (sevbattleCfg.buffSkill[buff].per * lv)
                            end
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
local function getMatchListByPos(data,round)
    local list = {win={},lose={}}
    local win,lose = {}, {}

    -- 记录数据id对应data中的下标
    local id2data = {}

    for k,v in pairs(data) do
        if v.id then
            id2data[v.id] = k
            -- 胜利者，或者是已经打过的组（打过的组的round会比当前的round大一点），都进行当前轮的排名
            if tonumber(v.status) == acrossserver.WIN or tonumber(v.round) > round and not v.npc then
                table.insert(win,v)
            end
        end
    end

    -- 按位置排序后，相临近的两个出现在下一次比赛的相同位置
    table.sort(win,function (a,b) return a.pos < b.pos end)
    
    -- 胜者组与败者组的位置（A,B...）经过一轮后，会缩减一半
    for k,v in pairs(win) do
        local gname
        if tonumber(v.round) > round then
            gname = v.pos
        else
            local posNum = groupName2SortNum[v.pos]
            gname = SortNum2GroupName[math.ceil(posNum / 2)]
        end
        
        if not list.win[gname] then list.win[gname] = {} end
        table.insert(list.win[gname],id2data[v.id])
    end

    return list
end

local function getMatchListByLogPos(data,round)
    local list = {win={},lose={}}
    local win,lose = {}, {}

    -- 记录数据id对应data中的下标
    local id2data = {}

    for k,v in pairs(data) do
        if v.id then
            id2data[v.id] = k
            -- 胜利者，或者是已经打过的组（打过的组的round会比当前的round大一点），都进行当前轮的排名
            if tonumber(v.status) == acrossserver.WIN or tonumber(v.round) > round and not v.npc then
                if type(v.log) ~= 'table' then v.log = json.decode(v.log) end
                table.insert(win,v)
            end
        end
    end

    -- 按位置排序后，相临近的两个出现在下一次比赛的相同位置
    table.sort(win,function (a,b)
        return a.log[round-1][2] < b.log[round-1][2]
    end)

    -- 胜者组与败者组的位置（A,B...）经过一轮后，会缩减一半
    for k,v in pairs(win) do
        local gname
        if tonumber(v.round) > round then
            gname = v.pos
        else
            local posNum = groupName2SortNum[v.pos]
            gname = SortNum2GroupName[math.ceil(posNum / 2)]
        end

        if not list.win[gname] then list.win[gname] = {} end
        table.insert(list.win[gname],id2data[v.id])
    end

    return list
end

local function repairRoundData(self,list,round,allianceData)
    local roundTs
    local sevbattleCfg = getConfig("serverWarTeamCfg")

    for group,data in pairs(list) do
        table.sort(data,function(a,b)
            -- 如果战力一样，随机出一个，反正Lua循环本身就不是固定的，所以不用管了
            return (tonumber(a.fight) or 0) > (tonumber(b.fight) or 0)
        end)

        local i = 1
        for k,v in pairs(data) do
            local iswin = i == 1 and 1 or 2
            local teams = json.decode(v.teams) or {}
            if not roundTs then _,roundTs = getBattleRoundTs(tonumber(v.st) or 0) end

            if #teams > 0 then
                local pointInfo = self:getEndDonates(v.bid,group,v.zid,v.aid,json.decode(v.teams),iswin)
                if type(pointInfo) == 'table' then _, pointInfo = next(pointInfo) end

                for _,teamUid in pairs(teams) do
                    local teamUidPoint = pointInfo[tostring(teamUid)]
                    if teamUidPoint then
                        if iswin == 2 then teamUidPoint = teamUidPoint * 2 end -- 失败方给补偿
                        local tk = mkKey(v.bid,v.zid,v.aid,teamUid)
                        if not repairUserData[tk] then
                            repairUserData[tk] = {}
                        end

                        repairUserData[tk][round] = {bid=v.bid,zid=v.zid,aid=v.aid,uid=teamUid,point=teamUidPoint,group=group}
                    end
                end
            end

            local ranking = getRanking(sevbattleCfg.produceRank,round,group,iswin)

            for aK,aInfo in ipairs(allianceData) do
                if tonumber(aInfo.zid) == tonumber(v.zid) and tonumber(aInfo.aid) == tonumber(v.aid) and aInfo.bid == v.bid then
                    local roundLog = v.log or {}
                    if type(roundLog) ~= 'table'  then roundLog =  json.decode(v.log) or {} end
                    table.insert(roundLog,{round,group,iswin,})

                    aInfo.pos = group
                    aInfo.round = round + 1
                    aInfo.status = iswin
                    aInfo.updated_at = getClientTs()
                    aInfo.ranking = ranking
                    -- aInfo.point = tonumber(alliances.point) + 0
                    aInfo.pos = group
                    aInfo.log = roundLog
                    aInfo.basetroops = {}
                    aInfo.battle_at = roundTs[round]
                    repairAllianceData[mkKey(aInfo.bid,aInfo.zid,aInfo.aid)] = aInfo
                end
            end

            i = i + 1
        end
    end
end

local function setRepairDataToDb(self)
    self:setautocommit(false)

    for k,v in pairs(repairAllianceData) do
        self.updateAllianceData(self,v)
    end

    for k,v in pairs(repairUserData) do
        for round,pInfo in pairs(v) do
            self:setMemberRoundInfo({
                bid=pInfo.bid,
                pos=pInfo.group,
                zid=pInfo.zid,
                aid=pInfo.aid,
                round=round,
                uid=pInfo.uid,
                point=pInfo.point or 0,
            })
        end
    end

    self:commit()

    repairAllianceData = {}
    repairCount = 0
end

-- 检测当前轮次的数据是否正常
-- 当前轮次有可能缺少多轮的情况，要按最小的轮次算
-- npc 是否代入npc来计算对阵列表，只有round是1的时候才这样
-- 要是不成功，只会一组数据都不成功，所以不用考虑一组中，只有一条数据失败的情况
local function checkRoundData(self,data,round,matchList2,npc)
    repairCount = repairCount + 1
    assert(repairCount < 20,'reapir count error')

    local tmp = {}

    for k,v in pairs(data or {}) do
        local dRound = tonumber(v.round) or 0
        if v.status ~= acrossserver.LOSE then
            local insert = true
            if v.npc ==1 and not npc then
                insert = false
            end

            if tonumber(v.status) == 2 then
                insert = false
            end

            if insert then
                if not tmp[dRound] then tmp[dRound] = {} end
                table.insert(tmp[dRound],v)
            end
        end
    end

    if tmp[1] then
        local n = 0
        for k,v in pairs(tmp[1]) do
            if not v.npc then
                n = n + 1
                break
            end
        end
        if n == 0 then tmp[1] = nil end
    end

    for i=1,round-1 do
        if tmp[i] then
            if i == 1 then
                local list = {}
                local tmplist = sortBattleDataByGroup(data)

                for k,v in pairs(matchList2) do
                    k = SortNum2GroupName[k]
                    list[k] = {}
                    for _,n in ipairs(v) do
                        local tmp = data[n] or {}
                        if tmp.npc == 1 or (tonumber(tmp.round) > i) then tmp = {} end
                        table.insert(list[k],copyTab(tmp))
                    end
                end

                repairRoundData(self,list,i,data)
                return checkRoundData(self,data,round,matchList2)
            else
                local list = {}
                local pos2List = getMatchListByLogPos(data,i)
                for g,gdata in pairs(pos2List) do
                    for gname,ginfo in pairs(gdata) do
                        list[gname] = {}
                        for _,n in ipairs(ginfo) do
                            -- data[n].binfo = nil     -- TEST
                            if tonumber(data[n].round) <= i then
                                table.insert(list[gname],data[n])
                            end
                        end
                    end
                end

                repairRoundData(self,list,i,data)
                return checkRoundData(self,data,round,matchList2)
            end
        end
    end

    setRepairDataToDb(self)
end

-- 生成下一轮战斗匹配队列
-- 第一轮(round为0时)是小组赛
-- 其它轮为淘汰赛
-- roundEvents 如果是最后一轮，需要将败者组的人拉入胜者组，决出冠军
local function mkMatchList(data,matchList,round)
    if not data or not next(data) or not round then return {} end

    local list = {}

    if round == 1 then
        data = sortBattleDataByGroup(data)

        for k,v in pairs(matchList) do
            k = SortNum2GroupName[k]
            list[k] = {}
            for _,n in ipairs(v) do
                local tmp = data[n] or {}
                if tmp.npc == 1 then tmp = {} end
                table.insert(list[k],tmp)
            end
        end
    else
        local pos2List = getMatchListByPos(data,round)        
        for g,gdata in pairs(pos2List) do
            for gname,ginfo in pairs(gdata) do
                list[gname] = {}
                for _,n in ipairs(ginfo) do
                    -- data[n].binfo = nil     -- TEST
                    table.insert(list[gname],data[n])
                end
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
    local totalnum = 0

    for k,v in pairs(initTroopsInfo) do
        if (tonumber(v.num) or 0) > 0 then
            table.insert(troops,{v.id,v.num})
            totalnum = totalnum + v.num
        else
            table.insert(troops,{})
        end
    end

    if totalnum <= 0 then
        troops = {}
    end

    return troops
end

-- 从战斗后的部队数据中获取胜余的坦克数量
-- return table, table
local function getDieTroopsByInavlidFleet(fleetinfo,invalidFleet)
    local troops = {}

    for k,v in pairs(fleetinfo) do
        if (v[2] or 0) > 0 then
            local dienum = v[2] - (invalidFleet[k] and invalidFleet[k][2] or 0)

            if dienum > 0 then
                troops[v[1]] = (troops[v[1]] or 0) + dienum
            end
        end
    end

    return troops
end

-- 获取战斗攻击出手顺序
local function getBattleSeq(battleInfo1,battleInfo2,owner)
    local attSeq

    if battleInfo1.dist > battleInfo2.dist  then
        attSeq = 1
    elseif battleInfo1.dist == battleInfo2.dist then
        if mkKey(battleInfo1.zid,battleInfo1.aid) == owner then
            attSeq = 1
        elseif mkKey(battleInfo2.zid,battleInfo2.aid) == owner then
            attSeq = 2
        else
            attSeq = 1
        end
    else
        attSeq = 2
    end

    return attSeq
end

local function basePlaceBattle(aUserinfo,aBattleTroops,baseTroops)
    local fleetInfo1 = aUserinfo.binfo
    local aUserBuffs = getUserBuffs(aUserinfo)
    local aUserBuff = {b1=aUserBuffs.b1,b2=aUserBuffs.b2}

    local inning = 1
    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][inning],aBattleTroops,aUserBuff)
    local defFleetInfo = baseTroops

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInvalidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.r, aInvalidFleet, dInvalidFleet, attSeq, setPoint = battle(aFleetInfo,defFleetInfo)

    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    local aDieTroops = getDieTroopsByInavlidFleet(aTroops,aAliveTroops)
    local dDieTroops = getDieTroopsByInavlidFleet(dTroops,dAliveTroops)

    report.t = {dTroops,aTroops}
    report.h = {{},{}}
    report.se = {0,0}

    if fleetInfo1[3] and fleetInfo1[3][inning] then
        report.h[2] = fleetInfo1[3][inning]
    end

    if fleetInfo1[4] then
        report.se[2] = fleetInfo1[4]
    end 

    return report, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops
end

-- 战斗
local function crossbattle(aUserinfo,aBattleTroops,dUserinfo,dBattleTroops)
    local fleetInfo1 = aUserinfo.binfo
    local fleetInfo2 = dUserinfo.binfo
    local aUserBuffs = getUserBuffs(aUserinfo)
    local dUserBuffs = getUserBuffs(dUserinfo)
    local aUserBuff = {b1=aUserBuffs.b1,b2=aUserBuffs.b2}
    local dUserBuff = {b1=dUserBuffs.b1,b2=dUserBuffs.b2}

    local inning = 1
    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][inning],aBattleTroops,aUserBuff)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][inning],dBattleTroops,dUserBuff)

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInvalidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.r, aInvalidFleet, dInvalidFleet, attSeq, setPoint = battle(aFleetInfo,defFleetInfo)

    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    local aDieTroops = getDieTroopsByInavlidFleet(aTroops,aAliveTroops)
    local dDieTroops = getDieTroopsByInavlidFleet(dTroops,dAliveTroops)

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if fleetInfo1[3] and fleetInfo1[3][inning] then
        report.h[2] = fleetInfo1[3][inning]
    end

    if fleetInfo2[3] and fleetInfo2[3][inning] then
        report.h[1] = fleetInfo2[3][inning]
    end

    report.se={0, 0}
    if fleetInfo1[4] then
        report.se[2] = fleetInfo1[4] --a
    end    
    if fleetInfo2[4] then
        report.se[1] = fleetInfo2[4] -- d
    end
    
    return report, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops
end

local function getStartBattleTsByGroup(group,cfg)
    local timeInfo = cfg.startBattleTs[groupName2SortNum[group]]
    return asweets + timeInfo[1] * 3600 + timeInfo[2] * 60
end

local function getEndBattleTsByGroup(group,cfg)
    return getStartBattleTsByGroup(group,cfg) + cfg.warTime
end

local function checkShowCountryRoad(group,cfg,ts)
    ts = ts or getClientTs()
    local showTs = getStartBattleTsByGroup(group,cfg) +  cfg.countryRoadTime

    return ts >= showTs
end

----------------------------------------------------------------------------

local function getAllianceDataByTime(self,endRound,ts)
    ts = ts or getClientTs()
    return self.db:getAllRows("select * from alliance where status != 2 and round <= :endRound and st < :ts and et > :lts limit 600",{ts=ts,lts=ts-86400,endRound=endRound} )
end

local function getAllianceFromDb(self,endRound,ts)
    ts = ts or getClientTs()
    -- return self.db:getAllRows("select * from alliance where status != 2 and round <= :endRound and st < :ts and et > :lts limit 600",{ts=ts,lts=ts,endRound=endRound} )
    return self.db:getAllRows("select * from alliance where round <= :endRound and st < :ts and et > :lts limit 600",{ts=ts,lts=ts,endRound=endRound} )
end

-- 根据BID获取跨服数据
local function getAllianceFromDbByBid(self,bid)
    return self.db:getAllRows("select * from alliance where bid = :bid  limit 50",{bid=bid} )
end

-- 每次开战前5分钟不允许修改军团数据，此时可以初始化军团数据，进入缓存
local function initAllianceData(self,group,endRound,ts)
    local stringAllBidKey = mkCacheKey(stringAllBid,group,asweets)

    local data = getAllianceFromDb(self,endRound,ts)

    if not next(data) then
        return  nil
    end

    local hdata = {}
    local tmpAllianceData = {}

    for _,v in pairs(data) do
        if not tmpAllianceData[v.bid] then  tmpAllianceData[v.bid] = {} end
        table.insert(tmpAllianceData[v.bid],v)
    end

    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local matchList2= sevbattleCfg.matchList2

    for k,v in pairs(tmpAllianceData) do
        local warSt = tonumber(v[1].st)
        local currRound = getCurrentRound(warSt)
        if currRound == 1 then
            v = checkBattleData(v,sevbattleCfg)
        end
        local tmpList = mkMatchList(v,matchList2,currRound)
        
        if type(tmpList[group]) == 'table' and next(tmpList[group]) then
            table.insert(hdata,k)
            
            local hashBidAllianceKey = mkCacheKey(hashBidAlliance,k,group,asweets)
            local tmp = {}
            for _,n in pairs(tmpList[group]) do
                if next(n) then
                    n.pos = group
                    tmp[mkKey(n.zid,n.aid)] = json.encode(n)
                end
            end

            if next(tmp) then
                local setret
                for i=1,2 do
                    setret = self.redis:hmset(hashBidAllianceKey,tmp)
                    self.redis:expire(hashBidAllianceKey,expireTs)
                    if setret then break end
                end

                if not setret then writeCrossLog('initAllianceData set cache faile:' .. (json.encode(tmp) or 'json tmp is nil')) end
            end
        end
    end

    for i=1,2 do
        local rr = self.redis:set(stringAllBidKey,json.encode(hdata))
        self.redis:expire(stringAllBidKey,expireTs)
        if rr then break end
    end

    return hdata
end

-- 按分组获取匹配列表（数据直接读数据库）
local function getMatchListByGroupFromDb(self,bid,group)
    local data = getAllianceFromDbByBid(self,bid)

    if not next(data) then
        return  nil
    end

    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local matchList2= sevbattleCfg.matchList2
    local warSt = tonumber(data[1].st)
    local currRound = getCurrentRound(warSt)
    if currRound == 1 then
        data = checkBattleData(data,sevbattleCfg)
    end
    local tmpList = mkMatchList(data,matchList2,currRound)

    local list = {}
    local tmp = {}
    
    if tmpList and type(tmpList[group]) == 'table' then
        local hashBidAllianceKey = mkCacheKey(hashBidAlliance,bid,group,asweets)

        for _,n in pairs(tmpList[group]) do
            if next(n) then
                n.pos = group
                n.basetroops = json.decode(n.basetroops) or {}
                n.log = json.decode(n.log) or {}
                n.servers = json.decode(n.servers) or {}
                n.teams = json.decode(n.teams) or {}

                tmp[mkKey(n.zid,n.aid)] = json.encode(n)
                list[mkKey(n.zid,n.aid)] = n
            end
        end

        if next(tmp) then
            self.redis:hmset(hashBidAllianceKey,tmp)
            self.redis:expire(hashBidAllianceKey,expireTs)
        end
    end

    return list
end

-- 获取今日有战斗的所有bid
local function getAllBid(self,group,endRound,ts)
    local cacheKey = mkCacheKey(stringAllBid,group,asweets)

    if not self.redis:exists(cacheKey) then
        return initAllianceData(self,group,endRound,ts)
    end

    local hdata = self.redis:get(cacheKey)
    hdata = hdata and json.decode(hdata) or {}

    return hdata
end

-- 按bid获取军团数据
-- endRound 比赛结束的轮次
-- group 当前的组
local function getAllianceData(self,bid,group)
    local data = {}
    local round = 0
    local endRound = 3

    local hashBidAllianceKey = mkCacheKey(hashBidAlliance,bid,group,asweets)

    -- TODO 如果没有取到，是否检测一下数据库？
    local hdata =  self.redis:hgetall(hashBidAllianceKey)
    if not next(hdata) then
        initAllianceData(self,group,endRound)
        hdata =  self.redis:hgetall(hashBidAllianceKey)
    end

    if type(hdata) == 'table' and next(hdata) then
        for k,v in pairs(hdata) do
            data[k] = json.decode(v)

            if type(data[k]) == 'table' then
                data[k].basetroops = json.decode(data[k].basetroops) or {}
                data[k].teams = json.decode(data[k].teams) or {}
                data[k].servers = json.decode(data[k].servers)
                data[k].log = data[k].log and json.decode(data[k].log) or {}
                round = tonumber(data[k].round) or 0
            end
        end
        hdata = nil
    end

    return data, round
end

-- 设置参战军团数据
local function setAllianceData(self,data)
    local ret, err

    if data.bid and data.et then
        data.updated_at = getClientTs()
        data.apply_at = data.updated_at
        ret = self.db:insert(tbAlliance,data)
        if not ret then err = self.db:getError() end
    end

    return ret, err
end

-- 设置战斗结束标识
local function setAllianceEndBattleFlag(self,bid,group,winner)
    winner = winner or 1
    local endKey = mkCacheKey(hashBidAidEndFlags,asweets)
    self.redis:hset(endKey,mkKey(bid,group),winner)
    self.redis:expire(endKey,864000)
end

-- 获取战斗结束标识
local function getAllianceEndBattleFlag(self,bid,group)
    local endKey = mkCacheKey(hashBidAidEndFlags,asweets)
    local battleFlag = mkKey(bid,group)
    local flag = self.redis:hget(endKey,battleFlag)

    if flag then
        battleWinners[battleFlag] = flag
    end

    return flag
end

-- 军团结束战斗
local function allianceEndBattle(self,data)
    local ret, err

    data.updated_at = getClientTs()

    ret = self.db:update(tbAlliance,data,string.format("bid = '%s' and zid = '%s' and aid = '%s' and battle_at <  '%s'",data.bid,data.zid,data.aid,asweets))

    if not ret then err = self.db:getError() end

    return (ret and ret > 0) , err
end

-- 修改军团数据
-- 需要在api里验证是哪个组，然后判定是否是开战5分钟前
local function updateAllianceData(self,data)
    local ret, err

    data.updated_at = getClientTs()
    ret = self.db:update(tbAlliance,data,string.format("bid = '%s' and zid = '%s' and aid = '%s'",data.bid,data.zid,data.aid))

    if not ret then err = self.db:getError() end

    return ret, err
end

local function setUserDataToCache(self,data)
    local ret
    local memKey = mkCacheKey(hashBidMember,data.bid,data.zid,data.aid,data.uid,asweets)
    local cacheData = {}

    for k,v in pairs(data) do
        cacheData[k] = type(v) == 'table' and json.encode(v) or v
    end

    if next(cacheData) then
        ret = self.redis:hmset(memKey,cacheData)
        self.redis:expire(memKey,expireTs)
        cacheData = nil
    end

    return ret
end

-- 插入跨服战用户数据
local function setUserBattleData (self,data)
    local ret, err
    local ckey = mkKey(data.bid,data.zid,data.aid,data.uid)

    data.updated_at = getClientTs()
    ret = self.db:insert(tbAllianceMember,data)

    if ret then 
        setUserDataToCache(self,data)
    else
        err = self.db:getError()
    end

    return ret, err
end

-- 修改跨服战用户数据
local function updateUserBattleData(self,data)
    local ret, err

    data.updated_at = getClientTs()
    ret = self.db:update(tbAllianceMember,data,string.format("bid = '%s' and zid = '%s'  and uid = '%s'",data.bid,data.zid,data.uid))

    if not ret or ret <= 0 then
        err = self.db:getError()
        ret = false
    else
        ret = setUserDataToCache(self,data)
    end

    return ret, err
end

-- 直接将积分加到数据库
local function addUserPointToDb(self,bid,zid,aid,uid,point)
    point = tonumber(point) or 0
    if point > 0 then
        return self.db:query(string.format("update %s set point = point + %d where bid = %s,zid = %s and aid = %s and uid = %s",tbAllianceMember,point,bid,zid,aid,uid))
    end
end

local function getUserDataFromDb(self,bid,zid,aid,uid)
    return self.db:getRow("select * from " .. tbAllianceMember .. " where zid=:zid and uid=:uid and bid=:bid and aid = :aid",{uid=uid,zid=zid,bid=bid,aid=aid})
end

local function getUserInFo(self,bid,zid,uid)
    return self.db:getRow("select gems from " .. tbAllianceMember .. " where zid=:zid and uid=:uid and bid=:bid ",{uid=uid,zid=zid,bid=bid})
end


-- 获取用户跨服数据
local function getUserData(self,bid,zid,aid,uid)
    local memKey = mkCacheKey(hashBidMember,bid,zid,aid,uid,asweets)

    local data = self.redis:hgetall(memKey)

    if type(data) ~= 'table' or not next(data)  then
        local dbData = getUserDataFromDb(self,bid,zid,aid,uid)

        if type(dbData) == 'table' then
            setUserDataToCache(self,dbData)
        end

        data = dbData
    end

    if data then
        if data.uid then
            local ukey = mkKey(bid,zid,aid,uid)
            battleUsersInfo[ukey] = data
        end

        if data.heroAccessoryInfo then
            data.heroAccessoryInfo = json.decode(data.heroAccessoryInfo)
        end

        if data.binfo then
            data.binfo = json.decode(data.binfo)
        else data.binfo = {}
        end
    end

    return data
end

local function getLocalUserData(self,bid,zid,aid,uid)
    local ukey = mkKey(bid,zid,aid,uid)
    if battleUsersInfo[ukey] then
        return battleUsersInfo[ukey]
    end

    return getUserData(self,bid,zid,aid,uid)
end

-- 获取用户基地
local function getGroupBasePlace(self,bid,group)
    local allianceData = getAllianceData(self,bid,group)

    if type(allianceData) == 'table' then
        local tmp = {}

        for k,v in pairs(allianceData) do
            table.insert(tmp,v)
        end

        table.sort(tmp,function(a,b)
            if a.apply_at == b.apply_at then
                if a.zid == b.zid then
                    return a.aid < b.aid
                else
                    return a.zid < b.zid
                end
            else
                return a.apply_at < b.apply_at
            end
        end
        )

        local mapCfg = getConfig('serverWarTeamMapCfg1')
        local cfg = mapCfg.baseCityID
        local flagInfo = {}

        if tmp[1] then
            local rk = mkKey(tmp[1].zid,tmp[1].aid) -- red
            flagInfo[rk]=cfg[1]
        end

        if tmp[2] then
            local bk = mkKey(tmp[2].zid,tmp[2].aid) -- blue
            flagInfo[bk] = cfg[2]
        end

        return flagInfo
    end
end

local function setUserActionInfo(self,bid,group,zid,aid,uid,data)
    local acKey = mkCacheKey(hashBidActions,bid,group,asweets)
    local uKey = mkKey(zid,aid,uid)

    if not data.basePlace or data.basePlace == 0 then
        local basePlaceInfo = getGroupBasePlace(self,bid,group)
        data.basePlace = basePlaceInfo[mkKey(zid,aid)]
    end

    if not data.target or data.target == 0 then
        data.target = data.basePlace
        data.dist = getClientTs()
    end

    if not data.battle_at then data.battle_at = getClientTs() end

    data.ts = getClientTs()
    local ret = self.redis:hset(acKey,uKey,json.encode(data))
    self.redis:expire(acKey,expireTs)

    return ret, data,uKey
end

-- bid,group,zid,aid,uid,basePlace
local function resetUserActionInfo(self,data)
    data = data or {}
    data.basePlace = data.basePlace or 0
    data.pos=0
    data.troops={}
    data.st=getClientTs()
    data.dist=getClientTs()
    data.target=nil
    data.zid=data.zid
    data.aid=data.aid
    data.uid=data.uid
    data.nickname = data.nickname
    data.aname = data.aname
    data.role = data.role
    data.pos = data.basePlace
    data.group = data.group
    data.speedUpNum = 0

    return setUserActionInfo(self,data.bid,data.group,data.zid,data.aid,data.uid,data)
end

local function getUserActionInfo(self,bid,group,zid,aid,uid)
    local acKey = mkCacheKey(hashBidActions,bid,group,asweets)
    local uKey = mkKey(zid,aid,uid)
    local data = self.redis:hget(acKey,uKey)

    if not data then
        local userinfo = getUserData(self,bid,zid,aid,uid)
        if userinfo then
            local setret, setdata = resetUserActionInfo(self,{bid=bid,group=group,zid=zid,aid=aid,uid=uid,nickname=userinfo.nickname,aname=userinfo.aname,role=userinfo.role})
            if setret then
                return setdata
            end
        end
    end

    data = data and json.decode(data)

    return data
end

-- 获取所有用户行动信息
local function getUsersActionInfo(self,bid,group)
    local info = {}

    local acKey = mkCacheKey(hashBidActions,bid,group,asweets)
    local data = self.redis:hgetall(acKey)

    if type(data) == 'table' and next(data) then
        for k,v in pairs(data) do
            info[k] = json.decode(v)
        end
    end

    setPushUsers(bid,group,info)

    return info
end

local function setPlaceInfo( self,bid,group,placeId,zid,aid )
    local acKey = mkCacheKey(hashBidPlaces,bid,group,asweets)
    local zidAid = mkKey(zid,aid)
    local ret = self.redis:hset(acKey,placeId,zidAid)
    self.redis:expire(acKey,expireTs)

    return ret,zidAid
end

local function getPlaceInfo(self,bid,group,placeId)
    local acKey = mkCacheKey(hashBidPlaces,bid,group,asweets)
    return self.redis:hget(acKey,placeId)
end

local function getPlacesInfo(self,bid,group)
    local acKey = mkCacheKey(hashBidPlaces,bid,group,asweets)
    return self.redis:hgetall(acKey)
end

local function getPlacesUsersList(self,bid,group)
    local battlePlaces = {}
    local ts = getClientTs()

    -- 所有用户行动信息
    local usersActionInfo = getUsersActionInfo(self,bid,group)

    for _,userActionInfo in pairs(usersActionInfo or {}) do
        -- TEST
        -- userActionInfo.dist = 0
        -- userActionInfo.target = 'a6'

        if userActionInfo.dist <= ts and userActionInfo.target and (userActionInfo.revive or 0) <= ts then
            if not battlePlaces[userActionInfo.target] then
                battlePlaces[userActionInfo.target] = {}
            end

            local zidAid = mkKey(userActionInfo.zid,userActionInfo.aid)

            if not battlePlaces[userActionInfo.target][zidAid] then
                battlePlaces[userActionInfo.target][zidAid] = {}
            end

            table.insert(battlePlaces[userActionInfo.target][zidAid],userActionInfo)

        end
    end

    return battlePlaces
end

local function addPoint(self,bid,group,zidAid,point)
    if point <= 0 then point = 0 end
    point = math.floor(tonumber(point))

    local acKey = mkCacheKey(hashBidAidPoint,bid,group,asweets)
    local ret = self.redis:hincrby(acKey,zidAid,point)
    self.redis:expire(acKey,expireTs)

    return tonumber(ret) or 0
end

local function getPoint(self,bid,group)
    local acKey = mkCacheKey(hashBidAidPoint,bid,group,asweets)
    local data = self.redis:hgetall(acKey)

    return data
end

-- 主基地掉耐久
local function deBasePlaceBlood(self,bid,group,place,num)
    local acKey = mkCacheKey(hashBidAidPlaceBlood,bid,group,asweets)
    num = math.floor(tonumber(num))

    local blood = self.redis:hincrby(acKey,place,num)
    self.redis:expire(acKey,expireTs)

    return blood
end

local function getBasePlaceBlood(self,bid,group)
    local acKey = mkCacheKey(hashBidAidPlaceBlood,bid,group,asweets)

    return self.redis:hgetall(acKey) or {}
end

local function getBasePlaceTroops(self,bid,group,place)
    local acKey = mkCacheKey(hashBidAidPlaceBlood,bid,group,asweets)
    local tk = mkKey(place,'die')
    local data = self.redis:hget(acKey,tk)
    self.redis:expire(acKey,expireTs)

    return json.decode(data)
end

local function setBasePlaceTroops(self,bid,group,place,troopsInfo)
    local acKey = mkCacheKey(hashBidAidPlaceBlood,bid,group,asweets)
    local tk = mkKey(place,'die')
    local ret = self.redis:hset(acKey,tk,json.encode(troopsInfo))
    self.redis:expire(acKey,expireTs)

    return ret
end

local function getAllianceApplyData(self,bid,zid,aid)
    return self.db:getRow("select * from alliance where aid=:aid and bid=:bid ",{aid=aid,bid=bid,zid=zid} )
end

local function getAllianceKillTroops(self,bid,group,count)
    local acKey = mkCacheKey(stringBidKillTroops,bid,group,asweets)

    local cacheData = self.redis:get(acKey)
    cacheData = json.decode(cacheData)
    if type(cacheData) ~= 'table' then
        cacheData = {}
    end

    -- 需要统计总的击杀数量
    local killCount = {}
    if count then
        for k,v in pairs(cacheData) do
            killCount[k] = 0
            if type(v) == 'table' then
                for _,num in pairs(v) do
                    killCount[k] = killCount[k] + (tonumber(num) or 0)
                end
            end
        end
    end

    return cacheData,acKey,killCount
end

local function addAllianceKillTroops(bid,group,zid,aid,troops)
    if type(troops) == 'table' then
        local bgk = mkKey(bid,group)
        local zak = mkKey(zid,aid)
        if not aKillTroops[bgk] then aKillTroops[bgk] = {} end
        if not aKillTroops[bgk][zak] then aKillTroops[bgk][zak] = {} end

        for k,v in pairs(troops) do
            aKillTroops[bgk][zak][k] = (aKillTroops[bgk][zak][k] or 0) + v
        end
    end
end

-- 直接存json串吧，没有并发，如果用incrby的话，有多少种部队种类就得调多少次redis，
-- 用json串的话，只需要先取，然后把数量叠加上，再存就好了
local function setAllianceKillTroops(self,bid,group)
    local bgk = mkKey(bid,group)

    if aKillTroops[bgk] then
        local cacheData,acKey = getAllianceKillTroops(self,bid,group)

        local setFlag = false
        for k,v in pairs(aKillTroops[bgk]) do
            if not cacheData[k] then cacheData[k] = {} end
            for aid,anum in pairs(v) do
                if anum > 0 then
                    cacheData[k][aid] = ( cacheData[k][aid] or 0 ) + anum
                    setFlag = true
                end
            end
        end

        if setFlag then
            self.redis:set(acKey,json.encode(cacheData))
            self.redis:expire(acKey,expireTs)
        end
    end

end

local function getUserDonate(self,bid,group)
    local acKey = mkCacheKey(stringBidUsersDonate,bid,group,asweets)
    local cacheData = self.redis:get(acKey)
    cacheData = json.decode(cacheData)

    if type(cacheData) ~= 'table' then cacheData = {} end

    return cacheData,acKey
end

local function addUserDonate(bid,group,zid,aid,uid,donate)
    if donate > 0 then
        local bgk = mkKey(bid,group)
        local zak = mkKey(zid,aid)
        if not usersDonate[bgk] then usersDonate[bgk] = {} end
        if not usersDonate[bgk][zak] then usersDonate[bgk][zak] = {} end

        uid = tostring(uid)
        usersDonate[bgk][zak][uid] = (usersDonate[bgk][zak][uid] or 0) + donate
    end
end

local function addUserDonateByTroops(bid,group,zid,aid,uid,troops,iswin)
    local donate = getDonateByTroops(troops)
    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local cfgDonate = iswin == 1 and sevbattleCfg.winDonate or sevbattleCfg.loseDonate
    donate = donate + cfgDonate

    addUserDonate(bid,group,zid,aid,uid,donate)
end

local function setUsersDonate(self,bid,group)
    local bgk = mkKey(bid,group)

    if  usersDonate[bgk] then
        local cacheData,acKey = getUserDonate(self,bid,group)

        local setFlag = false
        for k,v in pairs(usersDonate[bgk]) do
            if not cacheData[k] then cacheData[k] = {} end
            for uid,donate in pairs(v) do
                if donate > 0 then
                    cacheData[k][uid] = ( cacheData[k][uid] or 0 ) + donate
                    setFlag = true
                end
            end
        end

        if setFlag then
            self.redis:set(acKey,json.encode(cacheData))
            self.redis:expire(acKey,expireTs)
        end
    end

end

-- 获取结束时的军团和个人贡献值
-- return 军团总贡献和用户的
local function getEndDonates(self,bid,group,zid,aid,teams,iswin)
    local adonates = {}
    local udonates = {}

    local usersDonate = getUserDonate(self,bid,group)
    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local cfgPoint = iswin == 1 and sevbattleCfg.winPoint or sevbattleCfg.losePoint
    local cfgPersonalPoint = iswin == 1 and sevbattleCfg.personalWinPoint or sevbattleCfg.personalLosePoint
    local zidAid = mkKey(zid,aid)
    local tmpDonate = {}

    if usersDonate[zidAid] then
        adonates[zidAid] = 0
        for uid,donate in pairs(usersDonate[zidAid]) do
            if donate > 0 then
                local uinfo = getLocalUserData(self,bid,zid,aid,uid)
                local uBuffs = getUserBuffs(uinfo)
                local buffLv = uBuffs.b3
                if buffLv > 0 then
                    donate = donate + donate * buffLv * sevbattleCfg.buffSkill.b3.per
                end
                local tDonate = math.sqrt(donate)
                tmpDonate[uid] = tDonate
                adonates[zidAid] = adonates[zidAid] + tDonate
            end
        end
    end

    teams = getAllianceMemUids(self,bid,aid,zid,group)
    
    if type(teams) == 'table' then
        udonates[zidAid] = {}
        local totalDonate = adonates[zidAid] or 0
        totalDonate = totalDonate + (#teams - table.length(tmpDonate)) * 1
        for _,uid in ipairs(teams) do
            uid = tostring(uid)
            local donate = tmpDonate[uid] or 1
            if totalDonate > 0 then
                local rate = donate / totalDonate
                if rate > 0.2 then rate = 0.2 end
                udonates[zidAid][uid] = math.floor(rate * cfgPoint + cfgPersonalPoint)
            else
                udonates[zidAid][uid] = cfgPersonalPoint
            end
        end
    end

    return udonates
end

---------------------- 结算相关

local function setAllianceRoundInfo(self,info)
    local data = {}
    data.updated_at = getClientTs()
    data.bkey = mkKey(info.bid,info.round,info.pos)
    data.aid = info.aid
    data.zid = info.zid
    data.point = info.point
    data.kills = json.encode(info.kills)
    return self.db:insert("alliance_roundinfo",data)
end

local function getAllianceRoundInfo(self,bid,group,zid,round)
    local bkey = mkKey(bid,round,group)
    return self.db:getAllRows("select * from alliance_roundinfo where bkey=:bkey limit 2",{bkey=bkey})
end

local function setMemberRoundInfo(self,info)
    local data = {}
    data.updated_at = getClientTs()
    data.bkey = mkKey(info.bid,info.zid,info.aid,info.round,info.pos,info.uid)
    data.point=info.point

    return self.db:insert("alliance_member_roundinfo",data)
end

local function getMemberRoundInfo(self,bid,group,zid,aid,uid,round)
    local bkey = mkKey(bid,zid,aid,round,group,uid)
    return self.db:getRow("select * from alliance_member_roundinfo where bkey=:bkey limit 1",{bkey=bkey})
end

-- 所有的结口如果检测到游戏结束后，都需要返回固定格式的结束数据
-- 直接调这个方法简单粗暴
local function getOverData(self,bid,group,zid,aid,uid,round)
    local points = getPoint(self,bid,group)
    local _,_,kills = getAllianceKillTroops(self,bid,group,true)
    local userRoundInfo = getMemberRoundInfo(self,bid,group,zid,aid,uid,round)
    local userPoint = userRoundInfo and userRoundInfo.point or 0
    local zidAid = mkKey(zid,aid)

    return {
        winner = battleWinners[mkKey(bid,group)],
        points = points or {},
        kills = kills or 0,
        uPoints = {[zidAid] = {[tostring(uid)]=userPoint}}
    }
end

-- 设置跨服战战报
local function setBattleReport(self,data,isBase)
    data.updated_at = getClientTs()

    -- local ret = self.db:insert("alliance_battlelog",data)
    -- if not ret then writeLog(self.db:getError() or 'no report error','setReport') end
    local ret = true

    local reportType = getModuleReportType()

    local attReport = {
        user_id = data.attId,
        alliance_id = data.attAid,
        ext1 = data.bid,
        ext2 = data.round,
        ext3 = data.pos,
        ext4 = 1,
        type = reportType,
        data=data,
        updated_at=data.updated_at,
    }

    -- 全局战报
    if data.type == 1 or data.type == 2 then
        attReport.ext5 = 1
    end

    -- 攻击方生成一条战报
    table.insert(battleReports,attReport)

    if not isBase then
        -- 防守方生成一条战报
        table.insert(battleReports,{
            user_id = data.defId,
            alliance_id = data.defAid,
            ext1 = data.bid,
            ext2 = data.round,
            ext3 = data.pos,
            ext4 = 1,
            type = reportType,
            data=data,
            updated_at=data.updated_at,
        })
    end

    return ret
end

local function setbombReport(self,data)
    local reportType = getModuleReportType()
    data.updated_at = getClientTs()

    table.insert(battleReports,{
        user_id = data.defId,
        alliance_id = data.defAid,
        ext1 = data.bid,
        ext2 = data.round,
        ext3 = data.pos,
        -- ext4 = data.type,
        ext4 = 1,
        type = reportType,
        data=data,
        updated_at = data.updated_at,
    })
end

local function saveBattleReports()
    if next(battleReports) then
        local reportCenter = require "lib.reportcenter"
        reportCenter.set({data=battleReports})
    end
end

--获取详情战报信息
local function getBattleDetailReport (self,id)
    local id = tonumber(id)
    return self.db:getRow("select * from alliance_member_roundinfo where id=:id limit 1",{id=id})
end

-- 获取跨服战战报
local function getBattleReport(self,bid,round,pos,uid,dtype,page)

    local page = tonumber(page) or 1
    local dtype = tonumber(dtype) or 0
    local sqlmode = ""
    local sqlData = {}
    local showNums = 10
    local offset = (page - 1) * showNums
    local searchNum = showNums + 1
    if dtype == 0 then
        sqlmode = "select type,bid,id,attId,attName,defId,defName,attAName,defAName,attAid,defAid,updated_at,placeId,aPrevPlace,dPrevPlace,type,baseblood,placeOid,victor from alliance_battlelog where bid=:bid and round=:round and pos=:pos and ( type = 1 or type = 2 ) order by id desc limit :offset , :num"
        sqlData = {bid=bid,round=round,pos=pos,offset=offset,num=searchNum}
    else
        sqlmode = "select type,bid,id,attId,attName,defId,defName,attAName,defAName,attAid,defAid,updated_at,placeId,aPrevPlace,dPrevPlace,type,baseblood,placeOid,victor from alliance_battlelog where bid=:bid and round=:round and pos=:pos and (defId = :defId or attId = :attId) and (type = 1 or type is null) order by id desc limit :offset , :num"
        sqlData = {bid=bid,round=round,pos=pos,defId=uid,attId=uid,offset=offset,num=searchNum}
    end

    local result = self.db:getAllRows(sqlmode, sqlData)
    local nextPage = 0

    if type(result) == "table" and next(result) then
          if #result == searchNum then
               table.remove(result, #result)
               nextPage = page + 1
          end
    end

    return result, nextPage
end

local function getBattleReportFromReportCenter(self,bid,round,pos,uid,dtype,page)
    local page = tonumber(page) or 1
    local dtype = tonumber(dtype) or 0
    local sqlmode = ""
    local sqlData = {}
    local showNums = 10
    local offset = (page - 1) * showNums
    local searchNum = showNums + 1
    local paramsData

    local reportType = getModuleReportType()

    -- 1是个人，0是全局
    if dtype == 0 then
        paramsData = {
            -- ext5 是所有攻击方的战报(额外标识加了1,只是为了来取全局战报)
            {ext1=bid,ext2=round,ext3=pos,type=reportType,ext5=1},
            -- {ext1=bid,ext2=round,ext3=pos,type=reportType,ext4=2},
        }
    else
        paramsData = {
            {ext1=bid,ext2=round,user_id=uid,ext3=pos,type=reportType,ext4=1},
            -- {ext1=bid,ext2=round,user_id=uid,ext3=pos,type=reportType,ext4=0},
        }
    end

    local reportCenter = require "lib/reportcenter"
    local centerData = reportCenter.get({data=paramsData,limit=offset,limitC=searchNum,sort="order by id desc"},true)
    local result = {}

    if type(centerData) == 'table' then
        for k,v in pairs(centerData) do
            if type(v) == 'table' then
                for m,n in pairs(v) do
                    if type(n.data) == 'table' then
                        n.data.id = n.id
                        table.insert(result,n.data)
                    end
                end
            end
        end
    end

    local nextPage = 0
    if type(result) == "table" and next(result) then
          if #result == searchNum then
               table.remove(result, #result)
               nextPage = page + 1
          end
    end

    return result, nextPage
end

-- 跨服战详情战报
local function getBattleDetailReportInfo(self, rId)
    local result = {
        destroy={
            attacker={},
            defenser={},
        },
        aey={{},{}},
        hh={{{},0},{{},0}},
        equip={0,0},
        plane={0,0},
        report={},
    }

    rId = tonumber(rId)
    local tmpresult = self.db:getRow("select attKills,defKills,report,aHeroAccessoryInfo,dHeroAccessoryInfo from alliance_battlelog where id=:id limit 1",{id=rId})
    if type(tmpresult) == "table" then
        local attkills = json.decode(tmpresult["attKills"]) or {}
        local defkills = json.decode(tmpresult["defKills"]) or {}
        result.destroy.attacker = attkills
        result.destroy.defenser = defkills
        local aHhero = json.decode(tmpresult["aHeroAccessoryInfo"]) or {}
        local dHhero = json.decode(tmpresult["dHeroAccessoryInfo"]) or {}
        local report = json.decode(tmpresult["report"]) or {}
        if aHhero[1] then
            result.aey[1] = aHhero[1]
        end
        if dHhero[1] then
            result.aey[2] = dHhero[1]
        end
        if aHhero[2] then
            result.hh[1] = aHhero[2]
        end
        if dHhero[2] then
            result.hh[2] = dHhero[2]
        end
        if aHhero[3] then
            result.equip[1] = aHhero[3]
        end
        if dHhero[3] then
            result.equip[2] = dHhero[3]
        end 

        if aHhero[4] then
            result.plane[1] = aHhero[4]
        end
        if dHhero[4] then
            result.plane[2] = dHhero[4]
        end 

        local report = json.decode(tmpresult["report"]) or {}
        result.report=report
    end

    return result
end

local function getDetailReportFromReportCenter(self, rId)
    local reportCenter = require "lib/reportcenter"

    local result = {
        destroy={
            attacker={},
            defenser={},
        },
        aey={{},{}},
        hh={{{},0},{{},0}},
        equip={0,0},
        plane={0,0},
        report={},
    }

    rId = tonumber(rId)
    -- local tmpresult = self.db:getRow("select attKills,defKills,report,aHeroAccessoryInfo,dHeroAccessoryInfo from alliance_battlelog where id=:id limit 1",{id=rId})

    local tmpresult = reportCenter.get({data={{id=rId}}},true)
    tmpresult = arrayGet(tmpresult,"1>1>data")

    if type(tmpresult) == "table" then
        local attkills = tmpresult["attKills"] or {}
        local defkills = tmpresult["defKills"] or {}
        result.destroy.attacker = attkills
        result.destroy.defenser = defkills
        local aHhero = tmpresult["aHeroAccessoryInfo"] or {}
        local dHhero = tmpresult["dHeroAccessoryInfo"] or {}
        local report = tmpresult["report"] or {}
        if aHhero[1] then
            result.aey[1] = aHhero[1]
        end
        if dHhero[1] then
            result.aey[2] = dHhero[1]
        end
        if aHhero[2] then
            result.hh[1] = aHhero[2]
        end
        if dHhero[2] then
            result.hh[2] = dHhero[2]
        end
        if aHhero[3] then
            result.equip[1] = aHhero[3]
        end
        if dHhero[3] then
            result.equip[2] = dHhero[3]
        end
        if aHhero[4] then
            result.plane[1] = aHhero[4]
        end
        if dHhero[4] then
            result.plane[2] = dHhero[4]
        end 

        result.report=report
    end

    return result
end

local function getAllianceMemberList(self,bid,zid,aid)
    local list = self.db:getAllRows("select aid,uid,zid,nickname,pic,fc from "..tbAllianceMember.." where bid = '"..bid.."' and aid='"..aid.."' and zid="..zid)

    writeLog('6.5 memberlist,bid='..(bid or 0)..',zid='..(zid or 0)..',aid='..(aid or 0)..',sql='..self.db:getQueryString()..',list='..(json.encode(list) or 'no list') ,'acrossserverBattleOver')

    return list
end

-- 设置军团指令
local function setAllianceCommand(self,bid,group,zid,aid,command)
    if type(command) == 'table' then
        local aidKey = mkKey(group,zid,aid)
        local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
        local redis = self.redis
        local commandMsgs = redis:hset(acKey,aidKey,json.encode(command))
        redis:expire(acKey,expireTs)
    end
end

-- 获取军团指令
local function getAllianceCommand(self,bid,group,zid,aid)
    local redis = self.redis
    local acKey = mkCacheKey(hashAllianceCommandMsg,bid)
    local commandMsgs = redis:hget(acKey,mkKey(group,zid,aid))
    commandMsgs = json.decode(commandMsgs)

    if type(commandMsgs) ~= 'table' then
        commandMsgs = {}
    end

    return commandMsgs
end

local function bombUser(userTroops,uid)
    local totalnum = 0
    local destroy = {}
    local percent = getConfig('serverWarTeamMapCfg1.bombHpPercent')

    for k,v in pairs(userTroops) do
        if next(v) and v[2] > 0 then
            local dieNum = math.ceil(v[2] * percent)
            v[2] = v[2] - dieNum

            userTroops[k] = v
            destroy[v[1]] = (destroy[v[1]] or 0) + dieNum
            totalnum = totalnum + v[2]
        end
    end

    if totalnum <= 0 then
        userTroops = {}
    end

    bombedUsers[tonumber(uid)] = 1

    return userTroops,destroy
end

-- 按binfo获取三只部队的信息包含英雄
local function getTroopsByBinfo(binfo)
    local troops = {
        {},
    }
    
    local heros = {
        {0,0,0,0,0,0}
    }

    local equip = 0
    if type(binfo) == 'table' and next(binfo) then
        local idIndex
        local numIndex
        for k,v in pairs(binfo[1]) do
            if v == 'id' then
                idIndex = k
            elseif v == 'num' then
                numIndex = k
            end

            if idIndex and numIndex then 
                break 
            end
        end

        local emptyTroop = {}
        if type(binfo[2]) == 'table' then
            for sn,snVal in pairs(binfo[2]) do
                if  type(binfo[2][sn]) == 'table' and next(binfo[2][sn]) then
                    for k,v in pairs(snVal) do
                        if next(v) then
                            troops[sn][k] = {v[idIndex], (tonumber(v[numIndex]) or 0)}
                        else
                            troops[sn][k] = emptyTroop
                        end
                    end
                end
            end
        end

        if type(binfo[3]) == 'table' then
            for sn,snVal in pairs(binfo[3]) do
                if  type(binfo[3][sn]) == 'table' and next(binfo[3][sn]) then
                    for k,v in pairs(snVal) do
                        if type(v) == 'string' and v ~= "" then
                            local heroIndexInfo = string.split(v,'-')
                            heros[sn][k] = heroIndexInfo[1]
                        end
                    end
                end
            end
        end

        if binfo[4] then
            equip = binfo[4]
        end
    end

    return troops,heros,equip
end

----------------------------------------------------------------------------
local function battleRunFlag(self)
    local key = "acrosswar.battleAt"
    local ts = getClientTs()
    self.redis:watch(key)
    local lastAt = self.redis:get(key)
    lastAt = tonumber(lastAt) or 0
    local diffBattleAt = ts - lastAt
    if diffBattleAt < 5 then
        return false
    end

    self.redis:multi()
    self.redis:set(key,ts)       
    self.redis:expire(key,4)
    return self.redis:exec()
end

local function setautocommit(self,value)
    assert(self.db.conn:setautocommit(value),'mysql transaction set failed')
end

local function commit(self)
    return self.db.conn:commit()
end

local function connect(self)
    self.db = getCrossDbo("acrossserver")--getAllianceCrossDbo()
    -- self.redis = getAllianceCrossRedis("acrossserver")
end

local function bid2AreaServerId(bid,areaCount)
    local bid = tonumber(string.sub(bid, 2))
    local n = bid % areaCount
    if n == 0 then n = areaCount end

    return n
end 

local function setRedis(self,bid,areaServerId)
    local config = getConfig("config")
    local connector = config.areacrossserver.connector

    if not areaServerId then
        areaServerId = bid2AreaServerId(bid,#connector)
    end

    local cfg = connector[areaServerId] and connector[areaServerId].redis
    self.redis = getRedisByCfg({host=cfg.host,port=cfg.port})
end


local function writeCrossLog(log)
    writeLog(log,'acrossserver')
end

local function init()
    pushUsers = {}
    pushData = {}
    aKillTroops = {}
    usersDonate = {}
    battleWinners = {}
    repairAllianceData = {}
    repairCount = 0
    battleReports = {}
    bombedUsers = {}
    asweets = getWeeTs()
end

local function test(...)
    return checkRoundData(...)
        -- return pushData
end
----------------------------------------------------------------------------

local methods = {
    -- data
    setRedis = setRedis,
    getAllBid = getAllBid,
    setPlaceInfo = setPlaceInfo,
    setUserActionInfo = setUserActionInfo,
    resetUserActionInfo = resetUserActionInfo,
    initAllianceData = initAllianceData,
    getAllianceDataByTime = getAllianceDataByTime,
    getAllianceData = getAllianceData,
    setAllianceData = setAllianceData,
    getAllianceApplyData=getAllianceApplyData,
    updateAllianceData = updateAllianceData,
    getUserActionInfo = getUserActionInfo,
    getUsersActionInfo = getUsersActionInfo,
    getUserData = getUserData,
    getUserDataFromDb = getUserDataFromDb,
    getUserInFo       = getUserInFo,
    getPlacesInfo = getPlacesInfo,
    getPlaceInfo = getPlaceInfo,
    addPoint = addPoint,
    getPlaceBattleUser=getPlaceBattleUser,
    getGroupBasePlace = getGroupBasePlace,
    allianceEndBattle = allianceEndBattle,
    setAllianceEndBattleFlag = setAllianceEndBattleFlag,
    getAllianceEndBattleFlag = getAllianceEndBattleFlag,
    getAllianceFromDbByBid = getAllianceFromDbByBid,
    getPoint = getPoint,
    getMatchListByGroupFromDb = getMatchListByGroupFromDb,
    deBasePlaceBlood = deBasePlaceBlood,
    getBasePlaceTroops = getBasePlaceTroops,
    getPlacesUsersList = getPlacesUsersList,
    getAllianceKillTroops = getAllianceKillTroops,
    getBattleReportFromReportCenter = getBattleReportFromReportCenter,
    getDetailReportFromReportCenter = getDetailReportFromReportCenter,

    formatUserDataForClient = formatUserDataForClient,
    formatAllianceDataForClient = formatAllianceDataForClient,
    getStartBattleTsByGroup = getStartBattleTsByGroup,
    getEndBattleTsByGroup = getEndBattleTsByGroup,
    checkShowCountryRoad = checkShowCountryRoad,

    isBasePlace = isBasePlace,
    basePlaceBattle = basePlaceBattle,
    setBasePlaceTroops = setBasePlaceTroops,
    setAllianceKillTroops = setAllianceKillTroops,
    addAllianceKillTroops = addAllianceKillTroops,
    addUserDonateByTroops = addUserDonateByTroops,
    addUserDonate = addUserDonate,
    setUsersDonate = setUsersDonate,
    getEndDonates = getEndDonates,
    checkRoundData = checkRoundData,

    -- endcount
    setAllianceRoundInfo = setAllianceRoundInfo,
    getAllianceRoundInfo = getAllianceRoundInfo,
    setMemberRoundInfo = setMemberRoundInfo,
    getMemberRoundInfo = getMemberRoundInfo,

    mkKey = mkKey,
    getUserBuffs = getUserBuffs,
    splitKey = splitKey,
    setBattlePushData = setBattlePushData,
    battlePush = battlePush,
    getBasePlaceBlood = getBasePlaceBlood,

    getOverData = getOverData,

    mkMatchList = mkMatchList,

    getBattleSeq = getBattleSeq,
    crossbattle = crossbattle,
    getRoundEvents=getRoundEvents,
    getRanking = getRanking,

    checkBattleData = checkBattleData,
    getBattleRoundTs = getBattleRoundTs,
    getCurrentRound = getCurrentRound,
    formatTroops = formatTroops,
    battleRunFlag = battleRunFlag,

    setAllianceCommand = setAllianceCommand,
    getAllianceCommand = getAllianceCommand,
    getTroopsByInitTroopsInfo=getTroopsByInitTroopsInfo,
    bombUser = bombUser,
    getTroopsByBinfo = getTroopsByBinfo,
    joinBattlefield = joinBattlefield,
    getAllianceMemUids = getAllianceMemUids,

    -- connection
    connect = connect,
    -- data
    setUserBattleData = setUserBattleData,
    updateUserBattleData = updateUserBattleData,
    -- report
    setBattleReport = setBattleReport,
    setbombReport = setbombReport,
    getBattleReport = getBattleReport,
    getBattleDetailReportInfo = getBattleDetailReportInfo,
    -- db
    setautocommit = setautocommit,
    commit = commit,
    writeCrossLog = writeCrossLog,
    -- init
    init = init,
    -- test
    test = test,
    getAllianceMemberList = getAllianceMemberList,
    saveBattleReports = saveBattleReports,
}

local new = function()
    local r = acrossserver
    init()
    connect(r)
    return setmetatable(r, {__index = methods})
end

return {
    new = new
}
