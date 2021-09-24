--  添加到邮件黑名单

function api_mail_addblack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local tid = tonumber(request.params.tid)
    local uobjs = getUserObjs(uid)
    local list  = request.params.list
    uobjs.load({"userinfo", "mailblack"})
    local uMailblack = uobjs.getModel('mailblack')

    if #uMailblack.info>=40 then 
        response.ret=-312
        return response
    end
    local ret =uMailblack.addBlackList(tid)

    if uMailblack.updated_at==0 then
        if list~=nil then
            uMailblack.info=list
        end
    end
    if ret and  uobjs.save() then
        response.ret = 0       
        response.msg = 'Success'
    end
    
    return response


end