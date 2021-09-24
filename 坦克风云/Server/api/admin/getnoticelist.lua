function api_admin_getnoticelist(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local s = tostring(request.params.s)
    local db = getDbo()
    local result
    local ts = getClientTs() - 86400 * 7

    if s == 'Y' then
        result = db:getAllRows("select * from notice where enabled = 'Y' and time_end > :ts ",{ts=ts})
    elseif s == 'N' then
        result = db:getAllRows("select * from notice where enabled = 'N'")
    elseif s =='A' then
        result = db:getAllRows("select * from notice")
    end 

    response.data.noticelist = result
    response.ret = 0
    response.msg = 'Success'
    
    return response
end