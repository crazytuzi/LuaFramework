function api_admin_getalliance(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname)     
    local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
    local aid = tonumber(request.params.aid)
    local aname = tostring(request.params.aname)
    local capabilitylist = tostring(request.params.capabilitylist)
    local count = tostring(request.params.count) or 10
    local ret = M_alliance.getalliance{aid=aid,uid=uid,aname=aname,capabilitylist=capabilitylist,count=count}

    response.data.alliance = ret

    response.ret = 0
    response.msg = 'Success'

    return response
end