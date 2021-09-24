-- 神秘海域战斗
function api_alienweapon_seabattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local fleetInfo = {}
    local num = 0
    local hero   =request.params.hero  
    for m,n in pairs(request.params.fleetinfo) do
        if next(n) then
            n[1] = 'a' .. n[1]
            num = num + n[2]
        end
        fleetInfo[m] = n
    end

    if num <= 0 then
        response.ret = -1
        response.msg = 'tank num is empty'
        return response
    end

    -- 攻防双方id
    local attackerId = request.uid
    local equip = request.params.equip

    local uobjs = getUserObjs(attackerId)
    uobjs.load({"userinfo", "techs", "troops", "props",})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mAweapon = uobjs.getModel('alienweapon')    
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')

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

    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end

    local report,win = mAweapon.battleSea(fleetInfo,hero,equip)    

    if not report then
        response.ret = -311
        response.msg = "battle error"
        return response
    end

    processEventsBeforeSave()
    if uobjs.save() then        
        processEventsAfterSave()
        response.data.alienweapon = {sinfo= mAweapon.sinfo}
        response.data.troops = mTroop.toArray(true)
        response.data.report = report
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response

end
