function api_admin_setallmail(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    
    local id = tonumber(request.params.id)
    local st = tonumber(request.params.st)
    local subject = request.params.subject
    request.params.id = nil
    local URL = require "lib.url"

    if request.params.subject then
        request.params.subject = URL:url_unescape(request.params.subject)
    end
    
    if request.params.content then
        request.params.content = URL:url_unescape(request.params.content)
    end
    
    local db = getDbo()
    local redis = getRedis()
     local ret
    if not id then
        local subject= URL:url_unescape(subject)
        ret =db:query("delete from sysmail  where st ="..st.." and  subject=".."'"..subject.."'" )
    else
       ret = db:update("sysmail",request.params,"id="..id)
    end
    
   
    
    if ret and ret > 0  then
        local key = "z"..getZoneId()..".alluser.sysmailinfo"
        redis:del(key)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
