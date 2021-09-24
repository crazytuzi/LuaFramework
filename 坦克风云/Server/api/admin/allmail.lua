function api_admin_allmail(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    local mailbody = {
        st         = 0,
        et      = 0,
        type        = 1,
        subject     = '',
        content     = '',
        gift        = 0,
        item        ='',
    }

    local URL = require "lib.url"
    local appid = request.appid and tonumber(request.appid) or 0

    if request.params.st then

        mailbody.st = request.params.st
    end
    if request.params.et then
        mailbody.et = request.params.et
    end
    if request.params.subject then
        mailbody.subject = URL:url_unescape(request.params.subject)
    end

    if request.params.content then
        mailbody.content = URL:url_unescape(request.params.content)
    end
    if request.params.gift then
        mailbody.gift =request.params.gift
    end

    if request.params.item then
        mailbody.item =request.params.item
    end

    local limittype = tonumber(request.params.limittype) or 0
    local min = tonumber(request.params.min) or 0
    local max = tonumber(request.params.max) or 0
    local lastlogintime = tonumber(request.params.lastlogintime) or 0

    --sentSysMail(st,et,subject,content,mail_type,gift,item)
    local ret = MAIL:sentSysMail(mailbody.st,mailbody.et,mailbody.subject,mailbody.content,mailbody.type,mailbody.gift,mailbody.item, 0, appid, limittype, min, max,lastlogintime)
    if ret then
        self.response.ret = 0
        self.response.msg = 'Success'
    end

    return self.response
end