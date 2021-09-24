function api_skyladderserver_getmemlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local zid = tonumber(request.params.zid)
    local id = tonumber(request.params.id)

    if not id then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local across = model_skyladderserver()

    local base = across.getStatus()
    local data = across.getAllianceMemberList(base.cubid,0,zid,id) or {}

    if type(data) == 'string' then
        data = json.decode(data) or {}
    end
    local memList = data
    
    response.ret = 0
    response.msg = 'Success'
    response.data.memList = memList

    return response
end