function api_mail_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local maxeid = request.params.maxeid
    local mineid = request.params.mineid
    local mailType = request.params.type
    local isPage = request.params.isPage

    if uid == nil or maxeid == nil or mineid == nil or mailType == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local mail_list = MAIL:mailList(uid,maxeid,mineid,mailType,isPage)
 
    if mail_list then
        -- 邮件的event事件拿掉
        -- local uobjs = getUserObjs(uid)
        -- local mUserinfo = uobjs.getModel('userinfo')
        -- if mUserinfo.flags.event.m then
        --     mUserinfo.flags.event.m = nil
        --     uobjs.save()
        -- end
        
        response.ret = 0
        response.data.mail = mail_list
        response.msg = 'Success'   
    end

    return response
end
