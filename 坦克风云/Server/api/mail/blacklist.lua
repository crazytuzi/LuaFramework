--  邮件黑名单list

function api_mail_blacklist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "mailblack"})
    local uMailblack = uobjs.getModel('mailblack')
    local mailblack={}
    if next(uMailblack.info) then
        for k,v in pairs(uMailblack.info) do
            local tuid=tonumber(v)
            local tuobjs = getUserObjs(tuid,true)
            tuobjs.load({"userinfo", "mailblack"})
            Tuserinfo=tuobjs.getModel("userinfo")
            local tmp={tuid,Tuserinfo.nickname}
            table.insert( mailblack, tmp )
        end
    end 
    response.data.mailblack=mailblack
    response.data.updated_at=uMailblack.updated_at
    response.ret = 0
    response.msg = 'Success'
    return response
end