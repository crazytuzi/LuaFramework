-- 区域站排名

function api_areawar_applyrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = tonumber(request.uid)
    local aid   = tonumber(request.params.aid) or 0
    local date  = getWeeTs()

    if uid == nil   then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('areawar') == 0 then
        response.ret = -4012
        return response
    end
    

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')


    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local ts = getClientTs()
    local date  = getWeeTs()
    local areaWarCfg = getConfig('areaWarCfg')
    local day=areaWarCfg.prepareTime
    if true then  --weekday>day
        
        date=date-(weekday-day)*86400
        local execRet,code = M_alliance.applyrankarea{uid=uid,aid=aid,date=date}
        if not execRet then
            response.ret = code
            return response
        end
        response.data.rank = execRet.data.rank
        
    end

    response.ret = 0
    response.msg = 'Success'
    
    return response



end