function api_user_sigup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    -- local username = request.params.username or ''
    local uid = tonumber(request.uid) or 0

    -- if string.len(username) < 3 or string.len(username) > 40 then
    --     response.ret = -102
    --     response.msg = 'username invalid'
    --     return response
    -- end
    
    local nickname = request.params.nickname or ''
    
    if string.len(nickname) < 2 or string.len(nickname) > 40 then
        response.ret = -103  
        response.msg = 'nickname invalid'
        return response
    end
    
    if match(nickname) then
        response.ret = -8024
        return response
    end

    -- local password = request.params.password or ''
    -- if (string.len(password) < 3 or string.len(password) > 40) and uid <= 0 then
    --     response.ret = -104
    --     response.msg = 'password invalid'
    --     return response
    -- end
    
    local pic = tonumber(request.params.pic) or 0

    -- if uid > 0 then
    --     uid = uid 
    -- else
    --     uid = userCreateUid()
    -- end

    if(uid>1000) and userLogin(uid) <= 0 and userGetUidByNickname(nickname) <= 0  then 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props"})
        local userinfo = uobjs.getModel('userinfo')
        local ts = getClientTs()        

        --userinfo.username = username
        -- userinfo.password = password
        userinfo.nickname = nickname
        userinfo.regdate = ts        
        userinfo.logindate = 0
        userinfo.pic = pic
        
        if uobjs.save() then            
            response.ret = 0
            response.uid = uid
            response.msg = "success"
            return response
        else
            response.ret = -106
            response.msg = "sigup error"
            return response
        end
    end
    
    return response
end
