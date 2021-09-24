function api_alliance_quit(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    local memuid =  tonumber(request.params.memuid)
    local uid = request.uid
    
    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
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


    local isPush = false
    local qid
    local quitRet,code
    local ts = getClientTs()
    local areadate  = getWeeTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local areaWarCfg = getConfig('areaWarCfg')
    local day=areaWarCfg.prepareTime
    if weekday~=day then 
        if weekday>=day then
            areadate=areadate-(weekday-day)*86400
        else
            areadate=areadate+(day-weekday)*86400
        end
    end
    local areadateEt=areadate+86400

    local battletSt=areadateEt+areaWarCfg.startWarTime[1]*3600+areaWarCfg.startWarTime[2]*60

    local battleEt =battletSt+areaWarCfg.maxBattleTime

    local function updatehelp(uid) 
        ALLIANCEHELP = require "lib.alliancehelp"
        ALLIANCEHELP:updatealliance(uid,0)
    end
    local allianceWarCfg = getConfig('allianceWarCfg')
    if moduleIsEnabled('alliancewarnew')==1 then
        allianceWarCfg=getConfig('allianceWar2Cfg')
    end
    local quitRet,code
    if memuid and memuid > 0 then
        local memuobjs = getUserObjs(memuid)
        memuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
        local memUserinfo = memuobjs.getModel('userinfo')
        local memTroops = memuobjs.getModel('troops')

        -- 该成员有部队正在异星矿场活动，不能踢出
        if memTroops.hasAlienmineFleet() then
            response.ret = -8102
            return response
        end

        require "model.serverbattle"


        if memUserinfo.usegems >0 then
            local mServerbattle = model_serverbattle()
            local amMatchinfo = mServerbattle.getAcrossBattleInfo()
            -- 有军团的时候不能踢出军团
            if next(amMatchinfo) then
                response.ret=-21019  --跨站军饷未领取不能被提出军团
                return response
            end
        end

        local mServerbattle = model_serverbattle()


        --缓存跨服区域战的基本信息
        local mMatchinfo= mServerbattle.getserverareabattlecfg()
        local areaapplyts=nil
        local areaapplyet=nil
        if  type(mMatchinfo)=='table' and next(mMatchinfo)  then
            areaapplyts=tonumber(mMatchinfo.st)
            local sevCfg = getConfig('serverAreaWarCfg')
            areaapplyet=areaapplyts+(sevCfg.durationtime*24*3600)
        end
        
        local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
        local weeTs = getWeeTs()
        quitRet,code = M_alliance.quit{teamts=areaapplyts,teamet=areaapplyet,mid=memuid,uid=uid,aid=aid,et=weeTs+ents,config=json.encode(allianceWarCfg.startWarTime),date=weeTs,bttime=allianceWarCfg.warTime,areadate=areadate,areadateEt=areadateEt,battletSt=battletSt,battleEt=battleEt,count=areaWarCfg.signupBattleNum}

        if not quitRet then
            response.ret = code

            -- 正在参与群雄争霸不能踢出军团
            if areaapplyet and ts < areaapplyet then
                response.ret = -8104
            end

            return response
        end
        -- 万圣节狂欢
        activity_setopt(memuid,'wsjkh',{act='quit',aid=memUserinfo.alliance})
        -- hfdz 
        activity_setopt(memuid,'hfdz',{act='quit',aid=memUserinfo.alliance,num=0})  
        -- 愚人节大作战退出军团
        activity_setopt(memuid,'foolday2018',{act='quitAlliance',aid=memUserinfo.alliance},true)
        -- 团结之力
        activity_setopt(memuid,'unitepower',{quit=true,aid=memUserinfo.alliance})
        -- 军团之光
        activity_setopt(memuid,'jtzg',{act='quitAlliance',aid=memUserinfo.alliance})

        -- 番茄大作战
        activity_setopt(memuid,'fqdzz',{act='quit'})

        -- 三周年-冲破噩梦
        activity_setopt(memuid,'cpem',{type='quit',aid=memUserinfo.alliance})

        -- 国庆七天乐
        activity_setopt(memuid,'nationalday2018',{act='quit',aid=memUserinfo.alliance})
        activity_setopt(memuid,'double112018',{act='quit',aid=memUserinfo.alliance})

         -- 节日花朵
        activity_setopt(memuid,'jrhd',{act='quit',id=memUserinfo.alliance})  

        -- 领地部队撤回
        memTroops.territoryFleetBack()
        memuobjs.getModel('atmember').resetMember()

        memUserinfo.alliance = 0
        memUserinfo.alliancename = ''
        regEventBeforeSave(memuid,'e1')

        processEventsBeforeSave()

        if memuobjs.save() then
            processEventsAfterSave()
            if moduleIsEnabled('alliancehelp') == 1 then
                updatehelp(memuid)
            end
            if memUserinfo.mapx ~= -1 and memUserinfo.mapy ~= -1 then
                -- 更新地图中的联盟字段
                local mMap = require "lib.map"
                local mid = getMidByPos(memUserinfo.mapx,memUserinfo.mapy)
                mMap:update(mid,{alliance=''})
            end

            if quitRet.data and quitRet.data.alliance and quitRet.data.alliance.name then
                local content = {type=4,aName=quitRet.data.alliance.name,cName=mUserinfo.nickname,role=quitRet.data.user.role}
                content = json.encode(content)
                MAIL:mailSent(memuid,1,memuid,'',mUserinfo.nickname,4,content,1,0)

                isPush = true  
                qid = memuid
            end

            response.data.cPlace = {memUserinfo.mapx,memUserinfo.mapy,memuid}
            response.ret = 0
            response.msg = 'Success'    
        end

    else

        if mTroops.hasHelpFleet() then
            response.ret = -8034
            return response
        end

        -- 有部队正在异星矿场活动，不能退出军团
        if mTroops.hasAlienmineFleet() then
            response.ret = -8101
            return response
        end

        if mUserinfo.usegems~=nil and  mUserinfo.usegems >0 then
            response.ret=-21020  --跨站军饷未领取不能退出军团
            return response
        end

        local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
        local weeTs = getWeeTs()
        
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()

        if moduleIsEnabled('joqa')==1 then
            local jqstatus = mServerbattle.joinorquit(1)
            if jqstatus~=0 then
                response.ret = jqstatus
                return response
            end
        end
        --缓存跨服区域战的基本信息
        local mMatchinfo= mServerbattle.getserverareabattlecfg()
        local areaapplyts=nil
        local areaapplyet=nil
        if  type(mMatchinfo)=='table' and next(mMatchinfo)  then
            areaapplyts=tonumber(mMatchinfo.st)
            local sevCfg = getConfig('serverAreaWarCfg')
            areaapplyet=areaapplyts+(sevCfg.durationtime*24*3600)
        end
        quitRet,code = M_alliance.quit{mid=memuid,teamts=areaapplyts,teamet=areaapplyet,uid=uid,aid=aid,et=weeTs+ents,config=json.encode(allianceWarCfg.startWarTime),date=weeTs,bttime=allianceWarCfg.warTime,areadate=areadate,areadateEt=areadateEt,battletSt=battletSt,battleEt=battleEt,count=areaWarCfg.signupBattleNum}
        
        if not quitRet then
            response.ret = code

            -- 正在参与群雄争霸不能退出军团
            if areaapplyet and ts < areaapplyet then
                response.ret = -8103
            end

            return response
        end

        -- 军团被解散的标识
        if tonumber(quitRet.flag) == 1 then
            local mTerritory = getModelObjs("aterritory",aid)
            if not mTerritory.isEmpty() then
                local territoryPos = mTerritory.getPos()
                if mTerritory.lock() then
                    mTerritory.destroy()
                    mTerritory.territoryLockBroadcast(territoryPos[1],territoryPos[2])
                end
            end
        end

        -- 领地部队撤回
        mTroops.territoryFleetBack()
        uobjs.getModel('atmember').resetMember()
        
        -- 万圣节狂欢
        activity_setopt(uid,'wsjkh',{act='quit',aid=mUserinfo.alliance}) 
         -- hfdz 
        activity_setopt(uid,'hfdz',{act='quit',aid=mUserinfo.alliance,num=0})  
        -- 愚人节大作战退出军团
        activity_setopt(uid,'foolday2018',{act='quitAlliance',aid=mUserinfo.alliance},true)

        -- 团结之力
        activity_setopt(uid,'unitepower',{quit=true,aid=mUserinfo.alliance})
        -- 军团之光
        activity_setopt(uid,'jtzg',{act='quitAlliance',aid=mUserinfo.alliance})
        -- 番茄大作战
        activity_setopt(uid,'fqdzz',{act='quit'})

        -- 三周年-冲破噩梦
        activity_setopt(uid,'cpem',{type='quit',aid=mUserinfo.alliance})

        -- 国庆七天乐
        activity_setopt(uid,'nationalday2018',{act='quit',aid=mUserinfo.alliance})
        activity_setopt(uid,'double112018',{act='quit',aid=mUserinfo.alliance})
         -- 节日花朵
        activity_setopt(uid,'jrhd',{act='quit',id=mUserinfo.alliance}) 

        mUserinfo.alliance = 0
        mUserinfo.alliancename = ''
        regEventBeforeSave(uid,'e1')

        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
            if moduleIsEnabled('alliancehelp') == 1 then
                updatehelp(uid)
            end
            if mUserinfo.mapx ~= -1 and mUserinfo.mapy ~= -1 then
                -- 更新地图中的联盟字段
                local mMap = require "lib.map"
                local mid = getMidByPos(mUserinfo.mapx,mUserinfo.mapy)
                mMap:update(mid,{alliance=''})
            end

            isPush = true 
            qid = uid

            response.ret = 0
            response.msg = 'Success'    
        end
    end



    -- push -------------------------------------------------
    local cmd = 'alliance.memquit'
    local data = {
        alliance = {
            alliance={
                members = {
                    {uid=qid,cName=mUserinfo.nickname,role=quitRet.data.user and quitRet.data.user.role}
                }
            }
        }
    }

    local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    if mems then
        for _,v in pairs( mems.data.members) do
                regSendMsg(v.uid,cmd,data)
        end
    end

    if qid ~= uid then
        regSendMsg(qid,cmd,data)
    end
    -- push -------------------------------------------------     

    return response
end	