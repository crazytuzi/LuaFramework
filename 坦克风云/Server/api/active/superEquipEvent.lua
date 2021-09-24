function api_active_superEquipEvent(request)
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

    -- 活动名称 疯狂进阶
    local aname = 'superEquipEvent'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activecfg = mUseractive.getActiveConfig(aname)

    local self = {}
    -- idx 领奖索引
    function self.getaward( idx )
        if not activecfg.serverreward[idx] then
            response.ret = -401 
            return false, response
        end

        local cond = activecfg.serverreward[idx].condition

        mUseractive.info[aname].sv = mUseractive.info[aname].sv or {} -- 升阶数量
        if not mUseractive.info[aname].sv[ cond.color ] or 
            mUseractive.info[aname].sv[ cond.color ] < cond.num then
            response.ret = -402
            return false, response
        end

        mUseractive.info[aname].f = mUseractive.info[aname].f or {} -- 领取状态
        if mUseractive.info[aname].f[idx] and mUseractive.info[aname].f[idx] == 1 then
            response.ret = -405
            return false, response
        end

        for i = 1, idx do --领奖状态是顺序数组 0 未领取 1 已领取
            mUseractive.info[aname].f[i] = mUseractive.info[aname].f[i] or 0
        end
        mUseractive.info[aname].f[idx] = 1

        local reward = activecfg.serverreward[idx].r
        if not takeReward(uid, reward) then
            response.ret = -403
            return false, response
        end

        return true, reward
    end

    ----------------------main-----------------------------
    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local action = tonumber( request.params.action ) or 0
    local idx = tonumber( request.params.index)

    local ret, reward 

    if action == 0 then
        ret, reward = self.getaward(idx)
    end

    if not ret then
        return response 
    end

    processEventsBeforeSave()
    if  uobjs.save() then        
        processEventsAfterSave()
        -- 统计
        response.data.useractive = { [aname]=mUseractive.info[aname] }
        if reward then 
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
