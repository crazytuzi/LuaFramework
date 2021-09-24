--
-- 跨服战押注
-- User: luoning
-- Date: 14-9-28
-- Time: 下午3:14
--

function api_cross_bet(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    local detailId = request.params.detailId
    local joinUser = request.params.joinUser

    if uid == nil or matchId == nil or detailId == nil or joinUser == nil then
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

    if not mMatches.allowBet(detailId) then
        response.ret = mMatches.errorCode
        return response
    end

    if not mMatches.checkJoinUserByDid(joinUser, detailId) then
        response.ret = mMatches.errorCode
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)
    local crossCfg = getConfig('serverWarPersonalCfg')

    --检查用户是否可押注
    if not mCrossinfo.allowBet(mMatches, matchId, detailId, crossCfg) then
        response.ret = mCrossinfo.errorCode
        return response
    end

    --押注
    local res, gemCost, flowerNum = mCrossinfo.userBet(mMatches, matchId, detailId, joinUser, crossCfg)
    if not res then
        response.ret = mCrossinfo.errorCode
        return response
    end
    --消耗金币
    if gemCost >= 0 and not mUserinfo.useGem(gemCost) then
        return response
    end

    local tmpUser = joinUser:split('-')
    local params={bid=matchId, uid=tmpUser[1], zid=tmpUser[2], detailId=detailId, flowerNum=flowerNum}
    local data={cmd='crossserver.setuserbet', params=params}
    local config = getConfig("config.z"..getZoneId()..".cross")
    local flag = false
    -- 更新跨服数据库
    for i=1,5 do
        
        local ret=sendGameserver(config.host,config.port,data)
        if ret.ret==0 then
            flag=true
            break
        end
    end
    if not flag then
        writeLog("host=="..config.host..config.host.."data=="..json.encode(data),'setcrosserror')
        response.ret = -20020
        return response
    end
    -- 更新到缓存
    mMatches.updateBet2Cache(params)

    regActionLogs(uid,1,{action=42,item="",value=gemCost,params={did=detailId}})
    --天天爱助威活动
    activity_setopt(uid,"dayCheer",{})

    if uobjs.save() then
        response.msg = 'Success'
        response.data.gems = mUserinfo.gems
        response.ret = 0
    end

    return response
end
