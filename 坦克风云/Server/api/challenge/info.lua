--
-- 获取关卡掉落信息
-- User: luoning
-- Date: 15-1-6
-- Time: 上午11:38
--
function api_challenge_info(request)

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

    local challengeInfo = {
        reward={u={{exp=5,index=1},{honors=5,index=2}}},
        pool={},
        tank={{},{},{},{},{},{}, },
    }

    local challengeConfig = getConfig("challenge")
    if not challengeConfig[cId] then
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge"})
    local challenge = uobjs.getModel('challenge')
    local mUserinfo = uobjs.getModel('userinfo')

    local clientReward = challenge.takeReward(challengeConfig[cId].reward, nil, true, cId)

    challengeInfo.reward.u[1].exp = tonumber(clientReward.u.exp) or 0
    challengeInfo.reward.u[2].honors = tonumber(clientReward.u.honors) or 0
    challengeInfo.tank = challengeConfig[cId].tank
    local poolReward = clientReward.p
    local tmpReward = {}
    for i,v in pairs(poolReward) do
        table.insert(tmpReward, {i,v})
    end

    table.sort(tmpReward, function(a, b)
        local tmpa = tonumber(string.sub(a[1], 2)) or 0
        local tmpb = tonumber(string.sub(b[1], 2)) or 0
        if tmpa < tmpb then
            return true
        end
        return false
    end)

    for i,v  in pairs(tmpReward) do
        if not challengeInfo.pool.p then
            challengeInfo.pool.p = {}
        end
        local tmpReward = {}
        tmpReward[v[1]] = v[2]
        tmpReward["index"] = i
        table.insert(challengeInfo.pool.p, tmpReward)
    end
    response.msg = "Success"
    response.ret = 0
    response.data.challengeInfo = challengeInfo
    return response
end

