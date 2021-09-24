-- 获取战斗中的用户数据
function api_crossserver_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            d = {},
        },
    }
    
    -- 战斗标识
    local info = request.params.info
    local bid = request.params.bid
    
    if info == nil or bid == nil then
        response.ret = -102
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()
    
    local datas = cross:getBattleDataByBid(bid)
    
    if datas then        
        for k,v in pairs(datas) do 
            local tmp = {uid=v.uid}
            for _,n in pairs(info) do
                if v[n] then
                    tmp[n] = v[n]
                end
            end            
            table.insert(response.data.d,tmp)
        end                
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
