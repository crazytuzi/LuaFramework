function api_active_monthlysign(request)
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

    -- 活动名称 月度签到
    local aname = 'monthlysign'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local starWeets = getWeeTs(mUseractive.info[aname].st) 
    local nowWeets = getWeeTs()
    local svrDay = math.floor( (nowWeets - starWeets) / 86400 ) + 1
    -- 春节活动签到 做一下特殊检测
    -- if mUseractive.info[aname].cfg == 1  then

    -- end   
    local activeCfg = getActiveCfg(uid, aname)
    local self = {}

    --免费奖励
    function self.getFreeAward( nDay )
        -- 不能领取
        if svrDay ~= nDay then
            response.ret = -8302
            return false, response
        end

        mUseractive.info[aname].f = mUseractive.info[aname].f or {}
        -- 已经领取
        if self.in_array(mUseractive.info[aname].f, nDay) then
            response.ret = -8301
            return false, response
        end

        --vip 双倍奖励
        local rewardCfg = activeCfg.serverreward.freereward[nDay]
        local reward = copyTable( rewardCfg.r )
        if rewardCfg.vip ~= -1 and mUserinfo.vip >= rewardCfg.vip then
            for k, v in pairs( rewardCfg.r ) do
                reward[k] = tonumber(v) * 2
            end
        end

        if not takeReward(uid, reward) then        
            response.ret = -403 
            return false, response
        end

        --标记
        table.insert(mUseractive.info[aname].f, nDay)

        return true, reward
    end

    -- 付费奖励
    function self.getPayAward( nDay )
        mUseractive.info[aname].p = mUseractive.info[aname].p or {}
        -- 不能领取
        if svrDay < nDay  or not mUseractive.info[aname].p[nDay] or mUseractive.info[aname].p[nDay]~=2 then
            response.ret = -8302
            return false, response
        end

        -- 已经领取
        if mUseractive.info[aname].p[nDay] == 3  then
            response.ret = -8301
            return false, response
        end

        --发奖
        local rewardCfg = activeCfg.serverreward.payreward[nDay]
        local reward = rewardCfg.r
        if not takeReward(uid, reward) then        
            response.ret = -403 
            return false, response
        end

        --标记
        mUseractive.info[aname].p[nDay] = 3

        return true, reward
    end

    --存在数组中
    function self.in_array(array, vData)
        for k, v in pairs(array) do
            if v == vData then
                return true
            end
        end

        return false
    end

    ----------------------main-----------------------------
    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local action = tonumber( request.params.action ) or 0
    local cDay = tonumber(request.params.day)   
    local ret, reward 

    if action == 1 then
        ret, reward = self.getPayAward(cDay)          
    else
        ret, reward = self.getFreeAward(cDay)
    end

    if not ret then
        return response 
    end

    processEventsBeforeSave()
    if  uobjs.save() then        
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats({action=action, day= cDay})
        response.data.useractive = { [aname]=mUseractive.info[aname] }
        -- response.data.bag = mBag.toArray(true)
        if reward then 
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
