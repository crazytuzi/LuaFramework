-- 获取boss死亡信息

function api_achallenge_getboss(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
    local bossCfg = getConfig('alliancebossCfg')
    if mUserinfo.alliance <=0 then
        response.ret=-102
        return response
    end
    require "model.achallenge"
    local mChallenge = model_achallenge(uid)
    local boss,killcount= mChallenge.getBossInfo(bossCfg,mUserinfo.alliance)
    response.data.allianceboss=boss
    response.data.killcount=killcount
    response.ret = 0       
    response.msg = 'Success'
    return response
end