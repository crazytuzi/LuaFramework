function api_user_dailyhonors(request)
    local response = {}
    response.data={}
    
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    
    local mUserinfo = uobjs.getModel('userinfo')
    mUserinfo.dailyHonors(request.params.type)
        
    local mTask = uobjs.getModel('task')
    mTask.check()

    if request.params.type > 1 then
        local consume = {0,10,40,90}
        regActionLogs(uid,1,{action=12,item='honnors',value=consume[request.params.type],params={honorsNum=mUserinfo.honors}})
    end

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end
    
    return response
end	