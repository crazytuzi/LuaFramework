--
-- 跨服战押注
-- User: lmh
-- Date: 14-9-28
-- Time: 11:50
--

function api_worldwar_bet(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    local detailId = request.params.detailId
    local joinUser = request.params.joinUser
    local jointype = request.params.jointype or 1

    if uid == nil or matchId == nil or detailId == nil or joinUser == nil then
        response.ret = -102
        return response
    end
    --检查比赛是否可押注
    require "model.wmatches"
    local mMatches = model_wmatches()

    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end
    
    mMatches.getMultInfo(jointype)
    if not mMatches.allowBet(detailId,jointype) then
        response.ret = mMatches.errorCode
        return response
    end
    
    if not mMatches.checkJoinUserByDid(joinUser, detailId,jointype) then
        response.ret = mMatches.errorCode
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','wcrossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et,jointype)
    local crossCfg = getConfig('worldWarCfg')
    --检查用户是否可押注
    if not mCrossinfo.allowBet(mMatches, matchId, detailId, crossCfg,jointype) then
        response.ret = mCrossinfo.errorCode
        return response
    end
    --押注 jointype 精英or大师
    local res, gemCost = mCrossinfo.userBet(mMatches, matchId, detailId, joinUser, crossCfg,jointype)
    if not res or gemCost==nil then
        response.ret =-22013
        return response
    end
    --消耗金币
    if gemCost >= 0 and not mUserinfo.useGem(gemCost) then
        return response
        
    end
    if gemCost>0 then
        regActionLogs(uid,1,{action=69,item="",value=gemCost,params={}})
    end
    --天天爱助威活动
    --activity_setopt(uid,"dayCheer",{})

    if uobjs.save() then
        response.msg = 'Success'
        response.data.gems = mUserinfo.gems
        response.ret = 0
    end

    return response
end
