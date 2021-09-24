function api_admin_getuserinfo(request)
    local response = {
        data       				= {},
        config    		 		= {},
        ret        				= 0,
        msg        				= 'Success'
    }

    local uid      				= tonumber(request.uid)
    local name      		    = request.params.name
    if uid == nil then
        response.ret = -1
        response.msg = 'params invalid'
        return response
    end

    require "lib.admin"
    if uid == 1000001 then
        local tmp = get_id_by_name(name)
        local length =  table.length(tmp)
        local ret = tonumber(rand(1,length))
        uid = tmp[ret]["uid"]
    end
    local result = getMemberInfo(tonumber(uid))

    if result then
        response.data.userinfo	= result
        response.ret 			= 0
        response.msg 			= 'Success'
--        ptb:p(response.data.userinfo)
    else
        response.ret 			= -1
        response.msg 			= "save failed"
    end
    return response
end