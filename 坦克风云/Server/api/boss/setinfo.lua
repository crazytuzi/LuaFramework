-- 设置部队，英雄，自动攻击

function api_boss_setinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {worldboss={}},
    }
    
    local uid = request.uid
    local hero = request.params.hero
    local fleet = request.params.fleetinfo
    local auto  = request.params.auto
    local equip = request.params.equip
    local plane = request.params.plane
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('boss') == 0 then
        response.ret = -15000
        return response
    end
    local bossCfg = getConfig('bossCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
    local weet = getWeeTs()
    local ts = getClientTs()
    local gemCost=0
    local mTroop = uobjs.getModel('troops')
    local mWorldboss= uobjs.getModel('worldboss')
    local mHero  =uobjs.getModel('hero')
    local mSequip =uobjs.getModel('sequip')
    --设置英雄
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
        mWorldboss.binfo.h=hero
    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

    mWorldboss.binfo.se=mSequip.formEquip(equip) 
    mWorldboss.binfo.plane=plane
    mWorldboss.binfo.t=fleetInfo
    if type(hero)=='table' and not next(hero) then
        mWorldboss.binfo.h=nil
    end


    local fleetInfo={}
    -- 设置镜像部队
    local totalTanks = 0
    if type(fleet)=='table' and next(fleet)  then
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
        if next (fleetInfo) then
            if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
                response.ret = -5006
                return response
            end
        end
        mWorldboss.binfo.t=fleetInfo
    end
    --设置自动攻击
    if auto~=nil then
        mWorldboss.auto=auto
    end

    if uobjs.save() then
        response.data.worldboss = mWorldboss.toArray(true)
        response.ret = 0       
        response.msg = 'Success'
    end
    return response 
end