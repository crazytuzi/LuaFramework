function api_active_userfund(request)
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

    -- 活动名称 ，基金
    local aname = 'userFund'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active." .. aname.."."..mUseractive.info[aname].cfg)

    local currentGetNum = (mUseractive.info[aname].c or 0) + 1
    local currentCost = activeCfg.serverreward.cost[currentGetNum] or 0

    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end
    
    local reward = activeCfg.serverreward.r[currentGetNum]
    local ret = takeReward(uid,reward)
    	
   regActionLogs(uid,5,{action=5005,item="userfund",value=0,params={reward=reward}})


    --设置领取第几挡的奖励
    mUseractive.info[aname].c = currentGetNum
        
    processEventsBeforeSave()
    local function Log(logInfo,filename)
        local log = ""
        log = log .. os.time() .. "|"
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'fund'
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
