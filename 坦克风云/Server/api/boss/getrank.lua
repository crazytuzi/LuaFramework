-- 获取世界boss的攻打的排行榜

function api_boss_getrank(request)
    local response = {
        ret=0,
        msg='Success',
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
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","worldboss"})
    local mWorldboss= uobjs.getModel('worldboss')
    local weet = getWeeTs()
    local list=getActiveRanking("worldboss.rank",weet)
    local ranklist={}
    if type(list)=='table' and next(list) then

        for k,v in pairs(list) do
            local mid =tonumber(v[1])
            local uobjs = getUserObjs(mid,true)
            local userinfo = uobjs.getModel('userinfo')
            table.insert(ranklist,{mid,v[2],userinfo.nickname,userinfo.alliancename})
        end

        response.data.ranklist=ranklist
        response.data.kill =mWorldboss.getUserKill()
    end

    return response
end