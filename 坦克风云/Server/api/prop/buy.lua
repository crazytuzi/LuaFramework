function api_prop_buy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local pid = request.params.pid
    local buyNums = tonumber(request.params.num) or 1

    if uid == nil or pid == nil or buyNums < 1 then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    pid = 'p' .. pid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')    
    local mBag = uobjs.getModel('bag')    
    local mUseractive
    
    -- 刷新生产队列
    mProp.update()

    local cfg = getConfig('prop')
    local bPropInfo = cfg[pid]
    
    local iGemCost = bPropInfo.gemCost * buyNums  -- 价格
    local iMaxCount = bPropInfo.maxCount or 0 -- 最大数量   
    local iCurrNums = mBag.getPropNums(pid) --当前拥有的数量

    -- 活动
    local activeName = request.params.activeName
    if activeName then
        mUseractive = uobjs.getModel('useractive')
        local activStatus = mUseractive.getActiveStatus(activeName)

        -- 活动检测
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeParams = {
            pid=pid,
            gems=iGemCost,
            vip=mUserinfo.vip,
            info=request.params,
            onegem=bPropInfo.gemCost,
            num=buyNums,
        }

        local discountGemCost = activity_setopt(uid,activeName,activeParams)
        if not discountGemCost then
            response.ret = -1987
            return response
        end
        
        assert(discountGemCost>buyNums,"discountGemCost: ".. tostring(discountGemCost))
        iGemCost = discountGemCost or iGemCost
    end

    if iGemCost < buyNums then
        return response
    end

    if bPropInfo.isSell ~= 1 and not activeName then
        response.ret = -1983
        return response
    end

    if iCurrNums >= iMaxCount then
        response.ret = -1993
        return response
    end
    
    if not mUserinfo.useGem(iGemCost) then
        response.ret = -109
        return response
    end


    local ret = mBag.add(pid,buyNums)
        
    local mTask = uobjs.getModel('task')
    mTask.check()

    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    mDailyTask.changeNewTaskNum('s405',1)  
    --ceishi leijixiaofei
    --activity_setopt(uid,'totalRecharge',{num=2000})

    -- actionlog 使用金币购买道具
    regActionLogs(uid,1,{action=4,item=pid,value=iGemCost,params={buyNum=buyNums,propNum=mBag.getPropNums(pid)}})

    processEventsBeforeSave()

    if ret and uobjs.save() then           
        processEventsAfterSave()
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        response.data.bag = mBag.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
        
        if activeName and mUseractive then
            mUseractive.setStats(activeName,{pid=pid})
        end
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	

