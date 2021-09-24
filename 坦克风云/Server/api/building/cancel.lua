function api_building_cancel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = request.uid
    local bid = request.params.bid
    local buildType = request.params.buildType

    if uid == nil or bid == nil or buildType == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    bid = 'b' .. bid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuildings = uobjs.getModel('buildings')

    -- 刷新队列
    mBuildings.update()

    local iSlotKey = mBuildings.checkIdInSlots(bid)
    local bSlot = mBuildings.queue[iSlotKey]
    local currLevel = mBuildings[bid][2] or 0
    if type(bSlot) ~= 'table' and bSlot.type ~= buildType then
        response.ret = -1989
        return response
    end

    -- 计算返还的资源量
    local cfg = getConfig('building.' .. mBuildings[bid][1])
    local rate = getResRate4Cancel(bSlot.st,bSlot.et)
    
    local upLevel = 1 + (tonumber(mBuildings[bid][2]) or 0)
    local resource = {}
    resource.r1 = rate * cfg.metalConsumeArray[upLevel]
    resource.r2 = rate * cfg.oilConsumeArray[upLevel]
    resource.r3 = rate * cfg.siliconConsumeArray[upLevel]
    resource.r4 = rate * cfg.uraniumConsumeArray[upLevel]
    resource.gold = rate * cfg.moneyConsumeArray[upLevel]
    -- 冲级三重奏
    resource = activity_setopt(uid, 'leveling', {use = resource, type = 1, buildType = buildType, oldInfo = resource, level=currLevel}) or resource
    resource = activity_setopt(uid, 'leveling2', {use = resource, type = 1, buildType = buildType, oldInfo = resource, level=currLevel}) or resource

    -- 返还资源
    if not mUserinfo.addResource(resource) then
        response.ret = -1991
        return response
    end

    -- 打开使用的队列槽
    if not mBuildings.openSlot(iSlotKey) then
        response.ret = -1992
        return response
    end
    --没有开启自动升级
    if  getConfig("gameconfig").auto_build and getConfig("gameconfig").auto_build.enable==1 then
        local ts = getClientTs()
        if mBuildings.auto == 1 and mBuildings.auto_expire>ts then
            mBuildings.auto = 0
            mBuildings.auto_expire = mBuildings.auto_expire - ts
        end
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
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[2]~=nil and request.push.tb[2]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=bSlot.et,id=uid..bid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    else			
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
