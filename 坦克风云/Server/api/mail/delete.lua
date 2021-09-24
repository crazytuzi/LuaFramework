function api_mail_delete(request)
    local response = {
        data = {},
    }

    local uid = request.uid
    local messageid = request.params.eid
    local mail_type = request.params.type

    local ret = MAIL:mailDel(uid,messageid,mail_type)

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    
    local lmailcount = MAIL:lockmailCount(uid)
    if tonumber(lmailcount) and tonumber(mUserinfo.flags.lmail) ~= tonumber(lmailcount) then
        mUserinfo.flags.lmail = lmailcount
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
