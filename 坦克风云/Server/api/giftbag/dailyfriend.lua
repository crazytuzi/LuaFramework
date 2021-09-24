function api_giftbag_dailyfriend(request)
    local response = {
            ret=-1,
            msg='error',
            data = {dailyfriend={}},
        }
    
    local gid = tonumber(request.params.gid)
    local uid = tonumber(request.uid)
    local fid
    
    if not gid or not uid then
        response.ret = -102
        return response
    end
    
    local http = require("socket.http")
    http.TIMEOUT= 1

    local zoneid = getZoneId()
    local postdata = {gid=gid,uid=uid,zoneid=zoneid}
    local tankExtUrl = getConfig("config.z".. zoneid ..".tankExtUrl") .. "api/friends/gift/accept?"
    
    -- http://localhost/tank-server/public/index.php/api/friends/gift/accept?zoneid=1&uid=1001&gid=13

    local respbody, code = http.request(tankExtUrl,formPostData(postdata))

    if sysDebug() then
        ptb:p(tankExtUrl .. (formPostData(postdata) or ''))
    end

    if tonumber(code) == 200 then     
        local result = json.decode(respbody)
        if type(result) ~= 'table' then
            writeLog('tankext failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'tankExtfailed')
            response.ret = -307
            return response
        end

        if tonumber(result.ret) ~= 0 then
            response.ret = tonumber(result.ret)
            return response
        end

        fid = tonumber(result.data.fid)
    else
        response.ret = -307
        return response
    end
    
    if not fid or fid == uid then
        response.ret = -2010
        return response
    end

    local fobjs = getUserObjs(fid,true)
    local fUserinfo = fobjs.getModel('userinfo')
    local fLevel = fUserinfo.level
    
    local dailyFriendRewardCfg = getConfig('friend.dailyFriendReward')

    if not dailyFriendRewardCfg[fLevel] then
        response.ret = -2010
        return response
    end

    local reward = getRewardByPool(dailyFriendRewardCfg[fLevel])

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    local ret = takeReward(uid,reward)

    if ret and uobjs.save() then
        response.data.dailyfriend.reward = formatReward(reward)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
