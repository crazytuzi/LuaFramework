-- 获取自己报名的信息

function api_areawar_getapply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local aid   = tonumber(request.params.aid) or 0

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end
    local ts = getClientTs()
    local areaWarCfg = getConfig('areaWarCfg')
    
    local weeTs = getWeeTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))

    local date=weeTs


        if weekday-areaWarCfg.prepareTime>0 then

            date=weeTs-((weekday-areaWarCfg.prepareTime)*86400)
        end

        local execRet, code = M_alliance.getapplyarea{uid=uid,aid=aid,date=date,endts=date+86400,count=areaWarCfg.signupBattleNum,bufftime=areaWarCfg.buffTime}
        
        if not execRet then
            response.ret = code
            return response
        end
        response.data.applycount = execRet.data.applycount
        response.data.info = execRet.data.info
        response.data.city = execRet.data.city
        
        response.data.targetState =execRet.data.targetState
        response.data.joinline_at = execRet.data.joinline_at
  

    response.ret = 0
    response.data.startWarTime=areaWarCfg.startWarTime
    response.data.prepareTime=areaWarCfg.prepareTime
    response.msg = 'Success'
    
    return response
   

    
end
