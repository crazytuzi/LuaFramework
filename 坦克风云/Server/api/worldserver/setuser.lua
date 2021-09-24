-- 报名或者是设置部队

function api_worldserver_setuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local data = request.params.data
    local action = request.params.action or 'apply'

    if not data or not data.bid then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.worldserver"
    local across = acrossserver.new()

    local ret, err

    local matchType = data.jointype
    data.jointype=nil
    data.servers = nil

    local ret,err 
    -- 如果是报名，需要验证所属军团是否已经报名
   
    ret,err =across:getUserApplyData(data.bid,data.zid,data.uid,matchType)
    if ret then
        data.st = nil
        data.et = nil
        ret,err = across:updateUserApplyData(ret.id,data,matchType)
    else
        local bidData = across:getBidDataById(data.bid,matchType)
        
        if not bidData then
            ret,err = across:setBidData({bid=data.bid,st=data.st,et=data.et,matchType=matchType})
            if not ret then
                response.err = err
                response.ret = -22012
                return response
            end
        end

        data.st = nil
        data.et = nil

        ret,err = across:setUserApplyData(data,matchType)
        across:setUserApplyNum(data.bid,matchType)
    end
    if not ret then
        response.err = err
        response.ret = -22012
        response.data.jointype=jointype
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response



end