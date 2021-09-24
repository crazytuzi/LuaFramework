-- 返回跨服战用户的信息


function api_acrossserver_getuser(request)
    local response = {
        ret=0,
        msg='error',
        data = {
            
        },
    }

    local uid = tonumber(request.params.uid)
    local zid = request.zoneid
    local bid = request.params.bid    
    local aid = request.params.aid
    print(uid)
    if uid<=0 or bid==nil  then
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)
 

   
    local ret =across:getUserInFo(bid,zid,uid)
    if not ret then
        response.err = err
        response.ret = -102
        return response
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.userinfo=ret
    return response


end