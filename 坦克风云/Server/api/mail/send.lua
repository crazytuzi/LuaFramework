function api_mail_send(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

    local mail_type = request.params.type   or tankError('mailType invalid') -- 类型 1 接收，2战报
    local subject = request.params.title  or tankError('subject invalid')
    local content = request.params.content or tankError('content invalid')
    local mail_to = request.params.name or tankError('rid invalid')
    
    -- 如果直接传了接收者的ID,直接用ID发送
    local receiverId = request.params.receiverId -- 邮件接收者的ID
    local receiver = 0
    if receiverId then
        receiver = userGetUid(receiverId)
    elseif request.params.name then
        receiver = userGetUidByNickname(request.params.name)
    end
    
    local mailLimit = moduleIsEnabled("emailLimit") 
    if receiver < 1 or receiver == uid or mUserinfo.level < mailLimit then 
        response.ret = -104 
        return response
    end

    local tuobjs = getUserObjs(receiver,true)
    local TuMailblack = tuobjs.getModel('mailblack')

    local mail = MAIL:mailSent(uid,uid,receiver,mUserinfo.nickname,mail_to,subject,content,3,1)
    local flag=table.contains(TuMailblack.info,uid)
    if not flag then
       MAIL:mailSent(receiver,uid,receiver,mUserinfo.nickname,mail_to,subject,content,mail_type)
    end
    
    
    local receiverObjs = getUserObjs(receiver)
    receiverObjs.save()
    uobjs.save()

    if mail then
        response.data.eid = mail.eid
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
