-- 结算
function api_skyladderserver_startover(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }
    
    local ts = getClientTs()
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    skyladderserver.setautocommit(false)
    local skyladderStatus,err = skyladderserver.getStatus()
    
    if not skyladderStatus or not skyladderStatus.cubid or tonumber(skyladderStatus.status) == 0 then
        response.ret = -19000
        response.msg = "error"
        return response
    end
    
    if not skyladderStatus or not skyladderStatus.cubid or tonumber(skyladderStatus.over) == 1 then
        response.ret = -19001
        response.err = err
        return response
    end
    
    local overtime = tonumber(skyladderStatus.overtime) or 0
    if overtime > 0 and overtime <= ts then
        skyladderserver.setOver(skyladderStatus.cubid)
        if skyladderserver.commit() then
            response.ret = 0
            response.msg = 'Success'
            response.data = {over=1}
        end
    end
    
    writeLog(json.encode(response),'skyladderCheckOver')

    return response
end