-- 设置天梯榜开关状态a
function api_skyladderserver_setstatus(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local params = {
        cubid = request.params.cubid, -- 当前的赛季id
        lsbid = request.params.lsbid, -- 上一次结束的赛季id
        status = request.params.status or 1, -- 开关状态
        over = request.params.over, -- 是否已结算
        overtime = request.params.overtime, -- 结算的时间点
    }
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    skyladderserver.setautocommit(false)
    local base = skyladderserver.getStatus()
    
    if tonumber(request.params.cubid) > tonumber(base.cubid) then
        -- if tonumber(base.nextready) ~= 1 then
           -- response.ret = -19004
           -- response.err = err
           -- return response 
        -- end
    end
    
    local skyladderStatus,err = skyladderserver.setStatus(params)
    if not skyladderStatus then
        response.ret = -19001
        response.err = err
        return response
    end

    if skyladderserver.commit() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end