function api_admin_setnotice(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local s = tostring(request.params.s)
    local id = tonumber(request.params.id)

    request.params.id = nil
    local URL = require "lib.url"
    if request.params.title then
    	request.params.title = URL:url_unescape(request.params.title)
    end
    
    if request.params.content then
    	request.params.content = URL:url_unescape(request.params.content)
    end
   
    if not id then
        response.ret = -102
        return response
    end

    local db = getDbo()
    local ret = db:update("notice",request.params,"id="..id)
    
    if ret and ret > 0 then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
