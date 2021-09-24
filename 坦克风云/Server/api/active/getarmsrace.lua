--后去军备竞赛的数据

function api_active_getarmsrace(request)
    
    local response = {
        ret=-1,
        msg="error",
        data={useractive={}}
    }


    local uid = request.uid
    local uobjs = getUserObjs(uid)
       uobjs.load({"userinfo","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')


    local acname = "armsRace"

    -- 状态检测
    local activStatus = mUseractive.getActiveStatus(acname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    response.data.useractive[acname]=mUseractive.info[acname]
    response.ret = 0        
    response.msg = 'Success'
    return response
end