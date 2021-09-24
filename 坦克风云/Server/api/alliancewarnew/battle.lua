function api_alliancewarnew_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {},
        },
    }

    -- 参数验证 -----------------------------------------------------------------

    local placeId = request.params.placeId  -- 地点
    local positionId = tonumber(request.params.positionId) -- 战场
    local uid = tonumber(request.uid)
    local allianceWarCfg = getConfig('allianceWar2Cfg')

    if uid == nil or placeId == nil or positionId == nil or not allianceWarCfg.stronghold[placeId] then
        response.ret = -102
        return responsec
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
    local function occupyPosition(occupyTs,mAllianceWar,placeId,warId,uid,fleetInfo,userinfo,label,attackStatus,binfo)
        local occupyInfo = mAllianceWar.setPlaceInfo(warId,placeId,uid,fleetInfo,userinfo,label,attackStatus,occupyTs,binfo)
        positionInfo[placeId] =occupyInfo
    end

    -- 战斗损失的坦克数量求和
    local function troopsNumSum(troops)
        local num = 0
        if type(troops) == 'table' then
            for m,n in pairs(troops) do
                num = num + n
            end
        end
        return num
    end

    -- 初始化用户信息 -----------------------------------------------------------------
    local mAllianceWar = require "model.alliancewarnew"
    local warId = mAllianceWar.getWarId(positionId)

    local warOpenStatus = mAllianceWar.getWarOpenStatus(positionId,warId)
    if warOpenStatus ~= 0 then
        response.ret = warOpenStatus
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","techs","troops","props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    
    local duobjs
    local mDefenderUserinfo
    local mDefenderAllianceWar

    local attBuff = mUserAllianceWar.getBattleBuff()
    local defBuff = {}
    local victor = uid  -- 默认胜利者
    local attRaising = 0    -- 攻方贡献
    local defRaising = 0    -- 防守方贡献
    local attPoint = 0  -- 攻方积分
    local defPoint = 0  -- 防守方积分
    local attTankToDonate = {}  -- 攻方击毁坦克对应的贡献
    local defTankToDonate = {}  -- 防方击毁坦克对应的贡献
    local ts = getClientTs()    -- 当前时间
    local weets = getWeeTs()
    local report = {}

    -- 逻辑 -----------------------------------------------------------------

    if mUserAllianceWar.bid ~= warId then
        response.ret = -4002
        response.err = {warId,mUserAllianceWar.bid}
        return response
    end

    -- 复活中/正在其它据点
    local battleStatus,cdts = mUserAllianceWar.getNewBattleStatus() 
    if battleStatus ~= 0 then
        response.ret = battleStatus
        return response
    end

    -- TODO 对地块加锁(同时只能有一个人去占领这个地块，用户重新集结也要做这个判断)

    -- 有人在攻打这个矿
    if not mAllianceWar.placeLock(warId,placeId) then
        response.ret = -4001
        return response
    end

    local positionFleet = mAllianceWar.getPlaceInfo(warId,placeId)
    local oid = tonumber(positionFleet.oid)   -- 地块占领者    
    local defenderOccupyTs = tonumber(positionFleet.st) or ts   -- 占领者的占领时间
    local lastUpdateTs = tonumber(positionFleet.updated_at) or ts   -- 上一次更新时间(用来计算每场战斗后的积分)
    
    -- 本人已占领此地
    if oid == uid then
        mAllianceWar.placeUnlock(warId,placeId)
        response.ret = -4004
        return response
    end

    -- 我方军团占领
    if mUserinfo.alliance == positionFleet.aid then
        mAllianceWar.placeUnlock(warId,placeId)
        response.ret = -4003
        return response
    end

    -- 空据点，直接占领
    if not oid then
        -- 积分翻牌
        activity_setopt(uid,'jffp',{ac='aw'})
        occupyPosition(ts,mAllianceWar,placeId,warId,uid,nil,mUserinfo,mUserAllianceWar.rank,3,mUserAllianceWar.binfo)
    else
        duobjs = getUserObjs(oid)
        duobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","useralliancewar"})
        mDefenderUserinfo = duobjs.getModel('userinfo') 
        mDefenderAllianceWar = duobjs.getModel('useralliancewar')
        defBuff = mDefenderAllianceWar.getBattleBuff()

        local aDieTroops, dDieTroops,aSurviveTroops,dSurviveTroops,battleAttSeq,seqPoint

        local landform = allianceWarCfg.stronghold[placeId].lanform[1]
        report,aSurviveTroops,dSurviveTroops,battleAttSeq,seqPoint,aDieTroops,dDieTroops = mAllianceWar.placeBattle(mUserAllianceWar.binfo,positionFleet.binfo,positionFleet.troops,attBuff,defBuff,landform)

        report.p = {
            {mDefenderUserinfo.nickname,mDefenderUserinfo.level,0,seqPoint[2]},
            {mUserinfo.nickname,mUserinfo.level,1,seqPoint[1]},
        } 

        if battleAttSeq == 1 then
            report.p[1][3] = 1
            report.p[2][3] = 0
        end

        -- 损失的部队   
        report.lostShip = {
            attacker  = aDieTroops,
            defender = dDieTroops,
        }

        -- 双方积分
        report.warPoint = {
            attPoint = 0,
            defPoint = 0,
        }

        -- 积分计算 攻击方此次无积分
        report.warPoint.attPoint = 0
        report.warPoint.defPoint = mAllianceWar.getPointByOccupiedTime(placeId,mDefenderAllianceWar.upgradeinfo,lastUpdateTs,ts)
        
        -- 贡献计算 对方损失的坦克数，折算为自己的积分
        local attPointDonate = mAllianceWar.getDonateByOccupiedPoint(report.warPoint.attPoint)
        local defPointDonate = mAllianceWar.getDonateByOccupiedPoint(report.warPoint.defPoint)

        local attDieDonate,tmpAttTankToDonate = mAllianceWar.getDonateByTroops(report.lostShip.defender,attBuff)
        local defDieDonate,tmpDefTankToDonate = mAllianceWar.getDonateByTroops(report.lostShip.attacker,defBuff)

        attDieDonate,attTankToDonate = mAllianceWar.checkUserTroopsDonate(warId,uid,attDieDonate,tmpAttTankToDonate)
        defDieDonate,defTankToDonate = mAllianceWar.checkUserTroopsDonate(warId,oid,defDieDonate,tmpDefTankToDonate)

        attRaising = attPointDonate + attDieDonate
        defRaising = defPointDonate + defDieDonate

        mAllianceWar.addPoint(warId,mDefenderAllianceWar.rank,report.warPoint.defPoint)

        local attackerTask = {t1=1}
        local defenderTask = {t1=1}

        -- 胜利
        if report.r == 1 then
            victor = uid

            -- 积分翻牌
            activity_setopt(uid,'jffp',{ac='aw'})
            occupyPosition(ts,mAllianceWar,placeId,warId,uid,aSurviveTroops,mUserinfo,mUserAllianceWar.rank,1,mUserAllianceWar.binfo)
            
            -- 重新集结，有cd时间
            mDefenderAllianceWar.setCdTimeAt()

            -- 设置占领地块
            attackerTask.t3 = 1
            attackerTask.t4 = 1

        -- 失败了
        else
            victor = oid

            occupyPosition(defenderOccupyTs,mAllianceWar,placeId,warId,oid,dSurviveTroops,mDefenderUserinfo,mDefenderAllianceWar.rank,2,positionFleet.binfo)

            -- 重新集结，有cd时间
            mUserAllianceWar.setCdTimeAt()
            defenderTask.t5=1
            defenderTask.t6=1
        end

        attackerTask.t2 = troopsNumSum(dDieTroops)
        defenderTask.t2 = troopsNumSum(aDieTroops)

        -- 军团战任务
        mUserAllianceWar.setTask(attackerTask)
        mDefenderAllianceWar.setTask(defenderTask)

        attPoint = report.warPoint.attPoint
        defPoint = report.warPoint.defPoint

        report.w = report.r
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
        attdonate = attTankToDonate,
        defRaising = defRaising,
        defdonate = defTankToDonate,
        position = positionId,
        placeid = placeId,
    }

    local battlelog = json.encode({userbattlelog})
    local addbattlelogRet, code = M_alliance.addbattlelog({method=2,date=weets,data=battlelog})

    -- 记下Log
    mAllianceWar.writeLog({addbattlelogRet=tostring(addbattlelogRet),method=2,date=weets,data=battlelog})

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

        -- push -------------------------------------------------
        local pushCmd = 'alliancewarnew.battle.push'
        local pushData = {
            alliancewar = {
                positionInfo = mAllianceWar.formatPlacesDataForClient(positionInfo)
            }
        }

        local allUsers = mAllianceWar.getAllianceWarUsers(warId)
        if type(allUsers) == 'table' then
            for _,uid in pairs(allUsers) do
                local mid = tonumber(uid)
                if mid then
                    -- 如果是防守方，还需要推送部队信息和cd信息
                    if mid == oid then
                        local defenderPushData = copyTab(pushData)
                        defenderPushData.useralliancewar = mDefenderAllianceWar.toArray(true)
                        regSendMsg(mid,pushCmd,defenderPushData)
                    else
                        regSendMsg(mid,pushCmd,pushData)
                    end                    
                end
            end
        end
        -- push -------------------------------------------------

        response.data.alliancewar.positionInfo = mAllianceWar.formatPlacesDataForClient(positionInfo)
        response.data.useralliancewar = mUserAllianceWar.toArray(true)
        response.data.alliancewar.report = report

        response.ret = 0
        response.msg = 'Success'
    end

    mAllianceWar.placeUnlock(warId,placeId)

    return response
end
