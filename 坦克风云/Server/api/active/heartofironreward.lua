--领取钢铁之心的奖励
function api_active_heartofironreward(request)
    local response = {
        ret=-1,
        msg='error',
        data={},

    }

    local uid = request.uid
    local method = tonumber(request.params.method) or 1
    if uid==nil then
        response.ret=-102    
        return response
    end

    -- 活动名称 ，基金
    local aname = 'heartOfIron'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local rsttime  = mUserinfo.regdate

    local ts =getClientTs()
    local firstweets = getWeeTs(rsttime+24*3600)
    --检测注册时间是都大余7天
    if  ts> (firstweets+7*86400) then
        response.ret = -1981
        return response
    end   

    local activeCfg = getConfig("active.heartOfIron")

    
    if type(mUseractive.info[aname].t) ~='table' then  mUseractive.info[aname].t={} end

    local reward = {}
    --领取主基地等级奖励
    if method==1 then
        local need= activeCfg.condition.blevel[1]
        local cuut = (mUseractive.info[aname].v.blevel[3]) or 0 
        local rd = (mUseractive.info[aname].t.blevel)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.blevel=1
        local rindex = activeCfg.condition.blevel[2]
        reward=activeCfg.serverreward[rindex]

    end
    --领取玩家等级奖励
    if method==2 then
        local need= activeCfg.condition.ulevel[1]
        local cuut = (mUseractive.info[aname].v.ulevel[3]) or 0 
        local rd = (mUseractive.info[aname].t.ulevel)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.ulevel=1
        local rindex = activeCfg.condition.ulevel[2]
        reward=activeCfg.serverreward[rindex] 
    end
    --领取配件任务奖励
    if method==3 then
        local need= activeCfg.condition.alevel[1]
        local cuut = (mUseractive.info[aname].v.alevel[3]) or 0 
        local rd = (mUseractive.info[aname].t.alevel)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.alevel=1
        local rindex = activeCfg.condition.alevel[2]
        reward=activeCfg.serverreward[rindex]
    end
    --领取军团副本奖励
    if method==4 then
        local need= activeCfg.condition.acrd[1]
        local cuut = (mUseractive.info[aname].v.acrd[3]) or 0 
        local rd = (mUseractive.info[aname].t.acrd)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.acrd=1
        local rindex = activeCfg.condition.acrd[2]
        reward=activeCfg.serverreward[rindex]
    end

    --领取关卡星星的奖励
    if method==5 then
        local need= activeCfg.condition.star[1]
        local cuut = (mUseractive.info[aname].v.star[3]) or 0 
        local rd = (mUseractive.info[aname].t.star)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.star=1
        local rindex = activeCfg.condition.star[2]
        reward=activeCfg.serverreward[rindex]
    end
    --领取科技任务的奖励
    if method==6 then
        local need= activeCfg.condition.tech[1]
        local cuut = (mUseractive.info[aname].v.tech[3]) or 0 
        local rd = (mUseractive.info[aname].t.tech)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.tech=1
        local rindex = activeCfg.condition.tech[2]
        reward=activeCfg.serverreward[rindex]
    end
    --领取坦克任务奖励
    if method==7 then
        local need= activeCfg.condition.troops[1]
        local cuut = (mUseractive.info[aname].v.troops[3]) or 0 
       
        local rd = (mUseractive.info[aname].t.troops)  or 0
        if cuut<need or rd==1 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].t.troops=1
        local rindex = activeCfg.condition.troops[2]
        reward=activeCfg.serverreward[rindex]
    end


    if not next(reward) then
        response.ret = -1981
        return response
    end

    local ret = takeReward(uid,reward)
        
    regActionLogs(uid,5,{action=5007,item="heartofironreward",value=0,params={reward=reward,method=method}})

        
    processEventsBeforeSave()
    local function Log(logInfo,filename)
        local log = ""
        log = log .. os.time() .. "|"
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'heart'
        writeLog(log,filename)
    end 
    if ret and uobjs.save() then   
    Log({uid=uid,reward=reward})
        processEventsAfterSave()
        -- 统计

        mUseractive.setStats(aname,{reward=currentGetNum})
        response.ret = 0
        response.msg = 'Success'
        response.data.reward=da
    end
    
    return response





end