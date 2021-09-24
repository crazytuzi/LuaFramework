-- 
function api_admin_userdata(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    writeLog(request, 'userdata')
    local idx = request.params.idx
    local userids = request.params.uids

    local self = {}

    function self.getuser()
        -- body
        local ret = {}
        if not userids then
            writeLog(userids, 'userdata')
            return ret
        end

        for k, uid in pairs(userids) do
            local uobjs = getUserObjs(uid)
            local mUserinfo = uobjs.getModel('userinfo')

            table.insert(ret, {uid, mUserinfo.nickname, mUserinfo.level, mUserinfo.vip})

        end

        return ret        
    end


    --------------------------main---------------------------------

    if idx == 'userinfo' then
        response.data.userinfo = self.getuser()
    end

    response.msg ='success'
    response.ret = 0

    return response
end
