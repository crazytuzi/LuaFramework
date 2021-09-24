function api_troop_setdefense(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local fleet = request.params.fleetinfo
    local hero = request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane

    if uid == nil or type(fleet) ~= 'table' then
        response.ret = -102
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

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')  
    local mHero =  uobjs.getModel('hero')  
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    -- check hero
    if type(hero)=='table' and next(hero) then
        local len =#hero
        if len<6 then
            response.ret = -102
            response.msg = 'hero params invalid'
            return response
        end
        local hcount=0
        for k,v in pairs(hero) do
            if v~=0 then 
                local ret =mHero.checkHero(v)
                if not ret then
                    hero[k]=0
                end
            end
            if hero[k]==0 then
                hcount=hcount+1
            end
        end
        if hcount>=6 then
            hero={}
        end
    else
        mHero.releaseHero('d',1)
    end
    -- check end
    mHero.addHeroFleet('d',hero,1)

     -- check equip
    if equip then
        if not mSequip.checkFleetEquipStats(equip) then
            response.ret=-8650 
            return response        
        end
    else
        mSequip.releaseEquip('d',1)
    end   
    mSequip.addEquipFleet('d',1,equip)

    -- 添加飞机
    if plane then
        mPlane.addPlaneFleet('d',1,plane)
    else
        mPlane.releasePlane('d',1)
    end

    

    -- 设置没有防守部队 
    if totalTanks < 1 then
        mHero.releaseHero('d',1)
        mSequip.releaseEquip('d',1)
        hero=nil
    end

    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end
    
    local ret = mTroop.setDefenseFleet(fleetInfo)
    
    local mTask = uobjs.getModel('task')
    mTask.check()    

    processEventsBeforeSave()
    
    if ret and uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.data.troops = mTroop.toArray(true)
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.data.sequip={stats= mSequip.stats}
        response.data.plane={stats = mPlane.stats }
        response.msg = 'Success'
    else
        response.ret = -1
    end
    
    return response
end	