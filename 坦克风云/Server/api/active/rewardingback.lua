--
--满载而归
-- User: luoning
-- Date: 14-8-11
-- Time: 下午4:57
--

function api_active_rewardingback(request)

    local aname = 'rewardingBack'

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    --默认配置
    local defaultData = 0

    local uid = request.uid
    --领取奖励类型 login,gems,goods,updateTime
    local action = request.params.action

    if uid == nil then
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

    if mUseractive.info[aname].v then
        defaultData = mUseractive.info[aname].v
    end

    if defaultData == 0 then
        return response
    end

    local activeCfg = getConfig("active." .. aname )

    for type, vate in pairs(activeCfg.serverreward) do
        if not takeReward(uid, {[type] = math.floor(vate * defaultData)}) then
           return response
        end
    end

    mUseractive.info[aname].v = 0

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
