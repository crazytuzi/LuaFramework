-- 获取时间列表

function api_userwar_geteventlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local bid  = request.params.bid  or 116864
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end

    local maxeid = request.params.maxeid or 0
    local mineid = request.params.mineid or 0
    local userwarlogLib = require "lib.userwarlog"
    --userwarlogLib:userSend(uid,1,116855,{1,1,0,0,2,{10},0})
    local data = userwarlogLib:userList(uid,bid,maxeid,mineid)
    local list = {}
    for i,v in pairs(data) do
        if v.content then
            v.content = json.decode(v.content) or {}
            table.insert(list,v)
        end
    end

    if list then
        response.data.userwarlog = list
        response.data.count = tonumber(userwarlogLib:logCount(uid,bid))
    end
    
    response.ret=0
    response.msg = 'Success' 
    return response
end