function api_user_troopsup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","bag","task","dailytask"})
    local mUserinfo = uobjs.getModel('userinfo')

    local upLevel = (mUserinfo.troops or 0) + 1 

    if upLevel > mUserinfo.level then
        response.ret = -2003
        return response
    end

    local consumeN = 0
    --升级带兵量根据不同平台配置不同
    local platFlag = moduleIsEnabled('luck')
    if platFlag == 1 then
        local luckFlag = getConfig('player.commander_lucky_val')
        if luckFlag then
            response.data.status,response.data.ConsumeType,consumeN = mUserinfo.troopsLevelUpByLuck()
        else
            response.data.status,response.data.ConsumeType,consumeN = mUserinfo.troopsLevelUp()
        end
    else
        response.data.status,response.data.ConsumeType,consumeN = mUserinfo.troopsLevelUp()
    end

    local mTask = uobjs.getModel('task')
    mTask.check()
  
    if response.data.ConsumeType == 2 then
	local mDailyTask = uobjs.getModel('dailytask')
	--新的日常任务检测
	mDailyTask.changeNewTaskNum('s405',1)  
        regActionLogs(uid,1,{action=1,item='troopsup',value=consumeN,params={upNum=response.data.status,troopsLevel=mUserinfo.troops}})
    end
    processEventsBeforeSave()

    -- 版号2额外送一点声望
    if getClientBH() == 2 then
        if response.data.status == 1 then
            mUserinfo.addResource{honors=1}
            response.data.bhreward={1}
        else
            mUserinfo.addResource{honors=2}
            response.data.bhreward={1,1}
        end
    end

    if setUserDailyActionNum(uid,'troopsup') > 10 then
        response.ret = -1973
        return response
    end

    if uobjs.save() then
        processEventsAfterSave()
        local mBag = uobjs.getModel('bag')        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
