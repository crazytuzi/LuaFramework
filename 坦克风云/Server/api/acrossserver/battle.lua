--[[
    跨服军团战，战斗    

    以bid为单元，每5秒执行一次
        战场分为4组，分别在每天的4个时间段开始执行        
        获取所有参战成员的信息，对应到地图上的每个据点上
        按据点扫描战斗事件，执行战斗
    
    状态说明：
        1是胜利
        2是淘汰

    战斗前检测：
        战斗是否结束，
            a、比分达到上限
            b、有一方轮空，直接胜利，这种情况需要直接验证数据库的数据检测是否真的轮空，防止缓存数据不准
        时间验证，按组获取正确的开战时间，验证是否到开战时间

    结算的情况：
        a、有任意一方轮空
        b、有一方的地图积分达到结算上限
        c、有一方的主基地耐久被打掉
        d、结算战斗的时间到了
        
    注意用户的buff,对战斗的影响
    revive字段表示用户复活的时间

]]
function api_acrossserver_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        afterErr = {},
        over={},
        kill = {},
    }

    local battleDebug = false

    -- 结束时给前端推送的战场据点积分
    local endPushPoints = {}
    -- 结束时给前端推送的击杀数
    local endPushKills = {}
    -- 结束时给前端推送的用户商店积分
    local endUserPoints = {}
    -- 当前进行的轮次，记战报用
    local nowRound = 0
    -- 推给前端本场的胜利者，zid-aid
    local bwinner = 0

    -- 每届跨服战前需要初始化下这些数据
    local function bclear()
        endPushPoints = {}
        endPushKills = {}
        endUserPoints = {}
        nowRound = 0
        bwinner = 0
    end

    ---------------------------------------------------------------------
    -- init
    local group = request.params.group
    local ts = getClientTs()
    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local mapCfg = getConfig('serverWarTeamMapCfg1')
    local cityCfg = mapCfg.cityCfg
    local areaServerId = tonumber(request.params.areaServerId)
    response.areaServerId = areaServerId

    -- model
    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(nil,areaServerId)

    -- 以产生冠军的轮次作为最大轮次获取数据
    local roundEvents = across.getRoundEvents(sevbattleCfg.sevbattleAlliance)
    local allBids = across:getAllBid(group,roundEvents[2],ts)

    if type(allBids) ~= 'table' or not next(allBids) then
        response.err = "not bids in battle"
        return response
    end

    ---------- 

    -- 优化按areaServerId处理大战数据
    local config = getConfig("config")
    local connector = config.areacrossserver.connector

    local bids = {}
    local areaCount = #connector
    for _,bidstr in pairs(allBids) do
        local bid = tonumber(string.sub(bidstr, 2))
        local n = bid % areaCount
        if n == 0 then n = areaCount end
        if n == areaServerId then
            table.insert(bids,bidstr)
        end
    end
    
    ----------

    if not battleDebug and not across:battleRunFlag() then
        response.err =  'Run for 5 seconds'
        return response
    end

    ---------------------------------------------------------------------
    -- function

    local function initLogData(bid,group,placeId,owner)
        return {
                bid = bid,
                pos = group,
                placeId = placeId,
                placeOid = owner,
                report = nil,victor = nil,attId=nil,defId=nil,attName=nil,
                defName=nil,attAid=nil,defAid=nil,attAName=nil,
                defAName=nil,attKills=nil,defKills=nil,
            }
    end

    local function setLogInfo(across,logData,aUserinfo,dUserinfo)
        logData.attId = aUserinfo.uid
        logData.attName = aUserinfo.nickname
        logData.attAid = across.mkKey(aUserinfo.zid,aUserinfo.aid)
        logData.attAName = aUserinfo.aname
        logData.aHeroAccessoryInfo = aUserinfo.heroAccessoryInfo

        dUserinfo = dUserinfo or {}
        logData.defId = dUserinfo.uid or ''
        logData.defName = dUserinfo.nickname or ''
        logData.defAid = dUserinfo.aid and across.mkKey(dUserinfo.zid,dUserinfo.aid) or ''
        logData.defAName = dUserinfo.aname or ''
        logData.dHeroAccessoryInfo = dUserinfo.heroAccessoryInfo

        logData.round = nowRound
    end

    -- 设置用户行动数据
    local function setActionData(across,bid,group,userinfo,basePlace,bplace,enemy)        
        return across:resetUserActionInfo({
                    bid=bid,
                    group=group,
                    zid=userinfo.zid,
                    aid=userinfo.aid,
                    uid=userinfo.uid,
                    nickname=userinfo.nickname,
                    aname=userinfo.aname,
                    role=userinfo.role,
                    bplace=bplace,
                    basePlace=basePlace,
                    revive = ts + sevbattleCfg.reviveTime,
                    enemy = enemy,
                })
    end

    -- 战斗结束
    -- TODO
    local function setEndBattleData(across,bid,zid,group,aid,round,status,alliances,zidAid)   
    
        local zidAid = zidAid or across.mkKey(zid,aid)
        if status == 1 then bwinner = zidAid end

        local points = across:getPoint(bid,group)
        local kills,_,killCount = across:getAllianceKillTroops(bid,group,true)  
        
        response.kill[bid] = kills[zidAid] or {}
        local allianceRoundInfo = {
            bid=bid,
            round=round,
            pos=group,
            zid=zid,
            aid=aid,
            point=points[zidAid] or 0,
            kills=kills[zidAid] or {},
        }
        across:setAllianceRoundInfo(allianceRoundInfo)

        local donates = across:getEndDonates(bid,group,zid,aid,alliances.teams,status)
        for k,v in pairs(donates[zidAid] or {}) do
            across:setMemberRoundInfo({
                bid=bid,
                pos=group,
                zid=zid,
                aid=aid,
                round=round,
                uid=k,
                point=v or 0,
            })
        end

        local roundLog = alliances.log or {}
        table.insert(roundLog,{round,group,status,})

        local ranking = across.getRanking(sevbattleCfg.produceRank,round,group,status)
        
        local endData = {
            bid = bid,
            zid = zid,
            aid = aid,
            status = status,
            ranking=ranking,
            round = tonumber(round) + 1,
            point = tonumber(alliances.point) + (points[zidAid] or 0),
            pos = group,
            log = json.encode(roundLog),
            basetroops = {},
            battle_at = ts,
        }

        local ret = across:allianceEndBattle(endData)
        
        endPushKills = killCount
        endPushPoints = points
        endUserPoints =  table.merge(endUserPoints,donates)
    end

    local function setEndPushData(across,bid,group)
        across.setBattlePushData(bid,group,{
            over = {
                    winner = bwinner,
                    points = endPushPoints,
                    kills = endPushKills,
                    uPoints = endUserPoints,
                },
            })
    end

    local function after(across,bid,group)
        across.battlePush(bid,group)
        across:setAllianceKillTroops(bid,group)
        across:setUsersDonate(bid,group)
        across.saveBattleReports()
    end

    -- 用户攻打敌方主基地
    -- bid 跨服标识
    -- group,   组
    -- placeId, 基地id
    -- placeUserlist    据点中的用户信息
    -- baseTroops,  据点点的部队数
    -- allianceInfo     攻打的主基地军团信息
    local function userAttackBase(bid,group,placeId,placeUserlist,baseTroops,allianceInfo,baseZaid,owner,baseBlood)
        -- 攻击方信息
        local aUserinfo = across:getUserData(bid,placeUserlist[1].zid,placeUserlist[1].aid,placeUserlist[1].uid)
        local aUserAction = placeUserlist[1]

        if aUserinfo then
            -- 战报字段
            local tmpLogData = initLogData(bid,group,placeId,owner)

            -- 当前基地防守部队
            local currBaseTroops = {}
            local currBaseKey
            for k,v in pairs(baseTroops) do
                if next(v) then
                    currBaseTroops = v
                    currBaseKey = k
                    break
                end
            end
            
            -- 格式化基地防守部队属性
            local versionCfg = getVersionCfg()
            local roleMaxLevel = versionCfg.roleMaxLevel
            local baseskillCfg = sevbattleCfg.baseFleetAttribute[roleMaxLevel] or sevbattleCfg.baseFleetAttribute[80]

            local initBaseTroops = initTankAttribute(currBaseTroops,nil,baseskillCfg.skill,nil,nil,4,{acAttributeUp=baseskillCfg.attributeUp})
            
            -- 战斗
            local report, aAliveTroops, dAliveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops = across.basePlaceBattle(aUserinfo,aUserAction.troops,initBaseTroops)
            
            report.p = {
                {allianceInfo.name,30,0,seqPoint[2]},
                {aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]},
            }

            -- 记录推送消息 
            local pushData = {
                placesInfo = {},
                usersActionInfo = {},
            }

            local enemy = across.mkKey('npc',currBaseKey)
            setLogInfo(across,tmpLogData,aUserinfo,{})
            tmpLogData.report = report
            tmpLogData.aPrevPlace = aUserAction.prev
            tmpLogData.baseblood = baseBlood
            tmpLogData.defAName = allianceInfo.name
            tmpLogData.defAid = across.mkKey(allianceInfo.zid,allianceInfo.aid)
            tmpLogData.defId = currBaseKey
            tmpLogData.aHeroAccessoryInfo = aUserinfo.heroAccessoryInfo

            -- 如果胜利，修改自己的行动信息
            if report.r == 1 then
                tmpLogData.victor = aUserinfo.uid 
                placeUserlist[1].troops = aAliveTroops
                placeUserlist[1].battle_at = ts
                placeUserlist[1].bplace = placeId
                placeUserlist[1].enemy = enemy

                local setret,setdata,setkey = across:setUserActionInfo(bid,group,aUserinfo.zid,aUserinfo.aid,aUserinfo.uid,placeUserlist[1])
                pushData.usersActionInfo[setkey] = setdata
                   
            -- 如果失败，重置攻击者的信息（攻击者回到自己的基地，并且进入复活的CD时间）             
            else
                tmpLogData.victor = currBaseKey
                local setret,setdata,setkey = setActionData(across,bid,group,aUserinfo,placeUserlist[1].basePlace,placeId,enemy)
                pushData.usersActionInfo[setkey] = setdata
            end

            -- 增加贡献
            across.addUserDonateByTroops(bid,group,aUserinfo.zid,aUserinfo.aid,aUserinfo.uid,dDieTroops,report.r)
            across.addAllianceKillTroops(bid,group,aUserinfo.zid,aUserinfo.aid,dDieTroops)

            -- 设置战报击杀
            tmpLogData.attKills = dDieTroops
            tmpLogData.defKills = aDieTroops
            
            if battleDebug then
                local str = "attackBase bid:" .. bid .. "group:" .. group .. "zid:".. aUserinfo.zid .."aid:"..aUserinfo.aid .. "die:" .. json.encode(dDieTroops)
                writeLog(str ,'addAllianceKillTroops')
            end

            -- 修改主基地的部队数
            baseTroops[currBaseKey] = dAliveTroops
            across:setBasePlaceTroops(bid,group,placeId,baseTroops)

            if not next(dAliveTroops) then
                -- 推送主基地部队
                if not pushData.basetroops then pushData.basetroops = {} end
                pushData.basetroops[baseZaid] = currBaseKey 
            end
            
            across:setBattleReport(tmpLogData,true)
            across.setBattlePushData(bid,group,pushData)

        end
    end

    -- 用户在所点发生战斗
    -- bid, 跨服标识
    -- group, 组
    -- placeId, 据点
    -- placeUserlist 据点玩家列表
    -- owner 据点当前的占领者
    -- 队列中用户的数量，是否发生占领事件，需要敌队势力的count值为0
    local function userbattle(bid,group,placeId,placeUserlist,owner,userListCount,baseBlood)
        -- 战报字段
        local tmpLogData = initLogData(bid,group,placeId,owner)
        
        -- 对阵双方的用户信息
        local aUserinfo = across:getUserData(bid,placeUserlist[1].zid,placeUserlist[1].aid,placeUserlist[1].uid)
        local dUserinfo = across:getUserData(bid,placeUserlist[2].zid,placeUserlist[2].aid,placeUserlist[2].uid)

        -- TODO 如果没有找到用户信息，是否重置此用户的行动数据
        if not aUserinfo or not dUserinfo then
            return nil
        end

        -- 攻击顺序，1是placeUserlist[1]进攻，2是placeUserlist[2]进攻
        local attSeq = across.getBattleSeq(placeUserlist[1],placeUserlist[2],owner)

        -- 当双方信息都存在时进行战斗
        if aUserinfo and dUserinfo then
            setLogInfo(across,tmpLogData,aUserinfo,dUserinfo)
            local report, aAliveTroops, dAliveTroops,winner,battleAttSeq,seqPoint,aDieTroops,dDieTroops

            if attSeq == 1 then
                report, aAliveTroops, dAliveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops = across.crossbattle(aUserinfo,placeUserlist[1].troops,dUserinfo,placeUserlist[2].troops)

                report.p = {
                    {dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},
                    {aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]},
                }

                if battleAttSeq == 1 then
                    report.p[1][3] = 1
                    report.p[2][3] = 0
                end

                winner = report.r == 1 and 1 or 2

            else
                report, dAliveTroops, aAliveTroops,battleAttSeq,seqPoint,dDieTroops,aDieTroops = across.crossbattle(dUserinfo,placeUserlist[2].troops,aUserinfo,placeUserlist[1].troops)

                report.p = {
                    {aUserinfo.nickname,aUserinfo.level,0,seqPoint[2]},
                    {dUserinfo.nickname,dUserinfo.level,1,seqPoint[1]},
                }

                if battleAttSeq == 1 then
                    report.p[1][3] = 1
                    report.p[2][3] = 0
                end

                winner = report.r == 1 and 2 or 1

            end

            local pushData = {
                usersActionInfo = {},
                placesInfo = {},
            }

            local isOccupied = false
            tmpLogData.report = report 
            tmpLogData.aPrevPlace = placeUserlist[1].prev
            tmpLogData.dPrevPlace = placeUserlist[2].prev
            if baseBlood then tmpLogData.baseblood = baseBlood end
                    
            if winner == 1 then
                -- 战报
                tmpLogData.victor = placeUserlist[1].uid

                -- 更新胜利者的行动信息
                placeUserlist[1].pos = placeId
                placeUserlist[1].troops = aAliveTroops
                placeUserlist[1].battle_at = ts
                placeUserlist[1].bplace = placeId
                placeUserlist[1].enemy = across.mkKey(dUserinfo.zid,dUserinfo.aid,dUserinfo.uid)

                local setret,setdata,setkey = across:setUserActionInfo(bid,group,aUserinfo.zid,aUserinfo.aid,aUserinfo.uid,placeUserlist[1])
                
                pushData.usersActionInfo[setkey] = setdata

                -- 重置失败者的行动信息
                local enemy = across.mkKey(aUserinfo.zid,aUserinfo.aid,aUserinfo.uid)
                local setret,setdata,setkey = setActionData(across,bid,group,dUserinfo,placeUserlist[2].basePlace,placeId,enemy)
                
                pushData.usersActionInfo[setkey] = setdata

                -- 如果当前据点占领者不是获胜方，并且占领点不是主基地,更正据点的占领者
                if  across.mkKey(aUserinfo.zid,aUserinfo.aid) ~= owner then
                    if userListCount[2] <= 1 and not across.isBasePlace(placeId,mapCfg.baseCityID) then
                        local setret, setInfo = across:setPlaceInfo(bid,group,placeId,aUserinfo.zid,aUserinfo.aid)
                        pushData.placesInfo[placeId] = setInfo
                        isOccupied = true
                    end
                end

                -- 增加贡献
                across.addUserDonateByTroops(bid,group,aUserinfo.zid,aUserinfo.aid,aUserinfo.uid,dDieTroops,1)
                across.addUserDonateByTroops(bid,group,dUserinfo.zid,dUserinfo.aid,dUserinfo.uid,aDieTroops,2)

            else

                -- 战报
                tmpLogData.victor = placeUserlist[2].uid

                -- 更新胜利者的行动信息
                placeUserlist[2].pos = placeId
                placeUserlist[2].troops = dAliveTroops
                placeUserlist[2].battle_at = ts
                placeUserlist[2].bplace = placeId
                placeUserlist[2].enemy = across.mkKey(aUserinfo.zid,aUserinfo.aid,aUserinfo.uid)

                local setret,setdata,setkey = across:setUserActionInfo(bid,group,dUserinfo.zid,dUserinfo.aid,dUserinfo.uid,placeUserlist[2])

                pushData.usersActionInfo[setkey] = setdata

                -- 重置失败者的行动信息                
                local enemy = across.mkKey(dUserinfo.zid,dUserinfo.aid,dUserinfo.uid)
                setret,setdata,setkey = setActionData(across,bid,group,aUserinfo,placeUserlist[1].basePlace,placeId,enemy)

                pushData.usersActionInfo[setkey] = setdata

                if across.mkKey(dUserinfo.zid,dUserinfo.aid) ~= owner then
                    if userListCount[1] <= 1 and not across.isBasePlace(placeId,mapCfg.baseCityID) then
                        local setret, setInfo = across:setPlaceInfo(bid,group,placeId,dUserinfo.zid,dUserinfo.aid)
                        pushData.placesInfo[placeId] = setInfo
                        isOccupied = true
                    end
                end

                -- 增加贡献
                across.addUserDonateByTroops(bid,group,aUserinfo.zid,aUserinfo.aid,aUserinfo.uid,dDieTroops,2)
                across.addUserDonateByTroops(bid,group,dUserinfo.zid,dUserinfo.aid,dUserinfo.uid,aDieTroops,1)
            end
            
            across.addAllianceKillTroops(bid,group,aUserinfo.zid,aUserinfo.aid,dDieTroops)   
            across.addAllianceKillTroops(bid,group,dUserinfo.zid,dUserinfo.aid,aDieTroops)  

            -- 设置战报击杀
            tmpLogData.attKills = dDieTroops
            tmpLogData.defKills = aDieTroops

            if battleDebug then
                local str = "attackBase bid:" .. bid .. "group:" .. group .. "zid:".. aUserinfo.zid .."aid:"..aUserinfo.aid .. "die:" .. json.encode(dDieTroops)
                writeLog(str ,'addAllianceKillTroops')

                local str = "attackBase bid:" .. bid .. "group:" .. group .. "zid:".. dUserinfo.zid .."aid:"..dUserinfo.aid .. "die:" .. json.encode(aDieTroops)
                writeLog(str ,'addAllianceKillTroops')
            end   
            
            -- 如果发生占领，设置战报的type为1
            if isOccupied then
                tmpLogData.type = 1
            end

            across:setBattleReport(tmpLogData) 
            across.setBattlePushData(bid,group,pushData)

        end
    end

    -- 轰炸玩家,直接扣除百分比的部队
    local function bombUser(bid,group,userActionInfo,place,airportOwner)
        local userTroops = {}
        local userinfo = across:getUserData(userActionInfo.bid,userActionInfo.zid,userActionInfo.aid,userActionInfo.uid)

        if type(userActionInfo.troops) == 'table' and #userActionInfo.troops > 0 then
            userTroops = userActionInfo.troops
        else
            local tmp = json.decode(userinfo.troops)
            if type(tmp) == 'table' then
                userTroops = tmp
            end
        end

        local destroy
        local pushData = {
            usersActionInfo = {},
        }

        userTroops,destroy = across.bombUser(userTroops,userActionInfo.uid)

        -- 0 正常,1被炸,2被炸死
        local bombStatus = 1

        -- 炸死了
        if #userTroops == 0 then
            local setret,setdata,setkey = setActionData(across,bid,group,userinfo,userActionInfo.basePlace,userActionInfo.target)
            
            pushData.usersActionInfo[setkey] = setdata
            across.setBattlePushData(bid,group,pushData)
            bombStatus = 2
        else
            userActionInfo.troops = userTroops

            local setret,setdata,setkey = across:setUserActionInfo(userActionInfo.bid,group,userActionInfo.zid,userActionInfo.aid,userActionInfo.uid,userActionInfo)
            -- pushData.usersActionInfo[setkey] = setdata
        end

        local attackInfo = across.splitKey(airportOwner,"zid","aid")
        if attackInfo.zid and attackInfo.aid then
            across.addAllianceKillTroops(bid,group,attackInfo.zid,attackInfo.aid,destroy)
        end

        -- 炸死了需要一条战报
        if bombStatus == 2 then
            across:setbombReport({
                bid = userActionInfo.bid,
                defId = userActionInfo.uid,
                defAid = userActionInfo.aid,
                dPrevPlace = userActionInfo.prev,
                round = nowRound,
                pos = group,
                bomb = bombStatus,
                placeId = place,
                attKills = destroy,
                type = 0,
            })
        end
    end

    --[[
        轰炸据点中所所有玩家
        param table userList 轰炸的部队列表
    ]]
    local function bomdCityUsers(bid,group,userList,place,airportOwner)
        if type(userList) == "table" then
            for k,v in pairs(userList) do
                bombUser(bid,group,v,place,airportOwner)
            end
        end
    end

    -- 激活条件取配置
    local function airportIsActive(userList)
        return #userList >= mapCfg.flyNeed
    end

    -- 根据支援的机场军团id获取轰炸的军团ID
    local function getbombAid(placeAllianceList,airportOwner)
        if type(placeAllianceList) == 'table' then
            for k in pairs(placeAllianceList) do
                if k ~= airportOwner then
                    return k
                end
            end
        end
    end

    -- 为机场的激活玩家加贡献
    local function addAirportActiveUsersDonate(userList)
        local donate = mapCfg.bombDonate

        for i=1,mapCfg.flyNeed do
            if userList[i] then
                across.addUserDonate(userList[i].bid,userList[i].group,userList[i].zid,userList[i].aid,userList[i].uid,donate)
            end
        end
    end

    --[[
        空中支援
        机场据点被激活后,会轰炸指定的据点内的敌方所有部队,可以直接消灭敌方
    ]]
    local function airSupport(bid,group,battlePlaces,placesInfo)
        for airportPlace in pairs(mapCfg.bomdCity) do
            if battlePlaces[airportPlace] then
                local airportOwner = placesInfo[airportPlace]
                across.getPlaceBattleUser(battlePlaces[airportPlace])

                if airportOwner and airportIsActive(battlePlaces[airportPlace][airportOwner]) then
                    addAirportActiveUsersDonate(battlePlaces[airportPlace][airportOwner])

                    for _,v in pairs(mapCfg.bomdCity[airportPlace]) do
                        local bombAid = getbombAid(battlePlaces[v],airportOwner)
                        if bombAid then
                            bomdCityUsers(bid,group,battlePlaces[v][bombAid],v,airportOwner)
                        end
                    end
                end
            end
        end
    end

    local function run(bid,group)
        -- 检测结束标识
        if across:getAllianceEndBattleFlag(bid,group) then
            table.insert(response.over,{bid,'over: cache flag'})
            return response
        end

        -- 获取此组参赛的军团信息
        local alliancesInfo,allianceRound = across:getAllianceData(bid,group)        
        assert(allianceRound > 0,'round error:' .. allianceRound)
        nowRound = allianceRound
        
        -- 参赛军团数小于2，表示有轮空
        if table.length(alliancesInfo) < 2 then    
            -- 为了保险，直接从数据库取出数据验证，是否此组参赛军团少于2，即轮空了        
            local tmpInfo = across:getMatchListByGroupFromDb(bid,group)

            if table.length(tmpInfo) < 2 then
                across:setautocommit(false)
                writeLog('\n 1 |' .. json.encode(tmpInfo) .. '\n','acrossserverLunkong')
                
                for k,v in pairs(tmpInfo) do                    
                    setEndBattleData(across,bid,v.zid,group,v.aid,v.round,1,v,k)
                end
                
                if across:commit() then
                    across:setAllianceEndBattleFlag(bid,group,bwinner)
                end
                
                table.insert(response.over,{bid,'over: alliance empty'})
                return response
            end

            return nil
        end

        --------------------------

        -- 结算当前战场的积分
        local placesInfo =  across:getPlacesInfo(bid,group)        
        local cyclePoints = {}
        
        if type(placesInfo) == 'table' then
            for place,aid in pairs(placesInfo) do
                cyclePoints[aid] = (cyclePoints[aid] or 0 ) + cityCfg[place].winPoint
            end
        end

        --------------------------

        local isover = false
        local endBattleTs = across.getEndBattleTsByGroup(group,sevbattleCfg)
        
        for zidAid,point in pairs(cyclePoints) do
            local totalPoints = across:addPoint(bid,group,zidAid,point)
            
            -- 分数达到上限，或者时间到了，都要结算
            if totalPoints > sevbattleCfg.winPointMax then
                table.insert(response.over,{bid,'over: win point', zidAid, totalPoints})
                isover = true
            end
        end

        -- debug echo ts
        if battleDebug then
            writeLog(string.format("ts:%s,endts:%s",ts,endBattleTs) ,'acrossserver_debug')
        end

        if ts >= endBattleTs then
            table.insert(response.over,{bid,'over: time out'})
            isover = true
        end

        -- 结算,如果分数一样，战力少的获胜
        if isover then
            across:setautocommit(false)

            local alliancePoints = across:getPoint(bid,group)
            local overPoints = {}
            local i = 0
            for zidAid,aInfo in pairs(alliancesInfo) do
                table.insert(overPoints,{(alliancePoints[zidAid] or 0),zidAid,aInfo.fight})
                i = i + 1
                if i >= 2 then break end
            end
            
            table.sort(overPoints,function(a,b)
                if tonumber(a[1]) == tonumber(b[1]) then
                    return tonumber(a[3]) < tonumber(b[3])
                else
                    return tonumber(a[1]) > tonumber(b[1])
                end
            end
            )

            for k,overPinfo in ipairs(overPoints) do
                local aInfo = alliancesInfo[overPinfo[2]]  
                if k == 1 then bwinner = overPinfo[2]  end
                setEndBattleData(across,bid,aInfo.zid,group,aInfo.aid,aInfo.round,k,aInfo,zidAid) 
            end
 
            if across:commit() then
                across:setAllianceEndBattleFlag(bid,group,bwinner)
                -- 获取需要推送的所有用户
                local usersActionInfo = across:getUsersActionInfo(bid,group)
                setEndPushData(across,bid,group)
            end

            return response
        end

        -- 战场战斗 ---------------------------------------

        -- 地块的详细信息（用户列表）
        local battlePlaces = across:getPlacesUsersList(bid,group)

        airSupport(bid,group,battlePlaces,placesInfo)

        -- TEST        
        -- battlePlaces.a11 = copyTab(battlePlaces.a1)
        -- battlePlaces.a11['1-1164'][1].target = 'a11'
        -- battlePlaces.a1 = nil
        -- ptb:e(battlePlaces)

        -- 飞机轰炸后重新获取
        battlePlaces = across:getPlacesUsersList(bid,group)

        for placeId,userlist in pairs(battlePlaces) do    
            local placeUserlist,userListCount = across.getPlaceBattleUser(userlist)
            local owner = placesInfo[placeId]
            
            if type(placeUserlist) == 'table' then
                -- 当前据点的队伍数，相同的军团属于一个队伍，以此判断是否需要双方对战
                local tnum = #placeUserlist

                --[[
                    如果此据点只有1只队伍
                        按是否是主基地来判断
                        a、如果占领者是当前军团，则不处理
                        b、如果据点占领者不是属于当前队伍的话
                            1、此据点不是主基地，直接占领
                            2、此据点是主基地，判断是否是自己的，
                                不是自己的基地，需要与该主基地部队发生战斗，主基地部队被打完了，则直接掉耐久，每人每次掉5点
                    如果此据点有2只部队直接按正常逻辑走
                ]]
                
                local isBase = across.isBasePlace(placeId,mapCfg.baseCityID)

                if tnum == 1 then
                    local zidAid = across.mkKey(placeUserlist[1].zid,placeUserlist[1].aid)                    
                    -- 如果是主基地
                    if isBase then

                        -- 如果据点不是自己的军团,打基地或直接掉耐久
                        if placeId ~= placeUserlist[1].basePlace then 
                            local baseZaid,baseAlliance 
                            for zaid,alliance in pairs(alliancesInfo) do
                                if zidAid ~= zaid then
                                    baseZaid = zaid
                                    baseAlliance = alliance
                                    break
                                end
                            end
                            
                            local baseTroops = across:getBasePlaceTroops(bid,group,placeId)
                            if type(baseTroops) ~= 'table' then                                
                                if (tonumber(baseAlliance.donate_at) or 0) < (tonumber(baseAlliance.battle_at) or 1) then
                                    baseAlliance.basetroops = {}                                    
                                end

                                if not baseAlliance.basetroops then baseAlliance.basetroops = {} end

                                if type (baseAlliance.basetroops) ~= 'table' then
                                    baseAlliance.basetroops = json.decode(baseAlliance.basetroops) or {}
                                end
                                
                                baseTroops = baseAlliance.basetroops
                            end
                            
                            local battleFlag = false
                            for k,v in pairs(baseTroops) do
                                if next(v) then
                                    battleFlag = true
                                    break
                                end
                            end

                            if battleFlag then
                                -- 为了记战报，算下主基地的耐久度
                                local cBlood = across:deBasePlaceBlood(bid,group,placeId,0) or 0
                                local currBaseBlood = sevbattleCfg.baseBlood - cBlood
                                userAttackBase(bid,group,placeId,placeUserlist,baseTroops,baseAlliance,baseZaid,owner,currBaseBlood)
                            else
                                local blood = (userListCount[1] or 1) * sevbattleCfg.lossBlood
                                local cBlood = across:deBasePlaceBlood(bid,group,placeId,blood) or 0

                                across.setBattlePushData(bid,group,{
                                    placesBlood = {
                                        [placeId] = cBlood,
                                    },
                                })

                                local currBaseBlood = sevbattleCfg.baseBlood - cBlood
                                if currBaseBlood <= 0 then
                                    across:setautocommit(false)

                                    for zidAid,aInfo in pairs(alliancesInfo) do
                                        local endStatus = 2
                                        if (tonumber(aInfo.zid) == tonumber(placeUserlist[1].zid) and tonumber(aInfo.aid) == tonumber(placeUserlist[1].aid)) then 
                                            endStatus = 1
                                            bwinner = zidAid
                                        end
                                        
                                        setEndBattleData(across,bid,aInfo.zid,group,aInfo.aid,aInfo.round,endStatus,aInfo,zidAid)
                                    end

                                    local tmpLogData = initLogData(bid,group,placeId,owner)
                                    local aUserinfo = across:getUserData(bid,placeUserlist[1].zid,placeUserlist[1].aid,placeUserlist[1].uid)
                                    setLogInfo(across,tmpLogData,aUserinfo,{})

                                    tmpLogData.aPrevPlace = placeUserlist[1].prev
                                    tmpLogData.defAid = baseAlliance.aid
                                    tmpLogData.defAName = baseAlliance.name
                                    tmpLogData.type=2
                                    across:setBattleReport(tmpLogData,true)

                                    if across:commit() then
                                        across:setAllianceEndBattleFlag(bid,group,bwinner)
                                        setEndPushData(across,bid,group)
                                    end

                                    table.insert(response.over,{bid,'over: blood over', "placeId:", placeId})
                                    return response
                                end
                            end

                        end

                    else

                        -- 如果当前据点占领者不是我方，占领它
                        if owner ~= zidAid then
                            local setret, setInfo = across:setPlaceInfo(bid,group,placeId,placeUserlist[1].zid,placeUserlist[1].aid)                            
                            across.setBattlePushData(bid,group,{
                                placesInfo = {[placeId] = setInfo},
                            })
                        end

                    end

                elseif tnum == 2 then
                    local currBaseBlood
                    if isBase then
                        local cBlood = across:deBasePlaceBlood(bid,group,placeId,0) or 0
                        currBaseBlood = sevbattleCfg.baseBlood - cBlood
                    end
                    userbattle(bid,group,placeId,placeUserlist,owner,userListCount,currBaseBlood)
                end
            end

        end
    end
-- bid = 'b2201'
    for _,bid in pairs(bids) do
        across.init()
        local rstatus,rerror = pcall(run,bid,group)
        local afterRet,afterErr = pcall(after,across,bid,group)

        if not rstatus or not afterRet then
            response.err[bid] = rerror
            response.afterErr[bid] = afterErr
        end
        
        bclear()
    end
    
    response.ret = 0
    response.msg = 'Success'
    return response
end
