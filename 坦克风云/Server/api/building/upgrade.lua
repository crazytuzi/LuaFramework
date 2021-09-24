function api_building_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local bid = request.params.bid and 'b' .. request.params.bid
    local buildType = request.params.buildType

    if uid == nil or bid == nil or buildType == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","jobs","statue"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mBuildings = uobjs.getModel('buildings')
    local mStatue =uobjs.getModel('statue')

    -- 刷新队列
    mBuildings.update()

    -- 是否解锁
    -- 飞机建筑解锁等级是玩家等级
    if bid == 'b106' then
        local planecfg = getConfig('planeCfg')
        if mUserinfo.level < planecfg.buildLevel then
            response.ret = -113
            return response
        end
    else
        --  解锁等级是指挥中心
    if not mBuildings.buildingIsUnlock(bid,buildType) then
        response.ret = -113
        return response
    end

    end
    

    -- 正在升级中
    if mBuildings.checkIdInSlots(bid) then
        response.ret = -3002
        return response
    end

    local cfg = getConfig('building.'..buildType)
    local currLevel = mBuildings[bid][2] or 0

    -- 当前地块等级不小于最大等级
    if currLevel  >= cfg.maxLevel then
        response.ret = -121
        return response
    end

    local upLevel = 1 + currLevel

    local bRes = {}
    bRes.r1 = cfg.metalConsumeArray[upLevel]
    bRes.r2 = cfg.oilConsumeArray[upLevel]
    bRes.r3 = cfg.siliconConsumeArray[upLevel]
    bRes.r4 = cfg.uraniumConsumeArray[upLevel]
    bRes.gold = cfg.moneyConsumeArray[upLevel]
    -- 冲级三重奏
    bRes = activity_setopt(uid, 'leveling', {use = bRes, type = 1, buildType = buildType, oldInfo=bRes, level=currLevel}) or bRes
    bRes = activity_setopt(uid, 'leveling2', {use = bRes, type = 1, buildType = buildType, oldInfo=bRes, level=currLevel}) or bRes

    -- 使用资源
    if not mUserinfo.useResource(bRes) then   
        response.ret = -107
        return response
    end  

    local iConsumeTime = cfg.timeConsumeArray[upLevel]
    -- 科技影响
    local techLevel =  tonumber(mTech.getTechLevel('t23'))
    --  区域战职位
    local mJob =uobjs.getModel('jobs')
    -- 1 就是建筑加速
    local value =mJob.getjobaddvalue(1)
    local mSequip =uobjs.getModel('sequip')
    local equipvalue = mSequip.skillAttr('s304', 0) -- 急速建造
    -- 战争雕像建筑加速
    local statuevalue = mStatue.getSkillValue('buildSpeed') or 0

    -- 远洋征战
    local oceanExpBuff = mUserinfo.getOceanExpeditionBuff("buildSpeed") 

    iConsumeTime = iConsumeTime /(1+techLevel*0.05 + value + equipvalue + statuevalue + oceanExpBuff)


    -- 冲级三重奏
    iConsumeTime = activity_setopt(uid, 'leveling', {iConsumeTime = iConsumeTime, type = 2, buildType = buildType, oldInfo=iConsumeTime, level=currLevel}) or iConsumeTime
    iConsumeTime = activity_setopt(uid, 'leveling2', {iConsumeTime = iConsumeTime, type = 2, buildType = buildType, oldInfo=iConsumeTime, level=currLevel}) or iConsumeTime

    local ts = getClientTs()
    local bSlotInfo = {st=ts,id=bid,type=buildType}
    bSlotInfo.et = iConsumeTime + ts 

    -- 使用队列
    if not mBuildings.useSlot(bSlotInfo)    then        
        response.ret = -1997
        return response
    end
    
    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    
    
    if uobjs.save() then        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.buildings = mBuildings.toArray(true)
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
        ------------------------消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[2]~=nil and request.push.tb[2]==1 then

                local execRet, code=M_push.addPushMsg({bindid=request.push.binid,ts=bSlotInfo.et,t=1,pt=request.system,lag=request.lang,msg='b'..buildType,id=uid..bid,l=upLevel,appid=request.appid})
            end
           
        end
        ------------------------消息推送 end   ----------------------------------------   
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	