function api_admin_getallmail(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local s = tostring(request.params.s)
    local db = getDbo()
    local result
    local ts = getClientTs() - 86400 * 7

   
    result = db:getAllRows("select * from sysmail where et> :ts ",{ts=ts})
   
    response.data.noticelist = result
    response.ret = 0
    response.msg = 'Success'
    
    return response
end