function api_troop_speedup(request)
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
     -- 日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    mDailyTask.changeTaskNum(1,nums)

    -- 刷新队列
    mTroop.update()
    
    local qName = mTroop.bid2Qname(bid)  
    local iSlotKey = mTroop.checkIdInSlots(slotid,qName)   -- 占用的卡槽位置

    if not mTroop.queue[qName] or not mTroop.queue[qName][iSlotKey] then
        return response
    end

    local nums = mTroop.queue[qName][iSlotKey].nums or 0
    local et = tonumber(mTroop.queue[qName][iSlotKey].et) or 0
    local ts = getClientTs()

    if et <= 0 or et < ts or nums <= 0 then
        return response
    end

    -- todo 宝石计算     
    local surplusTime = et - ts
    local iGems = speedConsumeGems(surplusTime)

    --活动检测
    iGems = activity_setopt(uid,'speedupdisc',{speedtype="tankadd", gems=iGems},false,iGems)

    -- 使用资源,（新手引导期不用）
    if mUserinfo.tutorial >= 10 and not mUserinfo.useGem(iGems) then
        response.ret = -109 
        return response
    end

    local aid = mTroop.queue[qName][iSlotKey].id
    mTroop.incrTanks(aid,nums)

    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s102',nums)
    mDailyTask.changeTaskNum1("s1001",nums)

    -- 活动 军备竞赛收集龙珠
    activity_setopt(uid,'armsRace',{[aid]=nums})
    ----5.1钛矿丰收周
    activity_setopt(uid,'taibumperweek',{t=nums})
        -- 打开队列
    if not mTroop.openSlot(iSlotKey,qName) then
        response.ret = -1992
        return response
    end
    
   
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s402',1)
    local mTask = uobjs.getModel('task')
    mTask.check()

    if qName ~= 'tankdiy1' then
         zzbpupdate(uid,{t='f7',id=aid,n=nums})
        -- 远洋征战 士气值
        activity_setopt(uid,'oceanmorale',{act='proShip',id=aid,num=nums})
     else
        zzbpupdate(uid,{t='f8',id=aid,n=nums})
    end

   
    regActionLogs(uid,1,{action=7,item=aid,value=math.ceil(iGems),params={produceNum=nums,troopsNum=mTroop.troops[aid]}})
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
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=et,id=uid..aid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    else
    	response.ret = -1
    end

    return response
end