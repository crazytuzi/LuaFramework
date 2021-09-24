function api_active_finish(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local aname = tostring(request.params.aname)

     if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    local mUseractive = uobjs.getModel('useractive')
    
    local ret = mUseractive.finish(aname)

    local mTask = uobjs.getModel('task')
    mTask.check()

    if ret and uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
