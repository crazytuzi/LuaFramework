-- 掠夺战斗
function api_alienweapon_battle(request)
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
    local equip = request.params.equip

    local uobjs = getUserObjs(attackerId)
    uobjs.load({"userinfo", "techs", "troops", "hero"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero      = uobjs.getModel('hero')
    local mSequip = uobjs.getModel('sequip')
    local mAweapon = uobjs.getModel('alienweapon')

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

    -- 兵力检测
    if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
        response.ret = -5006
        return response
    end

    -- 抢夺次数不够
    if not mAweapon.incrRobnum() then
        response.ret = -12022
        return response
    end

    -- 攻打目标
    local targetid = request.params.id -- npc : npc_等级_id(npc_30_1) 玩家：userid_slot(1000001_1)
    local tindex = mAweapon.checkCanRob(targetid)
    if not tindex then
        response.ret = -12020
        return response
    end

    local report,win, duobjs = mAweapon.battle(targetid,tindex,fleetInfo,hero,equip)
    
    -- 异星任务:完成抢夺{1}次
    activity_setopt(attackerId,'alientask',{t='y2',n=1,w=win})
    -- 国庆七天乐
    activity_setopt(attackerId,'nationalday2018',{act='tk',type='ld',num=1}) 
    -- 节日花朵
    activity_setopt(attackerId,'jrhd',{act="tk",id="ld",num=1})

    -- 感恩节拼图
    activity_setopt(attackerId,'gejpt',{act='tk',type='ld',num=1})

    if not report then
        response.ret = -311
        response.msg = "battle error"
        return response
    end

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1012',1)
    
    processEventsBeforeSave()
    if uobjs.save() then          
        processEventsAfterSave()
        if duobjs then
            duobjs.save()
        end
        response.data.report = report
        response.data.alienweapon = mAweapon.toArray(true)
        response.data.report.w = win
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -501
        response.msg = "save failed"
    end

    return response

end
