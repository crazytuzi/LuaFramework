-- 设置多个用户数据
function api_crossserver_setusers(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local params = request.params.udata
    
    if params == nil then
        response.ret = -102
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local bidDataNums = nil

    cross:setautocommit(false)

    for k,v in pairs(params) do              
        local tmp = cross.formatServerUserData(v)        
        if not bidDataNums then bidDataNums = cross:countBattleDataByBid(tmp.bid) end  
        bidDataNums = bidDataNums + 1
        cross:setUserBattleData(tmp)
    end

    if not bidDataNums or bidDataNums > 16 then 
        response.err = 'bidNums:' .. (bidDataNums or "not bidNums")
        return response
    end

    if not cross:commit() then
        response.err = cross.db:getError()
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
