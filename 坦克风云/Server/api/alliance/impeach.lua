function api_alliance_impeach(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local aid = tonumber(request.params.aid) or 0    
    
    -- 成员id
    local memuid = tonumber(request.params.memuid)

    local uid = request.uid

    if uid == nil or aid == 0  then
        response.ret = -102
        return response
    end

    -- 领海战期间不能退出(踢出)军团
    local mTerritory = getModelObjs("aterritory",aid,true)
    if mTerritory.checkTimeOfWar(2) and mTerritory.checkApplyOfWar() then
        response.ret = -8429
        return response
    end

    -- 伟大航线战期间,不能操作军团(退出,解散,加入,踢出,弹劾)
    if getModelObjs("agreatroute",aid,true).allianceCanNotOperate() then
        response.ret = -8494
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local execRet, code = M_alliance.impeach{uid=uid,aid=aid,mid=memuid}
    
    if not execRet then
        response.ret = code
        return response
    end
    --记录弹劾人和被弹劾人信息以及弹劾时间
    local impeachinfo = {tkuid=request.uid,btkuid=memuid,ts=getClientTs()}   --tk弹劾 btk被弹劾
    writeLog(json.encode(impeachinfo),'impeachinfo')

    -- push -------------------------------------------------
    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    
    if mems then
        local cmd = 'alliance.memimpeach'
        local data = {
                alliance = {
                    alliance={
                        commander = execRet.data.alliance and execRet.data.alliance.commander,
                        members = {
                            {uid=memuid,role=execRet.data.user.role}
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
    local mtype=8

    local content = {type=mtype,aName=execRet.data.alliance.name,cName=mUserinfo.nickname,role=execRet.data.user.role,bName=execRet.data.user.name}
    content = json.encode(content)
    MAIL:mailSent(memuid,1,memuid,'',mUserinfo.nickname,mtype,content,1,0)
    -- mail -------------------------------------------------
    
    response.ret = 0
    response.msg = 'Success'
    
    return response


end
