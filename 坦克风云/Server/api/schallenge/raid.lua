-- 关卡扫荡
-- 关卡扫荡的战斗是真实发生的
-- 
function api_schallenge_raid(request)
    local response = {
        ret=-1,
        msg='error',
        data = {overflag=0, },
    }

    if moduleIsEnabled("sec")==0 or moduleIsEnabled('hero') == 0 or moduleIsEnabled('sraid') == 0 then
        response.ret = -9000
        return response
    end

    local fleetInfo = {}
    local num = 0
    local hero   =request.params.hero  
    for m,n in pairs(request.params.fleetinfo) do
            if next(n) then
                n[1] = 'a' .. n[1]
                num = num + n[2]
            end
            fleetInfo[m] = n
    end

    if num <= 0 then
        response.ret = -1
        response.cmd = request.cmd
        response.ts = os.time()
        response.msg = 'tank num is empty'
        return response
    end

    -- 攻防双方id
    local attackerId = request.uid
    local defenderId = request.params.defender
    local isTutorial = false    -- 是否是新手引导
    local raidnum = tonumber( request.params.num ) or 0 -- 扫荡次数
    local repair = request.params.repair -- 修复类型
    local equip = request.params.equip
    
    if not defenderId then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(attackerId)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","schallenge","hero"})
    local schallenge = uobjs.getModel('schallenge')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mBag = uobjs.getModel('bag')    
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    
    local reports = {}
    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
       
    end
    -- check end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end
        
    -- 关卡是否解锁
    if not schallenge.checkUnlock(defenderId) then
        response.ret = -6001
        response.msg = "schallenge not unlock"
        return response
    end

    if schallenge.getStar('s'.. defenderId) < 3 then
        response.ret = -60020
        response.msg = "schallenge not 3 star"
        return response        
    end

    local useEnergy  = true
    -- vip 战斗失败不损失能量
    if moduleIsEnabled('vps') == 1 and mUserinfo.vip>0 then
        local vipRelatedCfg = getConfig('player.vipRelatedCfg')
            if type(vipRelatedCfg)=='table' then
                local vip =vipRelatedCfg.storyPhysical[1]
                    if mUserinfo.vip>=vip then
                        useEnergy=false
                    end
                end 
                               
    end
    local challengeCfg = getConfig('schallenge')
    local nNum = challengeCfg.consumeEnergy or 2      
    local raidcnt, passcnt = 0, 0

    -- 扫荡次数
    for i=1, raidnum do 

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.data.overflag = -2
            break
        end

        -- 能量和次数要一起扣， 所以要先检测能量够否
        if not mUserinfo.checkEnergy(nNum) then
             response.data.overflag = -1        
            break           
        end

        -- 精英关卡次数限制, 扣次数
        if not schallenge.checkAccessEite(defenderId, true) then
            response.data.overflag = -3
            break
        end                
        --使用能量， 扣能量
        if useEnergy and not mUserinfo.useEnergy( nNum ) then    
            response.data.overflag = -1        
            break
        end

        local report,star,win, attach = schallenge.battle(defenderId,fleetInfo,isTutorial,hero, repair,equip)    
        if win == 1 and useEnergy==false and not mUserinfo.useEnergy( nNum ) then        
            response.data.overflag = -1        
            break
        end
        if not report then
            response.ret = -311
            response.msg = "battle error"
            return response
        end

        -- 粽子作战
        local zongzi=activity_setopt(attackerId, 'zongzizuozhan', {u=attackerId,e='d',num=1})
        if type(zongzi)=='table' and next(zongzi) then
            if type(report.acaward)~='table' then
                report.acaward={}
            end
            for k,v in pairs(zongzi) do
                report.acaward[k]=v
            end
        end



        -- 啤酒节
        local beerreward = activity_setopt(attackerId,'beerfestival',{act='Rate6',num=1}) 
        -- 万圣节狂欢
        local wsjkh = activity_setopt(attackerId,'wsjkh',{act=6,num=1,w=win}) 
        -- 感恩节2017
        local thanksgiving = activity_setopt(attackerId,'thanksgiving',{act=6,num=1,w=win})
        -- 装扮圣诞树
        local dresstree = activity_setopt(attackerId,'dresstree',{act=5,num=1,w=win})
        -- 圣帕特里克
        local dresshat = activity_setopt(attackerId,'dresshat',{act=5,num=1,w=win}) 
        if type(report.r)=='table' then
            if type(beerreward)=='table' and next(beerreward) then
                report.r.beer = beerreward
            end

            if win==1 then
                if type(wsjkh)=='table' and next(wsjkh) then
                    report.r.wsjkh = wsjkh
                end

                if type(thanksgiving)=='table' and next(thanksgiving) then
                    report.r.thank = thanksgiving
                end 

                if type(dresstree)=='table' and next(dresstree) then
                    report.r.dresstree = dresstree
                end 
                
                if type(dresshat)=='table' and next(dresshat) then
                    report.r.dresshat = dresshat
                end    
            end      
        end
                                      

        local tmp_report = {r=report.r, rr=report.rr, acaward=report.acaward, attach=attach}
        table.insert(reports, tmp_report)
        if win == 1 then
             mHero.refreshFeat("t2",hero,defenderId)
             passcnt = passcnt + 1
        end
        raidcnt = raidcnt + 1
    end
    
    --勇往直前
    activity_setopt(attackerId,'yongwangzhiqian',{sid=defenderId,action='raid',raidcnt=raidcnt, passcnt=passcnt})
    -- 设置钢铁之心 之关卡的星星(来自星星的你奥！)
    activity_setopt(attackerId,'heartOfIron',{star=schallenge.star})
    -- 春节攀升
    activity_setopt(attackerId, 'chunjiepansheng', {action='jq',num=raidcnt})
    -- 悬赏任务
    activity_setopt(attackerId,'xuanshangtask',{t='',e='jq',n=raidcnt})
    -- 愚人节大作战-攻打X次剧情战役
    activity_setopt(attackerId,'foolday2018',{act='task',tp='jq',num=raidcnt},true)
    -- 节日花朵
    activity_setopt(attackerId,'jrhd',{act="tk",id="jq",num=passcnt}) 
  
    -- 日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum(5, #reports)
    
    local mTask = uobjs.getModel('task')
    mTask.check()
    
    regActionLogs(attackerId,2,{action=8,item=defenderId,value=star,params={c=schallenge.star}})
    processEventsBeforeSave()
    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.reports = reports
        response.data.repair = repair
        response.data.scha = schallenge.getChallengeMaxSid()

        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response
end
