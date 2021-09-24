function api_active_qixi(request)
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

    -- 活动名称 ，七夕
    local aname = 'qixi'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activeCfg = getActiveCfg(uid, aname)
    local self = {}
    --领奖
    function self.getAward( currentGetNum )
        -- body

        --消费不够
        local currentCost = activeCfg.cost[currentGetNum] or 0
        if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
            response.ret = -1981
            return false, response
        end

        --已经领取
        mUseractive.info[aname].get = mUseractive.info[aname].get or {}
        for k, v in pairs(mUseractive.info[aname].get) do
            if v == currentGetNum then
                response.ret = -1982
                return false, response                
            end
        end

        local reward = activeCfg.serverreward[currentGetNum]
        if not takeReward(uid,reward) then        
            response.ret = -403 
            return false, response
        end

        --标记
        table.insert(mUseractive.info[aname].get, currentGetNum)

        return true, reward
    end


    ----------------------main-----------------------------
    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local idx = request.params.index    
    local ret, reward = self.getAward( idx )

    if not ret then
        return response 
    end

    processEventsBeforeSave()
    if  uobjs.save() then        
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats(aname, {reward=currentGetNum})
        response.data.bag = mBag.toArray(true)
        if reward then 
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
