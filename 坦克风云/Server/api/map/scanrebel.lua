function api_map_scanrebel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = request.uid or 0
    if uid == 0 then
        response.ret = -104
        response.msg = 'uid invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    local sql = string.format("select id, x, y from map where oid = 0 and type = 7 and protect > '%s' ", getClientTs())
    local db = getDbo()
    local result = db:getAllRows(sql)
    local redis = getRedis()
    local weeTs = getWeeTs()

    local target = nil
    if result then
        local rebels = {}  
        for k, v in pairs( result ) do
            local dist = (mUserinfo.mapx - v.x)^2 + (mUserinfo.mapy - v.y)^2
            table.insert(rebels, {dist, v.x, v.y})
        end

        if not next(rebels) then
            response.ret = -8632
            return response            
        end

        table.sort(rebels, function(a, b)
            return a[1] > b[1]
        end)

        local key = getZoneId() .. ".scanrebel." .. uid .. "." .. weeTs
        local cnt = (redis:get(key) or 0) + 1

        -- 消耗军团贡献
        local rasingCfg = getConfig('player.scanrebel')
        local use_rais = rasingCfg[cnt] or rasingCfg[#rasingCfg]

        local acceptRet, code = M_alliance.useRaising({uid=uid, use_rais=use_rais})
        if not acceptRet then
            response.ret = code
            return response
        end

        local idx = (cnt - 1) % (#rebels) + 1

        target = { x=rebels[idx][2], y=rebels[idx][3] }
        
        redis:set(key, cnt)
        redis:expireat(key, weeTs + 86400)
    end

    if true then
        response.ret = 0
        response.data.near = target
        response.msg = "success"
    end
    
    return response
end
