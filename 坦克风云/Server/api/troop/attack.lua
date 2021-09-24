function api_troop_attack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local targetid = request.params.targetid
    local isGather = request.params.isGather
    local fleet = request.params.fleetinfo
    local isHelp = request.params.isHelp    -- 协防标识
    local hero   =request.params.hero  
    local napc   =tonumber(request.params.apc) or 0
    local rebelFlag = request.params.rebel  -- 攻击叛军标识,按值来区分是否多倍攻击
    local annealFlag = request.params.anneal -- 试炼任务标志
    local territoryFlag = request.params.territoryFlag -- 领地采集
    local seaWarFlag = request.params.seaWarFlag -- 领海战争
    local plane = request.params.plane

    if uid == nil or type(targetid) ~= 'table' or type(fleet) ~= 'table' or isGather == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    -- 是否返回道具使用信息
    local retProp = false

    local fleetInfo = {}
    local totalTanks = 0
    for m,n in pairs(fleet) do        
        if type(n) == 'table' and next(n) and n[2] > 0 then
            if n[1] then 
                n[1]= 'a' .. n[1] 
            end    
            totalTanks = totalTanks + n[2]
            fleetInfo[m] = n
        else
            fleetInfo[m] = {}
        end
    end

    -- 总兵力为0
    if totalTanks < 1 then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)    
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","userexpedition","jobs"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mProp = uobjs.getModel('props')
    local mTroop = uobjs.getModel('troops')
    local mHero =  uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')
    local mMap = require "lib.map"
    local ts = getClientTs()
    local mJob =uobjs.getModel('jobs')
    local mUserRebel,mRebel,rebelInfo

    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
    end

    local equip = request.params.equip
    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

    -- end 
	if not rebelFlag and not seaWarFlag then
        --使用能量
        if not mUserinfo.useEnergy(1) then
            response.ret = -2001        
            return response
        end
    end

    local cfg = getConfig('player.actionFleets')
    local vipLevel = arrayGet(mUserinfo,'vip',0) + 1

    -- 检测当前拥有的队列数            
    local actionFleets = cfg[vipLevel] or 1
    if mTroop.getFleetNums() >= actionFleets then 
        response.ret = -5005
        return response
    end

    -- 兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
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

    local mid = getMidByPos(targetid[1],targetid[2])
    local isLandInfo = mMap:getMapById(mid)

    -- 岛的类型检测
    local isLandInfoType = tonumber(isLandInfo.type) or 0

    -- 攻击叛军必需有攻击标识
    if isLandInfoType == 7 and not rebelFlag then
        response.ret = -102
        return response
    end

    -- 试炼任务必需有攻击标识
    if isLandInfoType == 8 and not annealFlag then
        response.ret = -102
        return response
    end

    -- 不能攻打自己的岛
    if tonumber(isLandInfo.oid) == mTroop.uid then
        if isLandInfoType ~= 6 then
            if not mTroop.getGatherFleetByMid(mid) then
                mMap:format(mid) 
            end
        end

        response.ret = -5002 
        return response
    end
    
    -- 不能攻击空地
    if isLandInfoType == 0 then
        response.ret = -5003  
        return response
    end

    -- 只能协防主基地
    if isHelp == 1 and isLandInfoType ~= 6 then
        response.ret = -5010  
        return response
    end

    if isLandInfoType == 9 and not territoryFlag and not seaWarFlag then
        response.ret = -5003
        return response
    end

    -- 同盟不能互相攻击
    if isHelp ~= 1 and mUserinfo.alliance > 0 and isLandInfo.alliance == mUserinfo.alliancename then
        if isLandInfoType ~= 9 then
            response.ret = -5008
            return response
        end
    end

    -- 矿点升级需要计算一下矿点最新等级
    local omaplevel=tonumber(isLandInfo.level)
    local mapexp = tonumber(isLandInfo.exp) or 0
    local maplevel=mMap:getMapLevel(omaplevel,mapexp,mid)
    -- 攻击叛军检测
    if rebelFlag then
        mRebel = loadModel("model.rebelforces")
        rebelInfo = mRebel.getRebelInfo(mid)
        mUserRebel = uobjs.getModel('userforces')

        -- 叛军已被击杀
        if rebelInfo.isDie then
            response.ret = -5003  
            return response
        end

        -- 扣除能量
        local rebelAttackCfg = mRebel.getAttackCfg(rebelFlag)
        if not mUserRebel.useEnergy(rebelAttackCfg.attackConsume) then
            response.ret = -2001        
            return response
        end

        if isLandInfoType ~= 7 then
            response.ret = -102
            return response
        end
    elseif annealFlag then -- 新增试炼任务检测
        local mAnneal = loadModel("model.heroanneal", {uid=isLandInfo.data.oid})
        annealInfo = mAnneal.getAnnealInfo(mid)

        if annealInfo.isDie then
            response.ret = -5003
            return response
        end
        if isLandInfoType ~= 8 then
            response.ret = -102
            return response
        end
    elseif territoryFlag then
        -- 只能攻击领地
        if isLandInfoType ~= 9 then
            response.ret = -5003  
            return response 
        end

        -- 不是我方军团领地，不能操作(攻击)
        if mUserinfo.alliance <= 0 then
            response.ret = -8406
            response.err = "userinfo.alliance is 0"
            return response
        end

        -- 不是我方军团领地
        if tonumber(isLandInfo.oid) ~= mUserinfo.alliance then
            response.ret = -8406
            response.err = {isLandInfo.oid,mUserinfo.alliance}
            return response
        end

        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        -- 还未创建军团领地,不能操作
        if not mTerritory.isNormal() then
            response.ret = -8406
            response.err = "territory is empty"
            return response
        end

        -- 不是资源矿,不能出发采集
        if not mTerritory.isResourceIsland(isLandInfo.name) then
            response.ret = -8407
            return response
        end

        -- 维护期内不让攻击
        if mTerritory.isLockCollectTime() then
            response.ret = -8411
            return response
        end

        -- 采集次数判断
        if mUserinfo.alliance>0 then
            local mAtmember = uobjs.getModel('atmember')
            if not mAtmember.canCollect() then
                response.ret = -8410
                return response
            end
        end
    elseif seaWarFlag then
        -- 只能攻击领地
        if isLandInfoType ~= 9 then
            response.ret = -5003  
            return response 
        end

        if mTroop.checkSeaWarFleetCount() >= getConfig('allianceDomainWar').queueLimit then
            response.ret = -5005
            return response
        end

        -- 攻击
        if seaWarFlag == 1 then
            -- 我方军团领地,不能操作(攻击)
            if mUserinfo.alliance <= 0 or tonumber(isLandInfo.oid) == mUserinfo.alliance then
                response.ret = -8406
                response.err = {isLandInfo.oid,mUserinfo.alliance}
                return response
            end

        -- 驻防
        elseif seaWarFlag == 2 then
            -- 不是我方军团领地,不能驻防
            if mUserinfo.alliance <= 0 or tonumber(isLandInfo.oid) ~= mUserinfo.alliance then
                response.ret = -8406
                response.err = {isLandInfo.oid,mUserinfo.alliance}
                return response
            end
        end

        local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,true)

        -- 还未创建军团领地,不能操作
        if not mTerritory.isNormal() then
            response.ret = -8406
            response.err = "territory is empty"
            return response
        end

        -- 非战争领地,不能攻击
        if not mTerritory.checkIslandOfWar(isLandInfo.name) then
            response.ret = -8424
            response.err = isLandInfo.name
            return response
        end

        -- 非战争期,不能攻击
        if not mTerritory.checkTimeOfWar(seaWarFlag) then
            response.ret = -8425
            response.err = os.time()
            return response
        end

        local mTargetTerritory = getModelObjs("aterritory",tonumber(isLandInfo.oid),true)

        -- 领地等级太低不能攻击
        if not mTerritory.checkLevelOfWar() or not mTargetTerritory.checkLevelOfWar() then
            response.ret = -8426
            return response
        end

        -- 我方已经被击败
        if not mTerritory.checkStatusOfWar() then
            response.ret = -8438
            return response
        end
        
        -- 敌方军团已经被击败
        if not mTargetTerritory.checkStatusOfWar() then
            response.ret = -8439
            return response
        end

        -- 未报名
        if not mTerritory.checkApplyOfWar() or not mTargetTerritory.checkApplyOfWar() then
            response.ret = -8432
            return response
        end

        -- 攻击的建筑已经被损毁
        local battleGround = loadModel("lib.seawar").getBattleGround(tonumber(isLandInfo.oid),isLandInfo.name)
        if battleGround.isDestroyed then
            response.ret = -8435
            return response
        end

        maplevel = mTargetTerritory.getLevel(isLandInfo.name)

        isGather = 0
    end

    local fightFleet = {}
    fightFleet.troops = fleetInfo
    fightFleet.targetid = targetid
    fightFleet.level = maplevel
    fightFleet.type = isLandInfoType
    fightFleet.isGather = isGather or false
    fightFleet.isHelp = isHelp
    fightFleet.st = ts
    fightFleet.mid = mid
    fightFleet.rebelMulti = rebelFlag

    if rebelInfo then
        fightFleet.rebelForce = rebelInfo.force
    end

    -- 领地需要加上小类型
    if territoryFlag then
        fightFleet.mType = isLandInfo.name
    end

    -- 科技 急速行军
    -- vip 加成
    local vip = mUserinfo.vip
    local player =getConfig('player') 
    local addition=(player.marchSpeed[vip+1])  or 0
    local techLevel = mTech.getTechLevel('t22')
    
    local asaddition = 0
    if isHelp == 1 and  mUserinfo.alliance > 0  then 
        local allAllianceSkills = M_alliance.getAllianceSkills{aid=mUserinfo.alliance}
        if type(allAllianceSkills) == 'table' then
            if allAllianceSkills.s15~=nil and allAllianceSkills.s15>0 then
                allianceSkillCfg = getConfig("allianceSkillCfg.s15")
                if allianceSkillCfg.batterValue[allAllianceSkills.s15] then
                    asaddition=allianceSkillCfg.batterValue[allAllianceSkills.s15]/100
                end
            end
        end
    end
     -- 3 是行军速度减少时间
    local jobvalue =mJob.getjobaddvalue(3) -- 区域站减少时间
    
    -- 战争雕像减少行军时间
    jobvalue = jobvalue + (uobjs.getModel('statue').getSkillValue('moveSpeed') or 0)

    -- 远洋征战
    local oceanExpBuff = mUserinfo.getOceanExpeditionBuff("moveSpeed")
    
    local timeConsume = marchTimeConsume({mUserinfo.mapx,mUserinfo.mapy},targetid,techLevel,addition,asaddition,jobvalue,oceanExpBuff)
    
    -- 道具 13号道具 急速行军
    -- local propSlotKey = mProp.pidIsInUse('p13')
    -- if propSlotKey then
    --     if mProp.info[propSlotKey].et > ts then
    --         timeConsume = math.ceil(timeConsume * 0.5)
    --     end
    -- end
    local propCfg = getConfig('prop')
    for k,v in pairs(mProp.info or {}) do 
        if v.et > ts and propCfg[v.id] and propCfg[v.id].useGetCrop and propCfg[v.id].useGetCrop.sailingTime then
            timeConsume = math.ceil(timeConsume * propCfg[v.id].useGetCrop.sailingTime)
            break
        end
    end

    -- 全民劳动
    local laborRate = activity_setopt(uid,'laborday',{act='upRate',n=4})
    if laborRate then
        timeConsume =math.ceil(timeConsume/(1+laborRate))
    end

    -- 到达时间
    fightFleet.dist = ts + timeConsume
    local delay_time = timeConsume - 2
    if delay_time < 0 then
        response.ret = -5007
        return response
    end

    local oid = tonumber(isLandInfo.oid) or 0
    local cronId

    -- 领海战换个接口
    if seaWarFlag then
        cronId = 'c'.. mTroop.getAttackFleetId()
        local cronParams = {
            cmd = "territory.seawar.attack",
            uid=uid,
            params = {
                cronId=cronId,
                target = targetid,
                attacker=uid,
            }
        }

        local ret,workId = setGameCron(cronParams,delay_time)
        if not ret then
            cronId = nil
        end

        fightFleet.seaWarFlag = seaWarFlag
        fightFleet.workId = workId
        -- 目标拥有者ID(军团id)
        fightFleet.oid = oid
        -- 领地类型
        fightFleet.mType = isLandInfo.name
        -- 目标军团名
        fightFleet.tAname = isLandInfo.alliance

        if seaWarFlag == 1 then
            loadModel("lib.seawar").addAlert(oid,isLandInfo.name,cronId,mUserinfo.alliancename,mUserinfo.nickname)

            -- 打领地,出发的时候直接保护罩就没了
            mUserinfo.clearProtect()
        end
    else
        cronId = mTroop.setGameCron(mTroop.uid,targetid,delay_time )
    end

    if not cronId then
        response.ret = -5007
        return response
    end
        
    if fightFleet.type == 6 or (oid > 0 and isLandInfoType ~= 9) then
        -- 敌军来袭
        local targetUobjs = getUserObjs(oid)
        local targetInfo = targetUobjs.getModel('userinfo')
        local targetTroop = targetUobjs.getModel('troops')
        local targetProp = targetUobjs.getModel('props')

        if isHelp == 1 then
            -- 不是同盟不能协防            
            if targetInfo.alliance <= 0 or mUserinfo.alliance <= 0 or targetInfo.alliance ~= mUserinfo.alliance then
                response.ret = -5009
                return response
            end

            if type(targetTroop.helpdefense) ~= 'table' then
                targetTroop.helpdefense = {list={}}
            end 

            if type(targetTroop.helpdefense.list) ~= 'table' then
                targetTroop.helpdefense.list = {}
            end 
            local mUserExpedition = uobjs.getModel('userexpedition')
            local helpinfo = {
                uid = uid,
                aid = mUserinfo.alliance,
                name = mUserinfo.nickname,
                ts = fightFleet.dist,
                power=mUserExpedition.refreshExpFighting(uid,fleetInfo,hero,equip),
                status = 0,
            }
            targetTroop.helpdefense.list[cronId] = helpinfo
            fightFleet.tName = targetInfo.nickname
            fightFleet.tUid = oid

            local waitNums,listNums = 0,0
            for _,v in pairs(targetTroop.helpdefense.list) do
                listNums = listNums + 1
                if v.status ~= 0 then waitNums = waitNums + 1 end
            end

            local maxListNums = 5

            if waitNums >= maxListNums then
                response.ret = -5011
                return response
            end
            
            local tmp = {}
            for k,v in pairs(targetTroop.helpdefense.list) do
                if v.status == 0 then table.insert (tmp,{k,v.ts}) end
            end

            table.sort( tmp, function(a,b)return (a[2] > b[2]) end )
            for k,v in pairs(tmp) do
                if listNums > maxListNums then
                    if  targetTroop.helpdefense.list[v[1]] then targetTroop.helpdefense.list[v[1]] = nil end
                    listNums = listNums - 1
                end
            end

            for i=1,2 do                            
                if targetUobjs.save() then 
                    targetTroop.sendHelpDefenseMsgByUid()
                    break 
                end                
            end
            --日常任务
            local mDailyTask = uobjs.getModel('dailytask')
           --新的日常任务检测
            mDailyTask.changeNewTaskNum('s303',1)
            -- 奔赴前线,协防
            activity_setopt(uid,'benfuqianxian',{tasks={t3=1}})
        else
            if (targetInfo.alliance > 0 or mUserinfo.alliance > 0) and targetUobjs.alliance == mUserinfo.alliance then
                response.ret = -5008
                return response
            end

            -- 有保护罩时还要判断是否在领海战期间,能击飞
            if isLandInfoType == 6 and (tonumber(targetInfo.protect) > ts or targetProp.pidIsInUse("p14")) then
                if not ( switchIsEnabled('baseFly') and loadModel("lib.seawar").checkBaseFly(targetid[1],targetid[2],targetInfo.alliance,targetInfo.level) ) then
                    response.ret = -5004
                    return response
                end
            end
            
            local invalidNums = table.length(targetTroop.invade)
            local maxInvalidNums = 10
            if invalidNums >= maxInvalidNums then
                local tmp = {}
                for k,v in pairs(targetTroop.invade) do
                    table.insert (tmp,{k,v.ts})
                end

                table.sort( tmp, function(a,b)return (a[2] > b[2]) end )

                for i=1,invalidNums - (maxInvalidNums -1) do
                  if tmp[i] and tmp[i][1] then
                      targetTroop.invade[tmp[i][1]] = nil
                  end
                end
            end

            for i=1,2 do            
                local invadeInfo = {
                    attackerName=mUserinfo.nickname,
                    place=targetid,
                    islandType=isLandInfo.type,
                    level=isLandInfo.level,
                    ts=fightFleet.dist,
                    tc=timeConsume,
                    tarplace={mUserinfo.mapx,mUserinfo.mapy}
                }
                targetTroop.invade[cronId] = invadeInfo
                targetInfo.flags.event.f = 1
                fightFleet.tName = targetInfo.nickname
                fightFleet.tUid = oid 

                if targetUobjs.save() then 
                    -- local response = {data={},cmd="msg.event"}
                    -- response.data.event = targetInfo.flags.event
                    -- sendMsgByUid(oid,json.encode(response))

                    local cronParams = {cmd ="troop.msgpush.invade",params={uid=oid,event=targetInfo.flags.event}}
                    setGameCron(cronParams,5)
                    break 
                end
                targetUobjs.reset()
            end

            if fightFleet.type == 6 then
                -- 解除保护时间
                local protectTime = mUserinfo.protect or 0         
                if protectTime > ts then
                    mMap:resetProtectTime(mTroop.uid)
                    mProp.clearUsePropCd('p14')
                    retProp = true
                end
            end
        end        
    end

    -- 增加出海舰队
    mTroop.addAttackFleet(cronId,fightFleet)
    mHero.addHeroFleet('a',hero,cronId)
    mSequip.addEquipFleet('a',cronId,equip)
    mPlane.addPlaneFleet('a',cronId,plane)
    local mTask = uobjs.getModel('task')
    mTask.check()    

    -- kafkaLog
    local storeTroops = mTroop.getStoreTroopsByFleet(fightFleet.troops)
    local kfkalog = {
        {desc="id", value=cronId},
        {desc="野外派出",value=fightFleet.troops},
        {desc="留存",value=storeTroops},
        {desc="目标",value=fightFleet.targetid}
    }

    if isLandInfoType==9 and territoryFlag then
        table.insert(kfkalog,{desc="目标类型",value='军团海域资源'})
    end

    local goldMineMap = mMap:getGoldMine()
    if goldMineMap[tostring(mid)] then
        table.insert(kfkalog,{desc="目标类型",value='金矿'})
    end

    regKfkLogs(uid,'tankChange',{
            addition=kfkalog
        }
    ) 

    processEventsBeforeSave()

    if uobjs.save() then

        ---  军团活跃
        if isHelp == 1 then
            local date  = getWeeTs()
            local ts    = getClientTs()
            local weeTs = getWeeTs()
            local allianceActive = getConfig("alliance.allianceActive")
            local allianceActivePoint = getConfig("alliance.allianceActivePoint")
            local apoint =allianceActivePoint[4]
            local apointcount =allianceActive[4]
            local senddata={uid=uid,
            aid=mUserinfo.alliance,
            weet=weeTs,ts=ts,
            ap=apoint,
            apc=apointcount
            }
            if napc<=apointcount then
              local execRet,code = M_alliance.setDefance(senddata)
            end

        end
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.data.sequip={stats = mSequip.stats }
        response.data.plane={stats = mPlane.stats }
        if retProp then
            response.data.props = mProp.toArray(true)
        end
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end
    
    return response
end	