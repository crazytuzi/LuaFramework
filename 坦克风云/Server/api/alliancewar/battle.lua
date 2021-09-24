function api_alliancewar_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {},
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewar')== 0 then
        response.ret = -4012
        return response
    end

    -- 参数验证 -----------------------------------------------------------------

    local placeId = tonumber(request.params.placeId)  -- 地点
    local positionId = tonumber(request.params.positionId) -- 战场
    local fleet = request.params.fleetinfo
    local hero = request.params.hero
    local equip = request.params.equip
    local uid = tonumber(request.uid)

    if uid == nil or placeId == nil or positionId == nil or type(fleet) ~= 'table' then
        response.ret = -102
        return responsec
    end
    
    -- 舰队验证 
    local fleetInfo = {}
    local num = 0
    local tnum = 0
    for m,n in pairs(fleet) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
            tnum = tnum +1
    end

    -- 舰队数不合法
    if num <= 0 or tnum ~= 6 then
        response.ret = -5006
        return response
    end

    -- 事务 -----------------------------------------------------------------

    local db = getDbo()
    db.conn:setautocommit(false)


    -- 占领信息 -----------------------------------------------------------------

    -- 占领据点的用户信息
    local positionInfo = {}

    -- 占领阵地
    -- params int occupyTs 占领时间
    -- params table mAllianceWar 战斗model
    -- params table mTroop 部队model
    -- params int positionId 战场 
    -- params int placeId 据点
    -- params int warId 战斗标识id
    -- params int uid 用户id
    -- params table fleetInfo 占领部队信息
    -- params int aid 所属军团
    -- label int 红/蓝方标识 1红，2蓝
    -- buff table 占领者的buff效果
    -- attackStatus 进攻胜利是1，防守胜利是2
    local function occupyPosition(occupyTs,mAllianceWar,mTroop,positionId,placeId,warId,uid,fleetInfo,mUserinfo,label,buff,attackStatus)
        -- do return true end
        local troopsInfo = mAllianceWar:setPositionTroops(occupyTs,positionId,placeId,warId,uid,fleetInfo,mUserinfo,label,buff,attackStatus)
        if not troopsInfo then
            return false
        end
        
        mTroop.setFleetTroopsByAllianceWarId(troopsInfo)

        positionInfo['h'..placeId] = troopsInfo

        return true
    end

    local function setKfkLog(mTroop,dietroops)
        -- kafkaLog
        local storeTroops = mTroop.getStoreTroopsByFleet(dietroops)
        regKfkLogs(mTroop.uid,'tankChange',{
                addition={
                    {desc="类型",value="军团战"},
                    {desc="损失",value=dietroops},
                    {desc="留存",value=storeTroops},
                }
            }
        ) 
    end

    -- 初始化用户信息 -----------------------------------------------------------------

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","useralliancewar"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mHero    = uobjs.getModel('hero')
    local mTroop = uobjs.getModel('troops')    
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local mSequip = uobjs.getModel('sequip')

   --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
    else
        mHero.releaseHero('l',1)
        hero={}
    end

    -- end 
    mHero.addHeroFleet('l',hero,1)

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip) then
        response.ret=-8650 
        return response
    end

    mSequip.addEquipFleet('l', 1, equip)

    local mAllianceWar = require "model.alliancewar"

    local duobjs
    local mDefenderUserinfo
    local mDefenderTroop
    local mDefenderHero
    local mDefenderAllianceWar

    local attBuff = mUserAllianceWar.getBattleBuff()
    local defBuff = {}
    local victor = uid  -- 默认胜利者
    local attRaising = 0    -- 攻方贡献
    local defRaising = 0    -- 防守方贡献
    local attPoint = 0  -- 攻方积分
    local defPoint = 0  -- 防守方积分
    local ts = getClientTs()    -- 当前时间
    local weets = getWeeTs()
    local report = {}

    -- 逻辑 -----------------------------------------------------------------

    -- 战场未开放
    local warId = mAllianceWar:getWarId(positionId)
    if not warId then
        response.ret = -4002
        return response
    end

    -- 验证aid是否报名
    local queueInfo, code = M_alliance.getmembequeue{uid=uid,aid=mUserinfo.alliance,position=positionId,date=weets,warId=warId}        
    if not queueInfo then
        response.ret = code
        return response
    end

    local label = {}  -- 红蓝标识
    for k,v in pairs(queueInfo.data) do
        local tmpAid = tonumber(v.aid)
        label[tmpAid] = v.rank
    end

    local battleStatus,cdts = mUserAllianceWar.getBattleStatus() 
    if battleStatus ~= 0 then
        response.ret = battleStatus
        return response
    end

    local warOpenStatus = mAllianceWar:getWarOpenStatus(positionId)
    if warOpenStatus ~= 0 then
        response.ret = warOpenStatus
        return response
    end

    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo) then
        response.ret = -5006
        return response
    end

    -- 扣除出战的坦克数量
    local aid,num
    for k,v in pairs(fleetInfo) do
        local aid,num = v[1], arrayGet(v,2)
        if aid and mTroop.troops[aid] then 
            if not mTroop.consumeTanks(aid,num) then
                response.ret = -5006
                return response
            end
        end
    end

    -- kafkaLog
    local storeTroops = mTroop.getStoreTroopsByFleet(fleetInfo)
    regKfkLogs(uid,'tankChange',{
            addition={
                {desc="军团战派出",value=fleetInfo},
                {desc="留存",value=storeTroops},
            }
        }
    ) 

    -- 未加入军团（可能军团战期间被踢出）
    if mUserinfo.alliance < 0 then
        response.ret = -4005
        return response
    end

    -- 有部队正在据点中
    if mTroop.getFleetTroopsByAllianceWarId(warId) then
        response.ret = -4008
        return response
    end

    local positionFleet = mAllianceWar:getPlaceInfo(positionId,placeId,warId)
    if type(positionFleet) ~= 'table' then
        positionFleet = {}
    end
    
    local oid = tonumber(positionFleet.oid)   -- 地块占领者    
    local defenderOccupyTs = tonumber(positionFleet.st) or ts   -- 占领者的占领时间
    local lastUpdateTs = tonumber(positionFleet.updated_at) or ts   -- 上一次更新时间(用来计算每场战斗后的积分)
    local allianceWarCfg = getConfig('allianceWarCfg')

    if not oid then
        if not occupyPosition(ts,mAllianceWar,mTroop,positionId,placeId,warId,uid,fleetInfo,mUserinfo,label[mUserinfo.alliance],attBuff,3) then
            response.ret = -4001
            return response
        end
    end

    --  已经占领此地
    if  oid == uid then
        response.ret = -4004
        return response
    end

    if oid then
        duobjs = getUserObjs(oid)        
        duobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","useralliancewar"})
        mDefenderUserinfo = duobjs.getModel('userinfo')        
        mDefenderTroop = duobjs.getModel('troops')
        mDefenderHero = duobjs.getModel('hero')
        local defenderHero =mDefenderHero.getAttackHeros('l',1)

        local mDefenderEquip = duobjs.getModel('sequip')
        local dEquipid = mDefenderEquip.getEquipFleet('l',1)
        
        mDefenderAllianceWar = duobjs.getModel('useralliancewar')
        defBuff = mDefenderAllianceWar.getBattleBuff()

        -- 已被我方占领
        if mUserinfo.alliance == mDefenderUserinfo.alliance then
            response.ret = -4003
            return response
        end
        
        local defenderTroops = mDefenderTroop.getFleetTroopsByAllianceWarId(warId,positionFleet.troops)

        -- 没有防守部队
        if not defenderTroops then
            if not occupyPosition(ts,mAllianceWar,mTroop,positionId,placeId,warId,uid,fleetInfo,mUserinfo,label[mDefenderUserinfo.alliance],attBuff,3) then
                response.ret = -4001
                return response
            end

        -- 有防守部队
        else
            local defenderTroopInfo,_,dherosInfo = mDefenderTroop.initFleetAttribute(defenderTroops,5,{hero=defenderHero,equip=dEquipid})
            local attackerTroopInfo,_,aherosInfo = mTroop.initFleetAttribute(fleetInfo,5,{hero=hero})
            
            require "lib.battle"
            require "model.battle"
            local mBattle = model_battle()

            local aInavlidFleet, dInvalidFleet,aSurviveTroops,dSurviveTroops

            -- 损失的部队   
            report.lostShip = {
                attacker  = {},
                defender = {},
            }
            -- 双方积分
            report.warPoint = {
                attPoint = 0,
                defPoint = 0,
            }

            local attSeq,seqPoint

            report.d, report.w, aInavlidFleet, dInvalidFleet,attSeq,seqPoint = battle(attackerTroopInfo,defenderTroopInfo,1)
            report.t = {defenderTroops,fleetInfo}

            if attSeq == 1 then
                report.p = {{mDefenderUserinfo.nickname,mDefenderUserinfo.level,1,seqPoint[2]},{mUserinfo.nickname,mUserinfo.level,0,seqPoint[1]}}      
            else
                report.p = {{mDefenderUserinfo.nickname,mDefenderUserinfo.level,0,seqPoint[2]},{mUserinfo.nickname,mUserinfo.level,1,seqPoint[1]}} 
            end

            report.h = {dherosInfo[1],aherosInfo[1]}
            
            -- 部队统计【损失的部队，幸存的部队】
            report.lostShip.attacker ,aSurviveTroops = mBattle.allianceWarDamageTroops(uid,fleetInfo,aInavlidFleet)
            report.lostShip.defender,dSurviveTroops = mBattle.allianceWarDamageTroops(oid,defenderTroops,dInvalidFleet)

            -- kafkaLog
            setKfkLog(mTroop,report.lostShip.attacker)
            setKfkLog(mDefenderTroop,report.lostShip.defender)
            
            -- 积分计算 攻击方此此无积分
            report.warPoint.attPoint = 0
            report.warPoint.defPoint = mAllianceWar:getPointByOccupiedTime(positionId,placeId,defBuff,lastUpdateTs,ts)
            
            -- 贡献计算 对方损失的坦克数，折算为自己的积分
            attRaising = mAllianceWar:getDonateByOccupiedTime(report.lostShip.defender,report.warPoint.attPoint,attBuff)
            defRaising = mAllianceWar:getDonateByOccupiedTime(report.lostShip.attacker,report.warPoint.defPoint,defBuff)
            
            -- 如果有军团，给相应的军团增加积分
            if mDefenderUserinfo.alliance > 0 then
                if not mAllianceWar:addPoint(positionId,label[mDefenderUserinfo.alliance],report.warPoint.defPoint,warId) then
                    local tmpLog = {
                        msg="addPoint failed",
                        point=report.warPoint.defPoint,
                        aid=mDefenderUserinfo.alliance,
                        warId=warId,
                    }
                    mAllianceWar:writeLog(tmpLog)
                end
            end

            -- 胜利
            if report.w == 1 then
                victor = uid

                if not occupyPosition(ts,mAllianceWar,mTroop,positionId,placeId,warId,uid,aSurviveTroops,mUserinfo,label[mUserinfo.alliance],attBuff,1) then
                    response.ret = -4001
                    return response
                end

                -- 平局失败，很有可能有余下的部队需要返给用户
                if type(dSurviveTroops) then
                    for k,v in pairs(dSurviveTroops) do
                        if (tonumber(v[2]) or 0) > 0 then
                            mDefenderTroop.incrTanks(v[1],v[2])
                        end
                    end
                end 

                -- 防守方的战斗部队清空
                mDefenderTroop.setFleetTroopsByAllianceWarId({})

                -- 重新集结，有cd时间
                mDefenderAllianceWar.setCdTimeAt()

            -- 失败了
            else
                victor = oid

                if not occupyPosition(defenderOccupyTs,mAllianceWar,mDefenderTroop,positionId,placeId,warId,oid,dSurviveTroops,mDefenderUserinfo,label[mDefenderUserinfo.alliance],defBuff,2) then
                    response.ret = -4001
                    return response
                end

                -- 平局失败，很有可能有余下的部队需要返给用户
                if type(aSurviveTroops) then
                    for k,v in pairs(aSurviveTroops) do
                        if (tonumber(v[2]) or 0) > 0 then
                            mTroop.incrTanks(v[1],v[2])
                        end
                    end
                end 

                -- 重新集结，有cd时间
                mUserAllianceWar.setCdTimeAt()
                mHero.releaseHero('l',1)
            end

            -- 刷新一下积分
            mAllianceWar:getAllPlacePoint(positionId,true,warId)

            attPoint = report.warPoint.attPoint
            defPoint = report.warPoint.defPoint
        end
    end

    -- 战斗日志 -------------------------------------------------------------

    local userbattlelog = {
        warId = warId,
        attacker = uid,
        defender = oid or 0,
        attackerName = mUserinfo.nickname,
        defenderName = mDefenderUserinfo and mDefenderUserinfo.nickname or "",
        attackerAllianceId = mUserinfo.alliance,
        defenderAllianceId = mDefenderUserinfo and mDefenderUserinfo.alliance or 0,
        attAllianceName = mUserinfo.alliancename,
        defAllianceName = mDefenderUserinfo and mDefenderUserinfo.alliancename or "",
        attBuff = attBuff,
        defBuff = defBuff,
        attPoint = attPoint,
        defPoint = defPoint,
        victor = victor,
        report = report,
        attRaising = attRaising,
        defRaising = defRaising,
        position = positionId,
        placeid = placeId,
    }

    local battlelog = json.encode({userbattlelog})
    
    local addbattlelogRet, code = M_alliance.addbattlelog({method = 2,date=weets,data=battlelog})

    -- 记下Log
    mAllianceWar:writeLog({method = 2,date=weets,data=battlelog})

    if not addbattlelogRet then
        mAllianceWar:writeLog({msg="addbattlelog failed",battlelog=battlelog})
    end

    -- 战斗日志 -------------------------------------------------------------

    processEventsBeforeSave()
    
    
    local flag 
    if uobjs.save() then
        if duobjs then
            if duobjs.save() and db.conn:commit() then
                flag = true
            end
        else
            if db.conn:commit() then
                flag = true
            end
        end
    end

    if flag == true then
        processEventsAfterSave()

        response.data.troops = mTroop.toArray(true)
        response.data.alliancewar.positionInfo = positionInfo
        response.data.useralliancewar = mUserAllianceWar.toArray(true)


        if userbattlelog then
            response.data.alliancewar.report = {0}
            local tmpKey = {}
            table.insert(response.data.alliancewar.report,userbattlelog.warId)
        end

        if addbattlelogRet then
            response.data.alliancewar.report = addbattlelogRet.data.log
        end
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.ret = 0
        response.msg = 'Success'

        -- push -------------------------------------------------
        local pushCmd = 'alliancewar.battle.push'
        local pushData = {
            alliancewar = {
                positionInfo = positionInfo
            }
        }

        for _,v in pairs(queueInfo.data) do
            if type(v.members) == 'table' then
                for _,n in pairs(v.members) do
                    local mid = tonumber(n.uid)
                    if mid then
                        -- 如果是防守方，还需要推送部队信息和cd信息
                        if mid == oid then
                            local defenderPushData = copyTab(pushData)
                            defenderPushData.troops = mDefenderTroop.toArray(true)
                            defenderPushData.useralliancewar = mDefenderAllianceWar.toArray(true)
                            regSendMsg(mid,pushCmd,defenderPushData)
                        else
                            regSendMsg(mid,pushCmd,pushData)
                        end                    
                    end
                end
            end
        end
        -- push -------------------------------------------------
    end

    return response
end
