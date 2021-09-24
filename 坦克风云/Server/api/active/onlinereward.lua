--
-- 在线送好礼
-- User: luoning
-- Date: 14-12-19
-- Time: 下午4:23
--
function api_active_onlinereward(request)

    -- 活动名称，莫斯科赌局
    local aname = 'onlineReward'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local category = tonumber(request.params.category)

    if uid == nil or type(category) ~= "number" or category < 1 then
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

    local activeCfg =  getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local rewardlength = #activeCfg.oward
    local weelTs = getWeeTs()
    if type(mUseractive.info[aname].v) ~= "table" or mUseractive.info[aname].t < weelTs then
        mUseractive.info[aname].v = {}
        for i=1, rewardlength do
            table.insert(mUseractive.info[aname].v, {0,0,0})
        end
        mUseractive.info[aname].t = weelTs
    end

    if category > 1 then

        if not mUseractive.info[aname].v[category-1]
                or mUseractive.info[aname].v[category-1][1] == 0
        then
            response.ret = -1981
            return response
        end

        if mUseractive.info[aname].v[category][1] == 1 then
            response.ret = -401
            return response
        end
        local ts = getClientTs()
        local diffts = ts - mUseractive.info[aname].v[category-1][2]

        local needTs = activeCfg.oward[category].t - activeCfg.oward[category-1].t
        needTs = needTs - 10
        if diffts < needTs then
            response.ret = -1981
            return response
        end

        local reward = activeCfg.oward[category].serverReward
        if not takeReward(uid, reward) then
            return response
        end

        mUseractive.info[aname].v[category][1] = 1
        mUseractive.info[aname].v[category][2] = ts
        mUseractive.info[aname].v[category][3] = 0
    elseif category == 1 then

        if mUseractive.info[aname].v[category][1] == 1 then
            response.ret = -401
            return response
        end
        local ts = getClientTs()
        mUseractive.info[aname].v[category][1] = 1
        mUseractive.info[aname].v[category][2] = ts
        mUseractive.info[aname].v[category][3] = 0

        local reward = activeCfg.oward[category].serverReward
        if not takeReward(uid, reward) then
            return response
        end

    else
        return response
    end

    response.data[aname].rewardinfo = mUseractive.info[aname].v

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end
