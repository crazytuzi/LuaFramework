-- 记录分组信息
function api_skyladderserver_getgroup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local gkey = request.params.gkey
    local lsbid = request.params.lsbid

    if not gkey then
        response.ret = -102
        return response
    end

    require "model.skyladderserver"
    local across = model_skyladderserver()
    local base = across.getStatus()
    local countId = tonumber(base.cubid) ~= 0 and base.cubid or 0
    if lsbid then
        countId = lsbid
    end
    local group = across.getgroup(countId,gkey)
    if not group then
        group = {}
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.group = group.info or {}

    return response
end