
function api_mail_readAll(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local nType = request.params.type

    local msg = MAIL:mailreadByType(uid, nType)
    
    if msg then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = ''
    end

    return response
end
