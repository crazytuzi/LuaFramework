function api_building_remove(request)
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
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mBuildings = uobjs.getModel('buildings')

    -- 刷新队列
    mBuildings.update()

    local iSlotKey = mBuildings.checkIdInSlots(bid)
    local bSlot = mBuildings.queue[iSlotKey]
    
    local ret, code = mBuildings.remove(bid,buildType)
    if not ret then
        response.ret = code
        return response
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if uobjs.save() then 	
        response.data.buildings = mBuildings.toArray(true)

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[2]~=nil and request.push.tb[2]==1 and bSlot.et~=nil and bSlot.et >0 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=bSlot.et,id=uid..bid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------  
    else			
        response.ret = -1
    end

    return response
end