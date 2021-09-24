-- 移除黑名单

function api_mail_removeblack(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local tid = request.params.tid
    local uobjs = getUserObjs(uid)
    
    uobjs.load({"userinfo", "mailblack"})
    local uMailblack = uobjs.getModel('mailblack')
 

    local ret =uMailblack.removeBlackList(tid)

    if ret and  uobjs.save() then
        response.ret = 0       
        response.msg = 'Success'
    end
    
    return response
end