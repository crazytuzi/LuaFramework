--
-- 新手军饷
-- User: luoning
-- Date: 14-8-26
-- Time: 上午11:54
--
function api_active_holdground1(request)

    local aname = 'holdGround1'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    --签到1,7
    local num = tonumber(request.params.num) or 1

    if uid == nil or num == nil  then
        response.ret = -102
        return response
    end

    local checkGetReward = function(oldNum, newNum)

        if newNum < 1 or newNum > 7 then
            return false
        end
        if (newNum - oldNum) ~= 1 then
            return false
        end
        return true
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local weeTs = getWeeTs()


    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg =  getConfig("active." .. aname )
    local serverReward = activeCfg.serverreward
    local oldNum = mUseractive.info[aname].v and mUseractive.info[aname].v or 0
    --签到顺序
    if not checkGetReward(oldNum, num) then
        response.ret = -102
        return response
    end
    --每日领取
    local oldTime = mUseractive.info[aname].t and mUseractive.info[aname].t or 0
    if oldTime >= weeTs then
        response.ret = -302
        return response
    end

    local reward = serverReward[num] and serverReward[num] or nil

    if reward == nil then
        response.ret = -102
        return response
    end

    mUseractive.info[aname].v = num
    mUseractive.info[aname].t = weeTs
    --增加奖励
    if not takeReward(uid, reward) then
        return response
    end

    if uobjs.save() then
        response.data[aname].num = num
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

