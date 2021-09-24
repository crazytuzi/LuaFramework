-- 记录
function api_fleetgo_report(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fleetgo') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    if not uid then
        response.ret = -102
        return response
    end
    local redis =getRedis()
    local redkey ="zid."..getZoneId().."fleetgoreport".."uid."..uid    
    local data =redis:get(redkey)
    data =json.decode(data)
    if type(data) ~= 'table' then data = {} end
    response.ret = 0
    response.msg = 'Success'
    response.data.report=data

    return response


end