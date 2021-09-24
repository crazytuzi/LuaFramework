function api_alliance_donateall(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    local uid = tonumber(request.uid)
    local sid = request.params.sid

    if uid == nil or aid == nil or sid == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props", "useractive"})
    local mUserinfo = uobjs.getModel('userinfo')    
    local mBag = uobjs.getModel('bag')
    local mUseractive = uobjs.getModel('useractive')
    
    if aid ~= mUserinfo.alliance then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceskills') == 0 or moduleIsEnabled('donateall') == 0 then
        response.ret = -310
        return response
    end

    -- 玩家已经的捐献次数
    local acceptRet,code = M_alliance.get{aid=aid,uid=uid}
    if not acceptRet then
        response.ret = code
        return response
    end
    local todayraisingcount = acceptRet.data.user.todayraisingcount

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
    -- 玩家捐献上限
    local allcnt = acceptRet.data.user.allianceRaisingCount + adddonatecount

    local cfg = getConfig("player")
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

    --------------------- end
    local date  = getWeeTs()
    local ts    = getClientTs()
    local weeTs = getWeeTs()
    local consumeType = 2
    local usedGems = 0
    local allianceActive = getConfig("alliance.allianceActive")
    local allianceActivePoint = getConfig("alliance.allianceActivePoint")
    local apoint =allianceActivePoint[1]
    local apointcount =allianceActive[1]

    -- 依次捐献 {\"gold\":2,\"r1\":3,\"r2\":3,\"r3\":2}"
    local rnameArr = {"gold", "r1", "r2", "r3", "r4"}
    local exe_cnt = 0
    local exitcode=0
    local retDonate = {}
    local oldSkillRaising = nil -- execRet.data.old_point
    local skillRaising = 0 -- execRet.data.level_point
    -- {军团科技，贡献，军团资金，荣誉勋章，声望}
    local reward = {point=0, p19=0, honor=0 }  
    for count=1, allcnt do
        for krname, rname in pairs(rnameArr) do
            -- 没有捐献的次数  1 2
            if not todayraisingcount[rname] or (todayraisingcount[rname] < count) then
                local costGems = tonumber(cfg.allianceDonateGold[count])
                --检测钻石
                if not mUserinfo.checkResource({gems=costGems}) then
                    exitcode = -2
                    break
                end 
                               
                --捐献给军团
                local execRet,code = M_alliance.donate{uid=uid,aid=aid,skill=sid,method=consumeType,rname=rname,count=count,acst=st,acet=et,rate=rate,addcount=adddonatecount,weet=weeTs,ts=ts,ap=apoint,apc=apointcount}
                if execRet then
                    -- 扣钻石
                    if not mUserinfo.useGem(costGems) then
                        writeLog({uid=uid, 
                            msg='usegem err', 
                            cost=cfg.allianceDonateGold[count],
                            gems = mUserinfo.gems }, 'donateall')
                        exitcode = -2
                        break
                    end                     
                    -- 金币捐献时，除了道具和声望，其它送双倍 给自己
                    if type(cfg.allianceDonate[count]) == "table" then
                        if cfg.allianceDonate[count][3] and cfg.allianceDonate[count][3] > 0 then
                            reward.honor = reward.honor + cfg.allianceDonate[count][3]
                            mUserinfo.addHonor(cfg.allianceDonate[count][3])            
                        end

                        if cfg.allianceDonate[count][4] and cfg.allianceDonate[count][4] > 0 then
                            reward.p19 = reward.p19 + cfg.allianceDonate[count][4]            
                            mBag.add('p19',cfg.allianceDonate[count][4])
                        end
                    end

                    --过程记录
                    oldSkillRaising = oldSkillRaising or execRet.data.old_point 
                    skillRaising = execRet.data.level_point --军团科技（经验）
                    reward.point = reward.point + execRet.data.addpoint
                    exe_cnt = exe_cnt + 1
                    usedGems = usedGems + costGems
                    todayraisingcount[rname] = count
                    retDonate = execRet.data
                else
                    if code == -8058 or code == -8027 or code == -8031 or code == -8026 then
                        exitcode = code
                        break
                    end
                end

            end --可以捐献

        end  -- 每种资源试一次

        if exitcode ~= 0 then
            break
        end

    end

    -- 资金招募活动
    activity_setopt(uid,'fundsRecruit',{type=2, name="donate", donate_cnt=exe_cnt})
    activity_setopt(uid,'allianceLevel',{gold=usedGems, aid=aid},true)

    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='ad',n=exe_cnt})  

    --德国七日狂欢 
    activity_setopt(uid,'sevendays',{act='sd20',v=0,n=exe_cnt})    

    -- 愚人节大作战-进行X次军团捐献
    activity_setopt(uid,'foolday2018',{act='task',tp='ad',num=exe_cnt},true)  

     -- 团结之力
    activity_setopt(uid,'unitepower',{id=1,aid=mUserinfo.alliance,num=exe_cnt})   
     -- 感恩节拼图
    activity_setopt(uid,'gejpt',{act='tk',type='ad',num=exe_cnt})

    --日志
    regActionLogs(uid,1,{action=20,item="donateall",value=usedGems,params={skill=sid,allianceId=aid,donateCount=exe_cnt,reward=reward}})

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeNewTaskNum('s305',exe_cnt)
    mDailyTask.changeTaskNum1('s1009',exe_cnt)

    local gx = tonumber(reward.point) or 0
    if gx>0 and  mUserinfo.alliance > 0 then
        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false,true)
        if mAterritory then
            writeLog('一键捐献获得贡献='..gx,"territory_uptask")
            if mAterritory.uptask({act=4,num=gx,u=mUserinfo.uid}) then
                regEventAfterSave(uid,'e10',{aid=mUserinfo.alliance})
            end
        else
            writeLog('军团领地任务一键捐献uid='..uid..'贡献='..gx,"territory_uptask")
        end
    end

    if uobjs.save() then
        processEventsAfterSave()
        response.data = retDonate
        response.data.exitcode = exitcode
        response.data.usedGems = usedGems
        response.data.execnt = exe_cnt
        response.data.reward = reward
        response.data.rc = todayraisingcount
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	