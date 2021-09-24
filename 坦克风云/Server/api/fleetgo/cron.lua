-- 定时结算
function api_fleetgo_cron(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fleetgo') == 0 then
        response.ret = -180
        return response
    end
    local ts = getClientTs()
    local weeTs = getWeeTs()
    -- 当天23:59时间戳
    local currTs = weeTs+86400-1
    local weeket = weeTs - 7*86400
    local nextweek = weeTs + 7*86400
    local redis =getRedis()
    local cachekey = "zid."..getZoneId().."fleetgocache"
    local cachekeydata = redis:get(cachekey)
    cachekeydata =json.decode(cachekeydata)
    if cachekeydata ~= nil then
        response.ret = -102
        return response
    end
    local weekday = tonumber(getDateByTimeZone(ts,"%w"))
    if weekday ~= 1 then
        response.ret = -102
        return response
    end
    redis:set(cachekey,1)
    redis:expireat(cachekey,ts+86400*2)
    -- weeket = 2000995200
    local redkey ="zid."..getZoneId().."fleetgoweek"..weeket
    local uidkey ="zid."..getZoneId().."fleetgouids"..weeTs
    local data =redis:get(redkey)
    data =json.decode(data)
    local nowuids = {}
    local olduids =redis:get(uidkey)
    olduids =json.decode(olduids)
    if data ~= nil then
        if next(data) then
            data = getsort(data)
            local num = 10
            for k,v in pairs(data) do
                if k > num then
                   break
                end
                table.insert(nowuids,v[1])
            end
            if type(olduids) == "table" then 
                for k1,v1 in pairs(olduids) do
                    if not table.contains(nowuids,v1) then
                        local uobjs = getUserObjs(v1)
                        uobjs.load({"userinfo"})
                        local mUserinfo = uobjs.getModel('userinfo')
                        mUserinfo.flags.tmptaskcur = 0
                        if not uobjs.save() then
                            response.ret = -106
                            return response
                        end
                    end
                end
            end
            for k,uid in pairs(nowuids) do
                local uobjs = getUserObjs(uid)
                uobjs.load({"userinfo"})
                local mUserinfo = uobjs.getModel('userinfo')
                if mUserinfo.flags.tmptaskcur == nil then
                    mUserinfo.flags.tmptaskcur = 0
                end
                mUserinfo.flags.tmptaskcur = mUserinfo.flags.tmptaskcur + 1
                if mUserinfo.flags.tmptaskcur > mUserinfo.flags.task.f4.cur then
                    mUserinfo.flags.task.f4.cur = mUserinfo.flags.tmptaskcur
                end
                if not uobjs.save() then
                    response.ret = -106
                    return response
                end
            end
            local nextuidkey = "zid."..getZoneId().."fleetgouids"..nextweek
            nowuids=json.encode(nowuids)
            redis:set(nextuidkey,nowuids)
            redis:expireat(nextuidkey,ts+86400*9)
        end
    else
        if type(olduids) == "table" then 
            for k1,v1 in pairs(olduids) do
                local uobjs = getUserObjs(v1)
                uobjs.load({"userinfo"})
                local mUserinfo = uobjs.getModel('userinfo')
                mUserinfo.flags.tmptaskcur = 0
                if not uobjs.save() then
                    response.ret = -106
                    return response
                end
            end
        end
    end
    response.ret = 0
    response.msg = 'Success'
    return response
end