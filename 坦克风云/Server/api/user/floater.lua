function api_user_floater(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('floater') == 0 or moduleIsEnabled('ec') ==0  then
        response.ret = -9000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    if type(mUserinfo.flags.floater) ~= 'table' then mUserinfo.flags.floater={0,0} end
    local weets = getWeeTs()
    if mUserinfo.flags.floater[1] ~= weets then
        mUserinfo.flags.floater[1] = weets -- 0点时间戳
        mUserinfo.flags.floater[2] = 0 -- 拾取个数
    end

   -- local server_version = getVersionCfg()
    local cfg = getConfig('floaterCfg')[1]

    -- 寻找档次
    local pool_idx = #cfg.level
    for k, v in pairs(cfg.level) do
        if mUserinfo.level <= v then
            pool_idx = k
            break
        end
    end

    local maxcnt = cfg.floaterMax
 --    local aname = "searchEasterEgg"
	-- -- 活动上线倍率加成
 --    if mUseractive.getActiveStatus(aname) == 1 then
 --        local activeCfg = mUseractive.getActiveConfig(aname)
 --        maxcnt = maxcnt * activeCfg.floaterChangedProbability
 --    end
    if (mUserinfo.flags.floater[2] + 1) > maxcnt then
        response.ret = -1105
        response.msg = 'out of count'
        return response
    end

    local reward = getRewardByPool( cfg.reward[pool_idx].pool )
    if not takeReward(uid, reward) then 
        response.ret = -403
        return response
    end

    -- 复活节彩蛋大搜寻
    local eggReward = activity_setopt(uid,'searchEasterEgg',{egg1=1})
    if eggReward then
        response.data.egg= eggReward
    end
    mUserinfo.flags.floater[2] = mUserinfo.flags.floater[2] + 1
    -- 奖励统计
    local itemid, itemcnt = "", 0
    if next(reward) then
        for k, v in pairs(reward) do
            k = k:split('_')
            if type(k) == 'table' and k[2] then
                itemid = k[2]
            end
            itemcnt = v
        end
    end
    regActionLogs(uid,3,{action=2,item=itemid,value=itemcnt,params={count=mUserinfo.flags.floater[2]}})

    processEventsBeforeSave()
    if uobjs.save() then        
        processEventsAfterSave()
        if next(reward) then
            response.data.reward = formatReward(reward)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
