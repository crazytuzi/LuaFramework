-- 发送捷报
function api_mail_sendnews(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mail_type = request.params.type
    -- 类型 1 接收，2战报
    local subject = request.params.title
    local content = request.params.content
    local mail_to = request.params.name
    
    local ts=getClientTs()
    local mail = MAIL:mailSent(uid,1,uid,"",mail_to,subject,content,mail_type,0)

    if mail then
        response.data.eid = mail.eid
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
