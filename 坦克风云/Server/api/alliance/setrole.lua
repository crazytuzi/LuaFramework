function api_alliance_setrole(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    
    -- 权限标识
    local role = tonumber(request.params.role)

    -- 成员id
    local memuid = tonumber(request.params.memuid)

    local uid = request.uid

    if uid == nil or aid == 0 or not role then
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

    local execRet, code = M_alliance.setRole{uid=uid,aid=aid,role=role,mid=memuid}
    
    if not execRet then
        response.ret = code
        return response
    end
    
    -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        local cmd = 'alliance.memupdate'
        local data = {
                alliance = {
                    alliance={
                        commander = execRet.data.alliance and execRet.data.alliance.commander,
                        members = {
                            {uid=memuid,role=role,}
                        }
                    }
                }
            }

        if execRet.data.admin then
            table.insert(data.alliance.alliance.members,{uid=execRet.data.admin.uid,role=execRet.data.admin.role})
        end

        for _,v in pairs( mems.data.members) do                        
            regSendMsg(v.uid,cmd,data)
        end
    end
    -- push -------------------------------------------------
    
    -- mail -------------------------------------------------
    local mtype
     if tonumber(execRet.data.role) == 0  then 
        mtype = 7 
    elseif tonumber(execRet.data.role) == 1  then 
        mtype = 6 
    elseif tonumber(execRet.data.role) == 2  then 
        mtype = 5 
    end

    local content = {type=mtype,aName=execRet.data.alliance.name,cName=mUserinfo.nickname,role=role}
    content = json.encode(content)
    MAIL:mailSent(memuid,1,memuid,'',mUserinfo.nickname,mtype,content,1,0)
    -- mail -------------------------------------------------
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end	