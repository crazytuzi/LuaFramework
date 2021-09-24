function api_admin_mail(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }
    
    local mailbody = {
        uid         = 0,
        sender      = 0,
        receiver    = 0,
        type        = 1,
        mail_from   = '',
        mail_to     = '',
        subject     = '',
        content     = '',
        gift        = 0,
        item        ='',
    }
    
    local URL = require "lib.url"

    if request.params.uid then
        mailbody.uid = request.params.uid
        mailbody.receiver = request.params.uid
    else
        return self.response
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
    mailbody.update_at = getClientTs()
    local ret = MAIL:mailSent(mailbody.receiver,0,mailbody.receiver,'',mail_to,mailbody.subject,mailbody.content,mailbody.type,0,mailbody.gift,mailbody.item)
    
    if ret then
        self.response.ret = 0
        self.response.msg = 'Success'
    end

    return self.response
end