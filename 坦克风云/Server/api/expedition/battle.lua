-- 远征军的攻击
function api_expedition_battle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hero   =request.params.hero
    local equip = request.params.equip
    local plane = request.params.plane

    if uid ==nil then
        response.ret=-102
        return response
    end

    local num = 0
    local fleetInfo={}
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
        response.msg = 'tank num is empty'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero     = uobjs.getModel('hero')
    local mTroop    = uobjs.getModel('troops')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')
    local fc = mUserinfo.fc
    local eid = mUserExpedition.eid
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local expeditionCfg=getConfig("expeditionCfg")
    if mUserinfo.level < expeditionCfg.openLevel then
        response.ret = -13001
        return response
    end

    if mUserinfo.level <expeditionCfg.unlockExpUserLvl[eid] then
        response.ret = -13007
        return response
    end


    local function getbattlehero(hid)
        local flag = true
        if type(mUserExpedition.info.dh)=='table' and next(mUserExpedition.info.dh) then
                for k,v in pairs(mUserExpedition.info.dh) do
                    if v==hid then
                        flag=false
                    end
                end

        end
        return flag
    end    
    --check hero
    if type(hero)=='table' and next(hero) then
        hero =mHero.checkFleetHeroStats(hero)
        if hero==false then
            response.ret=-11016 
            return response
        end


        for k,v in pairs(hero) do
            if v~=0 then 
                --检测以设置过的英雄是否有重复
                local ret = getbattlehero(v)
                if not ret then
                    response.ret=-11016 
                    return response
                end
            end
        end

    end

    -- check equip
    if equip and not mSequip.checkFleetEquipStats(equip, mUserExpedition.info.dse)  then
        response.ret=-8650 
        return response        
    end

    -- check equip
   local mPlane = uobjs.getModel('plane')
    if plane and not mPlane.checkFleetPlaneStats(plane,mUserExpedition.info.dpe) then
        response.ret=-12110
        return response        
    end

    --兵力检测
    -- 减去自己死去的兵
    if not mTroop.checkFleetInfo(fleetInfo,mUserExpedition.info.dt, equip) then
        response.ret = -5006
        return response
    end
    if mUserExpedition.eid>=15  and mUserExpedition.info.win~=nil then
        response.ret = -13002
        return response
    end

    local report =mUserExpedition.battle(uid,fleetInfo,hero,equip,plane)
    if report.w==1 then
        mHero.refreshFeat("t7",1,1)
        -- 中秋赏月活动埋点
        activity_setopt(uid, 'midautumn', {action='eb'})
        -- 国庆活动埋点
        activity_setopt(uid, 'nationalDay', {action='eb'})
        -- 点亮铁塔
        activity_setopt(uid,'lighttower',{act='eb',num=1})
        --海域航线
        activity_setopt(uid,'hyhx',{act='tk',type='ez',num=1})

    end
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='ez'})
    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='ez',n=1})     
    -- 岁末回馈
    activity_setopt(uid,'feedback',{act='ez',num=1})
    -- 愚人节大作战-攻打X次远征
    activity_setopt(uid,'foolday2018',{act='task',tp='ez',num=1})

    

    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum1('s1014',1)

    if uobjs.save() then  
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true) 
        response.data.report = report
        response.ret = 0
        response.msg = 'Success'

    end


    return response
end
