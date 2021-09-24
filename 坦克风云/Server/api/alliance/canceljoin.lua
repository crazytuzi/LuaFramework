function api_alliance_canceljoin(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local aid = tonumber(request.params.aid) or 0 
    local uid = request.uid

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    local execRet,code = M_alliance.deny({aid=aid,uid=uid,mid=uid})

    if not execRet then
        response.ret = code
        return response
    end

    -- push -------------------------------------------------
    local admins = M_alliance.getMemberList{uid=uid,aid=aid,admin=1}
    if admins then
        local cmd = 'alliance.requestdeny'
        local data = {
            alliance={
                alliance={
                    requests = {
                        {uid=uid,}
                    }
                }
            }
        }
        
        for _,v in pairs( admins.data.members) do
            regSendMsg(v.uid,cmd,data)
        end
    end
    -- push -------------------------------------------------

    response.ret = 0
    response.msg = 'Success'   
    
    return response
end	