function api_alliance_deny(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 军团Id
    local aid = tonumber(request.params.aid) or 0
    local memuid = tonumber(request.params.memuid) or 0
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

    local execRet,code = M_alliance.deny{mid=memuid,uid=uid,aid=aid}

    if not execRet then
        response.ret = code
        return response
    end
    
    local requestdeny = {}

    -- 如果此人已经加入军团了，不飘板，不提示
    -- 否则需要提示此人（全部拒绝要挨个提示）
    -- 提供一个列表给php，返回所有人的军团信息
    -- 邮件的title可以是一个代号，前台自己去读配置
    if type(execRet.data.deny) == 'table' and type(execRet.data.alliance) == 'table' then
        for _,denyinfo in pairs(execRet.data.deny) do
            local content = {type=2,aName=execRet.data.alliance.name}
            content = json.encode(content)
            MAIL:mailSent(denyinfo[1],1,denyinfo[1],'',denyinfo[2],2,content,1,0)
            
            table.insert(requestdeny,{uid=denyinfo[1]})
        end
    end
        
    -- push -------------------------------------------------
    if #requestdeny > 0 then
        local admins = M_alliance.getMemberList{uid=uid,aid=aid,admin=1}
        local cmd = 'alliance.requestdeny'
        local data = {
            alliance = {
                alliance={
                    aid=aid,
                    requests = requestdeny,
                }
            }
        }

        if admins then            
            for _,v in pairs( admins.data.members) do
                regSendMsg(v.uid,cmd,data)
            end
        end

        for _,v in pairs(requestdeny) do
            regSendMsg(v.uid,cmd,data)
        end
    end
    -- push -------------------------------------------------

    response.ret = 0
    response.msg = 'Success'

    return response
end 