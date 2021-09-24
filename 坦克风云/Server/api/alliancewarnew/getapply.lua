--获取军团战自己军团的报名信息
function api_alliancewarnew_getapply(request)
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

    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseralliancewar    = uobjs.getModel('useralliancewar') 
    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local ts = getClientTs()
    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60

    local execRet, code = M_alliance.getapply{uid=uid,aid=aid,date=date,endts=date+ents}
    
    if not execRet then
        response.ret = code
        return response
    end
    response.ret = 0
    response.data.info = execRet.data.info
    response.data.targetState =execRet.data.targetState
    if response.data.targetState~=nil then
        if tostring(mUseralliancewar.bid)~=tostring(response.data.info.warid) then
            mUseralliancewar.reset()
        end

        response.data.useralliancewar=mUseralliancewar.toArray(true)
    end
    response.data.oldwarid = execRet.data.warid
    response.data.join_at = execRet.data.join_at
    response.data.startWarTime=allianceWarCfg.startWarTime
    response.data.signUpTime=allianceWarCfg.signUpTime
    response.data.openDate=allianceWarCfg.openDate
    response.msg = 'Success'
    
    return response
   
end