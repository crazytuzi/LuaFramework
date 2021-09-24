-- 重置排行榜
function api_skyladderserver_resetrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local bid = tonumber(request.params.bid)
    local rtype = request.params.type
    local all = request.params.all

    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    
    local num,resetnum = skyladderserver.resetPointRank(bid,rtype,all)
    skyladderserver.refRanking(bid,rtype,1,100)
    
    response.ret = 0
    response.msg = 'Success'
    response.data.result = {num,resetnum}

    return response
end