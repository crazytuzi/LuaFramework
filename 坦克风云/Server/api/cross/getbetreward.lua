--
-- 领取押注奖励
-- User: luoning
-- Date: 14-10-10
-- Time: 下午4:45
--
function api_cross_getbetreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    local detailId = request.params.detailId

    if uid == nil or matchId == nil or detailId == nil then
        response.ret = -102
        return response
    end

    --检查是否有正在进行的跨服战
    require "model.matches"
    local mMatches = model_matches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    --检查进行的比赛是否为同一场
    if not mMatches.isMatch(matchId) then
        response.ret = mMatches.errorCode
        return response
    end

    --检查是否发送区服邮件
    if next(mMatches.ranking) and not mMatches.checkAllUser() then
        mMatches.getAllUserReward()
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)
    local crossCfg = getConfig('serverWarPersonalCfg')

    if not mCrossinfo.getBetReward(mMatches, matchId, detailId, crossCfg, st) then
        response.ret = mCrossinfo.errorCode
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end

