function api_user_check(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    -- local username = request.params.username or ''
    local uid = tonumber(request.uid) or 0
    local platid = request.platid
    local logints = request.logints
    
    -- if (string.len(username) < 3 or string.len(username) > 40) and uid > 0 then
    --     response.ret = -103
    --     response.msg = 'username invalid'
    --     return response
    -- end

    local redis = getRedis()
    local key = "z"..getZoneId()..".login."..uid

    local tUid
    if uid > 0 then
        tUid = userGetUid(uid)
    -- else
    --     uid = userGetUid(username)
    end
    
    if tUid == 0 then
        local ts = getClientTs()        
        local nickname 

        for i=0,10 do
            local s1 = string.sub(ts+i,-4)
            local s2 = string.sub(uid,-6)

            local tmpName = 'pl' .. s2 .. s1
            if userGetUidByNickname(tmpName) <= 0 then
                nickname = tmpName
                break
            end 
        end

        if not nickname then
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","bag"})
            
        local mUserinfo = uobjs.getModel('userinfo')
        if type(mUserinfo.flags)~='table' then
             mUserinfo.flags={}   
        end 
        
        mUserinfo.nickname = nickname
        mUserinfo.regdate = ts
        mUserinfo.logindate = 0
        mUserinfo.pic = 1
        mUserinfo.flags.isnamed = 0
        mUserinfo.regip = tostring(request.client_ip)

        if uobjs.save() then
            response.ret = 0
            response.uid = uid
            response.msg = "Success"
        end
    end
   
    if uid > 0 and tUid == uid then
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if tonumber(mUserinfo.hwid) == 1 then
            response.ret = -133
            redis:set(key,response.ret)
            return response
        elseif type(mUserinfo.hwid) == 'table' then
            local bannedInfo = mUserinfo.hwid
            if (tonumber(bannedInfo[1]) or 0) <= getClientTs() and (tonumber(bannedInfo[2]) or 0) > getClientTs() then
                response.ret = -133
                redis:set(key,response.ret)
                response.bannedInfo = bannedInfo
                return response
            end
        end

        response.ret = 0
        response.uid = uid
        response.msg = "Success"
    end
    
    if response.uid and response.ret == 0 then
        redis:set(key,logints)    
        redis:expire(key,432000)
    end

    return response
end
