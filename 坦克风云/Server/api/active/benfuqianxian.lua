-- 前线军需活动
function api_active_benfuqianxian(request)
    local response = {
        ret = -1,
        msg = 'error',
        data = {},
    }
    
    local uid = request.uid
    local rewardId = request.params.rewardId -- 领取的奖励档次
    
    if uid == nil or rewardId == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({ "userinfo", "techs", "troops", "useractive", "props", "bag", "skills", "buildings", "dailytask", "task" })
    
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')
    
    -- 活动名称，
    local aname = 'benfuqianxian'
    
    -- 状态检测
    local status = mUseractive.getActiveStatus(aname)
    if status ~= 1 then
        response.ret = status
        return response
    end
    
    local activeCfg = mUseractive.getActiveConfig(aname)
    local activeInfo = mUseractive.info[aname]
    
    -- 配置无对应奖励
    if not activeCfg.serverreward[rewardId] then
        return response
    end
    
    -- 领取过的奖励信息
    if type(activeInfo.r) ~= 'table' then
        activeInfo.r = {}
    end
    
    -- 已经领过奖了
    if table.contains(activeInfo.r, rewardId) then
        response.ret = -1976
        return response
    end

    -- 领取对应奖励所需的点数不足
    if (activeInfo.point or 0) < activeCfg.need[rewardId] then
        response.ret = -1981
        return response
    end
    
    -- 记录领取过的奖励ID
    table.insert(activeInfo.r,rewardId)

    -- 发奖
    if not takeReward(uid, activeCfg.serverreward[rewardId]) then
        response.ret = -1989
        return response
    end    
    
    if uobjs.save() then
        response.data[aname] = activeInfo
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
