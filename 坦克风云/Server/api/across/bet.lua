--
-- 跨服战押注
-- User: luoning
-- Date: 14-9-28
-- Time: 下午3:14
--

function api_across_bet(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    local detailId = request.params.detailId
    local aid = request.params.aid

    if uid == nil or matchId == nil or detailId == nil or aid == nil then
        response.ret = -102
        return response
    end

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()

    if not next(amMatchinfo) or amMatchinfo.bid ~= matchId then
        response.ret = -21001
        return response
    end

    --检查是否有正在进行的跨服战
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    if not mMatches.allowBet(detailId, aid) then
        response.ret = mMatches.errorCode
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'acrossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('acrossinfo')
    mCrossinfo.setMatchId(amMatchinfo.bid, amMatchinfo.et)
    local crossCfg = getConfig('serverWarTeamCfg')

    --检查用户是否可押注
    if not mCrossinfo.allowBet(mMatches, amMatchinfo.bid, detailId, crossCfg) then
        response.ret = mCrossinfo.errorCode
        return response
    end

    --押注
    local res, gemCost = mCrossinfo.userBet(mMatches, amMatchinfo.bid, detailId, aid, crossCfg)
    if not res then
        response.ret = mCrossinfo.errorCode
        return response
    end
    --消耗金币
    if gemCost >= 0 and not mUserinfo.useGem(gemCost) then
        return response
    end
    --todo 修改actionLog Id

    regActionLogs(uid,1,{action=52,im="",value=gemCost,params={did=detailId}})

    if uobjs.save() then
        response.msg = 'Success'
        response.data.gems = mUserinfo.gems
        response.ret = 0
    end

    return response
end
