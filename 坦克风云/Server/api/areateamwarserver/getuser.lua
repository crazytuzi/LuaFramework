-- 返回跨服战用户的信息

--获取参加跨服区域战个人信息
function api_areateamwarserver_getuser(request)
    local response = {
        ret=0,
        msg='error',
        data = {
            
        },
    }

    local uid = tonumber(request.params.uid)
    local zid = request.params.zid
    local bid = request.params.bid    
    local aid = request.params.aid
    -- print(uid)
    if uid<=0 or bid==nil  then
        return response
    end

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(nil,bid)

    local ret =mAreaWar.getUserInFo(bid,zid,uid,aid)
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