function api_user_rankup(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    
    response.data.status = mUserinfo.rankLevelUp()

    local mTask = uobjs.getModel('task')
    mTask.check()

    if response.data.status == 1 and uobjs.save() then
        processEventsAfterSave()
        
        response.ret = 0
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
