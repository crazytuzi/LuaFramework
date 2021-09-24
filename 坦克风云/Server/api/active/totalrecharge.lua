function api_active_totalrecharge(request)
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

    -- 活动名称 ，累计充值
    local aname = 'totalRecharge'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    --activity_setopt(uid,'totalRecharge',{num=gold_num})
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getActiveCfg(uid, aname)
    local currentGetNum = (mUseractive.info[aname].c or 0) + 1
    local currentCost = activeCfg.serverreward.cost[currentGetNum] or 0
    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end
  
    local reward = activeCfg.serverreward.r[currentGetNum]
    local heroflag=false
    --如果包含将领 需要给客户端传hero刷新
    for k,v in pairs(reward) do
        local rk=k:split('_')
        if rk[1]=='hero' then
            heroflag=true
            break
        end
    end


    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end


    mUseractive.info[aname].c = currentGetNum
        
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
        -- 统计
        mUseractive.setStats(aname,{reward=currentGetNum})
        if heroflag then
            response.data.hero = mHero.toArray(true)
        end
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
