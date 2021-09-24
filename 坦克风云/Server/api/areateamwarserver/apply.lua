-- 报名服务端
function api_areateamwarserver_apply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local data = request.params.data
    local action=request.params.action
    if data==nil then
        response.ret=-102
        return response
    end

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct()
    mAreaWar.setRedis(data.bid)
    if action=='apply' then
        local ret=mAreaWar.apply(data)
        if ret and ret > 0 then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-8043
        end
    elseif action=='applyrank' then
        local reslut=mAreaWar.getApplyRank(data.bid)
        response.ret = 0
        response.msg = 'Success'
        response.data.ranklist=reslut
    end
    
    return response
end
