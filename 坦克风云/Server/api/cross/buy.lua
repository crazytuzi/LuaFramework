--
-- 购买跨服战商品
-- User: luoning
-- Date: 14-10-9
-- Time: 下午4:50
--

function api_cross_buy(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local matchId = request.params.matchId
    --pShopItems, aShopItems
    local sType = request.params.sType
    local tId = request.params.tId

    if uid == nil or matchId == nil or tId == nil or sType == nil then
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

    --假如是精品商店，检查用户是否参赛
    if sType == 'aShopItems' and (not mMatches.checkJoinUser(mMatches.createJoinUserId(uid))) then
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','crossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)

    --刷新参赛用户积分
    if mMatches.checkJoinUser(mMatches.createJoinUserId(uid)) then
        mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId)
    end

    -- hwm 开红色配件后，商店配置切换为版本2
    if switchIsEnabled("ra") then
        sType = sType .. "2"
    
    -- 如果未打开开关，需要判断sType是不是普通版本
    elseif sType ~= "pShopItems" and sType ~= "aShopItems" then
        response.ret = -102
        return response
    end

    local sCfg = getConfig('serverWarPersonalCfg.'..sType)
    local shopItem = sCfg[tId]
    local limitNum = shopItem.buynum
    local reward = shopItem.serverReward
    local cost = shopItem.price

    --验证积分是否够用
    for type, num in pairs(reward) do
        if not mCrossinfo.usePoint(matchId, cost, tId, limitNum, type, num) then
            response.ret = mCrossinfo.errorCode
            return response
        end
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end
