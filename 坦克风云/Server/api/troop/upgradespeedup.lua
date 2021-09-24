function api_troop_upgradespeedup(request)
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

    if type(mTroop.queue[qName][iSlotKey]) ~= 'table' then  
        response.ret = -102
        return response
    end

    local et = tonumber(mTroop.queue[qName][iSlotKey].et) or 0
    local ts = getClientTs()   

    if not (et > 0 and et > ts) then
        return response
    end

    -- todo 宝石计算     
    local surplusTime = et - ts
    local iGems = speedConsumeGems(surplusTime)

    --活动检测
    iGems = activity_setopt(uid,'speedupdisc',{speedtype="tankdiy", gems=iGems},false,iGems)

    -- 使用资源
    if  not mUserinfo.useGem(iGems) then   
        response.ret = -109  
        return response
    end

    local aid = mTroop.queue[qName][iSlotKey].id
    local troopNums = mTroop.queue[qName][iSlotKey].nums
    --军 备换代活动
    local v = activity_setopt(uid, "armamentsUpdate1", {type=1, v={id=aid, nums=troopNums}}) or {id=aid, nums=troopNums}
    v = activity_setopt(uid, "armamentsUpdate2", {type=1, v=v}) or v
    aid, troopNums = v.id, v.nums

    mTroop.incrTanks(aid,troopNums)

    -- 活动 军备竞赛收集龙珠
    activity_setopt(uid,'armsRace',{[aid]=troopNums})
    ----5.1钛矿丰收周
    activity_setopt(uid,'taibumperweek',{t=troopNums})
    if not mTroop.openSlot(iSlotKey,qName)  then
        response.ret = -1992  
        return response
    end
    --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s402',1)
    local mTask = uobjs.getModel('task')
    mTask.check()

    regActionLogs(uid,1,{action=10,item=aid,value=iGems,params={produceNum=troopNums,troopsNum=mTroop.troops[aid]}})
    processEventsBeforeSave()

    if qName ~= 'tankdiy1' then
         zzbpupdate(uid,{t='f7',id=aid,n=troopNums})
        -- 远洋征战 士气值
        activity_setopt(uid,'oceanmorale',{act='proShip',id=aid,num=troopNums})
    else
        zzbpupdate(uid,{t='f8',id=aid,n=troopNums})
    end


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