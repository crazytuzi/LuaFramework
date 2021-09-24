-- 获取世界大战最终排名信息

function api_admin_getworldwarrank(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local bids = request.params.bids
    if type(bids)~='table' or not next(bids) then 
        return response
    end
    local acrossserver = require "model.worldserver"
    local across = acrossserver.new()
    local db  = getCrossDbo("worldwarserver")
    for k,bid in pairs (bids) do
        response.data[bid]={}
        local  master,elite=  across:getUserEndRanking(bid)
        if master then
            response.data[bid]['master']=master
        end
        if elite then
            response.data[bid]['elite']=elite
        end
        
    end
    return response


end