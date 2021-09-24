-- 设置天梯榜开关状态a
function api_skyladderserver_nextseasondata(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local params = {
        nextreadytime = request.params.nextreadytime, -- 结算的时间点
    }
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    skyladderserver.setautocommit(false)
    local base = skyladderserver.getStatus()
    
    if not base or not base.cubid or tonumber(base.status) == 0 then
        response.ret = -19000
        response.msg = "error"
        return response
    end
    
    if tonumber(base.over) ~= 1 then
        response.ret = -19005
        response.err = err
        return response 
    end    

    if base and type(base) == 'table' and tonumber(base.cubid) > 0 then
        local skyladderStatus,err = skyladderserver.changeStatus(base.cubid,params)
        if not skyladderStatus then
            response.ret = -19001
            response.err = err
            return response
        end
    end

    if skyladderserver.commit() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end