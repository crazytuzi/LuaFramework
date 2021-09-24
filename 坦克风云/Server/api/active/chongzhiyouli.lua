--
-- 充值有礼活动
-- User: luoning
-- Date: 15-3-3
-- Time: 上午11:14
--
function api_active_chongzhiyouli(request)

    -- 活动名称，莫斯科赌局
    local aname = 'chongzhiyouli'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    require "model.active"
    local mActive = model_active()
    --自定义配置文件
    local activeCfg = mActive.selfCfg(aname)

    local weelTs = getWeeTs()
    if mUseractive.info[aname].t < weelTs then
        mUseractive.info[aname].v = 0
        mUseractive.info[aname].t = weelTs
    end

    if type(mUseractive.info[aname].v) ~= "number" then
        mUseractive.info[aname].v = 0
    end

    if mUseractive.info[aname].v < activeCfg.addGemCondition or mUseractive.info[aname].v <= 0 then
        response.ret = -1981
        return response
    end

    if not mUseractive.info[aname].n then
        mUseractive.info[aname].n = 0
    end

    if mUseractive.info[aname].n >= weelTs then
        response.ret = -401
        return response
    end

    mUseractive.info[aname].n = weelTs

    local reward = {userinfo_gems=activeCfg.addGemsNum }
    if not takeReward(uid, reward) then
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

