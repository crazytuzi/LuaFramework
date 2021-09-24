-- 关卡扫荡
-- 关卡扫荡的战斗是真实发生的
-- 
function api_challenge_raid(request)
    local response = {
        ret=-1,
        msg='error',
        data = {overflag=0, },
    }

    if moduleIsEnabled('raid') == 0 then
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
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge","hero"})
    local challenge = uobjs.getModel('challenge')
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
    if not challenge.checkUnlock(defenderId) then
        response.ret = -6001
        response.msg = "challenge not unlock"
        return response
    end

    if challenge.getStar('s'.. defenderId) < 3 then
        response.ret = -6002
        response.msg = "challenge not 3 star"
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

    local raidcnt, passcnt = 0, 0
    -- 扫荡次数
    for i=1, raidnum do 

        --兵力检测
        if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
            response.data.overflag = -2
            break
        end

        -- 检测能量不够直接中断，防止vip玩家打赢了扣除能量失败，只保存部分数据
        if not mUserinfo.checkEnergy(1) then
             response.data.overflag = -1        
            break           
        end

        --使用能量
        if useEnergy and not mUserinfo.useEnergy(1) then    
            response.data.overflag = -1        
            break
        end

        local report,star,win, attach = challenge.battle(defenderId,fleetInfo,isTutorial,hero, repair,equip)    
        if win == 1 and useEnergy==false and not mUserinfo.useEnergy(1) then        
            response.data.overflag = -1        
            break
        end
        if not report then
            response.ret = -311
            response.msg = "battle error"
            return response
        end
        
        -- 不给糖就捣蛋
        local halloween = activity_setopt(attackerId,'halloween',{at=1})
        -- 啤酒节
        local beerreward = activity_setopt(attackerId,'beerfestival',{act='Rate1',num=1})
         -- 万圣节狂欢
        local wsjkh = activity_setopt(attackerId,'wsjkh',{act=5,num=1,w=win}) 
        -- 感恩节2017
        local thanksgiving = activity_setopt(attackerId,'thanksgiving',{act=5,num=1,w=win}) 
        -- 装扮圣诞树
        local dresstree = activity_setopt(attackerId,'dresstree',{act=4,num=1,w=win})
        -- 圣帕特里克
        local dresshat = activity_setopt(attackerId,'dresshat',{act=4,num=1,w=win})  
        -- 百级开启
        local levelopen = activity_setopt(attackerId,'levelopen',{act='f4',defenderId=defenderId,w=win})
        
        if report.r and 'table' == type(report.r) then
            report.r.t = halloween
            if type(beerreward)=='table' and next(beerreward) then
                report.r.beer = beerreward
            end

            if win ==1 then
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
                if type(levelopen)=='table' and next(levelopen) then
                    report.r.levelopen = levelopen
                end

                -- 三周年-冲破噩梦-炮弹搜索
                local cpem = activity_setopt(attackerId,'cpem',{type='cn',num=1}) 
                if type(cpem)=='table' and next(cpem) then
                    report.r.cpem = cpem
                end

		
		--海域航线
		activity_setopt(attackerId,'hyhx',{act='tk',type='cn',num=1})
		-- 番茄大作战
		activity_setopt(attackerId,'fqdzz',{act='tk',type='cn',num=1}) 
            end
        end

 

        -- if type(halloween) == 'table' and next(halloween) then
        --     response.data.acreward = {}
        --     response.data.acreward.t = halloween
        -- end

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
    activity_setopt(attackerId,'heartOfIron',{star=challenge.star})
    -- 中秋赏月活动埋点
    activity_setopt(attackerId, 'midautumn', {action='cn', num=raidcnt})
    -- 国庆活动埋点
    activity_setopt(attackerId, 'nationalDay', {action='cn', num=raidcnt})
    -- 春节攀升埋点
    activity_setopt(attackerId, 'chunjiepansheng', {action='cn', num=raidcnt})
    -- 悬赏任务
    activity_setopt(attackerId,'xuanshangtask',{t='',e='cn',n=raidcnt})
    -- 点亮铁塔
    activity_setopt(attackerId,'lighttower',{act='cn',num=raidcnt}) 
    -- 岁末回馈
    activity_setopt(attackerId,'feedback',{act='cn',num=raidcnt})
    -- 合服大战
    activity_setopt(attackerId,'hfdz',{act='cn',num=raidcnt})
    -- 愚人节大作战-攻打X次关卡
    activity_setopt(attackerId,'foolday2018',{act='task',tp='cn',num=raidcnt})
 

    -- 日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    -- mDailyTask.changeTaskNum(5, #reports)
    mDailyTask.changeTaskNum1("s1004",#reports)
    
    local mTask = uobjs.getModel('task')
    mTask.check()
    
    regActionLogs(attackerId,2,{action=4,item=defenderId,value=star,params={c=challenge.star}})
    processEventsBeforeSave()
    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.reports = reports
        response.data.repair = repair

        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response
end
