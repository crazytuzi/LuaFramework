function api_dailytask_reset(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mDailytask = uobjs.getModel('dailytask')
    local status,cost = mDailytask.reset()
    response.data.status = status

    local mTask = uobjs.getModel('task')
    mTask.check()

    -- actionLog
    regActionLogs(uid,1,{action=19,item="dailytaskreset",value=cost,params={}})

    processEventsBeforeSave()

    if status == 1 and uobjs.save() then
        processEventsAfterSave()

        local mUserinfo = uobjs.getModel('userinfo')   
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        --response.data.dailytask = mDailytask.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
