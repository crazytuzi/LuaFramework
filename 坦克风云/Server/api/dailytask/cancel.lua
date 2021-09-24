function api_dailytask_cancel(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mDailytask = uobjs.getModel('dailytask')
    local status = mDailytask.cancel(request.params.taskid)
    response.data.status = status

    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if status == 1 and uobjs.save() then        
        processEventsAfterSave()
        response.ret = 0        
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
