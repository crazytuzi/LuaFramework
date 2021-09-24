function api_alliance_editmember(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    

    -- 军团内部公告，0-100字
    local signature = request.params.signature

    -- 成员id
    local memuid = tonumber(request.params.memuid)

    local uid = request.uid

    if uid == nil or aid == 0 or (signature and utfstrlen(signature) > 200) then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local execRet, code = M_alliance.editMember{uid=uid,aid=aid,mid=memuid,signature=signature}
    
    if not execRet then
        response.ret = code
        return response
    end
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	