function api_hchallenge_getreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sid = tonumber(request.params.sid) or 0
    local category = tonumber(request.params.category) or 1

    if (not uid) or sid == 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","troops", "props","bag","hchallenge"})
    local challenge = uobjs.getModel('hchallenge')
    local challengeRewardCfg = getConfig('hChallengeCfg.chapterReward')
    if not challengeRewardCfg[sid] then
        response.ret = -102
        return response
    end

    if type(challenge.info) ~= 'table' then
        challenge.info = {}
    end
    
    local chapterNum = getConfig("hChallengeCfg.chapterNum")
    local minSid = (sid - 1 ) * chapterNum + 1
    local maxSid = (sid) * chapterNum
    local allStars = challenge.info

    local totalStar = 0
    for i=minSid, maxSid do
        if allStars['s'..i] then
            totalStar = tonumber(allStars['s'..i]['s']) + totalStar
        end
    end

    if totalStar < challengeRewardCfg[sid]['content']['star'] then
        response.ret = -1981
        return response
    end

    if not challenge.reward['s'..sid] then
        challenge.reward['s'..sid] = {}
    end
    
    --是否已经领取奖励
    if challenge.reward['s'..sid] and challenge.reward['s'..sid] == 1 then
        response.ret = -1976
        return response
    end
    
    --标识已领取
    challenge.reward['s'..sid] = 1
    
    --发放奖励
    local rewardCfg = challengeRewardCfg[sid]['content']['serverreward']
    if next(rewardCfg) and not takeReward(uid, rewardCfg) then
        return response
    end

    if uobjs.save() then
        response.data.reward = formatReward(rewardCfg)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end

