function api_mail_read(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local messageid = request.params.eid
    
    local msg = MAIL:mailRead(uid,messageid)
    
    if type(msg) ~= 'table' then
        return response
    end

    local sender = {}
    msg.sender = tonumber(msg.sender) 
    if msg.sender ~= 1 then
        local senderobj = getUserObjs( msg.sender )
        if senderobj then
            local sUserinfo = senderobj.getModel( "userinfo" )
            sender.level = sUserinfo.level
            sender.alliancename = sUserinfo.alliancename
            sender.rank = sUserinfo.rank
            sender.vip = sUserinfo.showvip()
            sender.pic =sUserinfo.pic
            sender.fc = sUserinfo.fc 
            sender.bpic = sUserinfo.bpic 
            sender.apic = sUserinfo.apic
        end
    end

    msg.sendermsg = sender
    if msg then
        response.ret = 0
        response.data.msg = msg
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = ''
    end

    return response
end
