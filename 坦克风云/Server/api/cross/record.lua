--
-- 商店购买记录
-- User: luoning
-- Date: 14-10-16
-- Time: 下午12:40
--
function api_cross_record(request)

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

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)

    --刷新参赛用户积分
    if mMatches.checkJoinUser(mMatches.createJoinUserId(uid)) then
        mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId)
    end

    local record = mCrossinfo.getPointRecord(mMatches.base.matchId)
    response.data.record = record
    response.ret = 0
    response.msg = 'Success'
    return response
end

