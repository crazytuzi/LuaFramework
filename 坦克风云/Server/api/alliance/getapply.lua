--获取军团战自己军团的报名信息
function api_alliance_getapply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local aid   = tonumber(request.params.aid) or 0
    local date  = getWeeTs()

    if uid == nil or  aid == 0  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local ts = getClientTs()
    local mAllianceWar = require "model.alliancewar"
    local openPosition = mAllianceWar:getOpenPosition(ts)
    local allianceWarCfg = getConfig('allianceWarCfg')
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
    local weeTs = getWeeTs()

    local execRet, code = M_alliance.getapply{uid=uid,aid=aid,date=date,endts=weeTs+ents}
    
    if not execRet then
        response.ret = code
        return response
    end
    response.ret = 0
    response.data.info = execRet.data.info
    response.data.targetState =execRet.data.targetState
    response.data.joinline_at = execRet.data.joinline_at
    response.data.startWarTime=allianceWarCfg.startWarTime
    response.data.signUpTime=allianceWarCfg.signUpTime
    response.data.openPosition=openPosition
    response.msg = 'Success'
    
    return response
   
end