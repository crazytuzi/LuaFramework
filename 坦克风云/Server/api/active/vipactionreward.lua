-- VIP总动员活动 
-- 凌晨清数据清除每日的数据
-- 总的充值金币不会清除
function api_active_vipactionreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local total = tonumber(request.params.total) or 0
    local currentGetNum  =tonumber(request.params.num) or 1
     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，VIP总动员活动 
    local aname = 'vipAction'
        
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

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active.vipAction")
    local lastTs = mUseractive.info[aname].t or 0
    local reward ={} 

    if total ==0 then
        if weeTs > lastTs then
            mUseractive.info[aname].vc = {}
            mUseractive.info[aname].v = 0
        end

        if type(mUseractive.info[aname].vc )~='table' then mUseractive.info[aname].vc = {} end

        local flag=table.contains(mUseractive.info[aname].vc,currentGetNum)
        if(flag)then
            response.ret=-1976
            return response
        end
        local currentCost = activeCfg.dayrecharge[currentGetNum] or 0

        if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
            response.ret = -1981
            return response
        end
        
        mUseractive.info[aname].t = weeTs
        table.insert(mUseractive.info[aname].vc,currentGetNum)
        mUseractive.info[aname].c = currentGetNum
        reward = activeCfg.serverreward.r[currentGetNum]

    
    else
        --领取总的奖励
       local rc = (mUseractive.info[aname].rc or 0)
       if rc ==1 then
            response.ret = -1981
            return response
       end
       local cuut=(mUseractive.info[aname].r or 0)

       if cuut< activeCfg.cost[1] then
            response.ret = -1981
            return response
       end

       reward=activeCfg.serverreward.reward[1]
       mUseractive.info[aname].rc=1
    end
    if not next(reward) then
        response.ret=-1988  
        return response
    end
    local ret = takeReward(uid,reward)

    -- 统计
    mUseractive.setStats(aname,{reward=currentGetNum,weeTs=weeTs})

    processEventsBeforeSave()
    local function Log(logInfo,filename)
        local log = ""
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'vipAction'
        writeLog(log,filename)
    end 
    if ret and uobjs.save() then 
        Log({uid=uid,reward=reward})       
        processEventsAfterSave()
        response.data.reward=formatReward(reward)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
