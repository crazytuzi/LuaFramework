function api_alliance_accept(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local memuid = request.params.memuid
    local aid = tonumber(request.params.aid) or 0

    if uid == nil or memuid == nil or aid == 0 then
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

    local acceptRet,code = M_alliance.acceptJoin({aid=aid,uid=uid,mid=memuid})

    if not acceptRet then
        response.ret = code
        return response
    end
     
    -- 被批准的成员处理数据 --------------------
    -- 绑定用户的alliance alliancename
    -- 刷新战力
    -- 刷新地图
    local muobjs = getUserObjs(memuid)    
    muobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
    local memUserinfo = muobjs.getModel('userinfo')

    memUserinfo.alliance = aid
    memUserinfo.alliancename = acceptRet.data.alliance.name
    
    -- 成员被批准，刷新战力
    regEventBeforeSave(memuid,'e1')

    -- 资金招募活动
    activity_setopt(memuid,'fundsRecruit',{type=-1, name='accept'})
    processEventsBeforeSave()

    local mTerritory = getModelObjs("aterritory",aid,true)
    if mTerritory.isNormal() then
        local mAtmember = uobjs.getModel('atmember')
        if aid ~= mAtmember.aid then
            writeLog('玩家军团改变了aid='..aid..'uid='..memuid..'领地数据aid='..mAtmember.aid,'territory')
            mAtmember.resetMember()
            mAtmember.aid = aid
        end
    end   

    -- 海域航线
    activity_setopt(memuid,'hyhx',{act='join',aid=aid})   

    -- 番茄大作战
    activity_setopt(memuid,'fqdzz',{act='join',aid=aid})    
    -- 节日花朵
    activity_setopt(memuid,'jrhd',{act='join',id=aid})  

    if muobjs.save() then
        processEventsAfterSave()

        if memUserinfo.mapx ~= -1 and memUserinfo.mapy ~= -1 then
            -- 更新地图中的联盟字段
            local mMap = require "lib.map"
            local mid = getMidByPos(memUserinfo.mapx,memUserinfo.mapy)
            mMap:update(mid,{alliance=acceptRet.data.alliance.name})
        end

        -- 前台推送数据（前台全服广播更新地图）
        response.data.cPlace = {memUserinfo.mapx,memUserinfo.mapy,memuid}

        -- 成员邮件
        local content = {type=3,aName=acceptRet.data.alliance.name}
        content = json.encode(content)
        MAIL:mailSent(memuid,1,memuid,'',memUserinfo.nickname,3,content,1,0)

        -- push -------------------------------------------------
        local members = M_alliance.getMemberList{uid=uid,aid=aid,}
        if members then
            local cmd = 'alliance.memadd'
            local data = {
                alliance = {
                    alliance={
                        members = {
                            {
                                uid=memuid,
                                level=memUserinfo.level,
                                name=memUserinfo.nickname,
                                fight=memUserinfo.fc,
                                role=acceptRet.data.member.role,
                                raising=acceptRet.data.member.raising,
                                signature=acceptRet.data.member.signature,
                                logined_at=acceptRet.data.member.logined_at,
                            }
                        }
                    }
                }
            }

            -- 领地信息推送给被批准的成员
            local mTerritory = getModelObjs("aterritory",aid,true)
            local territoryPos
            if not mTerritory.isEmpty() then
                territoryPos = mTerritory.getPos()
            end

            for _,v in pairs( members.data.members) do
                if tonumber(v.uid) == memuid and territoryPos then
                    local p = copyTable(data)
                    p.alliance.alliance.mTerritory = territoryPos
                    regSendMsg(v.uid,cmd,p)
                else
                    regSendMsg(v.uid,cmd,data)
                end
            end
        end
    end
    -- push -------------------------------------------------

    response.ret = 0
    response.msg = 'Success'
    return response
end	