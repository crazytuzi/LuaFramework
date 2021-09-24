-- 记录分组信息
function api_skyladderserver_getstatus(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    require "model.skyladderserver"
    local across = model_skyladderserver()
    
    local skyladderStatus = across.getStatus()
    if not skyladderStatus then
        response.ret = -19003
        return response
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.base = skyladderStatus

    return response
end