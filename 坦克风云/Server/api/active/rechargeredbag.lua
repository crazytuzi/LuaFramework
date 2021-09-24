-- 充值红包活动
-- @params tid 目标id(兑换时是兑换目标的id)
function api_active_rechargeredbag(request)
    local response = {
        ret     = -1,
        msg     = 'error',
        data    = {},
    }

    local uid       = request.uid
    local tid       = tonumber(request.params.tid) or 1
    local aname     = 'rechargeredbag'

    if not uid then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({'userinfo','useractive','bag','troops','accessory','hero','friends'})
    local mUseractive   = uobjs.getModel('useractive')
    local mUserinfo     = uobjs.getModel('userinfo')
    local mBag          = uobjs.getModel("bag")
    local activStatus   = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    -- 活动数据
    local actinfo   = mUseractive.info[aname]
    local actCfg    = mUseractive.getActiveConfig(aname)
    
    -- 参数错误
    if 0 > tid or tid > #actCfg.reward.cost then
        response.ret = -102
        response.msg = 'tid error' 
        return response
    end
    
    -- 隔天刷新数据
    local weeTs     = getWeeTs()
    if actinfo.t < weeTs then
        actinfo.t = weeTs
        actinfo.v = 0                       -- 充值值
        actinfo.rs = {}                     -- 领奖状态
        for i=1,#actCfg.reward.cost do
            actinfo.rs[i] = 0
        end
        
        mUseractive.info[aname] = actinfo
    end
    
    -- 验证是否达标
    local targetNeed = actCfg.reward.cost[tid]
    if targetNeed > actinfo.v then
        response.ret = -102
        response.msg = 'recharge not enough' 
        return response
    end
    
    -- 验证是否已经领取
    if 1 == actinfo.rs[tid] then
        response.ret = -102
        response.msg = 'reward already get' 
        return response
    end
    
    -- 领取奖励
    local reward = actCfg.reward.serverreward.r[tid]
    if not takeReward(uid, reward) then
        response.ret = -403
        return response
    end
    
    -- 更新标识
    actinfo.rs[tid] = 1
    
    -- 数据返回
    if uobjs.save() then
        response.data[aname] = mUseractive.info[aname]
        response.data.bag = mBag.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
