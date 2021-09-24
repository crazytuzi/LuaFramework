--
-- 领取押注奖励
-- User: lmh
-- Date: 15-03-30
-- Time: 下午4:45
--
function api_worldwar_getbetreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    local detailId = request.params.detailId
    local jointype =request.params.jointype or 1 
    if uid == nil or matchId == nil or detailId == nil then
        response.ret = -102
        return response
    end

    --检查是否有正在进行的跨服战
   
    require "model.wmatches"
    local mMatches = model_wmatches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end


    --检查进行的比赛是否为同一场
    if not mMatches.isMatch(matchId) then
        response.ret = mMatches.errorCode
        return response
    end

   
    mMatches.getMultInfo(jointype)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','wcrossinfo'})
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et,jointype)
    local crossCfg = getConfig('worldWarCfg')
    if not mCrossinfo.getBetReward(mMatches, matchId, detailId, crossCfg,jointype) then
        response.ret = mCrossinfo.errorCode
        return response
    end
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end

