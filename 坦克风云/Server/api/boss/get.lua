-- 获取boss信息

function api_boss_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    if uid == nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('boss') == 0 then
        response.ret = -15000
        return response
    end
    local bossCfg = getConfig('bossCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
     

    if mUserinfo.level < bossCfg.levelLimite then
        response.ret = -15001
        return response
    end
    local weet = getWeeTs()
    local ts = getClientTs()
    local mWorldboss = uobjs.getModel('worldboss')
    --清空数据
    if weet>mWorldboss.attack_at then
        mWorldboss.point=0
        mWorldboss.auto=0
        -- 击杀数据
        mWorldboss.info.k=nil
        mWorldboss.info.boss=nil
        mWorldboss.attack_at=weet
        mWorldboss.bookAutoAttack(0)
    end

    if weet>mWorldboss.buy_at then
        mWorldboss.info.b=nil
        mWorldboss.buy_at =weet
    end

    if uobjs.save() then
        response.data.worldboss = mWorldboss.toArray(true)
        local boss= mWorldboss.getBossInfo(bossCfg)
        response.data.worldboss.boss=boss
        response.ret = 0       
        response.msg = 'Success'
    end
    return response
end