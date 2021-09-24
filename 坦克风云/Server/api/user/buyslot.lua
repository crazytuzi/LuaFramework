function api_user_buyslot(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    local iVipLevel = mUserinfo.vip or 0
    local iBuildingSlots = mUserinfo.buildingslots or 2

    -- 已经到vip对应所能购买槽的上限了
    local cfg = getConfig('player')
    if iBuildingSlots >= cfg.vip4BuildQueue[iVipLevel + 1] then 
        response.ret = -2006
        return response
    end

    local price = 0
    for k,v in pairs(cfg.buildQueuePrice) do
        if v == (iBuildingSlots + 1) and  cfg.buildQueuePrice[k+1] then 
            price = cfg.buildQueuePrice[k+1]
            break
        end
    end
    
    if price <= 0 then
        return response
    end

    if not mUserinfo.useGem(price) then
        response.ret = -109 
        return response        
    end

    mUserinfo.buildingslots = iBuildingSlots + 1        

    local mTask = uobjs.getModel('task')
    mTask.check()

    regActionLogs(uid,1,{action=2,item='buildingslots',value=price,params={slotsNum=mUserinfo.buildingslots}})
    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()
        response.data.userinfo = 	mUserinfo.toArray()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
    end

    return response
end
