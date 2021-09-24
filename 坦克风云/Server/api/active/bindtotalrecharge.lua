function api_active_bindtotalrecharge(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local rwdday = tonumber(request.params.day) or 1

     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称 ，累计充值
    local aname = 'bindTotalRecharge'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward
    
    -- 开关未开启
    if not switchIsEnabled('bindActive') then
        response.ret = -102
        return response
    end

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    --activity_setopt(uid,'totalRecharge',{num=gold_num})
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    local activeCfg = getConfig("active."..aname)
    
    -- 没超过指定注册天数
    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
    if regDays < activeCfg.bindTime[1] or regDays > activeCfg.bindTime[2] + activeCfg.rewardTime then
        response.ret = -102
        return response
    end 
    mUseractive.info[aname].rs = mUseractive.info[aname].rs or {}

    local currentCost = activeCfg.serverreward.cost[rwdday] or 0
    if currentCost <= 0 or mUseractive.info[aname].v < currentCost then
        response.ret = -1981
        return response
    end
    
    if mUseractive.info[aname].rs[tostring(rwdday)] then
        response.ret = -401
        return response
    end
    
    local reward = activeCfg.serverreward.r[rwdday]
    local ret, retw = takeReward(uid,reward)
    if not ret then        
        response.ret = -403 
        return response
    end
    if type(retw) == 'table' and type(retw.armor) == 'table' then
        response.data.amreward =retw.armor.info
    end

    mUseractive.info[aname].c = 1
    mUseractive.info[aname].rs[tostring(rwdday)] = 1
        
    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
        
        response.data[aname] = mUseractive.info[aname]
        
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
