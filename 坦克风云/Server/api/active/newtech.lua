--
-- 道具合成和道具研究（技术革新）
-- User: luoning
-- Date: 14-9-3
-- Time: 上午11:44
--

function api_active_newtech(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action = request.params.action
    local pid = request.params.pid
    local num = tonumber(request.params.num) or 0

    if uid == nil or pid == nil or action == nil or (not (num == 1 or num == 10)) then
        response.ret = -102
        return response
    end
    local aname = 'newTech'
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward
    local mProp = uobjs.getModel('props')
    local mBag = uobjs.getModel('bag')
    -- 刷新生产队列
    mProp.update()

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg =  getConfig("active." .. aname )
    -- 得到需要消耗的道具
    local getCost = function(pid, num, costCfg)
        for _, v in pairs(costCfg) do
            if v[1] == pid then
                return num * v[2], v[3]
            end
        end
        return false
    end

    local clientReward = {}
    --道具合成
    if action == 'normal' then

        local cost, rewardPid = getCost(pid, num, activeCfg.pa)
        if not cost then
            return response
        end

        if not mBag.use(pid,cost) then
            response.ret = -1989
            return response
        end

        if not mBag.add(rewardPid, num) then
            response.ret = -1998
            return response
        end
        clientReward = {{rewardPid, num}}
    --道具随机
    elseif action == 'rand' then
        --消耗道具
        local cost = getCost(pid, num, activeCfg.pb)
        if not mBag.use(pid,cost) then
            response.ret = -1989
            return response
        end

        local ts = getWeeTs()
        local poolSmall = activeCfg.serverreward.small
        local poolBig = false
        --检查是否有大奖机会
        if mUseractive.info[aname].v < ts then
            poolBig = activeCfg.serverreward.big
            --每日重置
            mUseractive.info[aname].v = ts
        end
        --大奖
        if poolBig then
            local reward = getRewardByPool(poolBig)
            for type,num in pairs(reward) do
                table.insert(clientReward, {type, num})
            end
            num = num - 1
        end
        --其余奖励
        if num > 0 then
            for i=1, num do
                local reward = getRewardByPool(poolSmall)
                for type,num in pairs(reward) do
                    table.insert(clientReward, {type, num})
                end
            end
        end

        for _,v in pairs(clientReward) do
            if not mBag.add(v[1], v[2]) then
                response.ret = -1998
                return response
            end
        end
    end

    if (action== 'normal' or action == 'rand') and uobjs.save() then
        if clientReward and next(clientReward) then
            response.clientReward = clientReward
        end
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end
