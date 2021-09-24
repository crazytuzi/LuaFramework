function api_hchallenge_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local sid = request.params.sid
    local hero = request.params.hero
    local equip = request.params.equip
    local fleetInfo = {}
    local num = 0
    
    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
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

    if not sid then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","hchallenge","hero","equip"})
    local hchallenge = uobjs.getModel('hchallenge')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mBag = uobjs.getModel('bag')
    local mHero = uobjs.getModel('hero')
    local mEquip = uobjs.getModel('equip')
    local mSequip = uobjs.getModel('sequip')
    local config = getConfig('hChallengeCfg')

    if moduleIsEnabled('hel') > mUserinfo.level then
        response.ret = -18000
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

    -- 关卡是否解锁
    if not hchallenge.checkUnlock(sid) then
        response.ret = -6001
        response.msg = "hchallenge not unlock"
        return response
    end

    --兵力检测
    if not mTroop.checkFleetInfo(fleetInfo,nil,equip) then
        response.ret = -5006
        return response
    end
    
    local challengeNum = hchallenge.checkAttackNum(sid)
    local useEnergy  = config.useEnergy

    if challengeNum >= config.challengeNum then
        response.ret = -18020
        return response
    end
    
    local useEnergy = config.useEnergy
    
    --使用能量
    if useEnergy then
        if not mUserinfo.useEnergy(useEnergy) then
            response.ret = -2001
            return response
        end
    end

    if not hchallenge.useBattleNum(sid, 1) then
        response.ret = -2002
        return response
    end 

    local report,star,win = hchallenge.battle(sid,fleetInfo,hero, nil, equip)
    
    if not report then
        response.ret = -311
        response.msg = "battle error"
        return response
    end

    --勇往直前
    activity_setopt(uid,'yongwangzhiqian',{sid=sid,action='pass',win=win})
    
    -- 每日任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1008')

    if win==1 then
         -- 粽子作战
         local zongzi,actinfo=activity_setopt(uid, 'zongzizuozhan', {u=uid,e='d',num=1})
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
        local wsjkh = activity_setopt(uid,'wsjkh',{act=7,num=1,w=1}) 
        -- 感恩节2017
        local thanksgiving = activity_setopt(uid,'thanksgiving',{act=7,num=1,w=1}) 
        -- 装扮圣诞树
        local dresstree = activity_setopt(uid,'dresstree',{act=6,num=1,w=1}) 
        -- 圣帕特里克
        local dresshat = activity_setopt(uid,'dresshat',{act=6,num=1,w=1}) 
        if  type(report.r)=='table' then
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
        end

        -- 节日花朵
        activity_setopt(uid,'jrhd',{act="tk",id="ht",num=1})
    end

    --writeLog('uid='..uid..'action=13'..'item='..sid..'value='..json.encode(star)..'c='..hchallenge.star,'hchallenge')
    regActionLogs(uid,2,{action=13,item=sid,value=star,params={c=hchallenge.star}})    

    processEventsBeforeSave()
    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.equip = mEquip.toArray(true)
        response.data.report = report
        if star then 
            response.data.hchallenge = {info={}}
            response.data.hchallenge.info['s'..sid] = star                    
            response.data.hchallenge.info['s'..sid] = star 
            local hchallengeInfo = hchallenge.getChallengeMaxSid()
            response.data.hchallenge.maxsid = hchallengeInfo.maxsid                    
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
