function api_admin_upallianceskill(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }    
    local aid = tonumber(request.params.aid)
    local s = request.params.s
    s = json.encode(s)
    local ret = M_alliance.upallianceskill{aid=aid,s=s}
    response.data.upallianceskill = ret

    response.ret = 0
    response.msg = 'Success'

    return response
end