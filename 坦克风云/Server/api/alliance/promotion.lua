function api_alliance_promotion(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    
    -- 权限标识
    local role = tonumber(request.params.role)

    local uid = request.uid

    if uid == nil or aid == 0 or role~=1 then
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

    local execRet, code = M_alliance.promotion{uid=uid,aid=aid,role=role}
    
    if not execRet then
        response.ret = code
        return response
    end
    
    -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        local cmd = 'alliance.mempromotion'
        local data = {
                alliance = {
                    alliance={
                        commander = execRet.data.alliance and execRet.data.alliance.commander,
                        members = {
                            
                        }
                    }
                }
            }

        if execRet.data.admin then
            table.insert(data.alliance.alliance.members,{uid=execRet.data.admin.uid,role=execRet.data.admin.role,use_rais=execRet.data.admin.use_rais,raising=execRet.data.admin.raising})
        end

        for _,v in pairs( mems.data.members) do                        
            regSendMsg(v.uid,cmd,data)
        end
    end
    -- push -------------------------------------------------
    
    
    response.ret = 0
    response.msg = 'Success'
    
    return response
end 