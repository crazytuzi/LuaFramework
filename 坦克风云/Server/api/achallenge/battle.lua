-- 无论输赢，都有奖励，经验为userinfo_exp * 当前杀敌数目
-- 战斗胜利，军团才有经验加成
--军团副本
function api_achallenge_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 攻防双方id
    local attackerId = request.uid
    local defenderId = math.abs(request.params.defender or 0)
    local useProps = request.params.use or {} --p17 减敌方10%的血，p18第一回合全部MISS
    local hero   =request.params.hero 
    local equip = request.params.equip 
    if not attackerId or defenderId <= 0 then
        response.ret = -102
        return response
    end

    
    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
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
       
    local uobjs = getUserObjs(attackerId)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})    
    require "model.achallenge"
    local mChallenge = model_achallenge(attackerId)
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mUseractive = uobjs.getModel('useractive')
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    
   --check hero
   local herofeat=false
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if type(hero)~='table' and hero==false then
            response.ret=-11016 
            return  response
        end
        herofeat=true
    end

    -- end 

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

    if mUserinfo.alliance <= 0 then
        response.ret = -8012
        return response
    end

    -- 道具使用
    if type(useProps) == 'table' then
        local mBag = uobjs.getModel('bag')
        for k,v in pairs(useProps) do
            if not mBag.use(k,v) then
                response.ret = -1996
                return response
            end
        end
    end

    local challengeData,code = M_alliance.getChallenge{uid=attackerId}

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

    -- 关卡是否解锁
    if not mChallenge.checkUnlock(defenderId,challengeData.barrier.maxbid) then
        response.ret = -6001
        response.msg = "challenge not unlock"
        return response
    end

    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end
    local allchallengeCfg = getConfig('allianceChallengeCfg')
    local bosschallenge=#allchallengeCfg
    local challengeCfg = allchallengeCfg[defenderId]
    local defFleetInfo,totalTroops = mChallenge.getCurrentChallengeTroops(challengeCfg.tank,challengeData.barrier['b'..defenderId])

    local totalTroops = 0
    for k,v in ipairs(defFleetInfo or {}) do
        if v[2] and v[2] > 0 then
            totalTroops = v[2]
            break
        end
    end

    if totalTroops <= 0 then
        response.ret = -8040
        return response
    end

    local report,dInvalidFleet,star,isWin = mChallenge.battle(fleetInfo,defFleetInfo,challengeCfg,useProps,hero,equip)

    local dieTroops = mChallenge.damageTroops(defFleetInfo,dInvalidFleet)
    local reward = mChallenge.getBattleReward(challengeCfg.award,dieTroops)
    
    report.r = mChallenge.takeReward(reward)  -- 关卡奖励
    report.w = isWin

    local allianceExp = 0
    local acfbReward

    if isWin == 1 then
        allianceExp = challengeCfg.AllianceExp
        report.r.a = {aexp=allianceExp}

        if mUseractive.getActiveStatus('fbReward',true) == 1 then
            acfbReward = 1
        end
        --将领授勋
        if defenderId==bosschallenge then
            if herofeat then
                mHero.refreshFeat("t4",hero,1)
            end
        end
    end
    
    local ts    = getClientTs()
    local weeTs = getWeeTs()
    local allianceActive = getConfig("alliance.allianceActive")
    local allianceActivePoint = getConfig("alliance.allianceActivePoint")
    local apoint =allianceActivePoint[2]
    local apointcount =allianceActive[2]
    -- 保存关卡损失数据
    local setRet,code = M_alliance.setChallenge{uid=attackerId,bid=defenderId,data=json.encode(dieTroops),kill=isWin,exp=allianceExp,ac=acfbReward,addcount=adddonatecount,weet=weeTs,ts=ts,ap=apoint,apc=apointcount}
    
    if not setRet then
        response.ret = code
        return response
    end

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s306',1)
    mDailyTask.changeTaskNum1('s1010',1)
        
    -- local mTask = uobjs.getModel('task')
    -- mTask.check()

    if not report then
        response.ret = -311
        response.msg = "battle error"
        return response
    end

    -- push -------------------------------------------------
   local data = {['b'..defenderId] = dieTroops,w=isWin}    

    local mems = M_alliance.getMemberList{uid=uid,aid=mUserinfo.alliance}
    if mems then
        for _,v in pairs( mems.data.members) do
                regSendMsg(v.uid,'alliance.challenge',data)
        end
    end
    -- push -------------------------------------------------    

    -- regActionLogs(attackerId,2,{action=4,item=defenderId,value=star,params={c=challenge.star}})

    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()

        response.data.alliData = setRet.data
        response.data.report = report
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
