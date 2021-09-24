--  攻击boss

function api_boss_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {worldboss={}},
    }
    
    local uid = request.uid
    local reborn  = request.params.reborn or 1
    local autoAttack = request.params.autoAttack

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('boss') == 0 then
        response.ret = -15000
        return response
    end
    local bossCfg = getConfig('bossCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
    local weet = getWeeTs()
    local ts = getClientTs()
    local gemCost=0
    local mTroop = uobjs.getModel('troops')
    local mWorldboss= uobjs.getModel('worldboss')

    if autoAttack then
        if not mWorldboss.checkAutoAttack() then
            response.ret = -102
            response.err = "checkAutoAttack failed"
            return response
        end
    else
        mWorldboss.bookAutoAttack(0)
    end

    if type(mWorldboss.binfo.t)~='table'  then   
        response.ret = -15005
        return response
    end 

    local time=bossCfg.opentime[2][1]*3600+bossCfg.opentime[2][2]*60
    local sttime=bossCfg.opentime[1][1]*3600+bossCfg.opentime[1][2]*60
    if ts >weet+time or ts <weet+sttime then
        response.ret = -15006 
        return response
    end

    local troops=mWorldboss.binfo.t
    local hero={}
    if type(mWorldboss.binfo.h)=='table' and next(mWorldboss.binfo.h) then
        hero=mWorldboss.binfo.h
    end

    local equip = nil
    if mWorldboss.binfo.se then
        equip = mWorldboss.binfo.se
    end
    local plane = nil
    if mWorldboss.binfo.plane then
        plane = mWorldboss.binfo.plane
    end

    local attack_at=mWorldboss.attack_at

    -- -2自动战斗每45秒一次，对定时做2秒的兼容
    local reBornTime = autoAttack and (bossCfg.autoRBTime-2) or bossCfg.reBornTime

    -- 是否在活着状态
    if attack_at+reBornTime>ts then

        if reborn==1 then
            local gemCost=bossCfg.reBorn
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
            regActionLogs(uid,1,{action=62,item="",value=gemCost,params={}})
        else
            response.ret = -15004
            return response
        end
    end

    -- 清楚积分和buff
    if weet>mWorldboss.attack_at then
        mWorldboss.point=0
    end
    if weet>mWorldboss.buy_at then
       -- mWorldboss.info.b=nil
        mWorldboss.buy_at =weet
    end
    --获取boss信息
    local boss= mWorldboss.getBossInfo(bossCfg)
    if boss[3]>=boss[2] then
        response.ret=-15005
        return response
    end
    local bossHp=boss[2] 

    local report,point = mWorldboss.battle(troops,hero,boss,equip,plane)
    report.p = {{},{mUserinfo.nickname,mUserinfo.level,1,1}}
    local oldhp=boss[2]-boss[3]
    local toldieHp=boss[3]
    if point>0 then
        local tolHp,oldHp=mWorldboss.addBossHp(tonumber(point))
        oldhp=boss[2]-oldHp
        toldieHp=tolHp
        if oldHp > bossHp then
            response.ret=-15005
            return response
        end
        if tolHp > bossHp then
            point =point-(tolHp-bossHp)
            tolHp=bossHp
        end
        -- 计算谁击杀的 然后存起来
        local PartBefore = math.ceil((bossHp-oldHp) * 6  / bossHp)
        local PartAfter  = math.ceil((bossHp-tolHp) * 6 / bossHp )
        local Part = PartBefore - PartAfter

        -- 击杀了
        if Part>0 then
            if type (mWorldboss.info.k)~='table' then  mWorldboss.info.k={}  end 
            -- 一次击杀了多个炮头
            if Part>1 then
                for i=1,Part do
                    if PartAfter==0 then
                        local flag=table.contains(mWorldboss.info.k, 6)
                        if flag then
                            table.insert(mWorldboss.info.k,1)
                        else
                            mWorldboss.killBoss()
                            table.insert(mWorldboss.info.k,6)
                        end
                    else
                        table.insert(mWorldboss.info.k,1)
                    end
                end
            else --一次只击杀一个炮头
                -- 击杀的最后一个炮头
                if PartAfter==0 then
                    mWorldboss.killBoss()
                    table.insert(mWorldboss.info.k,6)
                else
                    table.insert(mWorldboss.info.k,1)
                end
            end
           
        end

        mWorldboss.point=mWorldboss.point+point
        mWorldboss.addAttackBossRank(uid,mWorldboss.point)

    end

    mWorldboss.info.boss={boss[1],boss[2]}
    mWorldboss.attack_at=ts
    if uobjs.save() then
        response.data.worldboss = mWorldboss.toArray(true)
        local boss= mWorldboss.getBossInfo(bossCfg)
        boss[3]=toldieHp
        response.data.worldboss.boss=boss
        response.data.worldboss.boss[5]=oldhp
        response.data.report = report
        response.ret = 0       
        response.msg = 'Success'
    end
    
    return response 
end