--
-- 领取关卡奖励
-- User: luoning
-- Date: 14-9-15
-- Time: 下午4:22
--

function api_challenge_getreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sid = tonumber(request.params.sid) or 0
    local category = tonumber(request.params.category) or 0

    if (not uid) or sid == 0 or (category == 0 or category > 3)then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge"})
    local challenge = uobjs.getModel('challenge')
    local challengeRewardCfg = getConfig('challengeReward')
    if not challengeRewardCfg[sid] then
        response.ret = -102
        return response
    end

    local reward = challenge.reward
    if type(reward) ~= 'table' then
        reward = {}
    end
    local minSid = (sid - 1 ) * 16 + 1
    local maxSid = (sid) * 16
    local allStars = challenge.info

    local totalStar = 0
    for i=minSid, maxSid do
        if allStars['s'..i] then
            totalStar = tonumber(allStars['s'..i]['s']) + totalStar
        end
    end

    if totalStar < challengeRewardCfg[sid]['content'][category]['star'] then
        response.ret = -1981
        return response
    end

    if not reward['s'..sid] then
        reward['s'..sid] = {0,0,0}
    end
    --是否已经领取奖励
    if reward['s'..sid][category] == 1 then
        response.ret = -1976
        return response
    end
    --标识已领取
    reward['s'..sid][category] = 1
    --发放奖励
    local logreward = {}
    if category == 1 or category == 2 then
        local rewardCfg = challengeRewardCfg[sid]['content'][category]['serverreward']
        if next(rewardCfg) and not takeReward(uid, rewardCfg) then
            return response
        end
        logreward=rewardCfg
    end
    challenge.reward = reward
    --刷新战斗力
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

