function api_notice_read(request)
     local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local nid = request.params.nid
    local sysNotice = require "model.notice"
    local msg = sysNotice:readNotice(nid)
    
    response.data.nmsg = msg or ''
    response.ret = 0        
    response.msg = 'Success'

    return response
end
