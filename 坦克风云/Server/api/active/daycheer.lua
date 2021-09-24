--
-- 天天爱助威
-- User: luoning
-- Date: 14-10-23
-- Time: 下午3:11
--

function api_active_daycheer(request)

    --活动名称
    local aname = 'dayCheer'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local step = request.params.step
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

    if not mUseractive.info[aname].m then
        mUseractive.info[aname].m = {}
    end

    --检查是否领奖
    if table.contains(mUseractive.info[aname].m, step) then
        response.ret = -402
        return response
    end

    local activeCfg =  getConfig("active." .. aname )
    if step > tonumber(mUseractive.info[aname].v) then
        response.ret = -1981
        return response
    end

    if not activeCfg.serverreward[step] then
        return response
    end

    local reward = activeCfg.serverreward[step]
    if not takeReward(uid, reward) then
        return response
    end

    table.insert(mUseractive.info[aname].m, step)
    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
        response.data.dayStep = step
    end

    return response
end

