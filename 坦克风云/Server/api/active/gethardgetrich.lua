function api_active_gethardgetrich(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }


    local uid = request.uid
    local rid= tostring(request.params.rid) or ''
    local uobjs = getUserObjs(uid)
       uobjs.load({"userinfo","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')


    local acname = "hardGetRich"

    -- 状态检测
    local activStatus = mUseractive.getActiveStatus(acname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end


    response.data.res=(mUseractive.info[acname].res) or 0
    response.ret = 0        
    response.msg = 'Success'
    return response
end
