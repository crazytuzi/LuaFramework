function api_active_fbreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local rank = tonumber(request.params.rank) or 0

     if uid == nil or rank < 1 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    -- 状态检测
    local status = mUseractive.isTakeReward('fbReward')
    if status ~= 1 then
        response.ret = status
        return response
    end

    local activeCfg = getConfig("active")
    local rewards = activeCfg.fbReward.serverreward.ranking

    local allianceReward = {}
    for _,v in ipairs(rewards) do
        table.insert(allianceReward,v.AllianceExp)
    end

    local rankData,code = M_alliance.addPoint({uid=uid,reward=json.encode(allianceReward),acEt=mUseractive.info.fbReward.et})
    if type(rankData) ~= 'table' then
        response.ret = -307 
        return response
    end
    
    local myRank = tonumber(rankData.rank)

    -- 如果领奖的名称与排名不一致，客户端应该刷新数据
    if myRank ~= rank then
        response.ret = -1981
        return response
    end

    local userJoinAt = tonumber(rankData.join_at)
    if not userJoinAt or userJoinAt > mUseractive.info.fbReward.et then
        response.ret = -1979
        return response
    end

    if not rewards[myRank] then
        response.ret = -1980
        return response
    end
    local reward=copyTab(rewards[myRank])
    reward.AllianceExp=nil
    if not takeReward(uid,reward) then
        response.ret = -403
        return response
    end
        
    mUseractive.info.fbReward.c = -1

    local mTask = uobjs.getModel('task')
    mTask.check()  

    if uobjs.save() then
        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.alliData = rankData.data
        response.msg = 'Success'
    end
    
    return response
end
