--投资计划领取奖励
function api_active_investplan(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称 ，投资计划
    local aname = 'investPlan'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')


    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测

    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local weets  =getWeeTs() 
    local st = mUseractive.info[aname].st
    local stweets  = getWeeTs(st)
    local activeCfg = getConfig("active.investPlan")
    local changeday = tonumber(activeCfg.chargeday) or 0
    local ts = getClientTs()
    if ts <= (stweets+changeday*86400) then
        response.ret = -1981
        return response
    end 

    local rt  =tonumber(mUseractive.info[aname].rt) or 0;

    -- 检测今天是否领取
    if rt>weets then
        response.ret = -1993
        return response
    end 

    -- 检测是否有额外的奖励
    if mUseractive.info[aname].t <=0 then
        response.ret = -1981
        return response
    end
        
    local addgems = (activeCfg.serverreward.extra[mUseractive.info[aname].t]) or 0

    if addgems<=0 then
        response.ret = -1981
        return response
    end
    local ret = mUserinfo.addResource({gems=addgems})

    if not ret then
        response.ret = -403 
        return response
    end

    --添加统计    领取奖励增加金币
    regActionLogs(uid,6,{action=5006,item=pid,value=addgems,params={}})
    mUseractive.info[aname].rt = ts
        
    processEventsBeforeSave()
    local function Log(logInfo,filename)
        local log = ""
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'investplan'
        writeLog(log,filename)
    end 
    if ret and uobjs.save() then 
        Log({uid=uid,reward=reward})       
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats(aname,{user=uid})
        response.ret = 0
        response.msg = 'Success'

    end
    
    return response
end
