--
-- 积分和押注初始化信息
-- User: luoning
-- Date: 14-12-3
-- Time: 下午3:04
--

function api_across_betpointinfo(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid

    if uid == nil then
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

    --检查是否有正在进行的跨服战
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    --检查数据信息
    local getRewardAll = amMatchinfo.reward
    getRewardAll = json.decode(getRewardAll)
    if type(getRewardAll) ~= "table" then
        getRewardAll = {}
    end
    --检测发送全服邮件
    local rankInfo = mMatches.getRankInfo()
    if next(rankInfo) and not getRewardAll[amMatchinfo.bid] then
        local apiFile = "api.across.winmail"
        require (apiFile)
        api_across_winmail()
        writeLog(uid .. " get winmail reward" .. amMatchinfo.bid, "across")
    end

    --获取用户的积分信息
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'acrossinfo'})
    local mUserinfo = uobjs.getModel('userinfo')
    local mCrossinfo = uobjs.getModel('acrossinfo')
    mCrossinfo.setMatchId(amMatchinfo.bid, amMatchinfo.et)

    if mMatches.checkJoinUser(uid, mUserinfo.alliance) then
        mCrossinfo.bindJoinPoint(mMatches, amMatchinfo.bid, mUserinfo.alliance)
    end

    local point = mCrossinfo.getPointInfo(amMatchinfo.bid)

    if uobjs.save() then

        response.ret = 0
        response.msg = 'Success'
        if point.point[amMatchinfo.bid].rc then
            if point.point[amMatchinfo.bid].rc.buy then
                point.point[amMatchinfo.bid].rc.buy = nil
            end
            if point.point[amMatchinfo.bid].rc.add then
                point.point[amMatchinfo.bid].rc.add = nil
            end
        end
        response.data.point = point.point
        response.data.bet = point.bet
    end

    return response
end

