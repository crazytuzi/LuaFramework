-- 攻打副本的boss

function api_achallenge_battleboss(request)
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
    local hero   =request.params.hero  
    local equip = request.params.equip 

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end
    if moduleIsEnabled('fbboss') == 0 then
        response.ret = -17000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","worldboss","sequip"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')

    local bossCfg = getConfig('alliancebossCfg')
    if mUserinfo.level < bossCfg.levelLimite then
        response.ret = -17000
        return response
    end
    if mUserinfo.alliance <=0 then
        response.ret=-102
        return response
    end
    local fleetInfo = {}
    local num = 0
    for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
    end

    if num <= 0 then
        response.ret = -1
        return response
    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

     --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo,nil, equip) then
        response.ret = -5006
        return response
    end
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if type(hero)~='table' and hero==false then
            response.ret=-11016 
            return  response
        end
    end

    local challengeData,code = M_alliance.getChallenge{uid=uid}

    if type(challengeData) ~= 'table' then
        response.ret = code
        return response
    end

    local maxBattleN =4

    local vipAllianceFuben =getConfig('player.vipAllianceFuben')
    if type(vipAllianceFuben)=='table' then
        maxBattleN=vipAllianceFuben[mUserinfo.vip+1] or maxBattleN
    end
    if challengeData.akcount >= maxBattleN then
        response.ret = -8039
        return response
    end
    require "model.achallenge"
    local mChallenge = model_achallenge(uid)
    local boss= mChallenge.getBossInfo(bossCfg,mUserinfo.alliance)
    if boss[3]>=boss[2] then
        response.ret=-8300
        return response
    end
    local bossHp=boss[2] 

    local report,point = mChallenge.battleBoss(fleetInfo,hero,boss,equip)
    report.p = {{},{mUserinfo.nickname,mUserinfo.level,1,1}}
    local oldhp=boss[2]-boss[3]
    local toldieHp=boss[3]
    local addexp=0
    report.w = 0
    if point>0 then
        local tolHp,oldHp=mChallenge.addBossHp(mUserinfo.alliance,tonumber(point))
        oldhp=boss[2]-oldHp
        toldieHp=tolHp
        if oldHp > bossHp then
            response.ret=-8300
            return response
        end
        if tolHp > bossHp then
            point =point-(tolHp-bossHp)
            tolHp=bossHp
        end

        local PartAfter  = math.ceil((bossHp-tolHp) * 6 / bossHp )
        -- boss 死亡
        if PartAfter==0 then
            report.w = 1
            mChallenge.killBoss(mUserinfo.alliance)
            addexp=bossCfg.addexp
        end
    end   
    local ts    = getClientTs()
    local weeTs = getWeeTs()
    local allianceActive = getConfig("alliance.allianceActive")
    local allianceActivePoint = getConfig("alliance.allianceActivePoint")
    local apoint =allianceActivePoint[2]
    local apointcount =allianceActive[2]
    -- 保存关卡损失数据
    local setRet,code = M_alliance.setBoss{uid=uid,exp=addexp,weet=weeTs,ts=ts,ap=apoint,apc=apointcount}
    
    if not setRet then
        response.ret = code
        return response
    end
    local reward=copyTab(bossCfg.award)
    reward.userinfo_exp=math.floor(reward.userinfo_exp*point)

    if reward.userinfo_exp> bossCfg.expLimit then
        reward.userinfo_exp=bossCfg.expLimit
    end

    if reward.userinfo_exp<=0 then
        reward.userinfo_exp=nil
    end
    
    report.r = mChallenge.takeReward(reward)  -- 关卡奖励
      --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s306',1)
    mDailyTask.changeTaskNum1('s1010',1)
    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()
        local boss= mChallenge.getBossInfo(bossCfg,mUserinfo.alliance)
        boss[3]=toldieHp
        response.data.alliData = setRet.data
        response.data.allianceboss=boss
        response.data.allianceboss[5]=oldhp
        response.data.report = report
        response.ret = 0       
        response.msg = 'Success'
    end
    
    return response 

end