-- 获取报名信息
function api_areateamwar_getapply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
   
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --跨平台大战基本信息
    local mMatchinfo=mServerbattle.getserverareabattlecfg()
    if not next(mMatchinfo)  then
        return response
    end
    if mUserinfo.alliance <=0 then
        response.ret = -8023
        return response
    end
    local ts = getClientTs()
    local areaWarCfg = getConfig('areaWarCfg')
    
    local weeTs = getWeeTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local st =tonumber(mMatchinfo.st)
   
    local execRet, code = M_alliance.getapplyareawar{uid=uid,aid=mUserinfo.alliance,date=st}
        
    if not execRet then
        response.ret = code
        return response
    end
    response.data.info = execRet.data.info
    response.data.join_at = execRet.data.join_at
    response.ret = 0
    response.msg = 'Success'
    
    return response
   

end