function api_user_tutorial(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    mUserinfo.tutorial = mUserinfo.tutorial+1

    local mTask = uobjs.getModel('task')
    mTask.check()

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
