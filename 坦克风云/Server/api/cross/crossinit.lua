--
-- 跨服战信息接口
-- User: luoning
-- Date: 14-9-28
-- Time: 下午3:35
--

function api_cross_crossinit(request)

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

    require "model.matches"

    local mMatches = model_matches()
    if not next(mMatches.base) then
        response.ret = -1
        return response
    end
    --普通商店
    local shoplist = {'pShopItems' }
    --参赛用户可以在精品商店购买物品
    if mMatches.checkJoinUser(mMatches.createJoinUserId(uid)) then
        table.insert(shoplist, 'aShopItems')
    end
    --修复参战数据
    if mMatches.repairFlag then
        mMatches.reparisUserData()
    end

    --检查是否发送区服邮件
    if next(mMatches.ranking) and not mMatches.checkAllUser() then
        mMatches.getAllUserReward()
    end

    --获取用户的积分信息
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)

    --刷新参赛用户积分
    if mMatches.checkJoinUser(mMatches.createJoinUserId(uid)) then
        mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId)
    end

    local point = mCrossinfo.getPointInfo(mMatches.base.matchId)
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
        if point.point[mMatches.base.matchId].rc then
            if point.point[mMatches.base.matchId].rc.buy then
                point.point[mMatches.base.matchId].rc.buy = nil
            end
            if point.point[mMatches.base.matchId].rc.add then
                point.point[mMatches.base.matchId].rc.add = nil
            end
        end
        point.point.battle = nil
        response.data.winner = mMatches.getWinnerInfo()
        response.data.point = point.point
        response.data.bet = point.bet
        response.data.st = tonumber(mMatches.base.st)
        response.data.et = tonumber(mMatches.base.et)
        local servers = json.decode(mMatches.base.servers)
        response.data.servers = type(servers) == 'table' and servers or {}
        response.data.matchId = mMatches.base.matchId
        response.data.crossuser = mMatches.userinfo
        response.data.shoplist = shoplist
    end

    return response
end
