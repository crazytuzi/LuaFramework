function api_challenge_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

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
    local isTutorial = request.params.isTutorial    -- 是否是新手引导
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

    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end
       
    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip)  then
        response.ret=-8650 
        return response        
    end

    -- check end
    -- 关卡是否解锁
    if not challenge.checkUnlock(defenderId) then
        response.ret = -6001
        response.msg = "challenge not unlock"
        return response
    end

    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end

    local useEnergy  = true
    -------------------- start vip新特权 仓库保护量增加
    if moduleIsEnabled('vps') == 1 and mUserinfo.vip>0 then
        local vipRelatedCfg = getConfig('player.vipRelatedCfg')
            if type(vipRelatedCfg)=='table' then
                local vip =vipRelatedCfg.storyPhysical[1]
                    if mUserinfo.vip>=vip then
                        useEnergy=false
                    end
                end 
                               
    end
        --------------------- end
        
        --使用能量
    if useEnergy then    
        if not mUserinfo.useEnergy(1) then
            response.ret = -2001        
            return response
        end
    end
    local report,star,win = challenge.battle(defenderId,fleetInfo,isTutorial,hero,nil,equip)    
    if win == 1 and useEnergy==false then        
	if not mUserinfo.useEnergy(1) then
            response.ret = -2001        
            return response
        end
    end

    if win == 1 then
         mHero.refreshFeat("t2",hero,defenderId)
         -- 复活节彩蛋大搜寻
         if report.acaward and report.acaward.egg2 then
            response.data.egg= report.acaward
         end
         -- 啤酒节
         local beerreward = activity_setopt(attackerId,'beerfestival',{act='Rate1',num=1})
          -- 万圣节狂欢
         local wsjkh = activity_setopt(attackerId,'wsjkh',{act=5,num=1,w=1}) 
         -- 感恩节2017
         local thanksgiving = activity_setopt(attackerId,'thanksgiving',{act=5,num=1,w=1}) 
         -- 装扮圣诞树
         local dresstree = activity_setopt(attackerId,'dresstree',{act=4,num=1,w=1}) 
         -- 圣帕特里克
         local dresshat = activity_setopt(attackerId,'dresshat',{act=4,num=1,w=1})  
         -- 百级开启
         local levelopen = activity_setopt(attackerId,'levelopen',{act='f4',defenderId=defenderId,w=1}) 

        
         if report.r and type(report.r)=='table' then
            if type(beerreward)=='table' and next(beerreward) then
                report.r.beer = beerreward
            end

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
            
         end

        --海域航线
        activity_setopt(attackerId,'hyhx',{act='tk',type='cn',num=1})
        -- 番茄大作战
        activity_setopt(attackerId,'fqdzz',{act='tk',type='cn',num=1}) 
    end
    -- 日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1("s1004")
    
       
    local mTask = uobjs.getModel('task')
    mTask.check()

    if not report then
        response.ret = -311
        response.msg = "battle error"
        return response
    end

    --勇往直前
    activity_setopt(attackerId,'yongwangzhiqian',{sid=defenderId,action='pass',win=win})
    -- 设置钢铁之心 之关卡的星星(来自星星的你奥！)
    activity_setopt(attackerId,'heartOfIron',{star=challenge.star})
    
    regActionLogs(attackerId,2,{action=4,item=defenderId,value=star,params={c=challenge.star}})
    -- 中秋赏月活动埋点
    activity_setopt(attackerId, 'midautumn', {action='cn'})
    -- 国庆活动埋点
    activity_setopt(attackerId, 'nationalDay', {action='cn'})
    -- 春节攀升埋点
    activity_setopt(attackerId, 'chunjiepansheng', {action='cn'})
    -- 悬赏任务
    activity_setopt(attackerId,'xuanshangtask',{t='',e='cn',n=1}) 
    --点亮铁塔
     activity_setopt(attackerId,'lighttower',{act='cn',num=1}) 
    --岁末回馈
     activity_setopt(attackerId,'feedback',{act='cn',num=1}) 
     -- 合服大战
     activity_setopt(attackerId,'hfdz',{act='cn',num=1})
    -- 愚人节大作战-攻打X次关卡
    activity_setopt(attackerId,'foolday2018',{act='task',tp='cn',num=1},true)
  
 
    -- 不给糖就捣蛋
    local halloween = activity_setopt(attackerId,'halloween',{at=1})
    if report.r and 'table' == type(report.r) then
        report.r.t = halloween
    end

    if win==1 then
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
    end

    processEventsBeforeSave()
    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.report = report
        if star then 
            response.data.challenge ={}
            response.data.challenge['s'..defenderId] = star                    
        end
        if star and math.floor(defenderId/16) == defenderId/16 and star.s >=3 then
            if moduleIsEnabled("sec") == 1 and moduleIsEnabled("hero") == 1  then
                local schallenge = uobjs.getModel('schallenge')
                response.data.schallenge = schallenge.getChallengeMaxSid()
            end
        end           
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response

end
