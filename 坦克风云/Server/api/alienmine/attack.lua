-- 攻击异星矿场
-- 分两种情况
    -- 1是占领
    -- 2是抢夺不占领
-- 需要注意功能结束时部队需要系统及时拉回家，算排行榜需要，排行榜读取时，检测一下缓存中还有没有没处理完的在外面采矿的玩家
function api_alienmine_attack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local targetid = request.params.targetid
    local isGather = request.params.isGather    -- isGather: 是否采集 0 不采集直接劫掠，1采集，
    local fleet = request.params.fleetinfo
    local hero   =request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane

    if uid == nil or type(targetid) ~= 'table' or type(fleet) ~= 'table' or isGather == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    if moduleIsEnabled('amap') == 0 then
        response.ret = -5019
        return response
    end

    local fleetInfo,totalTanks = formatAttackTanks(fleet)

    -- 总兵力为0
    if totalTanks < 1 then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mProp = uobjs.getModel('props')
    local mTroop = uobjs.getModel('troops')
    local mHero =  uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    local mMap = require "lib.alienmap"
    local ts = os.time()

    local alienMineCfg = getConfig("alienMineCfg")

    -- TODO 检测用户等级,只有等级达到要求才能进入异星矿场，让前端做检测就行了

    local weets = getWeeTs()
    local startTime = weets + alienMineCfg.startTime[1] * 3600 + alienMineCfg.startTime[2] * 60
    local endTime = weets + alienMineCfg.endTime[1]*3600 + alienMineCfg.endTime[2]*60

    if startTime > ts or endTime <= ts then
        response.ret=-5019
        return response
    end

    local alienMineBattleInfo = mTroop.getAlienMineBattleInfo()
    
    if isGather == 1 then
        if alienMineBattleInfo.dailyOccupyNum >= alienMineCfg.dailyOccupyNum then
            response.ret=-5018
            return response
        end

        alienMineBattleInfo.dailyOccupyNum = alienMineBattleInfo.dailyOccupyNum + 1
    else
        if alienMineBattleInfo.dailyRobNum >= alienMineCfg.dailyRobNum then
            response.ret=-5017
            return response
        end

        alienMineBattleInfo.dailyRobNum = alienMineBattleInfo.dailyRobNum + 1
    end

    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

    -- 检测当前拥有的队列数   
    local cfg = getConfig('player.actionFleets')
    local vipLevel = arrayGet(mUserinfo,'vip',0) + 1
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
    for k,v in pairs(fleetInfo) do
        local aid,num = v[1], arrayGet(v,2)
        if aid and mTroop.troops[aid] then 
            if not mTroop.consumeTanks(aid,num) then
                response.ret = -5006
                return response
            end
        end
    end

    local mid = getAlienMineMidByPos(targetid[1],targetid[2])
    if not commonLock(mid,"alienmaplock") then
        response.ret = -5004  
        return response
    end

    local isLandInfo = mMap:getMapById(mid)

    -- 岛的类型检测
    local isLandInfoType = tonumber(isLandInfo.type) or 0

    -- 不能攻打自己的岛
    if tonumber(isLandInfo.oid) == uid then
        if isLandInfoType ~= 6 then
            if not mTroop.getGatherFleetByAlienMineMid(mid) then
                mMap:changeAlienMapOwner(mid,0)
            end
        end

        commonUnlock(mid,"alienmaplock")
        response.ret = -5002 
        return response
    end
    
    if  isLandInfoType < 1 or isLandInfoType > 6 then
        commonUnlock(mid,"alienmaplock")
        response.ret = -5003  
        return response
    end

    -- 同盟不能互相攻击
    -- if mUserinfo.alliance > 0 and isLandInfo.alliance == mUserinfo.alliancename then
    --     response.ret = -5008
    --     return response
    -- end

    -- 岛的保护时间
    if (tonumber(isLandInfo.protect) or 0) > ts then
        commonUnlock(mid,"alienmaplock")
        response.ret = -5004  
        return response
    end
    
    local oid = tonumber(isLandInfo.oid) or 0

    -- 异星矿山没有敌人在活动，无法掠夺
    if isGather == 0 and oid <= 0 then
        commonUnlock(mid,"alienmaplock")
        response.ret = -5016 
        return response
    end

    local mapLevel = tonumber(isLandInfo.level) or 0

    local fightFleet = {}
    fightFleet.troops = fleetInfo
    fightFleet.targetid = targetid
    fightFleet.level = mapLevel
    fightFleet.type = isLandInfoType
    fightFleet.isGather = isGather
    fightFleet.alienMine = 1
    fightFleet.st = ts
    fightFleet.mid = mid
    fightFleet.dist = ts

    -- 增加出海舰队
    local cronId = 'c' .. mTroop.getAttackFleetId()
    mTroop.addAttackFleet(cronId,fightFleet)
    mHero.addHeroFleet('a',hero,cronId)
    mSequip.addEquipFleet('a', cronId, equip)
    mPlane.addPlaneFleet('a',cronId,plane)

    -- kafkaLog
    local storeTroops = mTroop.getStoreTroopsByFleet(fightFleet.troops)
    regKfkLogs(uid,'tankChange',{
            addition={
                {desc="id", value=cronId},
                {desc="异星矿场派出",value=fightFleet.troops},
                {desc="留存",value=storeTroops},
                {desc="目标",value=fightFleet.targetid}
            }
        }
    ) 

    require "model.battle"
    local mBattle = model_battle()
    local targetType = isLandInfoType
    mBattle.mMap = mMap
    mBattle.defenser = oid
    mBattle.attacker = uid
    mBattle.islandType = targetType
    mBattle.place = targetid
    mBattle.islandLevel = mapLevel
    mBattle.attackerName = mUserinfo.nickname
    mBattle.attackerLevel = mUserinfo.level
    mBattle.AttackerPlace = {mUserinfo.mapx,mUserinfo.mapy}
    mBattle.AAName = mUserinfo.alliancename
    
    -- 防守岛的兵力
    if targetType >= 1 and targetType <= 5 then
        mBattle.islandTroops = mMap:getDefenseFleet(mid)
    end

    -- 如果矿山中有人
    local duobjs,mTargetUserinfo,mTargetTroop

    if oid > 0 then
        duobjs = getUserObjs(oid)
        duobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
        mTargetUserinfo = duobjs.getModel('userinfo')
        mTargetTroop = duobjs.getModel('troops')

        mBattle.defenserName = mTargetUserinfo.nickname
        mBattle.defenserLevel = mTargetUserinfo.level
        mBattle.DAName = mTargetUserinfo.alliancename
    end

    -- 同盟不能攻击，地图有可能写同盟信息时失败
    if oid > 0 and type(mTargetUserinfo) == 'table' and (mTargetUserinfo.alliance > 0 or mUserinfo.alliance > 0) and mUserinfo.alliance == mTargetUserinfo.alliance then
        commonUnlock(mid,"alienmaplock")
        response.ret = -5008 
        return response
    end

    alienMineBattleInfo.updated_at = ts

    -- 异星矿场时间到了，玩家需要定时把数据拉回来
    if isGather == 1 and tonumber(alienMineBattleInfo.setGameCron) ~= 1 then
        local delayTs = endTime - ts + (ts%10) + 2
        local params = {cmd ="alienmine.backall",uid=uid,params={}}
        local ret = setGameCron(params,delayTs)
        alienMineBattleInfo.setGameCron=1
        if not ret then
            commonUnlock(mid,"alienmaplock")
            response.ret = -5007
            return response
        end

    end

    -- 如果矿山被抢，矿山也会刷新它的保护时间10分钟

    local winFlag,report

    -- 直接抢用户,对用户的剩余部队直接返回，资源量直接加上
    -- 如果采集，还需要再加一个采集队列
    if oid > 0 then
        mBattle.islandOwner = oid
        winFlag,report =  mBattle.robAlienMineNpcToPlayer(cronId,mid,uid,fleetInfo,oid,isGather)

        -- 没有返回，表示在岛上没有找到玩家部队
        -- 如果是掠夺，抢夺失败，此时前端应该刷新地图
        -- 如果是采集，继续攻打矿山
        if not winFlag then
            if isGather == 0 then
                commonUnlock(mid,"alienmaplock")
                response.ret = -5016 
                return response
            elseif isGather == 1 then
                oid = 0
            end
        else
            regEventAfterSave(oid,'e6',{})
            mTroop.setAllienMineBattleInfo(alienMineBattleInfo)
        end
    end

    -- 攻打矿岛,必定采集
    if oid <= 0 then
        mBattle.islandOwner = oid
        winFlag,report = mBattle.battleAlienMineNpc(uid,fleetInfo,mid,cronId,isGather)
        mTroop.setAllienMineBattleInfo(alienMineBattleInfo)
    end

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()

        if duobjs  then
            duobjs.save()
        end

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.data.report = report
        response.data.sequip={stats = mSequip.stats }
        response.data.plane={stats = mPlane.stats }
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end
    
    commonUnlock(mid,"alienmaplock")
    return response
end 