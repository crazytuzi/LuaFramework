-- 重新集结部队
-- 需要结算，生成新的战报
-- 更新地块信息
function api_alliancewarnew_regroup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end

    local uid = tonumber(request.uid)
    local placeId = request.params.placeId  -- 地点
    local positionId = tonumber(request.params.positionId) -- 战场

    if uid == nil or placeId == nil or positionId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local mAllianceWar = require "model.alliancewarnew"

    -- 获取warid,验证战场是否开放
    local warId = mAllianceWar.getWarId(positionId)

    -- 已结束
    if mAllianceWar.getOverBattleFlag(warId) then
        response.ret = 0
        response.msg = 'Success'
        response.data.alliancewar.isover = 1
        return response
    end

    if mUserAllianceWar.bid ~= warId then
        response.ret = -4002
        response.err = {warId,mUserAllianceWar.bid}
        return response
    end

    -- 凌晨时间
    local weets = getWeeTs()

    -- 据点部队信息
    local positionFleet = mAllianceWar.getPlaceInfo(warId,placeId)

    -- 更新后的战场信息，差量推送给前台
    local positionInfo 

    -- 玩家占领此地块，重新集结
    if tonumber(positionFleet.oid) == uid then
        mAllianceWar.resetPosition(warId,placeId)

        -- 当前时间戳
        local ts = getClientTs()        

        -- 更新cd时间
        mUserAllianceWar.setCdTimeAt()

        -- 积分与贡献 ------------------------------------------------------------------

        local lastUpdateTs = tonumber(positionFleet.updated_at) or ts
        
        local defBuff = mUserAllianceWar.getBattleBuff()
        local defPoint = mAllianceWar.getPointByOccupiedTime(placeId,mUserAllianceWar.upgradeinfo,lastUpdateTs,ts)
        
        local defRaising = mAllianceWar.getDonateByOccupiedPoint(defPoint)
        mAllianceWar.addPoint(warId,mUserAllianceWar.rank,defPoint)

        -- send log ------------------------------------------------------------------

        local userbattlelog = {
            warId = warId,
            attacker = 1,
            defender = uid,
            attackerName = '',
            defenderName = mUserinfo.nickname,
            attackerAllianceId = 0,
            defenderAllianceId = mUserinfo.alliance or 0,
            attAllianceName = '',
            defAllianceName = mUserinfo.alliancename or "",
            attBuff = {},
            defBuff = defBuff,
            attPoint = 0,
            defPoint = defPoint,
            victor = 1,
            report = {},
            attRaising = 0,
            defRaising = defRaising,
            position = positionId,
            placeid = placeId,
        }

        local battlelog = json.encode({userbattlelog})        
        local addbattlelogRet, code = M_alliance.addbattlelog({method = 2,date=weets,data=battlelog})

        -- 记下Log
        mAllianceWar.writeLog({addbattlelogRet=tostring(addbattlelogRet),code=code,msg='regroup log',method = 2,date=weets,data=battlelog})

        -- 战场地块信息变更
        positionInfo = {[placeId]={}}

        -- push -------------------------------------------------
        local pushCmd = 'alliancewarnew.regroup.push'
        local pushData = {
            alliancewar = {
                positionInfo = positionInfo
            }
        }
        
        local allUsers = mAllianceWar.getAllianceWarUsers(warId)
        if type(allUsers) == 'table' then
            for _,uid in pairs(allUsers) do
                local mid = tonumber(uid)
                regSendMsg(mid,pushCmd,pushData)
            end
        end
        -- push -------------------------------------------------

    end

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()

        if positionInfo then
            response.data.alliancewar.positionInfo = positionInfo
        end

        response.data.useralliancewar = mUserAllianceWar.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
