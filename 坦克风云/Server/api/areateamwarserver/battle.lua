--[[
    跨服区域战，战斗    

    战斗每20秒执行一次
        获取所有参战成员的信息，对应到地图上的每个据点上
        按据点扫描战斗事件，执行战斗

        按防守方与攻击方分为两个阵营,每个阵营分战斗队列与预备队列,战斗队列打光或不足时,预备队列补充到战斗队列中
        击败最后一名防守者的攻击者占领据点，并且在此据点中的该军团所有成员作为防守方进入下一回合战斗 
        防守方在据点中的战斗享受本据点提供的BUFF加成

        一个回合战斗结束后，是否防守方还有预备队是发生据点占领事件的判断条件

        当玩家的主基地耐久为0后,其在野外的据点刷新兵力，并且保持中立，该军团所有成员退出战斗

        当前回合占领的据点BUFF不会影响本回合的战斗，比如A,B战斗，A先被我方占领，然后计算B据点时，我方A据点的BUFF效果不会有效果
    
    贡献分规则：
        胜利分
        失败分
        占领据点分,占领据点的军团当前在攻击队列的所有城员(包括死亡)都会获得
        最终胜利分,胜利者军团所有人获得

    耐久损失规则:
        主基地打人战斗胜利的话直接就掉主城耐久会比轮空掉的少
        如果主基地没人，掉耐久比战斗胜利掉的多
        只要战斗胜利，就会扣，不管是谁打的，打多少次

    NPC的刷新规则：
        1.据点和主基地,王城分别有自己的初始化NPC
        2.NPC能够被杀死,且杀死NPC后占领该据点的归属势力不会立刻刷新出属于该势力的NPC，而是当此势力方退出该据点，使该据点成为空城时，才会重新刷新出属于此势力的NPC,即据点易主后如果没有成为过空城那么此城永远不会刷出NPC。
        3.战斗时，需要检测此城是否有NPC，NPC死掉了的话，据点一定会易主，不用检测NPC死亡的情况。
        4.NPC的兵力是会损耗的，直到死亡易主才会刷出全新的NPC
    
    主基地攻击王城规则：
        前提：同时触发
        1.先算炮的伤害，再计算人
        2.最后一炮，4个基地全部计算在内（会出现负值）
        3.基地炮不计先后顺序

    状态说明：
        1是胜利
        2是淘汰

    战斗前检测：
        战斗是否结束，
        数据完整性

    结算的情况
        a、王城耐久值为0
        b、四个主基地的耐久为0
        c、没有军团报名，直接胜利，这种情况需要确实得到返回的空报名状态码后才能判定，防止出现意外导致数据没有取回
        d、结算战斗的时间到了

        数据：
            需要当前胜利军团的奴隶，所有成员的贡献值
        
    注意用户的buff,对战斗的影响
    

    主基地有城防值，攻击阵营中打掉城防值（记在个人身上），最后按军团汇总后，军团最多的一方占领主基地，
    主基地易主后所有攻击者的攻击城防值清零，并且新的主基地城防值满，而且NPC部队刷新

    奴隶：
        战败的玩家有概率成为胜利玩家所属军团的奴隶
        每个军团奴隶数上限是40,超出后按奴隶等级从上往下取

]]
function api_areateamwarserver_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        over={},
    }

    local battleDebug = false
    local areaServerId = tonumber(request.params.areaServerId)
    local areaGroup = request.params.areaGroup

    ---------------------------------------------------------------------
    -- init
    local ts = os.time()
    local sevbattleCfg = getConfig('serverWarLocalCfg')
    local mapCfg = getConfig('serverWarLocalMapCfg1')
    local cityCfg = mapCfg.cityCfg
    local overSkyladderRank

    -- model
    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(areaGroup)

    local startBattleTs,endBattleTs = mAreaWar.getBattleTs()
    if ts < startBattleTs then
        response.err =  'time err'
        return response
    end

    mAreaWar.setRedis(nil,areaServerId)
    local runId = tonumber(request.params.runId) or 1
    if not battleDebug and not mAreaWar.battleRunFlag(runId) then
        response.err =  'Run for 20 seconds'
        return response
    end

    ---------------------------------------------------------------------

    -- 设置军团成员数据
    local function setMembersInfo(mAreaWar,bid,allianceData,iswin)
        local zid = allianceData.zid
        local aid = allianceData.aid
        local zidAid = mAreaWar.mkKey(zid,aid)

        -- 获取所有成员的最终贡献值
        local shopPointInfo,donateInfo = mAreaWar.getEndDonates(bid,zid,aid,iswin)
        for k,v in pairs(shopPointInfo[zidAid] or {}) do
            v =  tonumber(v) or 0
            if v > 0 then
                local donate = donateInfo[zidAid] and donateInfo[zidAid][tostring(k)] or 0
                mAreaWar.addUserPointAndDonateToDb({bid=bid,zid=zid,aid=aid,uid=k,point=v,donate=donate})
            end
        end
    end

    -- 设置军团数据
    local function setAllianceInfo(mAreaWar,bid,group,currRound,point,allianceData)
        if currRound == 2 and group == 'a' then
            point = point * 2
        end

        local roundLog = json.decode(allianceData.log) or {}
        table.insert(roundLog,{currRound,group,point})

        mAreaWar.updateAllianceData(bid,{
            bid = bid,
            zid = allianceData.zid,
            aid = tostring(allianceData.aid),
            round = currRound,
            point = (tonumber(allianceData.point) or 0) + point,
            pos = group,
            log = json.encode(roundLog),
            battle_at = os.time(),
        })
    end

    -- 设置bid信息
    local function setBidData(mAreaWar,bid,group,currRound)
        mAreaWar.updateBidData(bid,{bid = bid,["round_"..group] = currRound})
    end

    -- 军团复活BUFF(从占领据点获得)
    local reviveBuff = {}

    -- 重置用户行动数据(战斗失败)
    -- 复活时间要加上玩家上一次购买的复活时间
    local function resetActionData(bid,mAreaWar,userActionInfo,bplace,enemy)
        if mAreaWar.isNpc(userActionInfo.uid) then
            mAreaWar.clearPlaceTroops(bplace)
        else
            local zidAid = mAreaWar.mkKey(userActionInfo.zid,userActionInfo.aid)
            if not reviveBuff[zidAid] then
                reviveBuff[zidAid] = mAreaWar.getAllianceReviveBuff(zidAid)
            end

            local reviveTime = sevbattleCfg.reviveTime 
            local allianceReviveBuff = reviveBuff[zidAid]
            
            if allianceReviveBuff[1] then
                reviveTime = math.ceil(reviveTime * (1-allianceReviveBuff[1]))
                if reviveTime < 1 then 
                    reviveTime = 1
                end
            end

            local reviveTs = ts + reviveTime + (userActionInfo.lastRevive or 0)
            return mAreaWar.resetUserActionInfo({
                bid=bid,
                uid=userActionInfo.uid,
                bplace=bplace,
                basePlace=userActionInfo.basePlace,
                revive = reviveTs,
                enemy = enemy,
                sn = userActionInfo.sn,
                death = userActionInfo.death,
            },userActionInfo)
        end
    end

    --[[
        用户在据点发生战斗
    ]]
    local function userBattle(bid,placeId,aUserinfo,dUserinfo)
        -- 战报信息
        local tmpLogData = {
            bid = bid,
            btype = placeId,
            win = 0,    -- 进攻方是否胜利
            occupy=0,   -- 是否发生占领
            attzid = aUserinfo.zid,
            defzid = dUserinfo.zid,
            attuid=aUserinfo.uid,
            defuid=dUserinfo.uid,
            attname=aUserinfo.nickname or '',
            defname=dUserinfo.nickname or '',
            attaid=aUserinfo.aid or 0,
            defaid=dUserinfo.aid or 0,
            attaname=aUserinfo.aname or '',
            defaname=dUserinfo.aname or '',
            attsn = aUserinfo.sn,
            defsn = dUserinfo.sn,
        }

        -- 防守方先攻击,注意战斗BUFF
        local report, aAliveTroops, dAliveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops = mAreaWar.placeBattle(bid,aUserinfo,dUserinfo,cityCfg[placeId].landType,placeId)
        report.p = {
            {dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},
            {aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]},
        } 

        if battleAttSeq == 1 then
            report.p[1][3] = 1
            report.p[2][3] = 0
        end

        -- 进攻方胜利
        if report.r == 1 then
            tmpLogData.win = 1

            -- 更新胜利者的行动信息
            aUserinfo.troops = aAliveTroops
            aUserinfo.battle_at = ts
            aUserinfo.bplace = placeId
            aUserinfo.enemy = mAreaWar.mkKey(dUserinfo.zid,dUserinfo.uid,dUserinfo.sn)

            -- 清除死亡统计
            mAreaWar.incrUserWinStreak(aUserinfo)
            local setret,setdata = mAreaWar.setUserActionInfo(bid,aUserinfo)
            if setdata then
                mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            end

            -- 重置失败者的行动信息
            mAreaWar.incrUserDeathCount(dUserinfo)
            local enemy = mAreaWar.mkKey(aUserinfo.zid,aUserinfo.uid,aUserinfo.sn)
            local setret,setdata = resetActionData(bid,mAreaWar,dUserinfo,placeId,enemy)
            if setdata then
                mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            end

            -- 增加贡献
            mAreaWar.addUserDonateByTroop(bid,aUserinfo.zid,aUserinfo.uid,aUserinfo.aid,dDieTroops,true)
            mAreaWar.addUserDonateByTroop(bid,dUserinfo.zid,dUserinfo.uid,dUserinfo.aid,aDieTroops,false)

        else

            -- 胜利者是一个NPC
            if mAreaWar.isNpc(dUserinfo.uid) then
                mAreaWar.setPlaceNpcTroops(placeId,dAliveTroops,dUserinfo.HPRate)
            else
                -- 更新胜利者的行动信息
                dUserinfo.troops = dAliveTroops
                dUserinfo.battle_at = ts
                dUserinfo.bplace = placeId
                dUserinfo.enemy = mAreaWar.mkKey(aUserinfo.zid,aUserinfo.uid,aUserinfo.sn)

                mAreaWar.incrUserWinStreak(dUserinfo)
                local setret,setdata = mAreaWar.setUserActionInfo(bid,dUserinfo)
                if setdata then
                    mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
                end
                
                mAreaWar.addUserDonateByTroop(bid,dUserinfo.zid,dUserinfo.uid,dUserinfo.aid,aDieTroops,true)
            end

            -- 重置失败者的行动信息
            mAreaWar.incrUserDeathCount(aUserinfo)
            local enemy = mAreaWar.mkKey(dUserinfo.zid,dUserinfo.uid,dUserinfo.sn)
            setret,setdata = resetActionData(bid,mAreaWar,aUserinfo,placeId,enemy)
            mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            mAreaWar.addUserDonateByTroop(bid,aUserinfo.zid,aUserinfo.uid,aUserinfo.aid,dDieTroops,false)
        end

        tmpLogData.report = report

        return report.r, tmpLogData
    end

    -- 战斗是否已经结束
    local function battleIsOver(allianceWarPoint)
        -- 检测各军团的分数，是否达到结算分值
        if type(allianceWarPoint) == 'table' then
            for zidAid,point in pairs(allianceWarPoint) do
                point = tonumber(point) or 0
                if point >= sevbattleCfg.winPointMax then
                    return true,{'over: winPointMax', zidAid, point}
                end
            end
        end
        
        -- 提前20秒结算,保证前端来拉结果和对阵列表时有数据
        local overTs = endBattleTs - 20

        -- 结束时间
        if ts >= overTs then
            return true,{'over: timeout'}
        end
    end

    -- 当前据点的队伍数teamNum，相同的军团属于一个队伍,以此判断是否需要双方对战
    local function getPlaceTeamNum(placeBattlelist)
        local tnum = 0
        if #placeBattlelist.defenser > 0 then 
            tnum = tnum + 1 
        end
        if #placeBattlelist.attacker > 0 then 
            tnum = tnum + 1 
        end

        return tnum
    end

    local function run(bid,group,currRound)
        -- 获取此组参赛的军团信息
        local alliancesInfo = mAreaWar.getAlliancesData(bid)

        -- 参赛军团等于0时，直接结束
        if table.length(alliancesInfo) == 0 then
            table.insert(response.over,{bid,group,os.time(),'over: not found alliance data'})
            if ts > (startBattleTs + 600) then
                mAreaWar.setautocommit(true)
                setBidData(mAreaWar,bid,group,currRound)
                mAreaWar.setOverBattleFlag(bid,"0")
            end
            return
        end

        -- 地块的详细信息（每个地块中的用户列表）
        local placesInfo =  mAreaWar.getPlacesInfo(bid)
        local placesUserList = mAreaWar.getPlacesUserList(bid)
        
        -- 按sortCity的顺序执行
        for _,placeId in pairs(mapCfg.sortCity) do 
            -- 当前据点的用户列表
            local userlist = placesUserList[placeId]
            -- 地块占领者的aid
            local placeOwner = placesInfo[placeId][1]   
            -- 当前据点的战斗列表
            local placeBattlelist = userlist and mAreaWar.getPlaceBattleList(placeId,placeOwner,userlist,true)

            if type(placeBattlelist) == 'table' then
                local teamNum = getPlaceTeamNum(placeBattlelist)
                
                if teamNum == 1 then
                    -- 据点中只有一股势力时,如果是攻击方，直接占领该据点
                    if #placeBattlelist.attacker > 0 then
                        mAreaWar.occupyPlace(bid,placeId,placeBattlelist.attacker[1].aid,placeBattlelist.attacker[1].zid,placeBattlelist.attacker[1].uid,placeBattlelist.attacker[1].aname,placeBattlelist.attacker[1].nickname)
                    end

                -- 据点中有两股势力
                elseif teamNum == 2 then
                    -- 本据点交战次数,队伍成员数量已经限制好了,直接取了用
                    local battleTimes = #placeBattlelist.attacker
                    if #placeBattlelist.defenser > battleTimes then
                        battleTimes = #placeBattlelist.defenser
                    end
                
                    -- 进攻方与防守方的初始战斗位置
                    local aSlot,dSlot=0,0

                    for round=1,battleTimes do
                        -- 获取本次双方战斗位置,并记录
                        aSlot = mAreaWar.getBattleSlot(aSlot,placeBattlelist.attacker)
                        dSlot = mAreaWar.getBattleSlot(dSlot,placeBattlelist.defenser)

                        -- 是否占领,本轮减城防值
                        local isOccupied = false
                        local attackerAid = tostring(placeBattlelist.attacker[aSlot].aid)
                        local attackerZid = tostring(placeBattlelist.attacker[aSlot].zid)
                        local attackerUid = placeBattlelist.attacker[aSlot].uid
                        local attackerNickname = placeBattlelist.attacker[aSlot].nickname
                        local attackerAllianceName = placeBattlelist.attacker[aSlot].aname

                        if aSlot and dSlot then
                            local winStatus,battleReport = userBattle(bid,placeId,placeBattlelist.attacker[aSlot],placeBattlelist.defenser[dSlot])

                            if winStatus == 1 then
                                table.remove(placeBattlelist.defenser,dSlot)
                                dSlot = dSlot - 1 

                                --如果防守方没有人了，直接占领
                                if #placeBattlelist.defenser < 1 and not next(placeBattlelist.dHasReserve) then
                                    isOccupied = true
                                end
                            else
                                table.remove(placeBattlelist.attacker,aSlot)
                                aSlot = aSlot - 1
                            end

                            -- 处理玩家的战报数据
                            if isOccupied then battleReport.occupy = 1 end
                            mAreaWar.addBattleReport(battleReport)
                        end
                        
                        -- 如果占领了据点,退出循环
                        if isOccupied then
                            mAreaWar.occupyPlace(bid,placeId,attackerAid,attackerZid,attackerUid,attackerAllianceName,attackerNickname)
                            break
                        end

                        -- 如果没有了攻击方，退出循环
                        if #placeBattlelist.attacker < 1 then 
                            break 
                        end
                    end
                end
            end
        end

        -- 计算军团战场分,并推送
        local allianceWarPoint = mAreaWar.countAllianceWarPoint(bid)
        mAreaWar.setBattlePushData({battlePointInfo=allianceWarPoint})

        -- 判断战斗是否结束
        local isOver,overLog = battleIsOver(allianceWarPoint)
        if isOver then
            overSkyladderRank = true
            -- 数据保存走事务
            mAreaWar.setautocommit(false)

            local overPoints = {}
            for zidAid,aInfo in pairs(alliancesInfo) do
                table.insert(overPoints,{
                    tonumber(allianceWarPoint[zidAid]) or 0,
                    zidAid or '',
                    tonumber(aInfo.ladderpoint) or 0,
                    tonumber(aInfo.fight) or 0,
                    tonumber(aInfo.zid) or 0,
                    tonumber(aInfo.aid) or 0,
                })
            end
            
            table.sort(overPoints,function(a,b)
                if a[1] == b[1] then
                        if a[3] == b[3] then
                            if a[4] == b[4] then
                                if a[5] == b[5] then
                                    return a[6] < b[6]
                                else
                                    return a[5] < b[5]
                                end
                            else
                                return a[4] > b[4]
                            end
                        else
                            return a[3] > b[3]
                        end
                    else
                        return a[1] > b[1]
                    end
                end
            )

            
            local winner,iswin
            
            for k,overPinfo in ipairs(overPoints) do
                iswin = false
                -- overPoints已经排好序,第一个元素就是第一名
                if k == 1 then  
                    winner = overPinfo[2] 
                    iswin = true
                end

                -- 保存军团数据
                setAllianceInfo(mAreaWar,bid,group,currRound,overPinfo[1],alliancesInfo[overPinfo[2]])

                -- 保存军团成员的数据
                setMembersInfo(mAreaWar,bid,alliancesInfo[overPinfo[2]],iswin)
            end

            -- 保存bid的信息
            setBidData(mAreaWar,bid,group,currRound)

            -- 所有数据入库
            if mAreaWar.commit() then
                -- 需要将胜利者推送出去
                mAreaWar.setBattlePushData{over={winner=winner}}
                -- 设置战斗结束标识
                mAreaWar.setOverBattleFlag(bid,winner)
                -- 添加log
                table.insert(response.over,{bid,os.time(),'winner:',winner,overLog})
            else
                mAreaWar.rollback()
            end

            mAreaWar.setautocommit(true)

            overPoints = nil
        end

        -- 触发战斗任务
        mAreaWar.triggerBattleTask(bid,startBattleTs)

        -- 推送本场战斗的消息
        mAreaWar.battlePush(bid)

        -- 本场战斗数据保存
        mAreaWar.save(bid)
    end

    ------------------------------------------------------------------------------------------

    local bidDatas = mAreaWar.getBidData(areaServerId)
    local groups = mAreaWar.getWarGroups()

    for k,v in pairs(bidDatas) do
        -- for _,group in pairs(groups) do
            local group = areaGroup
            local bid = v.bid
            reviveBuff = {}

             mAreaWar.reset()
             mAreaWar.setWarGroup(group)
            
            local currRound = mAreaWar.getCurrentRound(tonumber(v.st))

            -- TODO 这里修数据感觉单独拿出去要好点,检查一次就够了
            mAreaWar.checkRoundData(bid,currRound,nil,v)

            -- 检测结束标识
            if tonumber(v["round_"..group]) >= 2 then
                table.insert(response.over,{bid,group,'round:',tonumber(v["round_"..group]),os.time()})
            elseif mAreaWar.getOverBattleFlag(bid) then
                table.insert(response.over,{bid,group,'over: cache flag',os.time()})
            else
                -- run(bid,group,currRound)
                local rstatus,rerror = pcall(run,bid,group,currRound)
                if not rstatus then
                    response.err[bid] = {runId,rerror}
                end
            end
        -- end
    end
    
    -- local overSkyladderRank = true
    -- if overSkyladderRank and base and type(base) == 'table' and base.status and tonumber(base.status) == 1 then
        -- local bidDatas = mAreaWar.getBidData()
        -- local groups = mAreaWar.getWarGroups()
        -- for k,v in pairs(bidDatas) do
            -- local currnum = 0
            -- local groupnum = #groups or 0
            -- for _,group in pairs(groups) do
                -- if tonumber(v["round_"..group]) >= 2 then
                    -- currnum = currnum + 1
                -- end
            -- end
            -- if currnum >= groupnum then
                -- require "api/admin.accountsbattle"
                -- local status,result = pcall(_ENV["api_admin_accountsbattle"],{params={battleType=5}})
                -- if status then
                    -- writeLog(json.encode({ts=ts,runId=runId,status='sucess',result=result}),"skyladderAccountsForArea")
                -- else
                    -- local base = skyladderserver.getStatus()
                    -- writeLog(json.encode({ts=ts,runId=runId,status='fail',result=result}),"skyladderAccountsForArea")
                -- end
            -- end
        -- end
    -- end

    response.ret = 0
    response.msg = 'Success'
    response.runId = runId

    writeLog(response,"areateamwarserver")

    return response
end
