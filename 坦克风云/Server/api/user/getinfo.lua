function api_user_getinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }   

    local uid = request.params.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid,true)
    local userinfo = uobjs.getModel('userinfo')
    
    local info = {}
    -- table.insert(info,userinfo.uid)
    -- table.insert(info,userinfo.nickname)
    table.insert(info,userinfo.level)
    table.insert(info,userinfo.fc)
    table.insert(info,userinfo.pic)
    table.insert(info,userinfo.alliancename)

    response.data.usergetinfo = info

    response.ret=0
    response.msg ='Success'
    return response

end