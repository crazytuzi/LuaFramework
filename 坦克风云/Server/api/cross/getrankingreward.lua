--
-- 领取最后的排名奖励
-- User: luoning
-- Date: 14-10-16
-- Time: 下午9:51
--

function api_cross_getrankingreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil  then
        response.ret = -102
        return response
    end

    --检查比赛是否可押注
    require "model.matches"
    local mMatches = model_matches()

    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    --检查是否发送区服邮件
    if next(mMatches.ranking) and not mMatches.checkAllUser() then
        mMatches.getAllUserReward()
    end

    local tmpUid = mMatches.createJoinUserId(uid)
    if not mMatches.getRankInfo() then
        response.ret = mMatches.errorCode
        return response
    end

    local rankData = mMatches.formatRanking()
    local reward = 0
    if rankData[tmpUid] and rankData[tmpUid] ~= 0 then

        local crossCfg = getConfig('serverWarPersonalCfg')
        local rankCfg = crossCfg.rankReward
        for _, v in pairs(rankCfg) do
            if v['range'][1] <= rankData[tmpUid] and rankData[tmpUid] <= v['range'][2] then
                reward = v['point']
                break
            end
        end
    end

    if reward == 0 then
        response.ret = -20017
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)
    if not mCrossinfo.addRankingPoint(mMatches.base.matchId, reward, rankData[tmpUid]) then
        response.ret = mMatches.errorCode
        return response
    end
    mCrossinfo.recordRanking(mMatches, rankData[tmpUid])
    if uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

