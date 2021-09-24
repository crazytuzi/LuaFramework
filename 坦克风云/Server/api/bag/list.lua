function api_bag_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    
    if uid == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task"})
    local mProp = uobjs.getModel('props')
    local mBag = uobjs.getModel('bag')

    -- 刷新当前生产队列
    mProp.update()    
    response.data.bag = mBag.toArray(true)

    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if uobjs.save() then 
        processEventsAfterSave()
        
        response.data.bag = mBag.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	