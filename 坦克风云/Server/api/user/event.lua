function api_user_event(request)
    local response = {
        data={},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    local event = copyTable(mUserinfo.flags.event)
    
    if table.length(mUserinfo.flags.event) > 0 then
        mUserinfo.flags.event = {}
        if uobjs.save() then
            response.data.event = event
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -1
        end
    else
        response.data.event = event
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
