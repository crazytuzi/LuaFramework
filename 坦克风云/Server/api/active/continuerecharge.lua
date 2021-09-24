--
--连续充值活动
-- User: luoning
-- Date: 14-8-11
-- Time: 下午4:24
--
function api_active_continuerecharge(request)

    local aname = 'continueRecharge'

    local response = {
        ret=-1,
        msg='error',
        data = {['useractive'] = {[aname]={}}},
    }

    --默认配置
    local defaultData = {
        0,0,0,0,0,0,0
    }

    local uid = request.uid
    --领取奖励类型 login,gems,goods,updateTime
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward


    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if mUseractive.info[aname].v and type(mUseractive.info[aname].v) == 'table' then
        defaultData = mUseractive.info[aname].v
    end

    local activeCfg =  getActiveCfg(uid, aname)

    if action == 'modify' then
        local day = request.params.day or 1
        --当前时间
        local nowWeelTs = getWeeTs();
        local activeEndTime = getWeeTs(mUseractive.info[aname].et)

        if day < 1 or day > 7 then
            response.ret = -102
            return response
        end


        local checkDay = function(nowWeelTs, activeEndTime)
            local day = 7 - ((activeEndTime - nowWeelTs) / 86400)
            if day > 7 or day < 1 then
                return false
            else
                return day
            end
        end

        local maxDay = checkDay(nowWeelTs, activeEndTime)
        --活动是否过期
        if not maxDay then
            return response
        end
        --修改时间是否在当前时间之前
        if day >= maxDay then
            return response
        end
        --是否已经满足条件
        local blackGems = activeCfg.rR
        if defaultData[day] >= activeCfg.dC then
           return response
        end
        --使用金币
        local ret = mUserinfo.useGem(tonumber(blackGems))
        if not ret then
            response.ret = -1996
            return response
        end

        regActionLogs(uid,1,{action=38,item="",value=costGem,params={num=blackGems,type=day}})
        defaultData[day] = activeCfg.dC
        mUseractive.info[aname].v = defaultData
        response.data.useractive[aname] = mUseractive.info[aname]

    elseif action == 'getReward' then

        if mUseractive.info[aname].c == 1 then
            response.ret = -401
            return response
        end

        for _, v in pairs(defaultData) do
            if v < activeCfg.dC then
                response.ret = -1981
                return response
            end
        end
        --添加奖励
        for type,num in pairs(activeCfg.bR) do
            if not takeReward(uid, {['props_' .. type] = num}) then
                return response
            end
        end
        mUseractive.info[aname].c = 1
    end

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

