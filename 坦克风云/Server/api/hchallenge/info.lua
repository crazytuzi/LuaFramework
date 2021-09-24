--
-- 获取关卡掉落信息
-- User: luoning
-- Date: 15-1-6
-- Time: 上午11:38
--
function api_hchallenge_info(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local cId = tonumber(request.params.cid) or 0

    if uid == nil or cId == 0 then
        return response
    end

    local challengeConfig = getConfig("hChallengeCfg.list")
    if not challengeConfig[cId] then
        return response
    end

    local challengeInfo = {
        reward = challengeConfig[cId].clientReward,
        tank = challengeConfig[cId].tank
    }

    response.msg = "Success"
    response.ret = 0
    response.data.hchallengeInfo = challengeInfo
    return response
end

