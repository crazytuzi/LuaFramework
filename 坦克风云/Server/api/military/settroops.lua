--  军事演习设置部队镜像  无损状态
function api_military_settroops(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }
    -- 军事演习功能关闭
    
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
    --坦克信息
    local fleet = request.params.fleetinfo or {}
    local hero  = request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane

    if uid <= 0 then
        response.ret = -102
        return response
    end

    if not  next(fleet) then
        response.ret = -10002
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
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","userarena"})    
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mUserarena = uobjs.getModel('userarena')
    local mHero =  uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    -- 兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end
    
   --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
    else
        mHero.releaseHero('m',1)
        hero={}
    end

    -- end 

    -- check equip
    if equip then
        if not mSequip.checkFleetEquipStats(equip)  then
            response.ret=-8650 
            return response
        end
    else
        mSequip.releaseEquip('m',1)   
    end
    -- 添加飞机
    if plane then
        mPlane.addPlaneFleet('m',1,plane)
    else
        mPlane.releasePlane('m',1)
    end

    mUserarena.troops=fleetInfo
    mHero.addHeroFleet('m',hero,1)
    mSequip.addEquipFleet('m',1,mSequip.formEquip(equip))
    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end