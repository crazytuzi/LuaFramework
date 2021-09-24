-- 读取天梯
function api_skyladderserver_refdata(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local bid = tonumber(request.params.bid) or 0
    local zid = tonumber(request.params.zid) or 0
    local id = tonumber(request.params.id) or 0

    if not action or not zid or not id then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local skyladderStatus,err = skyladderserver.getStatus()
    if not skyladderStatus or not skyladderStatus.cubid or tonumber(skyladderStatus.status) == 0 then
        response.ret = -19000
        response.msg = "error"
    end
    
    local rtype
    if action == 1 then
        rtype = 'person'
    elseif action == 2 then
        rtype = 'alliance'
    else
        response.ret = -102
        return response
    end
    
    local cfg = getConfig("skyladderCfg")
    local myrank = skyladderserver.refRank(bid,rtype,zid,id) or 0
    --print('myrank',myrank)
    local rankdata = skyladderserver.refRankData(bid,rtype,zid,id,true) or {}
    --print('rankdata',rankdata)
    local blog = skyladderserver.refLogData(bid,rtype,zid,id) or {}
    --print('blog',blog)

    response.ret = 0
    response.msg = 'Success'
    response.data.rankdata = rankdata
    response.data.myrank = myrank
    response.data.blog = blog

    response.ret = 0
    response.msg = 'Success'

    return response
end