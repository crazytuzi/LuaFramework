-- 战斗 精英关卡  补给线
-- 战斗不损兵
function api_echallenge_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {echallengebattle={}},
    }

    -- 开关检测
    if moduleIsEnabled('ec')== 0 then
        response.ret = -6004
        return response
    end

    -- 攻防双方id
    local attackerId = request.uid
    local defenderId = request.params.defender

    -- ------------------------------------------------
    -- p17 (空中支援) 减敌方10%的血
    -- p18 (电磁干扰) 第一回合全部MISS
    ---------------------------------------------------
    local useProps = request.params.use or {} 
    local hero   =request.params.hero  
    local equip = request.params.equip
    -- 参数检测
    if not attackerId or not defenderId then
        response.ret = -102
        return response
    end

    -- 兵力检测、初始化格式
    local fleetInfo = {}
    local num = 0
    for m,n in pairs(request.params.fleetinfo or {}) do
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
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","echallenge","accessory","useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mChallenge = uobjs.getModel("echallenge")
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')    
    local mAccessory = uobjs.getModel('accessory')
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    
    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
       
    end

    -- end 

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
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

    -- 关卡是否解锁
    if not mChallenge.checkUnlock(defenderId,mUserinfo.level) then
        response.ret = -6001
        return response
    end
    
    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end
    
    local weeTs = getWeeTs()
    if (mChallenge.reset_at or 0) < weeTs then
        mChallenge.reset(weeTs)
    end

    -- 本日精英关卡已被攻破
    if mChallenge.dailykill[defenderId] then
        response.ret = -6006
        return response
    end

    --使用能量,只有非重置的时间才需要消耗能量
    if mChallenge.resetnum == 0 and not mUserinfo.useEnergy(1) then
        response.ret = -2001        
        return response
    end

    -- 配置
    local challengeCfg = getConfig('eliteChallengeCfg.challenge.'..defenderId)
    local defFleetInfo = challengeCfg.tank

    if not defFleetInfo then
        return response
    end
    
    if not mAccessory.getAddAccessoryFlag(challengeCfg.aDropMaxNum,challengeCfg.fDropTypeMaxNum) then
        response.ret = -6009
        return response
    end

    -- 战斗计算
    local defSkill = challengeCfg.skill
    local defTech = challengeCfg.alliance_tech
    local defAttUp = challengeCfg.attributeUp
    local defLevel = challengeCfg.level -- 关卡等级
    local defName = 0 -- 关卡名称

    local mSequip = uobjs.getModel('sequip')
    local debuffvalue = mSequip.dySkillAttr(equip, 's101', 0) --关卡护盾 减少敌方伤害x%
    local buffvalue = mSequip.dySkillAttr(equip, 's102', 0) --关卡强击 我方伤害增加X%
    local mBadge = uobjs.getModel('badge')

    local aFleetInfo,accessoryEffectValue,aherosInfo = mTroop.initFleetAttribute(fleetInfo,1,{hero=hero,equip=equip, equipskill={dmg=buffvalue, dmg_reduce=1-debuffvalue}})
     --活动检测关卡攻击力增加%比
    local acname = "accessoryFight";
    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    --ptb:p(aFleetInfo)
    if activStatus == 1 then
        local activeCfg = getConfig("active.accessoryFight")
        for k,v in pairs(aFleetInfo) do
            --ptb:p(v)
            if next(v) then
                if v['dmg']>0 then
                    aFleetInfo[k]['dmg']=aFleetInfo[k]['dmg']+(aFleetInfo[k]['dmg']*(activeCfg.serverreward.powerAdd or 0))
                end
            end
        end
    end
    local dFleetInfo = mChallenge.initDefFleetAttribute(defFleetInfo,defSkill,defTech,defAttUp)

    require "lib.battle"
    
    local report,aInavlidFleet, dInvalidFleet = {star=0}
    report.d, report.w, aInavlidFleet, dInvalidFleet = battle(aFleetInfo,dFleetInfo,0,useProps)
    report.t = {defFleetInfo,fleetInfo}
    report.p = {{defName,defLevel,0},{mUserinfo.nickname,mUserinfo.level,1}}    
    report.h = {{},aherosInfo[1]}
    report.se ={0, mSequip.formEquip(equip)}
    report.badge ={{0,0,0,0,0,0}, mBadge.formBadge()} -- 徽章数据
    
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1("s1006")
    
    local reward,rRecord
    if report.w == 1 then
        
        mChallenge.kill(defenderId)   -- 关卡被击杀
        --日常任务
        
        --新的日常任务检测
        mDailyTask.changeNewTaskNum('s204',1)

        local isfirst = false
        report.star,isfirst = mChallenge.setStar(defenderId,fleetInfo,aInavlidFleet)   -- 关卡评星，解锁
        
        reward = mChallenge.getRewardBySid(defenderId,nil,isfirst, equip)
        
        local ret,rDetail = takeReward(attackerId,reward)
        if not ret then
             response.ret = -6009
            return response
        end

        report.r = formatReward(reward)     
        _,rRecord = next(rDetail)

        -- 啤酒节
        local beerreward = activity_setopt(attackerId,'beerfestival',{act='Rate2',num=1})
        -- 感恩节2017
        local thanksgiving = activity_setopt(attackerId,'thanksgiving',{act=8,num=1,w=1})
        if report.r and type(report.r)=='table' then
            if type(beerreward)=='table' and next(beerreward) then
                report.r.beer = beerreward
            end

            if type(thanksgiving)=='table' and next(thanksgiving) then
                report.r.thank = thanksgiving
            end 
        end 

        -- 国庆七天乐
        activity_setopt(attackerId,'nationalday2018',{act='tk',type='ab',num=1})    
       
    end
    mHero.refreshFeat("t6",1,1)
    -- 中秋赏月活动埋点
    activity_setopt(attackerId, 'midautumn', {action='ab'})
    -- 国庆活动埋点
    activity_setopt(attackerId, 'nationalDay', {action='ab'})
    -- 春节攀升
    activity_setopt(attackerId, 'chunjiepansheng', {action='ab'})
    -- 猎杀潜航
    activity_setopt(attackerId,'silentHunter',{action='ab',num=1})
    -- 悬赏任务
    activity_setopt(attackerId,'xuanshangtask',{t='',e='ab',n=1})  
    --点亮铁塔
    activity_setopt(attackerId,'lighttower',{act='ab',num=1}) 
    --岁末回馈
    activity_setopt(attackerId,'feedback',{act='ab',num=1}) 
    -- 愚人节大作战-攻打X次补给线
    activity_setopt(attackerId,'foolday2018',{act='task',tp='ab',num=1},true)
    
    -- local mTask = uobjs.getModel('task')
    -- mTask.check()

    if not report then
        return response
    end
    
    -- regActionLogs(attackerId,2,{action=4,item=defenderId,value=star,params={c=challenge.star}})

    processEventsBeforeSave()

    if uobjs.save() then    
        processEventsAfterSave()
        
        if rRecord then 
            response.data.echallengebattle.reward = rRecord
        end

        response.data.report = report
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
