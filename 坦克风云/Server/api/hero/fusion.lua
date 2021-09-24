--  合成英雄
--  用英雄碎片
function api_hero_fusion(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')

    if type (mHero.hero[hid]) =='table' then
        response.ret=-11001
        return response
    end
    
    local heroCfg = getConfig('heroListCfg.'..hid)
    local fusion = heroCfg.fusion.soul
    local p=heroCfg.fusion.p
    
    if next(fusion) then
        if not mHero.usemoresoul(fusion) then
            response.ret=-11005
            return response
        end
    else
        response.ret=-11005
        return response
    end


    local ret= mHero.addhero(hid,p)
    regActionLogs(uid,9,{action=902,item=hid,value=p,params=fusion})  
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() and ret then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'


    end
    return response
end