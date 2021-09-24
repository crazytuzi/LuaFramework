function api_admin_createcard(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    
    local ctype = tonumber(request.params.type)
    local st = tonumber(request.params.st)
    local et = tonumber(request.params.et)
    local num = tonumber(request.params.num) or 0

    if not ctype or not st or not et or not num <= 0 then
        response.ret = -102
        return response
    end

    local mCard = require "model.card"
    local cards = mCard:create(ctype,num,st,et)

    if cards then
        response.data.cards = cards
        response.ret = 0
        response.msg = 'Success'
    end

    return self.response
end