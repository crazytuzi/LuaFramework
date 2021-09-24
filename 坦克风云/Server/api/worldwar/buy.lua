--
-- 购买跨服战商品
-- User: lmh
-- Date: 15-03-30
-- Time: 14:50
--

function api_worldwar_buy(request)

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
    local jointype =request.params.jointype or 0
    if uid == nil or tId == nil or sType == nil then
        response.ret = -102
        return response
    end

    local zoneid=request.zoneid
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
        --世界大战基本信息
    local mMatchinfo= mServerbattle.getWorldWarBattleInfo()
    if not next(mMatchinfo)  then
        return response
    end
    local ts =getClientTs()
    --检查是否有正在进行的跨服战
    require "model.wmatches"
    local mMatches = model_wmatches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end
    local worldserver = require "model.worldserverin"
    local cross = worldserver.new()
    local ApplyData =cross:getUserApplyData(mMatchinfo.bid,zoneid,uid)
    
    --假如是精品商店，检查用户是否参赛

    if sType == 'aShopItems' and (type (ApplyData)~='table'  or not next(ApplyData)) then
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive','wcrossinfo'})
    local mCrossinfo = uobjs.getModel('wcrossinfo')
    mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et,jointype)
    if jointype>0 then
        --刷新参赛用户积分
        mMatches.getMultInfo(jointype)
        if mMatches.checkJoinUser(uid,jointype) then
            mCrossinfo.bindJoinPoint(mMatches, mMatches.base.matchId,jointype)
        end
    end

    -- hwm 开红色配件后，商店配置切换为版本2
    if switchIsEnabled("ra") and sType == "aShopItems" then
        sType = sType .. "2"
    
    -- 如果未打开开关，需要判断sType是不是普通版本
    elseif sType ~= "pShopItems" and sType ~= "aShopItems" then
        response.ret = -102
        return response
    end
   
    local sCfg = getConfig('worldWarCfg.'..sType)
    local shopItem = sCfg[tId]
    local limitNum = shopItem.buynum
    local reward = shopItem.serverReward
    local cost = shopItem.price

    --验证积分是否够用
    if not mCrossinfo.usePoint(matchId, cost, tId, limitNum, type, num,sType,0) then
        response.ret = mCrossinfo.errorCode
        return response
    end
    
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end
