--[[
    区域军团战，战斗    

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
function api_areawar_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        afterErr = {},
        over={},
    }

    local battleDebug = false

    ---------------------------------------------------------------------
    -- init
    local ts = os.time()
    local sevbattleCfg = getConfig('areaWarCfg')
    local mapCfg = getConfig('localWarMapCfg')
    local cityCfg = mapCfg.cityCfg

    -- model
    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()

    -- 处理给前端
    response.bid = bid
    response.bts = ts

    local startBattleTs,endBattleTs = mAreaWar.getBattleTs()
    if ts < startBattleTs then
        response.err =  'time err'
        return response
    end

    -- 是否周2
    if tonumber(getDateByTimeZone(ts,"%w")) ~= sevbattleCfg.prepareTime+sevbattleCfg.battleTime then
        response.err =  'weekday err'
        response.weekday = tonumber(getDateByTimeZone(ts,"%w")) 
        return response
    end

    if not battleDebug and not mAreaWar.battleRunFlag() then
        response.err =  'Run for 20 seconds'
        return response
    end

    -- 检测结束标识
    if mAreaWar.getOverBattleFlag(bid) then
        response.over = 'over: cache flag'
        return response
    end

    if moduleIsEnabled("areawar") == 0 then
        response.err = 'not open'
        return response
    end

    ---------------------------------------------------------------------
    -- function
    local function setOverAreaWarInfo(mAreaWar,bid,aid)
        aid = tostring(aid)

        -- 如果有占领王城者，需要给所有军团成员最终胜利分,直接从缓存取成员，有可能基地开炮把王城搞死
        if (tonumber(aid) or 0) > 0 then
            local members = mAreaWar.getAllianceMemUids(bid,aid)
            mAreaWar.addUserDonate(members,aid,sevbattleCfg.occupyRate)
        end

        local allianceSlaves = mAreaWar.setAllianceSlaves(bid)
        local usersDonate = mAreaWar.setUsersDonate(bid) or mAreaWar.getUserDonate(bid)
        local winAllianceSlaves = mAreaWar.formatAllianceSlavesForOver(bid,allianceSlaves[aid],usersDonate['all'])
        local donateList = mAreaWar.sortDonateList(usersDonate['all'])
        local tasks = mAreaWar.getAllUsersTasks(bid)

        for k,v in pairs(donateList) do
            local tUid = tostring(v[1])
            if type(tasks[tUid]) ~= 'table' then
                tasks[tUid] = {}
            end

            tasks[tUid]["t7"] = k
            tasks[tUid]["t8"] = k
            tasks[tUid]["t9"] = k
        end
        
        local overData = {
            aid=tonumber(aid),
            aslave=winAllianceSlaves,
            content=usersDonate[tostring(aid)],
            donateList=donateList,
            tasks=tasks,
            exp=sevbattleCfg.winEXP,
            bid=bid,
        }

        local execRet, code = M_alliance.endareabattle(overData)
        writeLog({
            donateList = donateList or "not donateList",
            execRet = execRet,
            code = code,
            bloodValue=mAreaWar.getAlliancesDeBloodValue(bid),
            exp=sevbattleCfg.winEXP,
            overData = overData,
            placesInfo =  mAreaWar.getPlacesInfo(bid),
            msg = 'M_alliance endareabattle',
        },"areawar")

        mAreaWar.setBattlePushData{over={winner=aid}}

        -- 设置战斗结束标识
        mAreaWar.setOverBattleFlag(bid,aid)
    end

    -- 设置用户行动数据
    local function resetActionData(bid,mAreaWar,userinfo,bplace,enemy)    
        -- 如果需要重置NPC,表示NPC部队全灭了
        if userinfo.uid == -1 then
            return mAreaWar.clearPlaceTroops(bplace)
        end

        -- 复活时间需要加上最后一次购买的复活时间(复活时间被秒后需要累计到下一次)
        return mAreaWar.resetUserActionInfo({
                bid=bid,
                aid=userinfo.aid,
                uid=userinfo.uid,
                level=userinfo.level,
                nickname=userinfo.nickname,
                alliancename=userinfo.alliancename,
                bplace=bplace,
                basePlace=userinfo.basePlace,
                revive = ts + sevbattleCfg.reviveTime + (userinfo.lastRevive or 0),
                enemy = enemy,
                -- tasks = userinfo.tasks,
                -- TODO 成就与奖励也需要保存
            })
    end

    -- 用户在据点发生战斗
    -- bid, 区域战标识
    -- placeId, 战斗据点
    -- aUserinfo 攻击方信息
    -- dUserinfo 防守方信息
    local function userbattle(bid,placeId,aUserinfo,dUserinfo)
        -- 战报字段
        local tmpLogData = {
            bid = bid,
            btype = placeId,
            win = 0,    -- 进攻方是否胜利
            occupy=0,   -- 是否发生占领
            attuid=aUserinfo.uid,
            defuid=dUserinfo.uid,
            attname=aUserinfo.nickname or '',
            defname=dUserinfo.nickname or '',
            attaid=aUserinfo.aid or 0,
            defaid=dUserinfo.aid or 0,
            attaname=aUserinfo.alliancename or '',
            defaname=dUserinfo.alliancename or '',
        }

        -- 防守方先攻击,注意战斗BUFF
        local report, aAliveTroops, dAliveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops = mAreaWar.placeBattle(aUserinfo,dUserinfo,cityCfg[placeId].landType)

        report.p = {
            {dUserinfo.nickname,dUserinfo.level,0,seqPoint[2]},
            {aUserinfo.nickname,aUserinfo.level,1,seqPoint[1]},
        } 

        if battleAttSeq == 1 then
            report.p[1][3] = 1
            report.p[2][3] = 0
        end

        tmpLogData.report = report

        -- 进攻方胜利
        if report.r == 1 then
            tmpLogData.win = 1

            -- 更新胜利者的行动信息
            aUserinfo.troops = aAliveTroops
            aUserinfo.battle_at = ts
            aUserinfo.bplace = placeId
            aUserinfo.enemy = dUserinfo.uid

            local setret,setdata = mAreaWar.setUserActionInfo(bid,aUserinfo)
            if setdata then
                mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            end

            -- 重置失败者的行动信息
            local setret,setdata = resetActionData(bid,mAreaWar,dUserinfo,placeId,aUserinfo.uid)
            if setdata then
                mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            end

            -- 增加贡献
            mAreaWar.addUserDonate(aUserinfo.uid,aUserinfo.aid,sevbattleCfg.winRate)
            mAreaWar.addUserDonate(dUserinfo.uid,dUserinfo.aid,sevbattleCfg.loseRate)

            -- 如果防守方不是NPC,捕获奴隶
            if tonumber(dUserinfo.uid) > 0 then
                mAreaWar.captureSlave(bid,dUserinfo.uid,aUserinfo.aid)
            end

        else

            -- 胜利者是一个NPC
            if dUserinfo.uid == -1 then
                mAreaWar.setPlaceNpcTroops(placeId,dAliveTroops)
            else
                -- 更新胜利者的行动信息
                dUserinfo.troops = dAliveTroops
                dUserinfo.battle_at = ts
                dUserinfo.bplace = placeId
                dUserinfo.enemy = aUserinfo.uid

                local setret,setdata = mAreaWar.setUserActionInfo(bid,dUserinfo)
                if setdata then
                    mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
                end
                mAreaWar.captureSlave(bid,aUserinfo.uid,dUserinfo.aid)
                mAreaWar.addUserDonate(dUserinfo.uid,dUserinfo.aid,sevbattleCfg.winRate)
            end

            -- 重置失败者的行动信息
            setret,setdata = resetActionData(bid,mAreaWar,aUserinfo,placeId,dUserinfo.uid)
            mAreaWar.setBattlePushData({usersActionInfo=mAreaWar.formatUserActionDataForClient(setdata)})
            mAreaWar.addUserDonate(aUserinfo.uid,aUserinfo.aid,sevbattleCfg.loseRate)
        end

        -- 任务:进行1场战斗,歼灭任意坦克X辆
        mAreaWar.setUserTask(bid,aUserinfo.uid,{t1=1,t2=dDieTroops})
        mAreaWar.setUserTask(bid,dUserinfo.uid,{t1=1,t2=aDieTroops})

        return report.r, tmpLogData
    end

    local function run(bid)
        -- 获取此组参赛的军团信息
        local alliancesInfo = mAreaWar.getAlliancesData(bid)
        local allianceNum = table.length(alliancesInfo)

        -- 参赛军团等于0时，直接结束
        -- 军团数是1是判断此军团是否是王城，王城直接结算
        if allianceNum == 0 then
            response.over = 'over: not found alliance data'
            return response
        elseif allianceNum == 1 then
            for k,v in pairs(alliancesInfo) do
                if tonumber(v.ranking) == 5 then
                    setOverAreaWarInfo(mAreaWar,bid,tonumber(v.aid))

                    response.occupyAid = v.aid
                    response.over = 'over: The only alliance is king'
                    return response
                end
            end
        end

        -- 时间到了结算,
        -- 此时一定是王城没有被攻破,王城占领者还是原来的用户
        if ts >= endBattleTs then
            local occupyAid = 0
            for k,v in pairs(alliancesInfo) do
                if tonumber(v.ranking) == 5 then
                    occupyAid = tonumber(v.aid)
                    break
                end
            end

            setOverAreaWarInfo(mAreaWar,bid,occupyAid)
            response.occupyAid = occupyAid
            response.over = 'over: time out'
            return response
        end

        -- 战场战斗 ---------------------------------------

        -- 地块的详细信息（每个地块中的用户列表）
        local placesInfo =  mAreaWar.getPlacesInfo(bid)
        local placesUserList = mAreaWar.getPlacesUserList(bid)

        for _,placeId in pairs(mapCfg.sortCity) do 
            -- 当前据点的用户列表
            local userlist = placesUserList[placeId]

            -- 地块占领者的aid
            local placeOwner = placesInfo[placeId][1]   

            -- 当前据点的战斗列表
            local placeBattlelist = userlist and mAreaWar.getPlaceBattleList(placeId,placeOwner,userlist,true)
            
            if type(placeBattlelist) == 'table' then
                -- 当前据点的队伍数teamNum，相同的军团属于一个队伍，以此判断是否需要双方对战
                local tnum = 0
                if #placeBattlelist.defenser > 0 then 
                    tnum = tnum + 1 
                end
                if #placeBattlelist.attacker > 0 then 
                    tnum = tnum + 1 
                end

                --[[
                    如果此据点只有1只队伍
                        是否是主基地
                        a、如果占领者是当前军团，则不处理
                        b、如果据点占领者不是属于当前队伍的话
                            1、此据点是野地，直接占领
                            2、此据点是主基地，需要掉耐久，耐久值为0后直接占领，并且主基地所属军团全部退出战斗，其所属据点全部中立，刷新NPC
                            3、据点是王城
                                需要与该主基地部队发生战斗，主基地部队被打完了，则直接掉耐久，每人每次掉5点
                    如果此据点有2只部队直接按正常逻辑走
                ]]
                
                -- 据点类型，1是主基地，2是据点，3是王城
                local placeType = cityCfg[placeId].type

                -- 据点中只有一股势力时,并且是攻击方时,直接占领
                if tnum == 1 then
                    if placeType == 2 and #placeBattlelist.attacker > 0 then
                        mAreaWar.occupyPlace(bid,placeId,placeBattlelist.attacker[1].aid)

                        -- 任务攻陷据点一次
                        mAreaWar.setUserTask(bid,placeBattlelist.attacker[1].uid,{t3=1,t4=1})
                    end

                -- 据点中有两股势力
                elseif tnum == 2 then
                    local maxRound = #placeBattlelist.attacker
                    if #placeBattlelist.defenser > maxRound then
                        maxRound = #placeBattlelist.defenser
                    end
                    
                    -- 进攻方与防守方的初始战斗位置
                    local aSlot,dSlot=0,0

                    for round=1,maxRound do
                        -- 获取本次双方战斗位置,并记录
                        aSlot = mAreaWar.getBattleSlot(aSlot,placeBattlelist.attacker)
                        dSlot = mAreaWar.getBattleSlot(dSlot,placeBattlelist.defenser)

                        -- 是否占领
                        local isOccupied = false
                        local attackerAid = tostring(placeBattlelist.attacker[aSlot].aid)

                        if aSlot and dSlot then
                            local winStatus,battleReport = userbattle(bid,placeId,placeBattlelist.attacker[aSlot],placeBattlelist.defenser[dSlot])

                            -- 进攻者胜利
                            if winStatus == 1 then
                                table.remove(placeBattlelist.defenser,dSlot)
                                dSlot = dSlot - 1 
                                
                                -- 普通据点没有了防守方,并且没有预备队,直接占领
                                if placeType == 2 and #placeBattlelist.defenser < 1 and not next(placeBattlelist.dHasReserve) then
                                    isOccupied = true
                                end

                            -- 进攻者失败
                            else
                                table.remove(placeBattlelist.attacker,aSlot)
                                aSlot = aSlot - 1

                                -- 主基地需要检测剩余战斗队列与预备队中是否还有攻击方军团成员
                                -- 如果没有需要清除此军团已取得的目标据点城防值
                                if placeType == 1 then
                                    local inQueue = mAreaWar.aidInBattleQueue(attackerAid,placeBattlelist.attacker)
                                    local inReserve = placeBattlelist.aHasReserve[tostring(attackerAid)]
                                    
                                    if not inQueue and not inReserve then
                                        mAreaWar.clearAllianceDeBloodValue(bid,attackerAid,placeId)
                                    end
                                end

                                -- 防守据点胜利
                                mAreaWar.setUserTask(bid,placeBattlelist.defenser[dSlot].uid,{t5=1,t6=1})
                            end

                            -- 如果占领，需要写战报,给占领积分
                            if isOccupied then
                                battleReport.occupy = 1
                                mAreaWar.occupyPlace(bid,placeId,attackerAid)
                                mAreaWar.addUserDonate(placeBattlelist.aid2attacker[attackerAid],attackerAid,sevbattleCfg.winAllianceRate)

                                -- 任务攻陷据点一次
                                mAreaWar.setUserTask(bid,placeBattlelist.attacker[aSlot].uid,{t3=1,t4=1})
                            end

                            -- 添加玩家战报
                            mAreaWar.addBattleReport(battleReport)
                        end

                        -- 如果占领了据点,退出循环
                        if isOccupied or #placeBattlelist.attacker < 1 then
                            break
                        end
                    end
                end

                -- 优化后在这里扣城防值

                -- 如果是主基地或王城，有城防值，需要按人次掉城防值
                -- 城防值掉为0后，占领主基地/王城
                -- 主基地占领需要清除主基地在整个战场的所属势力，刷新每个地图的战斗队列
                -- 王城占领需要结算
                if (placeType == 3 or placeType == 1) and #placeBattlelist.attacker > 0 then
                    local deBloodValue = sevbattleCfg.attackBase * #placeBattlelist.attacker
                    local cBlood = mAreaWar.dePlaceBlood(bid,placeId,deBloodValue)

                    for round=1,#placeBattlelist.attacker do
                        local attackerAid = tostring(placeBattlelist.attacker[round].aid)
                        local attackerUid = tostring(placeBattlelist.attacker[round].uid)

                        -- 单场胜利贡献分
                        mAreaWar.addUserDonate(attackerUid,attackerAid,sevbattleCfg.winRate)
                        -- 增加我方军团攻掉的城防值
                        mAreaWar.addAllianceDeBloodValue(bid,placeId,attackerAid,sevbattleCfg.attackBase)

                        if cBlood <= 0 then
                            -- 任务攻陷据点一次
                            mAreaWar.setUserTask(bid,placeBattlelist.attacker[round].uid,{t3=1,t4=1})
                        end
                    end

                    -- 如果占领了据点
                    if cBlood <= 0 then
                        local defenserAid = tostring(placesInfo[placeId][1])
                        local occupyAid = mAreaWar.occupyPlace(bid,placeId)
                        mAreaWar.addUserDonate(placeBattlelist.aid2attacker[occupyAid],occupyAid,sevbattleCfg.winAllianceRate)

                        -- 王城
                        if placeType == 3 then
                            setOverAreaWarInfo(mAreaWar,bid,occupyAid)
                            response.over = '0 Blood value'
                            response.occupyAid = occupyAid
                            return response

                        -- 主基地
                        elseif placeType == 1 then
                            if (tonumber(defenserAid) or 0) > 0 then
                                local isOver = mAreaWar.allianceDestroy(bid,defenserAid,placeId)
                                if isOver then
                                    setOverAreaWarInfo(mAreaWar,bid,occupyAid)
                                    response.over = 'all alliance die'
                                    response.occupyAid = occupyAid
                                    return response
                                end

                                -- 主基地挂了，需要重新刷新据点用户列表
                                placesUserList = mAreaWar.getPlacesUserList(bid)
                            end
                        end
                    end

                end

            end

        end
    end

    -- 主基地攻打王城,如果王城城防值为0后，需要结算出王城归属
    local capitalBlood = mAreaWar.baseAttackCapital(bid)

    if capitalBlood <= 0 then
        local occupyAid = mAreaWar.occupyPlace(bid,mapCfg.capitalID)
        setOverAreaWarInfo(mAreaWar,bid,occupyAid)
        response.over = '0 Blood value of baseAttackCapital'
        response.occupyAid = occupyAid
    else
        run(bid)
    end

    -- 推送本场战斗的消息
    mAreaWar.battlePush(bid)
    -- 本场战斗数据保存
    mAreaWar.save(bid)
    
    response.ret = 0
    response.msg = 'Success'

    writeLog(response,"runareawar")
    return response
end
