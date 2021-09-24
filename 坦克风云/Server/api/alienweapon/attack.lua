-- 贸易护航，舰队派出挂机，不攻击目标
function api_alienweapon_attack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local fleet = request.params.fleetinfo
    local hero   =request.params.hero  
    local slot = request.params.id -- 任务索引
    local useGems = request.params.gems -- 钻石购买队列
    local plane = request.params.plane
    if uid == nil or type(fleet) ~= 'table' or slot == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

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
    uobjs.load({"userinfo", "techs", "troops","hero","props"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero =  uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mAweapon = uobjs.getModel('alienweapon')
    local mPlane = uobjs.getModel('plane')

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

    -- 护航次数
    if not mAweapon.incrAttacknum() then
        response.ret = -12011
        return response
    end

    -- 该槽位已经有任务
    if not mAweapon.checkSlot(slot) then
        response.ret = -12012
        return response
    end

    -- 租用队列
    local gemCost = mAweapon.getCurrSlotFee()
    if gemCost > 0 and not useGems then
        response.ret = -109
        return response
    end 
    if gemCost > 0 and not mUserinfo.useGem(gemCost) then
        response.ret = -109
        return response
    end

    local cfg = getConfig("alienWeaponTradingCfg")
    local ts = getClientTs()
    local weeTs = getWeeTs()

    local timeIdx = rand(1, #cfg.tradTime)
    local tardeTime = cfg.tradTime[timeIdx]
    -- 护航舰队信息
    mAweapon.trade[slot].orgtroops = fleetInfo -- 总舰队
    mAweapon.trade[slot].troops = fleetInfo -- 当前舰队信息
    mAweapon.trade[slot].st = ts --开始时间
    mAweapon.trade[slot].et = ts + tardeTime --结束时间 
    mAweapon.trade[slot].rate = 1 -- 倍率
    -- mAweapon.trade[slot].r = nil --奖励
    -- mAweapon.trade[slot].cr = nil -- 客户端奖励
    mAweapon.trade[slot].rob = 0 -- 被抢了 ？

    -- 倍率
    local doubleTime = {cfg.doubleTime[1] + weeTs, cfg.doubleTime[2] + weeTs}
    if doubleTime[1] <= ts and ts <= doubleTime[2] then
        mAweapon.trade[slot].rate = cfg.rewardRate

        local reward = mAweapon.trade[slot].r
        -- 奖励
        for k, v in pairs(reward) do --奖励倍率
            reward[k] = math.floor(v * mAweapon.trade[slot].rate)
        end
        mAweapon.trade[slot].r = reward
        mAweapon.trade[slot].cr = formatReward(reward)

    end

    -- 派出武器和将领
    local cronId = 'aweapon' .. slot
    mHero.addHeroFleet('a',hero,cronId)
    mSequip.addEquipFleet('a',cronId,equip)
    mAweapon.updateRobInfo(slot, false)
    mPlane.addPlaneFleet('a',cronId,plane)

    local cronParams = {cmd ="alienweapon.back", params={uid=uid,slot=slot}}
    if not setGameCron(cronParams, tardeTime) then
        setGameCron(cronParams, tardeTime) 
    end 

    -- kafkaLog
    local storeTroops = mTroop.getStoreTroopsByFleet(mAweapon.trade[slot].troops)
    regKfkLogs(uid,'tankChange',{
            addition={
                {desc="id", value=cronId},
                {desc="护航派出",value=mAweapon.trade[slot].troops},
                {desc="留存",value=storeTroops},
                {desc="目标",value=mAweapon.trade[slot].tid}
            }
        }
    ) 
    
    -- 岁末回馈
    activity_setopt(uid,'feedback',{act='hh',num=1})

    if gemCost > 0 then
        regActionLogs(uid,1,{action=160,item="tradeattack",value=gemCost,params={}})
    end

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.data.alienweapon = mAweapon.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.hero={stats=mHero.stats}
        response.data.sequip={stats = mSequip.stats }
        response.data.plane={stats = mPlane.stats }

        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end
    
    return response
end	