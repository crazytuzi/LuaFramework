function api_admin_notice(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }
    
    local URL = require "lib.url"
    local appid = request.appid and tonumber(request.appid) or 0
    request.params.title = URL:url_unescape(request.params.title)
    request.params.content = URL:url_unescape(request.params.content)
    request.params.appid = appid
    local db = getDbo()

    local ret = db:insert('notice',request.params)
    if ret and ret > 0 then
        self.response.ret = 0
        self.response.msg = 'Success'
    end

    return self.response
end