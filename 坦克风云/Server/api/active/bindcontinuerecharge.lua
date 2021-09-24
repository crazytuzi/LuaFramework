--
--绑定型 连续充值活动
--
function api_active_bindcontinuerecharge(request)

    local aname = 'bindcontinueRecharge'

    local response = {
        ret=-1,
        msg='error',
        data = {['useractive'] = {[aname]={}}},
    }

    local uid = request.uid
    --领取奖励类型 login,gems,goods,updateTime
    local action = request.params.action
    local rwdday = tonumber(request.params.day)

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end


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


    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
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
    
    --默认配置
    local defaultData = {}
    for i=1,activeCfg.bindTime[2] do
        defaultData[i] = 0
    end

    if mUseractive.info[aname].v and type(mUseractive.info[aname].v) == 'table' then
        defaultData = mUseractive.info[aname].v
    end

    if action == 'getReward' then
        -- 领取大奖
        if not rwdday then
            if mUseractive.info[aname].c == 1 then
                response.ret = -401
                return response
            end

            -- 计算总共有几天
            local ds =0 
            for i=1,8 do
                if defaultData[i] and defaultData[i] >= activeCfg.dC[i] then 
                    ds = ds + 1
                elseif i ~= 8 and ds < activeCfg.continueDay then
                    ds = 0
                end    
            end
            
            -- 不满足天数要求
            if ds < activeCfg.continueDay then
                response.ret = -1981
                return response
            end

            --添加奖励
            local rwd = activeCfg.serverreward.endserverward[1]
            local ret, retw = takeReward(uid, rwd)
            if not ret  then
                return response
            end
            if type(retw) == 'table' and type(retw.armor) == 'table' then
                response.data.amreward =retw.armor.info
            end

            mUseractive.info[aname].c = 1
        -- 领取每日奖励
        else
            -- 参数不对
            if rwdday <= 0 or rwdday >  activeCfg.bindTime[2] then
                response.ret = -102
                return response
            end
            
            -- 已经领取
            if mUseractive.info[aname].dr and 1 == mUseractive.info[aname].dr[tostring(rwdday)] then
                response.ret = -102
                return response
            end
            
            -- 当日有充值并且满足条件
            if defaultData[rwdday] and defaultData[rwdday] < activeCfg.dC[rwdday] then
                response.ret = -102
                return response
            end
            
            -- 发放奖励
            local rwd = activeCfg.serverreward.r[rwdday]
            local ret, retw = takeReward(uid, rwd)
            if not ret then
                return response
            end
            if type(retw) == 'table' and type(retw.armor) == 'table' then
                response.data.amreward =retw.armor.info
            end
            
            mUseractive.info[aname].dr = mUseractive.info[aname].dr or {}
            mUseractive.info[aname].dr[tostring(rwdday)] = 1
        end
    end

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
