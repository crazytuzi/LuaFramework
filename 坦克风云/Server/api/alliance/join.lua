function api_alliance_join(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 申请的军团Id
    local aid = tonumber(request.params.aid) or 0

    local uid = request.uid 

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    -- 已经入过盟了
    if mUserinfo.alliance > 0 then
        response.ret = -8001
        return response
    end

    -- -8437 领海战期间不能加入(申请)军团
    local mTerritory = getModelObjs("aterritory",aid,true)
    if mTerritory.checkTimeOfWar(2) and mTerritory.checkApplyOfWar() then
        response.ret = -8437
        return response
    end

    -- 伟大航线战期间,不能操作军团(退出,解散,加入,踢出,弹劾)
    if getModelObjs("agreatroute",aid,true).allianceCanNotOperate() then
        response.ret = -8494
        return response
    end

    if moduleIsEnabled('joqa')==1 then
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        local jqstatus = mServerbattle.joinorquit(2)
        if jqstatus~=0 then
            response.ret = jqstatus
            return response
        end
    end

    local joinRet,code = M_alliance.join({uid=uid,username=mUserinfo.nickname,level=mUserinfo.level,fight=mUserinfo.fc,aid=aid})

    if not joinRet then
        response.ret = code
        return response
    end

    -- 是否直接加入公会，以data中是否有user字段来判断
    -- 如果直接加入功会，刷新战力，绑定用户的公会信息，并刷新地图
    if joinRet.data and joinRet.data.user then
        regEventBeforeSave(uid,'e1')
        mUserinfo.alliance = aid
        mUserinfo.alliancename = joinRet.data.alliance.name

        -- 领地信息返给客户端
        local mTerritory = getModelObjs("aterritory",aid,true)
        if not mTerritory.isEmpty() then
            response.data.territory = mTerritory.getPos()
        end

        if mTerritory.isNormal() then
            local mAtmember = uobjs.getModel('atmember')
            if aid ~= mAtmember.aid then
                writeLog('玩家军团改变了aid='..aid..'uid='..mUserinfo.uid..'领地数据aid='..mAtmember.aid,'territory')
                mAtmember.resetMember()
                mAtmember.aid = aid
            end
        end  

        -- 资金招募活动
        activity_setopt(uid,'fundsRecruit',{type=-1, name='join'})
        -- 海域航线
        activity_setopt(uid,'hyhx',{act='join',aid=aid})  
        -- 番茄大作战
        activity_setopt(uid,'fqdzz',{act='join',aid=aid}) 
        -- 节日花朵
        activity_setopt(uid,'jrhd',{act='join',id=aid})  
    end


    
    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()
        
        -- 本人邮件
        -- 直接加入，全团广播
        -- 加入申请列表,管理员广播
        if joinRet.data.user then

            if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then
                -- 更新地图中的联盟字段
                local mMap = require "lib.map"
                local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                mMap:update(mid,{alliance=joinRet.data.alliance.name})
            end

            local content = {type=3,aName=joinRet.data.alliance.name}
            content = json.encode(content)
            MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname,3,content,1,0)

            -- push -------------------------------------------------            
            local mems = M_alliance.getMemberList{uid=uid,aid=aid}
            if mems then
                local cmd = 'alliance.memadd'
                local data = {
                    alliance = {
                        alliance={
                            members = {
                                {
                                    uid=uid,
                                    level=mUserinfo.level,
                                    name=mUserinfo.nickname,
                                    fight=mUserinfo.fc,
                                    role=joinRet.data.user.role,
                                    raising=joinRet.data.user.raising,
                                    signature=joinRet.data.user.signature,
                                    weekraising=joinRet.data.user.weekraising,
                                    logined_at=joinRet.data.user.logined_at,
                                    join_at=joinRet.data.user.join_at,
                                },
                            }
                        }
                    }
                }
                for _,v in pairs( mems.data.members) do
                        regSendMsg(v.uid,cmd,data)
                end
            end
            -- push -------------------------------------------------       
        else
            local content = {type=1,aName=joinRet.data.alliance.name}
            content = json.encode(content)
            MAIL:mailSent(uid,1,uid,'',mUserinfo.nickname,1,content,1,0)

            -- push -------------------------------------------------
            local admins = M_alliance.getMemberList{uid=uid,aid=aid,admin=1}
            if admins then
                local cmd = 'alliance.requestadd'
                local data = {
                    alliance={
                        alliance={  
                            requests = {
                                {
                                    uid = uid,
                                    nickname = mUserinfo.nickname,
                                    level = mUserinfo.level,
                                    fight = mUserinfo.fc,
                                },
                            }
                        }
                    }
                }
                
                for _,v in pairs( admins.data.members) do
                    regSendMsg(v.uid,cmd,data)
                end
            end
            -- push -------------------------------------------------
        end

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end 