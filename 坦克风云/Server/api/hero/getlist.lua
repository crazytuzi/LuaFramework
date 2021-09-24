-- 获取所有的英雄
function api_hero_getlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local pid = request.params.pid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","equip"})
    local mHero = uobjs.getModel('hero')
    local mEquip= uobjs.getModel('equip')
    if moduleIsEnabled('he') == 1 then
        response.data.equip={}
        response.data.equip.info=mEquip.info
    end

    -- 是否有出战英雄未释放
    if mHero.stats.a and next(mHero.stats.a) then
        local mTroop = uobjs.getModel('troops')
        local flag = false
        for k in pairs(mHero.stats.a) do
            if string.find(k, "c") == 1 then
                if not mTroop.getFleetByCron(k) then
                    mHero.releaseHero('a',k)
                    flag = true
                end
            end
        end

        if flag then
            uobjs.save()
        end
    end
   
    response.data.hero =mHero.toArray(true)
    response.ret = 0        
    response.msg = 'Success'
    return response
end