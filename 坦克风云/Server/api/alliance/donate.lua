function api_alliance_donate(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    local sid = request.params.sid
    local uid = tonumber(request.uid)

    local count = tonumber(request.params.count)
    local consumeType = tonumber(request.params.consumeType) -- 2是金币，1是资源
    local rname = request.params.rname

    if uid == nil or aid == 0 or sid == 0 or count == nil or consumeType == nil or rname == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task","useractive"})

    local mUserinfo = uobjs.getModel('userinfo')    
    local mBag = uobjs.getModel('bag')
    local mUseractive = uobjs.getModel('useractive')
    
    if aid ~= mUserinfo.alliance then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceskills') == 0 then
        response.ret = -310
        return response
    end
    local cfg = getConfig("player")

    if not cfg.allianceDonateResources or not cfg.allianceDonateResources[count] or not cfg.allianceDonateGold[count] then
        response.ret = -102
        return response
    end

    -- 使用资源
    if consumeType == 1 then
        if not mUserinfo.useResource({[rname]=cfg.allianceDonateResources[count]}) then
            response.ret = -107
            return response
        end

    -- 使用宝石
    elseif not mUserinfo.useGem(cfg.allianceDonateGold[count]) then
        response.ret = -109 
        return response
    end

    local acname = "allianceDonate"
    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    local st = 0
    local et = 0
    local rate = 1
    if activStatus == 1 then
        st=mUseractive.info[acname].st
        et=mUseractive.getAcet(acname,true)
        local activeCfg = getConfig("active.allianceDonate")
        rate= activeCfg.serverreward.value or 0

    end

    local adddonatecount = 0
    -------------------- start vip新特权 增加捐献次数
    if moduleIsEnabled('vdn') == 1 and mUserinfo.vip>0 then
            local vipRelatedCfg = getConfig('player.vipRelatedCfg')
            if type(vipRelatedCfg)=='table' then
                local vip =vipRelatedCfg.donateAddNum[1]
                if mUserinfo.vip>=vip then
                    adddonatecount=vipRelatedCfg.donateAddNum[2]
                end
            end                   
    end
    --------------------- end
    local date  = getWeeTs()
    local ts    = getClientTs()
    local weeTs = getWeeTs()
    local allianceActive = getConfig("alliance.allianceActive")
    local allianceActivePoint = getConfig("alliance.allianceActivePoint")
    local apoint =allianceActivePoint[1]
    local apointcount =allianceActive[1]
    local execRet,code = M_alliance.donate{uid=uid,aid=aid,skill=sid,nums=nums,method=consumeType,rname=rname,count=count,acst=st,acet=et,rate=rate,addcount=adddonatecount,weet=weeTs,ts=ts,ap=apoint,apc=apointcount}
    
    if not execRet then
        response.ret = code
        return response
    end
    -- 资金招募活动
    activity_setopt(uid,'fundsRecruit',{type=consumeType, name="donate"})
    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='ad',n=count}) 

    --德国七日狂欢 
    activity_setopt(uid,'sevendays',{act='sd20',v=0,n=count})    

    -- 金币捐献时，除了道具和声望，其它送双倍
    if type(cfg.allianceDonate[count]) == "table" then
        if cfg.allianceDonate[count][3] and cfg.allianceDonate[count][3] > 0 then
            mUserinfo.addHonor(cfg.allianceDonate[count][3])            
        end

        if cfg.allianceDonate[count][4] and cfg.allianceDonate[count][4] > 0 then            
            mBag.add('p19',cfg.allianceDonate[count][4])
        end
    end
    
    -- 如果成功的修改字段后，会有相应的字段返回，
    -- 前台传回的修改信息与原信息无任何变化的情况在这里排除
    -- if type(execRet.data) == 'table' and next(execRet.data) then

    --     -- push -------------------------------------------------
    --     local cmd = 'alliance.donate'
    --     local data = {
    --         alliance = {
    --             execRet.data
    --         }
    --     }

    --     local mems = M_alliance.getMemberList{uid=uid,aid=aid}
    --     if mems then
    --         for _,v in pairs( mems.data.members) do
    --                 regSendMsg(v.uid,cmd,data)
    --         end
    --     end
    --     -- push -------------------------------------------------
    -- end

    if consumeType == 2 then
        local oldSkillRaising = execRet.data.old_point
        local skillRaising = execRet.data.level_point
        regActionLogs(uid,1,{action=20,item="donate",value=cfg.allianceDonateGold[count],params={skill=sid,allianceId=aid,donateCount=count,userRaising=execRet.data.raising,userWeekRaising=execRet.data.weekraising,oldSkillRaising=oldSkillRaising,skillRaising=skillRaising,}})

        local  setinfo ={}
        setinfo.gold=cfg.allianceDonateGold[count]
        setinfo.aid=aid
        activity_setopt(uid,'allianceLevel',setinfo,true)
    end

      
    local gx = tonumber(execRet.data.addpoint) or 0
    if gx>0 and mUserinfo.alliance > 0 then
        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false,true)
        if mAterritory then
            if mAterritory.uptask({act=4,num=gx,u=mUserinfo.uid}) then
                regEventAfterSave(uid,'e10',{aid=mUserinfo.alliance})
            end
        else
            writeLog('军团领地任务uid='..uid..'贡献='..gx,"territory_uptask")
        end
    end

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s305',1)
    mDailyTask.changeTaskNum1('s1009',1)

    -- 愚人节大作战-进行X次军团捐献
    activity_setopt(uid,'foolday2018',{act='task',tp='ad',num=1},true)

     -- 团结之力
    activity_setopt(uid,'unitepower',{id=1,aid=mUserinfo.alliance,num=1})
    -- 感恩节拼图
    activity_setopt(uid,'gejpt',{act='tk',type='ad',num=1})

    if uobjs.save() then
        processEventsAfterSave()

        response.data = execRet.data
        

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	