function api_hchallenge_multiplebattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local sid = request.params.sid
    local sweepNum = tonumber(request.params.num)
    if not sweepNum or not sid then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","troops","props","bag","hchallenge","hero","equip"})
    local hchallenge = uobjs.getModel('hchallenge')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local mEquip = uobjs.getModel('equip')
    local mSequip = uobjs.getModel('sequip')
    local mHero = uobjs.getModel('hero')
    local mTroop = uobjs.getModel('troops')
    local config = getConfig('hChallengeCfg')

    if moduleIsEnabled('hel') > mUserinfo.level then
        response.ret = -18000
        return response
    end
        
    -- 关卡是否解锁
    if not hchallenge.checkUnlock(sid) then
        response.ret = -6001
        response.msg = "hchallenge not unlock"
        return response
    end
    
    local vipRelatedCfg = getConfig('player.vipRelatedCfg')
    if type(vipRelatedCfg)=='table' then
        local needVip = vipRelatedCfg.hchallengeSweepNeedVip or 0
        if mUserinfo.vip < needVip then
            response.ret = -1981
            response.msg = "vip error"
            return response
        end
    end 
    
    if not hchallenge.info['s'..sid] or type(hchallenge.info['s'..sid]) ~= 'table' or not hchallenge.info['s'..sid]['s'] or hchallenge.info['s'..sid]['s'] < config.sweepStar then
        response.ret = -18021
        return response
    end

    -- local sweepNum =  action -- config.challengeNum - hchallenge.checkAttackNum(sid)
    local nNum  = config.useEnergy

    if sweepNum <= 0 or (config.challengeNum - hchallenge.checkAttackNum(sid) < sweepNum) then
        response.ret = -18020
        return response
    end
    
    -- 单次扫荡
    -- if action == 1 then
    --     sweepNum = 1
    -- end

    -- --使用能量
    -- if useEnergy then
    --     if not mUserinfo.useEnergy(useEnergy*sweepNum) then
    --         response.ret = -2001
    --         return response
    --     end
    -- end
    
    -- if not hchallenge.useBattleNum(sid,sweepNum) then
    --     response.ret = -2001
    --     return response
    -- end
    
    local allReward = {}
    local repair = request.params.repair -- 修复类型
    local equip = request.params.equip
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

    local reports = {}
    local raidcnt, passcnt = 0, 0                    
    for i=1,sweepNum do

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

        --使用能量， 扣能量
        if useEnergy == true and not mUserinfo.useEnergy( nNum ) then    
            response.data.overflag = -1        
            break
        end

        if not hchallenge.useBattleNum(sid, 1) then
            response.data.overflag = -3
            break
        end 

        local report,star,win, attach = hchallenge.battle(sid, fleetInfo, hero, repair, equip)
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
        local zongzi=activity_setopt(uid, 'zongzizuozhan', {u=uid,e='d',num=1})
        if type(zongzi)=='table' and next(zongzi) then
            if type(report.acaward)~='table' then
                report.acaward={}
            end
            for k,v in pairs(zongzi) do
                report.acaward[k]=v
            end
        end

        -- 啤酒节
        local beerreward = activity_setopt(uid,'beerfestival',{act='Rate3',num=1})
        -- 万圣节狂欢
        local wsjkh = activity_setopt(uid,'wsjkh',{act=7,num=1,w=win}) 
        -- 感恩节2017
        local thanksgiving = activity_setopt(uid,'thanksgiving',{act=7,num=1,w=win}) 
        -- 装扮圣诞树
        local dresstree = activity_setopt(uid,'dresstree',{act=6,num=1,w=win})
        -- 圣帕特里克
        local dresshat = activity_setopt(uid,'dresshat',{act=6,num=1,w=win})  
        if type(report.r)=='table' then
            if  type(beerreward)=='table' and next(beerreward) then
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
             mHero.refreshFeat("t2",hero,sid)
             passcnt = passcnt + 1
        end
        raidcnt = raidcnt + 1
    end

    --勇往直前
    activity_setopt(uid,'yongwangzhiqian',{sid=sid,action='raid',raidcnt=raidcnt, passcnt=passcnt})
    -- 设置钢铁之心 之关卡的星星(来自星星的你奥！)
    activity_setopt(uid,'heartOfIron',{star=hchallenge.star})

    -- 节日花朵
    activity_setopt(uid,'jrhd',{act="tk",id="ht",num=passcnt})

    -- 日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    -- mDailyTask.changeTaskNum(5, #reports)
    mDailyTask.changeTaskNum1('s1008',sweepNum)

     --writeLog('uid='..uid..'action=13'..'item='..sid..'value='..json.encode(star)..'c='..hchallenge.star,'hchallenge')
    regActionLogs(uid,2,{action=13,item=sid,value=star,params={c=hchallenge.star}})   

    processEventsBeforeSave()
    if uobjs.save() then     
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.hchallenge = hchallenge.toArray(true)
        response.data.equip = mEquip.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.reports = reports
        response.data.repair = repair        
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response

end
