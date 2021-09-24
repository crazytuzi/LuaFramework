-- 重新集结部队
-- 需要结算，生成新的战报
-- 返还用户部队
-- 更新地块信息
function api_alliancewar_regroup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end

    local uid = tonumber(request.uid)
    local placeId = tonumber(request.params.placeId)  -- 地点
    local positionId = tonumber(request.params.positionId) -- 战场

    if uid == nil or placeId == nil or positionId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local mTroop = uobjs.getModel('troops')
    local mHero  = uobjs.getModel('hero')
    local mAllianceWar = require "model.alliancewar"

    -- 获取warid,验证战场是否开放
    local warId = mAllianceWar:getWarId(positionId)
    if not warId then
        response.ret = -4002
        return response
    end

    -- 凌晨时间
    local weets = getWeeTs() 

    -- 验证aid是否报名
    local queueInfo, code = M_alliance.getmembequeue{uid=uid,aid=mUserinfo.alliance,position=positionId,date=weets,warId=warId}
    if not queueInfo then
        response.ret = code
        return response
    end

    local label = {}  -- 红蓝标识
    for k,v in pairs(queueInfo.data) do
        local tmpAid = tonumber(v.aid)
        label[tmpAid] = v.rank
    end

    -- 据点部队信息
    local positionFleet = mAllianceWar:getPlaceInfo(positionId,placeId,warId)

    -- 更新后的战场信息，差量推送给前台
    local positionInfo 
    
    -- 玩家占领此地块，重新集结
    if tonumber(positionFleet.oid) == uid then
        -- 部队撤离失败
        if not mAllianceWar:resetPosition(positionId,placeId,warId) then
            response.ret = -4009    
            return response
        end

        -- 重新刷下积分
        mAllianceWar:getAllPlacePoint(positionId,true,warId)

        -- 当前时间戳
        local ts = getClientTs()        

        -- 更新cd时间
        mUserAllianceWar.setCdTimeAt()

        -- 积分与贡献 ------------------------------------------------------------------

        local lastUpdateTs = tonumber(positionFleet.updated_at) or ts
        
        local defBuff = mUserAllianceWar.getBattleBuff()
        local defPoint = mAllianceWar:getPointByOccupiedTime(positionId,placeId,mUserAllianceWar.upgradeinfo,lastUpdateTs,ts)
        
        local defRaising = mAllianceWar:getDonateByOccupiedTime({},defPoint,defBuff)
       
        if not mAllianceWar:addPoint(positionId,label[mUserinfo.alliance],defPoint,warId) then
            mAllianceWar:writeLog({msg="regroup addPoint failed",point=defPoint,aid=mUserinfo.alliance,warId=warId})
        end


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
        mAllianceWar:writeLog({msg='regroup log',method = 2,date=weets,data=battlelog})
        if not addbattlelogRet then
            mAllianceWar:writeLog({msg="regroup log failed",battlelog=battlelog})
        end

        -- 战场地块信息变更
        positionInfo = {['h'..placeId]={}}

        -- push -------------------------------------------------
        local pushCmd = 'alliancewar.regroup.push'
        local pushData = {
            alliancewar = {
                positionInfo = positionInfo
            }
        }
        
        for _,v in pairs(queueInfo.data) do
            if type(v.members) == 'table' then
                for _,n in pairs(v.members) do
                    local mid = tonumber(n.uid)
                    if mid then
                        regSendMsg(mid,pushCmd,pushData)
                    end
                end
            end
        end
        -- push -------------------------------------------------

    end
    
    -- 更新战斗部队
    mTroop.updateAllianceWarTroops(true)

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()

        if positionInfo then
            response.data.alliancewar.positionInfo = positionInfo
        end

        response.data.useralliancewar = mUserAllianceWar.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.hero={}
        response.data.hero.stats=mHero.stats
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
