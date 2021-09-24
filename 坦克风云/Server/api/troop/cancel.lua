function api_troop_cancel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid    
    local bid = request.params.bid
    local slotid = request.params.slotid

    if uid == nil or bid == nil or slotid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    bid = 'b' .. bid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')

    -- 刷新队列
    mTroop.update()

    local qName = mTroop.bid2Qname(bid)        
    local iSlotKey = mTroop.checkIdInSlots(slotid,qName)
    local bSlot = mTroop.queue[qName][iSlotKey]
    
    if type(bSlot) ~= 'table' then
        response.ret = -1989 
        return response
    end

    local aid = assert2(bSlot.id,'aid invalid')
    local nums = assert2(bSlot.nums,'num invalid')
    local cfg = getConfig('tank.' .. aid)
    
    local rate = getResRate4Cancel(bSlot.st,bSlot.et)     

    local bRes = {}
    bRes.r1 = rate * nums * cfg.metalConsume
    bRes.r2 = rate * nums * cfg.oilConsume
    bRes.r3 = rate * nums * cfg.siliconConsume
    bRes.r4 = rate * nums * cfg.uraniumConsume
        
    -- 使用资源
    if not mUserinfo.addResource(bRes) then   
        response.ret = -1991
        return response
    end

    -- 添加道具
    local bPropConsume = cfg.propConsume
    if type(bPropConsume) == 'table' and next(bPropConsume) then
        local mBag = uobjs.getModel('bag')
        
        for _,v in ipairs(bPropConsume) do
            local tmpNum = math.floor(v[2] * nums * rate)
            if tmpNum > 0 then
                if not mBag.add(v[1],tmpNum) then
                    response.ret = -1991
                    return response
                end
            end
        end
        response.data.bag = mBag.toArray(true)
    end

    -- 打开队列
    if not mTroop.openSlot(iSlotKey,qName) then
        response.ret = -1992
        return response
    end
    
    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if uobjs.save() then  
        processEventsAfterSave()       
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)	        
        response.ret = 0
        response.msg = 'Success'

        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[4]~=nil and request.push.tb[4]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=bSlot.et,id=uid..aid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    else
        response.ret = -1
        response.msg = 'save failed'
    end

    return response
end
