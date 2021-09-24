--
-- 领取最后的排名奖励
-- User: luoning
-- Date: 14-10-16
-- Time: 下午9:51
--

function api_across_getrankingreward(request)

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

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()

    if not next(amMatchinfo) then
        response.ret=-21001
        return response
    end

    --检查比赛是否可押注
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'acrossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('acrossinfo')

    local prepareTime = getConfig('serverWarTeamCfg.preparetime')
    local limitTime = amMatchinfo.st + prepareTime * 24 * 3600

    local joinAtData = M_alliance.getuseralliance{uid=uid,aid=aid}
    local joinAt = 0
    if type(joinAtData) == 'table' and joinAtData['ret'] == 0 then
        joinAt = tonumber(joinAtData['data']['join_at']) or 0
    end

    if joinAt == 0 or joinAt >= limitTime then
        response.ret = -1981
        return response
    end

    --检查是否发送区服邮件
    local rankData = mMatches.getRankInfo()
    local tmpAid = getZoneId()..'-'..mUserinfo.alliance

    local reward = 0
    if rankData[tmpAid] and rankData[tmpAid][1] ~= 0 then

        local crossCfg = getConfig('serverWarTeamCfg')
        local rankCfg = crossCfg.rankReward
        for _, v in pairs(rankCfg) do
            if v['range'][1] <= rankData[tmpAid][1] and rankData[tmpAid][1] <= v['range'][2] then
                reward = v['point']
                break
            end
        end
    end

    if reward == 0 then
        response.ret = -21117
        return response
    end


    mCrossinfo.setMatchId(amMatchinfo.bid, amMatchinfo.et)
    if not mCrossinfo.addRankingPoint(amMatchinfo.bid, reward, rankData[tmpAid][1]) then
        response.ret = mCrossinfo.errorCode
        return response
    end

    if uobjs.save() then
        response.msg = "Success"
        response.ret = 0
    end

    return response
end

