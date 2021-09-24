function api_dailytask_refresh(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mDailytask = uobjs.getModel('dailytask')

    local cost = 8
    mDailytask.useGemRefresh(cost)

    local mTask = uobjs.getModel('task')
    mTask.check()

    --刷新日常任务消费
    regActionLogs(uid,1,{action=17,item="dailytask",value=cost,params={}})
    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()        
        local mUserinfo = uobjs.getModel('userinfo')        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.dailytask = mDailytask.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
