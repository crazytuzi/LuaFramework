-- 读取事件
function api_skyladderserver_gethistory(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local id = tonumber(request.params.id) or 0

    if not id then
        response.ret = -102
        return response
    end

    require "model.skyladderserver"
    local across = model_skyladderserver()
    local history = across.getHistoryData(id)

    response.ret = 0
    response.msg = 'Success'
    response.data.history = history

    return response
end