function api_alliance_mail(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0 
    local subject = request.params.subject  or tankError('subject invalid')
    local content = request.params.content or tankError('content invalid')
    local uid = request.uid

    if uid == nil or aid == 0 then
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

    local execRet, code = M_alliance.get{uid=uid,aid=aid}
    
    if not execRet then
        response.ret = code
        return response
    end

    local weeTs = getWeeTs()
        
    if (tonumber(execRet.data.alliance.groupmsg_ts) or 0) < weeTs then
        execRet.data.alliance.groupmsg_limit = 0
    end

    execRet.data.alliance.groupmsg_limit = tonumber(execRet.data.alliance.groupmsg_limit) or 0

    -- 需要验证权限，军长才能发送
    local isMail,code = M_alliance.updateSettings{uid=uid,aid=aid,groupmsg_limit=execRet.data.alliance.groupmsg_limit + 1,groupmsg_ts=getClientTs()} 
    if not isMail then
        response.ret = code
        return response
    end

    local mail
    if execRet.data.alliance.groupmsg_limit < 20 and type(execRet.data.alliance.members) == 'table' then
        for _,v in pairs(execRet.data.alliance.members) do
            if tonumber(v.uid) == uid then
                mail = MAIL:mailSent(uid,uid,2,mUserinfo.nickname,2,subject,content,3,1,-1)                
            else
                local tid =v.uid
                local tuobjs = getUserObjs(tid,true)
                local TuMailblack = tuobjs.getModel('mailblack')
                local flag=table.contains(TuMailblack.info,uid)
                if not flag then
                    MAIL:mailSent(v.uid,uid,v.uid,mUserinfo.nickname,v.name,subject,content,1,0,-1)
                end
            end
        end         
    end
    
    if mail then
        response.data.eid = mail.eid
    end

    response.ret = 0
    response.msg = 'Success'
    
    return response
end	