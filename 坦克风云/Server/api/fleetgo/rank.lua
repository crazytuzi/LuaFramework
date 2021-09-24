-- 排行榜
function api_fleetgo_rank(request)
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
    local weekday = tonumber(getDateByTimeZone(ts,"%w"))
    if weekday == 0 then
        weekday = 7
    end
    local weeket = weeTs - (weekday-1)*86400
    local redis =getRedis()
    local redkey ="zid."..getZoneId().."fleetgoweek"..weeket
    local data =redis:get(redkey)
    data =json.decode(data)
    local rank = {}
    if data ~= nil then
        if next(data) then
            table.sort(data, function( a,b )
                local r
                local auid = tonumber(a[1])
                local buid = tonumber(b[1])
                local ast = tonumber(a[2])
                local bst = tonumber(b[2])
                local akm = tonumber(a[3])
                local bkm = tonumber(b[3])
                if akm == bkm then
                    if ast == bst then
                        r = auid < buid
                    else
                        r = ast < bst
                    end
                else
                   r = akm > bkm
                end
                return r
            end )
            local num = 30
            for k,v in pairs(data) do
                if k > num then
                   break
                end
                local uobjs = getUserObjs(v[1])
                uobjs.load({"userinfo"})
                local mUserinfo = uobjs.getModel('userinfo')
                table.insert(v,mUserinfo.nickname)
                table.insert(rank,v)
            end
        end
    end
    response.ret = 0
    response.msg = 'Success'
    response.data.report=rank
    return response

end