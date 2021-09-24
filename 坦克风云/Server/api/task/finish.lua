function api_task_finish(request)
    local response = {}
    response.data={}
    
    local uid = request.uid
    local taskid = request.params.taskid or 't0'
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local task = uobjs.getModel('task')
    task.finish(taskid)
    task.check()   
    processEventsBeforeSave()
    
    if uobjs.save() then
        processEventsAfterSave()
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local mTroop = uobjs.getModel('troops')
        response.data.troops = mTroop.toArray(true)      
        response.data.bag = mBag.toArray(true)
        response.data.task = task.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true) 
        if not response.data.task.info then response.data.task.info = {} end
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
    end
    
    return response
end	