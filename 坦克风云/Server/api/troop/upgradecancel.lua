function api_troop_upgradecancel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local bid = request.params.bid and 'b' .. request.params.bid
    local slotid = request.params.slotid

    if uid == nil or bid == nil or slotid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)   
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')

    -- 刷新队列
    mTroop.upgradeupdate()
    
    local qName = mTroop.bid2Qname(bid)
    local iSlotKey = mTroop.checkIdInSlots(slotid,qName)
    local bSlot = mTroop.queue[qName][iSlotKey]

    if type(bSlot) ~= 'table' then
        response.ret = -102
        return response
    end

    local aid = bSlot.id
    local nums = bSlot.nums or 0
    local cfg = getConfig('tank.' .. aid)

    -- todo 返还资源公式 返还值=升级完成剩余时间 / 总时间*升级所需资源 
    local rate = getResRate4Cancel(bSlot.st,bSlot.et)

    -- 改装需要的道具
    local bPropConsume = cfg.upgradePropConsume
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

    local bRes = {}
    bRes.r1 = rate * nums * cfg.upgradeMetalConsume
    bRes.r2 = rate * nums * cfg.upgradeOilConsume
    bRes.r3 = rate * nums * cfg.upgradeSiliconConsume
    bRes.r4 = rate * nums * cfg.upgradeUraniumConsume
    bRes.gold = rate * nums * cfg.upgradeMoneyConsume
    
    -- 增加资源失败
    if not mUserinfo.addResource(bRes) then
        response.ret = -1991 
        return response
    end

    -- 打开队列失败
    if not mTroop.openSlot(iSlotKey,qName) then  
        response.ret = -1997
        return response
    end

    local nums = nums * cfg.upgradeShipConsume[2]
    mTroop.incrTanks(cfg.upgradeShipConsume[1],nums)
    
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
    end

    return response
end
